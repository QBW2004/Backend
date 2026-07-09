using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace YYT.Entity
{
    public enum ERePortType : ushort
    {
        /// <summary>
        /// 充值报表
        /// </summary>
        RechargeReport = 1,
        /// <summary>
        /// 收益报表
        /// </summary>
        EarningsReport = 2,
        /// <summary>
        /// 人员报表
        /// </summary>
        UserReport = 3,
    }

    public class M_Reports
    {
        public ERePortType ReportType { get; set; }
        public string Title { get; set; }
        public long? Val { get; set; }
    }
    public class M_SumCoins
    {
        public long? SumCOINS { get; set; }
        public long? SumCOINS_BUY { get; set; }
        public long? SumCOINS_BACK { get; set; }
    }
    public class M_SumAgencies
    {
        public int PRIV { get; set; }
        public int Count { get; set; }
    }
    public class M_SumOrders
    {
        public int Processed { get; set; }
        public int Count { get; set; }
    }
    public class M_UserProit
    {
        public string User { get; set; }
        public long? Profit { get; set; }
    }
    public class M_AgencyProfit
    {
        public string Agency { get; set; }
        public long? Profit { get; set; }

        public long? PlayerBalance { get; set; }

        public long? UserBalance { get; set; }
    }
}
