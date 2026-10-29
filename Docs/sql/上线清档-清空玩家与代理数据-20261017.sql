-- ============================================================================
-- 上线清档：清空全部玩家数据与代理数据（仅保留超管 atmadmin）2026-10-17
-- ============================================================================
-- 目标库：线上 mth（服务器本机 MySQL，localhost:3306）。
--
-- ⚠️ 执行顺序（重要，不要颠倒）：
--   1. 先停游戏服：ServerCenterNew.exe（中心服）+ 全部子游戏进程
--      （ServerCard*/ServerFish*/ServerLaba* 等）。
--      中心服内存里缓存着玩家档案，开着服清库，缓存可能把已删玩家写回
--      users，或把在途流水继续写进日志表，清不干净。
--      IIS 后台站点不用停（停了反而没法从后台验证），它无状态。
--   2. mysqldump 全库备份（必须带 --routines --triggers，
--      users 表上挂着 trg_users_login_record 登录时间触发器）：
--        mysqldump -u root -p<密码> --routines --triggers mth > mth_prelaunch_backup_20261017.sql
--   3. 执行本脚本：
--        mysql -u root -p<密码> --default-character-set=utf8mb4 mth < 本文件
--      mysql 客户端遇错即停（本脚本未加 --force），哪一步报错就停在哪一步。
--   4. 重启中心服 + 各游戏服，回收 IIS 应用池，后台登录 atmadmin 验证。
--
-- 保留不动：
--   - admin 表仅保留 ID='atmadmin'（代码中 PRIV=0 / 总台语义，删除按 ID 判定）
--   - 全部游戏/桌台/牌型配置：games/gamepara/gameconfiglaba/gameacclaba/
--     paracard/parafish/parabet/parabetroom/paragame/paralaba/pararoom/
--     roomtableconfig/roomtableconfig_bet/roomtableconfig_card/betgamecfg/
--     cardpayoutprofile（含库存余量与奖池当前值，按要求不归零）/plattype/gamemo
--   - 机器人体系：userrobot/userrobotnum/robot_seat（机器人账号不落在 users）
--   - 运营内容：notice/activity/updateaddrnew/uploadsimage/mgrpermission/
--     agent_permission_template
--   - 一次性备份残留表（totalkill_table_backup/*_bak 等）不影响运行，未动
--   - users 表上的 trg_users_login_record 触发器（只清 userloginrecord 数据）
--
-- 清空（TRUNCATE，自增列归零）：
--   玩家本体/关系：users、userrelations
--   资金与流水：rechargerecords、ex_change、clientexchangerecord、transferlog、
--     safe_coins_log、sharebonus、tablecoinrecord、videogamecoinrecord、
--     games_money_spent、user_daily_winloss、userscoresnapshotledger、
--     gameprizerecord、rank
--   控制/状态：usercontrolstatus、usercontrolvalue、manageropt
--   日志：useroptlog、userloginrecord、userlockrecord、loginmissrecord、accountlog
--   代理相关：agencyoptlog、agent_hierarchy、invite_codes
--   中转：gamecommandoutbox
-- 清空（DELETE，按归属）：
--   admin（ID<>'atmadmin'）、cashierinfo（所属代理已不存在的行）
-- ============================================================================

-- ############################################################
-- 第 0 步：执行前诊断 + 守卫（atmadmin 不存在则整个脚本中止）
-- ############################################################

-- 0.1 清档前数据量快照（留作与第 4 步核对）
SELECT 'users' AS tbl, COUNT(*) AS before_cnt FROM users
UNION ALL SELECT 'admin',             COUNT(*) FROM admin
UNION ALL SELECT 'rechargerecords',   COUNT(*) FROM rechargerecords
UNION ALL SELECT 'clientexchangerecord', COUNT(*) FROM clientexchangerecord
UNION ALL SELECT 'agencyoptlog',      COUNT(*) FROM agencyoptlog
UNION ALL SELECT 'cashierinfo',       COUNT(*) FROM cashierinfo;

-- 0.2 将被保留的账号（应只有 atmadmin，PRIV 应为 0）
SELECT ID, PRIV, AGENCY, RE_ENABLE, CreateTime FROM admin WHERE ID = 'atmadmin';

-- 0.3 守卫：atmadmin 不存在直接报错中止，防止误删到无人能登录
DROP PROCEDURE IF EXISTS `__mth_guard_atmadmin`;
DELIMITER $$
CREATE PROCEDURE `__mth_guard_atmadmin`()
BEGIN
    IF NOT EXISTS (SELECT 1 FROM `admin` WHERE ID = 'atmadmin') THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'ABORT: admin 表中不存在 atmadmin，已中止（未做任何删除）';
    END IF;
END$$
DELIMITER ;
CALL `__mth_guard_atmadmin`();
DROP PROCEDURE `__mth_guard_atmadmin`;


-- ############################################################
-- 第 1 步：admin 只留 atmadmin
-- ############################################################
DELETE FROM `admin` WHERE ID <> 'atmadmin';
SELECT 'admin' AS after_step1, COUNT(*) AS cnt FROM admin;


-- ############################################################
-- 第 2 步：批量 TRUNCATE 数据表（表不存在则跳过，可重复执行）
-- ############################################################
DROP PROCEDURE IF EXISTS `__mth_truncate_if_exists`;
DELIMITER $$
CREATE PROCEDURE `__mth_truncate_if_exists`(IN p_tbl VARCHAR(64))
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.TABLES
               WHERE TABLE_SCHEMA = DATABASE()
                 AND TABLE_NAME = p_tbl
                 AND TABLE_TYPE = 'BASE TABLE') THEN
        SET @__t = CONCAT('TRUNCATE TABLE `', p_tbl, '`');
        PREPARE __stmt FROM @__t;
        EXECUTE __stmt;
        DEALLOCATE PREPARE __stmt;
        SELECT p_tbl AS truncated;
    ELSE
        SELECT p_tbl AS skipped_not_exists;
    END IF;
END$$
DELIMITER ;

-- 玩家本体与账号映射
CALL `__mth_truncate_if_exists`('users');
CALL `__mth_truncate_if_exists`('userrelations');
-- 资金与流水记录
CALL `__mth_truncate_if_exists`('rechargerecords');
CALL `__mth_truncate_if_exists`('ex_change');
CALL `__mth_truncate_if_exists`('clientexchangerecord');
CALL `__mth_truncate_if_exists`('transferlog');
CALL `__mth_truncate_if_exists`('safe_coins_log');
CALL `__mth_truncate_if_exists`('sharebonus');
CALL `__mth_truncate_if_exists`('tablecoinrecord');
CALL `__mth_truncate_if_exists`('videogamecoinrecord');
CALL `__mth_truncate_if_exists`('games_money_spent');
CALL `__mth_truncate_if_exists`('user_daily_winloss');
CALL `__mth_truncate_if_exists`('userscoresnapshotledger');
CALL `__mth_truncate_if_exists`('gameprizerecord');
CALL `__mth_truncate_if_exists`('rank');
-- 玩家控制/风控记录
CALL `__mth_truncate_if_exists`('usercontrolstatus');
CALL `__mth_truncate_if_exists`('usercontrolvalue');
CALL `__mth_truncate_if_exists`('manageropt');
-- 日志类
CALL `__mth_truncate_if_exists`('useroptlog');
CALL `__mth_truncate_if_exists`('userloginrecord');
CALL `__mth_truncate_if_exists`('userlockrecord');
CALL `__mth_truncate_if_exists`('loginmissrecord');
CALL `__mth_truncate_if_exists`('accountlog');
-- 代理侧
CALL `__mth_truncate_if_exists`('agencyoptlog');
CALL `__mth_truncate_if_exists`('agent_hierarchy');
CALL `__mth_truncate_if_exists`('invite_codes');
-- 游戏服命令中转（残留命令大多指向已删玩家）
CALL `__mth_truncate_if_exists`('gamecommandoutbox');

DROP PROCEDURE `__mth_truncate_if_exists`;


-- ############################################################
-- 第 3 步：cashierinfo 只留归属尚存账号的收款信息
-- ############################################################
-- Agency 列是所属代理 ID，代理已删的行一并删除（atmadmin 名下若有则保留）。
DELETE c FROM `cashierinfo` c
LEFT JOIN `admin` a ON a.ID = c.Agency
WHERE a.ID IS NULL;


-- ############################################################
-- 第 4 步：核对（以下应全部为 0；admin/cashierinfo 除外）
-- ############################################################
SELECT 'users' AS tbl, COUNT(*) AS after_cnt FROM users
UNION ALL SELECT 'userrelations',          COUNT(*) FROM userrelations
UNION ALL SELECT 'rechargerecords',        COUNT(*) FROM rechargerecords
UNION ALL SELECT 'ex_change',              COUNT(*) FROM ex_change
UNION ALL SELECT 'clientexchangerecord',   COUNT(*) FROM clientexchangerecord
UNION ALL SELECT 'transferlog',            COUNT(*) FROM transferlog
UNION ALL SELECT 'safe_coins_log',         COUNT(*) FROM safe_coins_log
UNION ALL SELECT 'sharebonus',             COUNT(*) FROM sharebonus
UNION ALL SELECT 'tablecoinrecord',        COUNT(*) FROM tablecoinrecord
UNION ALL SELECT 'videogamecoinrecord',    COUNT(*) FROM videogamecoinrecord
UNION ALL SELECT 'games_money_spent',      COUNT(*) FROM games_money_spent
UNION ALL SELECT 'user_daily_winloss',     COUNT(*) FROM user_daily_winloss
UNION ALL SELECT 'userscoresnapshotledger', COUNT(*) FROM userscoresnapshotledger
UNION ALL SELECT 'usercontrolstatus',      COUNT(*) FROM usercontrolstatus
UNION ALL SELECT 'usercontrolvalue',       COUNT(*) FROM usercontrolvalue
UNION ALL SELECT 'manageropt',             COUNT(*) FROM manageropt
UNION ALL SELECT 'useroptlog',             COUNT(*) FROM useroptlog
UNION ALL SELECT 'userlockrecord',         COUNT(*) FROM userlockrecord
UNION ALL SELECT 'loginmissrecord',        COUNT(*) FROM loginmissrecord
UNION ALL SELECT 'accountlog',             COUNT(*) FROM accountlog
UNION ALL SELECT 'agencyoptlog',           COUNT(*) FROM agencyoptlog
UNION ALL SELECT 'agent_hierarchy',        COUNT(*) FROM agent_hierarchy
UNION ALL SELECT 'invite_codes',           COUNT(*) FROM invite_codes
UNION ALL SELECT 'gamecommandoutbox',      COUNT(*) FROM gamecommandoutbox
UNION ALL SELECT 'admin(应=1)',            COUNT(*) FROM admin
UNION ALL SELECT 'cashierinfo(剩归属atmadmin的)', COUNT(*) FROM cashierinfo;

-- 4.x 兜底：列出库里仍可能带用户数据、但不在本次清单内的表，人工确认
-- （TABLE_ROWS 为 InnoDB 估算值，仅供肉眼扫，精确数以第 4 步为准）
SELECT TABLE_NAME, TABLE_ROWS
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = DATABASE() AND TABLE_TYPE = 'BASE TABLE'
  AND TABLE_NAME IN ('userloginrecord','gameprizerecord','roomtableconfig_card',
                     'totalkill_table_backup','usercontrolvalue_bak',
                     'cardpayoutprofile_bak','parabetroom_bak_20260815');


-- ============================================================================
-- 可选项（默认不执行，需要时去掉注释单独跑）
-- ============================================================================
-- A. 超管 atmadmin 的累计充退/钱包计数归零（注意：COINS 是代理钱包余币，
--    清零前确认运营不需要保留该数值）：
-- UPDATE admin SET COINS=0, RECHARGE=0, EXCHANGE=0, COINS_BUY=0, COINS_BACK=0
-- WHERE ID='atmadmin';
--
-- B. 一次性备份残留表一并删除（不影响运行，纯粹腾名字）：
-- DROP TABLE IF EXISTS totalkill_table_backup, usercontrolvalue_bak,
--                      cardpayoutprofile_bak, parabetroom_bak_20260815;
--
-- C. 测试期累积的机台库存余量回满、奖池值回默认（本次选了保留现状，勿跑）：
-- UPDATE cardpayoutprofile SET StockRemain = StockLimit;
-- （gameacclaba 奖池初值需按运营口径逐 GameId 设定，不在此提供）
-- ============================================================================
