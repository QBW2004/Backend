-- 只读：按 B_Users.GetUserPhoneDetail 实际拼接出的整条 SQL 验证（{0}=今日, {1}=目标账号）
SELECT c.ID, c.NAME, c.AGENCY, c.FROZEN, c.GAME_SCORE, c.COINS, c.COINS_BUY, c.COINS_BACK, c.CreateTime,
 IFNULL(w.WINLOSS,0) AS TodayWinLoss,
 (SELECT IFNULL(SUM(w2.WINLOSS),0) FROM user_daily_winloss w2 WHERE w2.UserID = c.ID) AS TotalWinLoss,
 l.LastLoginTime,
 (SELECT IFNULL(SUM(CASE WHEN r.RechargeType IN (20,22) OR (r.RechargeType = 30 AND r.Processed = 1) THEN r.Coin ELSE 0 END),0)
   FROM rechargerecords r WHERE r.GameID = c.ID AND r.CreateTime >= CURDATE() AND r.Processed = 1) AS TodayBuy,
 (SELECT IFNULL(SUM(CASE WHEN r.RechargeType IN (21,23) OR (r.RechargeType = 31 AND r.Processed = 1) THEN r.Coin ELSE 0 END),0)
   FROM rechargerecords r WHERE r.GameID = c.ID AND r.CreateTime >= CURDATE() AND r.Processed = 1) AS TodayBack,
 (SELECT ic.InviteCode FROM invite_codes ic WHERE ic.UsedBy = c.ID AND ic.IsUsed = 1 ORDER BY ic.ID DESC LIMIT 1) AS InviteCode
 FROM users c
 LEFT JOIN user_daily_winloss w ON w.UserID = c.ID AND w.DAY = CURDATE()
 LEFT JOIN (SELECT UserID, MAX(REC_TIME) AS LastLoginTime FROM `UserOptLog` GROUP BY UserID) l ON l.UserID = c.ID
 WHERE c.ID = 'a1403';
