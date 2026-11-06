using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using YYT.Common;

namespace YYT.BLL.EF
{
    /// <summary>
    /// 系统设置 / 排行榜管理（2026-11-06，仅超管）：按勾选游戏清空大厅排行榜（gamerankhistory 30 槽环形表）。
    /// 页面只列客户端排行榜可见的游戏（开启、牌机/拉霸、排除麻将胡了 54），与 api/RankingList/History 同口径；
    /// 客户端看不到的残留行（停用/非排行游戏/games 已无此游戏/旧口径非大奖/负分）由定时任务每日自动删除。
    /// 可选范围：全部代理线 / 公共桌台 / 某条直属代理线。公共桌台与代理线和客户端 History 共用
    /// TableDisplayMap.HistoryVisibilitySql：该线有专属桌的游戏看专属桌记录，没有专属桌的游戏看公共桌记录。
    /// 只删排行榜展示行，不动中奖明细 gameprizerecord、奖池或玩家资金。
    /// 游戏服 RankHistoryStore.h 写入时取本线本游戏最新 Slot+1，无行时从 0 开始，清空后无需重启或改服务端。
    /// </summary>
    public static class RankHistoryCleanup
    {
        public const int MaxGamesPerRequest = 200;

        /// <summary>客户端排行榜可见游戏条件（表别名 g），与 RankingListController.History 保持一致。</summary>
        public const string VisibleGameSql = "g.Enable=1 AND (g.GameType=1 OR g.GameType=3) AND g.GameId<>54";

        /// <summary>客户端可见记录条件（表别名 h）。</summary>
        public const string VisibleRowSql = "h.IsBigWin=1 AND h.Score>=0";

        /// <summary>残留行：客户端永远不会显示的排行记录。games 无对应行时 g.* 为 NULL，归入残留。</summary>
        public const string ResidualSql = "g.GameId IS NULL OR NOT (" + VisibleGameSql + ") OR NOT (" + VisibleRowSql + ")";

        /// <summary>代理线选择：全部代理线。</summary>
        public const string AllLines = "*";
        /// <summary>代理线选择：公共桌台（LineAgent=''，所有代理线玩家都能看到）。</summary>
        public const string PublicLine = "~";

        /// <summary>排行来源：所选范围本身（全部/公共）、某线专属桌台、某线无专属桌台时沿用公共桌台。</summary>
        public const string SourceScope = "scope";
        public const string SourceExclusive = "exclusive";
        public const string SourcePublic = "public";

        public sealed class GameRow
        {
            public int GameId { get; set; }
            public string Name { get; set; }
            public int GameType { get; set; }
            /// <summary>该行排行来源下的客户端口径可见条数（全部代理线时为各线合计）。</summary>
            public long VisibleCount { get; set; }
            public DateTime? LastTime { get; set; }
            /// <summary>SourceScope / SourceExclusive / SourcePublic；只有选具体代理线时区分专属与公共。</summary>
            public string Source { get; set; }
        }

        private sealed class CountRow
        {
            public int GameId { get; set; }
            public long Cnt { get; set; }
            public DateTime? LastTime { get; set; }
        }

        /// <summary>按客户端同一规则筛排行行时需要关联中奖明细取旧记录坐标（与 RankingListController.History 一致）。</summary>
        private const string ScopedFromSql = " FROM gamerankhistory h LEFT JOIN gameprizerecord p ON p.EventId=h.EventId AND p.GameId=h.GameId";

        /// <summary>
        /// 解析页面提交的代理线：空/"*" 全部 → 返回 null；"~" 公共桌台 → 返回 ""；
        /// 其它必须是现有直属代理（PRIV=1）账号，原样返回。非法返回 null 并给出 error。
        /// </summary>
        public static string ParseLine(string raw, ICollection<string> lineAgents, out string error)
        {
            error = null;
            string text = (raw ?? string.Empty).Trim();
            if (text.Length == 0 || text == AllLines) return null;
            if (text == PublicLine) return string.Empty;
            if (lineAgents != null && lineAgents.Contains(text)) return text;
            error = "代理线不存在，请刷新后重新选择！";
            return null;
        }

        /// <summary>
        /// 列出客户端排行榜可见的游戏及可见记录数；停用游戏和残留记录不展示。
        /// line：null 全部代理线（不分桌台合计）；"" 公共桌台；其它为具体代理线（只列该线可玩游戏）。
        /// 公共桌台/代理线与客户端 api/RankingList/History 共用 TableDisplayMap.HistoryVisibilitySql：
        /// 该线在此游戏有专属桌 → 只算这些专属桌的记录；没有 → 算公共桌记录（其它同样没有专属桌的线共用）。
        /// </summary>
        public static List<GameRow> ListGames(GameDbContext ef, string line = null)
        {
            List<GameRow> rows = ef.Database.SqlQuery<GameRow>(
                "SELECT g.GameId, g.Name, g.GameType FROM games g WHERE " + VisibleGameSql + " ORDER BY g.GameId").ToList();
            if (!string.IsNullOrEmpty(line))
            {
                List<int> playable = LineScopeRules.GetLinePlayableGames(ef, line);
                if (playable != null) rows = rows.Where(r => playable.Contains(r.GameId)).ToList();
            }
            if (rows.Count == 0) return rows;
            string ids = string.Join(",", rows.Select(r => r.GameId.ToString(CultureInfo.InvariantCulture)));
            List<CountRow> counts = ef.Database.SqlQuery<CountRow>(
                "SELECT h.GameId, CAST(COUNT(*) AS SIGNED) AS Cnt, MAX(h.RecTime) AS LastTime" + ScopedFromSql +
                " WHERE " + VisibleRowSql + " AND h.GameId IN (" + ids + ")" + ScopeSql(ef, rows, line) +
                " GROUP BY h.GameId", string.Empty, line ?? string.Empty).ToList();
            HashSet<int> exclusive = ExclusiveGames(ef, line);
            foreach (GameRow r in rows)
            {
                r.Source = line == null ? SourceScope : exclusive.Contains(r.GameId) ? SourceExclusive : SourcePublic;
                CountRow c = counts.FirstOrDefault(x => x.GameId == r.GameId);
                r.VisibleCount = c == null ? 0 : c.Cnt;
                r.LastTime = c == null ? null : c.LastTime;
            }
            return rows;
        }

