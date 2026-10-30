-- ============================================================
-- 多客户端包 + 代理线隔离（2026-10-30）
-- ============================================================
-- 方案：项目文档「多客戶端包與代理線隔離-2026-10」/ 后台 Docs/多客户端包与代理线隔离-20261030.md
--
-- 1) clientpackage：客户端包（换皮包）。大厅登录包里原来写死的口令串
--    "CDhP53fFb822" 改为每个包一串（AppKey），中心服按它识别包、判断启停。
--    原口令登记为 1 号「默认包」，现有线上包不受影响。
-- 2) admin.PlayableGames：超管直属代理（PRIV=1）的「玩家可玩游戏」，
--    逗号分隔 GameId；NULL = 不限（兼容现有代理线）。下级代理与玩家继承。
-- 3) roomtableowner：桌台归属。没有记录的桌 = 公共桌台；LineAgent = 直属代理账号；
--    LineAgent = '#' 表示已收回的专属桌（任何人不可见，下次分配优先复用）。
-- 4) gameprizerecord / gamerankhistory 加 LineAgent：中奖记录与大厅排行榜按线隔离，
--    '' = 公共（公共桌台上的机器人、直属超管的玩家）。排行榜 30 槽环形改为「线 × 游戏」。
--
-- 幂等：可重复执行。只加表加列，不改动既有数据（存量记录 LineAgent 回填为 ''）。
-- 部署顺序：本补丁 → 后台 + 中心服 + 子游戏服。中心服对缺表缺列有兜底（按旧口径运行），
--           但排行榜唯一键必须在新中心服上线前换好，否则新口径写入会冲突。
-- 回滚：DROP TABLE clientpackage, roomtableowner;
--       ALTER TABLE admin DROP COLUMN PlayableGames;
--       ALTER TABLE gamerankhistory DROP INDEX uq_rank_line_game_slot, ADD UNIQUE KEY uq_rank_game_slot(GameId,Slot), DROP COLUMN LineAgent;
--       ALTER TABLE gameprizerecord DROP COLUMN LineAgent;
--       （回滚排行榜唯一键前须先清理同游戏同槽位的多线记录。）
-- ============================================================

CREATE TABLE IF NOT EXISTS `clientpackage` (
  `ID` INT NOT NULL AUTO_INCREMENT COMMENT '包编号',
  `Name` VARCHAR(50) NOT NULL COMMENT '包名称（后台显示）',
  `AppKey` VARCHAR(32) NOT NULL COMMENT '包内登录口令（大厅登录包第二个字段）',
  `Enabled` TINYINT NOT NULL DEFAULT 1 COMMENT '1启用 0停用（停用后该包无法登录大厅）',
  `RealTableIndex` TINYINT NOT NULL DEFAULT 0 COMMENT '1=选桌按真实桌号显示，可进入有专属桌台的游戏',
  `Remark` VARCHAR(200) NULL DEFAULT NULL COMMENT '备注',
  `CreateTime` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `UpdateTime` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `uq_clientpackage_appkey` (`AppKey`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='客户端包（换皮包）';

INSERT IGNORE INTO `clientpackage` (`ID`, `Name`, `AppKey`, `Enabled`, `RealTableIndex`, `Remark`)
VALUES (1, '默认包', 'CDhP53fFb822', 1, 0, '2026-10-30 之前发布的线上包');

CREATE TABLE IF NOT EXISTS `roomtableowner` (
  `GAME_ID` INT NOT NULL COMMENT '游戏ID',
  `RoomIndex` INT NOT NULL DEFAULT 0 COMMENT '房间号（与 roomtableconfig 同口径）',
  `TableIndex` INT NOT NULL COMMENT '桌号（与 roomtableconfig 同口径，游戏内全局唯一）',
  `LineAgent` VARCHAR(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '直属代理账号；# = 已收回',
  `CreateTime` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`GAME_ID`, `RoomIndex`, `TableIndex`),
  KEY `ix_roomtableowner_line` (`LineAgent`, `GAME_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='桌台归属：无记录=公共桌台';

DROP PROCEDURE IF EXISTS `__mth_line_scope_20261030`;
DELIMITER $$
CREATE PROCEDURE `__mth_line_scope_20261030`()
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS
                   WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'admin' AND COLUMN_NAME = 'PlayableGames') THEN
        ALTER TABLE `admin` ADD COLUMN `PlayableGames` VARCHAR(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci
            NULL DEFAULT NULL COMMENT '玩家可玩游戏（仅直属代理有效，逗号分隔GameId，NULL=不限）';
    END IF;

    IF EXISTS (SELECT 1 FROM information_schema.TABLES
               WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'gameprizerecord')
       AND NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS
                       WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'gameprizerecord' AND COLUMN_NAME = 'LineAgent') THEN
        ALTER TABLE `gameprizerecord` ADD COLUMN `LineAgent` VARCHAR(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci
            NOT NULL DEFAULT '' COMMENT '归属代理线（直属代理账号，空=公共）';
    END IF;

    IF EXISTS (SELECT 1 FROM information_schema.TABLES
               WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'gamerankhistory') THEN
        IF NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS
                       WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'gamerankhistory' AND COLUMN_NAME = 'LineAgent') THEN
            ALTER TABLE `gamerankhistory` ADD COLUMN `LineAgent` VARCHAR(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci
                NOT NULL DEFAULT '' COMMENT '归属代理线（直属代理账号，空=公共）' AFTER `ID`;
        END IF;
        IF NOT EXISTS (SELECT 1 FROM information_schema.STATISTICS
                       WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'gamerankhistory' AND INDEX_NAME = 'uq_rank_line_game_slot') THEN
            ALTER TABLE `gamerankhistory` ADD UNIQUE KEY `uq_rank_line_game_slot` (`LineAgent`, `GameId`, `Slot`);
        END IF;
        IF EXISTS (SELECT 1 FROM information_schema.STATISTICS
                   WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'gamerankhistory' AND INDEX_NAME = 'uq_rank_game_slot') THEN
            ALTER TABLE `gamerankhistory` DROP INDEX `uq_rank_game_slot`;
        END IF;
        IF NOT EXISTS (SELECT 1 FROM information_schema.STATISTICS
                       WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'gamerankhistory' AND INDEX_NAME = 'ix_rank_line_game_id') THEN
            ALTER TABLE `gamerankhistory` ADD KEY `ix_rank_line_game_id` (`LineAgent`, `GameId`, `ID`);
        END IF;
    END IF;
END$$
DELIMITER ;
CALL `__mth_line_scope_20261030`();
DROP PROCEDURE `__mth_line_scope_20261030`;
