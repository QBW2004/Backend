# 历史 SQL 归档索引

2026-11-05：按用户要求清理多余 SQL。历史迁移、修复、种子数据与一次性排查文件已核对 SHA-256 后移到仓库外。它们有历史用途，归档不表示全部无效，也不表示每项都曾在线执行。

归档目录：`E:\MTH\MHT-Backend-db-archives\20261105-sql-prune`。完整路径、用途、边界与 SHA-256 见 [清单](legacy-sql-archive-manifest.json)。

新环境只使用 [正式数据库入口](README.md) 的 clean；当前结构与配置是基线。已有环境升级必须先比较实际缺项、准备增量和备份，不能直接重跑历史补丁或重导 clean。历史专题中的执行记录保留原意；其旧 SQL 链接已指向本索引。

旧的唯一索引提案不一定已采用，旧禁用游戏、清空配置、重写权重等语句也可能与现状冲突；不能把归档文件当作待执行清单。

本仓归档 66 份 SQL、1 份关联生成脚本。构建输出、测试证据、游戏存档以及正式 full/clean 均保留。

仍有用途的 [桌台归属只读检查](../Tools/db/check-line-ownership.sql) 已迁入 Tools/db；只有 SELECT，不是第三份数据库。现有验证程序读取正式 clean 中的结构，不再依赖已归档迁移。

