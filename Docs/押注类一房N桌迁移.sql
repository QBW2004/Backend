-- ============================================================================
-- 押注类「一房N桌」数据迁移脚本
-- 适用游戏: game_id 2(彩金单挑)/10(幸运六狮)/29(金鲨银鲨)/47(奔驰宝马)
--
// 迁移目标(与后台 B_BetGamePara/B_SuperPara 改造后的模型对齐):
--   paragame.ROOM_MAX = 1                       (1个房间)
--   parabetroom   只留 1 行 base 行(ID=gameId*1000), NUM = roomtableconfig 条数(桌台数)
--   roomtableconfig  按桌存(TableIndex 0..N-1), 不变(已是按桌)
--   parabet       按桌存(ID=gameId*1000+TableIndex), 清理多余自动回填行
--   cardpayoutprofile 按桌存(TableId=TableIndex), 不变(已是按桌)
--
// 迁移以 roomtableconfig 为准(它代表真实配置的桌台)。
-- 迁移前请先备份数据库！
-- ============================================================================

-- 临时表：记录每个押注游戏的桌台数(以 roomtableconfig 为准)
DROP TEMPORARY TABLE IF EXISTS tmp_bet_table_count;
CREATE TEMPORARY TABLE tmp_bet_table_count AS
SELECT GAME_ID, COUNT(*) AS tbl_cnt, MIN(TableIndex) AS min_idx, MAX(TableIndex) AS max_idx
FROM roomtableconfig
WHERE GAME_ID IN (2, 10, 29, 47)
GROUP BY GAME_ID;

-- ============================================================================
-- 步骤1: paragame.ROOM_MAX 设为 1
-- ============================================================================
UPDATE paragame SET ROOM_MAX = 1 WHERE ID IN (2, 10, 29, 47);

-- ============================================================================
-- 步骤2: parabetroom 合并为 1 行 base 行
--   - 若该游戏已有多行(ID=gameId*1000+0..k)，把最小 ID 行(ID=gameId*1000)作为 base 行保留
--   - 删除其余非 base 行
--   - base 行 NUM = roomtableconfig 条数
--   - 若该游戏在 parabetroom 没有任何行(如29/47)，则插入一条默认 base 行
-- ============================================================================

-- 2a. 对已存在 base 行的游戏：更新 base 行的 NUM = 桌台数
UPDATE parabetroom pb
INNER JOIN tmp_bet_table_count c ON pb.GAME_ID = c.GAME_ID
SET pb.NUM = c.tbl_cnt
WHERE pb.ID = pb.GAME_ID * 1000;

-- 2b. 删除非 base 行(保留 ID=gameId*1000 这一行)
DELETE pb FROM parabetroom pb
WHERE pb.GAME_ID IN (2, 10, 29, 47)
  AND pb.ID <> pb.GAME_ID * 1000;

-- 2c. 对没有 base 行的游戏(如29/47)：插入默认 base 行
INSERT INTO parabetroom (ID, GAME_ID, BET_TIME, NUM, BET_MAX, BET_MIN,
    BET_MAX_VICE, BET_MIN_VICE, BET_MAX_DRAW, BET_MIN_DRAW,
    EX_COIN, COIN_SC, COIN_NEED, BANKER_SC_NEED, SC_LIMIT_SING, SC_LIMIT_ALL,
    Game_MO, BetScores, DefaultBetIndex, TableName, MaxSeats, IdleFireTimeoutSec, IdleFireKickEnabled, Enabled)
SELECT g.GAME_ID * 1000, g.GAME_ID, 10, IFNULL(c.tbl_cnt, 0), 1000, 10,
    1000, 10, 1000, 10,
    10000, 1, 0, 500000, 3000, 10000,
    100, '1,5,10,15,20', 0, '默认桌', 6, 0, 1, 1
FROM (SELECT 2 AS GAME_ID UNION SELECT 10 UNION SELECT 29 UNION SELECT 47) g
LEFT JOIN tmp_bet_table_count c ON g.GAME_ID = c.GAME_ID
WHERE NOT EXISTS (
    SELECT 1 FROM parabetroom pb WHERE pb.ID = g.GAME_ID * 1000
);

-- ============================================================================
-- 步骤3: parabet 清理多余的自动回填行，只保留与 roomtableconfig 对应的桌
--   历史上 GetBetPara 的自动 INSERT 回填机制会按 tableMax 循环插入 parabet，
--   导致 parabet 行数远超实际桌台数(如 game_id=2 有 97 行)。
--   一房N桌后，parabet 行数应 = roomtableconfig 条数，ID = gameId*1000+TableIndex。
-- ============================================================================

