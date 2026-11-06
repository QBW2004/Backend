-- MySQL 5.7; back up before applying. No historical quota or account data is changed.
SET @robot_limit_ddl = IF(
    (SELECT COUNT(*) FROM information_schema.COLUMNS
     WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='robot_seat' AND COLUMN_NAME='MAX_PER_TABLE') = 0,
    'ALTER TABLE robot_seat ADD COLUMN MAX_PER_TABLE INT NOT NULL DEFAULT 0 COMMENT ''Robot limit per table; 0 means legacy quota''',
    'SELECT 1');
PREPARE robot_limit_stmt FROM @robot_limit_ddl;
EXECUTE robot_limit_stmt;
DEALLOCATE PREPARE robot_limit_stmt;
