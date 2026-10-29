using System;
using System.IO;
using System.Linq;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using YYT.Web.Models;

namespace UnitTestProj
{
    [TestClass]
    public sealed class LabaWeightMathTest
    {
        private static string Root()
        {
            var dir=new DirectoryInfo(AppDomain.CurrentDomain.BaseDirectory);
            while (dir!=null && !File.Exists(Path.Combine(dir.FullName,"MTH_Mgr_MySQL.sln"))) dir=dir.Parent;
            return dir.FullName;
        }
        private static LabaWeightMath MathModel()
        { return new LabaWeightMath(File.ReadAllText(Path.Combine(Root(),"TTY.Web/Config/laba-weight-catalog.json"))); }
        private static void Reject(Action action)
        { try { action(); } catch (ArgumentException) { return; } Assert.Fail("必须拒绝非法配置"); }

        [TestMethod]
        public void AllThreeDefaultsAndRelativeWeightsAreConsistent()
        {
            var math=MathModel();
            foreach (int game in new[]{16,53,40})
            {
                var c=math.Defaults(game); var r=math.Calculate(game,c,1);
                Assert.IsTrue(r.totalRtp>89 && r.totalRtp<91,game+" "+r.totalRtp);
                foreach (int i in Enumerable.Range(0,c.main.Length)) c.main[i]*=2;
                Assert.AreEqual(r.totalRtp,math.Calculate(game,c,1).totalRtp,1e-9);
            }
        }
        [TestMethod]
        public void EveryCategoryUsesItsActualEvaluatedBoards()
        {
            var math=MathModel(); int count=0;
            foreach (int game in new[]{16,53})
            {
                var c=math.Defaults(game); Array.Clear(c.main,0,c.main.Length);
                var items=math.Find(game).items;
                for (int i=0;i<c.main.Length;i++)
                {
                    c.main[i]=1; var r=math.Calculate(game,c,1);
                    Assert.AreEqual(items[i].boards.Average(b=>b.pay)/(game==16 ? 8.0 : 9.0)*100,r.baseRtp,1e-7,items[i].name);
                    c.main[i]=0; count++;
                }
            }
            Assert.AreEqual(68,count);
        }
        [TestMethod]
        public void FruitLuckyLightsAndSpecialTargetsAreIncluded()
        {
            var math=MathModel(); var c=math.Defaults(40); Array.Clear(c.main,0,c.main.Length);
            double ratSum=math.Find(40).rat.Sum();
            c.main[0]=9; c.main[9]=1;
            Assert.AreEqual((0.9*10/8.0+0.1*0.5*3.0/22*ratSum/8)*100,math.Calculate(40,c,1).totalRtp,1e-9);
            c.main[0]=0;
            Assert.AreEqual(0.5*3.0/22*ratSum/8*100,math.Calculate(40,c,1).totalRtp,1e-9);
            c.extra[0]=1; c.extra[9]=1; c.extra[12]=0;
            double expected=math.Find(40).rat.Sum()/8.0*7/22*100;
            Assert.AreEqual(expected,math.Calculate(40,c,1).totalRtp,1e-8);
        }
        [TestMethod]
        public void MaryUsesFiniteExitBudgetAndStackedInnerAwards()
        {
            var math=MathModel(); var c=math.Defaults(53); Array.Clear(c.main,0,c.main.Length);
            c.main[Array.FindIndex(math.Find(53).items,i=>i.code==440)]=1;
            c.extra[0]=1; for (int i=40;i<64;i++) c.extra[i]=0;
            c.extra[41]=1; c.extra[64]=30;
            var r=math.Calculate(53,c,1);
            Assert.AreEqual(500000,r.baseRtp,1e-7);
            Assert.AreEqual(3*(10+780.0/512)*100/9,r.extraRtp,1e-7);
            c.extra[64]=27; Assert.AreEqual(0,math.Calculate(53,c,1).extraRtp,1e-8);
        }
        [TestMethod]
        public void Star97HasNoExtraPlayAndChargesEightLines()
        {
            var math=MathModel(); var c=math.Defaults(16); Array.Clear(c.main,0,c.main.Length);
            c.main[0]=4; c.main[1]=1; c.extra[0]=1; c.extra[20]=3000;
            c.extra[24]=2000; c.extra[25]=1000; c.extra[26]=500; c.extra[27]=2;
            var r=math.Calculate(16,c,1);
            double mean=math.Find(16).items[1].boards.Average(b=>b.pay)*0.2/8;
            Assert.AreEqual(0,r.extraRtp,1e-12);
            Assert.AreEqual(mean*100,r.totalRtp,1e-8);
        }
        [TestMethod]
        public void InvalidConfigAndStaleCatalogCannotBeSaved()
        {
            var math=MathModel(); var c=math.Defaults(16);
            c.extra[24]=6000; c.extra[25]=5000; Reject(()=>math.Validate(16,c));
            c=math.Defaults(16); c.extra[70]=0; Reject(()=>math.Validate(16,c));
            c=math.Defaults(16); Array.Clear(c.main,0,c.main.Length); Reject(()=>math.Validate(16,c));
            c=math.Defaults(16); JObject payload=JObject.Parse(JsonConvert.SerializeObject(c)); payload["main"][0]=0.1;
            string json=payload.ToString();
            Reject(()=>math.Parse(16,json));
        }
        [TestMethod]
        public void SavedProfilesRoundTripPreservesExplicitZeroAndExtraOverrides()
        {
            var math=MathModel();
            foreach (int game in new[]{16,40,53})
            {
                var c=math.Defaults(game); c.enabled=true; c.main[1]=0; c.extra[40]=0;
                var rows=math.WriteProfiles(game,c); var restored=math.ReadProfiles(game,rows);
                CollectionAssert.AreEqual(c.main,restored.main);
                CollectionAssert.AreEqual(c.extra,restored.extra);
                Assert.IsTrue(restored.enabled);
                Assert.AreEqual(math.Calculate(game,c,1).totalRtp,math.Calculate(game,restored,1).totalRtp,1e-9);
            }
            Assert.IsFalse(math.ReadProfiles(16,new LabaWeightMath.Profile[0]).enabled);
        }
        [TestMethod]
        public void IncompleteAndDuplicateStoredProfilesAreRejectedBeforeDisplayingRtp()
        {
            var math=MathModel(); var c=math.Defaults(16); c.enabled=true; c.main[1]=0;
            var rows=math.WriteProfiles(16,c);
            Reject(()=>math.ReadProfiles(16,rows.Where(r=>r.HandType!=1101)));
            Reject(()=>math.ReadProfiles(16,rows.Where(r=>r.HandType!=1270)));
            Reject(()=>math.ReadProfiles(16,rows.Where(r=>r.HandType!=1000)));
            Reject(()=>math.ReadProfiles(16,rows.Concat(new[]{rows[1]})));
            var invalid=math.WriteProfiles(16,c); invalid[0].ProbabilityBasis=2;
            Reject(()=>math.ReadProfiles(16,invalid));
            invalid=math.WriteProfiles(16,c); invalid[0].PayoutMultiplier=2;
            Reject(()=>math.ReadProfiles(16,invalid));
        }
        [TestMethod]
        public void TableEditorOnlyOffersRelativeWeightsAndBaseSavePreservesOutcomeConfig()
        {
            string view=File.ReadAllText(Path.Combine(Root(),"TTY.Web/Areas/Game/Views/GameConfig/ConfigEditor.cshtml"));
            StringAssert.Contains(view,"@Html.Partial(\"_LabaWeights\")");
            foreach (string old in new[]{"gcAdvHead","gcRtpBox","gcFruitRtpBox","gcLabaPayoutTable","gcMx97ComboTable","gcShzComboTable","gcSyncWheelPanels"})
                Assert.IsFalse(view.Contains(old),"旧中奖编辑入口残留："+old);
            string source=File.ReadAllText(Path.Combine(Root(),"TTY.Web/Areas/Game/Controllers/GameConfigController.cs"));
            int start=source.IndexOf("if (gameType == 3)",source.IndexOf("public ActionResult SaveTableConfig"));
            string save=source.Substring(start,source.IndexOf("bool isNew = tableId < 0",start)-start);
            foreach (string old in new[]{"SaveMx97RtpConfig(","SaveFruitRtpConfig(","SaveShzRtpConfig(","form.Q<int>(\"WheelProb"})
                Assert.IsFalse(save.Contains(old),"基础保存不能覆盖开奖参数："+old);
            StringAssert.Contains(save,"SELECT * FROM paralaba WHERE GAME_ID={0} AND TableIndex={1}");
        }

        [TestMethod]
        public void NewConfigurationWriteHasAuthorizationTransactionAndScopeGuards()
        {
            string source=File.ReadAllText(Path.Combine(Root(),"TTY.Web/Areas/Game/Controllers/GameConfigWeightsController.cs"));
            StringAssert.Contains(source,"[AjaxOnly, HttpPost, ValidateAntiForgeryToken, SuperAdminAuthorize]");
            StringAssert.Contains(source,"ef.Database.BeginTransaction()");
            StringAssert.Contains(source,"CheckWeightScope(gameId,tableIndex)");
            StringAssert.Contains(source,"HandType BETWEEN 1000 AND 1279");
            StringAssert.Contains(source,"tx.Commit()");
            StringAssert.Contains(source,"SendPcCommand");
        }
    }
}
