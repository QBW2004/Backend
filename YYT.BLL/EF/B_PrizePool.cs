using System;
using System.Data;
using System.Linq;
using YYT.Common;
using YYT.Entity;

namespace YYT.BLL.EF
{
    /// <summary>代理送奖资金。余额、流水、操作员钱包在同一数据库事务内变更。</summary>
    public class B_PrizePool
    {
        public class Wallet
        {
            public decimal Balance { get; set; }
            public long Diamonds { get; set; }
        }

        public class CardQuote
        {
            public int GameId { get; set; }
            public int TableId { get; set; }
            public decimal BetDiamonds { get; set; }
            public decimal Multiplier { get; set; }
            public decimal RequiredDiamonds { get; set; }
            public bool Estimated { get; set; }
            /// <summary>玩家当前不在所选游戏或尚未押注：只能等开奖时按实际押注×倍率扣奖池。</summary>
            public bool NoBet { get; set; }
            public int? LiveTableId { get; set; }
        }

        /// <summary>
        /// 送奖报价：牌型倍率 × 玩家当前押注。
        /// 2026-11-03 起不再要求玩家已在所选游戏押注才能送奖（取消“请让玩家进入所选游戏并完成押注”拦截）：
        /// 拿不到实时押注时返回 NoBet 报价（押注/金额为 0），实际扣款以开奖事件为准；
        /// 奖池不足时开奖扣至 0 为止，不出现负数（见 agentprize_record_award）。
        /// </summary>
        public static CardQuote QuoteCard(string target, int action, int value, int count)
        {
            var choice = CardPrizeQuoteRules.Find(action, value);
            if (choice == null) throw new InvalidOperationException("无效的送奖牌型！");
            var online = new YYT.BLL.Services.GameServer.PipeGameServerClient().QueryAllOnlinePlayers();
            var live = online == null ? null : online.FirstOrDefault(p => p.ID == target);
            decimal bet = 0;
            if (live != null && live.Status == 0 && live.GameID == choice.GameId && live.CurBetUnitsPerCoin.HasValue && live.CurBetUnitsPerCoin.Value != 0)
                bet = live.CurBetDiamonds ?? (decimal)live.CurBet / live.CurBetUnitsPerCoin.Value;
            if (bet <= 0)
                return new CardQuote { GameId = choice.GameId, TableId = 0, Multiplier = choice.Multiplier, Estimated = true, NoBet = true,
                    LiveTableId = live != null && live.Status == 0 && live.GameID == choice.GameId ? (int?)live.TableId : null };
            return new CardQuote { GameId = live.GameID, TableId = live.TableId, LiveTableId = live.TableId, BetDiamonds = bet, Multiplier = choice.Multiplier,
                RequiredDiamonds = checked(bet * choice.Multiplier * count), Estimated = choice.Estimated };
        }

        public class ControlRecord
        {
            public int ID { get; set; }
            public string UserID { get; set; }
            public int ControlMode { get; set; }
            public int CardAction { get; set; }
            public int CardValue { get; set; }
            public int Status { get; set; }
            public int GameId { get; set; }
            public string GameName { get; set; }
            public long? TableId { get; set; }
            public string ActualCardType { get; set; }
            public decimal? AwardDiamonds { get; set; }
            public DateTime? AwardTime { get; set; }
            public DateTime CreatedTime { get; set; }
        }

        public class LedgerRecord
        {
            public long ID { get; set; }
            public int Kind { get; set; }
            public decimal BalanceAfter { get; set; }
            public decimal ChangeDiamonds { get; set; }
            public string UserID { get; set; }
            public int GameId { get; set; }
            public string GameName { get; set; }
            public string CardType { get; set; }
            public DateTime RecTime { get; set; }
        }

        public class LedgerSummary
        {
            public decimal Recharge { get; set; }
            public decimal Withdrawal { get; set; }
            public decimal Sent { get; set; }
        }

        public static decimal ReadBalance(GameDbContext ef, string agent)
        {
            return ef.Database.SqlQuery<decimal>("SELECT IFNULL((SELECT Balance FROM agentprizepool WHERE AgentID={0}),0)", agent).Single();
        }

