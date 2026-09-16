# AGENTS.md — MTH-Backend（MTH 游戏平台运营后台）

> 供 AI 代理 / 新成员快速上手。最后核实时间：**2026-09-17**（线上 `C:\Backend` 与仓库工作区 **1528 个文件 MD5 逐字节一致**（`Tools/one-off/_cmp_tree.ps1`），WebVer **1.0.45** 正在线上运行；1.0.42–1.0.45 四轮改动已于本日一次性提交入库。线上已迁移到新服务器 `8.218.67.82`；App 前台、App 游戏连接、后台域名三条链路均已打通验证；线上部署 **1.0.45** = 运营反馈 9 项问题的修复轮，逐条结论见 `Docs/手机端后台需求规划-20260902/tasks.md` 第 20 节。后台→中心服管道自 08-27 起不通的问题已于 09-16 用「应用池身份改 LocalSystem」修复并复验，见「已知未闭合项」8）。

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
| `TTY.Web/Areas/Mobile/` | 手机端后台（分支 `Add-Phone-Support` 正在做的 1:1 复刻改造，见 `.zcode/plans/plan-sess_4fe235af-*.md`），`Views/Home/` 已有 14 页 |
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

**手机端弹窗的滚动锁**（2026-09-13 起，见 `phone.core.js` 的 `lockPageScroll`/`unlockPageScroll`）：部分老安卓内核给 `position: fixed` 弹窗做触摸命中测试时按"文档坐标"算，命中区不随页面滚动更新 —— 页面滚到中下部后再打开弹窗，弹窗看着正常但**点确定/取消毫无反应**，必须把页面滚回顶部才点得中（充值、控制两页最先暴露）。因此 `M.modal` 打开期间会把 `body` 固定住（负 `top` 保留视觉位置）并把文档滚动量归零，关闭时还原滚动位置；弹窗会叠加（确认 → 结果提示），用计数配对加解锁。`.modal-overlay` 另加了独立合成层与 `overflow-y: auto`（超长弹窗可从头滚到底）。改弹窗样式/结构时别把这两条约束去掉，防回退断言见 `ViewContractTest.MobileModalLocksPageScrollSoDialogButtonsStayTappable`。

**手机端「代理流水」只出资金变动**（2026-09-13 起）：`AgencyOptLog` 里除充值/兑换/赠送/扣币（`OPT` 0/1/20/21/22/23）外，还有登录/退出（2/3）与封禁审计（24-27）等**没有金额**的记录，它们的「币 / 剩余币」只能显示 `--`。手机端「代理流水」页传 `MONEY_ONLY=1`（`M_S_Record.MONEY_ONLY` → `B_Records_MySQL.Get_AgencyRecords` 里白名单 `OPT IN`），这类记录整条不展示，且过滤必须在服务端做（否则 `total` 与分页对不上）。桌面「代理记录」要展示登录/退出明细，**不传该参数**、口径不变。

**封禁/冻结记录的可见口径**（2026-09-13 起，见 `AgencyRules.CanAccessBanRecord`）：代理封禁（`admin.RE_ENABLE=0`）与玩家冻结（`users.FROZEN=1`）的记录，**只有记录的操作人本人、特级代理（`PRIV=1`，限自己整条线内）、总台（`PRIV=0`）能查看和解除**；中间任何层级（含操作人的直接上级、被封账号的直接上级）都看不到。操作人取 `AgencyOptLog` 中该账号最近一条封禁类操作的 `OptID`（代理 `OPT=24`、玩家 `OPT=26`）；该表只留 7 天，超期后查不到操作人的记录只有特级/总台可见可解除。封禁/冻结**动作本身**仍按管理范围（`CanManageAgent`/`CanManagePlayer`，`ManageScope` 1 直属 / 2 整线），改的只是可见与解除。桌面端启用/禁用走 `B_Admin.SetAgentEnabledWithAudit`（写审计日志），不要再走无审计的 `SetRecharge`。

