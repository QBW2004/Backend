-- ============================================================================
-- 押注类数据修复脚本(清理 roomtableconfig_bet 孤儿行 + 字段统一)
-- 适用游戏: game_id 2/10/29/47
--
-- 问题背景:
--   roomtableconfig_bet 原由 center 在收到 TC 命令时写入，但 TC 命令因命名管道
--   问题频繁失败(historical pipe issue)，导致此表长期没写入或残留孤儿行。
--   现已改为后台 B_BetGamePara.SaveTableFull 直接写 roomtableconfig_bet(不依赖 TC)。
--   本脚本用于修复历史遗留的脏数据：删除孤儿行、统一字段、补齐缺行。
--
-- 修复目标:
--   1. 删除 roomtableconfig_bet 中没有对应 roomtableconfig 桌台的孤儿行
--   2. 统一 roomtableconfig_bet 的 BetMin/BetMax/CoinsNeed/OneCoinScore 与 roomtableconfig 一致
--   3. 统一 roomtableconfig_bet 的 BetTime/BetScores/BankerScoreNeed 等(从 parabetroom base 行取)
--   4. 统一 parabetroom base 行的 TableName(不再是某个具体桌名)
--   5. 补齐 roomtableconfig 有桌但 roomtableconfig_bet 缺行的桌
-- ============================================================================

-- ---------------------------------------------------------------------------
-- 步骤1: 删除 roomtableconfig_bet 中的孤儿行(没有对应 roomtableconfig 桌台)
-- ---------------------------------------------------------------------------
DELETE rb FROM roomtableconfig_bet rb
LEFT JOIN roomtableconfig rtc ON rb.GAME_ID = rtc.GAME_ID AND rb.TableIndex = rtc.TableIndex
WHERE rb.GAME_ID IN (2, 10, 29, 47)
  AND rtc.ID IS NULL;

-- ---------------------------------------------------------------------------
-- 步骤2: 统一 roomtableconfig_bet 的桌级参数与 roomtableconfig 一致
--   BetMin/BetMax/CoinsNeed/OneCoinScore 以 roomtableconfig 为准
-- ---------------------------------------------------------------------------
UPDATE roomtableconfig_bet rb
INNER JOIN roomtableconfig rtc ON rb.GAME_ID = rtc.GAME_ID AND rb.TableIndex = rtc.TableIndex
SET
    rb.BetMin      = rtc.BetMin,
    rb.BetMax      = rtc.BetMax,
    rb.CoinsNeed   = rtc.CoinsNeed,
    rb.OneCoinScore = rtc.OneCoinScore
WHERE rb.GAME_ID IN (2, 10, 29, 47);

-- ---------------------------------------------------------------------------
-- 步骤3: 统一 roomtableconfig_bet 的房级参数与 parabetroom base 行一致
--   BetTime/BankerScoreNeed/ItemSingleScoreLimit/ItemAllScoreLimit/BetScores/
--   DefaultBetIndex/BetMinVice/BetMaxVice/BetMinDraw/BetMaxDraw 从 base 行取
-- ---------------------------------------------------------------------------
UPDATE roomtableconfig_bet rb
INNER JOIN parabetroom pb ON pb.ID = rb.GAME_ID * 1000
SET
    rb.BetTime             = pb.BET_TIME,
    rb.BankerScoreNeed     = pb.BANKER_SC_NEED,
    rb.ItemSingleScoreLimit = pb.SC_LIMIT_SING,
    rb.ItemAllScoreLimit   = pb.SC_LIMIT_ALL,
    rb.BetScores           = pb.BetScores,
    rb.DefaultBetIndex     = IFNULL(pb.DefaultBetIndex, 0),
    rb.BetMinVice          = pb.BET_MIN_VICE,
    rb.BetMaxVice          = pb.BET_MAX_VICE,
    rb.BetMinDraw          = pb.BET_MIN_DRAW,
    rb.BetMaxDraw          = pb.BET_MAX_DRAW
WHERE rb.GAME_ID IN (2, 10, 29, 47);

-- ---------------------------------------------------------------------------
-- 步骤4: 修正 parabetroom base 行的 TableName(不应是某个具体桌名)
--   base 行是房级参数，TableName 字段对 base 行无意义，置空或设为游戏默认名
-- ---------------------------------------------------------------------------
UPDATE parabetroom SET TableName = '' WHERE ID IN (2000, 10000, 29000, 47000);