        /// <summary>奖池明细保留天数（2026-11-03 需求：只留 35 天，其余记录的清理口径不变）。</summary>
        public const int LedgerKeepDays = 35;
        private static readonly object sLedgerCleanLock = new object();
        private static DateTime sLedgerCleanedAt = DateTime.MinValue;

        /// <summary>
        /// 清理 35 天前的奖池明细，每小时最多一次，随奖池明细查询触发（不依赖 MySQL event_scheduler 是否开启）。
        /// 只删流水不动余额；仍在执行中的放水（其创建时间之后的控牌支出参与重叠返还计算）相关玩家的流水暂不删。
        /// 分批删除，避免一次锁表过久；失败只记日志，不影响查询。
        /// </summary>
        public static void CleanupLedger(GameDbContext ef)
        {
            lock (sLedgerCleanLock)
            {
                if ((DateTime.Now - sLedgerCleanedAt).TotalHours < 1) return;
                sLedgerCleanedAt = DateTime.Now;
            }
            try
            {
                DateTime cutoff = DateTime.Now.Date.AddDays(-LedgerKeepDays);
                for (int i = 0; i < 20; i++)
                {
                    int n = ef.Database.ExecuteSqlCommand(
                        "DELETE FROM agentprizeledger WHERE RecTime<{0} AND NOT EXISTS(SELECT 1 FROM usercontrolstatus c " +
                        "WHERE c.UserID=agentprizeledger.UserID AND c.GameType=9 AND c.ControlMode=5 AND c.Status=0 AND c.CreatedTime<=agentprizeledger.RecTime) LIMIT 5000", cutoff);
                    if (n < 5000) break;
                }
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(B_PrizePool), ex);
            }
        }

        public object GetLedger(M_LoginUser user, string agent, string kind, string player, M_Page page, DateTime start, DateTime end)
        {
            if (user == null) throw new InvalidOperationException("登录信息失效！");
            using (var ef = new GameDbContext())
            {
                CleanupLedger(ef);
                string account = string.IsNullOrWhiteSpace(agent) ? user.Accounts : agent.Trim();
                // 查看下级代理的奖池明细仅限总台/特级代理；其余代理只能看自己的（侧栏“奖池记录”）
                if (!string.Equals(account, user.Accounts, StringComparison.OrdinalIgnoreCase) &&
                    ((user.UserPriv ?? -1) > AgencyRules.TopAgentPriv || (user.UserPriv ?? -1) < 0 || !new B_Admin().CanManageAgent(ef, user, account, true)))
                    throw new InvalidOperationException("无权查看该代理奖池！");
                // 放水每手都会写一条进度流水，金额为 0 的不展示（余额没有变化）
                string where = " FROM agentprizeledger l WHERE l.AgentID={0} AND l.RecTime>={1} AND l.RecTime<{2} AND l.ChangeDiamonds<>0";
                if (kind == "player") where += " AND l.Kind IN(3,4,5)";
                else if (kind == "recharge") where += " AND l.Kind=1";
                else if (kind == "withdraw") where += " AND l.Kind=2";
                if (!string.IsNullOrWhiteSpace(player)) where += " AND l.UserID={3}";
                object[] args = { account, start, end, player ?? "" };
                int total = ef.Database.SqlQuery<int>("SELECT COUNT(*)" + where, args).Single();
                var summary = ef.Database.SqlQuery<LedgerSummary>("SELECT IFNULL(SUM(CASE WHEN l.Kind=1 THEN l.ChangeDiamonds ELSE 0 END),0) Recharge," +
                    "IFNULL(SUM(CASE WHEN l.Kind=2 THEN l.ChangeDiamonds ELSE 0 END),0) Withdrawal," +
                    "IFNULL(SUM(CASE WHEN l.Kind IN(3,4,5) THEN -l.ChangeDiamonds ELSE 0 END),0) Sent" + where, args).Single();
                var rows = ef.Database.SqlQuery<LedgerRecord>("SELECT l.ID,l.Kind,l.BalanceAfter,l.ChangeDiamonds,l.UserID,l.RecTime,l.GameId,l.CardType," +
                    "(SELECT Name FROM games WHERE GameId=l.GameId LIMIT 1) GameName" + where +
                    " ORDER BY l.ID DESC LIMIT " + page.PageSize + " OFFSET " + ((page.PageIndex - 1) * page.PageSize), args).ToList();
                foreach (var row in rows) row.GameName = GameDisplayNames.GetName(row.GameId, row.GameName);
                return new { total = total, rows = rows, summary = summary, balance = ReadBalance(ef, account) };
            }
        }

