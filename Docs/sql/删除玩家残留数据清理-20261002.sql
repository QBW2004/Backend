-- ============================================================================
-- 删除玩家后残留数据清理 + userrelations 重复映射去重（2026-10-02）
-- ============================================================================
-- 背景（运营反馈）：后台删除玩家后用同名账号重新注册，
--   1) 「用户管理」同一账号出现两行：userrelations 的 ID 列没有唯一约束，
--      中心服 Register 是无条件 INSERT（客户端重试/并发注册/后台与客户端
--      同时注册都会留下多条映射行），users INNER JOIN userrelations 后每个
--      账号出多行；会员盈亏统计卡的充退合计同样被重复行放大。
--   2) 新账号还带旧盈亏：user_daily_winloss / useroptlog / userloginrecord /
--      rechargerecords 等按账号串存储的表，旧删除逻辑没清，被同名新账号继承。
--
--   代码侧已修（DelUser 全量清除 + 删除前踢下线 + 所有 userrelations join
--   按 ID 取最小 UserID 去重）。本脚本清理线上存量。
--
-- ⚠️ 执行前：先确认目标账号不在线（后台踢人/玩家退出），否则在线会话还可能
--    往这些账号写新记录（写的是新账号自己的数据，不影响清理，但会干扰核对）。
-- 执行前确认已 USE 目标库（mth）。
-- ============================================================================

-- ############################################################
-- 第 0 步：执行前诊断（只读）
-- ############################################################

-- 0.1 userrelations 重复映射现状（预期能看到 a1401/a1402/a1403 各 2 行等）
SELECT ID, COUNT(*) AS c, GROUP_CONCAT(UserID ORDER BY UserID) AS userids
FROM userrelations GROUP BY ID HAVING c > 1;

-- 0.2 这三个账号的残留数据量（重注册后这些记录全部是旧账号留下的）
SELECT 'user_daily_winloss' AS tbl, COUNT(*) AS c FROM user_daily_winloss WHERE UserID IN ('a1401','a1402','a1403')
UNION ALL SELECT 'useroptlog',            COUNT(*) FROM useroptlog WHERE UserID IN ('a1401','a1402','a1403')
UNION ALL SELECT 'userloginrecord',       COUNT(*) FROM userloginrecord WHERE UserID IN ('a1401','a1402','a1403')
UNION ALL SELECT 'rechargerecords',       COUNT(*) FROM rechargerecords WHERE GameID IN ('a1401','a1402','a1403') AND AccountType = 0
UNION ALL SELECT 'agencyoptlog',          COUNT(*) FROM agencyoptlog WHERE ID IN ('a1401','a1402','a1403')
UNION ALL SELECT 'usercontrolstatus',     COUNT(*) FROM usercontrolstatus WHERE UserID IN ('a1401','a1402','a1403')
UNION ALL SELECT 'usercontrolvalue',      COUNT(*) FROM usercontrolvalue WHERE USERID IN ('a1401','a1402','a1403');


-- ############################################################
-- 第 1 步：userrelations 去重（全表，不只这三个账号）
-- ############################################################
-- 每个账号保留 UserID 最小的一行：中心服 GetUserInfo 的 INNER JOIN 按索引序
-- 只取第一行（最小 UserID），保留它 = 保留游戏服当前实际使用的映射。
START TRANSACTION;

DELETE r FROM userrelations r
INNER JOIN (SELECT ID, MIN(UserID) AS KeepID FROM userrelations GROUP BY ID) k
  ON k.ID = r.ID AND r.UserID <> k.KeepID;

-- 顺手清掉孤儿映射行（有 userrelations 但没有 users 行的，注册失败残留）
DELETE r FROM userrelations r
LEFT JOIN users u ON u.ID = r.ID
WHERE u.ID IS NULL;

-- 1.x 核对：应无输出（无重复、无孤儿）
SELECT ID, COUNT(*) AS c FROM userrelations GROUP BY ID HAVING c > 1;

COMMIT;


-- ############################################################
-- 第 2 步：指定账号的残留历史数据清除
-- ############################################################
-- ↓↓↓ 按需修改账号清单（当前为本次出问题的三个测试号）↓↓↓
-- 注意：这些账号已重新注册、users/userrelations 行必须保留，
--       这里只清历史/流水/控制类数据。
START TRANSACTION;

