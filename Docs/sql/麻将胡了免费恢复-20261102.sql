-- 配套中心服/麻将服/H5 使用；本轮仅导入 127.0.0.1:3307 的 mth_local_mjhl。
-- 正式环境需开发者另行备份、停旧版写入并授权后实施。
-- MySQL 5.7；相关资金表必须为 InnoDB；innodb_flush_log_at_trx_commit=1。
-- max_allowed_packet 至少 134217728，应用连接须重新建立后才获得新值。
SET NAMES utf8mb4;
SET @mjhl_revision_exists=(SELECT COUNT(*) FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA=DATABASE() AND LOWER(TABLE_NAME)='users' AND COLUMN_NAME='MJHL_WALLET_REV');
SET @mjhl_revision_ddl=IF(@mjhl_revision_exists=0,
    'ALTER TABLE Users ADD COLUMN MJHL_WALLET_REV BIGINT UNSIGNED NOT NULL DEFAULT 0', 'SELECT 1');
PREPARE mjhl_revision_statement FROM @mjhl_revision_ddl;
EXECUTE mjhl_revision_statement;
DEALLOCATE PREPARE mjhl_revision_statement;

CREATE TABLE IF NOT EXISTS mjhl_recovery_state (
    UserID VARCHAR(256) NOT NULL,
    Version BIGINT UNSIGNED NOT NULL DEFAULT 0,
    LoginSession BIGINT UNSIGNED NOT NULL DEFAULT 0,
    ScorePerCoin INT UNSIGNED NOT NULL DEFAULT 1,
    RemainderTicks INT UNSIGNED NOT NULL DEFAULT 0,
    CostUnitsRemainder BIGINT UNSIGNED NOT NULL DEFAULT 0,
    StateJson LONGTEXT NOT NULL,
    LastResultJson LONGTEXT NOT NULL,
    LastOperationID VARCHAR(128) COLLATE utf8mb4_bin NOT NULL DEFAULT '',
    UpdatedAt TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
    PRIMARY KEY (UserID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS mjhl_recovery_operation (
    UserID VARCHAR(256) NOT NULL,
    OperationID VARCHAR(128) COLLATE utf8mb4_bin NOT NULL,
    Version BIGINT UNSIGNED NOT NULL,
    LoginSession BIGINT UNSIGNED NOT NULL,
    RequestHash CHAR(40) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    DebitTicks BIGINT NOT NULL,
    WinTicks BIGINT NOT NULL,
    BeforeTicks BIGINT NOT NULL,
    AfterTicks BIGINT NOT NULL,
    ResultJson LONGTEXT NOT NULL,
    CreatedAt TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    PRIMARY KEY (UserID,OperationID),
    KEY IX_mjhl_recovery_operation_version(UserID,Version)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
