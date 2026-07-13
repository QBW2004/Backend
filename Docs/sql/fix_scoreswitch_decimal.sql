-- 修改 scoreSwitch 字段从 int 改为 decimal，支持小数炮值 (0.1-0.9)
-- 执行前请备份数据库

-- 修改 ParaRoom 表的 scoreSwitch 字段
ALTER TABLE ParaRoom MODIFY COLUMN scoreSwitch DECIMAL(10,2) NULL DEFAULT 1 COMMENT '加减炮幅度(支持小数0.1-0.9)';

-- 修改 M_RoomPara_From_Page 对应的字段（如果存在）
-- ALTER TABLE RoomPara_From_Page MODIFY COLUMN scoreSwitch_0 DECIMAL(10,2) NULL DEFAULT 1 COMMENT '初级场_加炮幅度';
-- ALTER TABLE RoomPara_From_Page MODIFY COLUMN scoreSwitch_1 DECIMAL(10,2) NULL DEFAULT 1 COMMENT '中级场_加炮幅度';
-- ALTER TABLE RoomPara_From_Page MODIFY COLUMN scoreSwitch_2 DECIMAL(10,2) NULL DEFAULT 1 COMMENT '高级场_加炮幅度';
-- ALTER TABLE RoomPara_From_Page MODIFY COLUMN scoreSwitch_3 DECIMAL(10,2) NULL DEFAULT 1 COMMENT 'VIP场_加炮幅度';
