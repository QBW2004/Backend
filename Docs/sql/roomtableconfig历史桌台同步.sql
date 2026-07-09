-- ============================================================================
-- roomtableconfig 历史桌台同步脚本
-- 用途：把后台已配置在 pararoom(鱼机/牌机) / parabetroom(押注) 的桌台，
--       一次性同步到 roomtableconfig 表(C++ center 读取、下发给客户端的那张表)。
-- 背景：此前 roomtableconfig 无人写入(为空)，TC 命令只对之后新保存的桌台生效，
--       历史桌台需用本脚本灌入。拉霸(明星97/水果拉霸/水浒传)桌名不在 pararoom，单独按游戏补一行。
--
-- 执行规范：先执行【第0步】核对列名 → 再执行【第1步】只读核对条数 →
--           条数符合预期后执行【第2步】事务同步；异常把 COMMIT 改 ROLLBACK。
-- 执行前请确认已 USE 目标库(mth)。
-- ============================================================================


-- ############################################################
-- 第 0 步：探测 roomtableconfig 的真实列名(只读，必先执行)
-- ############################################################
-- 用途：确认列名大小写，避免 INSERT 列不匹配。
-- 重点关注：TableName / IdleFireTimeoutSec / IdleFireKickEnabled / MaxSeats 是否存在。
SELECT TABLE_NAME, COLUMN_NAME, COLUMN_TYPE, IS_NULLABLE, COLUMN_DEFAULT
FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'roomtableconfig'
ORDER BY ORDINAL_POSITION;

-- ★ 若上述查询发现列名与下文 INSERT 中的不一致(如驼峰拼写不同)，
--   请把下文所有 INSERT 的列名替换为 information_schema 查出的实际列名后再执行。


-- ############################################################
-- 第 1 步：只读核对——预期同步的桌台条数(必先执行)
-- ############################################################
-- 1.1 鱼机/牌机桌台(pararoom)：每个 GAME_ID 的每张桌台一行
SELECT 'pararoom' AS src, COUNT(*) AS rows_cnt FROM pararoom
UNION ALL
-- 1.2 押注桌台(parabetroom)
SELECT 'parabetroom', COUNT(*) FROM parabetroom
UNION ALL
-- 1.3 拉霸(gameType=3)：每游戏一行(RoomIndex=0,TableIndex=0)，仅同步 Enable=1 的
--     当前 3 款(服务端已初始化)：明星97=16 / 水果拉霸=40 / 水浒传=53，均 Enable=1。
--     39/41/45 虽 GameType=3 但 Enable=0(无源码)，自动排除。
--     摇钱树(19)为鱼机(GameType=2)，已随 pararoom 同步，不在本步。
--     ⚠ 若计数 >3，说明 games 存在重复 GameId(此前 GameId=40 有脏数据重复)，
--        必须先清理 games(见下方说明)再继续，否则第2步会因 ID 主键冲突失败。
SELECT 'laba_games', COUNT(*) FROM games WHERE GameType = 3 AND Enable = 1;

-- 预期总条数 = pararoom 行数 + parabetroom 行数 + 3(明星97/水果拉霸/水浒传)


-- ############################################################
-- 第 2 步：事务同步(核对条数无误后执行)
-- ############################################################
-- roomtableconfig 实际列(15列,已用 information_schema 核对)：
--   ID(PK,NOT NULL,无默认→必须显式给值) / GAME_ID / RoomIndex / TableIndex
--   TableName(varchar(50)) / SeatCount(NOT NULL,默认4) / ExchangeRate(varchar(20),NOT NULL,默认'1:1')
--   MinBringIn(bigint,默认0) / MaxBringIn(bigint,默认0) / IdleFireTimeoutSec(默认0)
--   IdleFireKickEnabled(int,默认0) / MinBetUnits(默认0) / DifScaled(默认0)
--   Enabled(int,默认1) / MaxSeats(默认6)
-- 策略：ID 用 GAME_ID*100000+TableIndex 保证全局唯一；未列出的列(SeatCount/
--   ExchangeRate/MinBringIn/MaxBringIn/MinBetUnits/DifScaled)走各自默认值。
--   bit 类型的列在 roomtableconfig 中实为 int，直接写 0/1 即可。
START TRANSACTION;

-- 2.0 先清空 roomtableconfig 旧数据(此前为空或仅含零星测试数据)，
--      改为以 pararoom/parabetroom 为唯一数据源全量重建，保证与后台完全一致。
DELETE FROM roomtableconfig;

-- 2.1 鱼机/牌机桌台：pararoom → roomtableconfig
--     索引映射(扁平模型)：RoomIndex=0，TableIndex=ID%1000(全局桌台偏移)。
INSERT INTO roomtableconfig
    (ID, GAME_ID, RoomIndex, TableIndex, TableName,
     IdleFireTimeoutSec, IdleFireKickEnabled, Enabled, MaxSeats)
