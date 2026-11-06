using System;
using System.Linq;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using YYT.BLL.EF;
using YYT.BLL.Services.GameServer;

namespace UnitTestProj
{
    [TestClass]
    public class AnnouncementRulesTest
    {
        [TestMethod]
        public void DisconnectedGameAndUnknownCenterCannotLookLikeAnEmptyTable()
        {
            Assert.IsNull(PipeGameServerClient.ParseAnnouncementOccupants("[]", 5));
            Assert.IsNull(PipeGameServerClient.ParseAnnouncementOccupants("unknown command", 5));
            Assert.IsNull(PipeGameServerClient.ParseAnnouncementOccupants("{}", 5));
            Assert.IsNull(PipeGameServerClient.ParseAnnouncementOccupants("{\"Version\":1,\"AvailableGames\":[40],\"Players\":[]}", 5));
            Assert.IsNull(PipeGameServerClient.ParseAnnouncementOccupants("{\"Version\":1,\"AvailableGames\":[5]}", 5));
            Assert.AreEqual(0, PipeGameServerClient.ParseAnnouncementOccupants("{\"Version\":1,\"AvailableGames\":[5],\"Players\":[]}", 5).Count);
            var players = PipeGameServerClient.ParseAnnouncementOccupants("{\"Version\":1,\"AvailableGames\":[5],\"Players\":[{\"GameID\":5,\"TableId\":62,\"IsSitDown\":true}]}", 5);
            Assert.IsFalse(AnnouncementRules.Check(Record(), Map(), "", players).Play);
        }

        const string Text = "恭喜玩家【机器人名字】在【火凤凰】【63】机台，打中【五鬼】，获得【80000分】，再次表示祝贺！";
        static AnnouncementRules.Record Record(int game = 5)
        {
            return new AnnouncementRules.Record { GameId = game, GameType = TableDisplayMap.IsSlot(game) ? 3 : 1,
                RoomId = 0, TableId = TableDisplayMap.IsSlot(game) ? 62 : 63, IsRobot = 1, LineAgent = "", Text = Text, AgeSeconds = 2 };
        }
        static TableDisplayMap Map(int game = 5)
        {
            return new TableDisplayMap(Enumerable.Range(0, 67).Select(i => new TableDisplayMap.TableRow {
                GameId = game, TableIndex = i, RoomIndex = 0, LineAgent = i < 49 ? "#" : "" }), new TableDisplayMap.RoomRow[0]);
        }
        static OnlinePlayerInfo Player(int table, bool? sitting = true, int game = 5)
        {
            return new OnlinePlayerInfo { GameID = game, TableId = table, IsSitDown = sitting };
        }

        [TestMethod]
        public void EveryRobotGameRejectsRealOccupantAndAllowsVacantActualTable()
        {
            foreach (int game in new[] { 5, 15, 25, 37, 44, 55, 16, 40, 53 })
            {
                var record = Record(game); var map = Map(game);
                Assert.IsFalse(AnnouncementRules.Check(record, map, "", new[] { Player(62, game: game) }).Play);
                Assert.IsTrue(AnnouncementRules.Check(record, map, "", new OnlinePlayerInfo[0]).Play);
                Assert.IsTrue(AnnouncementRules.Check(record, map, "", new[] { Player(14, game: game), Player(63, game: game) }).Play);
                Assert.IsTrue(AnnouncementRules.Check(record, map, "", new[] { Player(62, false, game) }).Play);
                Assert.IsTrue(AnnouncementRules.Check(record, map, "", new[] { Player(62, game: 99) }).Play);
                Assert.IsFalse(AnnouncementRules.Check(record, map, "", null).Play);
                Assert.IsFalse(AnnouncementRules.Check(record, map, "", new[] { Player(62, null, game) }).Play);
                StringAssert.Contains(AnnouncementRules.Check(record, map, "", new OnlinePlayerInfo[0]).Content, "】【14】机台");
            }
        }

