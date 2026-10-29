-- 大厅排行榜独立保留每款游戏最新 30 条，避免后台七天明细清理导致榜单丢失。
-- 在目标业务库执行。上线前备份，先迁移，再更新后台和游戏服。
CREATE TABLE IF NOT EXISTS `gamerankhistory` (
    `ID` BIGINT NOT NULL AUTO_INCREMENT,
    `GameId` INT NOT NULL,
    `Slot` INT NOT NULL,
    `EventId` VARCHAR(64) NOT NULL,
    `UserID` VARCHAR(50) NOT NULL,
    `CardType` VARCHAR(100) NULL,
    `Score` BIGINT NOT NULL,
    `RecTime` DATETIME NOT NULL,
    PRIMARY KEY (`ID`),
    UNIQUE KEY `uq_rank_game_slot` (`GameId`, `Slot`),
    UNIQUE KEY `uq_rank_event` (`EventId`),
    KEY `ix_rank_time` (`RecTime`, `ID`),
    KEY `ix_rank_game_id` (`GameId`, `ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 仅首次回填各游戏现存的中奖历史；重复执行不覆盖已经运行的环形记录。
DROP PROCEDURE IF EXISTS `__mth_seed_rank_20261027`;
DELIMITER $$
CREATE PROCEDURE `__mth_seed_rank_20261027`()
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE game_id INT;
    DECLARE game_cursor CURSOR FOR SELECT DISTINCT GameId FROM gameprizerecord;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
    OPEN game_cursor;
    game_loop: LOOP
        FETCH game_cursor INTO game_id;
        IF done = 1 THEN LEAVE game_loop; END IF;
        IF NOT EXISTS (SELECT 1 FROM gamerankhistory WHERE GameId = game_id) THEN
            SET @rank_slot = -1;
            INSERT INTO gamerankhistory(GameId,Slot,EventId,UserID,CardType,Score,RecTime)
            SELECT GameId,(@rank_slot := @rank_slot + 1),EventId,UserID,CardType,Score,RecTime
            FROM (
                SELECT ID,GameId,EventId,UserID,CardType,Score,RecTime
                FROM gameprizerecord WHERE GameId = game_id AND Score > 0
                ORDER BY RecTime DESC, ID DESC LIMIT 30
            ) latest ORDER BY RecTime ASC, ID ASC;
        END IF;
    END LOOP;
    CLOSE game_cursor;
END$$
DELIMITER ;
CALL `__mth_seed_rank_20261027`();
DROP PROCEDURE `__mth_seed_rank_20261027`;
