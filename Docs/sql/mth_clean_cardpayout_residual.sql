-- ============================================================
-- 清理所有牌机桌台的吃分套残留（通用脚本，服务器/本地均可执行）
--
-- 说明：
--   1. 总控吃分(mode=4)会把牌机某桌的 13 种牌型概率整体改写为"吃分套"
--      （HandType 0-12 = 5900,2800,1200,50,40,10,0,0,0,0,0,0,0）。
--      本脚本找出所有这样的桌，恢复为原值。
--   2. 原值来源：取"同游戏未被污染的、有完整13行的桌"的逐项众数概率。
--      （牌机同游戏各桌默认配置一致；若个别桌之前单独调过概率，
--        会被恢复为同游戏主流值，请在后台配置页复核该桌。）
--   3. 若某被污染桌所在游戏没有任何未污染的完整13行桌（即这些桌原本就是
--      "无配置→默认难度"），则删除该桌被吃分新建的13行，还原"无配置"状态。
--   4. 执行前建议先备份：CREATE TABLE cardpayoutprofile_bak AS SELECT * FROM cardpayoutprofile;
--   5. 兼容 MySQL 5.7（临时表每次只引用一次，避免 1137 Can't reopen table）。
--
-- 执行方式：Navicat 直接运行，或
--   mysql -uroot -p密码 库名 --default-character-set=utf8mb4 < mth_clean_cardpayout_residual.sql
-- ============================================================

-- 0) （可选）备份
-- CREATE TABLE IF NOT EXISTS cardpayoutprofile_bak AS SELECT * FROM cardpayoutprofile;

-- 1) 找出被吃分套污染的桌（双特征：HandType=0 杂牌=5900 且 HandType=1 对子=2800）
CREATE TEMPORARY TABLE tmp_dirty AS
SELECT d.GAME_ID, d.TableId
FROM cardpayoutprofile d
JOIN cardpayoutprofile d0
  ON d0.GAME_ID = d.GAME_ID AND d0.TableId = d.TableId
 AND d0.HandType = 0 AND d0.ProbabilityBasis = 5900
JOIN cardpayoutprofile d1
  ON d1.GAME_ID = d.GAME_ID AND d1.TableId = d.TableId
 AND d1.HandType = 1 AND d1.ProbabilityBasis = 2800
WHERE d.HandType < 13
GROUP BY d.GAME_ID, d.TableId;

-- 2) 未被污染的"完整13行"桌（作为参考）
CREATE TEMPORARY TABLE tmp_clean AS
SELECT cp.GAME_ID, cp.TableId
FROM cardpayoutprofile cp
WHERE cp.HandType < 13
  AND NOT EXISTS (
      SELECT 1 FROM tmp_dirty td
      WHERE td.GAME_ID = cp.GAME_ID AND td.TableId = cp.TableId
  )
GROUP BY cp.GAME_ID, cp.TableId
HAVING COUNT(*) = 13;

-- 3) 逐项计数：(GAME_ID, HandType, ProbabilityBasis) 在未污染桌中的出现次数
CREATE TEMPORARY TABLE tmp_cnt AS
SELECT cp.GAME_ID, cp.HandType, cp.ProbabilityBasis AS pb, COUNT(*) AS cnt
FROM cardpayoutprofile cp
JOIN tmp_clean c ON c.GAME_ID = cp.GAME_ID AND c.TableId = cp.TableId
WHERE cp.HandType < 13
GROUP BY cp.GAME_ID, cp.HandType, cp.ProbabilityBasis;

-- 4) 每组最大次数
CREATE TEMPORARY TABLE tmp_max AS
SELECT GAME_ID, HandType, MAX(cnt) AS maxcnt
FROM tmp_cnt
GROUP BY GAME_ID, HandType;

-- 5) 众数参考表：(GAME_ID, HandType) -> 出现次数最多的 ProbabilityBasis
CREATE TEMPORARY TABLE tmp_ref AS
SELECT r.GAME_ID, r.HandType, r.pb
FROM tmp_cnt r
JOIN tmp_max m
  ON m.GAME_ID = r.GAME_ID AND m.HandType = r.HandType AND m.maxcnt = r.cnt;

-- 6) 恢复：被污染桌 ← 同游戏未污染桌的众数原值
UPDATE cardpayoutprofile cp
JOIN tmp_dirty d ON d.GAME_ID = cp.GAME_ID AND d.TableId = cp.TableId
JOIN tmp_ref   r ON r.GAME_ID = cp.GAME_ID AND r.HandType = cp.HandType
SET cp.ProbabilityBasis = r.pb
WHERE cp.HandType < 13;

-- 7) 还原"无配置"：被污染桌所在游戏没有任何未污染参考桌 → 删除被吃分新建的13行
DELETE cp FROM cardpayoutprofile cp
JOIN tmp_dirty d ON d.GAME_ID = cp.GAME_ID AND d.TableId = cp.TableId
LEFT JOIN tmp_clean c ON c.GAME_ID = d.GAME_ID
WHERE cp.HandType < 13 AND c.GAME_ID IS NULL;

-- 8) 清理临时表
DROP TEMPORARY TABLE IF EXISTS tmp_dirty;
DROP TEMPORARY TABLE IF EXISTS tmp_clean;
DROP TEMPORARY TABLE IF EXISTS tmp_cnt;
DROP TEMPORARY TABLE IF EXISTS tmp_max;
DROP TEMPORARY TABLE IF EXISTS tmp_ref;

-- ============================================================
-- 验证（清理后执行）
-- ============================================================
-- 残留应为空：
-- SELECT GAME_ID, TableId FROM cardpayoutprofile
-- WHERE HandType=0 AND ProbabilityBasis=5900
-- GROUP BY GAME_ID, TableId;

-- 查看各游戏各桌当前 13 型概率（确认无 5900 且各桌一致）：
-- SELECT GAME_ID, TableId,
--        GROUP_CONCAT(ProbabilityBasis ORDER BY HandType SEPARATOR ',') AS probs13
-- FROM cardpayoutprofile WHERE HandType<13
-- GROUP BY GAME_ID, TableId ORDER BY GAME_ID, TableId;