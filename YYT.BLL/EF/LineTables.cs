using System;
using System.Collections.Generic;
using System.Linq;
using YYT.Entity;

namespace YYT.BLL.EF
{
    /// <summary>
    /// 按线的专属桌台（2026-10-30）：归属只记在 roomtableowner(GAME_ID, RoomIndex, TableIndex, LineAgent)，
    /// 没有记录的桌就是公共桌台；其余按桌存的表结构一律不动，专属桌台就是同一游戏里接在后面的普通桌号。
    /// ⚠ 公共桌台必须保持 0~N-1 连续（老包按连续位置取配置），所以专属桌号一律接在现有最大桌号之后，
    ///   删除桌台时归属表要跟着各按桌表一起把高位桌号左移（见 OnTableDeleted）。
    /// 中心服每次 RP/PC 都会把本表下发给子游戏（COM_TABLE_OWNER），所以这里改完必须触发 RP 热更。
    /// </summary>
    public static class LineTables
    {
        /// <summary>押注/鱼机每款游戏桌台上限（MTH-Server Common/CommST.h MAX_TABLES，未定义 MTH_TABLES_EXTENDED；11 款鱼机内部桌号为 UInt8）。</summary>
        public const int MaxTables = 256;

        /// <summary>
        /// 牌机/拉霸每款游戏桌台上限（2026-11-05）：服务端这两类工程定义 MTH_TABLES_EXTENDED，MAX_TABLES=1000，
        /// 超长扩展参数由中心服分片下发；后台桌台主键按 gameId*1000+桌号 编码（桌号 0～999），客户端牌机选桌数组也是 1000。
        /// </summary>
        public const int ExtendedMaxTables = 1000;

        /// <summary>按参数口径（0 押注 / 1 牌机 / 2 鱼机 / 3 拉霸）取桌台上限。</summary>
        public static int MaxTablesFor(int paraType)
        {
            return paraType == 1 || paraType == 3 ? ExtendedMaxTables : MaxTables;
        }

        /// <summary>按桌复制时一张表的定位方式：GameCol=游戏列；IndexCol=桌号列；IdCol=按 gameId*1000+桌号 编码的主键列。</summary>
        public class CloneSpec
        {
            public CloneSpec(string table, string gameCol, string indexCol, string idCol)
            {
                Table = table;
                GameCol = gameCol;
                IndexCol = indexCol;
                IdCol = idCol;
            }

            public string Table { get; private set; }
            public string GameCol { get; private set; }
            public string IndexCol { get; private set; }
            public string IdCol { get; private set; }
        }

        public class OwnerRow
        {
            public int TableIndex { get; set; }
            public string LineAgent { get; set; }
        }

        private class ColumnRow
        {
            public string COLUMN_NAME { get; set; }
            public string EXTRA { get; set; }
        }

        /// <summary>
        /// 各参数口径（paraType：0 押注 / 1 牌机 / 2 鱼机 / 3 拉霸含麻将胡了）下“按桌存”的全部表，
        /// 与 GameConfigController.DeleteTableConfig / B_LabaGamePara.DeleteTable 删除时清理的表一一对应；那边新增按桌表时这里同步加。
        /// </summary>
        public static List<CloneSpec> PerTableSpecs(int paraType)
        {
            List<CloneSpec> specs = new List<CloneSpec>
            {
                new CloneSpec("roomtableconfig", "GAME_ID", "TableIndex", null),
                new CloneSpec("robot_seat", "GAME_ID", "TABLE_ID", null)
            };
            switch (paraType)
            {
                case 0:
                    specs.Add(new CloneSpec("roomtableconfig_bet", "GAME_ID", "TableIndex", null));
                    specs.Add(new CloneSpec("parabet", "GAME_ID", null, "ID"));
                    specs.Add(new CloneSpec("cardpayoutprofile", "GAME_ID", "TableId", null));
                    specs.Add(new CloneSpec("betgamecfg", "GAME_ID", "TableIndex", null));
                    break;
                case 1:
                    specs.Add(new CloneSpec("cardgamecfg", "GAME_ID", "TableIndex", null));
                    specs.Add(new CloneSpec("roomtableconfig_card", "GAME_ID", "TableIndex", null));
                    specs.Add(new CloneSpec("paracard", "GAME_ID", null, "ID"));
                    specs.Add(new CloneSpec("cardpayoutprofile", "GAME_ID", "TableId", null));
                    break;
                case 2:
                    specs.Add(new CloneSpec("parafish", "GAME_ID", "TableIndex", "ID"));
                    break;
                case 3:
                    specs.Add(new CloneSpec("paralaba", "GAME_ID", "TableIndex", "ID"));
                    specs.Add(new CloneSpec("gameconfiglaba", "GameId", "TableIndex", null));
                    specs.Add(new CloneSpec("roomtableconfig_bet", "GAME_ID", "TableIndex", null));
                    specs.Add(new CloneSpec("cardpayoutprofile", "GAME_ID", "TableId", null));
                    break;
            }
            return specs;
        }

