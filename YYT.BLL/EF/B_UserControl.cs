using System;
using System.Collections.Generic;
using System.Linq;
using YYT.BLL.Services.GameServer;
using YYT.Common;
using YYT.Entity;

namespace YYT.BLL.EF
{
    /// <summary>
    /// 鱼机和玩家控制（点杀/放水/金币上限）状态机
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
        /// UC 扩展指令码：05=点杀目标金额 06=放水目标金额 07=金币上限（金额=0 表示取消该项控制）
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

            // 权限校验：点杀需 IsKill，放水/金币上限需 IsProbability；机台范围仅超级管理员
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
                        if (loginUser.UserPriv > 0 && !new B_Admin().IsInAgencyLine(ef, loginUser.Accounts, user.AGENCY))
                        {
                            msg.content = "只能控制自己代理线内的玩家！";
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
                        if (user == null || !new B_Admin().IsInAgencyLine(ef, loginUser.Accounts, user.AGENCY))
                        {
                            msg.content = "只能关闭自己代理线内玩家的控制！";
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
        /// 分页查询控制记录（代理只能看到机台范围记录与自己代理线内玩家的记录）
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

                    if (loginUser.UserPriv > 0)
                    {
                        var agencies = new B_Admin().GetAgencyLineAccounts(ef, loginUser.Accounts);
                        rst = rst.Where(c => c.UserID == MACHINE_TARGET || agencies.Contains(c.AGENCY));
                    }
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
                            ConsumedCoins = c.ConsumedCoins,
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
                case (int)EControlMode.Limit: return "金币上限";
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

        /// <summary>
        /// 设置总控：总点杀(4)=鱼机+押注+牌机+拉霸；总放水(5)=鱼机+押注；总控牌(6)=牌机+拉霸。
        /// 累计吃分/放分达到金币阈值(goldThreshold)后自动失效，恢复桌台参数难度。
        /// 总控牌时 cardAction/cardValue/cardNumber/cardTotal 为精确控牌参数（与牌机控牌一致）。
        /// </summary>
        public Msg ApplyTotalControl(M_LoginUser loginUser, string userId, int mode, int strength, long goldThreshold,
            int cardAction, int cardValue, int cardNumber, int cardTotal)
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
            if (goldThreshold <= 0)
            {
                msg.content = "金币阈值必须大于 0！";
                return msg;
            }
            if (mode == (int)EControlMode.TotalCard)
            {
                if (cardAction < 5 || cardAction > 17)
                {
                    msg.content = "无效的控牌类型！";
                    return msg;
                }
                if (cardNumber < 1 || cardTotal < 5 || cardTotal > 50 || cardNumber > cardTotal)
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

            string target = userId.Trim();
            try
            {
                using (var ef = new GameDbContext())
                {
                    var user = ef.Users.FirstOrDefault(u => u.ID == target);
                    if (user == null)
                    {
                        msg.content = "此账号玩家不存在！";
                        return msg;
                    }
                    if (loginUser.UserPriv > 0 && !new B_Admin().IsInAgencyLine(ef, loginUser.Accounts, user.AGENCY))
                    {
                        msg.content = "只能控制自己代理线内的玩家！";
                        return msg;
                    }

                    // 总控互斥：同一玩家同时只允许一个总控，旧执行中总控记录（任意模式）全部置为过期
                    var olds = ef.UserControlStatuses
                        .Where(c => c.UserID == target && c.GameType == GAMETYPE_TOTAL && c.Status == (int)EControlStatus.Active)
                        .ToList();
                    foreach (var old in olds)
                    {
                        old.Status = (int)EControlStatus.Expired;
                        old.ExpiredTime = DateTime.Now;
                    }

                    var row = new M_UserControlStatus
                    {
                        UserID = target,
                        GameType = GAMETYPE_TOTAL,
                        GameId = 0,
                        ControlMode = mode,
                        TargetCoins = goldThreshold,
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

                    // 点杀记录由后台写入（含操作员），服务器侧不再记录，避免指令重发产生重复记录
                    int optCode = mode == (int)EControlMode.TotalKill ? 21 : (mode == (int)EControlMode.TotalRelease ? 22 : 23);
                    int optValue = mode == (int)EControlMode.TotalCard ? cardValue : strength;
                    ef.Database.ExecuteSqlCommand(
                        "INSERT INTO manageropt(UserID,NAME,Opt,OptValue,Type,OPERATOR) VALUES({0},{1},{2},{3},'UC',{4})",
                        target, user.NAME ?? "", optCode, optValue, loginUser.Accounts);
                }
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(B_UserControl), ex);
                msg.content = "数据库写入失败！";
                return msg;
            }

            // 下发服务器指令（DB 已落库，玩家下次进游戏时服务端也会按 DB 应用总控）
            Msg tmpMsg = SendTotalUcCommand(mode, strength, cardAction, cardValue, cardNumber, cardTotal, loginUser, target);
            msg.code = 1;
            msg.content = (tmpMsg != null && tmpMsg.code == 1)
                ? ModeName(mode) + "已生效！"
                : ModeName(mode) + "已保存（玩家进入游戏后生效）";
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
                    if (loginUser.UserPriv > 0)
                    {
                        var user = ef.Users.FirstOrDefault(u => u.ID == target);
                        if (user == null || !new B_Admin().IsInAgencyLine(ef, loginUser.Accounts, user.AGENCY))
                        {
                            msg.content = "只能查询自己代理线内的玩家！";
                            return msg;
                        }
                    }
                    var rows = ef.UserControlStatuses
                        .Where(c => c.UserID == target && c.GameType == GAMETYPE_TOTAL && c.Status == (int)EControlStatus.Active)
                        .OrderByDescending(c => c.ID)
                        .ToList()
                        .GroupBy(c => c.ControlMode)
                        .Select(g => g.First())
                        .Select(c => new M_UserControlStatus_DTO
                        {
                            ID = c.ID,
                            UserID = c.UserID,
                            GameType = c.GameType,
                            GameId = c.GameId,
                            ControlMode = c.ControlMode,
                            TargetCoins = c.TargetCoins,
                            ConsumedCoins = c.ConsumedCoins,
                            GrantedCoins = c.GrantedCoins,
                            LimitCoins = c.KillRatio, // 强度/控牌值借用 LimitCoins 字段回显
                            Status = c.Status,
                            CreatedBy = c.CreatedBy,
                            CreatedTime = c.CreatedTime.ToString("yyyy-MM-dd HH:mm:ss")
                        })
                        .ToList();
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
                    var rows = ef.UserControlStatuses
                        .Where(c => c.GameType == GAMETYPE_TOTAL && c.Status == (int)EControlStatus.Active && ids.Contains(c.UserID))
                        .OrderByDescending(c => c.ID)
                        .ToList()
                        .GroupBy(c => c.UserID + "_" + c.ControlMode)
                        .Select(g => g.First())
                        .Select(c => new M_UserControlStatus_DTO
                        {
                            ID = c.ID,
                            UserID = c.UserID,
                            GameType = c.GameType,
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
                    result = rows;
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
        public Msg CloseTotalControl(M_LoginUser loginUser, string userId, int mode)
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
                    if (loginUser.UserPriv > 0)
                    {
                        var user = ef.Users.FirstOrDefault(u => u.ID == target);
                        if (user == null || !new B_Admin().IsInAgencyLine(ef, loginUser.Accounts, user.AGENCY))
                        {
                            msg.content = "只能关闭自己代理线内玩家的控制！";
                            return msg;
                        }
                    }
                    var olds = ef.UserControlStatuses
                        .Where(c => c.UserID == target && c.GameType == GAMETYPE_TOTAL && c.ControlMode == mode && c.Status == (int)EControlStatus.Active)
                        .ToList();
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
                }

                // 强度/控牌类型 0 表示解除
                Msg tmpMsg = SendTotalUcCommand(mode, 0, 0, 0, 0, 0, loginUser, target);
                msg.code = 1;
                msg.content = (tmpMsg != null && tmpMsg.code == 1)
                    ? ModeName(mode) + "已关闭！"
                    : ModeName(mode) + "已关闭（服务器指令未确认，玩家重新进游戏后恢复桌台参数）";
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
                int set = (loginUser != null && loginUser.UserName == ConfigHelper.Get("admin")) ? 1 : 0;
                var svc = new GameCommandService();
                switch (mode)
                {
                    case (int)EControlMode.TotalKill:
                        return svc.SetUserControl("30", strength.ToString().PadLeft(2, '0'), set, userId);
                    case (int)EControlMode.TotalRelease:
                        return svc.SetUserControl("31", strength.ToString().PadLeft(2, '0'), set, userId);
                    case (int)EControlMode.TotalCard:
                        return svc.SetUserControl("32",
                            cardAction.ToString().PadLeft(2, '0'),
                            cardValue.ToString().PadLeft(2, '0'),
                            cardNumber.ToString().PadLeft(2, '0'),
                            cardTotal.ToString().PadLeft(2, '0'),
                            set, userId);
                }
                return new Msg(0, "无效的总控模式！");
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(B_UserControl), ex);
                return new Msg(0, "服务器指令发送异常：" + ex.Message);
            }
        }
    }
}
