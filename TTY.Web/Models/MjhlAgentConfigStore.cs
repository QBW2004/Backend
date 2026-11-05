using System;
using System.Linq;
using YYT.BLL.EF;

namespace YYT.Web.Models
{
    /// <summary>每条线整份配置事务保存，乐观版本锁防止两个页面互相覆盖；历史保留当时的完整参数。</summary>
    public static class MjhlAgentConfigStore
    {
        public sealed class Row
        {
            public int GameId { get; set; }
            public string LineAgent { get; set; }
            public long Revision { get; set; }
            public string ConfigJson { get; set; }
            public string ConfigHash { get; set; }
            public string UpdatedBy { get; set; }
            public DateTime UpdatedAt { get; set; }
            public string SimulationSummary { get; set; }
        }

        public static Row Read(GameDbContext ef, string line, bool forUpdate = false)
        {
            // 历史主键保证最多一条；版本与完整配置哈希同时匹配，才允许展示上次计算，避免串线或沿用旧权重结果。
            return ef.Database.SqlQuery<Row>("SELECT c.GameId,c.LineAgent,c.Revision,c.ConfigJson,c.ConfigHash,c.UpdatedBy,c.UpdatedAt,COALESCE(h.SimulationSummary,'') AS SimulationSummary " +
                "FROM mjhl_agent_config c LEFT JOIN mjhl_agent_config_history h ON h.GameId=c.GameId AND h.LineAgent=c.LineAgent AND h.Revision=c.Revision AND h.ConfigHash=c.ConfigHash " +
                "WHERE c.GameId=54 AND c.LineAgent={0}" + (forUpdate ? " FOR UPDATE" : ""), line).SingleOrDefault();
        }

        // 收回后仍保留历史版本，防止旧页面在删除/重建后重新获得写入资格。
        public static long Revision(GameDbContext ef, string line, Row row)
        {
            long history = ef.Database.SqlQuery<long>("SELECT COALESCE(MAX(Revision),0) FROM mjhl_agent_config_history WHERE GameId=54 AND LineAgent={0}", line).Single();
            return Math.Max(history, row == null ? 0 : row.Revision);
        }

        private static long NextRevision(GameDbContext ef, string line, Row row, long expected)
        {
            if (expected < 0 || expected == long.MaxValue) throw new ArgumentException("配置版本不合法。");
            if (Revision(ef, line, row) != expected) throw new ArgumentException("配置已被其他页面更新，请重新载入后再操作。");
            return expected + 1;
        }

        private static void History(GameDbContext ef, Row row, string summary)
        {
            summary = summary ?? "";
            if (summary.Length > 2048) summary = summary.Substring(0, 2048);
            ef.Database.ExecuteSqlCommand("INSERT INTO mjhl_agent_config_history (GameId,LineAgent,Revision,ConfigJson,ConfigHash,UpdatedBy,UpdatedAt,SimulationSummary) VALUES (54,{0},{1},{2},{3},{4},{5},{6})",
                row.LineAgent, row.Revision, row.ConfigJson, row.ConfigHash, row.UpdatedBy, row.UpdatedAt, summary);
        }

        private static Row Write(GameDbContext ef, string line, Row previous, long revision, MjhlAgentConfig config, string actor, string summary)
        {
            var row = new Row { GameId = 54, LineAgent = line, Revision = revision, ConfigJson = config.ToJson(), ConfigHash = config.ConfigHash(), UpdatedBy = actor, UpdatedAt = DateTime.UtcNow };
            int changed = previous == null
                ? ef.Database.ExecuteSqlCommand("INSERT IGNORE INTO mjhl_agent_config (GameId,LineAgent,Revision,ConfigJson,ConfigHash,UpdatedBy,UpdatedAt) VALUES (54,{0},{1},{2},{3},{4},{5})", line, row.Revision, row.ConfigJson, row.ConfigHash, actor, row.UpdatedAt)
                : ef.Database.ExecuteSqlCommand("UPDATE mjhl_agent_config SET Revision={0},ConfigJson={1},ConfigHash={2},UpdatedBy={3},UpdatedAt={4} WHERE GameId=54 AND LineAgent={5} AND Revision={6}", row.Revision, row.ConfigJson, row.ConfigHash, actor, row.UpdatedAt, line, previous.Revision);
            if (changed != 1) throw new ArgumentException("配置已被其他页面更新，请重新载入后再操作。");
            History(ef, row, summary);
            return row;
        }

        public static Row Save(GameDbContext ef, string line, long expected, MjhlAgentConfig config, string actor, string summary)
        {
            config.Validate();
            using (var tx = ef.Database.BeginTransaction())
            {
                // 所有写入统一按默认行→目标行加锁；复制/恢复读取的默认版本也在同一事务内保持不变。
                Row defaults = Read(ef, MjhlAgentConfig.DefaultLine, true);
                Row previous = line == MjhlAgentConfig.DefaultLine ? defaults : Read(ef, line, true);
                Row row = Write(ef, line, previous, NextRevision(ef, line, previous, expected), config, actor, summary);
                tx.Commit();
                return row;
            }
        }

        public static Row ChangeInheritance(GameDbContext ef, string line, long expected, long expectedDefault, bool copy, string actor)
        {
            if (string.IsNullOrEmpty(line) || line == MjhlAgentConfig.DefaultLine) throw new ArgumentException("请选择要操作的代理线，公共桌台参数不能复制给自身或收回。");
            using (var tx = ef.Database.BeginTransaction())
            {
                Row defaults = Read(ef, MjhlAgentConfig.DefaultLine, true);
                if (defaults == null) throw new ArgumentException("请先保存公共桌台参数，再复制公共参数配置或收回独立参数配置。");
                if (defaults.Revision != expectedDefault) throw new ArgumentException("公共桌台参数已更新，请重新载入后再操作。");
                var config = MjhlAgentConfig.Parse(defaults.ConfigJson);
                Row previous = Read(ef, line, true);
                long revision = NextRevision(ef, line, previous, expected);
                if (copy && previous != null) throw new ArgumentException("该代理线已有独立配置，无需重复复制。");
                if (!copy && previous == null) throw new ArgumentException("该代理线已在使用公共桌台参数。");
                Row row;
                if (copy)
                    row = Write(ef, line, null, revision, config, actor, defaults.SimulationSummary);
                else
                {
                    int changed = ef.Database.ExecuteSqlCommand("DELETE FROM mjhl_agent_config WHERE GameId=54 AND LineAgent={0} AND Revision={1}", line, previous.Revision);
                    if (changed != 1) throw new ArgumentException("配置已被其他页面更新，请重新载入后再操作。");
                    row = new Row { GameId = 54, LineAgent = line, Revision = revision, ConfigJson = previous.ConfigJson, ConfigHash = previous.ConfigHash, UpdatedBy = actor, UpdatedAt = DateTime.UtcNow };
                    History(ef, row, "收回独立参数配置，改用公共桌台参数；收回独立版本 " + previous.Revision + "，公共版本 " + defaults.Revision + "；本条保留收回前参数。");
                }
                tx.Commit();
                return row;
            }
        }
    }
}
