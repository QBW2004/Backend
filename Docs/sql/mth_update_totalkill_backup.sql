-- ============================================================
-- 修复：总控吃分(mode=4)桌台参数备份表缺失导致“进去会变、出来不变回”
-- 说明：
--   1. 服务端备份/恢复都依赖 totalkill_table_backup 表，该表在旧库中从未创建，
--      导致应用吃分成功(改 cardpayoutprofile)但玩家退出时查备份失败、桌台概率不恢复。
--   2. 本脚本：① 建备份表；② 清理历史测试残留的吃分概率套(可选，需按实际现场执行)；
--      ③ 提供验证查询。
-- 执行方式：mysql -uroot -p数据库密码 库名 < mth_update_totalkill_backup.sql
--           或直接在编辑器/命令行粘贴执行。
-- ============================================================

-- ------------------------------------------------------------
-- ① 建总控吃分桌台备份表（幂等：已存在则跳过，不覆盖已有数据）
--    字段与服务端 Database.cpp 的 INSERT/SELECT 完全对齐：
--    UserID 为主键(同玩家仅一条，服务端先 DELETE 再 INSERT)
--    GameType: 1=牌机 2=鱼机
--    CardProbs: 牌机13牌型原概率串 "ht0;ht1;...;ht12"（万分比）
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `totalkill_table_backup` (
  `UserID` varchar(64) NOT NULL COMMENT '被控玩家账号',
  `GameID` int(11) NOT NULL DEFAULT 0 COMMENT '被备份的游戏ID',
  `TableID` int(11) NOT NULL DEFAULT 0 COMMENT '被备份的桌台号',
  `GameType` int(11) NOT NULL DEFAULT 0 COMMENT '1=牌机 2=鱼机',
  `DIF` int(11) NOT NULL DEFAULT 0 COMMENT '鱼机原DIF',
  `SITE_TYPE` int(11) NOT NULL DEFAULT 0 COMMENT '鱼机原SITE',
  `CardProbs` varchar(512) NOT NULL DEFAULT '' COMMENT '牌机13牌型原概率串 ht0;ht1;...;ht12',
  `CreateTime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`UserID`) USING BTREE
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COMMENT = '总控吃分桌台参数备份表';

-- ------------------------------------------------------------
-- ② 【按需执行】清理历史测试残留的吃分概率套（cardpayoutprofile 中脏数据）
--    吃分套特征：HandType=0(杂牌) ProbabilityBasis=5900，且 6~12 号牌型概率全为 0。
--    说明：
--    - 由于备份表缺失，残留桌的原值没有备份可用；
--    - 以下 UPDATE 将该游戏所有"带吃分套特征"的桌，恢复为"本游戏未被污染的参考桌"概率
--      （参考桌 = TableId 最小且未被吃分套修改的桌；若各桌原配置一致即为正确原值；
--      若个别桌曾单独调过概率，请用后台配置页重新保存该桌）。
--    - 先执行下面的「查询残留」确认范围，再执行 UPDATE；
--    - 每个游戏都要单独执行一次（把 GAME_ID 换成实际游戏ID：5=大字板 7=ATT3 12=金皇冠 13=NBA 14=火凤凰 15=水浒 16=明星97 17=水果拉霸 等）。
-- ------------------------------------------------------------

-- (a) 查询残留：哪些桌带着吃分套（杂牌=5900 且牌型6~12全0）
-- SELECT GAME_ID, TableId,
--        GROUP_CONCAT(ProbabilityBasis ORDER BY HandType SEPARATOR ',') AS probs13
-- FROM cardpayoutprofile
-- WHERE GAME_ID=5 AND HandType<13
-- GROUP BY GAME_ID, TableId
-- HAVING MAX(CASE WHEN HandType=0 THEN ProbabilityBasis END)=5900;

-- (b) 清理：把 GAME_ID=5 中带吃分套的桌恢复为参考桌(TableId=0)的概率
UPDATE cardpayoutprofile cp
JOIN (
    SELECT HandType, ProbabilityBasis AS pb
    FROM cardpayoutprofile
    WHERE GAME_ID=5 AND TableId=0 AND HandType<13
) ref ON cp.HandType = ref.HandType
JOIN (
    SELECT TableId
    FROM cardpayoutprofile
    WHERE GAME_ID=5 AND HandType<13
    GROUP BY TableId
    HAVING MAX(CASE WHEN HandType=0 THEN ProbabilityBasis END)=5900
) dirty ON cp.TableId = dirty.TableId
SET cp.ProbabilityBasis = ref.pb
WHERE cp.GAME_ID=5 AND cp.HandType<13;

-- (c) 其它游戏重复执行 (b)，只需把 GAME_ID=5 与 参考桌(TableId=0)
--     换成该游戏实际值（例：GAME_ID=14 火凤凰、参考桌 TableId=0）。

-- ------------------------------------------------------------
-- ③ 验证查询（建表/清理后执行）
-- ------------------------------------------------------------

-- 备份表：正常流程下应为空；应用吃分期间应存在被控玩家一行
-- SELECT * FROM totalkill_table_backup;

-- 确认目标游戏各桌已恢复原概率（无 5900 残留）
-- SELECT GAME_ID, TableId,
--        GROUP_CONCAT(ProbabilityBasis ORDER BY HandType SEPARATOR ',') AS probs13
-- FROM cardpayoutprofile
-- WHERE GAME_ID=5 AND HandType<13
-- GROUP BY GAME_ID, TableId ORDER BY GAME_ID, TableId;