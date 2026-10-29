-- 2026-10-29 拉霸类去掉「一到五级筹码」并清空已存的按桌筹码
-- 范围：明星97(16) / 水果拉霸(40) / 水浒传(53) / 麻将胡了(54) 的 roomtableconfig_bet 按桌行。
-- 拉霸类在该表只存 BetScores/DefaultBetIndex（其余列恒 0），删除后游戏服下发空串，客户端回退房间级默认筹码
-- （parabetroom base 行 BetScores）。押注加减改由「每次增加的分值」(roomtableconfig.GunPowerStep) 决定。
-- 后台 1.0.70 起拉霸桌台保存时也会逐桌清空，本脚本一次性清掉存量。
--
-- 执行步骤（线上写操作，先经运营确认）：
--   1) 备份：mysqldump --single-transaction --hex-blob mth roomtableconfig_bet > roomtableconfig_bet_before_20261029.sql
--   2) 先跑下面的 SELECT 核对将被清除的行；
--   3) 执行 DELETE；
--   4) 让中心服重推配置：后台「游戏配置」对这四款游戏各打开一张桌台点一次保存（会发 PC 热更），无需重启中心服；
--      玩家下次选桌/进桌即按房间默认筹码显示。

SELECT GAME_ID, TableIndex, BetScores, DefaultBetIndex
FROM roomtableconfig_bet
WHERE GAME_ID IN (16, 40, 53, 54)
ORDER BY GAME_ID, TableIndex;

DELETE FROM roomtableconfig_bet WHERE GAME_ID IN (16, 40, 53, 54);
