-- 05：配套当前中心服和大厅历史记录读取。只补结构，不生成或重写历史中奖数据。
-- 停止中奖写入后执行，完成后重启中心服以刷新字段检测缓存。
CREATE TABLE IF NOT EXISTS gameprizerecord (
  ID BIGINT NOT NULL AUTO_INCREMENT, EventId VARCHAR(64) NOT NULL,
  UserID VARCHAR(50) NOT NULL, GameId INT NOT NULL, GameType INT NOT NULL DEFAULT 0,
  RoomId BIGINT NOT NULL DEFAULT 0, TableId BIGINT NOT NULL DEFAULT 0,
  CardType VARCHAR(100) NULL, Multiplier DECIMAL(12,2) NOT NULL DEFAULT 0,
  Score BIGINT NOT NULL DEFAULT 0, IsManualControl TINYINT NOT NULL DEFAULT 0,
  IsBroadcast TINYINT NOT NULL DEFAULT 0, RecTime DATETIME NOT NULL,
  LineAgent VARCHAR(50) NOT NULL DEFAULT '',
  PRIMARY KEY(ID), UNIQUE KEY uq_gameprizerecord_event(EventId)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
CREATE TABLE IF NOT EXISTS gamerankhistory (
  ID BIGINT NOT NULL AUTO_INCREMENT, LineAgent VARCHAR(50) NOT NULL DEFAULT '',
  GameId INT NOT NULL, Slot INT NOT NULL, EventId VARCHAR(64) NOT NULL,
  UserID VARCHAR(50) NOT NULL, CardType VARCHAR(100) NULL,
  Score BIGINT NOT NULL DEFAULT 0, RecTime DATETIME NOT NULL,
  IsBigWin TINYINT NOT NULL DEFAULT 0,
  PRIMARY KEY(ID), UNIQUE KEY uq_rank_line_game_slot(LineAgent,GameId,Slot)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
CREATE TABLE IF NOT EXISTS prizebroadcastoutbox (
  ID BIGINT NOT NULL AUTO_INCREMENT, EventId VARCHAR(64) NOT NULL,
  GameId INT NOT NULL, LineAgent VARCHAR(50) NOT NULL DEFAULT '',
  BroadcastText TEXT NOT NULL, CreatedAt DATETIME NOT NULL, SentAt DATETIME NULL,
  PRIMARY KEY(ID), UNIQUE KEY uq_prize_broadcast_event(EventId),
  KEY ix_prize_broadcast_pending(SentAt,ID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

SET @mjhl_ddl=IF((SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='gameprizerecord' AND COLUMN_NAME='LineAgent')=0,
 'ALTER TABLE gameprizerecord ADD COLUMN LineAgent VARCHAR(50) NOT NULL DEFAULT ''''', 'SELECT 1');
PREPARE mjhl_stmt FROM @mjhl_ddl;
EXECUTE mjhl_stmt;
DEALLOCATE PREPARE mjhl_stmt;
SET @mjhl_ddl=IF((SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='gamerankhistory' AND COLUMN_NAME='LineAgent')=0,
 'ALTER TABLE gamerankhistory ADD COLUMN LineAgent VARCHAR(50) NOT NULL DEFAULT ''''', 'SELECT 1');
PREPARE mjhl_stmt FROM @mjhl_ddl;
EXECUTE mjhl_stmt;
DEALLOCATE PREPARE mjhl_stmt;
SET @mjhl_ddl=IF((SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='gamerankhistory' AND COLUMN_NAME='IsBigWin')=0,
 'ALTER TABLE gamerankhistory ADD COLUMN IsBigWin TINYINT NOT NULL DEFAULT 0', 'SELECT 1');
PREPARE mjhl_stmt FROM @mjhl_ddl;
EXECUTE mjhl_stmt;
DEALLOCATE PREPARE mjhl_stmt;
-- 旧版每游戏30槽的唯一索引会阻止代理线各自保存30槽；只替换列序完全相同的旧索引。
SET @mjhl_old_rank_indexes=(SELECT GROUP_CONCAT(CONCAT('DROP INDEX `',REPLACE(INDEX_NAME,'`','``'),'`') SEPARATOR ',') FROM
 (SELECT INDEX_NAME FROM information_schema.STATISTICS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='gamerankhistory' AND NON_UNIQUE=0
  GROUP BY INDEX_NAME HAVING GROUP_CONCAT(COLUMN_NAME ORDER BY SEQ_IN_INDEX)='GameId,Slot') mjhl_old_indexes);
SET @mjhl_ddl=IF(@mjhl_old_rank_indexes IS NULL,'SELECT 1',CONCAT('ALTER TABLE gamerankhistory ',@mjhl_old_rank_indexes));
PREPARE mjhl_stmt FROM @mjhl_ddl;
EXECUTE mjhl_stmt;
DEALLOCATE PREPARE mjhl_stmt;
SET @mjhl_ddl=IF((SELECT COUNT(*) FROM information_schema.STATISTICS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='gamerankhistory' AND INDEX_NAME='uq_rank_line_game_slot')=0,
 'ALTER TABLE gamerankhistory ADD UNIQUE KEY uq_rank_line_game_slot(LineAgent,GameId,Slot)', 'SELECT 1');
PREPARE mjhl_stmt FROM @mjhl_ddl;
EXECUTE mjhl_stmt;
DEALLOCATE PREPARE mjhl_stmt;

-- 旧记录无可信代理线时保留空值，保持当前源码公共记录口径；不根据玩家现归属倒填历史。
