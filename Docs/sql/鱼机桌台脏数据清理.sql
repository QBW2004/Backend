-- ============================================================
-- 文件：中文总结.sql
-- 用途：历史脏数据（幽灵桌台 / 超额房间 / 孤儿游戏）清洗汇总脚本。
-- 说明：本文件汇总 4 个清洗分类，合计预期清理 244 行，全部仅作用于 para* 业务配置表，
--       绝不触碰 users/accountlog/safe_coins_log/admin/gamemo 等核心用户/资金/权限表。
-- 执行规范：每一节先执行【只读 SELECT】核对条数，与注释预期一致后，再执行该节
--           START TRANSACTION ... COMMIT 事务块；条数异常时把 COMMIT 改为 ROLLBACK。
-- 编码：UTF-8 (No BOM)。执行前请确认已 USE 目标库（mth）。
-- ============================================================


-- ############################################################
-- 第 1 节：清理失效鱼机桌台参数（parafish 超出 tableMax，预期 186 行）
-- ############################################################
-- 文件：清理失效鱼机桌台参数.txt
-- 目标表：parafish（鱼机/牌机桌台参数表，属业务配置，非核心用户/资金表）
-- 用途：清理 parafish 中超出引擎真实 tableMax 的"幽灵桌台"行。
--
-- 根因说明：
--   中心服引擎（ServerCenterNew/Database.cpp -> GetFishPara/GetCardPara）固定
--   每游戏 ROOM_MAX=3 个房间，真实桌台数 tableMax = 房间0~2 的 NUM 之和；
--   引擎只读取 ID 落在 [GAME_ID*1000, GAME_ID*1000+tableMax-1] 的 parafish 行，
--   更高位的 ID 行是历史 "GAME_ID*1000+i" 硬编码遗留下来的幽灵数据，引擎从不加载，
--   仅会扰乱后台桌台列表与统计，必须清除。
--
-- 安全须知：
--   1) 先执行【第一步】只读 SELECT，核对实际条数是否与注释预期一致；
--   2) 一致后再整体执行【第二步】事务块；若条数异常，请将末尾 COMMIT 改为 ROLLBACK。
--   3) 本脚本仅操作 parafish 业务配置表，绝不触碰 users/accountlog/safe_coins_log/admin 等核心表。
-- ============================================================

-- 【第一步·只读核对】预期总计 186 行
--   游戏 3/6/13/21/22/32/33/42：各 21 行（偏移 9~29），合计 168 行；
--   游戏 49：18 行（偏移 12~29）。
SELECT GAME_ID, COUNT(*) AS ghost_rows, MIN(ID) AS min_id, MAX(ID) AS max_id
FROM parafish
WHERE (GAME_ID IN (3,6,13,21,22,32,33,42) AND ID >= GAME_ID*1000 + 9)
   OR (GAME_ID = 49 AND ID >= 49*1000 + 12)
GROUP BY GAME_ID
ORDER BY GAME_ID;

-- 【第二步·事务清理】核对无误后整体执行。
START TRANSACTION;

-- 鱼机游戏 3/6/13/21/22/32/33/42：房间0~2 各 NUM=3 -> 真实 tableMax=9，
-- 故引擎仅加载偏移 0~8；删除偏移 >= 9 的桌台行（偏移 9~29，每游戏 21 行）。
DELETE FROM parafish
WHERE GAME_ID IN (3,6,13,21,22,32,33,42)
  AND ID >= GAME_ID*1000 + 9;

-- 鱼机游戏 49：房间0~2 各 NUM=4 -> 真实 tableMax=12，
-- 故引擎仅加载偏移 0~11；删除偏移 >= 12 的桌台行（偏移 12~29，共 18 行）。
DELETE FROM parafish
WHERE GAME_ID = 49
  AND ID >= 49*1000 + 12;

-- 受影响总行数应为 186；确认无误执行 COMMIT，否则执行 ROLLBACK 回滚。
COMMIT;


-- ############################################################
-- 第 2 节：清理失效鱼机房间配置（pararoom 房间偏移>=3，预期 4 行）
-- ############################################################
-- ============================================================
-- 文件：清理失效鱼机房间配置.txt
-- 目标表：pararoom（鱼机/牌机房间参数表，属业务配置，非核心用户/资金表）
-- 用途：清理 pararoom 中超出引擎 ROOM_MAX=3 的"幽灵房间"行。
--
-- 根因说明：
--   引擎固定每游戏 3 个房间，仅读取 ID 偏移为 0/1/2 的房间行
--   （ID = GAME_ID*1000 + 0/1/2）；偏移 >= 3 的房间行是旧版"多房间"配置遗留，
--   GetFishPara/GetCardPara 从不读取，纯属幽灵数据。
--
-- 现存幽灵行：
--   游戏 19：19003 / 19004 / 19005（旧 6 房间配置，引擎只认前 3 房）
--   游戏 49：49003（旧 4 房间配置，引擎只认前 3 房）
--
-- 删除后影响（与引擎运行态一致，无副作用）：
--   游戏 19 仍保留房间0~2（各 NUM=6 -> tableMax=18，与 parafish 18 行严格一致）；
--   游戏 49 仍保留房间0~2（各 NUM=4 -> tableMax=12）。引擎加载结果不变。
--
-- 安全须知：先执行 SELECT 核对，再执行事务块；异常时把 COMMIT 改为 ROLLBACK。
-- ============================================================

