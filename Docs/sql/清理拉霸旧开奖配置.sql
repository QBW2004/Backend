-- ============================================================
-- 清理拉霸旧开奖配置（水浒传=53 / 水果拉霸=40 / 明星97=16）
-- 背景：三款拉霸服务端旧开奖路径（逐格随机+机台难度+水位门控）已删除，
--       符号出现率（Prob0-8）、符号赔率（Payout0-8，水浒不读/明星97 已改走
--       「奖项配置」结果类表 Combo300-308）、机台难度（DIF/HAR）、
--       灰度开关 UseOutcomeFirst 不再被服务端读取，清理数据库中残留配置。
-- 注意：paralaba 的 Prob*/Payout*/DIF/HAR 列保留（避免 DDL），仅清值。
-- 执行前请先备份数据库。
-- ============================================================

-- 1) gameconfiglaba：删除符号出现率/符号赔率/UseOutcomeFirst 键
--    （Prob%/Payout% 不匹配 WheelProb/WheelStock/ComboProb 等新逻辑键）
DELETE FROM gameconfiglaba
WHERE GameId IN (16, 40, 53)
  AND (OptKey LIKE 'Prob%' OR OptKey LIKE 'Payout%' OR OptKey = 'UseOutcomeFirst');

-- 2) paralaba：水浒传/水果拉霸/明星97 的符号出现率、符号赔率与机台难度清 0
UPDATE paralaba
SET DIF = 0, HAR = 0,
    Payout0 = 0, Payout1 = 0, Payout2 = 0, Payout3 = 0, Payout4 = 0,
    Payout5 = 0, Payout6 = 0, Payout7 = 0, Payout8 = 0,
    Prob0 = 0, Prob1 = 0, Prob2 = 0, Prob3 = 0, Prob4 = 0,
    Prob5 = 0, Prob6 = 0, Prob7 = 0, Prob8 = 0
WHERE GAME_ID IN (16, 40, 53);

-- ---- 执行前预览（先跑 SELECT 确认影响行数）----
-- SELECT * FROM gameconfiglaba WHERE GameId IN (16,40,53) AND (OptKey LIKE 'Prob%' OR OptKey LIKE 'Payout%' OR OptKey = 'UseOutcomeFirst');
-- SELECT * FROM paralaba WHERE GAME_ID IN (16,40,53) AND (DIF<>0 OR HAR<>0 OR Payout0<>0 OR Payout1<>0 OR Payout2<>0 OR Payout3<>0 OR Payout4<>0 OR Payout5<>0 OR Payout6<>0 OR Payout7<>0 OR Payout8<>0 OR Prob0<>0 OR Prob1<>0 OR Prob2<>0 OR Prob3<>0 OR Prob4<>0 OR Prob5<>0 OR Prob6<>0 OR Prob7<>0 OR Prob8<>0);
