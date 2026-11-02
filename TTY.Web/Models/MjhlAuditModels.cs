using System;
using System.Collections.Generic;
using System.Globalization;

namespace YYT.Web.Models
{
    /// <summary>麻将审计只读范围；历史记录只使用开局时的代理线快照。</summary>
    public sealed class MjhlAuditScope
    {
        public bool CanSelectLine { get; set; }
        public bool AllLines { get; set; }
        public string LineAgent { get; set; }

        /// <summary>特级代理仍只能看自身线，断链账号不能回退到公共数据。</summary>
        public static MjhlAuditScope Resolve(int? privilege, string ownLine, string requestedLine, bool allLines)
        {
            string requested = (requestedLine ?? string.Empty).Trim();
            if (privilege == 0)
                return new MjhlAuditScope { CanSelectLine = true, AllLines = allLines, LineAgent = allLines ? null : requested };
            if (!privilege.HasValue || privilege.Value < 1 || string.IsNullOrWhiteSpace(ownLine) || ownLine == "#")
                throw new UnauthorizedAccessException("当前账号没有有效代理线，无法查看麻将账本。");
            if (allLines || (requested.Length > 0 && !string.Equals(requested, ownLine, StringComparison.OrdinalIgnoreCase)))
                throw new UnauthorizedAccessException("只能查看当前账号所属代理线。");
            return new MjhlAuditScope { CanSelectLine = false, AllLines = false, LineAgent = ownLine };
        }
    }

    /// <summary>数据库聚合保留整数 tick；跨兑换比例只相加换算后的钻。</summary>
    public sealed class MjhlAuditAggregate
    {
        public string LineAgent { get; set; }
        public long ScorePerCoin { get; set; }
        public long RoundCount { get; set; }
        public decimal BetTicks { get; set; }
        public decimal NormalWinTicks { get; set; }
        public decimal FreeWinTicks { get; set; }
        public decimal PaidWinTicks { get; set; }
        public decimal OutstandingTicks { get; set; }
        public decimal RoundingTicks { get; set; }
        public decimal FreeTotal { get; set; }
        public decimal FreeConsumed { get; set; }
    }

    /// <summary>金额以文本输出，避免浏览器 Number 丢失大整数 tick。</summary>
    public sealed class MjhlAuditAmounts
    {
        public string Bet { get; set; }
        public string NormalWin { get; set; }
        public string FreeWin { get; set; }
        public string PaidWin { get; set; }
        public string Outstanding { get; set; }
        public string CommittedProfit { get; set; }
        public string PaidProfit { get; set; }
        public string Rounding { get; set; }
        public string Rtp { get; set; }
    }

    public sealed class MjhlAuditGroup
    {
        public string LineAgent { get; set; }
        public long ScorePerCoin { get; set; }
        public long RoundCount { get; set; }
        public string FreeTotal { get; set; }
        public string FreeConsumed { get; set; }
        public MjhlAuditAmounts Raw { get; set; }
        public MjhlAuditAmounts Coins { get; set; }
    }

    public sealed class MjhlAuditRound
    {
        public string RoundId { get; set; }
        public string UserId { get; set; }
        public string LineAgent { get; set; }
        public int TableId { get; set; }
        public long ScorePerCoin { get; set; }
        public DateTime StartedAt { get; set; }
        public string RuleVersion { get; set; }
        public string ConfigHash { get; set; }
        public long BetTicks { get; set; }
        public long NormalWinTicks { get; set; }
        public long FreeWinTicks { get; set; }
        public long PaidWinTicks { get; set; }
        public int FreeTotal { get; set; }
        public int FreeConsumed { get; set; }
        public string Status { get; set; }
    }

    public sealed class MjhlAuditEvent
    {
        public string EventId { get; set; }
        public string RoundId { get; set; }
        public string EventType { get; set; }
        public long AmountTicks { get; set; }
        public long BalanceBeforeTicks { get; set; }
        public long BalanceAfterTicks { get; set; }
        public DateTime CreatedAt { get; set; }
    }

    /// <summary>审计计算和权限均为纯函数，离线验证不依赖正式数据库。</summary>
    public static class MjhlAuditMath
    {
        public const int ScoreScale = 200;

        public static decimal ToCoins(decimal ticks, long scorePerCoin)
        {
            if (scorePerCoin <= 0 || scorePerCoin > uint.MaxValue)
                throw new InvalidOperationException("账本兑换比例无效，不能按默认比例换算。");
            return ticks / ScoreScale / scorePerCoin;
        }

        public static string Number(decimal value)
        {
            return value.ToString("0.00##########", CultureInfo.InvariantCulture);
        }

        public static string Integer(decimal value)
        {
            return value.ToString("0", CultureInfo.InvariantCulture);
        }

        public static MjhlAuditAmounts Amounts(decimal bet, decimal normal, decimal free, decimal paid, decimal outstanding, decimal rounding)
        {
            return new MjhlAuditAmounts
            {
                Bet = Number(bet), NormalWin = Number(normal), FreeWin = Number(free), PaidWin = Number(paid),
                Outstanding = Number(outstanding), CommittedProfit = Number(bet - normal - free),
                PaidProfit = Number(bet - paid), Rounding = Number(rounding),
                Rtp = bet == 0 ? "—" : Number((normal + free) / bet * 100) + "%"
            };
        }

        public static MjhlAuditGroup Group(MjhlAuditAggregate row)
        {
            return new MjhlAuditGroup
            {
                LineAgent = row.LineAgent ?? string.Empty, ScorePerCoin = row.ScorePerCoin, RoundCount = row.RoundCount,
                FreeTotal = Integer(row.FreeTotal), FreeConsumed = Integer(row.FreeConsumed),
                Raw = Amounts(row.BetTicks / ScoreScale, row.NormalWinTicks / ScoreScale, row.FreeWinTicks / ScoreScale,
                    row.PaidWinTicks / ScoreScale, row.OutstandingTicks / ScoreScale, row.RoundingTicks / ScoreScale),
                Coins = Amounts(ToCoins(row.BetTicks, row.ScorePerCoin), ToCoins(row.NormalWinTicks, row.ScorePerCoin),
                    ToCoins(row.FreeWinTicks, row.ScorePerCoin), ToCoins(row.PaidWinTicks, row.ScorePerCoin),
                    ToCoins(row.OutstandingTicks, row.ScorePerCoin), ToCoins(row.RoundingTicks, row.ScorePerCoin))
            };
        }

        public static MjhlAuditAmounts Total(IEnumerable<MjhlAuditAggregate> groups)
        {
            decimal bet = 0, normal = 0, free = 0, paid = 0, outstanding = 0, rounding = 0;
            foreach (MjhlAuditAggregate row in groups)
            {
                bet += ToCoins(row.BetTicks, row.ScorePerCoin);
                normal += ToCoins(row.NormalWinTicks, row.ScorePerCoin);
                free += ToCoins(row.FreeWinTicks, row.ScorePerCoin);
                paid += ToCoins(row.PaidWinTicks, row.ScorePerCoin);
                outstanding += ToCoins(row.OutstandingTicks, row.ScorePerCoin);
                rounding += ToCoins(row.RoundingTicks, row.ScorePerCoin);
            }
            return Amounts(bet, normal, free, paid, outstanding, rounding);
        }
    }
}
