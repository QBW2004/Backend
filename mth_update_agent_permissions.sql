-- 代理权限设置页新增权限字段（默认全部关闭）
-- 执行前请备份 mth 库。
-- 注意：本脚本只需成功执行一次。若报 1060 Duplicate column 说明字段已存在（例如本机开发库在功能实现时已应用过），可直接忽略。
USE mth;

ALTER TABLE `admin`
  ADD COLUMN `IsDeleteAgent` int(11) NOT NULL DEFAULT 0 COMMENT '删除代理权限 0无 1有',
  ADD COLUMN `IsViewAgentPwd` int(11) NOT NULL DEFAULT 0 COMMENT '查看代理密码权限(仅直属代理) 0无 1有',
  ADD COLUMN `IsModifyAgentPwd` int(11) NOT NULL DEFAULT 0 COMMENT '修改代理密码权限(仅直属代理) 0无 1有';
