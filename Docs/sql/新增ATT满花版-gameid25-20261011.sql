-- ======================================================================
-- 新增子游戏「ATT满花版」库表配置（gameID=25）
-- 日期: 2026-10-11
-- 对应: 游戏服 ServerCardAttMhb（玩家端口 9206，中心服 COM 8250/8251，控牌 cardAction=8）
--       客户端 Assets/WGM/ATTManHuaBan（GameType.ATTManHuaBan = 9206）
-- 幂等: 可重复执行；已存在的行不会重复插入，games 行只做名称/启用/类型规范化。
-- 执行顺序（重要）:
--   1) 先执行本脚本（中心服只为 games.Enable=1 的游戏建 COM 监听；
--      且中心服 GetCardPara 读不到 paragame/pararoom/paracard 会自动补建默认 3 房 15 桌）
--   2) 部署新中心服 ServerCenterNew.exe 并重启（重启会连锁重启全部子游戏，见 AGENTS.md）
--   3) 部署并启动 ServerCardAttMhb.exe
-- 中文值用十六进制 utf8mb4 字面量，避免 GBK 控制台执行时乱码:
--   0x415454E6BBA1E88AB1E78988 = 'ATT满花版'，0xE69CBAE58FB031/32/33 = '机台1/2/3'
-- 初始桌台/赔付参数与 ATT3 线上同口径（3 桌，1~100 押分，牌型概率同 ATT3 出厂值），
-- 上线后在后台「台机设定」按需调整；HandType 204 为金拇指触发概率(万分比，仅杂牌局触发)。
-- ======================================================================

SET NAMES utf8mb4;
SET @GID := 25;
SET @GNAME := CONVERT(0x415454E6BBA1E88AB1E78988 USING utf8mb4);

START TRANSACTION;

-- ----------------------------------------------------------------------
-- 1) 游戏开关（GameType=1 牌机）与机器人数量行
-- ----------------------------------------------------------------------
INSERT INTO `games` (`GameId`, `Name`, `Enable`, `GameType`, `Num`)
SELECT @GID, @GNAME, 1, 1, 0 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `games` WHERE `GameId` = @GID);
UPDATE `games` SET `Name` = @GNAME, `Enable` = 1, `GameType` = 1 WHERE `GameId` = @GID;

INSERT INTO `userrobotnum` (`GameId`, `Name`, `Enable`, `GameType`, `Num`)
SELECT @GID, @GNAME, 1, 1, 0 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `userrobotnum` WHERE `GameId` = @GID);

-- ----------------------------------------------------------------------
-- 2) 一房 N 桌：paragame.ROOM_MAX 恒 1，pararoom 只保留 base 行(ID=gameId*1000，NUM=桌数)
-- ----------------------------------------------------------------------
INSERT INTO `paragame` (`ID`, `ROOM_MAX`, `PLY_MAX`)
SELECT @GID, 1, 1000 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `paragame` WHERE `ID` = @GID);
UPDATE `paragame` SET `ROOM_MAX` = 1 WHERE `ID` = @GID;

INSERT INTO `pararoom` (`ID`, `GAME_ID`, `NUM`, `BET_MIN`, `BET_MAX`, `EX_COIN`, `COIN_SC`, `COIN_NEED`, `scoreSwitch`, `Game_Mo`,
                        `TableName`, `MaxSeats`, `IdleFireTimeoutSec`, `IdleFireKickEnabled`, `Enabled`, `MinBetUnits`, `MaxBetUnits`)
SELECT @GID * 1000, @GID, 3, 10, 100, 1, 1, 1, 10, 1,
       CONVERT(0xE69CBAE58FB033 USING utf8mb4), 6, 0, 1, 1, 100, 1000 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `pararoom` WHERE `ID` = @GID * 1000);

-- ----------------------------------------------------------------------
-- 3) 机台难度（按桌）：paracard.ID = gameId*1000 + TableIndex
-- ----------------------------------------------------------------------
INSERT INTO `paracard` (`ID`, `GAME_ID`, `DIF`, `HYPE_TYPE`)
SELECT @GID * 1000 + t.TableIndex, @GID, '0000000000000000', 0
FROM (SELECT 0 AS TableIndex UNION ALL SELECT 1 UNION ALL SELECT 2) t
WHERE NOT EXISTS (SELECT 1 FROM `paracard` c WHERE c.`ID` = @GID * 1000 + t.TableIndex);

-- ----------------------------------------------------------------------
-- 4) 通用桌台参数（按桌）：roomtableconfig；牌机专属参数：roomtableconfig_card
--    GunPowerStep = 加分幅度 x10，MinBetUnits/MaxBetUnits = 押分显示值 x10（与后台保存口径一致）
-- ----------------------------------------------------------------------
INSERT INTO `roomtableconfig` (`GAME_ID`, `RoomIndex`, `TableIndex`, `TableName`, `Enabled`, `OneCoinScore`, `BetMin`, `BetMax`,
                               `CoinsNeed`, `IdleFireTimeoutSec`, `IdleFireKickEnabled`, `MaxSeats`, `MinBetUnits`, `GunPowerStep`)
