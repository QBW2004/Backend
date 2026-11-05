# Tools 目录脚本说明

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
- `-InitSchema` MySQL 全新初始化时顺便从仓库 `docker\mysql\init\*.sql` 导入表结构（需随完整仓库拷到服务器）

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
SQL按本次迁移清单及实际缺项执行，先备份；`Docs/sql/性能索引.sql` 是历史补丁，不是每次部署的前置命令。

## dev/ — 本地开发 / 构建

| 脚本 | 用途 |
|---|---|
| `build.bat` | Clean + Release MSBuild（`build.bat Debug` / `noclean` 可变参）。缺 .NET48 引用程序集或 Web targets 时自动经 NuGet 补齐，无需 VS 全家桶。 |
| `start.ps1` / `start.bat` | IIS Express 起本地站点（默认 8080；`-Stop` 停止）。仓库根缺 `apphost.config` 时用直连路径模式。 |
| `nuget.exe` | 供 build.bat 自动补引用程序集用。 |

## db/ — 本地数据库

| 脚本 | 用途 |
|---|---|
| `docker-db.bat` / `docker-db.ps1` | Docker MySQL 5.7 容器管理（start/stop/status/reinit；首启自动导入 `docker/mysql/init` SQL，reinit 危险会清库）。容器必须带 `--lower-case-table-names=1`，compose 已配置。 |
| `start-db.bat` / `start-db.ps1` | 本机（非 Docker）MySQL 服务启停/状态。 |
| `export-db.bat` / `export-db.ps1` | mysqldump 导出库（默认输出到本目录）。 |
| `reset-db.bat` / `reset-db.ps1` | 重建/重置隔离库（先读 `-Force`/`-DryRun` 与输入库路径）。补丁以脚本 `$patches` 列表为准，当前列5份；不保证与Docker初始化目录的全部文件一致，也不等于包含后续所有业务迁移。 |

## one-off/ — 一次性脚本（`_` 前缀，仅留档，勿复用）

| 文件 | 当时的用途 |
|---|---|
| `_deploy_db.ps1` | 线上执行 migration 20：`pararoom.scoreSwitch` 改 DECIMAL(10,2)。 |
| `_deploy_probe.ps1` | 线上读 Web.config（密码脱敏）+ dump mth 结构。 |
| `_deploy_verify.ps1` | 部署后新旧 Web.config diff 校验。 |
| `_prod_precheck.ps1` / `_prod_apply.ps1` / `_prod_verify.ps1` | 线上灌手机端测试数据的前置检查 / 应用 / 验证（口令仅内存中取自 Web.config，不打印）。 |
| `_prod_run_sql.ps1` | 线上通用一次性 SQL 执行器。 |
| `_prod_gamescheck.ps1` / `_prod_postcheck.ps1` | 线上 games 表名称乱码排查 / 收尾检查。 |
| `_seed_phone_testdata.py` | 生成手机端联调种子数据 `Docs/sql/手机端测试数据.sql`（在仓库根运行）。 |
| `_check_db.ps1` / `_check_login.ps1` / `_check_session.ps1` / `_debug_curl.ps1` | 登录/会话/数据库排查（带 Sysnative 逃离）。 |
| `_repro2.ps1` / `_repro3.ps1` / `_repro4.ps1` | 历次问题复现脚本。 |
| `_add_csproj.py` | 把手机端新增文件登记进 `YYT.Web.csproj`（在仓库根运行）。 |
| `_fix_ready_init.py` | phone.*.js 的 jQuery ready 初始化改为直接执行。 |
| `_rename_diamond.py` | 手机端文案 钻石→金币 批量替换。 |
| `_rename_coin_to_diamond.py` | 后台全端文案 金币/币→钻 批量替换（保护 货币/造币）。 |

注意：`_check_db.ps1`、`_check_login.ps1` 内嵌了数据库口令，若此目录会对外分发，先清理这两个文件。
