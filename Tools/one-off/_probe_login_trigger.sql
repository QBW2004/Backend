-- 触发器联调验证（可回滚，不留下任何数据）：用真实触发器 + 真实 users 行模拟游戏服的登录/离线写入。
-- 1) INHALL 0→1 记一条登录；2) 1→1 不重复；3) 离线后再次上线再记一条；4) ROLLBACK 后全部消失。
SELECT NOW() AS now_time;
SELECT ID, INHALL + 0 AS inhall_before FROM users WHERE ID = 'test02';
START TRANSACTION;
UPDATE users SET INHALL = b'0' WHERE ID = 'test02';
UPDATE users SET INHALL = b'1' WHERE ID = 'test02';
SELECT UserID, LoginTime FROM userloginrecord WHERE UserID = 'test02';
UPDATE users SET INHALL = b'1' WHERE ID = 'test02';
SELECT COUNT(*) AS rows_after_same_value FROM userloginrecord WHERE UserID = 'test02';
UPDATE users SET INHALL = b'0' WHERE ID = 'test02';
UPDATE users SET INHALL = b'1' WHERE ID = 'test02';
SELECT COUNT(*) AS rows_after_relogin FROM userloginrecord WHERE UserID = 'test02';
ROLLBACK;
SELECT COUNT(*) AS rows_after_rollback FROM userloginrecord WHERE UserID = 'test02';
SELECT ID, INHALL + 0 AS inhall_after FROM users WHERE ID = 'test02';
SELECT COUNT(*) AS total_rows FROM userloginrecord;
