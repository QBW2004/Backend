-- 手机端后台权限与 7x24 小时记录保留补丁（幂等）
-- 执行前请 USE mth；脚本只创建中奖记录表（缺失时）和查询/清理所需索引。

CREATE TABLE IF NOT EXISTS `gameprizerecord` (
    `ID` BIGINT NOT NULL AUTO_INCREMENT,
    `EventId` VARCHAR(64) NOT NULL,
    `UserID` VARCHAR(50) NOT NULL,
    `GameId` INT NOT NULL,
    `GameType` INT NOT NULL DEFAULT 0,
    `RoomId` BIGINT NOT NULL DEFAULT 0,
    `TableId` BIGINT NOT NULL DEFAULT 0,
    `CardType` VARCHAR(100) NULL,
    `Multiplier` DECIMAL(12,2) NOT NULL DEFAULT 0,
    `Score` BIGINT NOT NULL DEFAULT 0,
    `IsManualControl` TINYINT NOT NULL DEFAULT 0,
    `IsBroadcast` TINYINT NOT NULL DEFAULT 0,
    `RecTime` DATETIME NOT NULL,
    PRIMARY KEY (`ID`),
    UNIQUE KEY `uq_gameprizerecord_event` (`EventId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

DROP PROCEDURE IF EXISTS `__mth_add_mobile_index_20260902`;
DELIMITER $$
CREATE PROCEDURE `__mth_add_mobile_index_20260902`(
    IN p_tbl VARCHAR(64),
    IN p_idx VARCHAR(64),
    IN p_ddl TEXT
)
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.TABLES
        WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = p_tbl
    ) AND NOT EXISTS (
        SELECT 1 FROM information_schema.STATISTICS
        WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = p_tbl AND INDEX_NAME = p_idx
    ) THEN
        SET @mobile_idx_sql = CONCAT('ALTER TABLE `', p_tbl, '` ', p_ddl);
        PREPARE mobile_idx_stmt FROM @mobile_idx_sql;
        EXECUTE mobile_idx_stmt;
        DEALLOCATE PREPARE mobile_idx_stmt;
    END IF;
END$$
DELIMITER ;

CALL `__mth_add_mobile_index_20260902`('agencyoptlog', 'idx_agencyoptlog_rectime',
    'ADD INDEX `idx_agencyoptlog_rectime` (`REC_TIME`)');
CALL `__mth_add_mobile_index_20260902`('agencyoptlog', 'idx_agencyoptlog_target_opt_time',
    'ADD INDEX `idx_agencyoptlog_target_opt_time` (`ID`, `OPT`, `REC_TIME`)');
CALL `__mth_add_mobile_index_20260902`('useroptlog', 'idx_useroptlog_rectime',
    'ADD INDEX `idx_useroptlog_rectime` (`REC_TIME`)');
CALL `__mth_add_mobile_index_20260902`('rechargerecords', 'idx_rechargerecords_createtime',
    'ADD INDEX `idx_rechargerecords_createtime` (`CreateTime`)');
CALL `__mth_add_mobile_index_20260902`('rechargerecords', 'idx_rechargerecords_processed_time_game',
    'ADD INDEX `idx_rechargerecords_processed_time_game` (`Processed`, `CreateTime`, `GameID`)');
CALL `__mth_add_mobile_index_20260902`('manageropt', 'idx_manageropt_time',
    'ADD INDEX `idx_manageropt_time` (`TIME`)');
CALL `__mth_add_mobile_index_20260902`('tablecoinrecord', 'idx_tablecoinrecord_createtime',
    'ADD INDEX `idx_tablecoinrecord_createtime` (`CreateTime`)');
CALL `__mth_add_mobile_index_20260902`('clientexchangerecord', 'idx_clientexchangerecord_createtime',
    'ADD INDEX `idx_clientexchangerecord_createtime` (`CreateTime`)');
CALL `__mth_add_mobile_index_20260902`('gameprizerecord', 'ix_gameprizerecord_user_time',
    'ADD INDEX `ix_gameprizerecord_user_time` (`UserID`, `RecTime`)');
CALL `__mth_add_mobile_index_20260902`('gameprizerecord', 'ix_gameprizerecord_game_time',
    'ADD INDEX `ix_gameprizerecord_game_time` (`GameId`, `RecTime`)');
CALL `__mth_add_mobile_index_20260902`('gameprizerecord', 'ix_gameprizerecord_broadcast_game',
    'ADD INDEX `ix_gameprizerecord_broadcast_game` (`IsBroadcast`, `GameId`, `RecTime`)');

DROP PROCEDURE IF EXISTS `__mth_add_mobile_index_20260902`;
