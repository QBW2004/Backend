-- ----------------------------------------------------------------------------
-- roomtableconfig 表追加 MaxSeats 列（幂等脚本，可安全重复执行）
-- 配合 C++ 端 ts_RoomTableConfig 结构体扩展，用于坐席数组动态扩容防越界。
-- 鱼机默认 6，牌机默认 0（单人机台），押注类默认 8。
-- 执行前请确认已 USE 目标库。
-- ----------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS `__mth_add_col`;
DELIMITER $$
CREATE PROCEDURE `__mth_add_col`(IN p_tbl VARCHAR(64), IN p_col VARCHAR(64), IN p_ddl TEXT)
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = p_tbl AND COLUMN_NAME = p_col
  ) THEN
    SET @s = CONCAT('ALTER TABLE `', p_tbl, '` ADD COLUMN ', p_ddl);
    PREPARE st FROM @s;
    EXECUTE st;
    DEALLOCATE PREPARE st;
  END IF;
END$$
DELIMITER ;

CALL `__mth_add_col`('roomtableconfig', 'MaxSeats', '`MaxSeats` int(11) NOT NULL DEFAULT 6 COMMENT ''最大坐席数，0=单人机台，6=鱼机标准，8=押注扩容'' AFTER `Enabled`');

DROP PROCEDURE IF EXISTS `__mth_add_col`;

UPDATE `roomtableconfig` SET `MaxSeats` = 6 WHERE `GAME_ID` IN (
  SELECT `GameId` FROM `games` WHERE `GameType` = 2
);
UPDATE `roomtableconfig` SET `MaxSeats` = 0 WHERE `GAME_ID` IN (
  SELECT `GameId` FROM `games` WHERE `GameType` = 1
);
UPDATE `roomtableconfig` SET `MaxSeats` = 8 WHERE `GAME_ID` IN (
  SELECT `GameId` FROM `games` WHERE `GameType` = 0
);
