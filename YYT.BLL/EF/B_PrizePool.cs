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

        public class ControlRecord
        {
            public int ID { get; set; }
            public string UserID { get; set; }
            public int ControlMode { get; set; }
            public int CardAction { get; set; }
            public int CardValue { get; set; }
            public int Status { get; set; }
            public string GameName { get; set; }
            public long? TableId { get; set; }
            public string ActualCardType { get; set; }
            public decimal? AwardDiamonds { get; set; }
            public DateTime? AwardTime { get; set; }
            public DateTime CreatedTime { get; set; }
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

        /// <summary>由 ApplyTotalControl 持有事务调用，先锁自己的奖池，防止并发充值/下控绕过余额检查。</summary>
        public static void CheckFunding(GameDbContext ef, M_LoginUser user, int mode, long target)
        {
            if (mode != 5 && mode != 6) return;
            ef.Database.ExecuteSqlCommand("INSERT INTO agentprizepool(AgentID,Balance) VALUES({0},0) ON DUPLICATE KEY UPDATE AgentID=VALUES(AgentID)", user.Accounts);
            decimal balance = ef.Database.SqlQuery<decimal>("SELECT Balance FROM agentprizepool WHERE AgentID={0} FOR UPDATE", user.Accounts).Single();
            if (balance <= 0 || (mode == 5 && balance < target))
                throw new InvalidOperationException(mode == 5 ? "奖池余额不足以支付放水目标，请先充值奖池！" : "奖池余额不足，请先充值奖池！");
        }

        public static void AttachControl(GameDbContext ef, M_LoginUser user, M_UserControlStatus row)
        {
            ef.Database.ExecuteSqlCommand("INSERT INTO agentprizecontrol(ControlId,AgentID,UserID,ControlMode) VALUES({0},{1},{2},{3})",
                row.ID, user.Accounts, row.UserID, row.ControlMode);
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
                if (withdraw && ef.Database.SqlQuery<int>("SELECT COUNT(*) FROM agentprizecontrol p JOIN usercontrolstatus c ON c.ID=p.ControlId WHERE p.AgentID={0} AND c.Status=0 AND c.ControlMode IN (5,6)", user.Accounts).Single() > 0)
                    return new Msg(0, "请先结束执行中的送奖控制，再提取奖池！");
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

        public object GetControlRecords(M_LoginUser user, M_Page page, string account, DateTime start, DateTime end)
        {
            CheckPermission(user);
            using (var ef = new GameDbContext())
            {
                // 历史行缺乏开奖事件关联时保持空值，不能按时间相近猜测玩家的自然中奖。
                string where = " FROM usercontrolstatus c LEFT JOIN agentprizecontrol p ON p.ControlId=c.ID WHERE c.GameType=9 AND c.CreatedBy={0} AND COALESCE(p.AwardTime,c.CreatedTime)>={1} AND COALESCE(p.AwardTime,c.CreatedTime)<{2}";
                if (!string.IsNullOrWhiteSpace(account)) where += " AND c.UserID={3}";
                object[] args = { user.Accounts, start, end, account ?? "" };
                int total = ef.Database.SqlQuery<int>("SELECT COUNT(*)" + where, args).Single();
                decimal sent = ef.Database.SqlQuery<decimal>("SELECT IFNULL(SUM(p.BookedDiamonds),0)" + where, args).Single();
                int skip = (page.PageIndex - 1) * page.PageSize;
                string sql = "SELECT c.ID,c.UserID,c.ControlMode,c.GameId CardAction,c.KillRatio CardValue,c.Status,c.CreatedTime," +
                    "(SELECT Name FROM games WHERE GameId=p.ActualGameId LIMIT 1) GameName,p.ActualTableId TableId,p.ActualCardType,p.AwardTime," +
                    "CASE WHEN p.AwardTime IS NULL THEN NULL ELSE CASE WHEN c.ControlMode=5 THEN p.BookedDiamonds ELSE p.AwardDiamonds END END AwardDiamonds" + where +
                    " ORDER BY c.ID DESC LIMIT " + page.PageSize + " OFFSET " + skip;
                var rows = ef.Database.SqlQuery<ControlRecord>(sql, args).ToList();
                return new { total = total, rows = rows, sentDiamonds = sent };
            }
        }
    }
}