**「我的代理」按节点浏览**（2026-09-13 起，见 `phone.agents.js` 的 `OWN_ACCOUNT`）：根节点 = 登录账号自己，每个节点只列**该节点的直属代理**，行内"下级代理 N 个"是该代理真实的直属下级数（基数是权限范围内的全量代理），点它下钻一层，面包屑可回退。**权限范围没有任何变化** —— 仍是 `admin.ManageScope` 语义（1 仅直属 / 2 全部下级；线上所有代理都是 2 = 整条代理线），总台为全部；账号/邀请码搜索仍在整个权限范围内查，桌面端代理管理也仍是整条线的平铺列表。
> 插曲：1.0.39 / 1.0.40 一度把代理侧范围收紧成"非特级仅直属下级"（`AgencyRules.IsWholeLineAgencyScope`），1.0.41 起已全部回退（该函数已删除）。要收紧某个账号的范围请改 `admin.ManageScope`，不要改 `GetManagedAgencyAccounts`。

**控牌牌型口径**（2026-09-13 起，1.0.42/1.0.43 已上线）：控牌下拉的选项**是硬编码**（数据库 `cardpayoutprofile` 只存每桌出现概率，不生成选项），手机端在 `phone.core.js`、电脑端在 `Areas/Game/Views/UserInfo/Index.cshtml` 与 `OnlineUsers.cshtml` 各存一份，**改一处必须同步另一处**（`ViewContractTest.CardControlOptionsHideZeroPairAndJackpotsOverTwoThousand` 会卡）。牌机（5/7/12/13/14）统一隐藏杂牌(0)/五鬼(12)，大四梅(8) 仅火凤凰(14) 保留；拉霸按结果类 code 下发（水浒传 400-407/410-417/420-427/430-432/444-448/450/451、明星97 300-350、水果拉霸 24 面板位，其中面板位 9/21 是两个不同送灯位，按机台设定同名文案写「送灯位·免费局 1~3 次」/「送灯位·免费局 3~6 次」），文案统一为「名称(倍数)」。倍率超过 2000 倍的项不下发：水浒全屏类按**全屏奖+线奖（9 线）叠加**的总赔率计，440(14000)/441(11500)/442(4600)/443(2300) 已去掉，只到全屏·林冲 1840 倍。旧控牌值（牌机 0/8/12、水浒 0-7、明星97 0-8）不在下拉里但仍能回显（`M.cardTypeName` 回退 / 电脑端 `labaTypeName`）。

**手机端「控制牌型」是向上展开的浮层，不是原生下拉**（2026-09-14 起，见 `phone.core.js` 的 `M.upwardSelect`）：控制页的「控制牌型」在页面最底部，原生 `<select>` 的弹出列表只能向下、会被屏幕底部裁掉（牌机 11 项 / 水浒传 35 项，后面的牌型点不到；桌面浏览器模拟器里也一样，原生弹出框不参与页面渲染、滚不动）。所以换成「按钮 + 页面内浮层」：默认向上展开、上方不足 160px 且下方更宽敞才向下、高度取 min(可用空间, 60vh) 且不超视口、长列表内部滚动、当前项高亮并自动滚到可见处。**原生 select 仍留在 DOM 里作为取值与 `change` 的唯一来源**（`display:none`，`.val()`/`.trigger('change')` 照旧），改 `fillSelect` 重建选项后必须调 `M.upwardSelectRefresh` 同步按钮文案（已内联在 `fillSelect` 末尾）。目前只用于「控制牌型」。

**这几条口径是 2026-09-16 那轮修复定下的，改动前先读**（问题清单与证据见 `Docs/手机端后台需求规划-20260902/tasks.md` 第 20 节）：