DELETE FROM `user_daily_winloss`       WHERE UserID    IN ('a1401','a1402','a1403');
DELETE FROM `useroptlog`               WHERE UserID    IN ('a1401','a1402','a1403');
DELETE FROM `userloginrecord`          WHERE UserID    IN ('a1401','a1402','a1403');
DELETE FROM `rechargerecords`          WHERE GameID    IN ('a1401','a1402','a1403') AND AccountType = 0;
DELETE FROM `agencyoptlog`             WHERE ID        IN ('a1401','a1402','a1403');
DELETE FROM `gameprizerecord`          WHERE UserID    IN ('a1401','a1402','a1403');
DELETE FROM `usercontrolstatus`        WHERE UserID    IN ('a1401','a1402','a1403');
DELETE FROM `usercontrolvalue`         WHERE USERID    IN ('a1401','a1402','a1403');
DELETE FROM `userscoresnapshotledger`  WHERE UserID    IN ('a1401','a1402','a1403');
DELETE FROM `clientexchangerecord`     WHERE ID        IN ('a1401','a1402','a1403');
DELETE FROM `ex_change`                WHERE PLAYER_ID IN ('a1401','a1402','a1403');
DELETE FROM `safe_coins_log`           WHERE USER_ID   IN ('a1401','a1402','a1403');
DELETE FROM `loginmissrecord`          WHERE ID        IN ('a1401','a1402','a1403');
DELETE FROM `userlockrecord`           WHERE ID        IN ('a1401','a1402','a1403');
DELETE FROM `videogamecoinrecord`      WHERE ID        IN ('a1401','a1402','a1403');
DELETE FROM `accountlog`               WHERE UserName  IN ('a1401','a1402','a1403');
DELETE FROM `transferlog`              WHERE UserName  IN ('a1401','a1402','a1403');
DELETE FROM `games_money_spent`        WHERE USERID    IN ('a1401','a1402','a1403');
DELETE FROM `sharebonus`               WHERE UserId    IN ('a1401','a1402','a1403') OR DestUserId IN ('a1401','a1402','a1403');

-- 2.x 核对：第 0.2 步的诊断查询再跑一遍应全为 0
SELECT 'user_daily_winloss' AS tbl, COUNT(*) AS c FROM user_daily_winloss WHERE UserID IN ('a1401','a1402','a1403')
UNION ALL SELECT 'useroptlog',       COUNT(*) FROM useroptlog WHERE UserID IN ('a1401','a1402','a1403')
UNION ALL SELECT 'rechargerecords',  COUNT(*) FROM rechargerecords WHERE GameID IN ('a1401','a1402','a1403') AND AccountType = 0;

COMMIT;


-- ############################################################
-- 第 3 步（强烈建议）：userrelations.ID 加唯一索引，根治重复映射
-- ############################################################
-- 前置：第 1 步已去重，否则 ALTER 会因重复值报错。
-- 效果：中心服 Register 已改为 INSERT IGNORE（ServerCenterNew/Database.cpp），
--       但只有存在唯一索引时 IGNORE 才真正去重——并发重试的第二次插入被静默跳过，
--       不再产生重复映射行；不加索引则 IGNORE 退化为普通 INSERT，问题依旧。
--       后台 Regist/Add 本就是"先查再插"，不受影响。
ALTER TABLE `userrelations` ADD UNIQUE KEY `uk_userrelations_id` (`ID`);

-- 唯一索引已覆盖查询用途，原普通索引可删（保留也无妨）：
-- ALTER TABLE `userrelations` DROP INDEX `idx_userrelations_id`;


-- ############################################################
-- 第 4 步：核对
-- ############################################################
-- 4.1 三个账号应各只有 1 条映射
SELECT r.ID, COUNT(*) AS c, GROUP_CONCAT(r.UserID) AS userids
FROM userrelations r WHERE r.ID IN ('a1401','a1402','a1403') GROUP BY r.ID;

-- 4.2 后台「用户管理」行数 = 每账号 1 行（与后台 GetUsersList 同 join 口径）
SELECT c.ID, COUNT(*) AS rows_in_list
FROM users c INNER JOIN userrelations r ON r.ID = c.ID
WHERE c.ID IN ('a1401','a1402','a1403') GROUP BY c.ID;