-- 3a. 删除 parabet 中"没有对应 roomtableconfig 桌台"的行
DELETE pb FROM parabet pb
LEFT JOIN roomtableconfig rtc ON pb.GAME_ID = rtc.GAME_ID AND pb.ID = (pb.GAME_ID * 1000 + rtc.TableIndex)
WHERE pb.GAME_ID IN (2, 10, 29, 47)
  AND rtc.ID IS NULL;

-- 3b. 对 roomtableconfig 有桌但 parabet 缺行的桌，补插入默认难度行
--     (parabet.ID = gameId*1000 + TableIndex)
INSERT INTO parabet (ID, GAME_ID, DIF, HAR, SITE_TYPE, BANKER_DIF, BANKER_HAR, BANKER_SITE_TYPE, BANKER_PER, Kill_Big)
SELECT (rtc.GAME_ID * 1000 + rtc.TableIndex), rtc.GAME_ID, 4, 4, 1, 0, 0, 1, 30, 0
FROM roomtableconfig rtc
LEFT JOIN parabet pb ON pb.ID = (rtc.GAME_ID * 1000 + rtc.TableIndex)
WHERE rtc.GAME_ID IN (2, 10, 29, 47)
  AND pb.ID IS NULL;

-- ============================================================================
-- 步骤4: 校验查询(执行后人工核对)
-- ============================================================================

-- 4a. 每个押注游戏的桌台数一致性校验
--     期望: rtc_cnt = pb_cnt = parabetroom.NUM, 且 paragame.ROOM_MAX = 1
SELECT
    g.ID AS game_id,
    g.ROOM_MAX AS room_max,
    IFNULL(c.rtc_cnt, 0) AS roomtableconfig_cnt,
    IFNULL(p.parabet_cnt, 0) AS parabet_cnt,
    pb.NUM AS parabetroom_num,
    (SELECT COUNT(*) FROM parabetroom WHERE GAME_ID = g.ID) AS parabetroom_row_cnt
FROM paragame g
LEFT JOIN (SELECT GAME_ID, COUNT(*) AS rtc_cnt FROM roomtableconfig WHERE GAME_ID IN (2,10,29,47) GROUP BY GAME_ID) c ON g.ID = c.GAME_ID
LEFT JOIN (SELECT GAME_ID, COUNT(*) AS parabet_cnt FROM parabet WHERE GAME_ID IN (2,10,29,47) GROUP BY GAME_ID) p ON g.ID = p.GAME_ID
LEFT JOIN parabetroom pb ON pb.ID = g.ID * 1000
WHERE g.ID IN (2, 10, 29, 47);

-- 4b. parabetroom 应每游戏恰好 1 行(base 行)
--     期望: row_cnt = 1, ID = game_id*1000
SELECT GAME_ID, COUNT(*) AS row_cnt, MIN(ID) AS min_id, MAX(ID) AS max_id
FROM parabetroom
WHERE GAME_ID IN (2, 10, 29, 47)
GROUP BY GAME_ID;

-- 4c. parabet ID 应连续 = gameId*1000+0..N-1
SELECT pb.GAME_ID, pb.ID, pb.ID - pb.GAME_ID*1000 AS table_index
FROM parabet pb
WHERE pb.GAME_ID IN (2, 10, 29, 47)
ORDER BY pb.GAME_ID, pb.ID;

-- 清理临时表
DROP TEMPORARY TABLE IF EXISTS tmp_bet_table_count;

-- ============================================================================
-- 注意事项:
-- 1. 迁移后需重启或 RP 热更押注类游戏，让服务端 GetBetPara 按 ROOM_MAX=1 重新加载。
-- 2. roomtableconfig_bet 表由 center 在收到 TC 命令时写入，本脚本不处理。
--    迁移后建议在后台对每张押注桌台执行一次"保存"(触发 TC 推送)，让 center 重建 roomtableconfig_bet。
-- 3. 历史机器人记录(ROOM_ID=1/2/3 的押注类机器人)在改造后 ROOM_ID 语义变为恒0，
--    如需清理可执行: UPDATE robot_seat SET ROOM_ID=0 WHERE GAME_ID IN (2,10,29,47) AND ROOM_ID<>0;
--    (robot_seat 是 M_Robot 实体映射的表名)
-- ============================================================================
