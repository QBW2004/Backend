using System;
using System.Text;
using System.Collections.Generic;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using YYT.BLL.EF;
using YYT.Entity;
using System.Linq;

namespace UnitTestProj.ReCharge
{
    /// <summary>
    /// ConfirmReChargeOrder 的摘要说明
    /// </summary>
    [TestClass]
    public class ConfirmReChargeOrder
    {
        [TestMethod]
        public void ConfirmOrder()
        {
            B_ReChargeRecords bll = new B_ReChargeRecords();

            string orderNo = string.Empty;
            Msg msg = null;

            using (var ef = new GameDbContext())
            {
                M_Admin agency = ef.Admins.Where(c => c.ID.Equals("aaaaaa")).SingleOrDefault();
                M_ReChargeRecords record = ef.ReChargeRecords.Where(c => c.Processed == 0 && c.Coin == 100).FirstOrDefault();
                msg = bll.ConfirmReChargeOrder(agency.ToLoginUser(), record.OrderNo);

                Assert.AreEqual<int>(1, msg.code);
            }

        }
    }
}
