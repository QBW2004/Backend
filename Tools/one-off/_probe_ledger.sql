-- Read-only: userscoresnapshotledger shape - is there a per-login row?
SELECT Reason, COUNT(*) AS cnt, MIN(REC_TIME) AS min_t, MAX(REC_TIME) AS max_t
FROM userscoresnapshotledger GROUP BY Reason ORDER BY cnt DESC;
SELECT 'a1403 ledger 09-17+' AS tag;
SELECT LID, UserID, GameID, LoginSession, Coins, GameScore, TempCoin, RecoveredCoins, Reason, REC_TIME
FROM userscoresnapshotledger WHERE UserID IN ('a1403','a1402','test01') AND REC_TIME >= '2026-09-17 00:00:00'
ORDER BY LID DESC LIMIT 40;
