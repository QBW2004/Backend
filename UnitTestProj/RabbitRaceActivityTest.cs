using System;
using System.Collections.Generic;
using System.IO;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using Newtonsoft.Json.Linq;
using YYT.BLL.EF;

namespace UnitTestProj
{
    /// <summary>
    /// 全民赛跑活动配置（2026-11-03）：字段校验、JSON 与游戏服 RabbitActivity.h 同名、北京时间窗口与活动日口径、
    /// 客户端接口只在「活动开启 + 代理线开放大白兔」时展示、后台菜单入口。
    /// </summary>
    [TestClass]
    public class RabbitRaceActivityTest
    {
        private static DirectoryInfo FindRepoRoot()
        {
            DirectoryInfo dir = new DirectoryInfo(AppDomain.CurrentDomain.BaseDirectory);
            while (dir != null && !File.Exists(Path.Combine(dir.FullName, "MTH_Mgr_MySQL.sln")))
                dir = dir.Parent;
            Assert.IsNotNull(dir, "Cannot locate repository root.");
            return dir;
        }

        private static RabbitRaceActivity Sample()
        {
            return new RabbitRaceActivity { Enabled = true, StartMinute = 600, EndMinute = 1320, DailyQuota = 50, Multiplier = 10, Types = new List<int> { 10, 7, 7 } };
        }

        [TestMethod]
        public void ValidateRejectsBadFields()
        {
            Assert.IsNull(Sample().Validate());
            var a = Sample(); a.StartMinute = a.EndMinute; Assert.IsNotNull(a.Validate());
            a = Sample(); a.EndMinute = 1440; Assert.IsNotNull(a.Validate());
            a = Sample(); a.DailyQuota = 0; Assert.IsNotNull(a.Validate());
            a = Sample(); a.Multiplier = 0; Assert.IsNotNull(a.Validate());
            a = Sample(); a.Types = new List<int>(); Assert.IsNotNull(a.Validate());
            a = Sample(); a.Types = new List<int> { 6 }; Assert.IsNotNull(a.Validate(), "四梅以下不可勾选");
            a = Sample(); a.Types = new List<int> { 13 }; Assert.IsNotNull(a.Validate());
            Assert.IsNull(RabbitRaceActivity.Default().Validate());
            Assert.IsFalse(RabbitRaceActivity.Default().Enabled, "默认关闭");
        }

        [TestMethod]
        public void JsonMatchesGameServerContractAndRoundTrips()
        {
            JObject json = JObject.Parse(Sample().ToJson());
            Assert.AreEqual(1, (int)json["schemaVersion"]);
            Assert.IsTrue((bool)json["enabled"]);
            Assert.AreEqual(600, (int)json["startMinute"]);
            Assert.AreEqual(1320, (int)json["endMinute"]);
            Assert.AreEqual(50, (int)json["dailyQuota"]);
            Assert.AreEqual(10, (int)json["multiplier"]);
            CollectionAssert.AreEqual(new[] { 7, 10 }, json["types"].ToObject<int[]>(), "去重排序");
            var back = RabbitRaceActivity.Parse(json.ToString());
            Assert.AreEqual(600, back.StartMinute); CollectionAssert.AreEqual(new List<int> { 7, 10 }, back.Types);

            // 游戏服解析同一组字段名，改名必须两端同步。
            string header = File.ReadAllText(Path.Combine(FindRepoRoot().Parent.FullName, "MTH-Server", "ServerCardPhenix", "RabbitActivity.h"));
            foreach (string key in new[] { "schemaVersion", "enabled", "startMinute", "endMinute", "dailyQuota", "multiplier", "types" })
                StringAssert.Contains(header, "\"" + key + "\"");
        }

        [TestMethod]
        public void MinuteFormattingAndTypeText()
        {
            Assert.AreEqual(600, RabbitRaceActivity.ParseMinute("10:00"));
            Assert.AreEqual(1439, RabbitRaceActivity.ParseMinute("23:59"));
            Assert.AreEqual(-1, RabbitRaceActivity.ParseMinute("24:00"));
            Assert.AreEqual(-1, RabbitRaceActivity.ParseMinute(""));
            Assert.AreEqual("09:05", RabbitRaceActivity.FormatMinute(545));
            var all = Sample(); all.Types = new List<int> { 7, 8, 9, 10, 11, 12 };
            Assert.AreEqual("四梅及以上", all.TypeText());
            Assert.AreEqual("小四梅、五梅", Sample().TypeText());
        }

