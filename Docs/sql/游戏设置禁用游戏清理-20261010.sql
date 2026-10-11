-- 游戏设置：再次删除全部禁用(Enable<>1)游戏行
-- 背景：2026-10-06 已删过一轮(19/21/29/42/49)，其后 games 表被回滚到一个更早快照：
--   * 19/21/29/49 重新出现(Enable=0)，42 未回；
--   * 16/40/53(明星97/水果拉霸/水浒传) 由 Enable=1 被刷成 0。
-- 运营确认：三个拉霸同样不再开放，随死游戏一并删除；其 roomtableconfig(30)/paralaba(30)/
-- cardpayoutprofile(920) 等按 GAME_ID 关联的配置保留为孤儿行，不回收到此脚本。
-- 注意：若 games 表再次被旧快照覆盖，本删除需重跑。
--
-- 回滚用（恢复为删除当刻状态；三个拉霸若要恢复运营把 Enable 改回 1）：
-- INSERT INTO games (GameId,Name,Enable,GameType,Num) VALUES
--   (16, 0xE6988EE6989F3937,           0, 3, 0),  -- 明星97 (快照回滚前为 Enable=1)
--   (19, 0xE69187E992B1E6A091,         0, 2, 0),  -- 摇钱树
--   (21, 0xE58F8CE5938DE98791E9BE99E9B1BC, 0, 2, 0),  -- 双响金龙鱼
--   (29, 0xE98791E9B2A8E993B6E9B2A8,   0, 0, 0),  -- 金鲨银鲨
--   (40, 0xE6B0B4E69E9CE68B89E99CB8,   0, 3, 0),  -- 水果拉霸 (快照回滚前为 Enable=1)
--   (49, 0xE7BE8EE4BABAE9B1BC,         0, 2, 0),  -- 美人鱼
--   (53, 0xE6B0B4E6B592E4BCA0,         0, 3, 0);  -- 水浒传 (快照回滚前为 Enable=1)

DELETE FROM games WHERE Enable <> 1;

-- 验证：应只剩 Enable=1 的 13 行
SELECT GameId, Name, GameType, Enable FROM games ORDER BY GameType, GameId;