        [TestMethod]
        public void QueuedNoticeChecksLatestOccupancyEveryTimeWithoutChangingEvent()
        {
            var record = Record(); var map = Map();
            Assert.IsTrue(AnnouncementRules.Check(record, map, "", new OnlinePlayerInfo[0]).Play);
            Assert.IsFalse(AnnouncementRules.Check(record, map, "", new[] { Player(62) }).Play);
            Assert.IsTrue(AnnouncementRules.Check(record, map, "", new OnlinePlayerInfo[0]).Play);
            Assert.AreEqual(Text, record.Text);
            Assert.AreEqual(63L, record.TableId);
            record.IsRobot = 0;
            Assert.IsTrue(AnnouncementRules.Check(record, map, "", new[] { Player(62) }).Play);
        }

        [TestMethod]
        public void PublicHumanUsesPublicTablesInsteadOfPlayersAgency()
        {
            var record = Record(); record.IsRobot = 0; record.LineAgent = "other";
            Assert.IsTrue(AnnouncementRules.Check(record, Map(), "mo", null).Play);
            var privateMap = new TableDisplayMap(new[] {
                new TableDisplayMap.TableRow { GameId = 5, TableIndex = 62 },
                new TableDisplayMap.TableRow { GameId = 5, TableIndex = 70, LineAgent = "mo" }
            }, new TableDisplayMap.RoomRow[0]);
            Assert.IsFalse(AnnouncementRules.Check(record, privateMap, "mo", null).Play);
            record.TableId = 71; record.LineAgent = "mo";
            Assert.IsTrue(AnnouncementRules.Check(record, privateMap, "mo", null).Play);
            Assert.IsFalse(AnnouncementRules.Check(record, privateMap, "other", null).Play);
        }

        [TestMethod]
        public void SameVisibleNumberOnAnotherLineCannotMasqueradeAsViewersTable()
        {
            var rows = new[] { new TableDisplayMap.TableRow { GameId = 5, TableIndex = 0 },
                new TableDisplayMap.TableRow { GameId = 5, TableIndex = 62, LineAgent = "A" },
                new TableDisplayMap.TableRow { GameId = 5, TableIndex = 63, LineAgent = "B" } };
            var map = new TableDisplayMap(rows, new TableDisplayMap.RoomRow[0]);
            var record = Record(); record.TableId = 1;
            Assert.IsFalse(AnnouncementRules.Check(record, map, "A", new OnlinePlayerInfo[0]).Play);
            Assert.IsTrue(AnnouncementRules.Check(record, map, "C", new OnlinePlayerInfo[0]).Play);
            record.TableId = 63; record.LineAgent = "A";
            Assert.IsFalse(AnnouncementRules.Check(record, map, "B", new OnlinePlayerInfo[0]).Play);
            Assert.IsTrue(AnnouncementRules.Check(record, map, "A", new[] { Player(63) }).Play);
            Assert.IsFalse(AnnouncementRules.Check(record, map, "A", new[] { Player(62) }).Play);
        }

        [TestMethod]
        public void UnknownRecycledExpiredAndMalformedEventsFailClosed()
        {
            var record = Record(); var map = Map(); var empty = new OnlinePlayerInfo[0];
            Assert.IsFalse(AnnouncementRules.Check(null, map, "", empty).Play);
            record.TableId = 1; Assert.IsFalse(AnnouncementRules.Check(record, map, "", empty).Play);
            record.TableId = 1000; Assert.IsFalse(AnnouncementRules.Check(record, map, "", empty).Play);
            record.TableId = 63; record.AgeSeconds = 301; Assert.IsFalse(AnnouncementRules.Check(record, map, "", empty).Play);
            record.AgeSeconds = -1; Assert.IsFalse(AnnouncementRules.Check(record, map, "", empty).Play);
            record.AgeSeconds = 300; Assert.IsTrue(AnnouncementRules.Check(record, map, "", empty).Play);
            record.Text = "无法还原的旧文本"; Assert.IsFalse(AnnouncementRules.Check(record, map, "", empty).Play);
            string longText = new string('中', 180);
            Assert.AreEqual(new string('中', 166), AnnouncementRules.WireText(longText));
        }
    }
}
