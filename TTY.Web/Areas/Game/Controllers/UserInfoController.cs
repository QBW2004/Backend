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
        [AjaxOnly]
        [HttpPost]
        public ActionResult GetOnlineUsers()
        {
            Msg msg = new Msg(0, "查询失败！");
            try
            {
                List<OnlinePlayerInfo> players = new PlayerStateService().QueryAllOnlinePlayers();
                FillPlayerProfits(players);
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
        /// 总盈亏 = 购币 - 兑换（与用户管理页的总盈利同口径）
        /// </summary>
        private void FillPlayerProfits(List<OnlinePlayerInfo> players)
        {
            if (players == null || players.Count < 1)
                return;
            M_LoginUser loginUser = WebHelper.GetLoginInfo();
            if (loginUser == null)
                return;
            B_Users bll = new B_Users();
            List<string> ids = players.Where(c => !string.IsNullOrWhiteSpace(c.ID)).Select(c => c.ID).Distinct().ToList();
            Dictionary<string, long?> profitMap = new Dictionary<string, long?>(StringComparer.OrdinalIgnoreCase);
            for (int i = 0; i < ids.Count; i += 100)
            {
                List<M_Users_DTO> users = bll.GetUserRowsByIds(ids.Skip(i).Take(100).ToList(), loginUser);
                foreach (M_Users_DTO user in users)
                    profitMap[user.ID] = user.Profit;
            }
            foreach (OnlinePlayerInfo player in players)
            {
                if (player.ID != null && profitMap.TryGetValue(player.ID, out long? profit))
                    player.Profit = profit ?? 0;
            }
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
                list = new B_Users().GetUsersList(mPage, mUsers, loginUser);
                if (list != null && list.rows != null)
                {
                    //  List<M_UserProit> profits = bll.GetAgencyProfits(loginUser);
                    foreach (var item in list.rows)
                    {
                        //  var tmp = profits.Find(c => c.Agency.Equals(item.ID));
                        item.Profit = item.COINS_BUY - item.COINS_BACK;
                        // item.PlayerBalance = (tmp != null ? tmp.PlayerBalance : 0);
                    }
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
                if (loginUser == null || (loginUser.UserPriv > 0 && loginUser.IsFrozen != 1))
                {
                    msg.content = "没有冻结权限！";
                    return Json(msg);
                }
                string id = form.Q<string>("ID");
                int frozen = form.Q<int>("frozen", 0);
                if (!string.IsNullOrWhiteSpace(id))
                {
                    M_Users mUsers = new M_Users { ID = id, FROZEN = frozen };
                    int val = new B_Users().FrozenUser(mUsers);
                    if (val > 0)
                    {
                        msg.code = 1;
                        msg.content = "冻结成功！";
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
                if (loginUser == null || (loginUser.UserPriv > 0 && loginUser.IsModifyPwd != 1))
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
                if (string.IsNullOrWhiteSpace(pwd))
                {
                    msg.content = "密码不能为空！";
                    return Json(msg);
                }

                M_Users entity = new M_Users { ID = id, PWD = pwd };
                int val = new B_Users().ChgPwd(entity);
                if (val > 0)
                {
                    msg.code = 1;
                    msg.content = "密码修改成功！";
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

                M_LoginUser loginUser = WebHelper.GetLoginInfo();
                msg = new B_UserControl().ApplyTotalControl(loginUser, id, mode, strength, goldThreshold,
                    cardAction, cardValue, cardNumber, cardTotal);
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
                M_LoginUser loginUser = WebHelper.GetLoginInfo();
                msg = new B_UserControl().CloseTotalControl(loginUser, id, mode);
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
                    msg.content = "设置成功" + (goldLimit > 0 && goldSaved ? "，金币阈值已设置" : "");
                }
                else if (goldLimit > 0 && goldSaved)
                {
                    msg.code = 1;
                    msg.content = "金币阈值已设置";
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
        public ActionResult ChgUserRateBet(FormCollection form)
        {
            Msg msg = new Msg(0, "下注修改失败！");
            try
            {
                string id = form.Q<string>("ID11");
                int action = form.Q<int>("Action11", -1);
                int val = form.Q<int>("Val11");
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
                if (loginUser == null || loginUser.UserPriv > 0)
                {
                    if (action == 3 && (loginUser?.IsKill ?? 0) != 1)
                    {
                        msg.content = "没有点杀权限！";
                        return Json(msg);
                    }
                    if (action == 4 && (loginUser?.IsProbability ?? 0) != 1)
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

                long goldLimitBet = form.Q<long>("GoldLimit11", 0);
                bool goldSavedBet = false;
                try
                {
                    SaveGoldLimitToDb(id, goldLimitBet, loginUser?.Accounts ?? "");
                    goldSavedBet = true;
                }
                catch (Exception exGl) { LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.UserInfoController), exGl); }

                string tmpDatasBet = tmpMsg != null ? (tmpMsg.datas as string) : null;
                bool ucOkBet = tmpMsg != null && (tmpMsg.code == 1 || tmpDatasBet == "UCNL" || tmpDatasBet == "UCOK");

                if (ucOkBet)
                {
                    msg.code = 1;
                    msg.content = "设置成功" + (goldLimitBet > 0 && goldSavedBet ? "，金币阈值已设置" : "");
                }
                else if (goldLimitBet > 0 && goldSavedBet)
                {
                    msg.code = 1;
                    msg.content = "金币阈值已设置";
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
                    msg.content = "设置成功" + (goldLimitPaiJi > 0 && goldSavedPai ? "，金币阈值已设置" : "");
                }
                else if (goldLimitPaiJi > 0 && goldSavedPai)
                {
                    msg.code = 1;
                    msg.content = "金币阈值已设置";
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
            Msg msg = new Msg(0, "拉霸修改失败！");
            try
            {
                string id = form.Q<string>("IDLaba");
                int action = form.Q<int>("ActionLaba", -1);
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
                if (loginUser == null || loginUser.UserPriv > 0)
                {
                    if ((loginUser?.IsKill ?? 0) != 1 && (loginUser?.IsProbability ?? 0) != 1)
                    {
                        msg.content = "没有控制权限！";
                        return Json(msg);
                    }
                }
                int set = 0;
                if (loginUser != null && loginUser.UserName == ConfigHelper.Get("admin"))
                {
                    set = 1;
                }

                int labaMode = form.Q<int>("LabaMode", 0);
                Msg tmpMsg;
                if (labaMode == 1)
                {
                    int valLaba = form.Q<int>("ValLaba");
                    tmpMsg = new GameCommandService().SetUserControl("27", valLaba.ToString().PadLeft(2, '0'), set, id);
                }
                else
                {
                    int symbol = form.Q<int>("SymbolLaba", 0);
                    int number = form.Q<int>("NumberLaba", 1);
                    int totalNumber = form.Q<int>("TotalLaba", 5);
                    tmpMsg = new GameCommandService().SetUserControl(
                        action.ToString().PadLeft(2, '0'),
                        symbol.ToString().PadLeft(2, '0'),
                        number.ToString().PadLeft(2, '0'),
                        totalNumber.ToString().PadLeft(2, '0'),
                        set, id);
                    try
                    {
                        using (var efSave = new GameDbContext())
                        {
                            efSave.Database.ExecuteSqlCommand(
                                "INSERT INTO usercontrolvalue (USERID, GAME_TYPE, CONTROL_TYPE, CONTROL_VALUE, NUMBER, TOTAL_NUMBER) VALUES ({0},1,{1},{2},{3},{4}) ON DUPLICATE KEY UPDATE GAME_TYPE=1, CONTROL_TYPE={1}, CONTROL_VALUE={2}, NUMBER={3}, TOTAL_NUMBER={4}",
                                id, action, symbol, number, totalNumber);
                        }
                    }
                    catch (Exception exSave) { LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.UserInfoController), exSave); }
                }

                long goldLimitLaba = form.Q<long>("GoldLimitLaba", 0);
                bool goldSavedLaba = false;
                try
                {
                    SaveGoldLimitToDb(id, goldLimitLaba, loginUser?.Accounts ?? "");
                    goldSavedLaba = true;
                }
                catch (Exception exGl) { LogHelper.WriteLog(typeof(YYT.Web.Areas.Game.Controllers.UserInfoController), exGl); }

                string tmpDatasLaba = tmpMsg != null ? (tmpMsg.datas as string) : null;
                bool ucOkLaba = tmpMsg != null && (tmpMsg.code == 1 || tmpDatasLaba == "UCNL" || tmpDatasLaba == "UCOK");

                if (ucOkLaba)
                {
                    msg.code = 1;
                    msg.content = "设置成功" + (goldLimitLaba > 0 && goldSavedLaba ? "，金币阈值已设置" : "");
                }
                else if (goldLimitLaba > 0 && goldSavedLaba)
                {
                    msg.code = 1;
                    msg.content = "金币阈值已设置";
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
                    msg.content = "只能踢出自己代理线内的玩家！";
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

            if (loginUser.UserPriv != 1)
            {
                msg.content = "一键踢出整条线仅开放给一级代理！";
                return Json(msg);
            }

            List<string> onlinePlayers = (loginUser.ManageScope ?? 1) == 2
                ? new B_Admin().GetOnlinePlayerAccountsInLine(loginUser.Accounts)
                : new B_Admin().GetOnlinePlayerAccountsByAgency(loginUser.Accounts);
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

                if ((loginUser.ManageScope ?? 1) == 2)
                    return new B_Admin().IsInAgencyLine(ef, loginUser.Accounts, user.AGENCY);

                return user.AGENCY == loginUser.Accounts;
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