SELECT @GID, 0, s.TableIndex, CONVERT(s.TableNameHex USING utf8mb4), 1, 1, s.BetMin, 100,
       1, 0, 1, 6, s.BetMin * 10, s.ScoreSwitch * 10
FROM (SELECT 0 AS TableIndex, 0xE69CBAE58FB031 AS TableNameHex, 1 AS BetMin, 1 AS ScoreSwitch
      UNION ALL SELECT 1, 0xE69CBAE58FB032, 5, 1
      UNION ALL SELECT 2, 0xE69CBAE58FB033, 10, 10) s
WHERE NOT EXISTS (SELECT 1 FROM `roomtableconfig` r WHERE r.`GAME_ID` = @GID AND r.`TableIndex` = s.TableIndex);

INSERT INTO `roomtableconfig_card` (`GAME_ID`, `RoomIndex`, `TableIndex`, `ExCoin`, `ScoreSwitch`, `GameMo`, `MaxBetUnits`)
SELECT @GID, 0, s.TableIndex, 1, s.ScoreSwitch, 1, 1000
FROM (SELECT 0 AS TableIndex, 1 AS ScoreSwitch UNION ALL SELECT 1, 1 UNION ALL SELECT 2, 10) s
WHERE NOT EXISTS (SELECT 1 FROM `roomtableconfig_card` r WHERE r.`GAME_ID` = @GID AND r.`TableIndex` = s.TableIndex);

-- ----------------------------------------------------------------------
-- 5) 牌型概率（按桌，万分比）：HandType 0..12 牌型，201/202/203 鬼牌 1/2/3 王，204 金拇指
-- ----------------------------------------------------------------------
INSERT INTO `cardpayoutprofile` (`GAME_ID`, `TableId`, `HandType`, `PayoutMultiplier`, `ProbabilityBasis`, `StockLimit`, `StockRemain`, `Enabled`)
SELECT @GID, t.TableIndex, p.HandType, 0, p.ProbabilityBasis, 0, 0, p.Enabled
FROM (SELECT 0 AS HandType, 6000 AS ProbabilityBasis, 1 AS Enabled
      UNION ALL SELECT 1, 2000, 1  UNION ALL SELECT 2, 1000, 1  UNION ALL SELECT 3, 500, 1
      UNION ALL SELECT 4, 400, 1   UNION ALL SELECT 5, 60, 1    UNION ALL SELECT 6, 20, 1
      UNION ALL SELECT 7, 10, 1    UNION ALL SELECT 8, 3, 1     UNION ALL SELECT 9, 5, 1
      UNION ALL SELECT 10, 2, 1    UNION ALL SELECT 11, 4, 1    UNION ALL SELECT 12, 1, 1
      UNION ALL SELECT 201, 0, 0   UNION ALL SELECT 202, 0, 0   UNION ALL SELECT 203, 0, 0
      UNION ALL SELECT 204, 1, 1) p
CROSS JOIN (SELECT 0 AS TableIndex UNION ALL SELECT 1 UNION ALL SELECT 2) t
WHERE NOT EXISTS (SELECT 1 FROM `cardpayoutprofile` c
                  WHERE c.`GAME_ID` = @GID AND c.`TableId` = t.TableIndex AND c.`HandType` = p.HandType);

COMMIT;

-- ----------------------------------------------------------------------
-- 6) 校验
-- ----------------------------------------------------------------------
SELECT `GameId`, `Name`, `Enable`, `GameType` FROM `games` WHERE `GameId` = @GID;
SELECT `ID`, `ROOM_MAX` FROM `paragame` WHERE `ID` = @GID;
SELECT `ID`, `NUM`, `BET_MIN`, `BET_MAX`, `COIN_SC` FROM `pararoom` WHERE `GAME_ID` = @GID;
SELECT `TableIndex`, `TableName`, `Enabled`, `BetMin`, `BetMax`, `OneCoinScore`, `GunPowerStep` FROM `roomtableconfig` WHERE `GAME_ID` = @GID ORDER BY `TableIndex`;
SELECT `TableIndex`, `ExCoin`, `ScoreSwitch`, `GameMo`, `MaxBetUnits` FROM `roomtableconfig_card` WHERE `GAME_ID` = @GID ORDER BY `TableIndex`;
SELECT `TableId`, COUNT(*) AS rows_per_table, SUM(`HandType` = 204) AS gold_finger_row FROM `cardpayoutprofile` WHERE `GAME_ID` = @GID GROUP BY `TableId`;
