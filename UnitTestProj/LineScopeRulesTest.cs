using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text.RegularExpressions;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using YYT.BLL.EF;

namespace UnitTestProj
{
    /// <summary>
    /// 多客户端包与代理线隔离（2026-10-30）：可玩游戏解析、所属线查找、专属桌台规划与各端口径一致性。
    /// </summary>
    [TestClass]
    public class LineScopeRulesTest
    {
        private static DirectoryInfo FindRepoRoot()
        {
            DirectoryInfo dir = new DirectoryInfo(AppDomain.CurrentDomain.BaseDirectory);
            while (dir != null && !File.Exists(Path.Combine(dir.FullName, "MTH_Mgr_MySQL.sln")))
                dir = dir.Parent;
            Assert.IsNotNull(dir, "Cannot locate repository root.");
            return dir;
        }

        private static string ReadRepoFile(string relativePath)
        {
            return File.ReadAllText(Path.Combine(FindRepoRoot().FullName, relativePath));
        }

        [TestMethod]
        public void PlayableGamesParseLikeCenterServer()
        {
            Assert.IsNull(LineScopeRules.ParsePlayableGames(null));
            Assert.IsNull(LineScopeRules.ParsePlayableGames(""));
            Assert.IsNull(LineScopeRules.ParsePlayableGames(" , ,"));
            Assert.IsNull(LineScopeRules.ParsePlayableGames("0,70000"));
            CollectionAssert.AreEqual(new List<int> { 5, 37, 54 }, LineScopeRules.ParsePlayableGames("5,37,54"));
            CollectionAssert.AreEqual(new List<int> { 5, 37 }, LineScopeRules.ParsePlayableGames(" 5，a37;5 "));
            Assert.AreEqual("5,37,54", LineScopeRules.FormatPlayableGames(new[] { 54, 5, 37, 5, 0 }));
            Assert.IsNull(LineScopeRules.FormatPlayableGames(new int[0]));
            Assert.IsTrue(LineScopeRules.IsGameAllowed(null, 99));
            Assert.IsTrue(LineScopeRules.IsGameAllowed(new List<int> { 5 }, 5));
            Assert.IsFalse(LineScopeRules.IsGameAllowed(new List<int> { 5 }, 37));
        }

        [TestMethod]
        public void PlayableSelectionRequiresAtLeastOneEnabledGame()
        {
            string csv;
            Assert.IsNotNull(LineScopeRules.ValidatePlayableSelection("", new[] { 5, 37 }, out csv));
            Assert.IsNull(csv);
            StringAssert.Contains(LineScopeRules.ValidatePlayableSelection("5,99", new[] { 5, 37 }, out csv), "99");
            Assert.IsNull(LineScopeRules.ValidatePlayableSelection("37,5", new[] { 5, 37 }, out csv));
            Assert.AreEqual("5,37", csv);
        }

        [TestMethod]
        public void LineIsFirstDirectAgentUpTheChain()
        {
            var admins = new Dictionary<string, LineScopeRules.AgencyNode>(StringComparer.OrdinalIgnoreCase)
            {
                { "atmadmin", new LineScopeRules.AgencyNode("atmadmin", "", 0) },
                { "lineA", new LineScopeRules.AgencyNode("lineA", "atmadmin", 1) },
                { "a2", new LineScopeRules.AgencyNode("a2", "lineA", 2) },
                { "a3", new LineScopeRules.AgencyNode("a3", "a2", 3) },
                { "loop", new LineScopeRules.AgencyNode("loop", "loop", 4) }
            };
            Func<string, LineScopeRules.AgencyNode> lookup = id => admins.ContainsKey(id) ? admins[id] : null;
            Assert.AreEqual("lineA", LineScopeRules.ResolveLine("a3", lookup));
            Assert.AreEqual("lineA", LineScopeRules.ResolveLine("lineA", lookup));
            Assert.AreEqual("", LineScopeRules.ResolveLine("atmadmin", lookup), "直属超管的玩家不属于任何线");
            Assert.AreEqual("", LineScopeRules.ResolveLine("missing", lookup));
            Assert.AreEqual("", LineScopeRules.ResolveLine("loop", lookup));
            Assert.AreEqual("", LineScopeRules.ResolveLine("", lookup));
        }

