CREATE TABLE IF NOT EXISTS `roomtableconfig_card` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `GAME_ID` int(11) NOT NULL,
  `RoomIndex` int(11) NOT NULL DEFAULT 0,
  `TableIndex` int(11) NOT NULL,
  `ExCoin` int(11) NOT NULL DEFAULT 10000,
  `ScoreSwitch` int(11) NOT NULL DEFAULT 0,
  `GameMo` int(11) NOT NULL DEFAULT 0,
  `MaxBetUnits` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`ID`) USING BTREE,
  INDEX `idx_game_table`(`GAME_ID`, `TableIndex`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;
