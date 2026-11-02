using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.RegularExpressions;
using YYT.Entity;

namespace YYT.BLL.EF
{
    /// <summary>
    /// 代理线隔离（2026-10-30，方案见项目文档「多客戶端包與代理線隔離」与 Docs/多客户端包与代理线隔离-20261030.md）。
    /// 线 = 超管的一个直属代理（admin.PRIV=1）连同其下全部代理与玩家；玩家所属线 = 从 users.AGENCY 出发沿 admin.AGENCY
    /// 向上找到的第一个 PRIV=1 的代理，直接挂在超管下面的玩家不属于任何线（空串，按公共处理）。
    /// 可玩游戏只存在直属代理的 admin.PlayableGames（逗号分隔 GameId，NULL/空 = 不限），下级代理与玩家一律继承、不能单独设。
    /// ⚠ 与中心服 Database::LoadUserLineScope、Common/LineScope.h::ParsePlayableCsv 是同一口径，改一处必须同步另一处。
    /// PlayableGames 不映射进 EF 实体（M_Admin.PlayableGames 为 NotMapped），一律走原生 SQL 读写，
    /// 这样 SQL 补丁执行之前后台也能正常加载代理（读不到列时按“不限”处理）。
    /// </summary>
    public static class LineScopeRules
    {
        /// <summary>roomtableowner.LineAgent 取此值表示专属桌台已收回：任何人都看不到，下次分配优先复用。</summary>
        public const string RecycledLine = "#";

        /// <summary>沿上级链查找直属代理的最大层数（与中心服一致，防止脏数据成环）。</summary>
        public const int MaxDepth = 16;

        /// <summary>上级链上的一个代理节点。</summary>
        public class AgencyNode
        {
            public AgencyNode(string id, string agency, int priv)
            {
                ID = id;
                Agency = agency;
                Priv = priv;
            }

            public string ID { get; private set; }
            public string Agency { get; private set; }
            public int Priv { get; private set; }
        }

        /// <summary>原生 SQL 读取 admin.PlayableGames 用的行。</summary>
        public class PlayableRow
        {
            public string ID { get; set; }
            public string PlayableGames { get; set; }
        }

        /// <summary>
        /// 解析 PlayableGames：任何非数字字符都当分隔符，只认 1~65535 的游戏编号并去重；
        /// 空串或没有任何合法编号时返回 null，表示不限（与中心服 ParsePlayableCsv 同口径）。
        /// </summary>
        public static List<int> ParsePlayableGames(string csv)
        {
            if (string.IsNullOrWhiteSpace(csv)) return null;
            List<int> list = new List<int>();
            foreach (Match m in Regex.Matches(csv, @"\d+"))
            {
                int id;
                if (m.Value.Length <= 5 && int.TryParse(m.Value, out id) && id > 0 && id <= 65535 && !list.Contains(id))
                    list.Add(id);
            }
            return list.Count == 0 ? null : list;
        }

        /// <summary>把勾选的游戏编号整理成入库格式（升序、去重、逗号分隔）；没有合法编号时返回 null。</summary>
        public static string FormatPlayableGames(IEnumerable<int> ids)
        {
            if (ids == null) return null;
            List<int> list = ids.Where(id => id > 0 && id <= 65535).Distinct().OrderBy(id => id).ToList();
            return list.Count == 0 ? null : string.Join(",", list);
        }

        /// <summary>某游戏是否在可玩范围内；playable 为 null 表示不限。</summary>
        public static bool IsGameAllowed(List<int> playable, int gameId)
        {
            return playable == null || playable.Contains(gameId);
        }

        /// <summary>
        /// 校验创建/修改直属代理时提交的可玩游戏：至少勾选一款，且只能是已开放（games.Enable=1）的游戏。
        /// 返回 null 表示通过，csv 为整理后的入库值；否则返回给运营看的错误文案。
        /// </summary>
        public static string ValidatePlayableSelection(string submitted, IEnumerable<int> enabledGameIds, out string csv)
        {
            csv = null;
            List<int> picked = ParsePlayableGames(submitted);
            if (picked == null || picked.Count == 0)
                return "请至少勾选一款玩家可玩游戏！";
            HashSet<int> enabled = new HashSet<int>(enabledGameIds ?? new int[0]);
            List<int> unknown = picked.Where(id => !enabled.Contains(id)).ToList();
            if (unknown.Count > 0)
                return "所选游戏未开放或不存在：" + string.Join(",", unknown);
            csv = FormatPlayableGames(picked);
            return null;
        }