        [TestMethod]
        public void TableListFollowsOwnerTable()
        {
            var owners = new Dictionary<int, string> { { 3, "lineA" }, { 4, "lineA" }, { 5, "#" }, { 6, "lineB" } };
            Assert.IsTrue(LineScopeRules.TableBelongsTo(owners, 0, ""));
            Assert.IsFalse(LineScopeRules.TableBelongsTo(owners, 3, ""));
            Assert.IsFalse(LineScopeRules.TableBelongsTo(owners, 5, ""), "已收回的桌公共视图不列");
            Assert.IsFalse(LineScopeRules.TableBelongsTo(owners, 5, "lineA"));
            Assert.IsTrue(LineScopeRules.TableBelongsTo(owners, 4, "linea"));
            Assert.IsFalse(LineScopeRules.TableBelongsTo(owners, 6, "lineA"));
            Assert.IsFalse(LineScopeRules.TableBelongsTo(owners, 0, "lineA"));
        }

        [TestMethod]
        public void ExclusiveTablesReuseRecycledThenAppend()
        {
            CollectionAssert.AreEqual(new List<int> { 13, 14, 15 }, LineTables.PlanTargetIndexes(3, null, 12));
            CollectionAssert.AreEqual(new List<int> { 4, 9, 13 }, LineTables.PlanTargetIndexes(3, new[] { 9, 4 }, 12));
            CollectionAssert.AreEqual(new List<int> { 4 }, LineTables.PlanTargetIndexes(1, new[] { 9, 4 }, 12));
            Assert.IsNull(LineTables.PlanTargetIndexes(3, null, 253), "不能超过 256 桌");
            Assert.IsNotNull(LineTables.PlanTargetIndexes(2, null, 253));
        }

        [TestMethod]
        public void PerTableSpecsCoverEveryDeletedTable()
        {
            // 删除桌台时按桌清理的表，复制专属桌台时必须同样复制，否则新桌缺参数
            string controller = ReadRepoFile(@"TTY.Web\Areas\Game\Controllers\GameConfigController.cs");
            string laba = ReadRepoFile(@"YYT.BLL\EF\shit\B_LabaGamePara.cs");
            var specs = new[] { 0, 1, 2, 3 }.SelectMany(t => LineTables.PerTableSpecs(t)).Select(s => s.Table.ToLowerInvariant()).ToList();
            foreach (Match m in Regex.Matches(controller + laba, @"DELETE FROM (\w+) WHERE GAME_ID", RegexOptions.IgnoreCase))
            {
                string table = m.Groups[1].Value.ToLowerInvariant();
                if (table == "pararoom" || table == "parabetroom") continue;
                CollectionAssert.Contains(specs, table, "复制专属桌台漏了按桌表 " + table);
            }
            StringAssert.Contains(controller, "LineTables.OnTableDeleted(efCard, cardGid, delIdx);");
            StringAssert.Contains(controller, "LineTables.OnTableDeleted(ef2, fishGid, delTableIdx);");
            StringAssert.Contains(controller, "LineTables.OnTableDeleted(efBet, betGid, delIdx);");
            StringAssert.Contains(laba, "LineTables.OnTableDeleted(ef, gameId, tableIndex);");
        }