-- ---------------------------------------------------------------------------
-- 步骤5: 补齐 roomtableconfig_bet 缺失的桌台行
--   对 roomtableconfig 有但 roomtableconfig_bet 缺的桌，用 base 行参数插入
-- ---------------------------------------------------------------------------
INSERT INTO roomtableconfig_bet (GAME_ID, RoomIndex, TableIndex, BetTime, BetMin, BetMax,
    BankerScoreNeed, ItemSingleScoreLimit, ItemAllScoreLimit, CoinsNeed, OneCoinScore,
    BetScores, DefaultBetIndex, BetMinVice, BetMaxVice, BetMinDraw, BetMaxDraw)
SELECT rtc.GAME_ID, 0, rtc.TableIndex, pb.BET_TIME, rtc.BetMin, rtc.BetMax,
    pb.BANKER_SC_NEED, pb.SC_LIMIT_SING, pb.SC_LIMIT_ALL, rtc.CoinsNeed, rtc.OneCoinScore,
    pb.BetScores, IFNULL(pb.DefaultBetIndex, 0), pb.BET_MIN_VICE, pb.BET_MAX_VICE,
    pb.BET_MIN_DRAW, pb.BET_MAX_DRAW
FROM roomtableconfig rtc
INNER JOIN parabetroom pb ON pb.ID = rtc.GAME_ID * 1000
LEFT JOIN roomtableconfig_bet rb ON rb.GAME_ID = rtc.GAME_ID AND rb.TableIndex = rtc.TableIndex
WHERE rtc.GAME_ID IN (2, 10, 29, 47)
  AND rb.ID IS NULL;

-- ---------------------------------------------------------------------------
-- 步骤6: 校验查询
-- ---------------------------------------------------------------------------
-- 6a. 每个押注游戏的桌台数一致性
--     期望: rtc_cnt = rbc_cnt, 且都 = parabetroom.NUM
SELECT
    g.ID AS game_id,
    g.ROOM_MAX,
    IFNULL(r.cnt, 0) AS roomtableconfig_cnt,
    IFNULL(b.cnt, 0) AS roomtableconfig_bet_cnt,
    pb.NUM AS parabetroom_num
FROM paragame g
LEFT JOIN (SELECT GAME_ID, COUNT(*) AS cnt FROM roomtableconfig WHERE GAME_ID IN (2,10,29,47) GROUP BY GAME_ID) r ON g.ID = r.GAME_ID
LEFT JOIN (SELECT GAME_ID, COUNT(*) AS cnt FROM roomtableconfig_bet WHERE GAME_ID IN (2,10,29,47) GROUP BY GAME_ID) b ON g.ID = b.GAME_ID
LEFT JOIN parabetroom pb ON pb.ID = g.ID * 1000
WHERE g.ID IN (2, 10, 29, 47);

-- 6b. roomtableconfig 与 roomtableconfig_bet 桌级参数一致性
--     期望: rtc.BetMin=rb.BetMin, rtc.BetMax=rb.BetMax 等
SELECT rtc.GAME_ID, rtc.TableIndex, rtc.TableName,
       rtc.BetMin AS rtc_BetMin, rb.BetMin AS rb_BetMin,
       rtc.BetMax AS rtc_BetMax, rb.BetMax AS rb_BetMax,
       rtc.CoinsNeed AS rtc_CoinsNeed, rb.CoinsNeed AS rb_CoinsNeed,
       rtc.OneCoinScore AS rtc_OneCoinScore, rb.OneCoinScore AS rb_OneCoinScore,
       rb.BetScores, rb.BetTime
FROM roomtableconfig rtc
LEFT JOIN roomtableconfig_bet rb ON rb.GAME_ID = rtc.GAME_ID AND rb.TableIndex = rtc.TableIndex
WHERE rtc.GAME_ID IN (2, 10, 29, 47)
ORDER BY rtc.GAME_ID, rtc.TableIndex;

-- ---------------------------------------------------------------------------
-- 注意事项:
-- 1. 执行后必须重启 center 或触发 RP 热更，让服务端重新加载 roomtableconfig_bet。
-- 2. 修复后建议在后台对每张押注桌台执行一次"保存"，触发 TC 推送让 center 重建 roomtableconfig_bet。
-- 3. 此脚本可重复执行(幂等)。
-- ============================================================================
