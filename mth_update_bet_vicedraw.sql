-- ============================================================================
-- 幸运六狮(GAME_ID=10) 庄闲/和 与 彩金单挑(GAME_ID=2) 皇冠 押分限红修改脚本
--
-- 作用表：
--   1. parabetroom          房级参数表（base 行，兜底默认值）
--   2. roomtableconfig_bet  按桌参数表（实际限红权威来源，游戏服校验用它）
--
-- 字段对应：
--   幸运六狮(GAME_ID=10)：
--     BET_MAX_VICE / BetMaxVice  = 庄闲最大押分
--     BET_MAX_DRAW / BetMaxDraw  = 和最大押分
--   彩金单挑(GAME_ID=2)：
--     BET_MIN_VICE / BetMinVice  = 皇冠最小押分
--     BET_MAX_VICE / BetMaxVice  = 皇冠最大押分
--     （彩金单挑服务端不使用"和"门，BetMaxDraw 无需改）
--
-- 生效方式（重要）：
--   直接改库【不会】立即推送服务器。两种生效方式任选其一：
--     A) 重启中心服 + 对应游戏服（启动时全量加载）；
--     B) 在后台「桌台参数 -> 押注玩法设置」随便保存一桌，
--        后台会触发热更新推送，中心服全量重推，即改即生效。
--   建议执行前先备份：mysqldump -uroot -p mth parabetroom roomtableconfig_bet > bet_backup.sql
-- ============================================================================

USE `mth`;

-- ↓↓↓ 按需修改这里的值 ↓↓↓
-- 幸运六狮（GAME_ID=10）：庄闲最大押分 / 和最大押分
SET @LionMaxVice = 5000;
SET @LionMaxDraw = 5000;
-- 彩金单挑（GAME_ID=2）：皇冠最小押分 / 皇冠最大押分
SET @CrownMinVice = 10;
SET @CrownMaxVice = 5000;
-- ↑↑↑ 修改到此为止 ↑↑↑

-- 1) 幸运六狮：庄闲 / 和
UPDATE `parabetroom`
SET `BET_MAX_VICE` = @LionMaxVice, `BET_MAX_DRAW` = @LionMaxDraw
WHERE `GAME_ID` = 10;

UPDATE `roomtableconfig_bet`
SET `BetMaxVice` = @LionMaxVice, `BetMaxDraw` = @LionMaxDraw
WHERE `GAME_ID` = 10;

-- 2) 彩金单挑：皇冠（和门服务端不用，不改）
UPDATE `parabetroom`
SET `BET_MIN_VICE` = @CrownMinVice, `BET_MAX_VICE` = @CrownMaxVice
WHERE `GAME_ID` = 2;

UPDATE `roomtableconfig_bet`
SET `BetMinVice` = @CrownMinVice, `BetMaxVice` = @CrownMaxVice
WHERE `GAME_ID` = 2;

-- 3) 回显核对
SELECT 'parabetroom(六狮)' AS note, `ID`, `GAME_ID`, `BET_MAX_VICE`, `BET_MAX_DRAW`
FROM `parabetroom` WHERE `GAME_ID` = 10;
SELECT 'parabetroom(彩金单挑)' AS note, `ID`, `GAME_ID`, `BET_MIN_VICE`, `BET_MAX_VICE`
FROM `parabetroom` WHERE `GAME_ID` = 2;
SELECT 'roomtableconfig_bet(六狮)' AS note, `TableIndex`, `GAME_ID`, `BetMaxVice`, `BetMaxDraw`
FROM `roomtableconfig_bet` WHERE `GAME_ID` = 10 ORDER BY `TableIndex`;
SELECT 'roomtableconfig_bet(彩金单挑)' AS note, `TableIndex`, `GAME_ID`, `BetMinVice`, `BetMaxVice`
FROM `roomtableconfig_bet` WHERE `GAME_ID` = 2 ORDER BY `TableIndex`;
