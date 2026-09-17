-- Read-only: do PLAYER accounts also get 登录(2)/退出(3) rows in agencyoptlog?
SELECT 'agencyoptlog_all' AS tag, COUNT(*) AS cnt FROM agencyoptlog;
SELECT OPT, COUNT(*) AS cnt, MIN(REC_TIME) AS min_t, MAX(REC_TIME) AS max_t
FROM agencyoptlog GROUP BY OPT ORDER BY cnt DESC;
SELECT 'agent rows whose target is a player' AS tag;
SELECT a.ID, COUNT(*) AS cnt FROM agencyoptlog a INNER JOIN users u ON u.ID = a.ID GROUP BY a.ID ORDER BY cnt DESC LIMIT 10;
SELECT 'recent agencyoptlog rows targeting players' AS tag;
SELECT a.LID, a.OptID, a.ID, a.OPT, a.COINS, a.BEF_COINS, a.AFT_COINS, a.REC_TIME
FROM agencyoptlog a INNER JOIN users u ON u.ID = a.ID
ORDER BY a.LID DESC LIMIT 25;
SELECT 'manageropt' AS tag, COUNT(*) AS cnt FROM manageropt;
SELECT OPT, COUNT(*) AS cnt, MAX(REC_TIME) AS max_t FROM manageropt GROUP BY OPT ORDER BY cnt DESC LIMIT 10;
