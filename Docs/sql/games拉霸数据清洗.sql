-- ============================================================================
-- games 表拉霸游戏数据清洗（roomtableconfig 同步前置）
-- 背景：服务端初始化脚本用 SET NAMES utf8mb4 在 GBK 客户端下执行，
--       导致 16/40/53 的 Name 乱码或为空；且 games 无主键，重复 GameId 未被
--       ON DUPLICATE KEY UPDATE 拦截。本脚本清洗 games，为 roomtableconfig
--       同步扫清阻塞（同步脚本第1.3步期望 laba_games=3）。
-- 执行前：确认已 USE 目标库(mth)。
-- 编码：先 SET NAMES gbk 匹配 GBK 客户端，MySQL 自动转 utf8mb4 存储。
--        （服务端脚本失败正因 SET NAMES utf8mb4 与 GBK 客户端不匹配）
-- ============================================================================

SET NAMES gbk;


-- ############################################################
-- 第 1 步：清洗前诊断（只读，确认现状）
-- ############################################################
-- 1.1 重复 GameId（预期 16/40 各 2 行；53 应为 1 行；其余应无重复）
SELECT GameId, COUNT(*) AS c, GROUP_CONCAT(HEX(Name) SEPARATOR ' | ') AS name_hex
FROM games GROUP BY GameId HAVING c > 1;

-- 1.2 16/40/53 现状（Name/Enable/GameType/HEX/长度）
SELECT GameId, Name, Enable, GameType, HEX(Name) AS name_hex, CHAR_LENGTH(Name) AS len
FROM games WHERE GameId IN (16, 40, 53) ORDER BY GameId;

-- 1.3 检查 parabetroom 是否有 GameId=16 的旧押注配置
--     （16 原为押注 GameType=0，改拉霸后这些行变孤儿、不再同步，影响总条数）
SELECT GAME_ID, COUNT(*) AS cnt FROM parabetroom WHERE GAME_ID = 16 GROUP BY GAME_ID;
--     返回空 = 无孤儿；返回 cnt=N = 同步时 parabetroom 少 N 行(14→14-N)


-- ############################################################
-- 第 2 步：清洗（事务，确认第1步现状后执行）
-- ############################################################
-- 策略：
--   16/40 的旧行已含正确 UTF-8 名(明星97/水果拉霸)，只删脏行 + 改 Enable/GameType，
--   Name 字节不动(零编码风险)；53 只有乱码行，用 SET NAMES gbk 重写 Name。
START TRANSACTION;

-- 2.1 GameId=16：删空名脏行，把"明星97"行改为拉霸启用(Name 不动)
DELETE FROM games WHERE GameId = 16 AND CHAR_LENGTH(Name) = 0;
UPDATE games SET Enable = 1, GameType = 3 WHERE GameId = 16;

-- 2.2 GameId=40：删单字节脏行(GBK'水'误存为 U+02EE)，把"水果拉霸"行启用
DELETE FROM games WHERE GameId = 40 AND CHAR_LENGTH(Name) = 1;
UPDATE games SET Enable = 1, GameType = 3 WHERE GameId = 40;

-- 2.3 GameId=53：仅乱码行，重写 Name(SET NAMES gbk 后 '水浒传' 正确转 utf8mb4)
UPDATE games SET Name = '水浒传', Enable = 1, GameType = 3 WHERE GameId = 53;

-- 2.4 验证：每 GameId 应恰 1 行
SELECT GameId, Name, Enable, GameType, HEX(Name) AS name_hex, CHAR_LENGTH(Name) AS len
FROM games WHERE GameId IN (16, 40, 53) ORDER BY GameId;
-- 预期(SET NAMES gbk 下 Name 列应正常显示中文)：
--   16  明星97    1  3  E6988EE6989F3937            4
--   40  水果拉霸  1  3  E6B0B4E69E9CE68B89E99CB8     4
--   53  水浒传    1  3  E6B0B4...(3字符,以水的UTF-8开头) 3

-- 确认无误执行 COMMIT，否则执行 ROLLBACK。
COMMIT;


-- ############################################################
-- 第 3 步：清洗后回到 roomtableconfig 同步脚本
-- ############################################################
-- 重跑同步脚本第1步：
--   laba_games 应为 3（此前为 2，因 GameId=40 重复被算成 2）。
--   pararoom 仍为 57；parabetroom 视第1.3步结果：无孤儿=14，有孤儿=14-N。
-- 预期总条数 = 57 + parabetroom实际条数 + 3。
-- 确认后执行同步脚本第2步。


-- ############################################################
-- 附：可选后续（不影响本次同步，建议择机处理）
-- ############################################################
-- A. games 补主键，防止再次产生重复 GameId（须先确认第1.1步查无重复）：
--      ALTER TABLE games ADD PRIMARY KEY (GameId);
--
-- B. robot_seat 的 GAME_NAME 同样被服务端脚本写乱(36 warnings)，按需清洗：
--      SET NAMES gbk;
--      UPDATE robot_seat SET GAME_NAME='明星97'   WHERE GAME_ID=16 AND GAME_TYPE=3;
--      UPDATE robot_seat SET GAME_NAME='水果拉霸' WHERE GAME_ID=40 AND GAME_TYPE=3;
--      UPDATE robot_seat SET GAME_NAME='水浒传'   WHERE GAME_ID=53 AND GAME_TYPE=3;
--
-- C. parabetroom 有 GameId=16 的 3 行旧押注配置（已确认删除）：
--    明星97已改为拉霸(GameType=3)，旧押注配置变孤儿，删除以免后台显示幽灵桌台。
DELETE FROM parabetroom WHERE GAME_ID = 16;
