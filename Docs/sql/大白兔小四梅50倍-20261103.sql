-- 大白兔（GAME_ID=55）小四梅固定倍率由 40 调整为 50。
-- 仅改仍为旧默认 40 的桌；运营已单独配置成其他值的桌保持不变。
-- 执行前请备份 cardgamecfg；本脚本幂等，可重复执行。
SET NAMES utf8mb4;

START TRANSACTION;
UPDATE cardgamecfg
SET CfgJson = JSON_SET(CfgJson, '$.smallFourMultiplier', 50)
WHERE GAME_ID = 55
  AND JSON_VALID(CfgJson)
  AND CAST(JSON_UNQUOTE(JSON_EXTRACT(CfgJson, '$.smallFourMultiplier')) AS UNSIGNED) = 40;
COMMIT;

-- 核对：应无 GAME_ID=55 且 smallFourMultiplier=40 的桌。
SELECT GAME_ID, TableIndex, JSON_EXTRACT(CfgJson, '$.smallFourMultiplier') AS SmallFourMultiplier
FROM cardgamecfg
WHERE GAME_ID = 55
ORDER BY TableIndex;