        /// <summary>全部代理线不加桌台条件；公共桌台/具体代理线取客户端同款可见桌条件（@p1 为代理线）。</summary>
        private static string ScopeSql(GameDbContext ef, IEnumerable<GameRow> games, string line)
        {
            if (line == null) return string.Empty;
            var types = games.ToDictionary(g => g.GameId, g => g.GameType);
            return TableDisplayMap.Load(ef, types.Keys).HistoryVisibilitySql(line, types);
        }

        /// <summary>
        /// 某代理线拥有专属桌的游戏：roomtableowner.LineAgent=本线且桌台仍在 roomtableconfig（# 为已收回，不算），
        /// 与 TableDisplayMap 判断专属桌的口径一致。公共桌台/全部代理线或无归属表时为空。
        /// </summary>
        public static HashSet<int> ExclusiveGames(GameDbContext ef, string line)
        {
            if (string.IsNullOrEmpty(line) || !LineTables.OwnerTableExists(ef)) return new HashSet<int>();
            return new HashSet<int>(ef.Database.SqlQuery<int>(
                "SELECT DISTINCT o.GAME_ID FROM roomtableowner o INNER JOIN roomtableconfig t" +
                " ON t.GAME_ID=o.GAME_ID AND t.TableIndex=o.TableIndex WHERE o.LineAgent=@p0", line).ToList());
        }

        /// <summary>解析逗号分隔的游戏编号；任一项非法、为空或超出上限返回 null。结果去重排序。</summary>
        public static List<int> ParseGameIds(string csv)
        {
            if (string.IsNullOrWhiteSpace(csv)) return null;
            var ids = new List<int>();
            foreach (string part in csv.Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries))
            {
                int id;
                string text = part.Trim();
                if (text.Length == 0) continue;
                if (!int.TryParse(text, NumberStyles.None, CultureInfo.InvariantCulture, out id) || id <= 0) return null;
                ids.Add(id);
            }
            ids = ids.Distinct().OrderBy(i => i).ToList();
            return ids.Count == 0 || ids.Count > MaxGamesPerRequest ? null : ids;
        }

        /// <summary>
        /// 删除所选游戏在所选范围内、客户端能看到的排行行，返回删除行数。范围同 ListGames：
        /// 全部代理线删该游戏全部行；公共桌台/具体代理线只删客户端同款可见桌上的行。
        /// 具体代理线下“公共桌台”来源的游戏会删公共桌记录，影响同样使用公共桌的其它代理线（页面确认框单独列出）。
        /// 编号已由 ParseGameIds 限定为正整数，再与该范围页面上列出的游戏求交集，不在页面上的编号不会拼进 SQL。
        /// </summary>
        public static int Clear(GameDbContext ef, IList<int> gameIds, string line, out List<GameRow> cleared)
        {
            cleared = new List<GameRow>();
            if (gameIds == null || gameIds.Count == 0) return 0;
            var wanted = new HashSet<int>(gameIds);
            cleared = ListGames(ef, line).Where(g => wanted.Contains(g.GameId)).ToList();
            if (cleared.Count == 0) return 0;
            string ids = string.Join(",", cleared.Select(g => g.GameId.ToString(CultureInfo.InvariantCulture)));
            if (line == null)
                return ef.Database.ExecuteSqlCommand("DELETE FROM gamerankhistory WHERE GameId IN (" + ids + ")");
            return ef.Database.ExecuteSqlCommand(
                "DELETE h" + ScopedFromSql + " WHERE h.GameId IN (" + ids + ")" + ScopeSql(ef, cleared, line),
                string.Empty, line);
        }

        /// <summary>删除客户端不可见的残留排行行，返回删除行数。</summary>
        public static int CleanupResidual(GameDbContext ef)
        {
            return ef.Database.ExecuteSqlCommand(
                "DELETE h FROM gamerankhistory h LEFT JOIN games g ON g.GameId=h.GameId WHERE " + ResidualSql);
        }

        private static DateTime lastResidualDay = DateTime.MinValue;
        private static readonly object residualLock = new object();

        /// <summary>
        /// 残留清理唯一入口：只由 Global.asax 定时任务调用，每个自然日（服务器本地时间）最多执行一次；
        /// 进程启动后的首轮也会执行一次。失败只记日志，当天不再重试，次日再跑。
        /// </summary>
        public static void CleanupResidualDaily()
        {
            DateTime today = DateTime.Now.Date;
            lock (residualLock)
            {
                if (lastResidualDay == today) return;
                lastResidualDay = today;
            }
            try
            {
                using (var ef = new GameDbContext())
                {
                    int deleted = CleanupResidual(ef);
                    if (deleted > 0)
                        LogHelper.WriteLog(typeof(RankHistoryCleanup), "[RankResidualCleanup] deleted=" + deleted);
                }
            }
            catch (Exception ex)
            {
                LogHelper.WriteLog(typeof(RankHistoryCleanup), ex);
            }
        }
    }
}
