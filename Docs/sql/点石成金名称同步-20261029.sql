-- 已于 2026-10-29 随后台 1.0.70 在备份后执行等价的受影响行数校验事务。
-- games.Name 是当前客户端的开关标识，必须使用 DianShiChengJin。
-- 只改名称，不改 Enable、GameType、端口或游戏服目录。
START TRANSACTION;
UPDATE games SET Name='DianShiChengJin' WHERE GameId=37 AND Name='ATT3';
UPDATE userrobotnum SET Name='DianShiChengJin' WHERE GameId=37 AND Name='ATT3';
COMMIT;
SELECT GameId,Name,Enable,GameType FROM games WHERE GameId=37;
