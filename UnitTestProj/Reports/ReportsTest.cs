using System;
using System.Collections.Generic;
using System.Linq;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using YYT.BLL.EF;
using YYT.Entity;

namespace UnitTestProj.Reports
{
    [TestClass]
    public class ReportsTest
    {
        [TestMethod]
        public void GetAgencies()
        {

        }

        [TestMethod]
        public void ReChargeReports()
        {
            var sTime = new DateTime(DateTime.Now.Year, DateTime.Now.Month, DateTime.Now.Day);
            var eTime = sTime.AddDays(1).AddSeconds(-1);

            M_LoginUser loginUser = new M_LoginUser { Accounts = "admin", UserPriv = 0 };
            B_Reports reports = new B_Reports(loginUser);
            using (var ef = new GameDbContext())
            {
                reports.ReChargeReports(ef);
                Assert.AreEqual(ef.ReChargeRecords.Where(c => c.RechargeType != 21 && c.Processed == 1 && c.CreateTime >= sTime && c.CreateTime <= eTime).Sum(c => c.Coin), reports.reportList.Find(c => c.Title.Equals("今日充值额度")).Val);
                Assert.AreEqual(ef.ReChargeRecords.Where(c => c.RechargeType != 21).Count(), reports.reportList.Find(c => c.Title.Equals("充值订单总数")).Val);
                Assert.AreEqual(ef.ReChargeRecords.Where(c => c.RechargeType != 21 && c.Processed == 1).Count(), reports.reportList.Find(c => c.Title.Equals("已处理订单数")).Val);
                Assert.AreEqual(ef.ReChargeRecords.Where(c => c.RechargeType != 21 && c.Processed == 0).Count(), reports.reportList.Find(c => c.Title.Equals("未处理订单数")).Val);
            }

            loginUser = new M_LoginUser { Accounts = "aaaaaa", UserPriv = 2 };
            reports = new B_Reports(loginUser);
            using (var ef = new GameDbContext())
            {
                reports.ReChargeReports(ef);
                Assert.AreEqual(ef.ReChargeRecords.Where(c => c.Agency.Equals(loginUser.Accounts) && c.RechargeType != 21 && c.Processed == 1 && c.CreateTime >= sTime && c.CreateTime <= eTime).Sum(c => c.Coin), reports.reportList.Find(c => c.Title.Equals("今日充值额度")).Val);
                Assert.AreEqual(ef.ReChargeRecords.Where(c => c.Agency.Equals(loginUser.Accounts) && c.RechargeType != 21).Count(), reports.reportList.Find(c => c.Title.Equals("充值订单总数")).Val);
                Assert.AreEqual(ef.ReChargeRecords.Where(c => c.Agency.Equals(loginUser.Accounts) && c.RechargeType != 21 && c.Processed == 1).Count(), reports.reportList.Find(c => c.Title.Equals("已处理订单数")).Val);
                Assert.AreEqual(ef.ReChargeRecords.Where(c => c.Agency.Equals(loginUser.Accounts) && c.RechargeType != 21 && c.Processed == 0).Count(), reports.reportList.Find(c => c.Title.Equals("未处理订单数")).Val);
            }
        }

        [TestMethod]
        public void CoinReports()
        {
            M_LoginUser loginUser = new M_LoginUser { Accounts = "admin", UserPriv = 2 };

            B_Reports reports = new B_Reports(loginUser);
            using (var ef = new GameDbContext())
            {
                reports.CoinReports(ef);
                Assert.AreEqual(reports.reportList.Find(c => c.Title.Equals("总金币")).Val, 322614);
                Assert.AreEqual(reports.reportList.Find(c => c.Title.Equals("总充值")).Val, 10429999);
                Assert.AreEqual(reports.reportList.Find(c => c.Title.Equals("总兑换")).Val, 10000000);
                Assert.AreEqual(reports.reportList.Find(c => c.Title.Equals("总赢利")).Val, 107385);
            }
        }
    }
}
