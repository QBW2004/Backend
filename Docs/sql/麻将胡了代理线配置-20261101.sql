-- 仅在本地隔离库执行；不迁移旧按桌权重，不默认给任何线启用配置。
-- LineAgent = admin.PRIV=1 顶层代理账号；Revision/UpdatedAt 绑定完整不可变配置。
CREATE TABLE IF NOT EXISTS mjhl_agent_config (
  GameId INT NOT NULL,
  LineAgent VARCHAR(64) NOT NULL,
  Revision BIGINT UNSIGNED NOT NULL,
  ConfigJson LONGTEXT NOT NULL,
  ConfigHash CHAR(64) CHARACTER SET ascii NOT NULL,
  UpdatedBy VARCHAR(64) NOT NULL,
  UpdatedAt DATETIME NOT NULL,
  PRIMARY KEY (GameId, LineAgent)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS mjhl_agent_config_history (
  GameId INT NOT NULL,
  LineAgent VARCHAR(64) NOT NULL,
  Revision BIGINT UNSIGNED NOT NULL,
  ConfigJson LONGTEXT NOT NULL,
  ConfigHash CHAR(64) CHARACTER SET ascii NOT NULL,
  UpdatedBy VARCHAR(64) NOT NULL,
  UpdatedAt DATETIME NOT NULL,
  SimulationSummary VARCHAR(2048) NOT NULL DEFAULT '',
  PRIMARY KEY (GameId, LineAgent, Revision)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
