-- ============================================================
-- 修复鱼机"房间级底注/兑换"与桌台配置不一致问题
--
-- 背景：
--   鱼机一房N桌模型下，服务端 GetFishPara 按 roomMax=1 只读 base 行
--   (ID = GAME_ID*1000)，房间级底注/兑换全部取自该行。
--   旧版后台保存鱼机桌台时只写 roomtableconfig(按桌) 和按桌行
--   (ID=GAME_ID*1000+TableIndex)，从不同步 base 行，
--   导致新建/编辑桌台后子游戏收到的房间底注仍是旧值(例如内部 2-1000 而非 10-1000)。
--
-- 本脚本：把 base 行的底注/兑换字段按某张参考桌(默认 TableIndex=0)的
--   roomtableconfig 同步为一致。请先执行【只读核对】，确认参考桌的值
--   与全部桌台一致后再执行【修复】。
--
-- 说明：decimal 鱼机(0.1分炮)内部单位 = 显示值 × 10，
--   roomtableconfig.BetMin/BetMax 存的就是内部单位，可直接复制到 MinBetUnits/MaxBetUnits。
-- ============================================================

-- 【只读核对】19 号鱼机当前 base 行 与 各桌 roomtableconfig
SELECT 'pararoom base 行' AS src, ID, GAME_ID, NUM, BET_MIN, BET_MAX,
       MinBetUnits, MaxBetUnits, EX_COIN, COIN_SC, COIN_NEED
  FROM ParaRoom WHERE GAME_ID = 19 AND ID = 19000;

SELECT 'roomtableconfig 各桌' AS src, TableIndex, TableName, Enabled,
       BetMin, BetMax, OneCoinScore, CoinsNeed
  FROM roomtableconfig WHERE GAME_ID = 19 ORDER BY TableIndex;

-- ============================================================
-- 【修复】以 TableIndex=0 的桌台配置为准，同步 base 行
--   （若各桌底注不同，请自行决定以哪张桌为准；通常全桌一致）
-- ============================================================
START TRANSACTION;

UPDATE ParaRoom pr
JOIN roomtableconfig r
  ON r.GAME_ID = pr.GAME_ID AND r.RoomIndex = 0 AND r.TableIndex = 0
SET pr.BET_MIN     = r.BetMin,
    pr.BET_MAX     = r.BetMax,
    pr.MinBetUnits = r.BetMin,       -- decimal 鱼机内部单位(显示值×10)
    pr.MaxBetUnits = r.BetMax,
    pr.EX_COIN     = 10000,          -- 兑换单位(若无特殊配置保持默认)
    pr.COIN_SC     = r.OneCoinScore, -- 兑换币值
    pr.COIN_NEED   = r.CoinsNeed     -- 入场金币
WHERE pr.GAME_ID = 19 AND pr.ID = 19000;

COMMIT;

-- 【复核】修复后应看到 MinBetUnits=10, MaxBetUnits=1000(即 1.0-100 显示)
SELECT ID, GAME_ID, NUM, MinBetUnits, MaxBetUnits, EX_COIN, COIN_SC, COIN_NEED
  FROM ParaRoom WHERE GAME_ID = 19 AND ID = 19000;