        private static void CheckPermission(M_LoginUser user)
        {
            if (user == null || (user.UserPriv != 0 && user.IsRelease != 1 && user.IsProbability != 1 && user.IsKill != 1))
                throw new InvalidOperationException("没有送奖管理权限！");
        }

        public Msg GetWallet(M_LoginUser user)
        {
            CheckPermission(user);
            using (var ef = new GameDbContext())
            {
                var wallet = ef.Database.SqlQuery<Wallet>(
                    "SELECT IFNULL(p.Balance,0) Balance,IFNULL(a.COINS,0) Diamonds FROM admin a LEFT JOIN agentprizepool p ON p.AgentID=a.ID WHERE a.ID={0}",
                    user.Accounts).SingleOrDefault();
                return wallet == null ? new Msg(0, "账号不存在！") : new Msg(1, "操作成功") { datas = wallet };
            }
        }

        /// <summary>
        /// 由 ApplyTotalControl 持有事务调用，先锁自己的奖池，防止并发充值/下控绕过余额检查。
        /// 送奖(6)：2026-11-03 起只要求奖池有余额（>0）即可送，送出得分大于余额时开奖扣至 0，不出现负数；
        /// 放水(5)：仍要求余额覆盖目标。
        /// </summary>
        public static void CheckFunding(GameDbContext ef, M_LoginUser user, int mode, long target)
        {
            if (mode != 5 && mode != 6) return;
            ef.Database.ExecuteSqlCommand("INSERT INTO agentprizepool(AgentID,Balance) VALUES({0},0) ON DUPLICATE KEY UPDATE AgentID=VALUES(AgentID)", user.Accounts);
            decimal balance = ef.Database.SqlQuery<decimal>("SELECT Balance FROM agentprizepool WHERE AgentID={0} FOR UPDATE", user.Accounts).Single();
            if (balance <= 0 || (mode == 5 && balance < target))
                throw new InvalidOperationException("奖池余额不足，请充值奖池");
        }

        public static void AttachControl(GameDbContext ef, M_LoginUser user, M_UserControlStatus row, int gameId = 0, int? tableId = null)
        {
            ef.Database.ExecuteSqlCommand("INSERT INTO agentprizecontrol(ControlId,AgentID,UserID,ControlMode,ActualGameId,ActualTableId) VALUES({0},{1},{2},{3},{4},{5})",
                row.ID, user.Accounts, row.UserID, row.ControlMode, gameId, (object)tableId ?? DBNull.Value);
        }

        public Msg Transfer(M_LoginUser user, long amount, string requestId, bool withdraw)
        {
            CheckPermission(user);
            Guid token;
            if (amount <= 0 || !Guid.TryParse(requestId, out token)) return new Msg(0, "请输入有效的整数钻数并刷新后重试！");
            string eventId = "wallet:" + token.ToString("N");
            using (var ef = new GameDbContext())
            using (var tx = ef.Database.BeginTransaction(IsolationLevel.ReadCommitted))
            {
                ef.Database.ExecuteSqlCommand("INSERT INTO agentprizepool(AgentID,Balance) VALUES({0},0) ON DUPLICATE KEY UPDATE AgentID=VALUES(AgentID)", user.Accounts);
                decimal pool = ef.Database.SqlQuery<decimal>("SELECT Balance FROM agentprizepool WHERE AgentID={0} FOR UPDATE", user.Accounts).Single();
                if (ef.Database.SqlQuery<int>("SELECT COUNT(*) FROM agentprizeledger WHERE EventId={0} AND AgentID={1}", eventId, user.Accounts).Single() != 0)
                    return new Msg(1, "此笔操作已完成，请勿重复提交");
                long coins = ef.Database.SqlQuery<long>("SELECT IFNULL(COINS,0) FROM admin WHERE ID={0} FOR UPDATE", user.Accounts).Single();
                if ((!withdraw && coins < amount) || (withdraw && pool < amount)) return new Msg(0, "可用余额不足！");
                long change = withdraw ? -amount : amount;
                if (withdraw && coins > long.MaxValue - amount) return new Msg(0, "钱包余额超过可存储范围！");
                ef.Database.ExecuteSqlCommand("UPDATE admin SET COINS=COINS-{0} WHERE ID={1}", change, user.Accounts);
                ef.Database.ExecuteSqlCommand("UPDATE agentprizepool SET Balance=Balance+{0} WHERE AgentID={1}", change, user.Accounts);
                ef.Database.ExecuteSqlCommand("INSERT INTO agentprizeledger(EventId,AgentID,Kind,ChangeDiamonds,BalanceAfter,RecTime) VALUES({0},{1},{2},{3},{4},NOW(6))",
                    eventId, user.Accounts, withdraw ? 2 : 1, change, pool + change);
                tx.Commit();
                return new Msg(1, withdraw ? "奖池提取成功" : "奖池充值成功");
            }
        }