        [TestMethod]
        public void CardActionMappingMatchesCenterServerAndPages()
        {
            var expected = new Dictionary<int, int> { { 5, 15 }, { 7, 37 }, { 8, 25 }, { 12, 14 }, { 13, 44 }, { 14, 5 }, { 15, 53 }, { 16, 16 }, { 17, 40 }, { 19, 54 }, { 20, 55 } };
            foreach (var kv in expected)
                Assert.AreEqual(kv.Value, LineScopeRules.CardActionToGameId(kv.Key));
            Assert.AreEqual(0, LineScopeRules.CardActionToGameId(18));

            const string jsMap = "{ 5: 15, 7: 37, 8: 25, 12: 14, 13: 44, 14: 5, 15: 53, 16: 16, 17: 40, 19: 54, 20: 55 }";
            StringAssert.Contains(ReadRepoFile(@"TTY.Web\Views\Shared\Layout\_ContentLayout.cshtml"), jsMap);
            StringAssert.Contains(ReadRepoFile(@"TTY.Web\Scripts\app\phone\phone.core.js"), jsMap);
            StringAssert.Contains(ReadRepoFile(@"TTY.Web\Areas\Game\Views\UserInfo\Index.cshtml"), "return window.mthFilterCardActions([");
            StringAssert.Contains(ReadRepoFile(@"TTY.Web\Areas\Game\Views\UserInfo\OnlineUsers.cshtml"), "return window.mthFilterCardActions([");
            StringAssert.Contains(ReadRepoFile(@"TTY.Web\Scripts\app\phone\phone.control.js"), "M.playableCardActions(M.CARD_ACTIONS)");

            // 服务端仓库与后台同级（MTH/MTH-Server）时与中心服 cardActionToGameId 逐项比对；不在此布局则跳过
            string center = Path.Combine(FindRepoRoot().Parent.FullName, @"MTH-Server\ServerCenterNew\ServerCenterRun.cpp");
            if (File.Exists(center))
            {
                string text = File.ReadAllText(center);
                int start = text.IndexOf("int ServerCenterRun::cardActionToGameId(int cardAction)", StringComparison.Ordinal);
                Assert.IsTrue(start >= 0);
                string body = text.Substring(start, text.IndexOf("default:", start, StringComparison.Ordinal) - start);
                var pairs = Regex.Matches(body, @"case (\d+):\s*return (\d+);").Cast<Match>()
                    .ToDictionary(m => int.Parse(m.Groups[1].Value), m => int.Parse(m.Groups[2].Value));
                CollectionAssert.AreEquivalent(expected.ToList(), pairs.ToList());
            }
        }

        [TestMethod]
        public void ClientPackageKeyRules()
        {
            Assert.IsNull(ClientPackages.Validate("默认包", ClientPackages.LegacyAppKey));
            Assert.IsNotNull(ClientPackages.Validate("", "abcdef"));
            Assert.IsNotNull(ClientPackages.Validate("包", "abc"));
            Assert.IsNotNull(ClientPackages.Validate("包", "abc-def"));
            Assert.IsNotNull(ClientPackages.Validate("包", new string('a', 33)));
        }

        [TestMethod]
        public void ApisFilterByAccountOnlyWhenNewClientSendsIt()
        {
            string games = ReadRepoFile(@"TTY.Web\Controllers\Api\GamesController.cs");
            StringAssert.Contains(games, "public IEnumerable<M_Games> Get(string account = null)");
            StringAssert.Contains(games, "LineScopeRules.GetPlayableGamesOfPlayer(ef, account.Trim())");
            string rank = ReadRepoFile(@"TTY.Web\Controllers\Api\RankingListController.cs");
            StringAssert.Contains(rank, "public IHttpActionResult History(int gameId = 0, string account = null)");
            StringAssert.Contains(rank, "h.LineAgent='' OR h.LineAgent=@p1");
            string agency = ReadRepoFile(@"TTY.Web\Areas\Game\Controllers\AgencyInfoController.cs");
            StringAssert.Contains(agency, "bool needPlayable = loginUser.UserPriv == 0 && entity.PRIV == 1;");
            string control = ReadRepoFile(@"TTY.Web\Areas\Game\Controllers\UserInfoController.cs");
            StringAssert.Contains(control, "该玩家所在代理线不能玩此游戏，无法控牌！");
        }
    }
}