- **「总输赢/总盈亏」= 实际游戏输赢** = `SUM(user_daily_winloss)`（赢正输负）。手机端在线卡片、离线卡片、会员盈亏、玩家详情、电脑端「总盈亏」都是这个口径。**不要**改成游戏服 QA 的 `TotalWinLoss`（那是本局/本次在线口径，同一玩家在线/离线会显示两个数），也**不要**改成「充值-退币差额」（那是资金口径）。离线列表的 Profit 由 `GetOfflineUsersList` 走 `gameWinLossProfit=true` 给出，控制器不得再用差额覆盖。
- **押注（当前压分）0.1 分炮鱼机要 ÷10**：GameId `3/6/13/19/21/22/32/33/42/49/51` 的内部单位是 0.1 分。电脑端 `isDecimalBetFish`（`UserInfo/OnlineUsers.cshtml`、`GameConfigController`）、手机端 `M.betGold/M.isDecimalBetFish`（`phone.core.js`）三处同一份列表，**改一处必须同步**（`ViewContractTest.MobilePlayerCardShowsRealWinLossDecimalBetAndOneBasedPosition` 会卡）。场次/机台号/座号同理：服务端下发 0 基下标，端上 +1 显示。
- **控制进度 `ConsumedCoins` 原样显示**（净口径，可为负）：手机端三处曾经取反，把「已吃分 2608」显示成「-2608」，已全部改回与电脑端一致。
- **会员盈亏只算玩家**：`rechargerecords.GameID` 命中 `admin.ID` 的是给代理充的，统计卡与列表充退列都必须 `NOT EXISTS` 排除；代理维度的盈亏聚合必须 `INNER JOIN Users u ON u.ID = w.UserID`（`user_daily_winloss.UserID` 存账号串）——连 `userrelations`（UserID 是数字平台 ID）会恒不匹配、聚合恒 0。
- **充退/控制指令一律直发管道**：`B_Recharge` 的 LK/UL 与 `B_UserControl` 的 UC 不再按端分叉成"手机端只入发件箱排队"（定时器 60s 一轮，会让充退/应用控制最长等一分钟才生效）。失败仍由 `gamecommandoutbox` + 重试服务兜底。
- **EF 查询里禁止 `Select(c => new M_实体{...})`**：EF6 会抛 `NotSupportedException`，而且只在列表里存在在线玩家时才触发、还会被 controller 的 catch 吞成空列表（`FillCurrentPlayInfo` 就是这么让"用户管理里的用户一会有一会没有"的）。要投影就投影匿名类型，实体对象留到 `.ToList()` 之后在内存里组装。
- **代理密码可见性**：超管可见；其余账号要 `admin.IsViewAgentPwd=1` 且目标在自己管理范围内。判定点只有 `AgencyInfoController.GetAgencies` 的按权限脱敏一处（历史 bug 是在它之前先无条件清空，导致谁都看不到）。

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
   自动：备份旧版到 `C:\Backend_backup_<时间戳>` → robocopy /MIR 到 `C:\Backend`（保留 `App_Data`/`Logs`/`Upload`）→ 校验应用池 v4.0/64 位 → 站点绑目标端口 → 放行防火墙 → 回收应用池 → HTTP 探测。
   ⚠️ 脚本默认 `-Port 8081`（历史值）；**新机 8080 才是对 App/nginx 的业务口**，需要时显式传 `-Port 8080`（脚本只新增绑定、不动已有绑定，所以两个端口会同时可用）。
3. `server_deploy_check.ps1` 可一键收集服务器部署情况（注意：SSH 远程执行时它是 32 位 PowerShell，IIS 检测会拿空结果，见"坑"节）。
4. 首次搭环境用 `env-check.ps1`（补 .NET 4.8 / VC++ 运行库 / IIS / MySQL 5.7）；Server 2012 R2 缺 UCRT 用 `fix-legacy-ucrt.ps1`。中心服 `ServerCenterNew.exe` **不在本仓库**，需单独部署（新机游戏服与本后台**同机**，见"线上服务器实况"）。

## 线上服务器实况（8.218.67.82 — 2026-09-11 迁移，9-13 复核）

> 2026-09-11 线上整体换了服务器：**旧的 `134.122.203.102`（游戏服，已失联）与 `134.122.203.112`（后台/后作全栈）全部由新机 `8.218.67.82` 取代**。本节是迁移当天的实机核实结果。历史调查（.112）已归档在本节末尾。

连接：

```powershell
ssh administrator@8.218.67.82      # 密码方式（服务器还有 RDP 3389）
ssh mth-server                     # 免密：本机 ~/.ssh/mht-server-ed25519 已装到服务器（2026-09-13）
```

