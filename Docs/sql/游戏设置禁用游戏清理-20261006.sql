-- 游戏设置：删除全部已禁用(Enable=0)的游戏行
-- 背景：运营要求「游戏设置」页只保留开启中的游戏。
-- 影响评估（2026-10-06 线上实查）：
--   * 中心服 ServerCenterNew 启动时把 games 读进 mGameEnable，
--     缺行行=false 与 Enable=0 等价（ServerCenter.cpp 建子游戏转发端口处），无需重启。
--   * 后台读取均为 LEFT JOIN / Enable=1 过滤 / TryGetValue 回退；TableCoinRecord 对这 5 个 GameId 0 行。
--   * 残留配置（roomtableconfig/paragame/cardpayoutprofile 等按 GAME_ID 关联）保留为孤儿行，不影响后台展示。
--
-- 回滚用（如需恢复，去掉注释执行；Name 用 hex 字面量避免编码问题）：
-- INSERT INTO games (GameId,Name,Enable,GameType,Num) VALUES
--   (19, 0xE69187E992B1E6A091,         0, 2, 0),  -- 摇钱树
--   (21, 0xE58F8CE5938DE98791E9BE99E9B1BC, 0, 2, 0),  -- 双响金龙鱼
--   (29, 0xE98791E9B2A8E993B6E9B2A8,   0, 0, 0),  -- 金鲨银鲨
--   (42, '',                          0, 2, 0),  -- (空名,原八爪鱼)
--   (49, 0xE7BE8EE4BABAE9B1BC,         0, 2, 0);  -- 美人鱼

DELETE FROM games WHERE GameId IN (19,21,29,42,49) AND Enable <> 1;

-- 验证：应只剩 Enable=1 的 16 行
SELECT GameId, Name, GameType, Enable FROM games ORDER BY GameType, GameId;
