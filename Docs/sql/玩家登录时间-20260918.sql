-- ============================================================
-- 玩家登录（上线）时间记录 —— 「最后登录」数据源修正（2026-09-18）
-- ============================================================
-- 背景（运营反馈）：手机端玩家列表的「最后登录」在玩家在线时不刷新，
--   只有离线玩家才像有个"登录时间"。根因不是前端，是数据源：
--   后台一直取 `useroptlog` 的 MAX(REC_TIME)，而这张表游戏服只写
--   「进入/离开桌台（OPT 8/7）」「充值/兑换后（OPT 0-6）」「回退分数（OPT 99）」，
--   **从来不写登录事件**（ServerCenterRun.cpp 的 SaveUserLog 调用点可查）。
--   于是：在线玩家显示的是"最后一次进桌台的时间"（人一直在桌上就不动），
--   大厅挂机玩家显示的是上一局的旧时间，7 天内没记录的账号显示兜底 2000-01-01。
--
-- 方案：玩家上线时游戏服一定会写 `users.INHALL`（0→1：HallLogin 里的
--   SetUserOnlineImmediate，另有 20s 脏检查兜底）。本补丁在库内挂一个
--   AFTER UPDATE 触发器，把 0→1 的瞬间记进 `userloginrecord`；后台的
--   「最后登录」改为优先读这张表，没有记录时回退 useroptlog 旧口径。
--   好处：不动游戏服（不重启中心服/子游戏，不会踢在线玩家），时间即登录瞬间。
--
-- 幂等：可重复执行（CREATE TABLE IF NOT EXISTS + DROP TRIGGER IF EXISTS）。
-- 回滚：DROP TRIGGER `trg_users_login_record`; DROP TABLE `userloginrecord`;
--       （回滚后后台自动退回 useroptlog 口径，不会报错。）
-- ⚠️ 数据库迁移/导出必须带 --triggers（线上 2026-09-11 迁移用的正是
--    mysqldump --routines --triggers）。触发器丢失时后台只是回退旧口径。
-- ============================================================

CREATE TABLE IF NOT EXISTS `userloginrecord` (
  `LID` BIGINT NOT NULL AUTO_INCREMENT COMMENT '标识ID',
  `UserID` VARCHAR(50) NOT NULL COMMENT '玩家账号',
  `LoginTime` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '上线（登录）时间',
  PRIMARY KEY (`LID`),
  UNIQUE KEY `uk_userloginrecord_user_time` (`UserID`, `LoginTime`)
) ENGINE = InnoDB DEFAULT CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '玩家登录（上线）记录表';

DROP TRIGGER IF EXISTS `trg_users_login_record`;

DELIMITER $$
CREATE TRIGGER `trg_users_login_record`
AFTER UPDATE ON `users`
FOR EACH ROW
BEGIN
  -- 只做一件事：INHALL 由 0 变 1（玩家上线）时记一条时间。
  -- CONTINUE HANDLER 兜住触发器内任何异常：users 是游戏服的热表（余额/分数都写它），
  -- 触发器绝不能把游戏服的写入带崩；记不上就当没有，后台自动回退 useroptlog 口径。
  DECLARE CONTINUE HANDLER FOR SQLEXCEPTION BEGIN END;
  IF NEW.INHALL = b'1' AND (OLD.INHALL IS NULL OR OLD.INHALL = b'0') THEN
    INSERT INTO `userloginrecord` (`UserID`, `LoginTime`) VALUES (NEW.ID, NOW())
    ON DUPLICATE KEY UPDATE `LoginTime` = VALUES(`LoginTime`);
  END IF;
END$$
DELIMITER ;

-- 核对：应能查到 1 行 trg_users_login_record（AFTER UPDATE / users）
SELECT TRIGGER_NAME, EVENT_MANIPULATION, EVENT_OBJECT_TABLE, ACTION_TIMING
FROM information_schema.TRIGGERS WHERE TRIGGER_SCHEMA = DATABASE();

SELECT COUNT(*) AS userloginrecord_rows FROM `userloginrecord`;
