using System;
using System.IO;
using System.Linq;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using Newtonsoft.Json;
using YYT.Web.Models;

namespace UnitTestProj
{
    /// <summary>麻将胡了出货率配置：页面 JSON ↔ cardpayoutprofile 行（与游戏服 MjhlWeight::ProfileBuilder 同口径）及配置页契约。</summary>
    [TestClass]
    public sealed class MjhlWeightProfileTest
    {
        private static string Root()
        {
            var dir = new DirectoryInfo(AppDomain.CurrentDomain.BaseDirectory);
            while (dir != null && !File.Exists(Path.Combine(dir.FullName, "MTH_Mgr_MySQL.sln"))) dir = dir.Parent;
            return dir.FullName;
        }
        private static void Reject(Action action)
        { try { action(); } catch (ArgumentException) { return; } Assert.Fail("必须拒绝非法配置"); }

        // 与 Scripts/app/mjhl.engine.js defaults() 相同的示例配置
        private static MjhlWeightProfile.Config Sample()
        {
            int[][] n = {
                new[]{1561,1469,1469,1469,1561}, new[]{1560,1469,1469,1469,1560}, new[]{656,618,618,618,656}, new[]{656,617,617,617,656}, new[]{496,467,467,467,496},
                new[]{209,196,196,196,209}, new[]{146,137,137,137,146}, new[]{110,104,104,104,110}, new[]{824,776,776,776,824}, new[]{0,20,20,20,0}, new[]{0,568,568,568,0} };
            int[][] f = {
                new[]{546,514,514,514,546}, new[]{546,514,514,514,546}, new[]{230,216,216,216,230}, new[]{230,216,216,216,230}, new[]{174,164,164,164,174},
                new[]{73,69,69,69,73}, new[]{51,48,48,48,51}, new[]{38,36,36,36,38}, new[]{288,271,271,271,288}, new[]{0,20,20,20,0}, new[]{0,568,568,568,0} };
            return new MjhlWeightProfile.Config
            {
                version = 1, weightTotal = 10000, enabled = Enumerable.Repeat(true, 11).ToArray(),
                weights = new MjhlWeightProfile.Weights { n = n, f = f }, goldChance = 8m, retrigger = true, retriggerAward = 2, retriggerLimit = 5,
                freeLimit = 100, targetRtp = 90m, targetScatter = 5m, spinCount = 10000, calibrationSamples = 5000
            };
        }
        private static MjhlWeightProfile.Config Clone(MjhlWeightProfile.Config c)
        { return JsonConvert.DeserializeObject<MjhlWeightProfile.Config>(JsonConvert.SerializeObject(c)); }

        [TestMethod]
        public void RowsUseTheGameServerLayoutAndRoundTrip()
        {
            var c = Sample(); c.enabled[7] = false; c.retrigger = false; c.goldChance = 12.34m; c.targetRtp = 92.5m; c.targetScatter = 4.25m;
            var rows = MjhlWeightProfile.WriteRows(c);
            Assert.AreEqual(MjhlWeightProfile.RowsPerTable, rows.Count);
            CollectionAssert.AreEquivalent(Enumerable.Range(2000, 11).Concat(Enumerable.Range(2020, 11)).Concat(new[] { 2100, 2101 }).ToArray(), rows.Select(r => r.HandType).ToArray());
            var fiveTong = rows.Single(r => r.HandType == 2000 + 3);   // 符号4 五筒，普通
            Assert.AreEqual(656, fiveTong.PayoutMultiplier); Assert.AreEqual(617, fiveTong.ProbabilityBasis);
            Assert.AreEqual(617L * 10000000L + 617L, fiveTong.StockLimit); Assert.AreEqual(656L, fiveTong.StockRemain);
            Assert.AreEqual(0, rows.Single(r => r.HandType == 2007).Enabled); Assert.AreEqual(0, rows.Single(r => r.HandType == 2027).Enabled);
            var set = rows.Single(r => r.HandType == 2100);
            Assert.AreEqual(1234, set.PayoutMultiplier); Assert.AreEqual(100, set.ProbabilityBasis); Assert.AreEqual(2L, set.StockLimit); Assert.AreEqual(5L, set.StockRemain); Assert.AreEqual(0, set.Enabled);
            var meta = rows.Single(r => r.HandType == 2101);
            Assert.AreEqual(1, meta.PayoutMultiplier); Assert.AreEqual(10000, meta.ProbabilityBasis);

            var back = MjhlWeightProfile.ReadRows(rows);
            Assert.AreEqual(JsonConvert.SerializeObject(c), JsonConvert.SerializeObject(back));
            Assert.IsNull(MjhlWeightProfile.ReadRows(new MjhlWeightProfile.Row[0]), "未配置的桌返回 null（游戏服走原分档算法）");
            Assert.IsNull(MjhlWeightProfile.ReadRows(new[] { new MjhlWeightProfile.Row { HandType = 1000 } }), "拉霸权重等其它 HandType 不算出货率配置");
        }

