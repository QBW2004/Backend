-- 全民赛跑活动配置（2026-11-03）：后台「系统设置/活动配置」。幂等，可重复执行。
-- 先执行此补丁，再发布后台；中心服读不到表时按「活动关闭」下发，不影响大白兔正常开局。
-- 只建表、不插入行：未在后台保存前活动保持关闭。
CREATE TABLE IF NOT EXISTS `activityconfig` (
    `ActivityKey` VARCHAR(32)  NOT NULL COMMENT '活动标识，全民赛跑=rabbit_race',
    `GameId`      INT          NOT NULL DEFAULT 0 COMMENT '所属游戏，全民赛跑=55 大白兔',
    `Enabled`     TINYINT      NOT NULL DEFAULT 0 COMMENT '1 开启 0 关闭（与 CfgJson.enabled 一致，便于查询）',
    `CfgJson`     TEXT         NOT NULL COMMENT '活动规则 JSON，中心服 0x5621 原样下发游戏服',
    `Operator`    VARCHAR(50)  NULL COMMENT '最后保存的后台账号',
    `UpdateTime`  DATETIME     NOT NULL COMMENT '最后保存时间',
    PRIMARY KEY (`ActivityKey`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='后台活动配置';
