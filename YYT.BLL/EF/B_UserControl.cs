using System;
using System.Collections.Generic;
using System.Linq;
using YYT.BLL.Services.GameServer;
using YYT.Common;
using YYT.Entity;

namespace YYT.BLL.EF
{
    /// <summary>
    /// 鱼机和玩家控制（点杀/放水/钻上限）状态机
    /// </summary>
    public class B_UserControl
    {
        /// <summary>
        /// 鱼机机台范围控制的目标标识（进入鱼机的所有玩家）
        /// </summary>
        public const string MACHINE_TARGET = "*";
        /// <summary>
        /// 鱼机游戏类型（usercontrolstatus.GameType）
        /// </summary>
        public const int GAMETYPE_FISH = 1;

        /// <summary>
        /// UC 扩展指令码：05=点杀目标金额 06=放水目标金额 07=钻上限（金额=0 表示取消该项控制）
        /// </summary>
        private static string ModeToUcCode(int mode)
        {
            switch (mode)
            {
                case (int)EControlMode.Kill: return "05";
                case (int)EControlMode.Release: return "06";
                case (int)EControlMode.Limit: return "07";
            }
            return null;
        }

        /// <summary>
        /// 应用控制规则（同一目标+同一模式的旧 Active 记录会被置为 Expired 后新建）
        /// </summary>
        /// <param name="loginUser">操作人</param>
        /// <param name="scope">1=进入鱼机的所有玩家 2=精确到用户</param>
        /// <param name="gameId">机台范围时针对的鱼机（0=全部鱼机）</param>
        /// <param name="userId">精确到用户时的玩家账号</param>
        /// <param name="rules">要启用的规则列表（ControlMode + 金额）</param>
        public Msg ApplyControls(M_LoginUser loginUser, int scope, int gameId, string userId, List<KeyValuePair<int, long>> rules)
        {
            Msg msg = new Msg(0, "设置失败！");
            if (loginUser == null)
            {
                msg.content = "登录信息失效，请重新登录！";
                return msg;
            }
            if (scope != 1 && scope != 2)
            {
                msg.content = "请先选择控制条件（鱼机范围或精确到用户）！";
                return msg;
            }
            if (rules == null || rules.Count < 1)
            {
                msg.content = "请至少选择一个控制规则！";
                return msg;
            }
            foreach (var rule in rules)
            {
                if (ModeToUcCode(rule.Key) == null)
                {
                    msg.content = "无效的控制规则！";
                    return msg;
                }
                if (rule.Value <= 0)
                {
                    msg.content = "控制金额必须大于 0！";
                    return msg;
                }
            }

            // 权限校验：点杀需 IsKill，放水/钻上限需 IsProbability；机台范围仅超级管理员
            if (loginUser.UserPriv > 0)
            {
                if (scope == 1)
                {
                    msg.content = "只有超级管理员可以对整个鱼机设置控制！";
                    return msg;
                }
                foreach (var rule in rules)
                {
                    if (rule.Key == (int)EControlMode.Kill && (loginUser.IsKill ?? 0) != 1)
                    {
                        msg.content = "没有点杀权限！";
                        return msg;
                    }
                    if (rule.Key != (int)EControlMode.Kill && (loginUser.IsProbability ?? 0) != 1)
                    {
                        msg.content = "没有放水/控制权限！";
                        return msg;
                    }
                }
            }

            string target;
            if (scope == 1)
            {
                target = MACHINE_TARGET;
            }
            else
            {
                if (string.IsNullOrWhiteSpace(userId))
                {
                    msg.content = "请填写玩家账号！";
                    return msg;
                }
                target = userId.Trim();
                gameId = 0;
            }

            try
            {
                using (var ef = new GameDbContext())
                {
                    if (scope == 2)
                    {
                        var user = ef.Users.FirstOrDefault(u => u.ID == target);
                        if (user == null)
                        {
                            msg.content = "此账号玩家不存在！";
                            return msg;
                        }
                        if (!new B_Admin().CanManagePlayer(ef, loginUser, user.AGENCY))
                        {
                            msg.content = "只能控制自己管理范围内的玩家！";
                            return msg;
                        }
                    }
                    else
                    {
                        if (gameId > 0 && !ef.Games.Any(g => g.GameId == gameId && g.GameType == 2))
                        {
                            msg.content = "所选鱼机不存在！";
                            return msg;
                        }
                    }

                    foreach (var rule in rules)
                    {
                        int mode = rule.Key;
                        // 同目标+同模式的旧执行中记录置为过期
                        var olds = ef.UserControlStatuses
                            .Where(c => c.UserID == target && c.GameType == GAMETYPE_FISH && c.ControlMode == mode && c.Status == (int)EControlStatus.Active)
                            .ToList();
                        foreach (var old in olds)
                        {
                            old.Status = (int)EControlStatus.Expired;
                            old.ExpiredTime = DateTime.Now;
                        }

                        var row = new M_UserControlStatus
                        {
                            UserID = target,
                            GameType = GAMETYPE_FISH,
                            GameId = gameId,
                            ControlMode = mode,
                            TargetCoins = mode == (int)EControlMode.Limit ? 0 : rule.Value,
                            LimitCoins = mode == (int)EControlMode.Limit ? rule.Value : 0,
                            ConsumedCoins = 0,
                            GrantedCoins = 0,
                            KillRatio = 60,
                            Status = (int)EControlStatus.Active,
                            CreatedBy = loginUser.Accounts,
                            CreatedTime = DateTime.Now
                        };
                        ef.UserControlStatuses.Add(row);
                    }
                    ef.SaveChanges();
                }
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(B_UserControl), ex);
                msg.content = "数据库写入失败！";
                return msg;
            }

            // 下发游戏服务器 UC 扩展指令（DB 已落库，指令失败也保留状态，可重发）
            List<string> srvResults = new List<string>();
            bool allOk = true;
            foreach (var rule in rules)
            {
                var tmpMsg = SendUcCommand(rule.Key, rule.Value, gameId, target);
                if (tmpMsg == null || tmpMsg.code != 1)
                    allOk = false;
                srvResults.Add(ModeName(rule.Key) + "：" + (tmpMsg == null ? "无响应" : tmpMsg.content));

                // 精确到用户的点杀/放水同时走既有 UC 01/02 通道（ServerCenterUpdateControlConfig），
                // 服务端内置算法即刻生效，强度取 KillRatio 系数
                if (scope == 2 && rule.Key != (int)EControlMode.Limit)
                    SendLegacyUcCommand(rule.Key, 60, loginUser, target);
            }
            MarkManagerOptOperator(target, loginUser.Accounts);