        [TestMethod]
        public void InvalidConfigurationsAreRejectedLikeTheGameServer()
        {
            MjhlWeightProfile.Validate(Sample());
            var c = Sample(); c.weights.n[10][0] = 5; Reject(() => MjhlWeightProfile.Validate(c));          // 至尊在第1轴
            c = Sample(); c.weights.f[9][4] = 5; Reject(() => MjhlWeightProfile.Validate(c));               // 百搭在第5轴
            c = Sample(); c.weights.n[0][2] = 9000; Reject(() => MjhlWeightProfile.Validate(c));            // 超过总量
            c = Sample(); c.weights.n[0][2] = -1; Reject(() => MjhlWeightProfile.Validate(c));
            c = Sample(); c.weights.n[0][2] = 1000001; Reject(() => MjhlWeightProfile.Validate(c));
            c = Sample(); c.freeLimit = 13; Reject(() => MjhlWeightProfile.Validate(c));                    // 五个胡要送 14 次
            c = Sample(); c.goldChance = 8.125m; Reject(() => MjhlWeightProfile.Validate(c));
            c = Sample(); c.weightTotal = 99; Reject(() => MjhlWeightProfile.Validate(c));
            c = Sample(); for (int i = 0; i < 9; i++) c.enabled[i] = false; Reject(() => MjhlWeightProfile.Validate(c));
            c = Sample(); c.version = 2; Reject(() => MjhlWeightProfile.Validate(c));
            c = Sample(); c.weights.n = c.weights.n.Take(10).ToArray(); Reject(() => MjhlWeightProfile.Validate(c));
            Reject(() => MjhlWeightProfile.Parse("{not json"));
            Reject(() => MjhlWeightProfile.Parse("{\"version\":1,\"weightTotal\":10000,\"weights\":{\"n\":[[1.5]]}}"));
            // 关闭的牌不计入总量
            c = Sample(); c.weights.n[0][1] = 9000; c.enabled[0] = false; MjhlWeightProfile.Validate(c);
        }

        [TestMethod]
        public void IncompleteOrInconsistentStoredRowsAreRejected()
        {
            var rows = MjhlWeightProfile.WriteRows(Sample());
            Reject(() => MjhlWeightProfile.ReadRows(rows.Where(r => r.HandType != 2005)));
            Reject(() => MjhlWeightProfile.ReadRows(rows.Where(r => r.HandType != 2100)));
            Reject(() => MjhlWeightProfile.ReadRows(rows.Concat(new[] { rows[0] })));
            var bad = MjhlWeightProfile.WriteRows(Sample()); bad.Single(r => r.HandType == 2023).Enabled = 0;
            Reject(() => MjhlWeightProfile.ReadRows(bad));
            bad = MjhlWeightProfile.WriteRows(Sample()); bad.Single(r => r.HandType == 2101).PayoutMultiplier = 2;
            Reject(() => MjhlWeightProfile.ReadRows(bad));
            bad = MjhlWeightProfile.WriteRows(Sample()); bad.Single(r => r.HandType == 2002).StockLimit = -1;
            Reject(() => MjhlWeightProfile.ReadRows(bad));
        }