        /// <summary>控牌指令号(cardAction) → 平台 GameId，与中心服 cardActionToGameId / agentprize_record_award 同口径。</summary>
        public static int CardActionGameId(int action)
        {
            switch (action)
            {
                case 5: return 15; case 7: return 37; case 8: return 25; case 12: return 14; case 13: return 44;
                case 14: return 5; case 15: return 53; case 16: return 16; case 17: return 40; case 19: return 54; case 20: return 55;
            }
            return 0;
        }

        /// <summary>
        /// 送奖记录：本代理下发的全部记录。cardAction&gt;0 时只看该游戏
        /// （控牌按下发的控牌游戏，吃分/放水按实际开奖游戏）——手机端“选游戏+日期→刷新”按此筛选。
        /// </summary>
        public object GetControlRecords(M_LoginUser user, M_Page page, string account, DateTime start, DateTime end, int cardAction = 0)
        {
            CheckPermission(user);
            using (var ef = new GameDbContext())
            {
                // 历史行缺乏开奖事件关联时保持空值，不能按时间相近猜测玩家的自然中奖。
                string where = " FROM usercontrolstatus c LEFT JOIN agentprizecontrol p ON p.ControlId=c.ID WHERE c.GameType=9 AND c.CreatedBy={0} AND COALESCE(p.AwardTime,c.CreatedTime)>={1} AND COALESCE(p.AwardTime,c.CreatedTime)<{2}";
                if (!string.IsNullOrWhiteSpace(account)) where += " AND c.UserID={3}";
                int gameId = CardActionGameId(cardAction);
                if (cardAction > 0) where += " AND ((c.ControlMode=6 AND c.GameId={4}) OR (c.ControlMode<>6 AND p.ActualGameId={5}))";
                object[] args = { user.Accounts, start, end, account ?? "", cardAction, gameId };
                int total = ef.Database.SqlQuery<int>("SELECT COUNT(*)" + where, args).Single();
                decimal sent = ef.Database.SqlQuery<decimal>("SELECT IFNULL(SUM(p.BookedDiamonds),0)" + where, args).Single();
                int skip = (page.PageIndex - 1) * page.PageSize;
                string sql = "SELECT c.ID,c.UserID,c.ControlMode,c.GameId CardAction,c.KillRatio CardValue,c.Status,c.CreatedTime,COALESCE(p.ActualGameId,0) GameId," +
                    "(SELECT Name FROM games WHERE GameId=p.ActualGameId LIMIT 1) GameName,p.ActualTableId TableId,p.ActualCardType,p.AwardTime," +
                    "CASE WHEN p.AwardTime IS NULL THEN NULL ELSE CASE WHEN c.ControlMode=5 THEN p.BookedDiamonds ELSE p.AwardDiamonds END END AwardDiamonds" + where +
                    " ORDER BY c.ID DESC LIMIT " + page.PageSize + " OFFSET " + skip;
                var rows = ef.Database.SqlQuery<ControlRecord>(sql, args).ToList();
                foreach (var row in rows)
                {
                    row.GameName = GameDisplayNames.GetName(row.GameId, row.GameName);
                    // QA/放水与拉霸/麻将开奖用0基下标；牌机开奖已是1基roomTableID。
                    if (row.TableId.HasValue && (!row.AwardTime.HasValue || row.ControlMode != 6 ||
                        row.GameId == 16 || row.GameId == 40 || row.GameId == 53 || row.GameId == 54)) row.TableId++;
                }
                return new { total = total, rows = rows, sentDiamonds = sent };
            }
        }
    }
}
