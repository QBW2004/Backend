-- ============================================================
-- 同步 pararoom.NUM = roomtableconfig 条数
-- 保证旧房间参数口径与新按桌配置一致
-- 同时对已迁移的单房间鱼机设置 ROOM_MAX=1
-- ============================================================

-- 第1步：对有 roomtableconfig 的游戏，同步 pararoom.NUM
-- NUM 应以 roomtableconfig 按桌配置条数为准
UPDATE ParaRoom pr
JOIN (
    SELECT GAME_ID, COUNT(*) AS cfgCount
    FROM roomtableconfig
    WHERE Enabled = 1
    GROUP BY GAME_ID
) rtc ON pr.GAME_ID = rtc.GAME_ID AND pr.ID = pr.GAME_ID * 1000
SET pr.NUM = rtc.cfgCount
WHERE pr.NUM != rtc.cfgCount;

-- 第2步：对只有1个房间且有 roomtableconfig 的鱼机/牌机，设置 ROOM_MAX=1
UPDATE ParaGame pg
JOIN (
    SELECT GAME_ID, COUNT(*) AS roomCount
    FROM ParaRoom
    GROUP BY GAME_ID
) pr ON pg.ID = pr.GAME_ID
JOIN (
    SELECT GAME_ID, COUNT(*) AS cfgCount
    FROM roomtableconfig
    GROUP BY GAME_ID
) rtc ON pg.ID = rtc.GAME_ID
SET pg.ROOM_MAX = 1
WHERE pr.roomCount = 1 AND rtc.cfgCount > 0 AND pg.ROOM_MAX > 1;

-- 第3步：对没有 roomtableconfig 的游戏（旧模型），确保 NUM = 实际房间行数
UPDATE ParaRoom pr
SET pr.NUM = (
    SELECT COUNT(*) FROM ParaRoom WHERE GAME_ID = pr.GAME_ID
)
WHERE pr.GAME_ID NOT IN (
    SELECT DISTINCT GAME_ID FROM roomtableconfig
);

-- 第4步：校验结果
SELECT
    pg.ID AS GAME_ID,
    pg.ROOM_MAX,
    (SELECT COUNT(*) FROM ParaRoom WHERE GAME_ID = pg.ID) AS para_room_count,
    (SELECT NUM FROM ParaRoom WHERE GAME_ID = pg.ID AND ID = pg.ID * 1000) AS para_room_num,
    (SELECT COUNT(*) FROM roomtableconfig WHERE GAME_ID = pg.ID) AS rtc_count
FROM ParaGame pg
ORDER BY pg.ID;
