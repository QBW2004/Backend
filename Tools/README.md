# Tools 目录脚本说明

- `dev/check-multi-seat-robot.ps1`：鱼机/押注总数、每桌上限的实际BLL及MVC JSON验证；独立启动本地MySQL 33406，临时表结构只取clean，测试后删临时库并停止本次实例，不访问生产管道。
- `db/robot-table-limit-20261106.sql`：本次新增列升级（非初始化全库），运营库执行前备份；依赖和验收见[专题](../Docs/鱼机押注机器人总数与每桌上限-20261106.md)。

> 2026-11-05 复核。先读 [工作边界](../AGENTS.md)、[当前开发与交付指南](../Docs/architecture/backend-development.md)。本页说明脚本用途；参数、部署副本与目标环境每次核对，目录中的历史脚本不是自动执行清单。
> 带 `_` 前缀的是历次一次性排查/迁移脚本；需使用时先复核参数、路径、数据范围和副作用。

```
Tools/
├── server-env/    服务器环境安装 / 检测（在服务器上跑）
├── deploy/        部署与打包
├── dev/           本地构建 / 起站
├── db/            本地数据库
├── one-off/       一次性排查 / 迁移脚本（_ 前缀，仅留档）
└── README.md
```

## server-env/ — 服务器环境安装 / 检测（装机用）