            msg.code = 1;
            msg.content = allOk
                ? "控制规则已生效！"
                : "控制规则已保存，但服务器指令未全部确认（" + string.Join("；", srvResults) + "）";
            return msg;
        }

        /// <summary>
        /// 关闭一条执行中的控制
        /// </summary>
        public Msg CloseControl(M_LoginUser loginUser, int id)
        {
            Msg msg = new Msg(0, "关闭失败！");
            if (loginUser == null)
            {
                msg.content = "登录信息失效，请重新登录！";
                return msg;
            }
            try
            {
                M_UserControlStatus row;
                using (var ef = new GameDbContext())
                {
                    row = ef.UserControlStatuses.FirstOrDefault(c => c.ID == id);
                    if (row == null)
                    {
                        msg.content = "控制记录不存在！";
                        return msg;
                    }
                    if (row.Status != (int)EControlStatus.Active)
                    {
                        msg.content = "该控制已不在执行中！";
                        return msg;
                    }
                    if (loginUser.UserPriv > 0)
                    {
                        if (row.UserID == MACHINE_TARGET)
                        {
                            msg.content = "只有超级管理员可以关闭鱼机范围控制！";
                            return msg;
                        }
                        var user = ef.Users.FirstOrDefault(u => u.ID == row.UserID);
                        if (user == null || !new B_Admin().CanManagePlayer(ef, loginUser, user.AGENCY))
                        {
                            msg.content = "只能关闭自己管理范围内玩家的控制！";
                            return msg;
                        }
                    }
                    row.Status = (int)EControlStatus.Expired;
                    row.ExpiredTime = DateTime.Now;
                    ef.SaveChanges();
                }

                // 金额=0 表示取消该模式控制
                var tmpMsg = SendUcCommand(row.ControlMode, 0, row.GameId, row.UserID);
                if (row.UserID != MACHINE_TARGET && row.ControlMode != (int)EControlMode.Limit)
                    SendLegacyUcCommand(row.ControlMode, 0, loginUser, row.UserID);
                MarkManagerOptOperator(row.UserID, loginUser.Accounts);
                msg.code = 1;
                msg.content = (tmpMsg != null && tmpMsg.code == 1)
                    ? "关闭成功！"
                    : "已关闭，但服务器指令未确认（" + (tmpMsg == null ? "无响应" : tmpMsg.content) + "）";
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(B_UserControl), ex);
            }
            return msg;
        }

        /// <summary>
        /// 控制状态读取的过滤口径：总台/特级代理返回 null（不过滤看全部）；
        /// 其余代理返回自己的账号——只能看到 CreatedBy=自己 的控制状态，
        /// admin/特级/上级/平级代理设置的一律不可见。
        /// 设置入口不受此限制：看不到旧状态也能设置，且直接覆盖。
        /// </summary>
        private static string GetVisibleControlCreator(M_LoginUser loginUser)
        {
            int priv = loginUser.UserPriv ?? -1;
            if (priv == AgencyRules.SuperAdminPriv || priv == AgencyRules.TopAgentPriv)
                return null;
            return loginUser.Accounts;
        }

        /// <summary>
        /// 分页查询控制记录（普通代理仅能看到自己设置的记录；机台范围行由总台创建，对普通代理同样不可见；总台/特级看全部）
        /// </summary>
        public M_EasyuiGridData<M_UserControlStatus_DTO> GetControls(M_Page mPage, string userId, int status, M_LoginUser loginUser)
        {
            var list = new M_EasyuiGridData<M_UserControlStatus_DTO>();
            if (loginUser == null)
                return list;
            try
            {
                using (var ef = new GameDbContext())
                {
                    var rst = from c in ef.UserControlStatuses
                              join u in ef.Users on c.UserID equals u.ID into gu
                              from u in gu.DefaultIfEmpty()
                              join g in ef.Games on c.GameId equals g.GameId into gg
                              from g in gg.DefaultIfEmpty()
                              where c.GameType == GAMETYPE_FISH
                              select new
                              {
                                  c.ID,
                                  c.UserID,
                                  c.GameType,
                                  c.GameId,
                                  GameName = g == null ? null : g.Name,
                                  c.ControlMode,
                                  c.TargetCoins,
                                  c.ConsumedCoins,
                                  c.GrantedCoins,
                                  c.LimitCoins,
                                  c.Status,
                                  c.CreatedBy,
                                  c.CreatedTime,
                                  AGENCY = u == null ? null : u.AGENCY
                              };

                    string creator = GetVisibleControlCreator(loginUser);
                    if (creator != null)
                        rst = rst.Where(c => c.CreatedBy == creator);
                    if (!string.IsNullOrWhiteSpace(userId))
                        rst = rst.Where(c => c.UserID == userId);
                    if (status >= 0)
                        rst = rst.Where(c => c.Status == status);

                    mPage.SetTotalCount(rst.Count());
                    list.rows = rst
                        .OrderByDescending(c => c.CreatedTime)
                        .ThenByDescending(c => c.ID)
                        .Skip(mPage.PageSize * (mPage.PageIndex - 1)).Take(mPage.PageSize)
                        .ToList()
                        .Select(c => new M_UserControlStatus_DTO
                        {
                            ID = c.ID,
                            UserID = c.UserID,
                            GameType = c.GameType,
                            GameId = c.GameId,
                            GameName = c.GameName,
                            ControlMode = c.ControlMode,
                            TargetCoins = c.TargetCoins,
                            ConsumedCoins = c.ConsumedCoins, // 净盈亏口径下进度可能回退为负，显示负数（已取消0封底）
                            GrantedCoins = c.GrantedCoins,
                            LimitCoins = c.LimitCoins,
                            Status = c.Status,
                            CreatedBy = c.CreatedBy,
                            CreatedTime = c.CreatedTime.ToString("yyyy-MM-dd HH:mm:ss"),
                            AGENCY = c.AGENCY
                        })
                        .ToList();
                    list.total = mPage.TotalCount;
                }
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(B_UserControl), ex);
            }
            return list;
        }

        /// <summary>
        /// 手机端控制管理：总控记录分页（GameType=9，按设置时间倒序）。
        /// 非超管仅限代理线内玩家；activeCount 返回筛选范围内执行中的控制条数。
        /// 控牌行的牌型名/次数由前端按 GameId(=cardAction)+KillRatio(=cardValue)+TargetCoins(=cardNumber) 解析。
        /// </summary>
        public M_EasyuiGridData<M_UserControlStatus_DTO> GetTotalControlRecords(M_Page mPage, M_LoginUser loginUser, DateTime? startTime, DateTime? endTime, out int activeCount)
        {
            var list = new M_EasyuiGridData<M_UserControlStatus_DTO>();
            activeCount = 0;
            if (loginUser == null)
                return list;
            try
            {
                using (var ef = new GameDbContext())
                {
                    var rst = from c in ef.UserControlStatuses
                              join u in ef.Users on c.UserID equals u.ID into gu
                              from u in gu.DefaultIfEmpty()
                              where c.GameType == GAMETYPE_TOTAL
                              select new
                              {
                                  c.ID,
                                  c.UserID,
                                  c.GameId,
                                  c.ControlMode,
                                  c.TargetCoins,
                                  c.ConsumedCoins,
                                  c.GrantedCoins,
                                  c.KillRatio,
                                  c.Status,
                                  c.CreatedBy,
                                  c.CreatedTime,
                                  AGENCY = u == null ? null : u.AGENCY
                              };

                    string creator = GetVisibleControlCreator(loginUser);
                    if (creator != null)
                        rst = rst.Where(c => c.CreatedBy == creator);
                    if (startTime != null)
                        rst = rst.Where(c => c.CreatedTime >= startTime.Value);
                    if (endTime != null)
                        rst = rst.Where(c => c.CreatedTime < endTime.Value);

                    activeCount = rst.Count(c => c.Status == (int)EControlStatus.Active);
                    mPage.SetTotalCount(rst.Count());
                    list.rows = rst
                        .OrderByDescending(c => c.ID)
                        .Skip(mPage.PageSize * (mPage.PageIndex - 1)).Take(mPage.PageSize)
                        .ToList()
                        .Select(c => new M_UserControlStatus_DTO
                        {
                            ID = c.ID,
                            UserID = c.UserID,
                            GameType = GAMETYPE_TOTAL,
                            GameId = c.GameId,
                            ControlMode = c.ControlMode,
                            TargetCoins = c.TargetCoins,
                            ConsumedCoins = c.ConsumedCoins,
                            GrantedCoins = c.GrantedCoins,
                            LimitCoins = c.KillRatio,
                            Status = c.Status,
                            CreatedBy = c.CreatedBy,
                            CreatedTime = c.CreatedTime.ToString("yyyy-MM-dd HH:mm:ss")
                        })
                        .ToList();
                    list.total = mPage.TotalCount;
                }
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(B_UserControl), ex);
            }
            return list;
        }

        /// <summary>
        /// 下发 UC 扩展指令：UC + 指令码(2位) + 金额(12位左补零) + 游戏ID(4位左补零) + 目标账号（"*"=机台范围）
        /// </summary>
        private Msg SendUcCommand(int mode, long amount, int gameId, string target)
        {
            try
            {
                string code = ModeToUcCode(mode);
                if (code == null)
                    return new Msg(0, "无效的控制模式！");
                return new GameCommandService().SetUserControl(
                    code,
                    amount.ToString().PadLeft(12, '0'),
                    gameId.ToString().PadLeft(4, '0'),
                    target);
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(B_UserControl), ex);
                return new Msg(0, "服务器指令发送异常：" + ex.Message);
            }
        }

        /// <summary>
        /// 既有 UC 通道（与 ChgUserRate 相同格式）：UC + 类型(01点杀/02放水) + 强度(2位) + set(1位) + 玩家账号；强度 0 表示解除
        /// </summary>
        private void SendLegacyUcCommand(int mode, int val, M_LoginUser loginUser, string userId)
        {
            try
            {
                string code = mode == (int)EControlMode.Kill ? "01" : "02";
                int set = (loginUser != null && loginUser.UserName == ConfigHelper.Get("admin")) ? 1 : 0;
                new GameCommandService().SetUserControl(code, val.ToString().PadLeft(2, '0'), set, userId);
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(B_UserControl), ex);
            }
        }

        private static string ModeName(int mode)
        {
            switch (mode)
            {
                case (int)EControlMode.Kill: return "点杀";
                case (int)EControlMode.Release: return "放水";
                case (int)EControlMode.Limit: return "钻上限";
                case (int)EControlMode.TotalKill: return "总点杀";
                case (int)EControlMode.TotalRelease: return "总放水";
                case (int)EControlMode.TotalCard: return "总控牌";
            }
            return "未知";
        }

        /// <summary>
        /// 总控（总点杀/总放水/总控牌）记录的 GameType 标识
        /// </summary>
        public const int GAMETYPE_TOTAL = 9;

        private static bool IsTotalMode(int mode)
        {
            return mode == (int)EControlMode.TotalKill
                || mode == (int)EControlMode.TotalRelease
                || mode == (int)EControlMode.TotalCard;
        }

        private static bool CanUseTotalMode(M_LoginUser loginUser, int mode)
        {
            if (loginUser == null)
                return false;
            if (loginUser.UserPriv == 0)
                return true;
            if (mode == (int)EControlMode.TotalKill)
                return (loginUser.IsKill ?? 0) == 1;
            if (mode == (int)EControlMode.TotalRelease)
                return (loginUser.IsProbability ?? 0) == 1;
            if (mode == (int)EControlMode.TotalCard)
                return (loginUser.IsRelease ?? 0) == 1;
            return false;
        }

        /// <summary>
        /// 在线玩家的当前游戏能力校验。离线/大厅玩家不在这里拒绝，
        /// 由中心服在玩家真正进入子游戏时按同一能力矩阵判定。
        /// </summary>
        private static Msg ValidateCurrentGameCapability(string userId, int mode)
        {
            if (mode != (int)EControlMode.TotalKill && mode != (int)EControlMode.TotalRelease)
                return null;
            try
            {
                PlayerRuntimeState state = new GameCommandService().QueryPlayerRuntimeState(userId);
                if (state == null || !state.QuerySucceeded || state.RuntimeStatus != 1 || !state.GameId.HasValue)
                    return null;
                int gameId = state.GameId.Value;
                if (!TotalControlRules.IsModeSupportedForGame(mode, gameId))
                    return new Msg(0, TotalControlRules.UnsupportedModeMessage(mode, gameId));
            }
            catch (Exception ex)
            {
                // 实时查询失败时保留离线设置语义，中心服会在实际应用时返回明确拒绝。
                LogHelper.WriteLog(typeof(B_UserControl), ex);
            }
            return null;
        }

        /// <summary>
        /// 设置总控：总点杀(4)=鱼机+押注+牌机+三款拉霸+麻将胡了54；
        /// 总放水(5)累计上述游戏实际净收益（含控牌），仅鱼机/押注应用放水强度；
        /// 总控牌(6)=牌机+拉霸（含麻将胡了送奖控牌）。
        /// 累计吃分/放分达到钻阈值(goldThreshold)后自动失效，恢复桌台参数难度。
        /// 总控牌时 cardAction/cardValue/cardNumber/cardTotal 为精确控牌参数（与牌机控牌一致）。
        /// 互斥口径（TotalControlRules.ModesReplacedBy）：吃分/放水互斥，后下的覆盖先下的，
        /// 覆盖时先给旧模式补发解除指令；控牌与吃分/放水共存，新控牌仅替换旧控牌。
        /// </summary>
        public Msg ApplyTotalControl(M_LoginUser loginUser, string userId, int mode, int strength, long goldThreshold,
            int cardAction, int cardValue, int cardNumber, int cardTotal, bool mobileFixedCard = false, decimal? expectedBetDiamonds = null)
        {
            Msg msg = new Msg(0, "设置失败！");
            if (loginUser == null)
            {
                msg.content = "登录信息失效，请重新登录！";
                return msg;
            }
            if (!IsTotalMode(mode))
            {
                msg.content = "无效的总控模式！";
                return msg;
            }
            if (string.IsNullOrWhiteSpace(userId))
            {
                msg.content = "请填写玩家账号！";
                return msg;
            }
            // 下拉框的“关闭”与关闭按钮走同一事务，不能创建强度0但仍累计目标的 Active 行。
            if (mode != (int)EControlMode.TotalCard && strength == 0)
                return CloseTotalControl(loginUser, userId, mode, mobileFixedCard);
            // 控牌按次数控制，不需要钻阈值；仅吃分/放分需要钻阈值
            if (mode != (int)EControlMode.TotalCard && goldThreshold <= 0)
            {
                msg.content = "目标必须大于 0！";
                return msg;
            }
            if (mode == (int)EControlMode.TotalCard)
            {
                // 手机端需求固定为控制 1 次、限定在 5 把内；仅当请求明确来自手机端时校验该约束，
                // 保留电脑端原有的可配置次数/总把数能力。
                if (mobileFixedCard && (cardNumber != 1 || cardTotal != 5))
                {
                    msg.content = "控牌规则固定为 1 次、5 把之内！";
                    return msg;
                }
                if ((cardAction < 5 || cardAction > 17) && cardAction != 19 && cardAction != 20)
                {
                    msg.content = "无效的控牌类型！";
                    return msg;
                }
                if (cardAction == 19 && (cardValue < 1 || cardValue > 6))
                {
                    msg.content = "无效的麻将胡了送奖牌型！";
                    return msg;
                }
                // 牌机型(5-14/20大白兔)牌型值 0-12（与服务端 te_CardsType 枚举一致），99=关闭控制；
                // 火凤凰(14)扩展 13-18=正宗大四梅x1~x6、大白兔(20)扩展 13-26=x1~x14
                //（服务端 AlgProb 按 ctrl_value-12 取倍数，MTH_DABAITU 放开到 26）；
                // 拉霸型(15-17)为符号/面板位体系，值范围不同，保持宽松校验
                if (((cardAction >= 5 && cardAction <= 14) || cardAction == 20) && cardValue != 99 &&
                    (cardValue < 0 || cardValue > 12) && !((cardAction == 14 || cardAction == 20) && cardValue >= 13 && cardValue <= (cardAction == 20 ? 26 : 18)))
                {
                    msg.content = "无效的控牌牌型（0-12，火凤凰正宗大四梅 13-18、大白兔 13-26，或 99 关闭）！";
                    return msg;
                }
                // 大字板(5)五鬼已下线：控牌牌型 12(五鬼) 与服务端 AlgProb 控制通道封死保持一致
                if (cardAction == 5 && cardValue == 12)
                {
                    msg.content = "大字板五鬼已下线，无法控牌五鬼！";
                    return msg;
                }
                if (!mobileFixedCard && (cardNumber < 1 || cardTotal < 5 || cardTotal > 50 || cardNumber > cardTotal))
                {
                    msg.content = "控牌数量/总把数无效（数量≥1，总把数 5-50，数量≤总把数）！";
                    return msg;
                }
            }
            else
            {
                if (strength < 0 || strength > 11)
                {
                    msg.content = "控制强度无效（0-11）！";
                    return msg;
                }
            }

            // 权限校验：总点杀需 IsKill，总放水需 IsProbability，总控牌需 IsRelease（与单游戏控制一致）
            if (loginUser.UserPriv > 0)
            {
                if (mode == (int)EControlMode.TotalKill && (loginUser.IsKill ?? 0) != 1)
                {
                    msg.content = "没有点杀权限！";
                    return msg;
                }
                if (mode == (int)EControlMode.TotalRelease && (loginUser.IsProbability ?? 0) != 1)
                {
                    msg.content = "没有放水权限！";
                    return msg;
                }
                if (mode == (int)EControlMode.TotalCard && (loginUser.IsRelease ?? 0) != 1)
                {
                    msg.content = "没有控牌权限！";
                    return msg;
                }
            }

            if (mode == 6 && (cardValue == 99 || (cardAction >= 15 && cardAction <= 17 && cardValue == 10)))
                return CloseTotalControl(loginUser, userId.Trim(), 6, mobileFixedCard);
            string target = userId.Trim();
            Msg currentCapability = ValidateCurrentGameCapability(target, mode);
            if (currentCapability != null)
                return currentCapability;

            // 本次设置覆盖掉的旧总控模式（吃分/放水互斥时记录旧模式），DB 落库后先补发解除指令
            List<int> overriddenModes = new List<int>();
            int createdControlId = 0;
            try
            {
                var cardQuote = mode == 6 ? B_PrizePool.QuoteCard(target, cardAction, cardValue, cardNumber) : null;
                if (cardQuote != null && expectedBetDiamonds.HasValue && Math.Round(cardQuote.BetDiamonds, 8) != Math.Round(expectedBetDiamonds.Value, 8))
                    return new Msg(0, "玩家押注已变化，请重新查询后送奖！");
                decimal cardAmount = cardQuote == null ? 0 : cardQuote.RequiredDiamonds;
                var location = cardQuote == null ? new YYT.BLL.Services.GameServer.PipeGameServerClient().QueryAllOnlinePlayers()?.FirstOrDefault(p => p.ID == target && p.Status == 0) : null;
                using (var ef = new GameDbContext())
                using (var transaction = ef.Database.BeginTransaction(System.Data.IsolationLevel.ReadCommitted))
                {
                    // 与麻将结算统一先锁玩家；指令状态及次数同时提交，避免并发替换读到半份赠送。
                    ef.Database.SqlQuery<string>("SELECT ID FROM users WHERE ID={0} FOR UPDATE", target).ToList();
                    var user = ef.Users.FirstOrDefault(u => u.ID == target);
                    if (user == null)
                    {
                        msg.content = "此账号玩家不存在！";
                        return msg;
                    }
                    if (!new B_Admin().CanManagePlayer(ef, loginUser, user.AGENCY))
                    {
                        msg.content = "只能控制自己管理范围内的玩家！";
                        return msg;
                    }

                    B_PrizePool.CheckFunding(ef, loginUser, mode, goldThreshold, cardAmount);

                    // 总控互斥新口径：吃分(4)/放水(5)互斥，后下的覆盖先下的；控牌(6)只替换旧控牌，与吃分/放水共存
                    var replaced = TotalControlRules.ModesReplacedBy(mode);
                    var olds = ef.UserControlStatuses
                        .Where(c => c.UserID == target && c.GameType == GAMETYPE_TOTAL && c.Status == (int)EControlStatus.Active
                            && replaced.Contains(c.ControlMode))
                        .ToList();
                    // 记下被覆盖、且与新控不同的旧模式：DB 落库后需先补发该模式的解除指令
                    overriddenModes = olds.Select(o => o.ControlMode).Where(m => m != mode).Distinct().ToList();
                    foreach (var old in olds)
                    {
                        old.Status = (int)EControlStatus.Expired;
                        old.ExpiredTime = DateTime.Now;
                    }

                    var row = new M_UserControlStatus
                    {
                        UserID = target,
                        GameType = GAMETYPE_TOTAL,
                        GameId = mode == (int)EControlMode.TotalCard ? cardAction : 0, // 控牌模式存 cardAction，供次数回显精确关联
                        ControlMode = mode,
                        TargetCoins = mode == (int)EControlMode.TotalCard ? cardNumber : goldThreshold,
                        LimitCoins = 0,
                        ConsumedCoins = 0,
                        GrantedCoins = 0,
                        KillRatio = mode == (int)EControlMode.TotalCard ? cardValue : strength,
                        Status = (int)EControlStatus.Active,
                        CreatedBy = loginUser.Accounts,
                        CreatedTime = DateTime.Now
                    };
                    ef.UserControlStatuses.Add(row);
                    ef.SaveChanges();
                    createdControlId = row.ID;
                    B_PrizePool.AttachControl(ef, loginUser, row, cardQuote != null ? cardQuote.GameId : (location == null ? 0 : location.GameID),
                        cardQuote != null ? (int?)cardQuote.TableId : (location == null ? null : (int?)location.TableId));

                    // 点杀记录由后台写入（含操作员），服务器侧不再记录，避免指令重发产生重复记录
                    int optCode = mode == (int)EControlMode.TotalKill ? 21 : (mode == (int)EControlMode.TotalRelease ? 22 : 23);
                    int optValue = mode == (int)EControlMode.TotalCard ? cardValue : strength;
                    ef.Database.ExecuteSqlCommand(
                        "INSERT INTO manageropt(UserID,NAME,Opt,OptValue,Type,OPERATOR) VALUES({0},{1},{2},{3},'UC',{4})",
                        target, user.NAME ?? "", optCode, optValue, loginUser.Accounts);

                    // 换成其他游戏赠送也清除已过期的旧次数，禁止下次进原游戏恢复旧赠送。
                    foreach (var oldCard in olds.Where(o => o.ControlMode == (int)EControlMode.TotalCard))
                    {
                        ef.Database.ExecuteSqlCommand(
                            "DELETE FROM usercontrolvalue WHERE USERID={0} AND CONTROL_TYPE={1}", target, oldCard.GameId);
                    }

                    // 控牌模式：同步写入 usercontrolvalue（控牌类型/控牌值/次数/总次数），供状态回显次数
                    // 按 (USERID, CONTROL_TYPE) 区分游戏：金皇冠(12)和火凤凰(14)各自独立一行
                    if (mode == (int)EControlMode.TotalCard)
                    {
                        ef.Database.ExecuteSqlCommand(
                            "DELETE FROM usercontrolvalue WHERE USERID={0} AND CONTROL_TYPE={1}",
                            target, cardAction);
                        ef.Database.ExecuteSqlCommand(
                            "INSERT INTO usercontrolvalue (USERID,GAME_TYPE,CONTROL_TYPE,CONTROL_VALUE,NUMBER,TOTAL_NUMBER) VALUES({0},1,{1},{2},{3},{4})",
                            target, cardAction, cardValue, cardNumber, cardTotal);
                    }
                    transaction.Commit();
                }
            }
            catch (InvalidOperationException ex)
            {
                return new Msg(0, ex.Message);
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(B_UserControl), ex);
                msg.content = "数据库写入失败！";
                return msg;
            }

            // 吃分/放水互斥覆盖：先给被覆盖的旧模式发解除指令，游戏服收到解除才会恢复桌台参数并清掉牌机吃分标志
            foreach (var m in overriddenModes)
            {
                SendTotalUcCommand(m, 0, 0, 0, 0, 0, loginUser, target);
            }
            // 下发服务器指令（DB 已落库，玩家下次进游戏时服务端也会按 DB 应用总控）。
            // 手机端与电脑端统一走直发：只入发件箱等定时重试（间隔 60s）会让控制"点了半天不生效"；
            // 传输失败由发件箱+重试服务兜底，但中心服明确返回 UCER 的能力拒绝必须回滚本次 Active 行。
            Msg serverMsg = SendTotalUcCommand(mode, strength, cardAction, cardValue, cardNumber, cardTotal, loginUser, target);
            // UCER 表示中心服明确拒绝当前游戏能力；不能把已拒绝的行留在 Active，
            // 否则玩家下次进游戏会再次尝试并在后台显示“正在执行”。UCNL（离线/大厅）
            // 仍保留数据库状态，等待玩家进入游戏后应用。
            // SConnect 将所有非成功协议码归一为 code=0，但保留原始协议码在 datas。
            // 只能以 datas=UCER 区分“中心服明确拒绝”与可重试的管道失败/UCNL。
            if (TotalControlRules.IsServerCapabilityRejected(serverMsg))
            {
                try
                {
                    using (var ef = new GameDbContext())
                    using (var transaction = ef.Database.BeginTransaction(System.Data.IsolationLevel.ReadCommitted))
                    {
                        ef.Database.SqlQuery<string>("SELECT ID FROM users WHERE ID={0} FOR UPDATE", target).ToList();
                        var rejected = ef.UserControlStatuses.FirstOrDefault(c => c.ID == createdControlId);
                        if (rejected != null && rejected.Status == (int)EControlStatus.Active)
                        {
                            rejected.Status = (int)EControlStatus.Expired;
                            rejected.ExpiredTime = DateTime.Now;
                            ef.SaveChanges();
                            if (rejected.ControlMode == (int)EControlMode.TotalCard)
                            {
                                ef.Database.ExecuteSqlCommand(
                                    "DELETE FROM usercontrolvalue WHERE USERID={0} AND CONTROL_TYPE={1}", target, rejected.GameId);
                            }
                        }
                        transaction.Commit();
                    }
                }
                catch (Exception ex)
                {
                    LogHelper.WriteLog(typeof(B_UserControl), ex);
                }
                msg.code = 0;
                msg.content = string.IsNullOrWhiteSpace(serverMsg.content)
                    ? "当前游戏不支持该总控模式！"
                    : serverMsg.content;
                return msg;
            }
            msg.code = 1;
            msg.content = serverMsg != null && serverMsg.code == 1 ? "操作成功" : "已保存，等待游戏同步";
            return msg;
        }

        /// <summary>
        /// 查询玩家当前总控状态（三种模式各取最近一条执行中记录，含阈值进度）
        /// </summary>
        public Msg GetTotalControlStatus(M_LoginUser loginUser, string userId)
        {
            Msg msg = new Msg(0, "查询失败！");
            if (loginUser == null)
            {
                msg.content = "登录信息失效，请重新登录！";
                return msg;
            }
            if (string.IsNullOrWhiteSpace(userId))
            {
                msg.content = "请填写玩家账号！";
                return msg;
            }
            string target = userId.Trim();
            try
            {
                using (var ef = new GameDbContext())
                {
                    // 控制状态按设置人过滤：总台/特级看全部，其余代理只看自己设置的
                    // （admin/上级设置的状态对所属代理也不可见；看不到仍可设置并直接覆盖）
                    string creator = GetVisibleControlCreator(loginUser);
                    var statusQuery = ef.UserControlStatuses
                        .Where(c => c.UserID == target && c.GameType == GAMETYPE_TOTAL && c.Status == (int)EControlStatus.Active);
                    if (creator != null)
                        statusQuery = statusQuery.Where(c => c.CreatedBy == creator);
                    var rows = statusQuery
                        .OrderByDescending(c => c.ID)
                        .ToList()
                        .GroupBy(c => c.ControlMode)
                        .Select(g => g.First())
                        .Where(c => CanUseTotalMode(loginUser, c.ControlMode))
                        .Select(c => new M_UserControlStatus_DTO
                        {
                            ID = c.ID,
                            UserID = c.UserID,
                            GameType = c.GameType,
                            GameId = c.GameId,
                            ControlMode = c.ControlMode,
                            TargetCoins = c.TargetCoins,
                            ConsumedCoins = c.ConsumedCoins, // 净盈亏口径下进度可能回退为负，显示负数（已取消0封底）
                            GrantedCoins = c.GrantedCoins,
                            LimitCoins = c.KillRatio, // 强度/控牌值借用 LimitCoins 字段回显
                            Status = c.Status,
                            CreatedBy = c.CreatedBy,
                            CreatedTime = c.CreatedTime.ToString("yyyy-MM-dd HH:mm:ss")
                        })
                        .ToList();

                    // 控牌模式(mode=6)：联查 usercontrolvalue 表回显次数/总次数
                    // 按 usercontrolstatus.GameId(=cardAction) 精确关联该游戏的行，避免取到其他游戏行导致次数错乱
                    var cardRow = rows.FirstOrDefault(c => c.ControlMode == (int)EControlMode.TotalCard);
                    if (cardRow != null)
                    {
                        var ucRow = ef.Database.SqlQuery<M_UserControlValueRow>(
                            "SELECT ID AS ID, USERID AS UserID, CONTROL_TYPE AS CtrlType, CONTROL_VALUE AS CtrlValue, NUMBER AS Number, TOTAL_NUMBER AS TotalNumber FROM usercontrolvalue WHERE USERID={0} AND CONTROL_TYPE={1} AND NUMBER>0 ORDER BY ID DESC LIMIT 1",
                            target, cardRow.GameId).FirstOrDefault();
                        if (ucRow != null)
                        {
                            cardRow.CardNumber = ucRow.Number;
                            cardRow.CardTotal = ucRow.TotalNumber;
                        }
                    }
                    // 过滤掉控牌次数已消耗完的记录
                    rows = rows.Where(r => !(r.ControlMode == (int)EControlMode.TotalCard && r.CardNumber == 0)).ToList();
                    // 展示口径：每个玩家只留一条——控牌没完成只显示控牌；控牌结束后才显示未完成的吃分/放水
                    rows = TotalControlRules.PickDisplayControls(rows);

                    msg.code = 1;
                    msg.content = "";
                    msg.datas = rows;
                }
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(B_UserControl), ex);
            }
            return msg;
        }

        /// <summary>
        /// 批量查询多个玩家当前执行中的总控（用于在线用户列表"控制"列显示，每个玩家每模式取最近一条）
        /// </summary>
        public Msg GetActiveTotalControls(M_LoginUser loginUser, List<string> userIds)
        {
            Msg msg = new Msg(0, "查询失败！");
            if (loginUser == null)
            {
                msg.content = "登录信息失效，请重新登录！";
                return msg;
            }
            var ids = (userIds ?? new List<string>())
                .Where(s => !string.IsNullOrWhiteSpace(s))
                .Select(s => s.Trim())
                .Distinct()
                .ToList();
            var result = new List<M_UserControlStatus_DTO>();
            if (ids.Count == 0)
            {
                msg.code = 1;
                msg.content = "";
                msg.datas = result;
                return msg;
            }
            try
            {
                using (var ef = new GameDbContext())
                {
                    var activeQuery = ef.UserControlStatuses
                        .Where(c => c.GameType == GAMETYPE_TOTAL && c.Status == (int)EControlStatus.Active && ids.Contains(c.UserID));
                    // 读取接口也必须过滤，避免伪造 UserIDs 查看；口径与单人状态一致：
                    // 总台/特级看全部，其余代理只看 CreatedBy=自己 的记录
                    string creator = GetVisibleControlCreator(loginUser);
                    if (creator != null)
                        activeQuery = activeQuery.Where(c => c.CreatedBy == creator);
                    var rows = activeQuery
                        .OrderByDescending(c => c.ID)
                        .ToList()
                        .GroupBy(c => c.UserID + "_" + c.ControlMode)
                        .Select(g => g.First())
                        .Where(c => CanUseTotalMode(loginUser, c.ControlMode))
                        .Select(c => new M_UserControlStatus_DTO
                        {
                            ID = c.ID,
                            UserID = c.UserID,
                            GameType = c.GameType,
                            GameId = c.GameId,
                            ControlMode = c.ControlMode,
                            TargetCoins = c.TargetCoins,
                            ConsumedCoins = c.ConsumedCoins, // 净盈亏口径下进度可能回退为负，显示负数（已取消0封底）
                            GrantedCoins = c.GrantedCoins,
                            LimitCoins = c.KillRatio,
                            Status = c.Status,
                            CreatedBy = c.CreatedBy,
                            CreatedTime = c.CreatedTime.ToString("yyyy-MM-dd HH:mm:ss")
                        })
                        .ToList();
                    result = rows;

                    // 控牌模式(mode=6)：联查 usercontrolvalue 回显次数/总次数（与 GetTotalControlStatus 一致）
                    // 按 usercontrolstatus.GameId(=cardAction) 精确关联该游戏的行，避免取到其他游戏行导致次数错乱
                    var cardUserIds = rows.Where(c => c.ControlMode == (int)EControlMode.TotalCard).Select(c => c.UserID).Distinct().ToList();
                    if (cardUserIds.Count > 0)
                    {
                        var inClause = string.Join(",", cardUserIds.Select(s => "'" + s.Replace("'", "''") + "'"));
                        var cardRows = ef.Database.SqlQuery<M_UserControlValueRow>(
                            "SELECT ID AS ID, USERID AS UserID, CONTROL_TYPE AS CtrlType, CONTROL_VALUE AS CtrlValue, NUMBER AS Number, TOTAL_NUMBER AS TotalNumber FROM usercontrolvalue WHERE CONTROL_TYPE>=5 AND CONTROL_TYPE<=24 AND NUMBER>0 AND USERID IN (" + inClause + ")").ToList();
                        foreach (var cr in rows.Where(c => c.ControlMode == (int)EControlMode.TotalCard))
                        {
                            // 按该总控记录存的 cardAction(GameId) 精确匹配对应游戏行
                            var userCards = cardRows.Where(r => r.UserID == cr.UserID && (cr.GameId <= 0 || r.CtrlType == cr.GameId)).OrderByDescending(r => r.ID).ToList();
                            if (userCards.Count > 0)
                            {
                                var uc = userCards.First();
                                cr.CardNumber = uc.Number;
                                cr.CardTotal = uc.TotalNumber;
                            }
                        }
                        // 过滤掉控牌次数已消耗完的记录（服务器已回写 NUMBER=0，Status 尚未更新为 Completed）
                        result = result.Where(r => !(r.ControlMode == (int)EControlMode.TotalCard && r.CardNumber == 0)).ToList();
                    }
                    // 展示口径：每个玩家只留一条——控牌没完成只显示控牌；控牌结束后才显示未完成的吃分/放水
                    // （必须放在 if 块外，没有控牌记录的玩家也要收敛吃分/放水两条为一条）
                    result = TotalControlRules.PickDisplayControls(result);
                }
                msg.code = 1;
                msg.content = "";
                msg.datas = result;
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(B_UserControl), ex);
            }
            return msg;
        }

        /// <summary>
        /// 手动关闭玩家某一模式的总控（并下发解除指令，恢复桌台参数难度）
        /// </summary>
        public Msg CloseTotalControl(M_LoginUser loginUser, string userId, int mode, bool mobileRequest = false)
        {
            return CloseTotalControl(loginUser, userId, mode, mobileRequest, 0);
        }

        /// <summary>送奖明细移除时校验原记录，避免旧列表误关闭同玩家后来设置的控制。</summary>
        public Msg CloseTotalControl(M_LoginUser loginUser, string userId, int mode, bool mobileRequest, int expectedControlId)
        {
            Msg msg = new Msg(0, "关闭失败！");
            if (loginUser == null)
            {
                msg.content = "登录信息失效，请重新登录！";
                return msg;
            }
            if (!IsTotalMode(mode))
            {
                msg.content = "无效的总控模式！";
                return msg;
            }
            if (!CanUseTotalMode(loginUser, mode))
            {
                msg.content = "无权限操作！";
                return msg;
            }
            if (string.IsNullOrWhiteSpace(userId))
            {
                msg.content = "请填写玩家账号！";
                return msg;
            }
            string target = userId.Trim();
            try
            {
                using (var ef = new GameDbContext())
                using (var transaction = ef.Database.BeginTransaction())
                {
                    ef.Database.SqlQuery<string>("SELECT ID FROM users WHERE ID={0} FOR UPDATE", target).ToList();
                    if (loginUser.UserPriv > 0)
                    {
                        var user = ef.Users.FirstOrDefault(u => u.ID == target);
                        if (user == null || !new B_Admin().CanManagePlayer(ef, loginUser, user.AGENCY))
                        {
                            msg.content = "只能关闭自己管理范围内玩家的控制！";
                            return msg;
                        }
                    }
                    var olds = ef.UserControlStatuses
                        .Where(c => c.UserID == target && c.GameType == GAMETYPE_TOTAL && c.ControlMode == mode && c.Status == (int)EControlStatus.Active)
                        .ToList();
                    if (expectedControlId != 0 && (expectedControlId < 0 || olds.Count != 1 ||
                        olds[0].ID != expectedControlId || olds[0].CreatedBy != loginUser.Accounts ||
                        ef.Database.SqlQuery<int>("SELECT COUNT(*) FROM agentprizecontrol WHERE ControlId={0} AND AwardTime IS NOT NULL", expectedControlId).Single() != 0))
                    {
                        msg.content = "该送奖记录已变化，请刷新后重试！";
                        return msg;
                    }
                    if (olds.Count < 1)
                    {
                        msg.content = "该玩家没有执行中的" + ModeName(mode) + "！";
                        return msg;
                    }
                    foreach (var old in olds)
                    {
                        old.Status = (int)EControlStatus.Expired;
                        old.ExpiredTime = DateTime.Now;
                    }
                    ef.SaveChanges();
                    if (mode == (int)EControlMode.TotalCard)
                    {
                        foreach (var old in olds)
                        {
                            ef.Database.ExecuteSqlCommand(
                                "DELETE FROM usercontrolvalue WHERE USERID={0} AND CONTROL_TYPE={1}", target, old.GameId);
                        }
                    }
                    transaction.Commit();
                }

                // 强度/控牌类型 0 表示解除。电脑端/手机端都直发：手机端只入发件箱排队的旧逻辑
                // 要等定时重试（间隔 60s）才下发，控制会"点了半天不生效"；失败由发件箱+重试服务兜底。
                Msg serverMsg = SendTotalUcCommand(mode, 0, 0, 0, 0, 0, loginUser, target);
                msg.code = 1;
                msg.content = serverMsg != null && serverMsg.code == 1 ? "移除成功" : "已移除，等待游戏同步";
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(B_UserControl), ex);
            }
            return msg;
        }

        /// <summary>
        /// 总控 UC 指令：
        /// 总点杀 UC30 + 强度(2位) + set(1位) + 玩家账号（强度 00 表示解除）
        /// 总放水 UC31 + 强度(2位) + set(1位) + 玩家账号（强度 00 表示解除）
        /// 总控牌 UC32 + 控牌类型(2位) + 控牌值(2位) + 数量(2位) + 总把数(2位) + set(1位) + 玩家账号（类型 00 表示解除）
        /// </summary>
        /// <summary>
        /// 把刚写入的点杀记录标记上执行操作的代理员账号（记录由游戏服务器写入，不含操作人）
        /// </summary>
        private void MarkManagerOptOperator(string userId, string operatorName)
        {
            try
            {
                using (var ef = new GameDbContext())
                {
                    ef.Database.ExecuteSqlCommand(
                        "UPDATE manageropt SET OPERATOR = {0} WHERE UserID = {1} AND (OPERATOR IS NULL OR OPERATOR = '') AND TIME >= NOW() - INTERVAL 1 MINUTE",
                        operatorName, userId);
                }
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(B_UserControl), ex);
            }
        }

        private Msg SendTotalUcCommand(int mode, int strength, int cardAction, int cardValue, int cardNumber, int cardTotal,
            M_LoginUser loginUser, string userId)
        {
            try
            {
                object[] args = BuildTotalUcCommandArgs(mode, strength, cardAction, cardValue, cardNumber, cardTotal, loginUser, userId);
                return args == null ? new Msg(0, "无效的总控模式！") : new GameCommandService().SetUserControl(args);
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(B_UserControl), ex);
                return new Msg(0, "服务器指令发送异常：" + ex.Message);
            }
        }

        private static object[] BuildTotalUcCommandArgs(int mode, int strength, int cardAction, int cardValue, int cardNumber, int cardTotal,
            M_LoginUser loginUser, string userId)
        {
            int set = (loginUser != null && loginUser.UserName == ConfigHelper.Get("admin")) ? 1 : 0;
            switch (mode)
            {
                case (int)EControlMode.TotalKill:
                    return new object[] { "30", strength.ToString().PadLeft(2, '0'), set, userId };
                case (int)EControlMode.TotalRelease:
                    return new object[] { "31", strength.ToString().PadLeft(2, '0'), set, userId };
                case (int)EControlMode.TotalCard:
                    return new object[]
                    {
                        "32",
                        cardAction.ToString().PadLeft(2, '0'),
                        cardValue.ToString().PadLeft(2, '0'),
                        cardNumber.ToString().PadLeft(2, '0'),
                        cardTotal.ToString().PadLeft(2, '0'),
                        set,
                        userId
                    };
            }
            return null;
        }
    }

    /// <summary>
    /// usercontrolvalue 表查询映射（仅用于总控牌状态回显次数/总次数）
    /// </summary>
    public class M_UserControlValueRow
    {
        public long ID { get; set; }
        public string UserID { get; set; }
        public int CtrlType { get; set; }
        public int CtrlValue { get; set; }
        public int Number { get; set; }
        public int TotalNumber { get; set; }
    }
}
