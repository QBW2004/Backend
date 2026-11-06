-- 新版本配套增量：先备份，再在维护窗口执行；不是初始化库，不改历史资金或记录归属。
-- MySQL 5.7；可重复执行。原始桌号由仍存在的同一 EventId 明细补齐，缺失保持 NULL。
SET @rank_room_sql = IF(EXISTS(SELECT 1 FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='gamerankhistory' AND COLUMN_NAME='RoomId'),
  'SELECT 1', 'ALTER TABLE gamerankhistory ADD COLUMN RoomId INT NULL');
PREPARE rank_stmt FROM @rank_room_sql;
EXECUTE rank_stmt;
DEALLOCATE PREPARE rank_stmt;
SET @rank_table_sql = IF(EXISTS(SELECT 1 FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='gamerankhistory' AND COLUMN_NAME='TableId'),
  'SELECT 1', 'ALTER TABLE gamerankhistory ADD COLUMN TableId BIGINT NULL');
PREPARE rank_stmt FROM @rank_table_sql;
EXECUTE rank_stmt;
DEALLOCATE PREPARE rank_stmt;
UPDATE gamerankhistory h INNER JOIN gameprizerecord p ON p.GameId=h.GameId AND p.EventId=h.EventId
SET h.RoomId=p.RoomId,h.TableId=p.TableId
WHERE h.RoomId IS NULL OR h.TableId IS NULL;
