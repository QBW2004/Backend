-- 先执行此补丁，再发布后台与客户端。中心服注册 INSERT 未指定此列，自动使用默认值 0。
-- 仅首次新增列时兼容存量自定义昵称；重跑不能把后来注册的账号误记为已设置。
SET @nickname_column_exists = (
    SELECT COUNT(*) FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'users' AND COLUMN_NAME = 'NICKNAME_SET'
);
SET @nickname_ddl = IF(@nickname_column_exists = 0,
    'ALTER TABLE users ADD COLUMN NICKNAME_SET TINYINT NOT NULL DEFAULT 0 COMMENT ''玩家已主动设置昵称''',
    'SELECT 1');
PREPARE nickname_stmt FROM @nickname_ddl;
EXECUTE nickname_stmt;
DEALLOCATE PREPARE nickname_stmt;
SET @nickname_backfill = IF(@nickname_column_exists = 0,
    'UPDATE users SET NICKNAME_SET=1 WHERE NAME IS NOT NULL AND TRIM(NAME)<>'''' AND BINARY TRIM(NAME)<>BINARY TRIM(ID)',
    'SELECT 1');
PREPARE nickname_stmt FROM @nickname_backfill;
EXECUTE nickname_stmt;
DEALLOCATE PREPARE nickname_stmt;