        /// <summary>
        /// 纯函数：本次给某线分配的目标桌号。先按升序复用已收回(#)的桌号，不够再从 maxIndex+1 往后接；超过上限返回 null。
        /// </summary>
        public static List<int> PlanTargetIndexes(int count, IEnumerable<int> recycled, int maxIndex, int maxTables = MaxTables)
        {
            List<int> result = new List<int>();
            foreach (int idx in (recycled ?? new int[0]).Distinct().OrderBy(i => i))
            {
                if (result.Count >= count) break;
                result.Add(idx);
            }
            int next = maxIndex + 1;
            while (result.Count < count)
            {
                if (next >= maxTables) return null;
                result.Add(next++);
            }
            return result;
        }

        /// <summary>roomtableowner 是否存在（SQL 补丁未执行时返回 false，调用方按“全部公共桌台”处理）。</summary>
        public static bool OwnerTableExists(GameDbContext ef)
        {
            return TableExists(ef, "roomtableowner");
        }

        /// <summary>某游戏全部桌台的归属：TableIndex → LineAgent；表不存在时返回空字典。</summary>
        public static Dictionary<int, string> GetOwners(GameDbContext ef, int gameId)
        {
            Dictionary<int, string> map = new Dictionary<int, string>();
            if (!OwnerTableExists(ef)) return map;
            foreach (OwnerRow r in ef.Database.SqlQuery<OwnerRow>(
                "SELECT TableIndex, IFNULL(LineAgent,'') AS LineAgent FROM roomtableowner WHERE GAME_ID={0}", gameId).ToList())
            {
                map[r.TableIndex] = r.LineAgent ?? string.Empty;
            }
            return map;
        }

        /// <summary>登记一张桌的归属（覆盖旧值）。</summary>
        public static void AssignOwner(GameDbContext ef, int gameId, int tableIndex, string line)
        {
            ef.Database.ExecuteSqlCommand(
                "REPLACE INTO roomtableowner (GAME_ID, RoomIndex, TableIndex, LineAgent) VALUES ({0}, 0, {1}, {2})",
                gameId, tableIndex, line);
        }

        /// <summary>
        /// 删除桌台后同步归属表：删掉该桌的归属，高位桌号整体左移 1，与各按桌表的“压实为 0..k-1”保持一致。
        /// 必须在 DeleteTableConfig / B_LabaGamePara.DeleteTable 的压实之后、RP 热更之前调用。
        /// </summary>
        public static void OnTableDeleted(GameDbContext ef, int gameId, int deletedIndex)
        {
            if (!OwnerTableExists(ef)) return;
            ef.Database.ExecuteSqlCommand("DELETE FROM roomtableowner WHERE GAME_ID={0} AND TableIndex={1}", gameId, deletedIndex);
            ef.Database.ExecuteSqlCommand(
                "UPDATE roomtableowner SET TableIndex=TableIndex-1 WHERE GAME_ID={0} AND TableIndex>{1} ORDER BY TableIndex",
                gameId, deletedIndex);
        }

