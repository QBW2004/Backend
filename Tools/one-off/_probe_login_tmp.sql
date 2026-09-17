-- 「最后登录」优先级复验（可反复执行，不留残留）：验证接口是否优先取 userloginrecord、删除后回退 useroptlog。
-- 步骤 1（临时写入，用于观察接口变化）：
--   INSERT INTO userloginrecord (UserID, LoginTime) VALUES ('a1403', '2026-09-18 03:05:00');
--   然后跑 Tools/one-off/_probe_lastlogin_api.ps1：a1403 的「最后登录」应变成 09-18 03:05（并被排到列表第一位）。
-- 步骤 2（本文件内容，收尾还原）：删掉临时记录，接口回到 useroptlog 口径。
DELETE FROM userloginrecord WHERE UserID = 'a1403';
SELECT COUNT(*) AS total_rows FROM userloginrecord;
