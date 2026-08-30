-- 修正线上 games.Name（老服迁移遗留：大部分为空、少数 GBK 乱码字节）。
-- 值取自本地 docker 初始化库（mth.sql），逐行 HEX 已核对。执行前旧值见 2026-08-30 gamescheck 输出，可回滚。
SET NAMES utf8mb4;
UPDATE games SET Name='彩金单挑' WHERE GameId=2;
UPDATE games SET Name='金蟾捕鱼' WHERE GameId=3;
UPDATE games SET Name='火凤凰'   WHERE GameId=5;
UPDATE games SET Name='牛魔王'   WHERE GameId=6;
UPDATE games SET Name='幸运六狮' WHERE GameId=10;
UPDATE games SET Name='李逵劈鱼' WHERE GameId=13;
UPDATE games SET Name='金皇冠'   WHERE GameId=14;
UPDATE games SET Name='大字板'   WHERE GameId=15;
UPDATE games SET Name='明星97'   WHERE GameId=16;
UPDATE games SET Name='摇钱树'   WHERE GameId=19;
UPDATE games SET Name='双响金龙鱼' WHERE GameId=21;
UPDATE games SET Name='金鲨银鲨' WHERE GameId=29;
UPDATE games SET Name='神龙宝藏' WHERE GameId=32;
UPDATE games SET Name='史前巨鳄' WHERE GameId=33;
UPDATE games SET Name='ATT3'    WHERE GameId=37;
UPDATE games SET Name='水果拉霸' WHERE GameId=40;
UPDATE games SET Name='NBA'     WHERE GameId=44;
UPDATE games SET Name='奔驰宝马' WHERE GameId=47;
UPDATE games SET Name='美人鱼'   WHERE GameId=49;
UPDATE games SET Name='水浒传'   WHERE GameId=53;
-- 校验：HEX 应与本地一致
SELECT GameId, Name, HEX(Name) FROM games ORDER BY GameId;
