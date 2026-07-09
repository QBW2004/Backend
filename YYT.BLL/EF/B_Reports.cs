using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Diagnostics;
using System.Linq;
using YYT.Common;
using YYT.Entity;

namespace YYT.BLL.EF
{
    public class B_Reports
    {
        /// <summary>
        /// 是否是管理员
        /// </summary>
        private bool IsAdmin { get; set; }
        /// <summary>
        /// 登录用户
        /// </summary>
        private M_LoginUser LoginUser { get; set; }
        /// <summary>
        /// 报表
        /// </summary>
        public List<M_Reports> reportList { get; set; }
        /// <summary>
        /// 报表
        /// </summary>
        /// <param name="loginUser"></param>
        public B_Reports(M_LoginUser loginUser)
        {
            this.LoginUser = loginUser;
            this.reportList = new List<M_Reports>();
            this.IsAdmin = loginUser.UserPriv == 0;
        }


        #region 总报表
        public List<M_Reports> GetReports()
        {
            using (var ef = new GameDbContext())
            {
                try
                {
                    if (this.IsAdmin == true)
                    {
                        // 今日充值额度
                        ReChargeReports(ef);
                    }
                    // 总金币、总充值、总兑换、盈利额度
                    CoinReports(ef);

                    // 统计权限内的代理
                    UserReports(ef);
                }
                catch (Exception ex)
                {
                    LogHelper.WriteLog(typeof(YYT.BLL.EF.B_Reports), ex);
                }
            }
            return this.reportList;
        }
        /// <summary>
        /// 人员统计
        /// </summary>
        /// <param name="ef"></param>
        public void UserReports(GameDbContext ef)
        {
            IQueryable<M_Users> users = ef.Users;
            IQueryable<M_Admin> admins = ef.Admins;
            List<M_Users> listuser = new List<M_Users>();
            List<M_SumAgencies> sumAgencies = new List<M_SumAgencies>();
            int userCount = 0;
            int TotalCount = 0;
            int userCount1 = 0;
            if (this.LoginUser.UserPriv == 0)// 超级管理
            {
                sumAgencies = (from a in ef.Admins
                               where a.PRIV > 0 && a.PRIV < 10
                               group a by a.PRIV into g
                               select new M_SumAgencies { PRIV = g.Key.Value, Count = g.Count() }).ToList();
            }
            else
            {

                sumAgencies = (from a in ef.Admins
                               where a.AGENCY.Equals(this.LoginUser.Accounts)
                               group a by a.PRIV into g
                               select new M_SumAgencies { PRIV = g.Key.Value, Count = g.Count() }).ToList();



                ////查询所有代理
                //var agent = from a in ef.Admins where a.AGENCY.Equals(this.LoginUser.Accounts) select a;

                

                //foreach (var item in agent)
                //{
                //    var agent1 = from a in ef.Admins where a.AGENCY.Equals(item.AGENCY) select a;
                //    foreach (var item1 in agent1)
                //    {
                //        var agent2 = from a in ef.Admins where a.AGENCY.Equals(item1.AGENCY) select a;
                //    }
                //}

                var sss = from u in ef.Users
                          join a in ef.Admins
                          on u.AGENCY equals a.ID
                          where a.AGENCY.Equals(this.LoginUser.Accounts)
                          select u;
                if (sss != null)
                {
                    TotalCount += sss.Count();
                }

                users = users.Where(c => c.AGENCY.Equals(this.LoginUser.Accounts));
                // 统计用户
            }

            // 结果拼装
            if (sumAgencies != null)
            {
                var tmpList = from t in sumAgencies
                              group t by new { title = AdminTypeTranslater.TitleTranlate((EAdminType)t.PRIV) } into g
                              select new M_Reports { ReportType = ERePortType.UserReport, Title = g.Key.title, Val = g.Sum(c => c.Count) };

                foreach (var item in tmpList)
                {

                    this.reportList.Add(new M_Reports { ReportType = ERePortType.UserReport, Title = item.Title, Val = item.Val });
                }
            }
            if (users != null)
                userCount = users.Count();
                TotalCount += userCount;
                userCount1 = users.Where(c => c.INHALL == true).Count();
            if (this.LoginUser.UserPriv != 0)
            {
                this.reportList.Add(new M_Reports { ReportType = ERePortType.UserReport, Title = "总人数", Val = TotalCount });
            }
            this.reportList.Add(new M_Reports { ReportType = ERePortType.UserReport, Title = "用户数", Val = userCount });
            this.reportList.Add(new M_Reports { ReportType = ERePortType.UserReport, Title = "在线用户数", Val = userCount1 });
          
          
        }
        /// <summary>
        /// 充值统计
        /// </summary>
        /// <param name="ef"></param>
        public void ReChargeReports(GameDbContext ef)
        {
            DateTime sTime = DateTime.Parse(DateTime.Now.ToString("yyyy-MM-dd"));
            DateTime eTime = DateTime.Parse(DateTime.Now.ToString("yyyy-MM-dd 23:59:59"));

          
            // 充值订单
            IQueryable<M_ReChargeRecords> records = from r in ef.ReChargeRecords
                                                    where r.RechargeType != 21 // 1微信充值  2支付宝充值  20后台充值  21后台兑换
                                                    select r;
            records = records.Where(p => p.RechargeType != 22);
            records = records.Where(p => p.RechargeType != 31);
            // 今日充值
            long? coins = records.Where(c => c.CreateTime >= sTime && c.CreateTime <= eTime).Sum(c => c.Coin);
            this.reportList.Add(new M_Reports { ReportType = ERePortType.RechargeReport, Title = "今日充值额度", Val = (coins ?? 0) });

            // 处理、未处理订单分类数量统计
            IQueryable<M_SumOrders> orders = null;
            if (LoginUser.UserPriv == 0)
            {
                orders = (from r in records
                          group r by new { processed = r.Processed } into g
                          select new M_SumOrders { Processed = g.Key.processed, Count = g.Count() });
            }
            else
            {
                orders = (from r in records
                          join u in ef.Users on new { ID = r.GameID, Agency = LoginUser.Accounts } equals new { ID = u.ID, Agency = u.AGENCY }
                          group r by new { processed = r.Processed } into g
                          select new M_SumOrders { Processed = g.Key.processed, Count = g.Count() });
            }

            if (orders != null && orders.Count() > 0)
            {
                int totalCount = orders.Sum(a => a.Count);

                var processedRst = orders.Where(c => c.Processed == 1).SingleOrDefault();
                int processedCount = processedRst != null ? processedRst.Count : 0;
                var noProcessedRst = orders.Where(c => c.Processed == 0).SingleOrDefault();
                int noProcessedCount = noProcessedRst != null ? noProcessedRst.Count : 0;

                this.reportList.Add(new M_Reports { ReportType = ERePortType.RechargeReport, Title = "充值兑换订单", Val = totalCount });
                this.reportList.Add(new M_Reports { ReportType = ERePortType.RechargeReport, Title = "已处理订单数", Val = processedCount });
                this.reportList.Add(new M_Reports { ReportType = ERePortType.RechargeReport, Title = "未处理订单数", Val = noProcessedCount });
            }
        }
        /// <summary>
        /// 收益统计
        /// </summary>
        /// <param name="ef"></param>
        public void CoinReports(GameDbContext ef)
        {
            long _sumCoins = 0;
            long _sumCoinsBuy = 0;
            long _sumCoinsBack = 0;
            long _sumGain = 0;

            IQueryable<M_Users> usrs = ef.Users;

            // //统计直属代理
            //IQueryable<M_Admin> agencies = ef.Admins;
            if (LoginUser.UserPriv > 0)
            {
                //    agencies = agencies.Where(c=>c.AGENCY.Equals(LoginUser.Accounts));
                usrs = usrs.Where(c => c.AGENCY.Equals(LoginUser.Accounts));
            }
            //_sumCoins += agencies.Sum(c => c.COINS) ?? 0;
            //_sumCoinsBuy += agencies.Sum(c => c.COINS_BUY) ?? 0;
            //_sumCoinsBack += agencies.Sum(c => c.COINS_BACK) ?? 0;

            _sumCoins += usrs.Sum(c => c.COINS) ?? 0;//总金币
            _sumCoinsBuy += usrs.Sum(c => c.COINS_BUY) ?? 0;//总充值
            _sumCoinsBack += usrs.Sum(c => c.COINS_BACK) ?? 0;//总兑换

            _sumGain += (_sumCoinsBuy - _sumCoinsBack);//总盈利

            this.reportList.Add(new M_Reports { ReportType = ERePortType.EarningsReport, Title = "总充值", Val = _sumCoinsBuy });
            this.reportList.Add(new M_Reports { ReportType = ERePortType.EarningsReport, Title = "总兑换", Val = _sumCoinsBack });
            this.reportList.Add(new M_Reports { ReportType = ERePortType.EarningsReport, Title = "玩家总余额", Val = _sumCoins });
            this.reportList.Add(new M_Reports { ReportType = ERePortType.EarningsReport, Title = "总赢利", Val = _sumGain });
        }
        #endregion


    }
}
