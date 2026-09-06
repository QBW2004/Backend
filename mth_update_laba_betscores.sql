-- =====================================================================
-- 拉霸三款（水果拉霸=40 / 明星97=16 / 水浒传=53）：按桌筹码档位(1~5级)初始化
-- 存储：roomtableconfig_bet（与彩金单挑 GAME_ID=2 同一张表、同一管道），无需 DDL。
-- 热更：后台保存 → 写 roomtableconfig_bet + TC(押分扩展段) → 中心服 UpsertBetRoomTableConfig
--       → SendExtendedPara 全量重推 → 拉霸服按桌快照 → 客户端选桌(10015)拿到每桌筹码。
-- 前置：后台/中心服/拉霸服均已部署新版本（本次改造的代码）。
-- 行为：为现有每张桌(roomtableconfig)补齐 roomtableconfig_bet 行，
--       BetScores 取 parabetroom base 行（房间级筹码，ID=GAME_ID*1000），无则用默认 '1,5,10,15,20'；
--       已有行不覆盖；其余列全 0（中心服自动用 parabetroom 房间值补填）。
-- 验证：后台「游戏配置 → 拉霸 → 水果拉霸」选任意桌可见五档筹码输入框；
--       修改后保存，客户端选桌列表/机台 BottomPanel/ThirdLine/Bet1~Bet5 文本应随之变化。
-- 回滚：DELETE FROM roomtableconfig_bet WHERE GAME_ID IN (16,40,53);
-- =====================================================================

INSERT INTO roomtableconfig_bet
    (GAME_ID, TableIndex, BetTime, BetMin, BetMax, BankerScoreNeed,
     ItemSingleScoreLimit, ItemAllScoreLimit, CoinsNeed, OneCoinScore,
     BetScores, DefaultBetIndex, BetMinVice, BetMaxVice, BetMinDraw, BetMaxDraw)
SELECT rc.GAME_ID, rc.TableIndex, 0, 0, 0, 0, 0, 0, 0, 0,
       COALESCE(NULLIF(pr.BetScores, ''), '1,5,10,15,20'), 0, 0, 0, 0, 0
FROM roomtableconfig rc
LEFT JOIN parabetroom pr ON pr.GAME_ID = rc.GAME_ID AND pr.ID = rc.GAME_ID * 1000
WHERE rc.GAME_ID IN (16, 40, 53)
  AND NOT EXISTS (
        SELECT 1 FROM roomtableconfig_bet b
        WHERE b.GAME_ID = rc.GAME_ID AND b.TableIndex = rc.TableIndex
  );