        [TestMethod]
        public void BeijingWindowAndActivityDay()
        {
            var a = Sample();
            Assert.IsFalse(a.IsOpen(new DateTime(2026, 11, 3, 9, 59, 0)));
            Assert.IsTrue(a.IsOpen(new DateTime(2026, 11, 3, 10, 0, 0)));
            Assert.IsFalse(a.IsOpen(new DateTime(2026, 11, 3, 22, 0, 0)));
            Assert.AreEqual(new DateTime(2026, 11, 3, 10, 0, 0), a.ActivityDayStart(new DateTime(2026, 11, 3, 23, 0, 0)));
            // 跨零点：凌晨段属于前一天的活动日，与游戏服 ActivityDay 一致。
            var night = Sample(); night.StartMinute = 1320; night.EndMinute = 120;
            Assert.IsTrue(night.IsOpen(new DateTime(2026, 11, 4, 1, 0, 0)));
            Assert.IsFalse(night.IsOpen(new DateTime(2026, 11, 4, 2, 0, 0)));
            Assert.AreEqual(new DateTime(2026, 11, 3, 22, 0, 0), night.ActivityDayStart(new DateTime(2026, 11, 4, 1, 0, 0)));
            Assert.AreEqual(new DateTime(2026, 11, 4, 22, 0, 0), night.ActivityDayStart(new DateTime(2026, 11, 4, 23, 0, 0)));
            var off = Sample(); off.Enabled = false;
            Assert.IsFalse(off.IsOpen(new DateTime(2026, 11, 3, 12, 0, 0)));
            Assert.AreEqual(new DateTime(2026, 11, 3, 20, 0, 0), RabbitRaceActivity.BeijingNow(new DateTime(2026, 11, 3, 12, 0, 0, DateTimeKind.Utc)));
        }

        [TestMethod]
        public void QuotaDayIncludesAwardsBeforeChangedOpeningTime()
        {
            var a = Sample();
            var noon = new DateTime(2026, 11, 5, 12, 30, 0);
            Assert.AreEqual(noon.Date, a.QuotaDayStart(noon));
            a.StartMinute = 720;
            Assert.AreEqual(noon.Date, a.QuotaDayStart(noon), "修改开始时间不退回当天已用名额");
            Assert.AreEqual(noon.Date.AddDays(-1), a.QuotaDayStart(noon.Date.AddHours(1)), "开始前保留上一轮");
            Assert.AreEqual(noon.Date, a.QuotaDayStart(noon.Date.AddDays(1)), "零点不提前恢复名额");
            Assert.AreEqual(noon.Date, a.QuotaDayStart(noon.Date.AddDays(1).AddHours(12).AddTicks(-1)), "开始前最后一刻保留上一轮");
            Assert.AreEqual(noon.Date.AddDays(1), a.QuotaDayStart(noon.Date.AddDays(1).AddHours(12)), "到开始时间才切换下一轮");
            a.StartMinute = 1320; a.EndMinute = 120;
            Assert.AreEqual(noon.Date.AddDays(-1).AddHours(2), a.QuotaDayStart(noon.Date.AddHours(1)), "跨午夜凌晨属于前日名额");
            Assert.AreEqual(noon.Date.AddDays(-1).AddHours(2), a.QuotaDayStart(noon.Date.AddHours(2)), "跨午夜结束时不恢复");
            Assert.AreEqual(noon.Date.AddDays(-1).AddHours(2), a.QuotaDayStart(noon), "跨午夜未开场保留上一轮");
            Assert.AreEqual(noon.Date.AddHours(2), a.QuotaDayStart(noon.Date.AddHours(22)), "跨午夜到开始时间恢复");
        }

        [TestMethod]
        public void EveryOpeningMinuteRestoresOnlyAtTheBoundary()
        {
            var nextDay = new DateTime(2026, 11, 6);
            var a = Sample();
            for (int start = 0; start < 1440; start++)
            {
                a.StartMinute = start; a.EndMinute = (start + 60) % 1440;
                DateTime opening = nextDay.AddMinutes(start);
                Assert.AreEqual(opening.AddDays(-1), a.ActivityDayStart(opening.AddTicks(-1)), "开始前仍是上一轮: " + start);
                Assert.AreEqual(opening, a.ActivityDayStart(opening), "到开始时间切换: " + start);
                Assert.AreEqual(a.QuotaDayStart(opening.AddTicks(-1)).AddDays(1), a.QuotaDayStart(opening), "只切换一天: " + start);
            }
        }

        [TestMethod]
        public void ClientApiHidesWhenClosedOrLineWithoutRabbitAndMenuHasEntry()
        {
            DirectoryInfo root = FindRepoRoot();
            string api = File.ReadAllText(Path.Combine(root.FullName, "TTY.Web", "Controllers", "Api", "RabbitRaceActivityController.cs"));
            StringAssert.Contains(api, "!cfg.Enabled");
            StringAssert.Contains(api, "GetPlayableGamesOfPlayer");
            StringAssert.Contains(api, "!playable.Contains(RabbitRaceActivity.GameId)");
            StringAssert.Contains(api, "Enable=1");
            string menu = File.ReadAllText(Path.Combine(root.FullName, "TTY.Web", "Views", "Mgr", "Index.cshtml"));
            StringAssert.Contains(menu, "\"ActivityConfig\"");
            StringAssert.Contains(menu, "活动配置");
            byte[] view = File.ReadAllBytes(Path.Combine(root.FullName, "TTY.Web", "Areas", "Game", "Views", "ActivityConfig", "Index.cshtml"));
            Assert.IsTrue(view.Length > 3 && view[0] == 0xEF && view[1] == 0xBB && view[2] == 0xBF, "cshtml 必须 UTF-8 BOM");
        }
    }
}
