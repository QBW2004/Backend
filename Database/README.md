# 两套数据库的唯一入口

> 2026-11-06 鱼机/押注机器人总数与每桌上限另需 [robot_seat 新增列升级](../Tools/db/robot-table-limit-20261106.sql)，本地隔离验证通过、未在线执行。此增量仅新增 `MAX_PER_TABLE`，不改历史人数；full/clean 原快照不改写。使用本功能的新装/升级均须在发布流程应用该增量，详见 [实现与验收](../Docs/鱼机押注机器人总数与每桌上限-20261106.md)。

> 2026-11-06 待发布版本新增排行榜原始坐标列：配套代码需要执行 [排行榜桌台范围增量](../Tools/db/rank-history-table-scope-20261106.sql)，仅本地隔离验证通过，未在线上执行。现有 full/clean 仍保留原始快照和哈希，不手工伪装为新版导出；使用当前 clean 初始化并部署此新版本时，在同一安装流程执行这份新增量。该文件是版本升级，不是第三套完整数据库，也不要求重跑已归档迁移。具体依赖见 [三端联调](../Docs/大厅排行榜-三端联调.md)。

2026-11-05 **20:47:29（UTC+8）已上线**，后台仍为 **1.0.107 / MySQL 5.7.44**；线上已导入 `admina` 干净库并保留原管理员密码、权限及游戏存档。当前 full 是停写后、切换前 **20:47:15**（`2026-11-05T12:47:15.1537615Z`）的最终完整备份；clean 仍由 **19:53:12** 的早期原始快照派生，没有用最终 full 重新清洗。执行范围及回退依据见 [上线验收记录](../Docs/干净库上线与admina验收-20261105.md)。

| 文件 | 用途 | 数据范围 |
|---|---|---|
| `mth_full.sql` | 最终切换前恢复与排查 | 20:47:15 停写备份的完整结构与全部数据，含 18 个管理员、37 个玩家；保持原始导出字节 |
| `mth_clean.sql` | 已部署的初始化库 | 早期源快照衍生的完整结构、系统与游戏配置；仅保留总管理员 admina，清空业务历史与运行状态 |

这两个 SQL 保存在本地仓库目录，但含生产数据或初始化管理员凭据，均被 Git 忽略；应通过受控备份渠道传递。Git 保存本说明、清洗策略、哈希和验证记录。克隆仓库后须另行取得相应 SQL，不能用旧迁移拼出初始库。当前干净库总管理员账号为 `admina`，沿用原总管理员密码；权限与清零策略不变，不在文档展示密码。后台 `Web.config` 的 `appSettings/admin` 必须同步为 `admina`，控制指令会使用该键识别总台身份。

## 干净库保留与清理

- 两份都包含 **73 张基表、1 个视图、1 个登录记录触发器、5 个存储过程**，线上无事件。保留所有结构、索引和字段类型。
- 保留 **19 款游戏目录，其中 14 款开启**、公共桌台与参数、权限模板、客户端包、运营公告、活动规则及麻将公共参数。不开启线上已停用的游戏。
- 删除玩家、下级代理、机器人实例、关系、充值/退钻/盈亏/中奖/登录记录、控制、恢复状态、发件箱和历史流水。44 张表保留结构但清空数据，详见 [clean-policy.json](clean-policy.json)。
- 总管理员资金清零；拉霸累计库存/奖池清零；机器人数量归零，新环境通过后台设置名额后生成新机器人。
- 原代理专属桌按当前 `roomtableowner.LineAgent='#'` 收回规则处理，保留真实桌号和参数，不误公开旧专属桌。新代理可从公共桌复制。
- 麻将仅保留 `LineAgent='*'`；保留其 JSON、版本与校验哈希。活动和麻将的操作人统一为保留的总管理员。`games.Num` 清零。
- `cardpayoutprofile.StockLimit/StockRemain` 包含麻将轴权重、押注编码，属于配置，**没有**当作余额清零。清洗前精确确认 `totalkill_table_backup=0`，没有遗留吃分参数需要恢复。
- 全量 SQL 中 408 行历史 DDL 注释含 GBK 字节；全量原样保留且已成功导入。干净库仅将这些注释转为 UTF-8，业务数据未转码。

清洗时 22 张保留表的行数和 `CHECKSUM TABLE ... EXTENDED` 与早期源快照一致；7 张表按上述规则定向处理；44 张表为空。清洗采用闭合表清单，新表出现时脚本会拒绝继续，必须先分类。

## 新环境初始化

MySQL 使用 **5.7.44、`lower_case_table_names=1`、utf8mb4，目标库默认排序规则必须为 `utf8mb4_unicode_ci`**。这是本次线上实查值；存储过程参数继承库的排序规则，使用 `general_ci` 会使代理层级查询失败。以有权创建表、视图、触发器和存储过程的安装账户导入；快照含原有 `DEFINER=root@localhost`。SQL 不创建数据库，也不含 `USE`，由入口明确选择目标库。

