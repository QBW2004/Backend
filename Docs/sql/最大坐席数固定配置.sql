-- ----------------------------------------------------------------------------
-- 最大坐席数(MaxSeats)固定配置：坐席数由本脚本统一设定，后台不再可编辑。
-- 鱼机类型(GameType=2)统一 6 人座；牌机类型(GameType=1)无桌位记 0。
-- 押注类型：彩金单挑(2)/幸运六狮(10) 为 8 人桌；金鲨银鲨(29)/奔驰宝马(47) 无桌记 0。
-- 可安全重复执行；执行前请确认已 USE 目标库。
-- ----------------------------------------------------------------------------

UPDATE `pararoom` r
JOIN `games` g ON g.`GameId` = r.`GAME_ID`
SET r.`MaxSeats` = 6
WHERE g.`GameType` = 2;

UPDATE `pararoom` r
JOIN `games` g ON g.`GameId` = r.`GAME_ID`
SET r.`MaxSeats` = 0
WHERE g.`GameType` = 1;

UPDATE `parabetroom` SET `MaxSeats` = 8 WHERE `GAME_ID` IN (2, 10);
UPDATE `parabetroom` SET `MaxSeats` = 0 WHERE `GAME_ID` IN (29, 47);
