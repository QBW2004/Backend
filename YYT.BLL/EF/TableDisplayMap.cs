using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;

namespace YYT.BLL.EF
{
    /// <summary>选桌展示与业务桌号分离；仅映射显示，不修改在线状态或中奖明细。</summary>
    public sealed class TableDisplayMap
    {
        public sealed class TableRow
        {
            public int GameId { get; set; }
            public int RoomIndex { get; set; }
            public int TableIndex { get; set; }
            public string TableName { get; set; }
            public string LineAgent { get; set; }
        }

        public sealed class RoomRow
        {
            public int GameId { get; set; }
            public int ID { get; set; }
            public int TableCount { get; set; }
        }

        public sealed class OwnerRow
        {
            public int GameId { get; set; }
            public int TableIndex { get; set; }
            public string LineAgent { get; set; }
        }

        readonly Dictionary<string, TableRow> mTables;
        readonly Dictionary<string, string> mLabels;
        readonly Dictionary<int, List<RoomRow>> mRooms;

        public TableDisplayMap(IEnumerable<TableRow> tables, IEnumerable<RoomRow> rooms, IEnumerable<OwnerRow> owners = null)
        {
            mTables = tables.GroupBy(t => Key(t.GameId, t.TableIndex)).ToDictionary(g => g.Key, g => g.First());
            mRooms = rooms.GroupBy(r => r.GameId).ToDictionary(g => g.Key, g => g.OrderBy(r => r.ID).ToList());
            // CollectTableEntries 保留 0..最大下标间的缺号位置；这些位置也参与选桌序号。
            foreach (var game in mTables.Values.Where(t => IsSlot(t.GameId) && t.TableIndex < 1000).GroupBy(t => t.GameId).ToList())
                for (int i = 0, last = game.Max(t => t.TableIndex); i <= last; i++)
                    if (!mTables.ContainsKey(Key(game.Key, i)))
                        mTables.Add(Key(game.Key, i), new TableRow { GameId = game.Key, TableIndex = i });
            foreach (var owner in owners ?? new OwnerRow[0])
            {
                TableRow table;
                if (mTables.TryGetValue(Key(owner.GameId, owner.TableIndex), out table)) table.LineAgent = owner.LineAgent;
            }
            mLabels = new Dictionary<string, string>();
            // 与 SourceTableSkin/原生选桌列表一致：回收桌排除，停用但仍列出的桌继续占序号。
            foreach (var group in mTables.Values.Where(t => t.LineAgent != LineScopeRules.RecycledLine)
                .GroupBy(t => new { t.GameId, Room = IsSlot(t.GameId) ? 0 : t.RoomIndex, Line = t.LineAgent ?? "" }))
            {
                int ordinal = 0;
                foreach (TableRow table in group.OrderBy(t => t.TableIndex))
                {
                    ordinal++;
                    string label = UsesOrdinal(table.GameId) || string.IsNullOrEmpty(table.TableName)
                        ? ordinal.ToString(CultureInfo.InvariantCulture) : table.TableName;
                    mLabels[Key(table.GameId, table.TableIndex)] = table.GameId == 54 ? "--" : label;
                }
            }
        }

        public static TableDisplayMap Load(GameDbContext db, IEnumerable<int> gameIds)
        {
            string ids = string.Join(",", gameIds.Where(id => id > 0).Distinct().OrderBy(id => id));
            if (ids.Length == 0) return new TableDisplayMap(new TableRow[0], new RoomRow[0]);
            var tables = db.Database.SqlQuery<TableRow>(
                "SELECT GAME_ID AS GameId,RoomIndex,TableIndex,TableName,'' AS LineAgent " +
                "FROM roomtableconfig WHERE GAME_ID IN (" + ids + ")").ToList();
            var owners = LineTables.OwnerTableExists(db) ? db.Database.SqlQuery<OwnerRow>(
                "SELECT GAME_ID AS GameId,TableIndex,IFNULL(LineAgent,'') AS LineAgent FROM roomtableowner WHERE GAME_ID IN (" + ids + ")").ToList()
                : new List<OwnerRow>();
            var rooms = db.Database.SqlQuery<RoomRow>(
                "SELECT GAME_ID AS GameId,ID,IFNULL(NUM,0) AS TableCount FROM pararoom WHERE GAME_ID IN (" + ids + ")").ToList();
            return new TableDisplayMap(tables, rooms, owners);
        }

        public string OnlineLabel(int gameId, int tableIndex)
        {
            string label;
            return gameId > 0 && tableIndex >= 0 && mLabels.TryGetValue(Key(gameId, tableIndex), out label) ? label : "--";
        }

        /// <summary>进出桌日志使用0基全局下标，与原生中奖的房间内1基编号不同。</summary>
        public string PlayerRecordLabel(int gameId, long tableIndex, int operation)
        {
            if ((operation != 2 && operation != 3 && operation != 7 && operation != 8)
                || tableIndex < 0 || tableIndex > ushort.MaxValue) return "--";
            return OnlineLabel(gameId, (int)tableIndex);
        }

