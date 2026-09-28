-- ----------------------------------------------------------------------------
-- 幸运六狮(GAME_ID=10) 庄闲/和 的最小押分跟随本桌「最低压分」（2026-09-25）
--
-- 口径：庄/闲(BET_MIN_VICE)、和(BET_MIN_DRAW) 不单独配最小值，统一取该桌最低压分
--       (roomtableconfig.BetMin / parabetroom.BET_MIN)；保存桌台时由后台按此写入。
--       最大押分仍是独立配置（页面上的「庄/闲单门最高押分」「和单门最高押分」），本脚本不动。
--
-- 为什么需要本脚本：后台代码（GameConfigController）已改为保存时按桌写这两个最小值，
--   但【库内已存在的桌台】还是历史值——线上四张桌都是 10，而各自的最低压分是 1/2/5/10，
--   不刷一次的话游戏服仍按旧值校验（庄闲和会接受低于最低压分的首次押注）。
--   也可以用后台逐桌「保存」一次代替本脚本，效果相同。
--
-- 生效方式：直接改库不会推送给在线游戏服，二选一：
--   A) 在后台「桌台设置」随便保存一桌，触发全量重推；
--   B) 重启中心服 + ServerBetAnimal（会踢掉在线玩家，慎用）。
--
-- 幂等，可安全重复执行；执行前请确认已 USE 目标库(mth)。
-- ----------------------------------------------------------------------------

-- 1) 按桌：roomtableconfig_bet.BetMinVice/BetMinDraw = roomtableconfig.BetMin
UPDATE `roomtableconfig_bet` b
JOIN `roomtableconfig` r
  ON r.`GAME_ID` = b.`GAME_ID` AND r.`TableIndex` = b.`TableIndex`
SET b.`BetMinVice` = r.`BetMin`,
    b.`BetMinDraw` = r.`BetMin`
WHERE b.`GAME_ID` = 10;

-- 2) 房级 base 行（登录房间块兜底值，客户端按桌取不到时才用它）
UPDATE `parabetroom`
SET `BET_MIN_VICE` = `BET_MIN`,
    `BET_MIN_DRAW` = `BET_MIN`
WHERE `GAME_ID` = 10;

-- 3) 回显核对：BetMinVice/BetMinDraw 应等于同表的 BetMin
SELECT 'roomtableconfig_bet(六狮)' AS note, b.`TableIndex`, r.`BetMin` AS `最低压分`,
       b.`BetMinVice`, b.`BetMaxVice`, b.`BetMinDraw`, b.`BetMaxDraw`
FROM `roomtableconfig_bet` b
JOIN `roomtableconfig` r
  ON r.`GAME_ID` = b.`GAME_ID` AND r.`TableIndex` = b.`TableIndex`
WHERE b.`GAME_ID` = 10
ORDER BY b.`TableIndex`;

SELECT 'parabetroom(六狮)' AS note, `ID`, `BET_MIN`, `BET_MIN_VICE`, `BET_MAX_VICE`,
       `BET_MIN_DRAW`, `BET_MAX_DRAW`
FROM `parabetroom` WHERE `GAME_ID` = 10;
