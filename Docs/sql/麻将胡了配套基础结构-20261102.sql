-- 04：补齐本轮中心服实际使用的基础结构。MySQL 5.7；不重写已有业务数据。
-- 先备份目标库，再按 01/02/03/04 顺序执行。重复执行不会清空控制备份或配置。
CREATE TABLE IF NOT EXISTS `clientpackage` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `Name` varchar(50) NOT NULL,
  `AppKey` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `Enabled` tinyint NOT NULL DEFAULT 1,
  `RealTableIndex` tinyint NOT NULL DEFAULT 0,
  `Remark` varchar(200) NOT NULL DEFAULT '',
  `CreateTime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `UpdateTime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`ID`), UNIQUE KEY `uk_clientpackage_appkey` (`AppKey`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `betgamecfg` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `GAME_ID` int NOT NULL,
  `TableIndex` int NOT NULL,
  `CfgJson` varchar(16000) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`ID`), UNIQUE KEY `uk_game_table` (`GAME_ID`,`TableIndex`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC;

CREATE TABLE IF NOT EXISTS `totalkill_table_backup` (
  `UserID` varchar(64) NOT NULL,
  `GameID` int NOT NULL DEFAULT 0,
  `TableID` int NOT NULL DEFAULT 0,
  `GameType` int NOT NULL DEFAULT 0,
  `DIF` int NOT NULL DEFAULT 0,
  `SITE_TYPE` int NOT NULL DEFAULT 0,
  `CardProbs` varchar(512) NOT NULL DEFAULT '',
  `CreateTime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`UserID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

SET @mjhl_ddl = IF((SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='users' AND COLUMN_NAME='CURRENT_GAME')=0,
  'ALTER TABLE users ADD COLUMN CURRENT_GAME int NOT NULL DEFAULT 0', 'SELECT 1');
PREPARE mjhl_stmt FROM @mjhl_ddl;
EXECUTE mjhl_stmt;
DEALLOCATE PREPARE mjhl_stmt;
SET @mjhl_ddl = IF((SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='users' AND COLUMN_NAME='CURRENT_ROOM')=0,
  'ALTER TABLE users ADD COLUMN CURRENT_ROOM int NOT NULL DEFAULT 0', 'SELECT 1');
PREPARE mjhl_stmt FROM @mjhl_ddl;
EXECUTE mjhl_stmt;
DEALLOCATE PREPARE mjhl_stmt;
SET @mjhl_ddl = IF((SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='users' AND COLUMN_NAME='CURRENT_TABLE')=0,
  'ALTER TABLE users ADD COLUMN CURRENT_TABLE int NOT NULL DEFAULT 0', 'SELECT 1');
PREPARE mjhl_stmt FROM @mjhl_ddl;
EXECUTE mjhl_stmt;
DEALLOCATE PREPARE mjhl_stmt;
SET @mjhl_ddl = IF((SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='users' AND COLUMN_NAME='IS_PLAYING')=0,
  'ALTER TABLE users ADD COLUMN IS_PLAYING tinyint NOT NULL DEFAULT 0', 'SELECT 1');
PREPARE mjhl_stmt FROM @mjhl_ddl;
EXECUTE mjhl_stmt;
DEALLOCATE PREPARE mjhl_stmt;

-- clientpackage 已存在时保留所有包登记；新建空表必须先登记实际使用的客户端包，
-- 否则中心服会拒绝未登记 AppKey。不能用测试包口令覆盖正式包的登记。
