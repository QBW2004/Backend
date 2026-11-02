-- 03：先应用「麻将胡了免费恢复-20261102.sql」（02），再应用本迁移。
-- 本轮仅允许导入 127.0.0.1:3307 / mth_local_mjhl；不连接正式环境。
-- 整币进度继续使用 usercontrolstatus.ConsumedCoins，余数按恢复行 ScorePerCoin * 200 归一化。
-- 控制 ID 更替即清旧余数；钱包、免费进度、控制进度、操作收据同事务提交。
-- 本迁移不猜测或改写旧版以原分累计的历史进度；上线交接时需核对旧控制，
-- 经业务确认后结束旧控制并重新建立，不能直接把历史 ConsumedCoins 除以当前兑换比例。
SET NAMES utf8mb4;
SET @mjhl_control_id_exists=(SELECT COUNT(*) FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA=DATABASE() AND LOWER(TABLE_NAME)='mjhl_recovery_state' AND COLUMN_NAME='ControlProgressID');
SET @mjhl_control_id_ddl=IF(@mjhl_control_id_exists=0,
    'ALTER TABLE mjhl_recovery_state ADD COLUMN ControlProgressID BIGINT UNSIGNED NOT NULL DEFAULT 0', 'SELECT 1');
PREPARE mjhl_control_id_statement FROM @mjhl_control_id_ddl;
EXECUTE mjhl_control_id_statement;
DEALLOCATE PREPARE mjhl_control_id_statement;

SET @mjhl_control_tail_exists=(SELECT COUNT(*) FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA=DATABASE() AND LOWER(TABLE_NAME)='mjhl_recovery_state' AND COLUMN_NAME='ControlRemainderTicks');
SET @mjhl_control_tail_ddl=IF(@mjhl_control_tail_exists=0,
    'ALTER TABLE mjhl_recovery_state ADD COLUMN ControlRemainderTicks BIGINT UNSIGNED NOT NULL DEFAULT 0', 'SELECT 1');
PREPARE mjhl_control_tail_statement FROM @mjhl_control_tail_ddl;
EXECUTE mjhl_control_tail_statement;
DEALLOCATE PREPARE mjhl_control_tail_statement;
