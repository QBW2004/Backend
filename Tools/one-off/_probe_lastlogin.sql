-- Read-only: which useroptlog record produced the 19:48 shown on the online card?
SELECT UserID, LID, OPT, OPT_COINS, COINS, SCORE, ROOM, GAME_TYPE, TABLE_ID, SEAT_ID, REC_TIME
FROM useroptlog
WHERE UserID IN ('a1403','a1402','a1404') AND REC_TIME >= '2026-09-17 18:00:00' AND REC_TIME <= '2026-09-17 21:30:00'
ORDER BY LID;
