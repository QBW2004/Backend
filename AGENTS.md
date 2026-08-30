# AGENTS.md — MTH-Backend（MTH 游戏平台运营后台）

> 供 AI 代理 / 新成员快速上手。最后核实时间：**2026-08-29**（含线上服务器实况调查，调查方式见文末）。

## 项目是什么

棋牌/捕鱼/拉霸类游戏平台的**运营后台**（管理员/代理用，不是玩家客户端）：
ASP.NET **MVC5 + .NET Framework 4.x（目标 4.8）**，EF6 + **MySQL 5.7**（库名 `mth`），
通过**命名管道**与游戏中心服 `ServerCenterNew.exe` 通信（踢人、机器人、热更推送等指令）。
功能域：玩家/代理管理、充退与流水、游戏桌台/机台配置、机器人、公告、封禁、风控等。

## 仓库地图

| 路径 | 说明 |
|---|---|
| `MTH_Mgr_MySQL.sln` | 解决方案（VS2022 / MSBuild 可构建） |
| `TTY.Web/` | **Web 主站**，项目文件是 `TTY.Web/YYT.Web.csproj`（⚠️ 目录叫 TTY.Web，项目名/程序集叫 YYT.Web） |
| `TTY.Web/Controllers/` | 根级：`LoginController`（桌面登录）、`MgrController`（后台框架页/主入口）、`Common`、`Validator`（验证码）、`Api/`（WebAPI：`/api/PayOrderNotify`、`/api/DPayOrderNotify` 支付回调等） |
| `TTY.Web/Areas/Game/` | 桌面后台业务接口（约 25 个 Controller：用户、代理、充值、游戏配置、机器人、公告…），JSON 接口为主 |
| `TTY.Web/Areas/Mobile/` | 手机端后台（分支 `Add-Phone-Support` 正在做的 1:1 复刻改造，见 `.zcode/plans/plan-sess_4fe235af-*.md`），`Views/Home/` 已有 11 页 |
| `YYT.BLL/` | 业务层。`EF/` 为 EF6 实体+操作类（`GameDbContext` 等），`Services/GameServer/` 为游戏服指令通道（见下文） |
| `YYT.Entity/` | 实体与枚举（`M_LoginUser`、`TipMsg`、`EServerData` 等） |
| `YYT.Common/` | `ConfigHelper`/`CacheHelper`/`WebHelper`（Session 登录态）等基础设施 |
| `YYT.DbUtility/` | 数据访问工具 |
| `YYT.Remote/` | `SConnect`：命名管道客户端（向中心服发 XML 消息，消息定义在 `TTY.Web/Config/MsgDefine.config`） |
| `Game.Utils/`、`UnitTestProj/` | 工具类、单元测试 |
| `Tools/` | 运维脚本，按用途分 5 个子目录：`server-env/`（服务器环境安装/检测）、`deploy/`（部署与打包）、`dev/`（本地构建/起站）、`db/`（本地数据库）、`one-off/`（一次性排查脚本）。逐个脚本说明见 `Tools/README.md` |
| `docker/` + `docker-compose.yml` | 本地 MySQL 5.7 容器（含初始化 SQL） |
| `Docs/` | 历次改造方案与进度文档（拉霸/押注/桌台配置等） |
| `Phone/` | 手机端改造参考物：`_reference/` 参考站 DOM 快照、`_accept/` 验收截图、`index.html`+`serve.js` 预览服务 |
| 根目录 `mth*.sql` | 数据库导出（`mth.sql` 结构 + 3 迁移补丁给 docker 初始化用；`mth_havedata.sql` 8.5MB 带数据） |

## 构建与本地开发

```bash
# 数据库：docker compose up -d        # mysql:5.7，容器名 mth-mysql，root/123456，库 mth
#            ⚠️ 必须带 --lower-case-table-names=1（compose 已配置），
#            否则 EF 大写表名映射（[Table("Users")] 等）全部报 Table doesn't exist
Tools\dev\build.bat             # Clean + Release MSBuild（自动补 .NET48 引用程序集/Web targets，无需 VS 全家桶）
Tools\dev\start.ps1             # IIS Express 起站（root apphost.config 缺失时用直连路径模式）
Tools\db\docker-db.bat          # 数据库容器 start/stop/status/reinit
Tools\server-env\env-check.ps1  # 部署环境检测+补装（服务器用）
```