SELECT
    r.GAME_ID * 100000 + (r.ID % 1000)               AS ID,
    r.GAME_ID,
    0                                                 AS RoomIndex,
    (r.ID % 1000)                                     AS TableIndex,
    LEFT(COALESCE(r.TableName, ''), 50)               AS TableName,   -- varchar(50) 截断
    r.IdleFireTimeoutSec                              AS IdleFireTimeoutSec,
    IF(r.IdleFireKickEnabled, 1, 0)                   AS IdleFireKickEnabled,  -- bit→int
    IF(r.Enabled, 1, 0)                               AS Enabled,              -- bit→int
    CASE WHEN r.MaxSeats BETWEEN 0 AND 8 THEN r.MaxSeats ELSE 6 END AS MaxSeats
FROM pararoom r
  JOIN games g ON g.GameId = r.GAME_ID
WHERE g.GameType IN (1, 2);   -- 1=牌机, 2=鱼机

-- 2.2 押注桌台：parabetroom → roomtableconfig
INSERT INTO roomtableconfig
    (ID, GAME_ID, RoomIndex, TableIndex, TableName,
     IdleFireTimeoutSec, IdleFireKickEnabled, Enabled, MaxSeats)
SELECT
    r.GAME_ID * 100000 + (r.ID % 1000)               AS ID,
    r.GAME_ID,
    0                                                 AS RoomIndex,
    (r.ID % 1000)                                     AS TableIndex,
    LEFT(COALESCE(r.TableName, ''), 50)               AS TableName,
    r.IdleFireTimeoutSec                              AS IdleFireTimeoutSec,
    IF(r.IdleFireKickEnabled, 1, 0)                   AS IdleFireKickEnabled,
    IF(r.Enabled, 1, 0)                               AS Enabled,
    CASE WHEN r.MaxSeats BETWEEN 0 AND 8 THEN r.MaxSeats ELSE 8 END AS MaxSeats
FROM parabetroom r
  JOIN games g ON g.GameId = r.GAME_ID
WHERE g.GameType = 0;          -- 0=押注

-- 2.3 拉霸桌台：pararoom 无对应行，按游戏补一行(RoomIndex=0,TableIndex=0)。
--     同步所有 Enable=1 的 GameType=3 游戏(当前：明星97=16 / 水果拉霸=40 / 水浒传=53)。
--     39/41/45 Enable=0 自动排除；摇钱树(19)为鱼机已随 pararoom 同步。
--     拉霸桌名此前未持久化，TableName 暂用游戏名；保存后由 TC 命令覆盖。
--     Enabled 跟随 games.Enable；IdleFire 取默认，MaxSeats=6。
--     ⚠ 前置：games 表不得有重复 GameId(否则产出重复行/ID冲突)，先跑第1步核对计数。
INSERT INTO roomtableconfig
    (ID, GAME_ID, RoomIndex, TableIndex, TableName,
     IdleFireTimeoutSec, IdleFireKickEnabled, Enabled, MaxSeats)
SELECT
    g.GameId * 100000                                 AS ID,   -- TableIndex=0
    g.GameId,
    0                                                 AS RoomIndex,
    0                                                 AS TableIndex,
    LEFT(g.Name, 50)                                  AS TableName,
    0                                                 AS IdleFireTimeoutSec,
    0                                                 AS IdleFireKickEnabled,
    IF(g.Enable, 1, 0)                                AS Enabled,   -- 跟随 games.Enable
    6                                                 AS MaxSeats
FROM games g
WHERE g.GameType = 3 AND g.Enable = 1;   -- 当前命中 16/40/53；39/41/45 Enable=0 自动排除

-- 核对同步结果条数(应与第1步预期一致)
SELECT COUNT(*) AS synced_rows FROM roomtableconfig;

-- 确认无误执行 COMMIT，否则执行 ROLLBACK。
COMMIT;


-- ############################################################
-- 第 3 步：同步后验证(只读)
-- ############################################################
-- 3.1 拉霸三款(16/40/53)是否已有桌台行(Enabled 应与 games.Enable=1 一致)
SELECT * FROM roomtableconfig WHERE GAME_ID IN (16, 40, 53) ORDER BY GAME_ID, RoomIndex, TableIndex;

-- 3.1b 摇钱树(GameId=19, 鱼机 GameType=2)随 pararoom 同步，确认已有桌台行
SELECT * FROM roomtableconfig WHERE GAME_ID = 19 ORDER BY GAME_ID, RoomIndex, TableIndex;

-- 3.2 按游戏类型汇总同步条数
SELECT g.GameType, COUNT(*) AS cnt
FROM roomtableconfig rc JOIN games g ON g.GameId = rc.GAME_ID
GROUP BY g.GameType ORDER BY g.GameType;