        /// <summary>
        /// 从公共桌台复制一套给某线：公共桌台的全部按桌数据原样复制到新桌号（桌名改为“1号机……N号机”），并登记归属。
        /// 复制内容：1) 全部公共桌台参数；2) 全部公共桌台机器人配置（robot_seat 随桌复制）。
        /// 复制后该线在本游戏只看到专属桌台、看不到公共桌台；中奖播报与排行榜也只含该线可见桌台与可玩游戏（游戏服/中心服/排行榜接口按归属过滤）。
        /// 调用方随后负责同步房间桌数 NUM 并发 RP 热更与机器人热更。成功时 datas 为复制的桌数。
        /// </summary>
        public static Msg CopyPublicToLine(int gameId, int paraType, string line)
        {
            Msg msg = new Msg(0, "复制失败！");
            if (string.IsNullOrEmpty(line) || line == LineScopeRules.RecycledLine)
            {
                msg.content = "请选择直属代理！";
                return msg;
            }
            using (var ef = new GameDbContext())
            {
                if (!OwnerTableExists(ef))
                {
                    msg.content = "数据库缺少 roomtableowner 表，请参照 Database/README.md 核对所需增量升级；运营库不可直接重导初始化库。";
                    return msg;
                }
                // MySQL 比较不分大小写，但中心服按 admin.ID 原样下发玩家所属线、游戏服逐字节比对归属：
                // 归属一律写成库里 admin.ID 的原样写法，否则后台看得到专属桌、该线玩家却看不到（只会落回公共桌）。
                string agent = ef.Admins.Where(a => a.ID == line && a.PRIV == 1).Select(a => a.ID).FirstOrDefault();
                if (agent == null)
                {
                    msg.content = "该账号不是超管的直属代理！";
                    return msg;
                }
                line = agent;
                Dictionary<int, string> owners = GetOwners(ef, gameId);
                if (owners.Values.Any(v => string.Equals(v, line, StringComparison.OrdinalIgnoreCase)))
                {
                    msg.content = "该线在本游戏已有专属桌台，无需重复复制！";
                    return msg;
                }
                List<int> allIndexes = ef.Database.SqlQuery<int>(
                    "SELECT DISTINCT TableIndex FROM roomtableconfig WHERE GAME_ID={0} ORDER BY TableIndex", gameId).ToList();
                List<int> publicIndexes = allIndexes.Where(i => !owners.ContainsKey(i) || string.IsNullOrEmpty(owners[i])).ToList();
                if (publicIndexes.Count == 0)
                {
                    msg.content = "该游戏没有公共桌台可以复制！";
                    return msg;
                }
                List<int> recycled = owners.Where(kv => kv.Value == LineScopeRules.RecycledLine).Select(kv => kv.Key).ToList();
                int maxIndex = allIndexes.Count == 0 ? -1 : allIndexes.Max();
                int maxTables = MaxTablesFor(paraType);
                List<int> targets = PlanTargetIndexes(publicIndexes.Count, recycled, maxIndex, maxTables);
                if (targets == null)
                {
                    msg.content = "桌台数量将超过本游戏上限 " + maxTables + " 张（当前最大桌号 " + maxIndex + "，需新增 " + publicIndexes.Count + " 张），无法复制！";
                    return msg;
                }

                List<CloneSpec> specs = PerTableSpecs(paraType);
                int robotRows = 0;
                using (var trans = ef.Database.BeginTransaction())
                {
                    try
                    {
                        for (int k = 0; k < publicIndexes.Count; k++)
                        {
                            int src = publicIndexes[k];
                            int dst = targets[k];
                            string tableName = (k + 1) + "号机";
                            foreach (CloneSpec spec in specs)
                            {
                                ClearRows(ef, spec, gameId, dst);
                                int copied = CloneRows(ef, spec, gameId, src, dst, tableName);
                                if (spec.Table == "robot_seat") robotRows += copied;
                            }
                            AssignOwner(ef, gameId, dst, line);
                        }
                        trans.Commit();
                    }
                    catch (Exception ex)
                    {
                        trans.Rollback();
                        YYT.Common.LogHelper.WriteLog(typeof(LineTables), ex);
                        msg.content = "复制失败：" + ex.Message;
                        return msg;
                    }
                }
                msg.code = 1;
                msg.content = "已从公共桌台复制 " + publicIndexes.Count + " 张专属桌台：桌台参数已全部复制，机器人配置复制 " + robotRows + " 条";
                msg.datas = publicIndexes.Count;
            }
            return msg;
        }

