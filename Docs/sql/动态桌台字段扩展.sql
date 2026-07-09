-- ----------------------------------------------------------------------------
-- 动态桌台配置：pararoom / parabetroom 字段扩展（幂等脚本，可安全重复执行）
-- 逐列检查 information_schema，列不存在才 ADD，已存在自动跳过，不再报 Duplicate column。
-- bool 字段沿用本库既有约定使用 bit(1)，下注炮值入库为整数（显示值放大 10 倍）。
-- 仅在当前所选数据库(DATABASE())上执行；执行前请确认已 USE 目标库。
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

CALL `__mth_add_col`('pararoom', 'TableName', '`TableName` varchar(64) NULL DEFAULT NULL COMMENT ''桌名'' AFTER `Game_Mo`');
CALL `__mth_add_col`('pararoom', 'MaxSeats', '`MaxSeats` int(11) NOT NULL DEFAULT 6 COMMENT ''最大坐席数，配合C++端数组扩容'' AFTER `TableName`');
CALL `__mth_add_col`('pararoom', 'IdleFireTimeoutSec', '`IdleFireTimeoutSec` int(11) NOT NULL DEFAULT 0 COMMENT ''无发炮踢出时间(秒)'' AFTER `MaxSeats`');
CALL `__mth_add_col`('pararoom', 'IdleFireKickEnabled', '`IdleFireKickEnabled` bit(1) NOT NULL DEFAULT b''0'' COMMENT ''是否开启无发炮踢出'' AFTER `IdleFireTimeoutSec`');
CALL `__mth_add_col`('pararoom', 'Enabled', '`Enabled` bit(1) NOT NULL DEFAULT b''1'' COMMENT ''桌台开关状态'' AFTER `IdleFireKickEnabled`');
CALL `__mth_add_col`('pararoom', 'MinBetUnits', '`MinBetUnits` int(11) NOT NULL DEFAULT 0 COMMENT ''最小下注炮值(整数单位，显示值x10)'' AFTER `Enabled`');
CALL `__mth_add_col`('pararoom', 'MaxBetUnits', '`MaxBetUnits` int(11) NOT NULL DEFAULT 0 COMMENT ''最大下注炮值(整数单位，显示值x10)'' AFTER `MinBetUnits`');

CALL `__mth_add_col`('parabetroom', 'TableName', '`TableName` varchar(64) NULL DEFAULT NULL COMMENT ''桌名'' AFTER `DefaultBetIndex`');
CALL `__mth_add_col`('parabetroom', 'MaxSeats', '`MaxSeats` int(11) NOT NULL DEFAULT 6 COMMENT ''最大坐席数，配合C++端数组扩容'' AFTER `TableName`');
CALL `__mth_add_col`('parabetroom', 'IdleFireTimeoutSec', '`IdleFireTimeoutSec` int(11) NOT NULL DEFAULT 0 COMMENT ''无发炮踢出时间(秒)'' AFTER `MaxSeats`');
CALL `__mth_add_col`('parabetroom', 'IdleFireKickEnabled', '`IdleFireKickEnabled` bit(1) NOT NULL DEFAULT b''0'' COMMENT ''是否开启无发炮踢出'' AFTER `IdleFireTimeoutSec`');
CALL `__mth_add_col`('parabetroom', 'Enabled', '`Enabled` bit(1) NOT NULL DEFAULT b''1'' COMMENT ''桌台开关状态'' AFTER `IdleFireKickEnabled`');

DROP PROCEDURE IF EXISTS `__mth_add_col`;

UPDATE `pararoom` SET `MinBetUnits` = `BET_MIN` * 10 WHERE `MinBetUnits` = 0;
UPDATE `pararoom` SET `MaxBetUnits` = `BET_MAX` * 10 WHERE `MaxBetUnits` = 0;
