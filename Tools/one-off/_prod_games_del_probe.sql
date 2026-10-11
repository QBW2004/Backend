SELECT 'paragame', ID, COUNT(*) FROM paragame WHERE ID IN (19,21,29,42,49) GROUP BY ID;
SELECT 'gameconfiglaba', GameId, COUNT(*) FROM gameconfiglaba WHERE GameId IN (19,21,29,42,49) GROUP BY GameId;
SELECT 'usercontrolstatus', GameId, COUNT(*) FROM usercontrolstatus WHERE GameId IN (19,21,29,42,49) GROUP BY GameId;
SELECT 'useroptlog_7d', GAME_TYPE, COUNT(*) FROM useroptlog WHERE GAME_TYPE IN (19,21,29,42,49) GROUP BY GAME_TYPE;
SELECT 'cardpayoutprofile', GAME_ID, COUNT(*) FROM cardpayoutprofile WHERE GAME_ID IN (19,21,29,42,49) GROUP BY GAME_ID;
SELECT 'robot_seat', GAME_ID, COUNT(*) FROM robot_seat WHERE GAME_ID IN (19,21,29,42,49) GROUP BY GAME_ID;
SELECT 'games_row', GameId, HEX(Name), Enable, GameType, Num FROM games WHERE GameId IN (19,21,29,42,49) ORDER BY GameId;