        /// <summary>
        /// 专属视图里「新建桌台」（2026-11-05；2026-11-06 起该线没有专属桌台时也可新建）：给该线加一张专属桌台。桌号接在现有最大桌号之后（不复用已收回桌号——
        /// 那些桌的按桌行还在，走普通新建流程会和旧行冲突），并在写桌台参数**之前**先登记归属，
        /// 保证保存后的 RP/PC 热更下发时这张桌已是该线专属，不会有一瞬间作为公共桌台被其他线看到。
        /// 保存失败时调用方须 <see cref="ReleaseUnusedReservation"/> 撤掉登记。成功时 datas 为桌号（0 起）。
        /// </summary>
        public static Msg ReserveNewLineTable(int gameId, int paraType, string line)
        {
            Msg msg = new Msg(0, "新建专属桌台失败！");
            if (string.IsNullOrEmpty(line) || line == LineScopeRules.RecycledLine)
            {
                msg.content = "请选择直属代理！";
                return msg;
            }
            if (gameId == 54)
            {
                msg.content = "麻将胡了按代理线配置，不支持专属桌台！";
                return msg;
            }
            using (var ef = new GameDbContext())
            {
                if (!OwnerTableExists(ef))
                {
                    msg.content = "数据库缺少 roomtableowner 表，请参照 Database/README.md 核对所需增量升级；运营库不可直接重导初始化库。";
                    return msg;
                }
                string agent = ef.Admins.Where(a => a.ID == line && a.PRIV == 1).Select(a => a.ID).FirstOrDefault();
                if (agent == null)
                {
                    msg.content = "该账号不是超管的直属代理！";
                    return msg;
                }
                // 2026-11-06：该线还没有专属桌台时也允许直接新建（首张建好后该线只看到专属桌台，前端已二次确认）
                int maxIndex = ef.Database.SqlQuery<int?>(
                    "SELECT MAX(TableIndex) FROM roomtableconfig WHERE GAME_ID={0}", gameId).FirstOrDefault() ?? -1;
                int idx = maxIndex + 1;
                int maxTables = MaxTablesFor(paraType);
                if (idx >= maxTables)
                {
                    msg.content = "本游戏桌台已达上限 " + maxTables + " 张，无法新建！";
                    return msg;
                }
                // 与复制一致写成 admin.ID 原样写法（游戏服逐字节比对归属）
                AssignOwner(ef, gameId, idx, agent);
                msg.code = 1;
                msg.content = "ok";
                msg.datas = idx;
            }
            return msg;
        }

        /// <summary>撤掉 <see cref="ReserveNewLineTable"/> 的预登记：只在该桌号确实没有写成桌台时删除，已保存成功的不动。</summary>
        public static void ReleaseUnusedReservation(int gameId, int tableIndex)
        {
            if (tableIndex < 0) return;
            using (var ef = new GameDbContext())
            {
                if (!OwnerTableExists(ef)) return;
                ef.Database.ExecuteSqlCommand(
                    "DELETE FROM roomtableowner WHERE GAME_ID={0} AND TableIndex={1} AND NOT EXISTS (SELECT 1 FROM roomtableconfig WHERE GAME_ID={0} AND TableIndex={1})",
                    gameId, tableIndex);
            }
        }

        /// <summary>收回某线在某游戏的全部专属桌台（不支持只收回部分桌）：桌号不删除，归属改为 #（谁都看不到），下次分配优先复用。调用方随后发 RP。</summary>
        public static Msg RecallLine(int gameId, string line)
        {
            Msg msg = new Msg(0, "收回失败！");
            if (string.IsNullOrEmpty(line) || line == LineScopeRules.RecycledLine)
            {
                msg.content = "请选择直属代理！";
                return msg;
            }
            using (var ef = new GameDbContext())
            {
                if (!OwnerTableExists(ef))
                {
                    msg.content = "数据库缺少 roomtableowner 表，请先执行 SQL 补丁！";
                    return msg;
                }
                int robots;
                int n;
                // 收回范围 = 该线在本游戏的全部专属桌台（复制来的与单独新建的都算），按 GAME_ID+LineAgent 整体处理，不做按桌部分收回。
                // 删机器人与改归属同一事务：避免机器人已删、归属未改（或反之）的半收回状态。
                using (var trans = ef.Database.BeginTransaction())
                {
                    try
                    {
                        // 收回的桌谁都看不到，机器人不应再占用：先删掉这些桌上的机器人设置（调用方随后发机器人热更）
                        robots = ef.Database.ExecuteSqlCommand(
                            "DELETE rs FROM robot_seat rs INNER JOIN roomtableowner o ON o.GAME_ID=rs.GAME_ID AND o.TableIndex=rs.TABLE_ID WHERE o.GAME_ID={0} AND o.LineAgent={1}",
                            gameId, line);
                        n = ef.Database.ExecuteSqlCommand(
                            "UPDATE roomtableowner SET LineAgent={0} WHERE GAME_ID={1} AND LineAgent={2}",
                            LineScopeRules.RecycledLine, gameId, line);
                        if (n <= 0)
                        {
                            trans.Rollback();
                            msg.content = "该线在本游戏没有专属桌台！";
                            return msg;
                        }
                        trans.Commit();
                    }
                    catch (Exception ex)
                    {
                        trans.Rollback();
                        YYT.Common.LogHelper.WriteLog(typeof(LineTables), ex);
                        msg.content = "收回失败：" + ex.Message;
                        return msg;
                    }
                }
                msg.code = 1;
                msg.content = "已收回该线在本游戏的全部 " + n + " 张专属桌台，该线玩家重新进入游戏后改用公共桌台"
                    + (robots > 0 ? "；这些桌上的机器人设置已一并删除（" + robots + " 条）" : "");
                msg.datas = n;
            }
            return msg;
        }

