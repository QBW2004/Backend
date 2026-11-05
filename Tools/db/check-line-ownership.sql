-- 专属桌台归属一致性检查（2026-11-05）：只读，不修改任何数据。任意一段查出行即为“后台看得到、玩家匹配不上”的风险。
-- 背景：后台与中心服用 MySQL 比较（不分大小写、忽略尾部空格），游戏服 LineScope::TableVisible 按 admin.ID 原样逐字节比对归属。

-- 1) 归属写法与直属代理 admin.ID 不完全一致 / 代理已不存在 / 已不是直属代理(PRIV<>1) / 首尾带空格
SELECT o.GAME_ID, o.TableIndex, o.LineAgent, a.ID AS AdminId, a.PRIV
FROM roomtableowner o
LEFT JOIN admin a ON a.ID = o.LineAgent
WHERE o.LineAgent <> '#'
  AND (a.ID IS NULL OR BINARY a.ID <> BINARY o.LineAgent OR a.PRIV <> 1 OR o.LineAgent <> TRIM(o.LineAgent))
ORDER BY o.GAME_ID, o.TableIndex;

-- 2) 有归属但桌台已不存在（孤儿归属，下次新建同桌号会直接变成该线专属）
SELECT o.GAME_ID, o.TableIndex, o.LineAgent
FROM roomtableowner o
LEFT JOIN roomtableconfig c ON c.GAME_ID = o.GAME_ID AND c.TableIndex = o.TableIndex
WHERE c.ID IS NULL
ORDER BY o.GAME_ID, o.TableIndex;

-- 3) 同一游戏同一线出现多种大小写写法
SELECT GAME_ID, LOWER(LineAgent) AS Line, COUNT(DISTINCT BINARY LineAgent) AS Spellings
FROM roomtableowner
WHERE LineAgent <> '#'
GROUP BY GAME_ID, LOWER(LineAgent)
HAVING Spellings > 1;