        /// <summary>
        /// 从某个代理账号出发沿上级链找所属线：遇到 PRIV=1 返回该代理账号；遇到总台(PRIV&lt;=0)、断链或成环返回空串。
        /// lookup 按账号返回节点，查不到返回 null。
        /// </summary>
        public static string ResolveLine(string startAgency, Func<string, AgencyNode> lookup)
        {
            string cur = startAgency;
            for (int depth = 0; depth < MaxDepth && !string.IsNullOrEmpty(cur); depth++)
            {
                AgencyNode node = lookup(cur);
                if (node == null || string.IsNullOrEmpty(node.ID) || node.Priv <= 0)
                    return string.Empty;
                if (node.Priv == 1)
                    return node.ID;
                if (string.Equals(node.Agency, cur, StringComparison.OrdinalIgnoreCase))
                    return string.Empty;
                cur = node.Agency;
            }
            return string.Empty;
        }

        /// <summary>控牌指令号 cardAction → 平台 GameId（与中心服 ServerCenterRun::cardActionToGameId 同口径）；未知返回 0。</summary>
        public static int CardActionToGameId(int cardAction)
        {
            switch (cardAction)
            {
                case 14: return 5;
                case 12: return 14;
                case 5: return 15;
                case 13: return 44;
                case 7: return 37;
                case 8: return 25;
                case 17: return 40;
                case 15: return 53;
                case 16: return 16;
                case 19: return 54;
                case 20: return 55;
                default: return 0;
            }
        }

        /// <summary>
        /// 后台桌台设置的列表口径：line 为空 = 公共桌台（没有归属记录的桌）；否则只认归属该线的桌。已收回(#)的桌两边都不列。
        /// </summary>
        public static bool TableBelongsTo(IDictionary<int, string> owners, int tableIndex, string line)
        {
            string owner;
            bool owned = owners != null && owners.TryGetValue(tableIndex, out owner) && !string.IsNullOrEmpty(owner);
            if (string.IsNullOrEmpty(line))
                return !owned;
            return owned && string.Equals(owners[tableIndex], line, StringComparison.OrdinalIgnoreCase);
        }

        /// <summary>代理账号所属线（PRIV=1 时就是自己；总台返回空串）。</summary>
        public static string ResolveLineOfAgency(GameDbContext ef, string agency)
        {
            return ResolveLine(agency, id =>
            {
                var a = ef.Admins.AsNoTracking().Where(x => x.ID == id)
                    .Select(x => new { x.ID, x.AGENCY, x.PRIV }).FirstOrDefault();
                return a == null ? null : new AgencyNode(a.ID, a.AGENCY, a.PRIV ?? -1);
            });
        }

        /// <summary>玩家账号所属线；玩家不存在或直属超管时返回空串。</summary>
        public static string ResolveLineOfPlayer(GameDbContext ef, string playerId)
        {
            if (string.IsNullOrWhiteSpace(playerId)) return string.Empty;
            string agency = ef.Users.AsNoTracking().Where(u => u.ID == playerId).Select(u => u.AGENCY).FirstOrDefault();
            return string.IsNullOrEmpty(agency) ? string.Empty : ResolveLineOfAgency(ef, agency);
        }

        /// <summary>读直属代理的 PlayableGames 原值；没有该列（SQL 补丁未执行）或查不到时返回 null。</summary>
        public static string ReadPlayableCsv(GameDbContext ef, string line)
        {
            if (string.IsNullOrEmpty(line)) return null;
            try
            {
                return ef.Database.SqlQuery<string>("SELECT PlayableGames FROM admin WHERE ID={0} LIMIT 1", line).FirstOrDefault();
            }
            catch (Exception ex)
            {
                YYT.Common.LogHelper.WriteLog(typeof(LineScopeRules), ex);
                return null;
            }
        }