        public string HistoryMachine(int gameId, int gameType, long? roomId, long? tableId, string recordLine)
        {
            int? index = HistoryTableIndex(gameId, gameType, roomId, tableId, recordLine);
            if (!index.HasValue) return "--";
            string label = OnlineLabel(gameId, index.Value);
            int number;
            return int.TryParse(label, NumberStyles.None, CultureInfo.InvariantCulture, out number)
                ? label + "号机" : label;
        }

        /// <summary>还原中奖事件的真实桌索引，供播报检查占用；不把展示序号当作业务桌号。</summary>
        public int? HistoryTableIndex(int gameId, int gameType, long? roomId, long? tableId, string recordLine)
        {
            if (!roomId.HasValue || roomId < 0 || roomId > ushort.MaxValue || !tableId.HasValue
                || tableId < 0 || tableId > ushort.MaxValue || gameId == 54) return null;
            long index = tableId.Value;
            bool roomLocal = gameType == 1 || gameType == 2;
            if (roomLocal)
            {
                if (index == 0) return null;
                index--;
                if (roomId > 0)
                {
                    List<RoomRow> rooms;
                    if (!mRooms.TryGetValue(gameId, out rooms) || roomId >= rooms.Count) return null;
                    index += rooms.Take((int)roomId.Value).Sum(r => (long)r.TableCount);
                }
            }
            if (index > ushort.MaxValue) return null;
            TableRow table;
            if (!mTables.TryGetValue(Key(gameId, (int)index), out table)
                || (roomLocal && table.RoomIndex != roomId)
                || (!string.IsNullOrEmpty(table.LineAgent) && table.LineAgent != (recordLine ?? ""))
                || OnlineLabel(gameId, (int)index) == "--") return null;
            return (int)index;
        }

        /// <summary>与选桌一致：本线有专属桌时只看本线桌，否则只看公共桌，避免不同实际桌同号。</summary>
        public bool IsVisible(int gameId, int tableIndex, string viewerLine)
        {
            TableRow table;
            if (!mTables.TryGetValue(Key(gameId, tableIndex), out table)
                || table.LineAgent == LineScopeRules.RecycledLine) return false;
            string line = viewerLine ?? "";
            bool privateTables = line.Length > 0 && mTables.Values.Any(t => t.GameId == gameId && t.LineAgent == line);
            return (table.LineAgent ?? "") == (privateTables ? line : "");
        }

        /// <summary>将实际可见桌映射成历史协议坐标，在 SQL 的 LIMIT 前过滤；这里只拼配置整数，代理值仍用参数。</summary>
        public string HistoryVisibilitySql(string viewerLine, IDictionary<int, int> gameTypes)
        {
            var clauses = new List<string>();
            string line = viewerLine ?? "";
            var privateGames = new HashSet<int>(mTables.Values.Where(t => line.Length > 0 && t.LineAgent == line).Select(t => t.GameId));
            var visible = mTables.Values.Where(t => gameTypes.ContainsKey(t.GameId) && t.LineAgent != LineScopeRules.RecycledLine
                && (t.LineAgent ?? "") == (privateGames.Contains(t.GameId) ? line : ""));
            foreach (var group in visible.GroupBy(t => new { t.GameId,
                Room = gameTypes[t.GameId] == 1 || gameTypes[t.GameId] == 2 ? t.RoomIndex : 0 }))
            {
                bool slot = gameTypes[group.Key.GameId] != 1 && gameTypes[group.Key.GameId] != 2;
                long offset = 0;
                if (!slot && group.Key.Room > 0)
                {
                    List<RoomRow> rooms;
                    if (!mRooms.TryGetValue(group.Key.GameId, out rooms) || group.Key.Room >= rooms.Count) continue;
                    offset = rooms.Take(group.Key.Room).Sum(r => (long)r.TableCount);
                }
                var ids = group.Select(t => slot ? (long)t.TableIndex : t.TableIndex - offset + 1)
                    .Where(i => i >= (slot ? 0 : 1) && i <= ushort.MaxValue).OrderBy(i => i).ToList();
                if (ids.Count == 0) continue;
                string room = slot ? " AND COALESCE(h.RoomId,p.RoomId) BETWEEN 0 AND 65535" : " AND COALESCE(h.RoomId,p.RoomId)=" + group.Key.Room;
                // 专属桌历史还需匹配写入时归属，防止收回后重新分配同一真实桌号时串入其他线旧记录。
                string owner = string.IsNullOrEmpty(group.First().LineAgent) ? "" : " AND h.LineAgent=@p1";
                clauses.Add("(h.GameId=" + group.Key.GameId + room + " AND COALESCE(h.TableId,p.TableId) IN ("
                    + string.Join(",", ids) + ")" + owner + ")");
            }
            return clauses.Count == 0 ? " AND 1=0" : " AND (" + string.Join(" OR ", clauses) + ")";
        }

        static string Key(int gameId, int tableIndex) { return gameId + "|" + tableIndex; }
        public static bool IsSlot(int gameId) { return gameId == 16 || gameId == 40 || gameId == 53; }
        public static bool UsesOrdinal(int gameId)
        {
            switch (gameId)
            {
                case 5: case 14: case 15: case 25: case 37: case 44: case 55:
                case 16: case 40: case 53: return true;
                default: return false;
            }
        }
    }
}
