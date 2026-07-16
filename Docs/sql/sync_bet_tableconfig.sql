-- ============================================================
-- 押分类（games.GameType=0）桌数口径对齐迁移脚本
-- 依据：parabetroom 每行 = 一张桌台（ID = 游戏ID*1000 + 桌号）
-- 1) roomtableconfig 按 parabetroom 现有桌台重建（清理已删桌残留、补齐缺失配置）
-- 2) parabetroom.NUM = 该游戏实际桌台行数（与后台保存逻辑一致）
-- 3) paragame.ROOM_MAX = 该游戏实际桌台行数
-- 仅影响押注类游戏（当前：2 彩金单挑 / 10 幸运六狮 / 29 金鲨银鲨 / 47 奔驰宝马），
-- 不触碰鱼机、牌机、拉霸的任何配置。
-- ============================================================

START TRANSACTION;

-- 1) 重建押分类 roomtableconfig
DELETE rtc FROM roomtableconfig rtc
JOIN games g ON g.GameId = rtc.GAME_ID AND g.GameType = 0;

INSERT INTO roomtableconfig
(GAME_ID, RoomIndex, TableIndex, TableName, Enabled, OneCoinScore, BetMin, BetMax, CoinsNeed, IdleFireTimeoutSec, IdleFireKickEnabled, MaxSeats)
SELECT r.GAME_ID, 0, r.ID - r.GAME_ID * 1000, IFNULL(r.TableName, ''), r.Enabled + 0,
       IFNULL(r.COIN_SC, 0), IFNULL(r.BET_MIN, 0), IFNULL(r.BET_MAX, 0), IFNULL(r.COIN_NEED, 0),
       r.IdleFireTimeoutSec, r.IdleFireKickEnabled + 0, r.MaxSeats
FROM parabetroom r
JOIN games g ON g.GameId = r.GAME_ID AND g.GameType = 0;

-- 2) parabetroom.NUM = 实际桌台行数
UPDATE parabetroom r
JOIN games g ON g.GameId = r.GAME_ID AND g.GameType = 0
JOIN (SELECT GAME_ID, COUNT(*) AS c FROM parabetroom GROUP BY GAME_ID) t ON t.GAME_ID = r.GAME_ID
SET r.NUM = t.c;

-- 3) paragame.ROOM_MAX = 实际桌台行数
UPDATE paragame p
JOIN games g ON g.GameId = p.ID AND g.GameType = 0
JOIN (SELECT GAME_ID, COUNT(*) AS c FROM parabetroom GROUP BY GAME_ID) t ON t.GAME_ID = p.ID
SET p.ROOM_MAX = t.c;

COMMIT;

-- 验证：
-- SELECT g.GameId, g.Name,
--        (SELECT COUNT(*) FROM parabetroom r WHERE r.GAME_ID=g.GameId) AS 桌台行数,
--        (SELECT COUNT(*) FROM roomtableconfig c WHERE c.GAME_ID=g.GameId) AS 配置条数,
--        (SELECT ROOM_MAX FROM paragame p WHERE p.ID=g.GameId) AS ROOM_MAX
-- FROM games g WHERE g.GameType=0 AND g.Enable=1;