| 项 | 现状（2026-09-13 实机核实） |
|---|---|
| 系统 | Windows Server 2019 Datacenter（10.0.17763），阿里云 ECS（`iZadhbme469z51Z`），8 核 / 16GB，仅 C 盘（可用 232GB） |
| 站点 | IIS `Default Web Site` → **`C:\Backend`**，绑定 `http/*:80:` + `*:8080:` + `*:8081:`，应用池 DefaultAppPool（v4.0 / 64 位），运行正常 |
| 部署版本 | **WebVer = 1.0.45**（2026-09-16 部署，备份 `C:\Backend_backup_20260916_235236`；8 个文件 MD5 与仓库源码/构建产物逐字节一致：`Web.config`/`bin/YYT.Web.dll`/`bin/YYT.BLL.dll`/`Scripts/app/phone/phone.core.js`/`phone.players.js`/`phone.control.js`/`phone.playerdetail.js`/`phone.huiyuan.js`；CDN `?v=1.0.45` 三份手机端资源 MD5 一致且含 `M.betGold`；80/8081/`abc.12.sqrdwj.top` 200，`x.52.dyj.wang` 302）。1.0.45 = 运营反馈 9 项问题的修复（详见 tasks.md 第 20 节）；1.0.44 = 手机端「控制牌型」改向上展开（备份 `C:\Backend_backup_20260914_031033`）；1.0.42 = 控牌牌型口径（`C:\Backend_backup_20260913_223905`）。**2026-09-17 再复核**：线上 `C:\Backend` 与仓库工作区逐文件 MD5 全一致（1528 个文件；线上仅多一个迁移留档 `Web.config.orig_before_migration`） |
| MySQL | 5.7.44，服务 `MySQL57`，`C:\mysql`，库 `mth`（**58 表，与旧服一致**：users 191 / admin 31 / games 21 / rechargercounts 37 / roomtableconfig 95 / cardpayoutprofile 806 / userscoresnapshotledger 97494），`lower_case_table_names=1`，`utf8mb4/utf8mb4_unicode_ci` |
| 数据来源 | 本次从 `.112` 用 `mysqldump --single-transaction --hex-blob --routines --triggers` 全量导出（8.2MB，`C:\Users\Administrator\mth_migrate.sql` 留档）。旧服 `Web.config`、`Config\*`、`Upload\`(13 文件)、`servers.ini` 一并迁移 |
| 网络入口 | **App 前台**：`https://x.52.dyj.wang` → DNS A `94.103.6.39`（Ubuntu 22.04 + Nginx 1.18 中转，只开 22/80/443，Let's Encrypt 证书至 2026-12-10 自动续期，`/proxy-health` 返回 `nginx ok`，证书校验通过）→ 反代 `http://8.218.67.82:8080`。**后台**：`abc.12.sqrdwj.top` → 阿里云 ESA CDN → 回源 `http://8.218.67.82:80`（**必须用 80，不能用 8080/443**），已修复并验证：`/zh-CN/Login/Index` → 200 后台登录页。**App HTTP 接口**：`http://8.218.67.82:8081`（充值/客服/活动等，App 直连） |
| 防火墙 | 自定义入站规则：`MTH-Backend HTTP 80`(Any)、`Allow Nginx Proxy 8080`(**仅 94.103.6.39**)、`MTH-Backend HTTP 8081`(Any)、`MTH-GameServer TCP 9000/9100/9102/9103/9109/9200/9203/9204/9208/9209/9300/9302/9305/9307/9309/9315/9316/9321/9400/9402/9403`(Any，游戏服客户端直连用) |
| 同机游戏服 | 本仓库产物也在这台：`C:\Server\`（中心服 + 21 子游戏 + `ServerManager`），后台发指令走的命名管道 `\\.\pipe\mynamedpipe` 由中心服创建（`Web.config serverName="."` 指本机，`pipeName=mynamedpipe`）。⚠️ **管道虽在，但自 2026-08-27 起一直连不上、指令发不出去**，见「已知未闭合项」8 |
| 环境 | .NET Framework 4.8 (528049) 已装；VC++ 2015-2022 x64 (14.44.35211) 已装；7-Zip 已装；OS 语言中文（控制台 936） |
| 与 .112 的差异 | `UploadPath` 由 `D:\Uploads` 改为 **`C:\Backend\Upload`**（新机无 D 盘），并把旧服 Upload 里 13 个文件拷了过来 |

### 已知未闭合项（2026-09-13 复核）

> 面向运维/运营的**易读版待办文档**见游戏服仓库 `MTH-Server/docs/线上迁移待办-2026-09-11.md`（现象/原因/修法/验证四段式，含各控制台入口）。

1. **支付回调仍是旧服地址**（⚠️ 最要紧，涉及充值到账）：`PayOrderNotify`/`DPayOrderNotify` = `http://175.178.196.75:8081/api/...`（该机已无响应，**会导致充值不到账**）；`WebHost=http://www.dyj.wang`、`Andriod_Url/PC_Url=www.scuyco.top:8080/Upload/yhyl.apk`（**该下载地址当前访问不通**）、`RecordDbPath=C:\Users\Administrator\Proj\`（目录不存在）等历史值也需按新架构确认后再改，**别盲改支付参数**（第三方商户后台可能也要同步登记新回调）。
2. **客户端服务器域名 `bbs.1.mmssxxa.xin` 仍无 A 记录**：解析链 `bbs.1.mmssxxa.xin` → CNAME `bbs.1.mmssxxa.xin.a3.initzz.com` → 无 A（权威 NS `eiger/swan.ns.edgegslb.com`）。若线上 APK 已带该域名则玩家无法连服；需把 A 记录指向 `8.218.67.82`（直连，**不要套 CDN 代理——CDN 不转发游戏 TCP 端口**）或重发包。
3. **【已修复】后台域名 `abc.12.sqrdwj.top` 已回源成功**：CDN（阿里云 ESA）回源配置改为 **协议 HTTP + 端口 80**（源站 `8.218.67.82`）后，`https://abc.12.sqrdwj.top/zh-CN/Login/Index` → **200**（后台登录页 5412 字节），`/` → 302 跳登录页；源站 IIS 日志可见 CDN 边缘节点（`163.181.x.x`）从 80 端口取到全部页面与静态资源。**踩坑记录**：回源**不能用 8080**（该端口防火墙只放行 nginx `94.103.6.39`，CDN 节点会被丢包 —— 实测 `DROP TCP 163.181.x.x → 8080`，正是 522 的成因），也**不能用 443**（源站 IIS 只监听 80/8080/8081）。
4. **【已修复】游戏服客户端直连端口已放通**：从独立机器（旧服 `.112`）实测 `8.218.67.82` 的 21 个游戏端口全部可连（9000、9100/9102/9103/9109、9200/9203/9204/9208/9209、9300/9302/9305/9307/9309/9315/9316/9321、9400/9402/9403）+ 8081 + 80；`8080`/`3306` 仍正确对外关闭。
5. **【已修复】`x.52.dyj.wang` HTTPS 已恢复**：DNS 已改回直连 `94.103.6.39`，证书校验通过（Let's Encrypt，至 2026-12-10 自动续期），`/proxy-health` → `nginx ok`、登录页 → 200。
6. **旧机 `.112` 仍在运行**（游戏服 + 后台 + MySQL 全部照旧，数据仍在写入），未做任何停用操作；`.102` 已完全失联（SSH/HTTP 全不通）。确认新机稳定后再决定旧机下线时机。
7. 部署脚本已同步到新机：`C:\Users\Administrator\Desktop\deploy\`（`deploy.ps1`/`deploy.bat`/`pack.ps1`）与 `server-env\`（`env-check.ps1` 等）——与仓库 `Tools\` 同款。新机 `env-check-report.txt` 里 .NET 4.8 的 FAIL 是 8/30 的旧报告，实际 9/11 复查已满足。
8. **【已修复】后台→中心服管道自 2026-08-27 起不通**（2026-09-13 部署 1.0.40 时发现，**与后台代码无关**）：`gamecommandoutbox` 最后一条成功（`Status=2 Acked`）曾是 **08-26 11:26**，此后 LK/UL/UC/KU（封禁下发/解封/控牌/踢人）全部失败，错误为「数据发送失败！无法连接中心服管道（管道尚未连接）。」与「游戏服管道熔断冷却中」。**2026-09-16 修复**：把 IIS 应用池 `DefaultAppPool` 身份改为 **LocalSystem**（`appcmd set apppool /apppool.name:DefaultAppPool /processModel.identityType:LocalSystem` + 回收）后管道即通，`UL` 指令被中心服 `ComSendToGame` 正常处理（中心服日志 `Rec:UL ... UserId test01 success 1 ChangeCoins 1`）；恢复手段可参考 `Tools/one-off/_fix_pipe_access.ps1`（一次性排查脚本）。历史观察（备查）：`\\.\pipe\mynamedpipe` 一直存在于命名管道命名空间（`MTH_ServerPipe` 也在；`MTH_RobotPipe` 不存在 = `ServerRobot` 未启动，与 `servers.ini` 的 `ServerRobot=false` 一致），失败走的是"连接超时"路径而非管道名/权限错，中心服日志里那次「WEB管道通信开始」后紧跟 `ERROR_BROKEN_PIPE` 即断在那里。**验证管道是否真的通，只看 `gamecommandoutbox` 里 `Status=2`；不要去连管道试探或重启中心服（重启会踢掉全部在线玩家）**。
9. **⚠️ 中奖历史页会是空的，直到中心服写入 `gameprizerecord`**（2026-09-16 复核）：`gameprizerecord` 表**线上 0 行**，9/11 从旧服迁移的 `mth_migrate.sql` 里也没有任何该表的 INSERT —— 中心服从未实现这张表的写入（数据契约与写入格式见 `Docs/手机端中奖历史数据契约-20260901.md`，表结构与索引已由 `Docs/sql/手机端后台权限与记录保留-20260902.sql` 在线上建好）。后台侧 `/Game/UserRecord/GetPrizeHistory` 与手机端页面口径正确、无需改动；玩家照常游戏（`useroptlog` 有实时记录）但该表始终为空。**修法**：在中心服结算分支按契约写 `gameprizerecord`（属游戏服仓库）。
10. **线上 `Web.config` 的 `UploadPath=D:\Uploads` 在新机（只有 C 盘）不存在**：上传类功能（活动/公告图片等）会失败。仓库与线上该值一致（历史沿用），新机迁移时曾改过又被后续整包部署覆盖回去；确认目标目录后改成 `C:\Backend\Upload` 并同步仓库，再重新部署（本轮未动，避免改变现状）。

### 迁移当天（2026-09-11）实际执行的步骤

1. 旧服 `.112` 只读采集 + 导出：`mysqldump mth` → 下载；`Web.config`/`Config\*`/`Upload\`/`C:\Server\servers.ini` → 下载。
2. 本地 `TTY.Web` 打 zip（排除 Logs/obj/.db/pdb，24.2MB）→ 上传 `C:\Users\Administrator\backend.zip`。
3. 服务器上解压 → `robocopy /E` 到 `C:\Backend`（保留 `App_Data`/`Logs`/`Upload`）→ `UploadPath` 改 `C:\Backend\Upload`（原文件备份为 `Web.config.orig_before_migration`）。
4. IIS：站点物理路径指 `C:\Backend`，应用池设 v4.0/64 位，新增 8080、8081 绑定，回收应用池。
5. `mysql mth < mth_migrate.sql`（58 表，行数与旧服一致）。
6. 防火墙：新增/调整 80、8081、8080（后者只放行 nginx `94.103.6.39`）与全部游戏端口。
7. 验证：本机 `http://127.0.0.1:8080/zh-CN/Login/Index` → 200；外网 `https://x.52.dyj.wang/...` → 200（经 nginx）；`C:\Backend\Logs\yyt_20260911.log` 有正常业务日志。
8. 遗留：`C:\Users\Administrator\` 下保留 `backend.zip`、`upload.zip`、`mth_migrate.sql` 与各步骤 `.log` 作为回滚资料。

### 历史实况（旧机 134.122.203.112，2026-08-29 / 09-10 —— 已停用）

Windows Server 2012 R2，IIS `Default Web Site` → `C:\Backend` 绑 `*:80` + `*:8081`，MySQL 5.7.44（`MySQL57`，`C:\mysql`，库 mth，users 191 / admin 31），WebVer 1.0.36，部署备份目录 `C:\Backend_backup_<时间戳>`（自 8/26 起共 31 次）。**该机后期实为"全栈机"**：除后台外还跑着中心服 `ServerCenterNew` + 20 个子游戏（`C:\Server`，`MTH_Daemon` 计划任务，监听 9000 与 91xx-94xx）+ `mynamedpipe` 命名管道；3306 曾被公网探测可达。原始 `.112` 的 `Web.config serverName="."` 与本机部署是自洽的。

## 日常工作须知（坑清单）

- 目录名 `TTY.Web` ≠ 项目名 `YYT.Web`；部署目标目录固定 `C:\Backend`。
- 新增文件必须登记 csproj（老式项目，无 SDK 通配）。
- **新增 .cshtml 必须是 UTF-8 with BOM**：Web.config 已设 `<globalization fileEncoding="utf-8"/>`，但历史上无 BOM 的视图（手机端 13 个页面曾中招）在中文 Windows 服务器上会被运行时按 GBK 解码导致整页乱码。怀疑乱码先查文件头三字节是不是 `EF BB BF`。
- **想校验 .cshtml 改动能不能编译，别只看 HTTP 200**：视图是首次访问才编译，未登录页面根本走不到。可在服务器用 `C:\Windows\Microsoft.NET\Framework64\v4.0.30319\aspnet_compiler.exe -v / -p <站点目录> -f <输出目录>` 全站预编译。注意既存遗留 `Views/Shared/PartialPage/_PartialYearMonthSelPage.cshtml` 引用了本仓库不存在的 `FengBo.BLL`（该 partial 全仓无人引用、运行时不渲染），直接对 `C:\Backend` 编译会报 CS0246；确认本次改动时把站点复制一份、删掉 `Views\Shared\PartialPage\` 再编译即可（只读副本，别动线上目录）。
- MySQL 必须 `lower_case_table_names=1`；本地容器已配置，Windows 本机 MySQL 天然满足，Linux 上会炸。
- 应用池必须 64 位（x64 SQLite.Interop）。
- **SSH 远程执行 PowerShell 时是 32 位进程**：`Import-Module WebAdministration` 后 `Get-Website` 返回空、`Get-Process` 拿不到 64 位进程路径。要用 `C:\Windows\Sysnative\WindowsPowerShell\v1.0\powershell.exe` 起真正的 64 位会话。长脚本用 `scp` 传 `-File` 执行（cmd 有 8191 字符限制，`-EncodedCommand` 太长会报"命令行太长"）。
- `deploy.ps1` 已内置 WOW64 逃离（Sysnative），直接在服务器本地跑没问题。
- 分支现状（2026-09-17）：`Add-Phone-Support` 上 1.0.37–1.0.45 各轮改动均已部署上线**并已提交入库**（1.0.45 = 运营反馈 9 项问题的修复，逐条结论见 `Docs/手机端后台需求规划-20260902/tasks.md` 第 20 节）；入场前先 `git status` + `git diff` 看现状 —— 历史上出现过「已部署上线但连续几轮没提交」的情况（1.0.42–1.0.45 就是这么攒到 09-17 才一次性补提交的）。
- 数据库结构变更参考根目录 `mth.sql` + `docker/mysql/init/` 迁移补丁的顺序加载机制。
- 读接口禁止全量 `ToList()` 后内存分页/排序/求和——玩家与记录类查询一律 SQL 下推（参考 `B_Users.QueryUsersPaged` / `B_ReChargeRecords.GetReChargeRecordsForPhone`，见 `Docs/手机端性能优化-20260829.md`）。`/Game`、`/Mobile` 已改只读会话，往这两个区域加写 Session 的代码需先确认（当前仅 `Game/UserInfo/Register` 例外可写）。
- **线上部署前先在 MySQL57 对 mth 库执行 `Docs/sql/性能索引.sql`**（幂等；核心表二级索引 + user_daily_winloss.UserID 字符集对齐，未执行则新查询走不了索引）。
- 单测用 `"C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\IDE\CommonExtensions\Microsoft\TestWindow\vstest.console.exe" UnitTestProj/bin/Release/UnitTestProj.dll` 跑。**24 个走库的用例会失败**（`Recharge_Test_*`、`GetAgenciesBy*`、`CoinReports`、`Exchange_Test_2`、`GetBetParams` 等）——根因是 `UnitTestProj/App.config` 的 `<system.data><DbProviderFactories>` 只注册了 SQLite，MySQL 仅注册在 `<entityFramework>` 段，`DbProviderFactories.GetFactory("MySql.Data.MySqlClient")` 直接抛 ArgumentException，且连接串指向已失效的 `192.168.0.101`。属既有环境问题（该文件自首次提交未改过），不是代码回归；纯逻辑与视图契约用例（`AgencyRulesTest`、`ViewContractTest`）可正常跑。
- 部署脚本里没有 `deploy.ps1` 的自动同步：线上用的是 `C:\Users\Administrator\Desktop\deploy\deploy.ps1`（新机；旧机是桌面根下的 `deploy.ps1`），与仓库 `Tools/deploy/deploy.ps1` 内容一致。改仓库脚本后记得同步过去，否则线上跑的仍是旧逻辑。
- **后台与游戏服同机**（新架构）：`Web.config serverName="."` + `pipeName=mynamedpipe` 指向本机中心服，所以"踢人/机器人/热更推送"是否可用取决于 `C:\Server` 里中心服进程在不在（见仓库 MTH-Server 的 AGENTS.md），不是配置问题。⚠️ **"进程在"不等于"管道通"**：2026-08-27 起中心服进程一直在，但管道一次都没连上过（指令全部失败），排查见「已知未闭合项」8。验证管道别去连它试探，先查 `gamecommandoutbox` 的 `Status=2(Acked)` 最近时间——那才是"真的发出去了"的唯一凭据。
- **上传目录**：新机 `UploadPath=C:\Backend\Upload`（旧机写的 `D:\Uploads` 在新机不存在，迁移时已改）。改主机时别忘这条。
- **站点有三个入口端口，别搞混**（2026-09-12 排 522 时踩过）：**8080** 只给 nginx 链路（防火墙精确白名单只放行 `94.103.6.39`）；**80** 给 CDN 回源与直访（对所有来源开放）；**8081** 是 App 的 HTTP 接口。给 CDN 配 8080 回源会被防火墙丢包直接 522。部署时传 `-Port 8080` 是安全的（2026-09-13 实测：`Add-FirewallPort` 只要发现该端口已有规则就直接返回，不会把白名单放宽，部署后从公网测 8080 仍是超时丢弃）。
- **CDN 回源协议必须选 HTTP**：源站 IIS 只监听 80/8080/8081，**没有 443**。"跟随客户端协议"会让 CDN 用 443 回源而失败。

## 调查方式（可复现）

**2026-09-17（线上/仓库一致性整树核对）**：`Tools/one-off/_cmp_tree.ps1`（纯 ASCII，`scp` 到服务器后 `powershell -File` 跑，输出 `MD5 相对路径` 清单）本地 `find + md5sum`（把 `/` 换成 `\` 再 sort）比对，可直接回答「线上到底是不是这一版」。注意两边都要排除 `Logs`/`App_Data`/`Upload`/`obj`/`.vs`（`Logs`/`App_Data`/`Upload` 是线上部署时保留的运行期目录）；线上会比仓库多 `Web.config.orig_before_migration` 这类迁移留档。

**2026-09-11（新机 `8.218.67.82` 迁移与核查）**：SSH 密码登录 `administrator@8.218.67.82`（本机 Git Bash 无 sshpass 时用 Python `paramiko`）；远程 PowerShell 长脚本用 base64 `-EncodedCommand` 或先 `scp` 再 `-File`（cmd 会吃反斜杠、8191 字符上限会报"命令行太长"）；远程脚本文件保持**纯 ASCII**（PS 5.1 把无 BOM UTF-8 当 GBK 读，中文会解析失败）。采集项：`Get-Process`/`Get-NetTCPConnection -State Listen`/`Get-ScheduledTask`/`Get-NetFirewallRule`(+PortFilter/AddressFilter)/IIS `appcmd list sites|vdirs|apppool`/`C:\inetpub\logs\LogFiles\W3SVC1`（`s-port`+`c-ip` 判定流量来源）/`C:\Backend\Logs\yyt_*.log`；DB 用 `mysql -N -e "show databases / 行数"` 与 `mysqldump --single-transaction --hex-blob` 迁移。**哈希比对**本地 `md5sum` 与服务器 `Get-FileHash -Algorithm MD5` 逐文件核对（YYT.*.dll 6 个 + exe）。外网侧用 `curl --noproxy '*'`（本机 DNS 在代理域 `198.18.x.x`，Python socket 测外网是假阳性）与 DoH（cloudflare/alidns）解析域名，避免本地 DNS 污染。

**2026-08-29（旧机 `.112` 只读采集，已归档）**：系统/磁盘/WMI 硬件信息、WebAdministration 站点与应用池、进程路径、netstat 监听端口、`C:\Backend` bin 时间戳与 Web.config 关键项（密码已脱敏）、MySQL 服务与 `SELECT VERSION()/SHOW TABLES/行数`、命名管道枚举、防火墙状态、部署备份目录、最近日志尾部；另从本机外网探测 80/8081（HTTP 302）与 3306（TCP 可达）。除 2026-09-11 的迁移外未在旧机做写操作。
