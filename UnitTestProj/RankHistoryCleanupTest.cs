using System;
using System.IO;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using YYT.BLL.EF;

namespace UnitTestProj
{
    /// <summary>
    /// 系统设置 / 排行榜管理（2026-11-06）：勾选游戏编号解析、仅超管入口、只删排行表不删中奖明细、
    /// 残留每日清理接入定时任务且可见口径与客户端接口一致、视图 BOM。
    /// </summary>
    [TestClass]
    public class RankHistoryCleanupTest
    {
        private static DirectoryInfo FindRepoRoot()
        {
            DirectoryInfo dir = new DirectoryInfo(AppDomain.CurrentDomain.BaseDirectory);
            while (dir != null && !File.Exists(Path.Combine(dir.FullName, "MTH_Mgr_MySQL.sln")))
                dir = dir.Parent;
            Assert.IsNotNull(dir, "Cannot locate repository root.");
            return dir;
        }

        [TestMethod]
        public void ParseGameIdsAcceptsCheckedGamesOnly()
        {
            CollectionAssert.AreEqual(new[] { 5, 40, 55 }, RankHistoryCleanup.ParseGameIds(" 55,5,40,5 ,").ToArray());
            Assert.IsNull(RankHistoryCleanup.ParseGameIds(null));
            Assert.IsNull(RankHistoryCleanup.ParseGameIds(" , "));
            Assert.IsNull(RankHistoryCleanup.ParseGameIds("5,0"));
            Assert.IsNull(RankHistoryCleanup.ParseGameIds("5,-1"));
            Assert.IsNull(RankHistoryCleanup.ParseGameIds("5,1 OR 1=1"));
            Assert.IsNull(RankHistoryCleanup.ParseGameIds("5,99999999999"));
            var many = new System.Text.StringBuilder();
            for (int i = 1; i <= RankHistoryCleanup.MaxGamesPerRequest + 1; i++) many.Append(i).Append(',');
            Assert.IsNull(RankHistoryCleanup.ParseGameIds(many.ToString()));
        }

        [TestMethod]
        public void ParseLineSupportsAllPublicAndExistingAgentOnly()
        {
            var agents = new System.Collections.Generic.List<string> { "agentA", "agentB" };
            string error;
            Assert.IsNull(RankHistoryCleanup.ParseLine(null, agents, out error)); Assert.IsNull(error);
            Assert.IsNull(RankHistoryCleanup.ParseLine(" * ", agents, out error)); Assert.IsNull(error);
            Assert.AreEqual("", RankHistoryCleanup.ParseLine("~", agents, out error)); Assert.IsNull(error);
            Assert.AreEqual("agentB", RankHistoryCleanup.ParseLine(" agentB ", agents, out error)); Assert.IsNull(error);
            Assert.IsNull(RankHistoryCleanup.ParseLine("ghost", agents, out error));
            Assert.IsNotNull(error, "不存在的代理线必须报错，不能退回全部代理线");
            Assert.IsNull(RankHistoryCleanup.ParseLine("#", agents, out error));
            Assert.IsNotNull(error, "收回标记 # 不是可选代理线");
        }

        [TestMethod]
        public void ClearOnlyTouchesRankTableAndPageIsSuperAdmin()
        {
            DirectoryInfo root = FindRepoRoot();
            string bll = File.ReadAllText(Path.Combine(root.FullName, "YYT.BLL", "EF", "RankHistoryCleanup.cs"));
            StringAssert.Contains(bll, "DELETE FROM gamerankhistory WHERE GameId IN (");
            Assert.IsFalse(bll.Contains("DELETE FROM gameprizerecord"), "排行榜清理不能删除中奖明细");
            StringAssert.Contains(bll, "DELETE h FROM gamerankhistory h LEFT JOIN games g");
            StringAssert.Contains(bll, ".HistoryVisibilitySql(line, types)");
            string global = File.ReadAllText(Path.Combine(root.FullName, "TTY.Web", "Global.asax.cs"));
            StringAssert.Contains(global, "RankHistoryCleanup.CleanupResidualDaily();");
            string api = File.ReadAllText(Path.Combine(root.FullName, "TTY.Web", "Controllers", "Api", "RankingListController.cs"));
            StringAssert.Contains(api, "g.Enable == 1");
            StringAssert.Contains(api, "g.GameId != 54");
            StringAssert.Contains(api, "h.IsBigWin=1 AND h.Score>=0");
            StringAssert.Contains(api, "HistoryVisibilitySql(line, types)");
            string controller = File.ReadAllText(Path.Combine(root.FullName, "TTY.Web", "Areas", "Game", "Controllers", "RankingManageController.cs"));
            StringAssert.Contains(controller, "[SuperAdminAuthorize]");
            StringAssert.Contains(controller, "[ValidateAntiForgeryToken]");
            string menu = File.ReadAllText(Path.Combine(root.FullName, "TTY.Web", "Views", "Mgr", "Index.cshtml"));
            StringAssert.Contains(menu, "\"RankingManage\"");
            StringAssert.Contains(menu, "排行榜管理");
            byte[] view = File.ReadAllBytes(Path.Combine(root.FullName, "TTY.Web", "Areas", "Game", "Views", "RankingManage", "Index.cshtml"));
            Assert.IsTrue(view.Length > 3 && view[0] == 0xEF && view[1] == 0xBB && view[2] == 0xBF, "cshtml 必须 UTF-8 BOM");
        }
    }
}
