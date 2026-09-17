using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using System.Web.Mvc;
using YYT.BLL.EF;
using YYT.BLL.Services.GameServer;
using YYT.Common;
using YYT.Entity;
using YYT.Web.Controllers;

namespace YYT.Web.Areas.Game.Controllers
{
    public class UserCtrlRow
    {
        public int CtrlType { get; set; }
        public int CtrlValue { get; set; }
        public int Number { get; set; }
        public int TotalNumber { get; set; }
    }

    public class UserInfoController : BaseController
    {
        static readonly string REG_TOKEN = "yyt_reg_token";
        public bool LogSwitch { get; }

        public UserInfoController()
        {
            LogSwitch = (ConfigHelper.GetInt("logSwitch") == 1);
        }

        [MemberAuthorize]
        // GET: Game/UserInfo
        public ActionResult Index()
        {
            return View();
        }
        public ActionResult OnlinePlayers()
        {
            return View();
        }
        public ActionResult OnlineUsers()
        {
            return View();
        }
        [MemberAuthorize]
        [AjaxOnly]
        [HttpPost]
        public ActionResult GetOnlineUsers()
        {
            Msg msg = new Msg(0, "查询失败！");
            try
            {
                M_LoginUser loginUser = WebHelper.GetLoginInfo();
                if (loginUser == null)
                    return Json(msg);

                List<OnlinePlayerInfo> players = new PlayerStateService().QueryAllOnlinePlayers();
                if (players == null)
                {
                    // 游戏服不可达/超时（管道失败或熔断冷却中）：返回失败态而不是空列表。
                    // 端上才能区分"确实没人在线"与"查不到"——手机端保留上一次的列表并提示，
                    // 电脑端在线用户页弹提示文案（该页 code != 1 走 showMsg）。
                    msg.code = 0;
                    msg.content = "游戏服暂无响应，请稍后重试！";
                    return Json(msg);
                }

                // 游戏服返回的是全量在线玩家；先用一次批量查询裁剪到当前代理可见范围，避免泄露线外玩家。
                List<string> ids = players.Where(c => !string.IsNullOrWhiteSpace(c.ID))
                    .Select(c => c.ID).Distinct().ToList();
                B_Users usersBll = new B_Users();
                HashSet<string> visibleIds = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
                Dictionary<string, M_Users_DTO> visibleRows = new Dictionary<string, M_Users_DTO>(StringComparer.OrdinalIgnoreCase);
                for (int i = 0; i < ids.Count; i += 100)
                {
                    // 游戏服结果已包含当前游戏/桌台等实时字段，此处只补权限、基础资料和输赢统计。
                    foreach (M_Users_DTO row in usersBll.GetUserRowsByIds(ids.Skip(i).Take(100).ToList(), loginUser, false))
                    {
                        visibleIds.Add(row.ID);
                        visibleRows[row.ID] = row;
                    }
                }
                players = players.Where(c => !string.IsNullOrWhiteSpace(c.ID) && visibleIds.Contains(c.ID)).ToList();
                // GetUserRowsByIds 已完成权限裁剪、总盈亏和今日输赢补充，直接复用结果，
                // 避免在线列表再发起两轮相同的数据库查询。
                foreach (OnlinePlayerInfo player in players)
                {
                    M_Users_DTO row;
                    if (!visibleRows.TryGetValue(player.ID, out row))
                        continue;
                    player.NAME = string.IsNullOrWhiteSpace(row.NAME) ? player.NAME : row.NAME;
                    player.AGENCY = row.AGENCY;
                    player.FROZEN = row.FROZEN ?? 0;
                    player.Profit = row.Profit ?? 0;
                    player.TodayWinLoss = row.TodayWinLoss ?? 0;
                }
                FillPlayerLastLogin(players);
                msg.code = 1;
                msg.content = "查询成功！";
                msg.datas = players;
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.UserInfoController), $"GetOnlineUsers Err >> {ex.Message} \r\n");
            }
            return Json(msg);
        }
        /// <summary>
        /// 补充最近登录时间，避免在线/离线卡片字段不一致。
        /// 数据源分两段（运营反馈"玩家登录时后台登录时间不更新"后的口径修正）：
        ///   1) userloginrecord：玩家上线瞬间由库内触发器写入的真实登录时间
        ///      （见 Docs/sql/玩家登录时间-20260918.sql，游戏服只写 users.INHALL，从不写登录日志）；
        ///   2) 没有登录记录的账号（补丁上线前的老数据）回退 useroptlog 的最后操作时间——
        ///      那是"最后进桌台/充退"的时间，不等于登录时间，只作兜底。
        /// 在线卡片同样走这条链路，玩家一上线这里就会变成本次登录时间。
        /// </summary>
        private void FillPlayerLastLogin(List<OnlinePlayerInfo> players)
        {
            if (players == null || players.Count < 1)
                return;
            List<string> ids = players.Where(c => !string.IsNullOrWhiteSpace(c.ID)).Select(c => c.ID).Distinct().ToList();
            if (ids.Count < 1)
                return;
            try
            {
                using (var ef = new GameDbContext())
                {
                    Dictionary<string, DateTime?> loginMap = new Dictionary<string, DateTime?>(StringComparer.OrdinalIgnoreCase);
                    try
                    {
                        string placeholders = string.Join(",", ids.Select((c, i) => "{" + i + "}"));
                        string sql = "SELECT UserID, MAX(LoginTime) AS LastLoginTime FROM userloginrecord WHERE UserID IN (" + placeholders + ") GROUP BY UserID";
                        loginMap = ef.Database.SqlQuery<UserLastLoginRow>(sql, ids.Cast<object>().ToArray())
                            .ToList()
                            .ToDictionary(c => c.UserID, c => c.LastLoginTime, StringComparer.OrdinalIgnoreCase);
                    }
                    catch (Exception ex)
                    {
                        // 补丁表缺失/查询失败不影响卡片渲染：下面按 useroptlog 兜底。
                        LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.UserInfoController), $"FillPlayerLastLogin(userloginrecord) Err >> {ex.Message}");
                    }

                    List<string> fallbackIds = ids.Where(c => !loginMap.ContainsKey(c)).ToList();
                    if (fallbackIds.Count > 0)
                    {
                        string fallbackPlaceholders = string.Join(",", fallbackIds.Select((c, i) => "{" + i + "}"));
                        string fallbackSql = "SELECT UserID, MAX(REC_TIME) AS LastLoginTime FROM UserOptLog WHERE UserID IN (" + fallbackPlaceholders + ") GROUP BY UserID";
                        foreach (UserLastLoginRow row in ef.Database.SqlQuery<UserLastLoginRow>(fallbackSql, fallbackIds.Cast<object>().ToArray()).ToList())
                        {
                            if (!string.IsNullOrWhiteSpace(row.UserID))
                                loginMap[row.UserID] = row.LastLoginTime;
                        }
                    }

                    foreach (OnlinePlayerInfo player in players)
                    {
                        DateTime? last;
                        if (player.ID != null && loginMap.TryGetValue(player.ID, out last))
                            player.LastLoginTime = last;
                    }
                }
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.UserInfoController), $"FillPlayerLastLogin Err >> {ex.Message}");
            }
        }

        private sealed class UserLastLoginRow
        {
            public string UserID { get; set; }
            public DateTime? LastLoginTime { get; set; }
        }
        [MemberAuthorize]
        [AjaxOnly]
        [HttpPost]
        public ActionResult GetUsers(FormCollection form)
        {
            M_EasyuiGridData<M_Users_DTO> list = new M_EasyuiGridData<M_Users_DTO>();
            try
            {
                string id = form.Q<string>("srch_ID");
                string name = form.Q<string>("srch_NAME");
                string agency = form.Q<string>("srch_Agency");
                // 服务端排序（EasyUI remoteSort 默认开启，表头点击会带上 sort/order）
                string sort = form.Q<string>("sort");
                string order = form.Q<string>("order");

                int pageIndex = form.Q<int>("page", 1);
                int pageSize = form.Q<int>("rows", 10);

                M_LoginUser loginUser = WebHelper.GetLoginInfo();
                if (loginUser == null)
                    return Json(list);

                M_Page mPage = new M_Page(pageIndex, pageSize);
                M_Users_DTO mUsers = new M_Users_DTO { ID = id, AGENCY = agency, NAME = name };

                // loginUser.UserPriv
                // 0 超级管理
                // 1 总代
                // 2 ~ 8 一般代理
                // 9 副管理
                // 10 运营
                list = new B_Users().GetUsersList(mPage, mUsers, loginUser, sort, order);
                if (list != null && list.rows != null)
                {
                    // 总盈亏已由 B_Users.FillTotalWinLoss 填充（SUM user_daily_winloss 全量，与在线用户页同口径）
                    List<M_Users_DTO> listFooter = new List<M_Users_DTO>();
                    M_Users_DTO footer = new M_Users_DTO();
                    long? tatolCOINS = 0;
                    long? tatolGAME_SCORE = 0;
                    long? tatolCOINS_BUY = 0;
                    long? tatolCOINS_BACK = 0;
                    long? tatolProfit = 0;
                    foreach (var item in list.rows)
                    {
                        tatolCOINS += item.COINS;
                        tatolGAME_SCORE += item.GAME_SCORE;
                        tatolCOINS_BUY += item.COINS_BUY;
                        tatolCOINS_BACK += item.COINS_BACK;
                        tatolProfit += item.Profit;
                    }

                    footer.FROZEN = 2;
                    footer.NAME = "合计";
                    footer.COINS = tatolCOINS;
                    footer.GAME_SCORE = tatolGAME_SCORE;
                    footer.COINS_BUY = tatolCOINS_BUY;
                    footer.COINS_BACK = tatolCOINS_BACK;
                    footer.Profit = tatolProfit;
                    
                    listFooter.Add(footer);
                    list.footer = listFooter;
                }

            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.UserInfoController), ex);
            }
            return Json(list);
        }

        [MemberAuthorize]
        [AjaxOnly]
        [HttpPost]
        public ActionResult GetVisibleUserRows(FormCollection form)
        {
            Msg msg = new Msg(0, "刷新失败！");
            try
            {
                M_LoginUser loginUser = WebHelper.GetLoginInfo();
                if (loginUser == null)
                    return Json(msg);

                string rawIds = form.Q<string>("UserIDs");
                List<string> userIds = string.IsNullOrWhiteSpace(rawIds)
                    ? new List<string>()
                    : JsonConvert.DeserializeObject<List<string>>(rawIds);

                List<M_Users_DTO> rows = new B_Users().GetUserRowsByIds(userIds, loginUser);
                msg.code = 1;
                msg.content = "刷新成功！";
                msg.datas = rows;
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.UserInfoController), ex);
            }
            return Json(msg);
        }


        [MemberAuthorize]
        [AjaxOnly]
        [HttpPost]
        public ActionResult GetOnlinePlayers(FormCollection form)
        {
            M_EasyuiGridData<M_Users_DTO> list = new M_EasyuiGridData<M_Users_DTO>();
            try
            {
                string id = form.Q<string>("srch_ID");
                int userId = form.Q<int>("srch_UserID");
                string name = form.Q<string>("srch_NAME");
                string agency = form.Q<string>("srch_Agency");
                int pageIndex = form.Q<int>("page", 1);
                int pageSize = form.Q<int>("rows", 10);

                M_LoginUser loginUser = WebHelper.GetLoginInfo();
                if (loginUser == null)
                    return Json(list);

                M_Page mPage = new M_Page(pageIndex, pageSize);
                M_Users_DTO mUsers = new M_Users_DTO { ID = id, UserID = userId, AGENCY = agency, NAME = name };

                // loginUser.UserPriv
                // 0 超级管理
                // 1 总代
                // 2 ~ 8 一般代理
                // 9 副管理
                // 10 运营
                list = new B_Users().GetOnlinePlayersList(mPage, mUsers, loginUser);
                if (list != null && list.rows != null)
                {
                    //  List<M_UserProit> profits = bll.GetAgencyProfits(loginUser);
                    foreach (var item in list.rows)
                    {
                        //  var tmp = profits.Find(c => c.Agency.Equals(item.ID));
                        item.Profit = item.COINS_BUY - item.COINS_BACK;
                        // item.PlayerBalance = (tmp != null ? tmp.PlayerBalance : 0);
                    }
                }
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.UserInfoController), ex);
            }
            return Json(list);
        }

        #region 手机端扩展接口
        /// <summary>
        /// 手机端：今日玩家总输赢合计（权限范围内）
        /// </summary>
        [MemberAuthorize]
        [AjaxOnly]
        [HttpPost]
        public ActionResult GetTodayWinLoss()
        {
            Msg msg = new Msg(0, "查询失败！");
            try
            {
                M_LoginUser loginUser = WebHelper.GetLoginInfo();
                if (loginUser == null)
                    return Json(msg);

                long total = new B_Users().GetTodayTotalWinLoss(loginUser);
                msg.code = 1;
                msg.content = "查询成功！";
                msg.datas = new { total = total };
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.UserInfoController), ex);
            }
            return Json(msg);
        }

        /// <summary>
        /// 手机端：离线玩家分页（玩家列表-离线页签）
        /// </summary>
        [MemberAuthorize]
        [AjaxOnly]
        [HttpPost]
        public ActionResult GetOfflineUsers(FormCollection form)
        {
            M_EasyuiGridData<M_Users_DTO> list = new M_EasyuiGridData<M_Users_DTO>();
            try
            {
                M_LoginUser loginUser = WebHelper.GetLoginInfo();
                if (loginUser == null)
                    return Json(list);

                M_Page mPage = new M_Page(form.Q<int>("page", 1), form.Q<int>("rows", 10));
                M_Users_DTO mUsers = new M_Users_DTO
                {
                    ID = form.Q<string>("srch_ID"),
                    NAME = form.Q<string>("srch_NAME"),
                    AGENCY = form.Q<string>("srch_Agency")
                };
                string sort = form.Q<string>("sort");
                // 总盈亏(Profit) = 实际游戏输赢（user_daily_winloss 全量），由 B_Users.GetOfflineUsersList 直接给出，
                // 与在线列表/会员盈亏详情/电脑端"总盈亏"同口径。这里不能再按充退差额（COINS_BUY-COINS_BACK）覆盖：
                // 那是资金口径，会让同一个玩家的"总输赢"在线与离线显示成两个不同的数（离线也变成充值-退币）。
                list = new B_Users().GetOfflineUsersList(mPage, mUsers, loginUser, sort);
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.UserInfoController), ex);
            }
            return Json(list);
        }

        /// <summary>
        /// 手机端：封禁中的玩家分页（玩家封号页）
        /// </summary>
        [MemberAuthorize]
        [AjaxOnly]
        [HttpPost]
        public ActionResult GetFrozenUsers(FormCollection form)
        {
            M_EasyuiGridData<M_Users_DTO> list = new M_EasyuiGridData<M_Users_DTO>();
            try
            {
                M_LoginUser loginUser = WebHelper.GetLoginInfo();
                if (loginUser == null)
                    return Json(list);

                M_Page mPage = new M_Page(form.Q<int>("page", 1), form.Q<int>("rows", 10));
                M_Users_DTO mUsers = new M_Users_DTO { ID = form.Q<string>("srch_ID") };
                list = new B_Users().GetFrozenUsersList(mPage, mUsers, loginUser);
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.UserInfoController), ex);
            }
            return Json(list);
        }

        /// <summary>
        /// 手机端：会员盈亏分页（今日输赢 + 总盈亏，支持排序）
        /// </summary>
        [MemberAuthorize]
        [AjaxOnly]
        [HttpPost]
        public ActionResult GetMemberWinLoss(FormCollection form)
        {
            M_EasyuiGridData<M_Users_DTO> list = new M_EasyuiGridData<M_Users_DTO>();
            try
            {
                M_LoginUser loginUser = WebHelper.GetLoginInfo();
                if (loginUser == null)
                    return Json(list);

                M_Page mPage = new M_Page(form.Q<int>("page", 1), form.Q<int>("rows", 10));
                M_Users_DTO mUsers = new M_Users_DTO
                {
                    ID = form.Q<string>("srch_ID"),
                    AGENCY = form.Q<string>("srch_Agency")
                };
                bool includeDescendants = form.Q<int>("IncludeDescendants", 0) == 1;
                string sort = form.Q<string>("sort");
                list = new B_Users().GetMemberWinLossList(mPage, mUsers, loginUser, sort, includeDescendants);
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.UserInfoController), ex);
            }
            return Json(list);
        }

        /// <summary>
        /// 手机端：会员盈亏统计卡（权限范围内，支持代理过滤）。
        /// 口径：总盈亏/今日盈亏 = 实际游戏输赢（user_daily_winloss 累计/当日），赢正输负，
        /// 只有真正玩过游戏产生结算的会员才有记录，不按充值/退币差额统计；
        /// 总充值/总退币 = 最近 7x24 小时内已生效充退流水，今日充值/今日退分 = 当日已生效充退流水。
        /// </summary>
        [MemberAuthorize]
        [AjaxOnly]
        [HttpPost]
        public ActionResult GetMemberWinLossStats(FormCollection form)
        {
            Msg msg = new Msg(0, "查询失败！");
            try
            {
                M_LoginUser loginUser = WebHelper.GetLoginInfo();
                if (loginUser == null)
                    return Json(msg);

                string agency = form.Q<string>("srch_Agency");
                bool includeDescendants = form.Q<int>("IncludeDescendants", 0) == 1;
                M_MemberWinLossStats stats = new B_Users().GetMemberWinLossStats(loginUser, agency, includeDescendants);
                msg.code = 1;
                msg.content = "查询成功！";
                msg.datas = new
                {
                    TotalBuy = stats.TotalBuy ?? 0,
                    TotalBack = stats.TotalBack ?? 0,
                    TodayBuy = stats.TodayBuy ?? 0,
                    TodayBack = stats.TodayBack ?? 0,
                    // 盈亏按实际游戏输赢统计（user_daily_winloss），不再按充值/退币差额
                    TotalWinLoss = stats.TotalWinLoss ?? 0,
                    TodayWinLoss = stats.TodayWinLoss ?? 0
                };
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.UserInfoController), ex);
            }
            return Json(msg);
        }

        /// <summary>
        /// 手机端控制管理：总控记录分页（GameType=9，按设置时间倒序）。
        /// 返回 { total, rows, activeCount }；StartTime/EndTime 为 yyyy-MM-dd（End 含当天，闭区间）。
        /// 控牌行的牌型名由前端按 GameId(=cardAction)+LimitCoins(=cardValue)+TargetCoins(=cardNumber) 解析。
        /// </summary>
        [MemberAuthorize]
        [AjaxOnly]
        [HttpPost]
        public ActionResult GetControlRecords(FormCollection form)
        {
            var list = new M_EasyuiGridData<M_UserControlStatus_DTO>();
            try
            {
                M_LoginUser loginUser = WebHelper.GetLoginInfo();
                if (loginUser == null)
                    return Json(list);

                DateTime? start = ParseDateOrNull(form.Q<string>("StartTime"));
                DateTime? end = ParseDateOrNull(form.Q<string>("EndTime"));
                if (end != null)
                    end = end.Value.AddDays(1); // 结束日期含当天

                M_Page mPage = new M_Page(form.Q<int>("page", 1), form.Q<int>("rows", 20));
                int activeCount;
                list = new B_UserControl().GetTotalControlRecords(mPage, loginUser, start, end, out activeCount);
                return Json(new { total = list.total, rows = list.rows, activeCount = activeCount });
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.UserInfoController), ex);
            }
            return Json(list);
        }

        private static DateTime? ParseDateOrNull(string value)
        {
            DateTime d;
            if (string.IsNullOrWhiteSpace(value))
                return null;
            return DateTime.TryParse(value.Trim(), out d) ? d.Date : (DateTime?)null;
        }

        /// <summary>
        /// 手机端：玩家详情页数据（注册/最后登录/今日与累计充退/今日与总盈亏/总控状态/邀请码）。
        /// 返回 datas = { 玩家基础字段..., Controls = [当前执行中的总控] }，Controls 复用
        /// B_UserControl.GetTotalControlStatus（含吃分/放水阈值进度与控牌次数）。
        /// 总盈亏/今日盈亏 = 实际游戏输赢（user_daily_winloss 全量/当日），不是充退差额。
        /// </summary>
        [MemberAuthorize]
        [AjaxOnly]
        [HttpPost]
        public ActionResult GetUserDetail(FormCollection form)
        {
            Msg msg = new Msg(0, "查询失败！");
            try
            {
                string id = form.Q<string>("ID");
                if (string.IsNullOrWhiteSpace(id))
                {
                    msg.content = "玩家账号不能为空！";
                    return Json(msg);
                }

                M_LoginUser loginUser = WebHelper.GetLoginInfo();
                if (loginUser == null)
                    return Json(msg);

                M_UserPhoneDetail detail = new B_Users().GetUserPhoneDetail(id, loginUser);
                if (detail == null)
                {
                    msg.content = "未找到该玩家，或其不在您的代理线内！";
                    return Json(msg);
                }

                Msg ctrl = new B_UserControl().GetTotalControlStatus(loginUser, id);
                msg.code = 1;
                msg.content = "查询成功！";
                msg.datas = new
                {
                    detail.ID,
                    detail.NAME,
                    detail.PWD,
                    detail.AGENCY,
                    detail.FROZEN,
                    detail.GAME_SCORE,
                    detail.COINS,
                    detail.COINS_BUY,
                    detail.COINS_BACK,
                    detail.TotalWinLoss,
                    detail.TodayWinLoss,
                    detail.TodayBuy,
                    detail.TodayBack,
                    detail.CreateTime,
                    detail.LastLoginTime,
                    detail.InviteCode,
                    Controls = (ctrl != null && ctrl.code == 1) ? ctrl.datas : null
                };
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.UserInfoController), ex);
            }
            return Json(msg);
        }
        #endregion

        [MemberAuthorize]
        [AjaxOnly]
        [HttpPost]
        public ActionResult QueryPlayerCoins(FormCollection form)
        {
            Msg msg = new Msg(0, "查询失败！");
            try
            {
                string id = form.Q<string>("ID");
                if (string.IsNullOrWhiteSpace(id))
                {
                    msg.content = "用户账号不能为空！";
                    return Json(msg);
                }

                M_LoginUser loginUser = WebHelper.GetLoginInfo();
                if (loginUser == null)
                    return Json(msg);
                if (loginUser.UserPriv > 0 && loginUser.IsUpDown != 1)
                {
                    msg.content = "没有上下分权限！";
                    return Json(msg);
                }

                M_Admin rechargeUser = loginUser.ToAdminType();
                M_Recharge rechargeTarget = new M_Recharge
                {
                    ID = id,
                    Coin = 0,
                    RechargeType = 0,
                    AdminType = EAdminType.None,
                    IDType = EIDType.Account
                };
                msg = new B_ReChargeBase(rechargeUser, rechargeTarget).QueryTargetCoins();
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.UserInfoController), ex);
            }
            return Json(msg);
        }

        [AllowAnonymous]
        [HttpGet]
        // GET: Game/UserInfo/Register
        public ActionResult Register()
        {
            try
            {
                string token = DESEncrypt.EnCrypString(DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss"), REG_TOKEN);
                WebHelper.WriteSession<string>(REG_TOKEN, token);
                ViewBag.token = token;

                ViewBag.IOS_Url = ConfigHelper.Get("IOS_Url");
                ViewBag.Andriod_Url = ConfigHelper.Get("Andriod_Url");
                ViewBag.PC_Url = ConfigHelper.Get("PC_Url");
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.UserInfoController), ex);
            }
            return View();
        }

        [AllowAnonymous]
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Register(FormCollection form)
        {
            Msg msg = new Msg(0, "注册失败！");
            try
            {
                string registerToken = form.Q<string>("_RequestVerificationToken");
                if (string.IsNullOrWhiteSpace(registerToken))
                {
                    msg.content = "非法操作！";
                    goto deny;
                }

                string token = WebHelper.GetSession<string>(REG_TOKEN);
                if (!token.Equals(registerToken))
                {
                    msg.content = "页面过期，请重新扫码注册！";
                    goto deny;
                }

                try
                {
                    token = DESEncrypt.DeCrypString(registerToken, REG_TOKEN);

                    // 超过1分钟token 失效，需要重新打开页面注册
                    DateTime time;
                    if (!DateTime.TryParse(token, out time))
                    {
                        msg.content = "非法请求！";
                        goto deny;
                    }
                    if (DateTime.Now.Subtract(time).Minutes > 1)
                    {
                        msg.content = "页面过期，请重新扫码注册！";
                        return View();
                    }
                }
                catch
                {
                    msg.content = "非法操作！";
                    goto deny;
                }

                string agency = form.Q<string>("AGENCY");
                if (string.IsNullOrWhiteSpace(agency))
                {
                    msg.content = "无代理,注册失败！";
                    return View();
                }

                M_Users entity = new M_Users();
                if (TryUpdateModel<M_Users>(entity) && ModelState.IsValid)
                {
                    entity.AGENCY = agency;

                    msg = new B_Users().Regist(entity);
                    // 注册成功后使 Token 过期
                    if (msg.code == 1)
                    {
                        string _token = DESEncrypt.EnCrypString(DateTime.Now.AddDays(1).ToString("yyyy-MM-dd HH:mm:ss"), REG_TOKEN);
                        WebHelper.WriteSession<string>(REG_TOKEN, _token);
                    }
                }
                else
                {
                    msg.content = ModelState.Values.GetErrMsg();
                }
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.UserInfoController), ex);
                msg.content = "注册失败！";
            }
        deny:
            return Json(msg);
        }

        [MemberAuthorize]
        [AjaxOnly]
        [HttpPost]
        public ActionResult DelUser(FormCollection form)
        {
            Msg msg = new Msg(0, "删除失败！");
            try
            {
                M_LoginUser loginUser = WebHelper.GetLoginInfo();
                if (loginUser == null)
                {
                    msg.content = "登录已失效！";
                    return Json(msg);
                }
                if (loginUser.UserPriv > 0 && loginUser.IsDelete != 1)
                {
                    msg.content = "没有删除用户权限！";
                    return Json(msg);
                }
                string id = form.Q<string>("ID");
                if (!string.IsNullOrWhiteSpace(id))
                {
                    if (loginUser.UserPriv > 0 && !CanManagePlayer(loginUser, id))
                    {
                        msg.content = "只能删除自己管理范围内的用户！";
                        return Json(msg);
                    }
                    M_Users mUsers = new M_Users { ID = id };
                    int val = new B_Users().DelUser(mUsers);
                    if (val > 0)
                    {
                        msg.code = 1;
                        msg.content = "删除成功！";
                    }
                }
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.UserInfoController), ex);
            }
            return Json(msg);
        }


        [MemberAuthorize]
        [AjaxOnly]
        [HttpPost]
        public ActionResult ResetSafePwd(FormCollection form)
        {
            Msg msg = new Msg(0, "重置保险柜密码失败！");
            try
            {
                M_LoginUser loginUser = WebHelper.GetLoginInfo();
                if (loginUser == null || (loginUser.UserPriv > 0 && loginUser.IsResetSafePwd != 1))
                {
                    msg.content = "没有重置保险柜密码权限！";
                    return Json(msg);
                }
                string id = form.Q<string>("ID");
                if (!string.IsNullOrWhiteSpace(id))
                {
                    using (var ef = new GameDbContext())
                    {
                        M_Users target = ef.Users.FirstOrDefault(c => c.ID == id);
                        if (target == null || !new B_Admin().CanManagePlayer(ef, loginUser, target.AGENCY))
                        {
                            msg.content = target == null ? "用户不存在！" : "无权限操作！";
                            return Json(msg);
                        }
                    }
                    M_Users mUsers = new M_Users { ID = id };
                    int val = new B_Users().ResetSafePwd(mUsers);
                    if (val > 0)
                    {
                        msg.code = 1;
                        msg.content = "重置保险柜密码成功！";
                    }
                }
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.UserInfoController), ex);
            }
            return Json(msg);
        }

        [MemberAuthorize]
        [AjaxOnly]
        [HttpPost]
        public ActionResult FrozenUser(FormCollection form)
        {
            Msg msg = new Msg(0, "冻结失败！");
            try
            {
                M_LoginUser loginUser = WebHelper.GetLoginInfo();
                if (loginUser == null)
                {
                    msg.content = "无权限操作！";
                    return Json(msg);
                }
                string id = form.Q<string>("ID");
                int frozen = form.Q<int>("frozen", 0);
                if (!string.IsNullOrWhiteSpace(id))
                {
                    int val = new B_Users().FrozenUserWithAudit(loginUser, id, frozen);
                    if (val < 0)
                    {
                        msg.content = "无权限操作！";
                    }
                    else if (val > 0)
                    {
                        msg.code = 1;
                        msg.content = "操作成功";
                        // 冻结即时生效：把在线玩家踢下线，重新登录时被中心服冻结校验拦截
                        if (frozen == 1)
                        {
                            Msg kickMsg = KickPlayer(id);
                            if (kickMsg.code != 1)
                                msg.content += "，但踢出玩家指令未确认（" + kickMsg.content + "）";
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.UserInfoController), ex);
            }
            return Json(msg);
        }

        [MemberAuthorize]
        [AjaxOnly]
        [HttpPost]
        public ActionResult ChgPwd(FormCollection form)
        {
            Msg msg = new Msg(0, "密码修改失败！");
            try
            {
                M_LoginUser loginUser = WebHelper.GetLoginInfo();
                if (loginUser == null || (loginUser.UserPriv > 0 && (loginUser.IsViewPwd != 1 || loginUser.IsModifyPwd != 1)))
                {
                    msg.content = "没有修改密码权限！";
                    return Json(msg);
                }
                string id = form.Q<string>("ID");
                string pwd = form.Q<string>("PWD");

                if (string.IsNullOrWhiteSpace(id))
                {
                    msg.content = "用户ID不能为空！";
                    return Json(msg);
                }
                if (loginUser.UserPriv > 0 && !CanManagePlayer(loginUser, id))
                {
                    msg.content = "只能修改自己管理范围内用户的密码！";
                    return Json(msg);
                }
                if (string.IsNullOrWhiteSpace(pwd))
                {
                    msg.content = "密码不能为空！";
                    return Json(msg);
                }

                using (var ef = new GameDbContext())
                {
                    M_Users target = ef.Users.FirstOrDefault(c => c.ID == id);
                    if (target == null)
                    {
                        msg.content = "用户不存在！";
                        return Json(msg);
                    }
                    if (!new B_Admin().CanManagePlayer(ef, loginUser, target.AGENCY))
                    {
                        msg.content = "无权限操作！";
                        return Json(msg);
                    }
                }

                M_Users entity = new M_Users { ID = id, PWD = pwd };
                int val = new B_Users().ChgPwd(entity);
                if (val > 0)
                {
                    msg.code = 1;
                    msg.content = "修改成功";
                }
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.UserInfoController), ex);
            }
            return Json(msg);
        }

        [MemberAuthorize]
        [AjaxOnly]
        [HttpPost]
        public ActionResult ChgSafePwd(FormCollection form)
        {
            Msg msg = new Msg(0, "保险柜密码修改失败！");
            try
            {
                M_LoginUser loginUser = WebHelper.GetLoginInfo();
                if (loginUser == null || (loginUser.UserPriv > 0 && loginUser.IsModifySafePwd != 1))
                {
                    msg.content = "没有修改保险柜密码权限！";
                    return Json(msg);
                }
                string id = form.Q<string>("ID");
                string safePwd = form.Q<string>("SAFE_PWD");

                if (string.IsNullOrWhiteSpace(id))
                {
                    msg.content = "用户ID不能为空！";
                    return Json(msg);
                }
                if (string.IsNullOrWhiteSpace(safePwd))
                {
                    msg.content = "保险柜密码不能为空！";
                    return Json(msg);
                }

                using (var ef = new GameDbContext())
                {
                    M_Users target = ef.Users.FirstOrDefault(c => c.ID == id);
                    if (target == null || !new B_Admin().CanManagePlayer(ef, loginUser, target.AGENCY))
                    {
                        msg.content = target == null ? "用户不存在！" : "无权限操作！";
                        return Json(msg);
                    }
                }

                M_Users entity = new M_Users { ID = id, SAFE_PWD = safePwd };
                int val = new B_Users().ChgSafePwd(entity);
                if (val > 0)
                {
                    msg.code = 1;
                    msg.content = "保险柜密码修改成功！";
                }
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.UserInfoController), ex);
            }
            return Json(msg);
        }

        /// <summary>
        /// 等级修改
        /// </summary>
        /// <param name="form"></param>
        /// <returns></returns>
        [MemberAuthorize]
        [AjaxOnly]
        [HttpPost]
        public ActionResult ChgGrade(FormCollection form)
        {
            Msg msg = new Msg(0, "等级修改失败！");
            try
            {
                M_LoginUser loginUser = WebHelper.GetLoginInfo();
                if (loginUser == null || loginUser.UserPriv != 0)
                {
                    msg.content = "没有等级设置权限！";
                    return Json(msg);
                }
                string id = form.Q<string>("ID2");
                string GRADE = form.Q<string>("GRADE");
                if (string.IsNullOrWhiteSpace(id))
                {
                    msg.content = "用户ID不能为空！";
                    return Json(msg);
                }
                if (string.IsNullOrWhiteSpace(GRADE))
                {
                    msg.content = "等级不能为空！";
                    return Json(msg);
                }
                M_Users entity = new M_Users { ID = id, GRADE = Convert.ToInt32(GRADE) };
                int val = new B_Users().ChgGrade(entity);
                if (val > 0)
                {
                    msg.code = 1;
                    msg.content = "等级修改成功！";
                }
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.UserInfoController), ex);
            }
            return Json(msg);
        }

        /// <summary>
        /// 充值
        /// </summary>
        /// <param name="form"></param>
        /// <returns></returns>
        [AjaxOnly]
        [HttpPost]
        public ActionResult SaveReChange(FormCollection form)
        {
            Msg msg = new Msg(0, "充值失败！");
            try
            {
                string id = form.Q<string>("ID3");
                int coin = form.Q<int>("txtE_COINS1");// 充值币数量
                if (string.IsNullOrWhiteSpace(id))
                {
                    msg.content = "用户ID不能为空！";
                    return Json(msg);
                }
                if (coin <= 0)
                {
                    msg.content = "请填充值数量！";
                    return Json(msg);
                }
                M_LoginUser loginUser = WebHelper.GetLoginInfo();
                if (loginUser != null)
                {
                    if (loginUser.UserPriv > 0 && loginUser.IsUpDown != 1)
                    {
                        msg.content = "没有上下分权限！";
                        return Json(msg);
                    }
                    //if (loginUser.UserPriv != 0)
                    //{
                    //    int val = new B_Users().SelectUserINHALL(id,"1");
                    //    if (val == 1)
                    //    {
                    //        msg.content = "该用户在线.不可以充值";
                    //        return Json(msg);
                    //    }
                    //}
                    /// <summary>
                    /// 是否是真金版
                    /// </summary>
                    bool isRMB = ConfigHelper.Get("IsRMB").Equals("1");
                    /// <summary>
                    /// 真金版兑换率
                    /// </summary>
                    int exchangeRate = 0;
                    if (isRMB == true)
                    {
                        exchangeRate = Convert.ToInt32(ConfigHelper.Get("ExchangeRate"));
                        if (exchangeRate > 0)
                            coin *= exchangeRate;
                    }
                    int targetType = -2;
                    EAdminType eAdminType = (EAdminType)targetType;
                    M_Admin rechargeUser = loginUser.ToAdminType();
                    int idType = 0;// 默认为 0通过用户账号充值  1通过平台用户唯一标识充值
                    EIDType eIDType = (EIDType)idType;
                    M_Recharge rechargeTarget = new M_Recharge { ID = id, Coin = coin, RechargeType = 0, AdminType = eAdminType, IDType = eIDType };
                    B_ReChargeBase bll = new B_ReChargeBase(rechargeUser, rechargeTarget);
                    msg = bll.PlayerReCharge();
                }
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.UserInfoController), ex);
            }
            return Json(msg);
        }


        /// <summary>
        /// 赠送
        /// </summary>
        /// <param name="form"></param>
        /// <returns></returns>
        [AjaxOnly]
        [HttpPost]
        public ActionResult SaveGive(FormCollection form)
        {
            Msg msg = new Msg(0, "赠送失败！");
            try
            {
                string id = form.Q<string>("ID4");
                int coin = form.Q<int>("txtE_COINS2");// 赠送币数量
                if (string.IsNullOrWhiteSpace(id))
                {
                    msg.content = "用户ID不能为空！";
                    return Json(msg);
                }
                if (coin <= 0)
                {
                    msg.content = "请填赠送数量！";
                    return Json(msg);
                }
                M_LoginUser loginUser = WebHelper.GetLoginInfo();
                if (loginUser == null || loginUser.UserPriv != 0)
                {
                    msg.content = "没有赠送权限！";
                    return Json(msg);
                }
                if (loginUser != null)
                {
                    //if (loginUser.UserPriv != 0)
                    //{
                    //    int val = new B_Users().SelectUserINHALL(id, "1");
                    //    if (val == 1)
                    //    {
                    //        msg.content = "该用户在线.不可以赠送";
                    //        return Json(msg);
                    //    }
                    //}
                    /// <summary>
                    /// 是否是真金版
                    /// </summary>
                    bool isRMB = ConfigHelper.Get("IsRMB").Equals("1");
                    /// <summary>
                    /// 真金版兑换率
                    /// </summary>
                    int exchangeRate = 0;
                    if (isRMB == true)
                    {
                        exchangeRate = Convert.ToInt32(ConfigHelper.Get("ExchangeRate"));
                        if (exchangeRate > 0)
                            coin *= exchangeRate;
                    }
                    int targetType = -2;
                    EAdminType eAdminType = (EAdminType)targetType;
                    M_Admin rechargeUser = loginUser.ToAdminType();
                    int idType = 0;// 默认为 0通过用户账号充值  1通过平台用户唯一标识充值
                    EIDType eIDType = (EIDType)idType;
                    M_Recharge rechargeTarget = new M_Recharge { ID = id, Coin = coin, RechargeType = 2, AdminType = eAdminType, IDType = eIDType };
                    B_ReChargeBase bll = new B_ReChargeBase(rechargeUser, rechargeTarget);
                    msg = bll.PlayerReCharge();
                }
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.UserInfoController), ex);
            }
            return Json(msg);
        }

        /// <summary>
        /// 扣币
        /// </summary>
        /// <param name="form"></param>
        /// <returns></returns>
        [AjaxOnly]
        [HttpPost]
        public ActionResult SaveDeduct(FormCollection form)
        {
            Msg msg = new Msg(0, "扣币失败！");
            try
            {
                string id = form.Q<string>("ID5");
                int coin = form.Q<int>("txtE_COINS3");// 扣币数量
                if (string.IsNullOrWhiteSpace(id))
                {
                    msg.content = "用户ID不能为空！";
                    return Json(msg);
                }
                if (coin <= 0)
                {
                    msg.content = "请填扣币数量！";
                    return Json(msg);
                }
                M_Users usr = new B_Users().GetSingle(new M_Users { ID = id });
                if (usr == null)
                {
                    msg.content = "此ID用户不存在！";
                    return Json(msg);
                }
                M_LoginUser loginUser = WebHelper.GetLoginInfo();
                if (loginUser == null)
                    return Json(msg);
                if (loginUser.UserPriv > 0 && loginUser.IsUpDown != 1)
                {
                    msg.content = "没有上下分权限！";
                    return Json(msg);
                }
                bool isRMB = ConfigHelper.Get("IsRMB").Equals("1");
                /// <summary>
                /// 真金版兑换率
                /// </summary>
                int exchangeRate = 0;
                if (isRMB == true)
                {
                    exchangeRate = Convert.ToInt32(ConfigHelper.Get("ExchangeRate"));
                    if (exchangeRate > 0)
                        coin *= exchangeRate;
                }
                if (usr.COINS < coin)
                {
                    msg.content = "请重新填写扣币数量，用户金币不够！";
                    return Json(msg);
                }
                if (loginUser != null)
                {
                    int targetType = -2;
                    EAdminType eAdminType = (EAdminType)targetType;
                    M_Admin rechargeUser = loginUser.ToAdminType();
                    int idType = 0;// 默认为 0通过用户账号充值  1通过平台用户唯一标识充值
                    EIDType eIDType = (EIDType)idType;
                    M_Recharge rechargeTarget = new M_Recharge { ID = id, Coin = coin, RechargeType = 3, AdminType = eAdminType, IDType = eIDType };
                    B_ReChargeBase bll = new B_ReChargeBase(rechargeUser, rechargeTarget);
                    msg = bll.PlayerReCharge();
                }
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.UserInfoController), ex);
            }
            return Json(msg);
        }

        [MemberAuthorize]
        [AjaxOnly]
        [HttpPost]
        public ActionResult GetUserCtrlConfigs(FormCollection form)
        {
            Msg msg = new Msg(0, "");
            try
            {
                string id = form.Q<string>("ID");
                if (string.IsNullOrWhiteSpace(id))
                    return Json(msg);
                using (var ef = new GameDbContext())
                {
                    var rows = ef.Database.SqlQuery<UserCtrlRow>(
                        "SELECT CONTROL_TYPE AS CtrlType, CONTROL_VALUE AS CtrlValue, NUMBER AS Number, TOTAL_NUMBER AS TotalNumber FROM usercontrolvalue WHERE USERID={0}", id)
                        .ToList();
                    msg.code = 1;
                    msg.datas = rows;
                }
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.UserInfoController), ex);
            }
            return Json(msg);
        }

        [MemberAuthorize]
        [AjaxOnly]
        [HttpPost]
        public ActionResult GetUserGoldLimit(FormCollection form)
        {            Msg msg = new Msg(0, "");
            try
            {
                string id = form.Q<string>("ID");
                if (string.IsNullOrWhiteSpace(id))
                    return Json(msg);
                using (var ef = new GameDbContext())
                {
                    var row = ef.UserControlStatuses
                        .Where(c => c.UserID == id && c.ControlMode == (int)EControlMode.Limit && c.Status == (int)EControlStatus.Active)
                        .OrderByDescending(c => c.ID)
                        .FirstOrDefault();
                    if (row != null)
                    {
                        msg.code = 1;
                        msg.content = row.LimitCoins.ToString();
                    }
                }
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.UserInfoController), ex);
            }
            return Json(msg);
        }

        private static void SaveGoldLimitToDb(string userId, long goldLimit, string createdBy)
        {
            using (var ef = new GameDbContext())
            {
                var olds = ef.UserControlStatuses
                    .Where(c => c.UserID == userId && c.ControlMode == (int)EControlMode.Limit && c.Status == (int)EControlStatus.Active)
                    .ToList();
                foreach (var old in olds)
                {
                    old.Status = (int)EControlStatus.Expired;
                    old.ExpiredTime = DateTime.Now;
                }
                if (goldLimit > 0)
                {
                    ef.UserControlStatuses.Add(new M_UserControlStatus
                    {
                        UserID = userId,
                        GameType = 1,
                        GameId = 0,
                        ControlMode = (int)EControlMode.Limit,
                        TargetCoins = 0,
                        ConsumedCoins = 0,
                        GrantedCoins = 0,
                        LimitCoins = goldLimit,
                        KillRatio = 60,
                        Status = (int)EControlStatus.Active,
                        CreatedBy = createdBy,
                        CreatedTime = DateTime.Now
                    });
                }
                ef.SaveChanges();
            }
        }

        /// <summary>
        /// 设置总控（总点杀/总放水/总控牌），带金币阈值：
        /// Mode=4 总点杀（鱼机+押注+牌机+拉霸，Strength=强度）
        /// Mode=5 总放水（鱼机+押注，Strength=强度）
        /// Mode=6 总控牌（牌机+拉霸，CardAction/CardValue/CardNumber/CardTotal=精确控牌参数）
        /// GoldThreshold=金币阈值（必填>0），累计吃分/放分达到后自动失效并恢复桌台参数难度
        /// </summary>
        [MemberAuthorize]
        [AjaxOnly]
        [HttpPost]
        public ActionResult ApplyTotalControl(FormCollection form)
        {
            Msg msg;
            try
            {
                string id = form.Q<string>("ID");
                int mode = form.Q<int>("Mode", -1);
                int strength = form.Q<int>("Strength", 0);
                long goldThreshold = form.Q<long>("GoldThreshold", 0);
                int cardAction = form.Q<int>("CardAction", 0);
                int cardValue = form.Q<int>("CardValue", 0);
                int cardNumber = form.Q<int>("CardNumber", 0);
                int cardTotal = form.Q<int>("CardTotal", 0);
                bool mobileFixedCard = form.Q<int>("MobileRequest", 0) == 1;

                M_LoginUser loginUser = WebHelper.GetLoginInfo();
                msg = new B_UserControl().ApplyTotalControl(loginUser, id, mode, strength, goldThreshold,
                    cardAction, cardValue, cardNumber, cardTotal, mobileFixedCard);
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.UserInfoController), ex);
                msg = new Msg(0, "设置失败！");
            }
            return Json(msg);
        }

        /// <summary>
        /// 查询玩家当前总控状态（三种模式各返回最近一条执行中记录，含阈值进度）
        /// </summary>
        [MemberAuthorize]
        [AjaxOnly]
        [HttpPost]
        public ActionResult GetTotalControlStatus(FormCollection form)
        {
            Msg msg;
            try
            {
                string id = form.Q<string>("ID");
                M_LoginUser loginUser = WebHelper.GetLoginInfo();
                msg = new B_UserControl().GetTotalControlStatus(loginUser, id);
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.UserInfoController), ex);
                msg = new Msg(0, "查询失败！");
            }
            return Json(msg);
        }

        /// <summary>
        /// 批量查询多个玩家执行中的总控（在线用户列表"控制"列）
        /// </summary>
        [MemberAuthorize]
        [AjaxOnly]
        [HttpPost]
        public ActionResult GetActiveTotalControls(FormCollection form)
        {
            Msg msg;
            try
            {
                string rawIds = form.Q<string>("UserIDs");
                List<string> userIds = string.IsNullOrWhiteSpace(rawIds)
                    ? new List<string>()
                    : JsonConvert.DeserializeObject<List<string>>(rawIds);
                M_LoginUser loginUser = WebHelper.GetLoginInfo();
                msg = new B_UserControl().GetActiveTotalControls(loginUser, userIds);
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.UserInfoController), ex);
                msg = new Msg(0, "查询失败！");
            }
            return Json(msg);
        }

        /// <summary>
        /// 手动关闭玩家某一模式的总控（Mode=4/5/6），并恢复桌台参数难度
        /// </summary>
        [MemberAuthorize]
        [AjaxOnly]
        [HttpPost]
        public ActionResult CloseTotalControl(FormCollection form)
        {
            Msg msg;
            try
            {
                string id = form.Q<string>("ID");
                int mode = form.Q<int>("Mode", -1);
                bool mobileRequest = form.Q<int>("MobileRequest", 0) == 1;
                M_LoginUser loginUser = WebHelper.GetLoginInfo();
                msg = new B_UserControl().CloseTotalControl(loginUser, id, mode, mobileRequest);
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.UserInfoController), ex);
                msg = new Msg(0, "关闭失败！");
            }
            return Json(msg);
        }

        [MemberAuthorize]
        [AjaxOnly]
        [HttpPost]
        public ActionResult ChgUserRate(FormCollection form)
        {
            Msg msg = new Msg(0, "鱼机修改失败！");
            try
            {
                string id = form.Q<string>("ID");
                int action = form.Q<int>("Action", -1);
                int val = form.Q<int>("Val");

                if (string.IsNullOrWhiteSpace(id))
                {
                    msg.content = "用户ID不能为空！";
                    return Json(msg);
                }

                // 押注点杀(3)/押注放水(4) 已收编进总控（总点杀 mode=4 / 总放水 mode=5，带金币阈值与进度），
                // 此旧通道已废弃，统一走总控对话框设置。
                if (action == 3 || action == 4)
                {
                    msg.content = "押注控制已收编到总控（吃分/放水），请在总控中设置！";
                    return Json(msg);
                }

                bool rst = new B_Users().Exists(new M_Users { ID = id });
                if (!rst)
                {
                    msg.content = "此ID用户不存在！";
                    return Json(msg);
                }

                M_LoginUser loginUser = WebHelper.GetLoginInfo();
                if (loginUser == null || loginUser.UserPriv > 0)
                {
                    if (action == 1 && (loginUser?.IsKill ?? 0) != 1)
                    {
                        msg.content = "没有点杀权限！";
                        return Json(msg);
                    }
                    if (action == 2 && (loginUser?.IsProbability ?? 0) != 1)
                    {
                        msg.content = "没有放水权限！";
                        return Json(msg);
                    }
                }
                int set = 0;
                if (loginUser != null && loginUser.UserName == ConfigHelper.Get("admin"))
                {
                    set = 1;
                }
                var tmpMsg = new GameCommandService().SetUserControl(action.ToString().PadLeft(2, '0'), val.ToString().PadLeft(2, '0'), set, id);

                long goldLimit = form.Q<long>("GoldLimit", 0);
                bool goldSaved = false;
                try
                {
                    SaveGoldLimitToDb(id, goldLimit, loginUser?.Accounts ?? "");
                    goldSaved = true;
                }
                catch (Exception exGl) { LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.UserInfoController), exGl); }

                string tmpDatas = tmpMsg != null ? (tmpMsg.datas as string) : null;
                bool ucOk = tmpMsg != null && (tmpMsg.code == 1 || tmpDatas == "UCNL" || tmpDatas == "UCOK");

                if (ucOk)
                {
                    msg.code = 1;
                    msg.content = "设置成功" + (goldLimit > 0 && goldSaved ? "，目标已设置" : "");
                }
                else if (goldLimit > 0 && goldSaved)
                {
                    msg.code = 1;
                    msg.content = "目标已设置";
                }
                else
                {
                    msg.code = 0;
                    msg.content = "设置失败";
                }
            }
            catch (Exception ex)
            {
                msg.content = "服务器内部错误。";
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.UserInfoController), ex);
            }
            return Json(msg);
        }

        [MemberAuthorize]
        [AjaxOnly]
        [HttpPost]
        public ActionResult ChgUserRatePAIJI(FormCollection form)
        {
            Msg msg = new Msg(0, "牌机控制修改失败！");
            try
            {
                string id = form.Q<string>("ID1");
                if (string.IsNullOrWhiteSpace(id))
                {
                    msg.content = "用户ID不能为空！";
                    return Json(msg);
                }

                bool rst = new B_Users().Exists(new M_Users { ID = id });
                if (!rst)
                {
                    msg.content = "此ID用户不存在！";
                    return Json(msg);
                }

                M_LoginUser loginUser = WebHelper.GetLoginInfo();
                if (loginUser == null || (loginUser.UserPriv > 0 && loginUser.IsRelease != 1))
                {
                    msg.content = "没有牌机控制权限！";
                    return Json(msg);
                }
                int set = 0;
                if (loginUser.UserName == ConfigHelper.Get("admin"))
                {
                    set = 1;
                }
                int paiJiMode = form.Q<int>("PaiJiMode", 0);
                Msg tmpMsg;
                if (paiJiMode == 1)
                {
                    int killVal = form.Q<int>("KillVal");
                    tmpMsg = new GameCommandService().SetUserControl("25", killVal.ToString().PadLeft(2, '0'), set, id);
                }
                else
                {
                    int action = form.Q<int>("Action1", -1);
                    int val = form.Q<int>("Val1");
                    int type = form.Q<int>("Type1");
                    int number = form.Q<int>("Number1");
                    tmpMsg = new GameCommandService().SetUserControl(action.ToString().PadLeft(2, '0'), type.ToString().PadLeft(2, '0'), number.ToString().PadLeft(2, '0'), val.ToString().PadLeft(2, '0'), set, id);
                    try
                    {
                        using (var efSave = new GameDbContext())
                        {
                            efSave.Database.ExecuteSqlCommand(
                                "INSERT INTO usercontrolvalue (USERID, GAME_TYPE, CONTROL_TYPE, CONTROL_VALUE, NUMBER, TOTAL_NUMBER) VALUES ({0},1,{1},{2},{3},{4}) ON DUPLICATE KEY UPDATE GAME_TYPE=1, CONTROL_TYPE={1}, CONTROL_VALUE={2}, NUMBER={3}, TOTAL_NUMBER={4}",
                                id, action, type, number, val);
                        }
                    }
                    catch (Exception exSave) { LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.UserInfoController), exSave); }
                }

                long goldLimitPaiJi = form.Q<long>("GoldLimitPaiJi", 0);
                bool goldSavedPai = false;
                try
                {
                    SaveGoldLimitToDb(id, goldLimitPaiJi, loginUser?.Accounts ?? "");
                    goldSavedPai = true;
                }
                catch (Exception exGl) { LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.UserInfoController), exGl); }

                string tmpDatasPai = tmpMsg != null ? (tmpMsg.datas as string) : null;
                bool ucOkPai = tmpMsg != null && (tmpMsg.code == 1 || tmpDatasPai == "UCNL" || tmpDatasPai == "UCOK");

                if (ucOkPai)
                {
                    msg.code = 1;
                    msg.content = "设置成功" + (goldLimitPaiJi > 0 && goldSavedPai ? "，目标已设置" : "");
                }
                else if (goldLimitPaiJi > 0 && goldSavedPai)
                {
                    msg.code = 1;
                    msg.content = "目标已设置";
                }
                else
                {
                    msg.code = 0;
                    msg.content = "设置失败";
                }
            }
            catch (Exception ex)
            {
                msg.content = "服务器内部错误。";
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.UserInfoController), ex);
            }
            return Json(msg);
        }

        [MemberAuthorize]
        [AjaxOnly]
        [HttpPost]
        public ActionResult ChgUserRateLaba(FormCollection form)
        {
            // 拉霸控制（点杀 UC27 / 控牌 UC15/16/17）已收编进总控（吃分 mode=4 / 控牌 mode=6），
            // 此旧通道已废弃，统一走总控对话框设置。
            Msg msg = new Msg(0, "拉霸修改失败！");
            msg.content = "拉霸控制已收编到总控（吃分/控牌），请在总控中设置！";
            return Json(msg);
        }

        [MemberAuthorize]
        /// <summary>
        /// 在线分数【玩家实时分数】
        /// </summary>
        /// <returns></returns>
        public ActionResult OnlineCoin()
        {
            return View();
        }
        [MemberAuthorize]
        [AjaxOnly]
        [HttpPost]
        public ActionResult OnlineCoin(FormCollection form)
        {
            Msg msg = new Msg(0, "查询失败！");
            try
            {
                int idType = form.Q<int>("idType", 0);// 默认为 0通过用户账号充值  1通过平台用户唯一标识充值
                string tmpId = form.Q<string>("UserID");

                if (string.IsNullOrWhiteSpace(tmpId))
                {
                    msg.content = "用户账号/ID不能为空！";
                    return Json(msg);
                }

                string userAccount = string.Empty;
                if (idType == 1)
                {
                    if (!Regex.IsMatch(tmpId, "^\\d+$"))
                    {
                        msg.content = "请填写正确的用户ID！";
                        return Json(msg);
                    }
                    int userId = Convert.ToInt32(tmpId);
                    userAccount = new B_UserRelations().GetSingle(userId);
                }
                else
                {
                    userAccount = tmpId;
                }

                if (!string.IsNullOrWhiteSpace(userAccount))
                {
                    msg = new PlayerStateService().QueryRuntimeState(userAccount);
                }
                else
                {
                    msg.content = "没有找到该用户！";
                }
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.UserInfoController), $" QueryUserOnlineData Err >> {ex.Message} \r\n");
            }
            return Json(msg);
        }

        [MemberAuthorize]
        [AjaxOnly]
        [HttpPost]
        public ActionResult KickPlayer(FormCollection form)
        {
            Msg msg = new Msg(0, "操作失败！");
            M_LoginUser loginUser = WebHelper.GetLoginInfo();
            if (loginUser == null || (loginUser.UserPriv > 0 && loginUser.IsKicking != 1))
            {
                msg.content = "没有踢人权限！";
                return Json(msg);
            }
            string userAccount = form.Q<string>("UserID");

            if (string.IsNullOrWhiteSpace(userAccount))
            {
                msg.content = "用户账号不能为空！";
            }
            else
            {
                if (loginUser.UserPriv > 0 && !CanManagePlayer(loginUser, userAccount))
                {
                    msg.content = "只能踢出自己管理范围内的玩家！";
                    return Json(msg);
                }
                msg = KickPlayer(userAccount);
            }
            return Json(msg);
        }


        [MemberAuthorize]
        [AjaxOnly]
        [HttpPost]
        public ActionResult KickAllPlayer(FormCollection form)
        {
            Msg msg = new Msg(0, "操作失败！");
            M_LoginUser loginUser = WebHelper.GetLoginInfo();
            if (loginUser == null || (loginUser.UserPriv > 0 && loginUser.IsKicking != 1))
            {
                msg.content = "没有踢人权限！";
                return Json(msg);
            }

            if (loginUser.UserPriv == 0)
            {
                msg = KickPlayer(string.Empty);
                return Json(msg);
            }

            List<string> onlinePlayers;
            using (var ef = new GameDbContext())
            {
                List<string> agencies = new B_Admin().GetManagedPlayerAgencyAccounts(ef, loginUser);
                onlinePlayers = ef.Users.Where(c => c.INHALL && agencies.Contains(c.AGENCY))
                    .Select(c => c.ID).ToList();
            }
            int success = 0;
            foreach (string account in onlinePlayers)
            {
                Msg kickMsg = KickPlayer(account);
                if (kickMsg.code == 1)
                    success++;
            }
            msg.code = 1;
            msg.content = $"操作成功，已发送踢出指令{success}个！";
            return Json(msg);
        }
        private Msg KickPlayer(string userAccount)
        {
            Msg msg = new Msg(0, "操作失败！");
            try
            {
                return Task.Factory.StartNew(() => new GameCommandService().KickPlayer(userAccount)).Result;
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.UserInfoController), $" KickPlayer Err >> {ex.Message} \r\n");
            }
            return msg;
        }

        private bool CanManagePlayer(M_LoginUser loginUser, string userAccount)
        {
            using (var ef = new GameDbContext())
            {
                var user = ef.Users.FirstOrDefault(u => u.ID == userAccount);
                if (user == null)
                    return false;

                return new B_Admin().CanManagePlayer(ef, loginUser, user.AGENCY);
            }
        }

        [MemberAuthorize]
        [AjaxOnly]
        [HttpPost]
        public ActionResult AddUser(FormCollection form)
        {
            Msg msg = new Msg(0, "操作失败！");
            string txtE_UID1 = form.Q<string>("txtE_UID1");
            string txtE_NAME1 = form.Q<string>("txtE_NAME1");
            string txtE_TELEPHONE1 = form.Q<string>("txtE_TELEPHONE1");
            string PWD1 = form.Q<string>("PWD1");
            string RE_PWD1 = form.Q<string>("RE_PWD1");
            if (string.IsNullOrWhiteSpace(txtE_UID1))
            {
                msg.content = "用户登录账户不能为空！";
                return Json(msg);
            }
            if (string.IsNullOrWhiteSpace(txtE_NAME1))
            {
                msg.content = "用户显示昵称不能为空！";
                return Json(msg);
            }
            char[] arrChar = txtE_NAME1.ToCharArray(0, txtE_NAME1.Trim().Length);
            foreach (char char1 in arrChar)
            {
                if (!char.IsLetterOrDigit(char1))
                {
                    msg.content = "用户昵称包含非法字符！";
                    return Json(msg);
                }
            }
            if (string.IsNullOrWhiteSpace(txtE_TELEPHONE1))
            {
                msg.content = "用户手机不能为空！";
                return Json(msg);
            }

            if (string.IsNullOrWhiteSpace(PWD1))
            {
                msg.content = "密码不能为空！";
                return Json(msg);
            }
            if (string.IsNullOrWhiteSpace(txtE_UID1))
            {
                msg.content = "确认密码不能为空！";
                return Json(msg);
            }
            if (PWD1 != RE_PWD1)
            {
                msg.content = "确认密码错误！";
                return Json(msg);
            }
            M_LoginUser loginUser = WebHelper.GetLoginInfo();
            string agency = loginUser.Remark;//代理
            M_Users entity = new M_Users();
            entity.ID = txtE_UID1;
            entity.NAME = txtE_NAME1;
            entity.TELEPHONE = txtE_TELEPHONE1;
            entity.PWD = RE_PWD1;
            entity.AGENCY = agency;
            Msg msg1 = new B_Users().Regist(entity);
            // 注册成功后使 Token 过期
            if (msg1.code == 1)
            {
                msg.code = 1;
                msg.content = "添加用户成功";
            }
            else
            {
                msg.content = msg1.content;
            }
            return Json(msg);
        }
    }
}