- 连接串在 `TTY.Web/Web.config`：本地为 `Server=localhost;Port=3306;Database=mth;Uid=root;Pwd=123456`。
- ⚠️ **老式 csproj**：新增 .cs/.cshtml/.js/.css 必须手工登记进 `TTY.Web/YYT.Web.csproj`（可用 `Tools/one-off/_add_csproj.py`），否则编译产物缺文件。
- ⚠️ bin 里同时有 x86/x64 `SQLite.Interop.dll`；应用池必须 **64 位 v4.0 Integrated**，不要开 32 位兼容。
- 仓库根 `TTY.Web.rar` 是整站源码快照备份；`Tools/one-off/` 下的 `_check_*`、`_repro*`、`_prod_*` 等是历次排查的一次性脚本。

## 核心运行逻辑

**认证**：Session 存 `M_LoginUser`（`WebHelper.GetLoginInfo()`）。`MemberAuthorizeAttribute`（业务接口）/`MgrAuthorizeAttribute`（要求 RoleId=1 超管）拦截：
POST 未登录 → HTTP 200 返回 `TipMsg.MSG_LOGIN_TIMEOUT`（前端约定 `code==-1` 跳登录页）；GET 未登录 → 桌面跳 `~/Login/Index`，**Mobile 区域跳 `~/Login/Mobile`**。角色/权限位（IsSuper/CanCreateAgent/CanUpDown/CanFrozen…）经 `window.MConfig` 注入前端控制显隐。
超管（`atmadmin`）与所有代理一律走 `admin` 表校验（明文密码比对 + `RE_ENABLE=1`）。2026-08-29 已移除"账号名等于 Web.config `admin` 键（admin1）即免密码登录超管"的后门分支；`admin` 键残留的唯一用途是总控指令里 `UserName=="admin1"` 时置 set=1（移除后恒为 0，与 atmadmin 历史行为一致）。

**手机端适配**：`BaseController` 用 UA 正则识别手机浏览器（平板按 PC），选择记在 Cookie `mth_view`（30 天）；`/Mgr/Index` 命中手机 UA 自动跳 `/Mobile/Home/Index`，可用 `?view=pc|mobile` 强制切换。

**与游戏中心服通信**：`YYT.Remote.SConnect` 连命名管道 `\\.\pipe\mynamedpipe`（配置键 `serverName`/`pipeName`，机器人走 `robotPipeName`=`MTH_RobotPipe`），发 `Config/MsgDefine.config` 定义的 XML 指令。BLL 侧封装为 `GameCommandService` + `gamecommandoutbox` 发件箱表，`PipeGameServerClient` 实际发管道，失败可由重试服务补偿。

**定时任务**（`Global.asax` `Application_Start`，间隔=appSettings `Timer`=60s）：
`B_UserLockRecord.TimerTaskRun`（锁定记录迁移）+ `GameCommandOutboxRetryService.ProcessDueCommands`（指令重试）+ `B_LoginMissRecord.ResetLoginMissRecord`（登录失败计数解封）+ `B_Records_MySQL.CleanupExpiredRecordsThrottled`（6 张日志表 7 天滚动清理，进程内节流每小时最多一次）。单飞锁防重入。
注意：清理只允许走定时任务，任何列表/指令接口**不得**内联调用 `CleanupExpiredRecords`（6 条 DELETE 会把读接口变成全表扫描+写锁）。

**JSON 约定**：表格接口返回 `{ total, rows }`（`BaseController.GridJson`）；操作接口返回 `{ code, msg }`；全部 GET-可 Json 化、AJAX POST 为主。

**数据库**：库 `mth` 约 58 表。核心：`users`(玩家)、`admin`(后台账号)、`agencyoptlog`/`manageropt`(操作日志)、`rechargerecords`(充退)、`agent_hierarchy`/`agent_permission_template`/`invite_codes`(代理体系)、`games`/`gamemo`/`gamepara`/`paragame`/`pararoom`/`roomtableconfig*`(游戏与桌台配置，按游戏类型分表)、`robot_seat`/`userrobot*`(机器人)、`userlockrecord`/`loginmissrecord`(风控锁定)、`user_daily_winloss`、`gamecommandoutbox`(指令发件箱)。表名在 EF 里映射为大写，运行环境必须 `lower_case_table_names=1`。