        private static bool TableExists(GameDbContext ef, string table)
        {
            return ef.Database.SqlQuery<int>(
                "SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME={0}", table)
                .FirstOrDefault() > 0;
        }

        private static List<ColumnRow> Columns(GameDbContext ef, string table)
        {
            return ef.Database.SqlQuery<ColumnRow>(
                "SELECT COLUMN_NAME, IFNULL(EXTRA,'') AS EXTRA FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME={0} ORDER BY ORDINAL_POSITION",
                table).ToList();
        }

        private static bool Has(List<ColumnRow> cols, string name)
        {
            return name != null && cols.Any(c => string.Equals(c.COLUMN_NAME, name, StringComparison.OrdinalIgnoreCase));
        }

        private static string RowFilter(List<ColumnRow> cols, CloneSpec spec, int gameId, int tableIndex)
        {
            string filter = "`" + spec.GameCol + "`=" + gameId;
            if (Has(cols, spec.IndexCol))
                return filter + " AND `" + spec.IndexCol + "`=" + tableIndex;
            if (Has(cols, spec.IdCol))
                return filter + " AND `" + spec.IdCol + "`=" + (gameId * 1000 + tableIndex);
            return null;
        }

        private static void ClearRows(GameDbContext ef, CloneSpec spec, int gameId, int tableIndex)
        {
            List<ColumnRow> cols = Columns(ef, spec.Table);
            if (cols.Count == 0) return;
            string filter = RowFilter(cols, spec, gameId, tableIndex);
            if (filter == null) return;
            ef.Database.ExecuteSqlCommand("DELETE FROM `" + spec.Table + "` WHERE " + filter);
        }

        private static int CloneRows(GameDbContext ef, CloneSpec spec, int gameId, int src, int dst, string tableName)
        {
            List<ColumnRow> cols = Columns(ef, spec.Table);
            if (cols.Count == 0) return 0;
            string filter = RowFilter(cols, spec, gameId, src);
            if (filter == null) return 0;
            List<string> insertCols = new List<string>();
            List<string> selectExprs = new List<string>();
            bool renamed = false;
            foreach (ColumnRow c in cols)
            {
                if ((c.EXTRA ?? string.Empty).IndexOf("auto_increment", StringComparison.OrdinalIgnoreCase) >= 0)
                    continue;
                insertCols.Add("`" + c.COLUMN_NAME + "`");
                if (spec.IndexCol != null && string.Equals(c.COLUMN_NAME, spec.IndexCol, StringComparison.OrdinalIgnoreCase))
                    selectExprs.Add(dst.ToString());
                else if (spec.IdCol != null && string.Equals(c.COLUMN_NAME, spec.IdCol, StringComparison.OrdinalIgnoreCase))
                    selectExprs.Add((gameId * 1000 + dst).ToString());
                else if (spec.Table == "roomtableconfig" && string.Equals(c.COLUMN_NAME, "TableName", StringComparison.OrdinalIgnoreCase))
                {
                    selectExprs.Add("{0}");
                    renamed = true;
                }
                else
                    selectExprs.Add("`" + c.COLUMN_NAME + "`");
            }
            string sql = "INSERT INTO `" + spec.Table + "` (" + string.Join(",", insertCols) + ") SELECT " +
                string.Join(",", selectExprs) + " FROM `" + spec.Table + "` WHERE " + filter;
            return renamed ? ef.Database.ExecuteSqlCommand(sql, tableName) : ef.Database.ExecuteSqlCommand(sql);
        }
    }
}