-- 【第一步·只读核对】预期 4 行：19003,19004,19005,49003
SELECT ID, GAME_ID, NUM
FROM pararoom
WHERE GAME_ID IN (19,49)
  AND (ID % 1000) >= 3
ORDER BY ID;

-- 【第二步·事务清理】
START TRANSACTION;

-- 删除游戏 19、49 中房间偏移 >= 3 的幽灵房间行（引擎 ROOM_MAX=3，从不加载）。
DELETE FROM pararoom
WHERE GAME_ID IN (19,49)
  AND (ID % 1000) >= 3;

-- 受影响行数应为 4；确认无误执行 COMMIT，否则 ROLLBACK 回滚。
COMMIT;


-- ############################################################
-- 第 3 节：清理失效押注房间配置（parabetroom 房间偏移>=3，预期 1 行）
-- ############################################################
-- ============================================================
-- 文件：清理失效押注房间配置.txt
-- 目标表：parabetroom（押注类游戏房间参数表，属业务配置，非核心用户/资金表）
-- 用途：清理 parabetroom 中超出引擎 ROOM_MAX=3 的"幽灵房间"行。
--
-- 根因说明：
--   押注引擎（ServerCenterNew/Database.cpp -> GetBetPara）同样固定每游戏 3 个房间，
--   仅读取 ID 偏移 0/1/2；偏移 >= 3 的房间行为旧版多房间配置遗留，引擎从不加载。
--
-- 现存幽灵行：
--   游戏 29：29003（旧 4 房间配置，各 NUM=4；引擎只读房间0~2 -> tableMax=12，
--            parabet 正好 12 行，故房间偏移 3 的 29003 为纯幽灵行）。
--
-- 删除后影响：引擎运行态不变（本就只读房间0~2）。
-- 安全须知：先执行 SELECT 核对，再执行事务块；异常时把 COMMIT 改为 ROLLBACK。
-- ============================================================

-- 【第一步·只读核对】预期 1 行：29003
SELECT ID, GAME_ID, NUM
FROM parabetroom
WHERE GAME_ID = 29
  AND (ID % 1000) >= 3
ORDER BY ID;

-- 【第二步·事务清理】
START TRANSACTION;

-- 删除游戏 29 中房间偏移 >= 3 的幽灵房间行（引擎 ROOM_MAX=3，从不加载）。
DELETE FROM parabetroom
WHERE GAME_ID = 29
  AND (ID % 1000) >= 3;

-- 受影响行数应为 1；确认无误执行 COMMIT，否则 ROLLBACK 回滚。
COMMIT;


-- ############################################################
-- 第 4 节：清理幽灵游戏配置（games 不存在的游戏 51/52，预期 53 行）
-- ############################################################
-- ============================================================
-- 文件：清理幽灵游戏配置.txt
-- 目标表：paragame / pararoom / parafish / paracard（均为业务配置表，非核心表）
-- 用途：清理 games 主表中不存在的"幽灵游戏"（GameId 51、52）残留的全部参数配置。
--
-- 根因说明：
--   游戏 51、52 不在 games 主表（已下线或历史误建），但其在各 para* 参数表中
--   仍残留整套配置行，属于无主的孤儿数据，引擎与后台均不应再引用，须整体清除。
--
-- 现存孤儿行（合计 53 行）：
--   paragame：2 行（ID=51,52）
--   pararoom：6 行（51000~51002、52000~52002）
--   parafish：30 行（51000~51029）
--   paracard：15 行（52000~52014）
--   parabet / parabetroom：0 行（无残留）
--
-- 安全须知：
--   1) 先执行【第一步】只读 SELECT 汇总，核对各表条数与上表一致；
--   2) 一致后再整体执行【第二步】事务块；异常时把 COMMIT 改为 ROLLBACK。
--   3) 仅操作 para* 业务配置表，绝不触碰核心用户/资金/权限表。
-- ============================================================

-- 【第一步·只读核对】各表孤儿行汇总，预期：paragame=2 / pararoom=6 / parafish=30 / paracard=15
SELECT 'paragame' AS tbl, COUNT(*) AS rows_cnt FROM paragame WHERE ID IN (51,52)
UNION ALL SELECT 'pararoom', COUNT(*) FROM pararoom WHERE GAME_ID IN (51,52)
UNION ALL SELECT 'parafish', COUNT(*) FROM parafish WHERE GAME_ID IN (51,52)
UNION ALL SELECT 'paracard', COUNT(*) FROM paracard WHERE GAME_ID IN (51,52);

-- 同时确认 51、52 确实不在 games 主表（返回空集即为确认孤儿）。
SELECT GameId FROM games WHERE GameId IN (51,52);

-- 【第二步·事务清理】
START TRANSACTION;

-- 删除幽灵游戏 51、52 的房间配置（pararoom，预期 6 行）。
DELETE FROM pararoom WHERE GAME_ID IN (51,52);

-- 删除幽灵游戏 51 的鱼机桌台参数（parafish，预期 30 行）。
DELETE FROM parafish WHERE GAME_ID IN (51,52);

-- 删除幽灵游戏 52 的牌机桌台参数（paracard，预期 15 行）。
DELETE FROM paracard WHERE GAME_ID IN (51,52);

-- 最后删除幽灵游戏自身的总参数行（paragame，预期 2 行）。
DELETE FROM paragame WHERE ID IN (51,52);

-- 受影响总行数应为 53；确认无误执行 COMMIT，否则 ROLLBACK 回滚。
COMMIT;
