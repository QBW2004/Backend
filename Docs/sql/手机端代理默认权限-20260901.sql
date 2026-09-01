-- 手机端后台代理默认权限与中奖播报记录（幂等）
-- 普通代理 PRIV 1-8：启用冻结、吃分、上下分、整条线踢人/管理；
-- 禁用控牌、放水、删除用户、查看用户/代理密码、删除代理、踢人开关。
UPDATE admin
SET IsFrozen = 1,
    IsProbability = 0,
    IsKicking = 0,
    IsDelete = 0,
    IsUpDown = 1,
    KickScope = 2,
    IsCreateAgent = 1,
    IsViewPwd = 0,
    IsViewSafePwd = 0,
    IsKill = 1,
    IsRelease = 0,
    ManageScope = 2
WHERE PRIV BETWEEN 1 AND 8;

UPDATE agent_permission_template
SET IsUpDown = 1,
    IsFrozen = 1,
    IsProbability = 0,
    IsKicking = 0,
    KickScope = 2,
    IsDelete = 0,
    IsCreateAgent = 1,
    IsViewPwd = 0,
    ManageScope = 2,
    IsKill = 1,
    IsRelease = 0
WHERE `Level` BETWEEN 1 AND 8;

CREATE TABLE IF NOT EXISTS gameprizerecord (
    ID BIGINT NOT NULL AUTO_INCREMENT,
    EventId VARCHAR(64) NOT NULL,
    UserID VARCHAR(50) NOT NULL,
    GameId INT NOT NULL,
    GameType INT NOT NULL DEFAULT 0,
    RoomId BIGINT NOT NULL DEFAULT 0,
    TableId BIGINT NOT NULL DEFAULT 0,
    CardType VARCHAR(100) NULL,
    Multiplier DECIMAL(12,2) NOT NULL DEFAULT 0,
    Score BIGINT NOT NULL DEFAULT 0,
    IsManualControl TINYINT NOT NULL DEFAULT 0,
    IsBroadcast TINYINT NOT NULL DEFAULT 0,
    RecTime DATETIME NOT NULL,
    PRIMARY KEY (ID),
    UNIQUE KEY uq_gameprizerecord_event (EventId),
    KEY ix_gameprizerecord_user_time (UserID, RecTime),
    KEY ix_gameprizerecord_game_time (GameId, RecTime),
    KEY ix_gameprizerecord_broadcast_game (IsBroadcast, GameId, RecTime)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 已存在的历史表也统一为显式未播报默认值；游戏服仍必须在结算时明确传入标志。
ALTER TABLE gameprizerecord ALTER COLUMN IsBroadcast SET DEFAULT 0;

-- MySQL 5.7 没有 ADD INDEX IF NOT EXISTS，使用元数据判断保证重复执行不报错。
SET @game_time_index_exists = (
    SELECT COUNT(*)
    FROM information_schema.STATISTICS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'gameprizerecord'
      AND INDEX_NAME = 'ix_gameprizerecord_game_time'
);
SET @game_time_index_sql = IF(
    @game_time_index_exists = 0,
    'ALTER TABLE gameprizerecord ADD INDEX ix_gameprizerecord_game_time (GameId, RecTime)',
    'SELECT 1'
);
PREPARE game_time_index_stmt FROM @game_time_index_sql;
EXECUTE game_time_index_stmt;
DEALLOCATE PREPARE game_time_index_stmt;