| 脚本 | 用途 |
|---|---|
| `env-check.ps1` / `env-check.bat` | **部署环境检测 + 一键补装**。默认检测并自动安装缺失组件、注册服务或修改防火墙；只读检查必须用 `-CheckOnly`。安装范围包括 .NET Framework 4.8、VC++ Redist、IIS/ASP.NET、MySQL5.7；先核对目标机器与参数。 |
| `fix-legacy-ucrt.ps1` / `fix-legacy-ucrt.bat` | **Server 2012 R2 专用** UCRT 补丁链修复（KB2919442 → clearcompressionflag → KB2919355 → … → KB2999226）。一次性系统级变更、装完必重启；KB2919355 有少量存储控制器重启循环的已知问题，故需手动输入 `CONTINUE` 确认。KB2999226 无稳定直链，需手动下载放到本目录 `ucrt-patches\` 下。 |
| `server_deploy_check.ps1` | 只读采集服务器现状（IIS 站点/应用池、进程、Web 目录 bin 时间戳与 Web.config 关键项、中心服、命名管道、监听端口、日志），结果存桌面 `server_info.txt`。远程排查先跑这个。 |
| `Start-MTH-Backend.bat` | 启动 MySQL/IIS、Daemon 托管游戏与独立 Robot。先核对实际服务器脚本、Daemon列表和既有进程，防止无托管旧进程重复启动；旧桌面副本的日期不能证明它与仓库相同。纯 ASCII 包装保持原编码。 |

`env-check.ps1` 参数：
- 默认行为：管理员权限下检测到缺失必需项直接下载安装，全程无需确认
- `-CheckOnly` 仅检测不改动机器（巡检用）
- `-Yes` 已废弃（自动修复现为默认行为，传不传效果相同）
- `-WebPort <n>` 防火墙放行的站点端口，默认 80
- `-MySqlRootPassword <pwd>` 全新装 MySQL 时设置的 root 密码（默认与 Web.config 一致；已有服务不会覆盖）
- `-InitSchema` MySQL 全新初始化时顺便从仓库 `Database/mth_clean.sql` 导入完整结构和干净配置（需随完整仓库拷到服务器）

`fix-legacy-ucrt.ps1` 参数：`-CheckOnly` / `-Yes`（跳过逐项询问，但**绕不过** CONTINUE 风险确认）/ `-AutoReboot` / `-PatchDir`。

运行要点：
- 都要**管理员身份**运行；脚本内置 WOW64 逃离（SSH 32 位会话会自动用 Sysnative 重启为 64 位）。
- `.bat` 是给 cmd 双击/远程执行用的纯 ASCII 包装（cmd 对含非 ASCII 字节的批处理有截断 bug），提示语全部由同名 `.ps1` 打印。
- 装机顺序：`env-check.bat` → 若报缺 UCRT 再跑 `fix-legacy-ucrt.bat` → 重启 → 回到 `env-check.bat` 继续。
- `env-check.ps1` 每次运行会在本目录生成 `env-check-report.txt`。

## deploy/ — 部署（发布到服务器）

| 脚本 | 用途 |
|---|---|
| `deploy.ps1` / `deploy.bat` | 把 TTY.Web zip 或解压目录部署为 IIS 站点：备份旧版到 `C:\Backend_backup_<时间戳>` → robocopy /MIR 到 `C:\Backend`（保留 `App_Data`/`Logs`/`Upload`）→ 校验应用池 v4.0/64 位 → 绑定 8081 → 放行防火墙 → 回收应用池 → HTTP 探测。`-CheckOnly` 只看状态；`-Yes` 免确认；`-NoBackup` 跳过备份；`-Port` 默认 8081。旧备份不会自动清理，需手动删。 |
| `pack.ps1` | 本地把 `TTY.Web` 打成部署 zip（排除 Logs/obj/.vs 并校验关键文件齐全）。用法：`powershell -File Tools\deploy\pack.ps1 -Version 1.0.16`。可选 `-SourcePath <完整站点目录>` 支持按线上基线隔离打包，避免夹带其它待上线改动；不传时仍使用本仓库 `TTY.Web`。（原名 `_pack.ps1`，归入长期脚本后去掉下划线前缀。） |

发布链路以确认的线上基线准备隔离完整站点，再用 `pack.ps1 -Version <版本> -SourcePath <隔离站点>` 打包并核对依赖。实际上传/部署只在用户已授权范围执行；不能默认把整个工作区作为发布源。
SQL 按本次迁移清单及实际缺项执行，先备份。历史补丁已移到仓库外，见 [归档索引](../Database/legacy-sql-archive.md)，不是每次部署的前置命令。

## dev/ — 本地开发 / 构建

| 脚本 | 用途 |
|---|---|
| `build.bat` | Clean + Release MSBuild（`build.bat Debug` / `noclean` 可变参）。缺 .NET48 引用程序集或 Web targets 时自动经 NuGet 补齐，无需 VS 全家桶。 |
| `start.ps1` / `start.bat` | IIS Express 起本地站点（默认 8080；`-Stop` 停止）。仓库根缺 `apphost.config` 时用直连路径模式。 |
| `nuget.exe` | 供 build.bat 自动补引用程序集用。 |
| `check-laba-weight-capacity.ps1` | 三拉霸权重容量专项；`-SitePath` 指定待发完整站点，使用实际 Web/BLL DLL 与 `127.0.0.1:33406` 临时 MySQL，验证超过旧单帧、桌号 999、U16 条数边界与失败事务回滚，完成删测试库并停本次实例。 |
| `check-rabbit-remaining.ps1` | 全民赛跑隔离 MySQL + 实际 BLL/MVC/WebAPI 回归，涵盖记录统计与权威文件台账。`-BinPath` 指定已构建 DLL，`-OutputPath` 可把临时库/证据放在有空间的磁盘，`-Variant` 区分测试产物；仅绑定 `127.0.0.1:33416`，使用 `lower_case_table_names=1`，结束删测试库并停止本次测试实例。 |

## db/ — 本地数据库

当前两套数据库、清洗范围和验证结果以 [Database/README.md](../Database/README.md) 为准。`make-clean-db.py` 从已恢复的完整快照生成并验证 clean，只允许专用本地 MySQL 5.7 实例；源库和目标库必须为 `utf8mb4_unicode_ci`，脚本会检查存储过程参数的排序规则。

| 脚本 | 用途 |
|---|---|
| `docker-db.bat` / `docker-db.ps1` | Docker MySQL 5.7 容器管理（start/stop/status/reinit；新卷首启只导入 `Database/mth_clean.sql`，reinit 危险会清库）。容器必须带 `--lower-case-table-names=1`，compose 已配置。 |
| `start-db.bat` / `start-db.ps1` | 本机（非 Docker）MySQL 服务启停/状态。 |
| `export-db.bat` / `export-db.ps1` | mysqldump 单事务导出，带 hex-blob/routines/triggers/events；默认输出到仓库外相邻的 `MHT-Backend-db-archives/`，不覆盖已有备份，也不在仓库新建第三份库。密码取 `MYSQL_PWD` 或交互输入。 |
| `backup-to-remote.ps1` / `register-remote-backup.ps1` / `remote-backup-receiver.py` | 已部署的每日 04:00 完整 SQL 异机备份，SYSTEM 执行、SSH 专用密钥、SHA-256 核验，成功后保留最近 3 个北京时间日期。源/目标、权限、日志和恢复证据见 [每日备份记录](../Docs/数据库每日异机备份-20261105.md)。注册脚本拒绝覆盖已有同名任务。 |
| `reset-db.bat` / `reset-db.ps1` | 重建本地隔离库，必须显式传 `-DbName`；默认导入 `Database/mth_clean.sql`，可用 `-SqlFile` 指定单库快照，不再叠加旧补丁。仅允许 loopback，保留确认及 `-Force`；`-DryRun` 不连接数据库。 |
| `check-line-ownership.sql` | 只读检查直属代理 ID 拼写、孤儿归属及大小写混用，三段 SELECT 的返回行需人工核对；不是初始化库，也不自动修复数据。 |

## one-off/ — 一次性脚本（`_` 前缀，仅留档，勿复用）

| 文件 | 当时的用途 |
|---|---|
| `_deploy_db.ps1` | 线上执行 migration 20：`pararoom.scoreSwitch` 改 DECIMAL(10,2)。 |
| `_deploy_probe.ps1` | 线上读 Web.config（密码脱敏）+ dump mth 结构。 |
| `_deploy_verify.ps1` | 部署后新旧 Web.config diff 校验。 |
| `_prod_precheck.ps1` / `_prod_apply.ps1` / `_prod_verify.ps1` | 线上灌手机端测试数据的前置检查 / 应用 / 验证（口令仅内存中取自 Web.config，不打印）。 |
| `_prod_run_sql.ps1` | 线上通用一次性 SQL 执行器。 |
| `_prod_gamescheck.ps1` / `_prod_postcheck.ps1` | 线上 games 表名称乱码排查 / 收尾检查。 |
| 旧手机联调种子生成器及一次性 SQL | 已与历史种子 SQL 一起移至仓库外，原路径、用途和哈希见 [归档索引](../Database/legacy-sql-archive.md)，不再向仓库生成第三份数据脚本。 |
| `_check_db.ps1` / `_check_login.ps1` / `_check_session.ps1` / `_debug_curl.ps1` | 登录/会话/数据库排查（带 Sysnative 逃离）。 |
| `_repro2.ps1` / `_repro3.ps1` / `_repro4.ps1` | 历次问题复现脚本。 |
| `_add_csproj.py` | 把手机端新增文件登记进 `YYT.Web.csproj`（在仓库根运行）。 |
| `_fix_ready_init.py` | phone.*.js 的 jQuery ready 初始化改为直接执行。 |
| `_rename_diamond.py` | 手机端文案 钻石→金币 批量替换。 |
| `_rename_coin_to_diamond.py` | 后台全端文案 金币/币→钻 批量替换（保护 货币/造币）。 |

注意：`_check_db.ps1`、`_check_login.ps1` 内嵌了数据库口令，若此目录会对外分发，先清理这两个文件。
