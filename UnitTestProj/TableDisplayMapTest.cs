using System.Collections.Generic;
using System.Linq;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using YYT.BLL.EF;

namespace UnitTestProj
{
    [TestClass]
    public class TableDisplayMapTest
    {
        static TableDisplayMap.TableRow Table(int game, int index, int room = 0, string line = "", string name = "")
        {
            return new TableDisplayMap.TableRow { GameId = game, TableIndex = index, RoomIndex = room, LineAgent = line, TableName = name };
        }

        [TestMethod]
        public void PlayerRecordsKeepZeroBasedGlobalIndexesAndIgnoreNonGameOperations()
        {
            var map = new TableDisplayMap(new[] { Table(15, 24), Table(15, 25), Table(15, 30, 1),
                Table(15, 10, line: "#"), Table(3, 50, name: "贵宾桌"), Table(54, 0) }, new TableDisplayMap.RoomRow[0]);
            foreach (int operation in new[] { 2, 3, 7, 8 })
            {
                Assert.AreEqual("1", map.PlayerRecordLabel(15, 24, operation));
                Assert.AreEqual("2", map.PlayerRecordLabel(15, 25, operation));
                Assert.AreEqual("1", map.PlayerRecordLabel(15, 30, operation));
                Assert.AreEqual("贵宾桌", map.PlayerRecordLabel(3, 50, operation));
                Assert.AreEqual("--", map.PlayerRecordLabel(15, 10, operation));
                Assert.AreEqual("--", map.PlayerRecordLabel(54, 0, operation));
                Assert.AreEqual("--", map.PlayerRecordLabel(15, long.MaxValue, operation));
            }
            foreach (int operation in new[] { 0, 1, 4, 5, 6, -1 })
                Assert.AreEqual("--", map.PlayerRecordLabel(15, 24, operation));
        }

        [TestMethod]
        public void AllMachineSkinsCountVisibleTablesWithoutChangingRealIndexes()
        {
            foreach (int game in new[] { 5, 14, 15, 25, 37, 44, 55, 16, 40, 53 })
            {
                var rows = Enumerable.Range(0, 49).Select(i => Table(game, i, line: "#"))
                    .Concat(Enumerable.Range(49, 18).Select(i => Table(game, i, name: "人为桌名999"))).ToList();
                var map = new TableDisplayMap(rows, new TableDisplayMap.RoomRow[0]);
                Assert.AreEqual("1", map.OnlineLabel(game, 49));
                Assert.AreEqual("14", map.OnlineLabel(game, 62));
                Assert.AreEqual("18", map.OnlineLabel(game, 66));
                Assert.AreEqual("--", map.OnlineLabel(game, 48));
                Assert.AreEqual("--", map.OnlineLabel(game, 67));
                Assert.AreEqual(62, rows.Single(t => t.TableIndex == 62).TableIndex);
                Assert.AreEqual("14号机", map.HistoryMachine(game, TableDisplayMap.IsSlot(game) ? 3 : 1,
                    0, TableDisplayMap.IsSlot(game) ? 62 : 63, ""));
            }
        }

        [TestMethod]
        public void SparsePrivateTablesAndOtherRoomsHaveIndependentNumbers()
        {
            var rows = new[] { Table(15, 0, line: "#"), Table(15, 24), Table(15, 100, line: "A"),
                Table(15, 101, line: "B"), Table(15, 999, line: "A"), Table(15, 1000, 1), Table(15, 1009, 1) };
            var map = new TableDisplayMap(rows, new[] { new TableDisplayMap.RoomRow { GameId = 15, ID = 15000, TableCount = 1000 },
                new TableDisplayMap.RoomRow { GameId = 15, ID = 15001, TableCount = 10 } });
            Assert.AreEqual("1号机", map.HistoryMachine(15, 1, 0, 25, "player-line"));
            Assert.AreEqual("2", map.OnlineLabel(15, 999));
            Assert.AreEqual("2号机", map.HistoryMachine(15, 1, 0, 1000, "A"));
            Assert.AreEqual("--", map.HistoryMachine(15, 1, 0, 1000, "B"));
            Assert.AreEqual("2号机", map.HistoryMachine(15, 1, 1, 10, ""));
            Assert.AreEqual("--", map.HistoryMachine(15, 1, 2, 1, ""));
            Assert.AreEqual("--", map.HistoryMachine(15, 1, 0, 0, ""));
            Assert.AreEqual("--", map.HistoryMachine(15, 1, null, null, ""));
            Assert.AreEqual("--", map.HistoryMachine(15, 1, 0, long.MaxValue, ""));
        }

        [TestMethod]
        public void SlotHolesKeepTheirPositionsAndRespectOwnersWithoutConfigs()
        {
            var map = new TableDisplayMap(new[] { Table(40, 3), Table(40, 5, 1) }, new TableDisplayMap.RoomRow[0],
                new[] { new TableDisplayMap.OwnerRow { GameId = 40, TableIndex = 1, LineAgent = "#" },
                    new TableDisplayMap.OwnerRow { GameId = 40, TableIndex = 2, LineAgent = "A" } });
            Assert.AreEqual("4", map.OnlineLabel(40, 5));
            Assert.AreEqual("3", map.OnlineLabel(40, 4));
            Assert.AreEqual("1", map.OnlineLabel(40, 2));
            Assert.AreEqual("--", map.OnlineLabel(40, 1));
            Assert.AreEqual("4号机", map.HistoryMachine(40, 3, 1, 5, ""));
        }

        [TestMethod]
        public void SlotsIgnoreRoomTypeAndNamedTablesKeepSelectionLabels()
        {
            var map = new TableDisplayMap(new[] { Table(40, 3), Table(40, 5, 1), Table(3, 50, name: "金蟾VIP桌"),
                Table(2, 0, name: "9号机"), Table(47, 1, name: "普通场"), Table(54, 0) }, new TableDisplayMap.RoomRow[0]);
            Assert.AreEqual("6", map.OnlineLabel(40, 5));
            Assert.AreEqual("5", map.OnlineLabel(40, 4));
            Assert.AreEqual("金蟾VIP桌", map.OnlineLabel(3, 50));
            Assert.AreEqual("金蟾VIP桌", map.HistoryMachine(3, 2, 0, 51, ""));
            Assert.AreEqual("9号机", map.OnlineLabel(2, 0));
            Assert.AreEqual("普通场", map.OnlineLabel(47, 1));
            Assert.AreEqual("--", map.OnlineLabel(54, 0));
            Assert.AreEqual("--", map.OnlineLabel(0, 0));
            Assert.AreEqual("--", map.OnlineLabel(5, -1));
        }
    }
}
