-- 只读：在线玩家列表刷新性能排查（表规模 / 索引 / 单条查询耗时）
SELECT 'users' AS tbl, COUNT(*) AS rows_cnt FROM users
UNION ALL SELECT 'users_inhall', COUNT(*) FROM users WHERE INHALL = 1
UNION ALL SELECT 'user_daily_winloss', COUNT(*) FROM user_daily_winloss
UNION ALL SELECT 'useroptlog', COUNT(*) FROM useroptlog
UNION ALL SELECT 'userrelations', COUNT(*) FROM userrelations
UNION ALL SELECT 'admin', COUNT(*) FROM admin
UNION ALL SELECT 'gamecommandoutbox', COUNT(*) FROM gamecommandoutbox;

SELECT TABLE_NAME, INDEX_NAME, GROUP_CONCAT(COLUMN_NAME ORDER BY SEQ_IN_INDEX) AS cols
FROM information_schema.STATISTICS
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_NAME IN ('users','user_daily_winloss','useroptlog','userrelations')
GROUP BY TABLE_NAME, INDEX_NAME;