| 原文件 | 历史用途 |
|---|---|
| <a id="sql-001"></a>`Docs/sql/create_roomtableconfig_card.sql` | 建立按桌牌机参数表 |
| <a id="sql-002"></a>`Docs/sql/fix_fish_room_base_bet.sql` | 修复旧鱼机房间base行底注与兑换参数 |
| <a id="sql-003"></a>`Docs/sql/fix_scoreswitch_decimal.sql` | 将鱼机炮值增量scoreSwitch扩展小数 |
| <a id="sql-004"></a>`Docs/sql/fix_usercontrolvalue_unique.sql` | 清理控牌重复行并拟加玩家/控制类型唯一索引 |
| <a id="sql-005"></a>`Docs/sql/games拉霸数据清洗.sql` | 修复历史拉霸游戏名称乱码、重复行及脏配置 |
| <a id="sql-006"></a>`Docs/sql/mth_clean_cardpayout_residual.sql` | 按未污染桌众数修复历史吃分概率残留 |
| <a id="sql-007"></a>`Docs/sql/mth_update_totalkill_backup.sql` | 建立总控桌台参数备份表并恢复历史残留概率 |
| <a id="sql-008"></a>`Docs/sql/roomtableconfig历史桌台同步.sql` | roomtableconfig历史桌台同步 |
| <a id="sql-009"></a>`Docs/sql/sync_bet_tableconfig.sql` | 同步旧押注模型桌数和按桌配置 |
| <a id="sql-010"></a>`Docs/sql/sync_pararoom_num_to_roomtableconfig.sql` | 同步旧房间NUM和桌台数及单房间模式 |
| <a id="sql-011"></a>`Docs/sql/上线清档-清空玩家与代理数据-20261017.sql` | 上线清档-清空玩家与代理数据 |
| <a id="sql-012"></a>`Docs/sql/代理送奖奖池-20261102.sql` | 代理送奖奖池 |
| <a id="sql-013"></a>`Docs/sql/全民赛跑活动配置-20261103.sql` | 全民赛跑活动配置 |
| <a id="sql-014"></a>`Docs/sql/公告唯一化与字号-20260923.sql` | 公告唯一化与字号 |
| <a id="sql-015"></a>`Docs/sql/删除玩家残留数据清理-20261002.sql` | 删除玩家残留数据清理 |
| <a id="sql-016"></a>`Docs/sql/动态桌台字段扩展.sql` | 动态桌台字段扩展 |
| <a id="sql-017"></a>`Docs/sql/多客户端包与代理线-20261030.sql` | 多客户端包与代理线 |
| <a id="sql-018"></a>`Docs/sql/大厅排行榜最新30条-20261027.sql` | 大厅排行榜最新30条 |
| <a id="sql-019"></a>`Docs/sql/大奖榜与播报统一事件-20261031.sql` | 大奖榜与播报统一事件 |
| <a id="sql-020"></a>`Docs/sql/大白兔小四梅50倍-20261103.sql` | 大白兔小四梅50倍 |
| <a id="sql-021"></a>`Docs/sql/奖池精准扣除与明细保留-20261103.sql` | 奖池精准扣除与明细保留 |
| <a id="sql-022"></a>`Docs/sql/幸运六狮庄闲和最小押分-20260925.sql` | 幸运六狮庄闲和最小押分 |
| <a id="sql-023"></a>`Docs/sql/性能索引.sql` | 性能索引 |
| <a id="sql-024"></a>`Docs/sql/房间桌台配置表坐席扩列.sql` | 房间桌台配置表坐席扩列 |
| <a id="sql-025"></a>`Docs/sql/手机端代理默认权限-20260901.sql` | 手机端代理默认权限 |
| <a id="sql-026"></a>`Docs/sql/手机端后台权限与记录保留-20260902.sql` | 手机端后台权限与记录保留 |
| <a id="sql-027"></a>`Docs/sql/手机端测试数据.sql` | 手机端测试数据 |
| <a id="sql-028"></a>`Docs/sql/拉霸三台新版默认权重-20261031.sql` | 拉霸三台新版默认权重 |
| <a id="sql-029"></a>`Docs/sql/拉霸清空按桌筹码-20261029.sql` | 拉霸清空按桌筹码 |
| <a id="sql-030"></a>`Docs/sql/新增ATT满花版-gameid25-20261011.sql` | 新增ATT满花版-gameid25 |
| <a id="sql-031"></a>`Docs/sql/新增大白兔-gameid55-20261101.sql` | 新增大白兔-gameid55 |
| <a id="sql-032"></a>`Docs/sql/最大坐席数固定配置.sql` | 最大坐席数固定配置 |
| <a id="sql-033"></a>`Docs/sql/清理拉霸旧开奖配置.sql` | 清理拉霸旧开奖配置 |
| <a id="sql-034"></a>`Docs/sql/游戏设置禁用游戏清理-20261006.sql` | 游戏设置禁用游戏清理 |
| <a id="sql-035"></a>`Docs/sql/游戏设置禁用游戏清理-20261010.sql` | 游戏设置禁用游戏清理 |
| <a id="sql-036"></a>`Docs/sql/点石成金名称同步-20261029.sql` | 点石成金名称同步 |
| <a id="sql-037"></a>`Docs/sql/玩家昵称设置标记-20261101.sql` | 玩家昵称设置标记 |
| <a id="sql-038"></a>`Docs/sql/玩家登录时间-20260918.sql` | 玩家登录时间 |
| <a id="sql-039"></a>`Docs/sql/玩家盈亏统一币口径-20261102.sql` | 玩家盈亏统一币口径 |
| <a id="sql-040"></a>`Docs/sql/线上games名称修正.sql` | 线上games名称修正 |
| <a id="sql-041"></a>`Docs/sql/鱼机桌台脏数据清理.sql` | 鱼机桌台脏数据清理 |
| <a id="sql-042"></a>`Docs/sql/麻将胡了代理线配置-20261101.sql` | 麻将胡了代理线配置 |
| <a id="sql-043"></a>`Docs/sql/麻将胡了免费恢复-20261102.sql` | 麻将胡了免费恢复 |
| <a id="sql-044"></a>`Docs/sql/麻将胡了控制金币进度-20261102.sql` | 麻将胡了控制金币进度 |
| <a id="sql-045"></a>`Docs/sql/麻将胡了配套中奖结构-20261102.sql` | 麻将胡了配套中奖结构 |
| <a id="sql-046"></a>`Docs/sql/麻将胡了配套基础结构-20261102.sql` | 麻将胡了配套基础结构 |
| <a id="sql-047"></a>`Docs/押注类一房N桌迁移.sql` | 押注类一房N桌迁移 |
| <a id="sql-048"></a>`Docs/押注类数据修复.sql` | 押注类数据修复 |
| <a id="sql-049"></a>`mth_update_agent_permissions.sql` | 新增代理删除/查看密码/修改密码权限字段 |
| <a id="sql-050"></a>`mth_update_bet_vicedraw.sql` | 设置旧版六狮与单挑房间/按桌限红 |
| <a id="sql-051"></a>`mth_update_laba_betscores.sql` | 旧版拉霸按桌筹码初始化 |
| <a id="sql-052"></a>`Tools/one-off/_check_winloss.sql` | 历史一次性检查/校准脚本 |
| <a id="sql-053"></a>`Tools/one-off/_probe_accountlog.sql` | 历史一次性检查/校准脚本 |
| <a id="sql-054"></a>`Tools/one-off/_probe_agencylog.sql` | 历史一次性检查/校准脚本 |
| <a id="sql-055"></a>`Tools/one-off/_probe_lastlogin.sql` | 历史一次性检查/校准脚本 |
| <a id="sql-056"></a>`Tools/one-off/_probe_ledger.sql` | 历史一次性检查/校准脚本 |
| <a id="sql-057"></a>`Tools/one-off/_probe_login_tmp.sql` | 历史一次性检查/校准脚本 |
| <a id="sql-058"></a>`Tools/one-off/_probe_login_trigger.sql` | 历史一次性检查/校准脚本 |
| <a id="sql-059"></a>`Tools/one-off/_probe_online_perf.sql` | 历史一次性检查/校准脚本 |
| <a id="sql-060"></a>`Tools/one-off/_probe_opt_semantics.sql` | 历史一次性检查/校准脚本 |
| <a id="sql-061"></a>`Tools/one-off/_probe_session.sql` | 历史一次性检查/校准脚本 |
| <a id="sql-062"></a>`Tools/one-off/_probe_users.sql` | 历史一次性检查/校准脚本 |
| <a id="sql-063"></a>`Tools/one-off/_prod_games_del_probe.sql` | 历史一次性检查/校准脚本 |
| <a id="sql-064"></a>`Tools/one-off/_prod_games_enabled.sql` | 历史一次性检查/校准脚本 |
| <a id="sql-065"></a>`Tools/one-off/_prod_laba_activity_probe.sql` | 历史一次性检查/校准脚本 |
| <a id="sql-066"></a>`Tools/one-off/mjhl-calibrate/apply.sql` | 历史一次性检查/校准脚本 |
| <a id="sql-067"></a>`Tools/one-off/_seed_phone_testdata.py` | 历史手机联调数据生成器 |

需要复查原文时，按清单的归档路径读取；如确需恢复文件，先核对 SHA-256，再复制到明确的隔离目录审查，不自动送回初始化或发布链路。

影响范围为 F17 初始化入口和 F18 存储/恢复：归档文件、调整测试结构来源、同步索引和缺表提示；线上数据库、程序和状态文件不在本轮改动范围。归档哈希、当前引用、后台专项和服务端 1670 项隔离检查均通过；完整结果与耗时见 [验证记录](legacy-sql-verification.json)。E 盘空间不足时采用 F 盘的新隔离输出目录，旧失败证据、构建产物和历史测试数据保留。
