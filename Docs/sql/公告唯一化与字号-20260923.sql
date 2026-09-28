-- ============================================================
-- 全屏公告「唯一化 + 字号」补丁（2026-09-23）
-- ============================================================
-- 背景：客户端已改成只展示一条公告（大厅 Notice 面板「Scroll View」里的一个 Label），
--   后台「全屏公告」页也从「列表 + 新增/修改/删除」改成「进入即编辑唯一公告」。
--
-- 本补丁做两件事：
--   1) 把历史多余的公告行清掉，只留最新一条（ID 最大的那条 = 最近发布的一条）。
--      中心服 ServerCenterNew::MessageNotice 是把 notice 表**所有行**都下发给客户端的，
--      残留多行会让客户端又收到多条公告；后台保存时也会再收敛一次。
--   2) 给 notice 表加 FONTSIZE 列（公告字号，客户端 Label 的 mFontSize，设计基准 41）。
--      ⚠️ 必须先执行本补丁再部署后台新版本：后台实体 M_Notice 已含 FONTSIZE，
--         列不存在时公告页读取会直接报 "Unknown column 'FONTSIZE'"。
--
-- 字号怎么下发到客户端：中心服只下发 TITLE / NOTICE 两个字符串，报文里没有字号字段，
--   所以后台保存时按需把 `[SIZE=nn]` 前缀写进 NOTICE（字号 = 默认 41 时不写），
--   客户端解析该前缀后套用到 Label 上并把它从正文剥掉（见客户端 LibAlg/Notice.cs）。
--
-- 幂等：可重复执行。ALTER 用 information_schema 判定后再执行，列已存在时只打印一行提示；
--   「保留最新一条」的 DELETE 放在最前面，即使 ALTER 那步因环境差异报错也不影响它生效。
--   （注意：mysql 客户端默认遇到错误即中断脚本，所以脚本内所有语句都做成了可重复执行。）
-- 回滚：ALTER TABLE `notice` DROP COLUMN `FONTSIZE`;（回滚后后台公告页会报未知列，
--       需同时回滚后台代码；已清掉的历史公告行无法恢复，如需保留请先备份。）
-- ============================================================

USE mth;

-- 1) 只保留最新一条公告（表里原本没有多条时这一步不删任何行）
DELETE n1 FROM `notice` n1
  JOIN `notice` n2 ON n1.ID < n2.ID;

-- 2) 字号列（列宽/默认值与 M_Notice.FONTSIZE 对应）
SET @has_fontsize := (SELECT COUNT(*) FROM information_schema.COLUMNS
                      WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'notice' AND COLUMN_NAME = 'FONTSIZE');

SET @ddl_fontsize := IF(@has_fontsize = 0,
  'ALTER TABLE `notice` ADD COLUMN `FONTSIZE` int(11) NOT NULL DEFAULT 41 COMMENT ''公告字号（客户端 Label mFontSize，默认 41）'' AFTER `NOTICE`',
  'SELECT ''notice.FONTSIZE 已存在，跳过加列'' AS info');

PREPARE stmt_fontsize FROM @ddl_fontsize;
EXECUTE stmt_fontsize;
DEALLOCATE PREPARE stmt_fontsize;

-- 3) 执行后自检（应只有 0 或 1 行）
-- SELECT ID, TITLE, FONTSIZE, CHAR_LENGTH(NOTICE) AS LEN FROM `notice` ORDER BY ID;