        /// <summary>某条线的可玩游戏；null 表示不限（含公共/总台）。</summary>
        public static List<int> GetLinePlayableGames(GameDbContext ef, string line)
        {
            return ParsePlayableGames(ReadPlayableCsv(ef, line));
        }

        /// <summary>某个代理（含后台登录账号）所在线的可玩游戏；总台返回 null（不限）。</summary>
        public static List<int> GetPlayableGamesOfAgency(GameDbContext ef, string agency)
        {
            return GetLinePlayableGames(ef, ResolveLineOfAgency(ef, agency));
        }

        /// <summary>某个玩家所在线的可玩游戏；null 表示不限。</summary>
        public static List<int> GetPlayableGamesOfPlayer(GameDbContext ef, string playerId)
        {
            return GetLinePlayableGames(ef, ResolveLineOfPlayer(ef, playerId));
        }

        /// <summary>写直属代理的 PlayableGames（只对 PRIV=1 生效）；返回受影响行数。</summary>
        public static int SavePlayableGames(GameDbContext ef, string line, string csv)
        {
            if (string.IsNullOrEmpty(line)) return 0;
            return ef.Database.ExecuteSqlCommand("UPDATE admin SET PlayableGames={0} WHERE ID={1} AND PRIV=1",
                string.IsNullOrEmpty(csv) ? (object)DBNull.Value : csv, line);
        }

        /// <summary>给代理列表里的直属代理补上 PlayableGames（NotMapped 字段，单次原生查询）。</summary>
        public static void FillPlayableGames(GameDbContext ef, IEnumerable<M_Admin> rows)
        {
            if (rows == null) return;
            List<M_Admin> lines = rows.Where(r => r != null && r.PRIV == 1).ToList();
            if (lines.Count == 0) return;
            Dictionary<string, string> map;
            try
            {
                map = ef.Database.SqlQuery<PlayableRow>("SELECT ID, PlayableGames FROM admin WHERE PRIV=1").ToList()
                    .Where(r => r.ID != null)
                    .GroupBy(r => r.ID, StringComparer.OrdinalIgnoreCase)
                    .ToDictionary(g => g.Key, g => g.First().PlayableGames, StringComparer.OrdinalIgnoreCase);
            }
            catch (Exception ex)
            {
                YYT.Common.LogHelper.WriteLog(typeof(LineScopeRules), ex);
                return;
            }
            foreach (M_Admin row in lines)
            {
                string csv;
                row.PlayableGames = map.TryGetValue(row.ID ?? string.Empty, out csv) ? csv : null;
            }
        }

        /// <summary>超管的全部直属代理账号（桌台设置“代理”下拉的候选）。</summary>
        public static List<string> GetLineAgents(GameDbContext ef)
        {
            return ef.Admins.AsNoTracking().Where(a => a.PRIV == 1).OrderBy(a => a.ID).Select(a => a.ID).ToList();
        }

        /// <summary>
        /// 后台页面注入用：登录账号所在线的可玩游戏 JSON 数组（如 [5,37]）；总台、不限或出错时返回 "null"。
        /// 只决定控制页下拉显示哪些游戏，真正的拦截在保存控制时按玩家所在线再校验一次。
        /// </summary>
        public static string PlayableGamesJson(M_LoginUser user)
        {
            if (user == null || user.UserPriv == 0 || string.IsNullOrEmpty(user.Accounts)) return "null";
            try
            {
                using (var ef = new GameDbContext())
                {
                    List<int> playable = GetPlayableGamesOfAgency(ef, user.Accounts);
                    return playable == null ? "null" : "[" + string.Join(",", playable) + "]";
                }
            }
            catch (Exception ex)
            {
                YYT.Common.LogHelper.WriteLog(typeof(LineScopeRules), ex);
                return "null";
            }
        }

        /// <summary>已开放（games.Enable=1）的全部游戏，按类型、编号排序；可玩游戏勾选框与校验共用。</summary>
        public static List<M_Games> GetEnabledGames(GameDbContext ef)
        {
            return ef.Games.AsNoTracking().Where(g => g.Enable == 1).OrderBy(g => g.GameType).ThenBy(g => g.GameId).ToList();
        }
    }
}
