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
        public void FruitLuckyLightsUseIndependentAwardPools()
        {
            // 右侧(灯10/面板位9)用 extra[1..12]，左侧(灯22/面板位21)用 extra[28..39]；左侧全 0 沿用右侧。
            var math=MathModel(); var c=math.Defaults(40); Array.Clear(c.main,0,c.main.Length);
            c.extra[0]=1; c.extra[9]=1; c.extra[12]=0;
            c.main[9]=1; c.main[21]=0;
            double right=math.Calculate(40,c,1).totalRtp;
            c.main[9]=0; c.main[21]=1;
            Assert.AreEqual(right,math.Calculate(40,c,1).totalRtp,1e-9,"左侧未配置奖池时应沿用右侧");
            CollectionAssert.AreEqual(new[]{0,0,0,0,0,0,0,0,1,0,0,0},LabaWeightMath.FruitPool(c,9));
            CollectionAssert.AreEqual(new[]{0,0,0,0,0,0,0,0,1,0,0,0},LabaWeightMath.FruitPool(c,21));
            // 左侧单独配成另一种奖（大四喜=索引2），只影响左灯
            c.extra[30]=1;
            CollectionAssert.AreEqual(new[]{0,0,1,0,0,0,0,0,0,0,0,0},LabaWeightMath.FruitPool(c,21));
            CollectionAssert.AreEqual(new[]{0,0,0,0,0,0,0,0,1,0,0,0},LabaWeightMath.FruitPool(c,9));
            double leftOnly=math.Calculate(40,c,1).totalRtp;
            c.main[9]=1; c.main[21]=0;
            Assert.AreEqual(right,math.Calculate(40,c,1).totalRtp,1e-9,"左灯奖池不能影响右灯");
            c.main[9]=0; c.main[21]=1;
            Assert.AreEqual(leftOnly,math.Calculate(40,c,1).totalRtp,1e-9);
            Assert.AreNotEqual(right,leftOnly,1e-9);
            // 两灯各半时是两种奖池的加权平均
            c.main[9]=1; c.main[21]=1;
            Assert.AreEqual((right+leftOnly)/2,math.Calculate(40,c,1).totalRtp,1e-9);
            // 左侧 12 项全 0 时保存/回读仍是全 0（沿用标记不能丢）
            c.main[9]=1; c.main[21]=1; c.extra[12]=1; Array.Clear(c.extra,28,12);
            var restored=math.ReadProfiles(40,math.WriteProfiles(40,c));
            CollectionAssert.AreEqual(new int[12],restored.extra.Skip(28).Take(12).ToArray());
            Assert.AreEqual(1,restored.extra[12]);
            c.extra[30]=2; c.extra[39]=3;
            restored=math.ReadProfiles(40,math.WriteProfiles(40,c));
            Assert.AreEqual(2,restored.extra[30]);
            Assert.AreEqual(3,restored.extra[39]);
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
        public void FruitWheelExposesBothLuckyLightsIndependently()
        {
            // 转盘 24 灯：灯10（面板位 9）是右列正中=右侧幸运灯，灯22（面板位 21）是左列正中=左侧幸运灯。
            // 两项必须都能在桌台设置里单独改，保存/回读不得互相覆盖或均分。
            var math=MathModel(); var g=math.Find(40);
            Assert.AreEqual(24,g.items.Length);
            Assert.AreEqual(9,g.items[9].code);
            Assert.AreEqual(21,g.items[21].code);
            StringAssert.Contains(g.items[9].name,"右侧");
            StringAssert.Contains(g.items[21].name,"左侧");
            Assert.AreEqual(0,g.rat[9]); Assert.AreEqual(0,g.rat[21]);
            Assert.AreEqual(-1,g.area[9]); Assert.AreEqual(-1,g.area[21]);
            var c=math.Defaults(40); c.enabled=true; c.main[9]=111; c.main[21]=222;
            var restored=math.ReadProfiles(40,math.WriteProfiles(40,c));
            Assert.AreEqual(111,restored.main[9]);
            Assert.AreEqual(222,restored.main[21]);
            Assert.IsFalse(restored.main[9]==restored.main[21],"两个幸运灯权重不能合并");
            string view=File.ReadAllText(Path.Combine(Root(),"TTY.Web/Areas/Game/Views/GameConfig/_LabaWeights.cshtml"));
            StringAssert.Contains(view,"lwFruitHint");
            StringAssert.Contains(view,"灯10（右侧幸运灯）");
            StringAssert.Contains(view,"灯22（左侧幸运灯）");
            StringAssert.Contains(view,"game.labaweights.js?v=");
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
        public void EditorUsesPer10000WithDerivedNoWin()
        {
            var math=MathModel();
            foreach (int game in new[]{16,53})
            {
                Assert.IsTrue(math.HasNoWin(game));
                int scale=LabaWeightMath.ScaleOf(game);
                Assert.AreEqual(game==53 ? 100000 : 10000,scale);
                bool converted; var c=math.ToEditorScale(game,math.Defaults(game),out converted);
                Assert.IsTrue(converted);
                Assert.AreEqual(scale,c.main.Sum());
                Assert.IsTrue(c.main.All(v=>v>=0 && v<=scale));
                math.ValidateEditor(game,c);
                var again=math.ToEditorScale(game,c,out converted);
                Assert.IsFalse(converted);
                CollectionAssert.AreEqual(c.main,again.main);
                var bad=math.ToEditorScale(game,math.Defaults(game),out converted); bad.main[0]+=1;
                Reject(()=>math.ValidateEditor(game,bad));
                bad=math.ToEditorScale(game,math.Defaults(game),out converted); Array.Clear(bad.main,0,bad.main.Length); bad.main[1]=scale+1;
                Reject(()=>math.ValidateEditor(game,bad));
            }
            // 水浒传按 100000：默认值换算后全屏大奖都不为 0
            bool shzConverted; var shz=math.ToEditorScale(53,math.Defaults(53),out shzConverted);
            var shzItems=math.Find(53).items;
            Assert.IsTrue(Enumerable.Range(0,shz.main.Length).Where(i=>shzItems[i].code>=440).All(i=>shz.main[i]>0));
            Assert.IsFalse(math.HasNoWin(40));
            bool fruitConverted; var fruit=math.ToEditorScale(40,math.Defaults(40),out fruitConverted);
            Assert.IsFalse(fruitConverted);
            math.ValidateEditor(40,fruit);
            fruit.main[0]=10001; Reject(()=>math.ValidateEditor(40,fruit));
            fruit=math.Defaults(40); fruit.extra[1]=10001; Reject(()=>math.ValidateEditor(40,fruit));
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

        [TestMethod]
        public void EditorActivationPreservesStoredValuesUntilExplicitSave()
        {
            var math=MathModel();
            foreach (int game in new[]{16,40,53})
            {
                bool converted;
                var stored=math.ToEditorScale(game,math.Defaults(game),out converted);
                var main=(int[])stored.main.Clone(); var extra=(int[])stored.extra.Clone();
                var editor=math.ActivateEditor(game,stored);
                Assert.IsTrue(editor.enabled);
                Assert.IsFalse(stored.enabled,"载入编辑页不能改写原配置");
                CollectionAssert.AreEqual(main,stored.main);
                CollectionAssert.AreEqual(extra,stored.extra);
                CollectionAssert.AreEqual(main,editor.main);
                if (game==40) extra[0]=1;
                CollectionAssert.AreEqual(extra,editor.extra);
                var restored=math.ReadProfiles(game,math.WriteProfiles(game,editor));
                Assert.IsTrue(restored.enabled);
                CollectionAssert.AreEqual(editor.extra,restored.extra);
            }
        }

        [TestMethod]
        public void MaryRejectsZeroOuterWeightsWithLegacyFlagOff()
        {
            var math=MathModel(); var c=math.Defaults(53);
            c.extra[0]=0; Array.Clear(c.extra,40,24);
            Reject(()=>math.Validate(53,c));
        }
    }
}