        [TestMethod]
        public void BetLadderRuleMatchesTheGameServer()
        {
            Assert.IsNull(MjhlWeightProfile.CheckBetLadder(100, 5000, 100));
            Assert.IsNull(MjhlWeightProfile.CheckBetLadder(40, 6000, 40));
            Assert.IsNull(MjhlWeightProfile.CheckBetLadder(40, 6000, 400));     // 最大值不在步长上时仍作为最后一档
            Assert.IsNotNull(MjhlWeightProfile.CheckBetLadder(40, 6000, 1));    // 线上原数据（步长 1）不合法，需运营改成 20 的倍数
            Assert.IsNotNull(MjhlWeightProfile.CheckBetLadder(50, 5000, 100));
            Assert.IsNotNull(MjhlWeightProfile.CheckBetLadder(100, 5010, 100));
            Assert.IsNotNull(MjhlWeightProfile.CheckBetLadder(200, 100, 20));
            Assert.IsNotNull(MjhlWeightProfile.CheckBetLadder(20, 100000, 20)); // 超过 200 档
            Assert.IsNotNull(MjhlWeightProfile.CheckBetLadder(100.5m, 5000, 100));
        }

        [TestMethod]
        public void ConfigPageWiringAndLabaChipRemoval()
        {
            string web = Path.Combine(Root(), "TTY.Web");
            string view = File.ReadAllText(Path.Combine(web, "Areas/Game/Views/GameConfig/ConfigEditor.cshtml"));
            StringAssert.Contains(view, "@Html.Partial(\"_MjhlWeights\")");
            StringAssert.Contains(view, "window.mjhlWeightsLoad");
            StringAssert.Contains(view, "window.mjhlWeightsClear");
            Assert.IsFalse(view.Contains("gc-only-0 gc-only-3"), "拉霸不再显示一到五级筹码");
            StringAssert.Contains(view, "if (gcGetType() === 3) { $('#gcBetScores').val(''); return; }");
            StringAssert.Contains(view, "function gcMjhlLadderError(");

            string controller = File.ReadAllText(Path.Combine(web, "Areas/Game/Controllers/GameConfigController.cs"));
            int start = controller.IndexOf("if (gameType == 3)", controller.IndexOf("public ActionResult SaveTableConfig"));
            string laba = controller.Substring(start, controller.IndexOf("bool isNew = tableId < 0", start) - start);
            StringAssert.Contains(laba, "string labaBetScores = \"\";");
            Assert.IsFalse(laba.Contains("form.Q<string>(\"BetScores\""), "拉霸保存不再读取页面筹码");
            StringAssert.Contains(laba, "MjhlWeightProfile.CheckBetLadder(");
            StringAssert.Contains(laba, "gameId == global::YYT.Web.Models.MjhlWeightProfile.GameId) && msg.code == 1");

            string weights = File.ReadAllText(Path.Combine(web, "Areas/Game/Controllers/GameConfigMjhlController.cs")).Replace("\r\n", "\n");
            StringAssert.Contains(weights, "[AjaxOnly, HttpPost, ValidateAntiForgeryToken, SuperAdminAuthorize]\n        public ActionResult SaveMjhlWeights");
            StringAssert.Contains(weights, "[AjaxOnly, HttpPost, ValidateAntiForgeryToken, SuperAdminAuthorize]\n        public ActionResult DeleteMjhlWeights");
            StringAssert.Contains(weights, "ef.Database.BeginTransaction()");
            StringAssert.Contains(weights, "tx.Commit()");
            StringAssert.Contains(weights, "HandType BETWEEN 2000 AND 2199");
            StringAssert.Contains(weights, "SendPcCommand");

            string csproj = File.ReadAllText(Path.Combine(web, "YYT.Web.csproj"));
            foreach (string f in new[] { "Models\\MjhlWeightProfile.cs", "Areas\\Game\\Controllers\\GameConfigMjhlController.cs", "Areas\\Game\\Views\\GameConfig\\_MjhlWeights.cshtml", "Scripts\\app\\mjhl.engine.js", "Scripts\\app\\game.mjhlweights.js" })
                StringAssert.Contains(csproj, "Include=\"" + f + "\"", "老式 csproj 必须登记新文件：" + f);
        }
    }
}