本地隔离库示例（密码通过安全提示或 `MYSQL_PWD` 提供，不写进命令）：

```powershell
.\Tools\db\reset-db.ps1 -DbName mth_new -Port <本地端口> -MySqlExe <mysql.exe完整路径>
```

该命令会要求确认并重建指定库；默认导入 `Database/mth_clean.sql`，不叠加历史补丁。导入 full 时显式传 `-SqlFile Database\mth_full.sql`。Docker 首次初始化直接挂载 clean；已有数据卷不会被自动覆盖。详情见 [Docker 指南](../Docs/docker-mysql.md)。

**初始化入口默认面向新的空环境。** 替换已有运营库必须按单独授权的部署清单执行并先备份；本次用户授权范围是替换数据库、保留现有游戏存档，不清理服务端状态文件。新环境还必须部署匹配的后台、中心、游戏服及 Robot，配置数据库连接、管道、文件目录、域名/证书与客户端包。数据库快照不包含服务端文件存档、文件奖池、`RabbitActivity.dat` 活动台账或遗留 SQLite 文件；全新环境需按配套版本准备运行目录，现有环境保留原状态。真实支付通道、网络和 APK 联调须在目标环境验收。

## 更新这两套库

1. 从当前线上只读导出 `mth`，使用 `--single-transaction --quick --hex-blob --routines --triggers --events --set-gtid-purged=OFF`；全 InnoDB，避免锁表。先写仓库外备份，再校验两端 SHA-256。
2. 将旧两套 SQL 归档到仓库外，新的完整导出放 `Database/mth_full.sql`。不要覆盖未经归档的快照。
3. 在专用本地 MySQL 5.7 实例中，以 `utf8mb4_unicode_ci` 创建名称以 `mth_snapshot_` 开头的库，再恢复 full。实例须用非 3306/3307 端口，不复用开发或生产实例。
4. 安装 Python `pymysql` 后执行清洗与双向验证；脚本只连接 `127.0.0.1`，新建唯一测试库，拒绝覆盖已有 clean。示例：

```powershell
python Tools\db\make-clean-db.py --mysql-bin <MySQL的bin目录> --port <隔离端口> --source-schema mth_snapshot_full --admin-account admina --evidence-dir <仓库外或.build证据目录>
```

5. 脚本默认以 `Database/mth_full.sql` 为源，核对恢复源库与源文件的每表校验值，再清洗、导出和重新导入 clean。仅全部通过才生成正式 `mth_clean.sql`。如只从已归档的干净库派生，显式传 `--source-sql <归档clean的完整路径>`，`--source-schema` 必须恢复自同一文件；报告分别记录源文件角色和 SHA-256，不能将该结果当作重新导出 full。**省略 `--admin-account` 会保留源账号；从当前未改名的 full 再生时仍须传 `--admin-account admina`。** 脚本保留新建隔离库供检查，停用时仅处理该隔离实例。
6. 更新 [manifest.json](manifest.json) 并运行实际后台程序集的配置/登录/建号验证。不能只凭建表数宣称全部业务已通过。

## 本次归档与验证

原有 **13 份完整或近完整快照及 6 份 Docker 迁移副本**已逐文件校验 SHA-256 后移出工作区，保存在 `E:\MTH\MHT-Backend-db-archives\20261105-consolidation`，详见 [archive-manifest.json](archive-manifest.json)。后续按用户要求进一步将后台 **66 份历史迁移/修复/种子/一次性 SQL 和 1 份旧种子生成器**归档至 `20261105-sql-prune`；服务端另归档 14 份，见 [历史 SQL 索引](legacy-sql-archive.md)。它们有历史用途，不表示全部执行过或逐句等价于 clean；当前测试改读正式 clean，旧专题保留发布事实并链接归档。

当前只维护两份数据库 SQL，另保留 [桌台归属只读检查](../Tools/db/check-line-ownership.sql)。该检查只有 SELECT，不是第三套库。旧 `usercontrolvalue/userrelations` 唯一索引提案未采用；历史禁用游戏或覆盖权重脚本也不应重跑。本轮只整理本地仓库，没有重新执行 SQL；`.build`、构建输出、历史测试证据和游戏存档均保留。

当前 full 为 **15,704,248 字节**，SHA-256 为 `efb4d701f63b11053c79da5625e02d5b36895fef9691431a9a749623b8f210df`。最终备份下载的 **136 个文件**哈希通过，其中运行文件 134 个；两次独立下载的 ready/runtime 清单字节一致。full 本地隔离回导 **5.511 秒**，73 张表完整性检查通过，18 个管理员、37 个玩家，结构签名与当前 clean 一致；验证及文件替换共 **6.724 秒**。原 full（SHA-256 `27f9735e614473a4014a01d48abb838baa1f5a07f30f8dac6806bb0e14807469`）已核验归档至 `E:\MTH\MHT-Backend-db-archives\20261105-admina\mth_full_before_final_cutover.sql`，保留为 clean 的源头证据。

