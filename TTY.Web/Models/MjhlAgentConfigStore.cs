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

        public static Row Read(GameDbContext ef, string line)
        {
            // 历史主键保证最多一条；版本与完整配置哈希同时匹配，才允许展示上次计算，避免串线或沿用旧权重结果。
            return ef.Database.SqlQuery<Row>("SELECT c.GameId,c.LineAgent,c.Revision,c.ConfigJson,c.ConfigHash,c.UpdatedBy,c.UpdatedAt,COALESCE(h.SimulationSummary,'') AS SimulationSummary " +
                "FROM mjhl_agent_config c LEFT JOIN mjhl_agent_config_history h ON h.GameId=c.GameId AND h.LineAgent=c.LineAgent AND h.Revision=c.Revision AND h.ConfigHash=c.ConfigHash " +
                "WHERE c.GameId=54 AND c.LineAgent={0}", line).SingleOrDefault();
        }

        public static Row Save(GameDbContext ef, string line, long expected, MjhlAgentConfig config, string actor, string summary)
        {
            config.Validate();
            if (expected < 0 || expected == long.MaxValue) throw new ArgumentException("配置版本不合法。");
            string json = config.ToJson(), hash = config.ConfigHash();
            DateTime now = DateTime.UtcNow;
            long revision = expected + 1;
            summary = summary ?? "";
            if (summary.Length > 2048) summary = summary.Substring(0, 2048);
            using (var tx = ef.Database.BeginTransaction())
            {
                int changed;
                if (expected == 0)
                    changed = ef.Database.ExecuteSqlCommand("INSERT IGNORE INTO mjhl_agent_config (GameId,LineAgent,Revision,ConfigJson,ConfigHash,UpdatedBy,UpdatedAt) VALUES (54,{0},{1},{2},{3},{4},{5})", line, revision, json, hash, actor, now);
                else
                    changed = ef.Database.ExecuteSqlCommand("UPDATE mjhl_agent_config SET Revision={0},ConfigJson={1},ConfigHash={2},UpdatedBy={3},UpdatedAt={4} WHERE GameId=54 AND LineAgent={5} AND Revision={6}", revision, json, hash, actor, now, line, expected);
                if (changed != 1) throw new ArgumentException("配置已被其他页面更新，请重新载入后再保存。");
                ef.Database.ExecuteSqlCommand("INSERT INTO mjhl_agent_config_history (GameId,LineAgent,Revision,ConfigJson,ConfigHash,UpdatedBy,UpdatedAt,SimulationSummary) VALUES (54,{0},{1},{2},{3},{4},{5},{6})", line, revision, json, hash, actor, now, summary);
                tx.Commit();
            }
            return new Row { GameId = 54, LineAgent = line, Revision = revision, ConfigJson = json, ConfigHash = hash, UpdatedBy = actor, UpdatedAt = now };
        }
    }
}
