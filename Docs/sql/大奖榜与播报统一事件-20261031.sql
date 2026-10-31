-- 先备份并停止中奖写入，再在业务库执行；中心服和牌机/拉霸须配套更新。
-- 不改变中奖明细、余额、赔率或机器人配置；旧榜中无法证明为大奖的条目不继续展示。
CREATE TABLE IF NOT EXISTS prizebroadcastoutbox (
    ID BIGINT NOT NULL AUTO_INCREMENT,
    EventId VARCHAR(64) NOT NULL,
    GameId INT NOT NULL,
    LineAgent VARCHAR(50) NOT NULL DEFAULT '',
    BroadcastText TEXT NOT NULL,
    CreatedAt DATETIME NOT NULL,
    SentAt DATETIME NULL,
    PRIMARY KEY (ID),
    UNIQUE KEY uq_prize_broadcast_event (EventId),
    KEY ix_prize_broadcast_pending (SentAt,ID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

DROP PROCEDURE IF EXISTS __mth_bigwin_rank_20261031;
DELIMITER $$
CREATE PROCEDURE __mth_bigwin_rank_20261031()
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS
        WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='gamerankhistory' AND COLUMN_NAME='IsBigWin') THEN
        ALTER TABLE gamerankhistory ADD COLUMN IsBigWin TINYINT NOT NULL DEFAULT 0;
    END IF;
    UPDATE gamerankhistory h INNER JOIN gameprizerecord p ON p.EventId=h.EventId AND p.GameId=h.GameId
        SET h.IsBigWin=1 WHERE p.IsBroadcast=1 AND p.Score>=0
        AND h.GameId IN (5,14,15,16,25,37,40,44,53);
    DELETE FROM gamerankhistory WHERE IsBigWin=0;
END$$
DELIMITER ;
CALL __mth_bigwin_rank_20261031();
DROP PROCEDURE __mth_bigwin_rank_20261031;