**日志**：log4net → `~/Logs/yyt_yyyyMMdd.log`（会滚动出 `.1` 后缀）。

## 部署流程（线上）

1. 本地 `Tools\dev\build.bat` 编译（`Tools\deploy\pack.ps1 -Version x.x.x` 打包），把**整个 TTY.Web 目录**（源码+bin+Views+Web.config）打成 zip 上传服务器（不走 VS 发布精简流程——这是既有习惯）。
2. 服务器上管理员运行：`powershell -ExecutionPolicy Bypass -File deploy.ps1 -SourcePath C:\...\TTY.Web.zip [-Yes]`
   自动：备份旧版到 `C:\Backend_backup_<时间戳>` → robocopy /MIR 到 `C:\Backend`（保留 `App_Data`/`Logs`/`Upload`）→ 校验应用池 v4.0/64 位 → 站点绑 8081 → 放行防火墙 → 回收应用池 → HTTP 探测。
3. `server_deploy_check.ps1` 可一键收集服务器部署情况（注意：SSH 远程执行时它是 32 位 PowerShell，IIS 检测会拿空结果，见"坑"节）。
4. 首次搭环境用 `env-check.ps1`（补 .NET 4.8 / VC++ 运行库 / IIS / MySQL 5.7）；Server 2012 R2 缺 UCRT 用 `fix-legacy-ucrt.ps1`。中心服 `ServerCenterNew.exe` **不在本仓库**，需单独部署。

## 线上服务器实况（134.122.203.112）

连接（PowerShell）：
```powershell
ssh -i "$HOME\.ssh\mht-server-ed25519" -o IdentitiesOnly=yes administrator@134.122.203.112
```
（Git Bash 把密钥路径写成 `~/.ssh/mht-server-ed25519`；sshd 是 32 位 OpenSSH 装在 `Program Files (x86)`）

| 项 | 现状（2026-08-29 调查） |
|---|---|
| 系统 | Windows Server 2012 R2（6.3.9600），12 核 / 24GB，时区 UTC+8，上次开机 2026-08-26 |
| 磁盘 | 仅 C:（338/360 GB 空闲）。**没有 D 盘** |
| IIS | `Default Web Site` → `C:\Backend`，绑定 `*:80` + `*:8081`，应用池 DefaultAppPool（v4.0 / 64 位），运行正常，本机探测 HTTP 200 |
| 公网 | 80 / 8081 均可达（返回 302 跳登录页） |
| 部署版本 | **WebVer = 1.0.20**（2026-08-31 部署，手机端改版：控制/玩家详情页、移除拉黑与送江、登录禁用提示，备份 `C:\Backend_backup_20260831_011351`）；此前 1.0.18（备份 `C:\Backend_backup_20260830_112202`）。性能索引补丁（`Docs/sql/性能索引.sql`）已在线上 MySQL57 的 mth 库执行；`Docs/sql/线上games名称修正.sql` 已应用（games.Name 已为正常 UTF-8 中文）；`usercontrolstatus`/`usercontrolvalue` 表线上已存在 |
| MySQL | 5.7.44，服务名 `MySQL57`，`C:\mysql\bin\mysqld.exe --defaults-file=C:\mysql\my.ini`，库 mth，`lower_case_table_names=1`，users≈124 行 / admin≈7 行（数据量很小） |
| 端口监听 | 80、8081（HTTP.sys）、3306、3389(RDP) |
| 中心服 | **本机没有**：找不到 `ServerCenterNew.exe`（扫到两层深度）、无 `mynamedpipe`/`MTH_RobotPipe` 命名管道、无 8020/8021/9000 监听 |
| 其他 | 防火墙三档全启用；装有 Chrome（有人 RDP 使用）；无相关计划任务 |

### 线上风险/待办（调查发现，未做任何修改）

