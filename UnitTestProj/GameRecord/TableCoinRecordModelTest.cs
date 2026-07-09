using System;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using YYT.Entity;

namespace UnitTestProj.GameRecord
{
    [TestClass]
    public class TableCoinRecordModelTest
    {
        [TestMethod]
        public void TableCoinRecord_CreateTimeStr_ShouldFormatTimestamp()
        {
            var record = new M_TableCoinRecord
            {
                CreateTime = new DateTime(2026, 5, 14, 10, 20, 30)
            };

            Assert.AreEqual("2026-05-14 10:20:30", record.CreateTimeStr);
        }
    }
}