当前 `admina` 版 clean 为 **396,748 字节**，SHA-256 为 `86bd1bbb5082dbd9f31c7e5a42d9a3556b232cfff60cbabcb0e72060b6c894ec`。它只从原干净库的归档文件派生，未使用有测试写入的库；仅改 `admin.ID`、`activityconfig.Operator`、`mjhl_agent_config.UpdatedBy`。原管理员密码、权限、资金与更新时间均保持不变。源文件回导 **2.065 秒**、导出 **0.401 秒**、成品回导 **2.048 秒**，含全表数据、结构与存储过程参数排序规则校验共 **5.639 秒**，通过。

对当前 SHA 使用已发布 **1.0.107** 程序集验证，合计 **249 项通过**：**185 项 / 5.122 秒**覆盖 14 款开放游戏的实际 Controller 和 `JsonResult.ExecuteResult`；**64 项 / 4.141 秒**覆盖 `admina` 登录、错误密码拒绝、总台控制身份、建代理/玩家、层级存储过程、邀请/分页/盈亏/登录触发器、Robot/奖池/活动。独立测试库回导耗时 **2.088 秒**，测试写入仅在该副本。证据位于 `.build/database-consolidation-20261105/admina/`，完整结果及 DLL/SQL 哈希见 [manifest.json](manifest.json)。

历史 clean 的 SHA-256 为 `dba81c1752e4eab412d8c8db8b36c42bd85708dc2460dead4d62eb2182aae0ba`，已归档到 `E:\MTH\MHT-Backend-db-archives\20261105-admina\mth_clean_before_admina.sql`。其原始导入/清洗 **8.687 秒**、配置 **185 项**、业务 **61 项 / 4.066 秒**、reset/export 往返 **1.08 秒**、专属桌台 **203 项 / 5.61 秒**、盈亏 **17 项 / 4.61 秒**保留在 manifest 的 `historicalVerification`，这些旧报告不冒充当前 SHA 的复测结果。

验证过程中保留的限制：全量扫描旧 EF 模型会遇到 `pararoom.Game_Mo` 历史 NULL，现行鱼机配置 Controller 已用显式 SQL 兼容；旧 AppUpdate 菜单已注释，未为其缺失的旧 `updateaddr` 表造数据。首次使用 general_ci 的隔离导入导致代理存储过程失败，已通过 unicode_ci 重导修正并纳入恢复前置条件。盈亏测试旧驱动默认 SSL 握手失败，仅隔离验证副本加 `SslMode=None` 后通过。

线上已完成 **290 项真实 HTTP 检查 / 6.892 秒**，覆盖电脑/手机登录、受保护 Razor、14 款游戏配置、麻将与活动/逐桌规则、零余额临时代理/玩家生命周期及精确清理；删除测试玩家的 KU 已确认。公网电脑登录、手机登录、`/Api/Games` 三项 HTTPS 均为 200，证书校验通过，耗时 **13.951 秒**。正式切换维护窗口 **19.306 秒**，导入期间 134 个运行文件哈希不变；恢复运行后的正常落盘不要求哈希永远不变。

尚未执行真实进桌/下注/结算、充退钻、支付回调、控制开牌、客户端真机或浏览器交互回归。后续人工验收约 5–10 分钟可检查新账号客户端登录、各游戏选桌/进退桌与余额显示；涉及资金或下注时须按具体授权范围记录与清理，不能将 HTTP 通过称为全游戏结算通过。

## 影响与发布范围

| 影响编号 | 处理与依据 |
|---|---|
| F18 存储/迁移/恢复 | 修改两套快照、清洗工具与初始化入口；完整导入、数据校验、结构比对 |
| F17 环境/启停/发布 | Docker、新装及本地 reset 统一 clean；线上和本地 Web.config 的 admin 键已同步，正式切换 19.306 秒，详见上线验收记录 |
| F01–F04、F08–F14 | 保留登录、权限、游戏、桌台、规则所需结构和配置；清除业务与运行数据，验证公共参数和实际后台加载 |
| F05–F07、F15–F16 | 没有改客户端、协议、游戏算法、UI或程序集；真实进桌、下注、结算、支付及 APK 验收未在此次导库中执行 |

当前源码分支 `codex/mjhl-rtp-fast-preview`；后台业务源码与程序集未改。两处专项验证程序的 SQL 基线路径改为 clean；目标站点与本地 `Web.config` 的 admin 键已同步。本次未递增前端版本或替换后台、中心、游戏服、Robot、APK 产物；完整部署、HTTP 与回退记录见 [上线验收记录](../Docs/干净库上线与admina验收-20261105.md)。