1. **MySQL 3306 公网可直接连通**（本机外测通）。连接串账号是 root，仅靠密码防护。建议改为仅监听 127.0.0.1 或防火墙收紧 3306 来源。
2. **游戏控制类功能在这台机器上不可用**：无中心服、无管道（Web.config `serverName="."` 指本机）。踢人/机器人/热更推送等管道指令会失败；中心服要么部署在别的机器（需把 `serverName` 改成对方主机名并打通管道权限），要么尚未迁移。
3. **`UploadPath=D:\Uploads` 但服务器没有 D 盘** → 涉及图片/文件上传的功能会失败。改为存在的目录（如 `C:\Uploads`）并放好权限。
4. **支付回调仍指旧服**：`PayOrderNotify`/`DPayOrderNotify` = `http://175.178.196.75:8081/api/...`（Web.config 里连同第三方支付参数都是旧值）。切流量前必须确认回调地址与公网 IP（134.122.203.112）一致。
5. **分支尚未合并**：手机端适配（`Add-Phone-Support`）代码已随 1.0.20 部署到线上，但分支本身尚未合并回 `master`。
6. 日志每 60s 刷 `Legacy UserLockRecord cannot be migrated because coin amount was not found {...}`——定时任务对旧锁定记录的无害告警，量大需清理/降级。
7. `Config/MsgDefine.config`、Web.config 含生产密钥（支付 shop_key、api token、DB 密码）。**不要**把它们写进文档/日志/对外输出。

## 日常工作须知（坑清单）

- 目录名 `TTY.Web` ≠ 项目名 `YYT.Web`；部署目标目录固定 `C:\Backend`。
- 新增文件必须登记 csproj（老式项目，无 SDK 通配）。
- **新增 .cshtml 必须是 UTF-8 with BOM**：Web.config 已设 `<globalization fileEncoding="utf-8"/>`，但历史上无 BOM 的视图（手机端 13 个页面曾中招）在中文 Windows 服务器上会被运行时按 GBK 解码导致整页乱码。怀疑乱码先查文件头三字节是不是 `EF BB BF`。
- MySQL 必须 `lower_case_table_names=1`；本地容器已配置，Windows 本机 MySQL 天然满足，Linux 上会炸。
- 应用池必须 64 位（x64 SQLite.Interop）。
- **SSH 远程执行 PowerShell 时是 32 位进程**：`Import-Module WebAdministration` 后 `Get-Website` 返回空、`Get-Process` 拿不到 64 位进程路径。要用 `C:\Windows\Sysnative\WindowsPowerShell\v1.0\powershell.exe` 起真正的 64 位会话。长脚本用 `scp` 传 `-File` 执行（cmd 有 8191 字符限制，`-EncodedCommand` 太长会报"命令行太长"）。
- `deploy.ps1` 已内置 WOW64 逃离（Sysnative），直接在服务器本地跑没问题。
- 分支现状（2026-08-29）：`Add-Phone-Support` 上有大量未提交改动（手机端 12 页改造 + AbnormalController + phone.css/js + MobileOnlyAttribute 等），工作区不要随意 checkout/reset。
- 数据库结构变更参考根目录 `mth.sql` + `docker/mysql/init/` 迁移补丁的顺序加载机制。
- 读接口禁止全量 `ToList()` 后内存分页/排序/求和——玩家与记录类查询一律 SQL 下推（参考 `B_Users.QueryUsersPaged` / `B_ReChargeRecords.GetReChargeRecordsForPhone`，见 `Docs/手机端性能优化-20260829.md`）。`/Game`、`/Mobile` 已改只读会话，往这两个区域加写 Session 的代码需先确认（当前仅 `Game/UserInfo/Register` 例外可写）。
- **线上部署前先在 MySQL57 对 mth 库执行 `Docs/sql/性能索引.sql`**（幂等；核心表二级索引 + user_daily_winloss.UserID 字符集对齐，未执行则新查询走不了索引）。

## 调查方式（可复现）

2026-08-29 通过上述 SSH 只读采集：系统/磁盘/WMI 硬件信息、WebAdministration 站点与应用池、进程路径、netstat 监听端口、`C:\Backend` bin 时间戳与 Web.config 关键项（密码已脱敏）、MySQL 服务与 `SELECT VERSION()/SHOW TABLES/行数`、命名管道枚举、防火墙状态、部署备份目录、最近日志尾部；另从本机外网探测 80/8081（HTTP 302）与 3306（TCP 可达）。未在服务器上做任何写操作（临时脚本已删除）。
