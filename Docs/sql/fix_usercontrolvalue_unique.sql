-- ============================================================
-- 控牌游戏隔离修复：usercontrolvalue 每游戏一行
-- 执行前请先备份 usercontrolvalue 表！
--   备份: CREATE TABLE usercontrolvalue_bak AS SELECT * FROM usercontrolvalue;
-- ============================================================

-- 1. 清理重复行：保留每个 (USERID, CONTROL_TYPE) 中 ID 最大的 1 行，删除其余
--    (旧代码 INSERT ... ON DUPLICATE KEY UPDATE 因主键为 (ID,USERID) 从不触发 UPDATE，
--     导致反复下发时堆积大量重复行，必须清理)
DELETE uc FROM usercontrolvalue uc
LEFT JOIN (
    SELECT USERID, CONTROL_TYPE, MAX(ID) AS keep_id
    FROM usercontrolvalue
    GROUP BY USERID, CONTROL_TYPE
) k ON uc.USERID = k.USERID AND uc.CONTROL_TYPE = k.CONTROL_TYPE
WHERE uc.ID <> k.keep_id OR k.keep_id IS NULL;

-- 2. 加唯一索引：保证每个 (USERID, CONTROL_TYPE) 只有一行（每游戏一行）
ALTER TABLE `usercontrolvalue`
    ADD UNIQUE INDEX `uk_userid_ctrltype`(`USERID`, `CONTROL_TYPE`) USING BTREE;

-- 3. 验证清理结果（应返回 0 行）
-- SELECT USERID, CONTROL_TYPE, COUNT(*) FROM usercontrolvalue GROUP BY USERID, CONTROL_TYPE HAVING COUNT(*) > 1;
