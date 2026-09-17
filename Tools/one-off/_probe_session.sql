-- Read-only: is LoginSession stable across one evening (one login) per player?
SELECT UserID, LoginSession, COUNT(*) AS cnt, MIN(REC_TIME) AS first_t, MAX(REC_TIME) AS last_t
FROM userscoresnapshotledger
WHERE UserID IN ('a1403','a1402','a1404','test01','aa1122') AND REC_TIME >= '2026-09-17 00:00:00'
GROUP BY UserID, LoginSession ORDER BY UserID, first_t;
