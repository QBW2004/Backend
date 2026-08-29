-- ----------------------------------------------------------------------------
-- 性能索引补丁（2026-08-29，配合手机端后台数据加载优化审查）
-- 幂等脚本，可安全重复执行：逐索引检查 information_schema.STATISTICS，
-- 不存在才 ADD，已存在自动跳过，不再报 Duplicate key name。
-- 背景：users / userrelations / useroptlog / rechargerecords / agencyoptlog /
--       loginmissrecord 原本只有主键，后台玩家列表、记录查询、日志清理全部全表扫描。
-- 仅在当前所选数据库(DATABASE())上执行；执行前请确认已 USE 目标库。
-- ----------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS `__mth_add_index`;
DELIMITER $$
CREATE PROCEDURE `__mth_add_index`(IN p_tbl VARCHAR(64), IN p_idx VARCHAR(64), IN p_ddl TEXT)
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.STATISTICS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = p_tbl AND INDEX_NAME = p_idx
  ) THEN
    SET @s = CONCAT('ALTER TABLE `', p_tbl, '` ', p_ddl);
    PREPARE st FROM @s;
    EXECUTE st;
    DEALLOCATE PREPARE st;
  END IF;
END$$
DELIMITER ;

-- users：后台所有玩家列表按代理(AGENCY)过滤；在线/离线页签按 INHALL 过滤
CALL `__mth_add_index`('users', 'idx_users_agency', 'ADD INDEX `idx_users_agency`(`AGENCY`)');
CALL `__mth_add_index`('users', 'idx_users_inhall', 'ADD INDEX `idx_users_inhall`(`INHALL`)');

-- userrelations：玩家列表全部 JOIN userrelations ON ID（原来只有 UserID 主键，ID 无索引）
CALL `__mth_add_index`('userrelations', 'idx_userrelations_id', 'ADD INDEX `idx_userrelations_id`(`ID`)');

-- useroptlog：每玩家最新记录(UserID+LID)、玩家历史查询、按时间的 7 天清理
CALL `__mth_add_index`('useroptlog', 'idx_useroptlog_userid_lid', 'ADD INDEX `idx_useroptlog_userid_lid`(`UserID`, `LID`)');
CALL `__mth_add_index`('useroptlog', 'idx_useroptlog_rectime', 'ADD INDEX `idx_useroptlog_rectime`(`REC_TIME`)');

-- rechargerecords：充退记录按玩家/代理/时间查询，及按时间的 7 天清理
CALL `__mth_add_index`('rechargerecords', 'idx_rechargerecords_createtime', 'ADD INDEX `idx_rechargerecords_createtime`(`CreateTime`)');
CALL `__mth_add_index`('rechargerecords', 'idx_rechargerecords_gameid', 'ADD INDEX `idx_rechargerecords_gameid`(`GameID`)');
CALL `__mth_add_index`('rechargerecords', 'idx_rechargerecords_agency', 'ADD INDEX `idx_rechargerecords_agency`(`Agency`)');

-- agencyoptlog：按时间的 7 天清理；拉黑/解封记录(OPT=24/25)查询
CALL `__mth_add_index`('agencyoptlog', 'idx_agencyoptlog_rectime', 'ADD INDEX `idx_agencyoptlog_rectime`(`REC_TIME`)');

-- loginmissrecord：登录失败锁定/异常账号解封按账号(ID)查记录
CALL `__mth_add_index`('loginmissrecord', 'idx_loginmissrecord_id', 'ADD INDEX `idx_loginmissrecord_id`(`ID`)');

-- user_daily_winloss：超管"今日总输赢"按 DAY 聚合（主键 (UserID, DAY) 无法用 DAY 前缀）；
-- 同时把 UserID 字符集统一为 utf8mb4，否则与 users.ID 做 JOIN 时跨字符集隐式转换、无法走索引。
DROP PROCEDURE IF EXISTS `__mth_fix_udw_charset`;
DELIMITER $$
CREATE PROCEDURE `__mth_fix_udw_charset`()
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'user_daily_winloss'
      AND COLUMN_NAME = 'UserID' AND CHARACTER_SET_NAME <> 'utf8mb4'
  ) THEN
    ALTER TABLE `user_daily_winloss`
      MODIFY `UserID` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL;
  END IF;
END$$
DELIMITER ;
CALL `__mth_fix_udw_charset`();

CALL `__mth_add_index`('user_daily_winloss', 'idx_udw_day', 'ADD INDEX `idx_udw_day`(`DAY`)');

DROP PROCEDURE IF EXISTS `__mth_add_index`;
DROP PROCEDURE IF EXISTS `__mth_fix_udw_charset`;
