# AGENTS.md — MTH 运营后台

本文件供编码助手与新成员使用。中文交流；先读当前任务相关约束，再改代码。
整理日期：2026-11-05。发布状态取自本地证据，本次整理未连接生产环境。

## 1. 工作边界与效率

- 以最短有效路径完成任务，记录构建与测试耗时。人工验证更快、更准时，给出页面、操作与预期结果；不要为局部文档/样式改动跑整套业务回归。
- 开始先看 `git status --short`、当前分支和相关 diff；保留已有未提交改动，不清理根目录历史文件、`.build/`、测试证据或其它任务产物。
- 当前工作区、已提交代码、隔离发布包、线上版本分别核对，不能相互替代。分支名、PID、表行数、开放游戏数以当次检查为准。
- 生产环境有真实玩家和资金。排查先只读；线上写文件/写库、部署、重启、回收应用池和测试下注须在用户已授权的具体范围内执行。已有明确授权时直接落实，不重复索要确认。
- 中心服重启会中断玩家；应用池回收会短暂中断后台。不要为验证通信而重启中心服或主动连接生产管道试探；先看近期命令回执、发件箱 `Status=2` 和日志。
- 线上 DDL/DML 前备份，数据库导出带 `--single-transaction --hex-blob --routines --triggers`。测试事务应在隔离库验证，不将可回滚写入称为只读。
- 不自动修正历史余额、盈亏、控制进度或奖池；不把历史迁移脚本当作每次发布的必跑清单。
- 不在文档、日志或交付物中打印密码、连接串秘密、私钥；只在必要的本地配置/凭据渠道读取。
- 每次改功能先读 [三端影响图](../MTH-Server/docs/architecture/feature-impact-map.md)，按 [影响模板](../MTH-Server/docs/architecture/change-impact-template.md) 记录影响面、排除依据、验证与发布依赖；后台源码入口见 [功能指南](Docs/architecture/backend-features.md)。
- 新增子游戏必须使用 [三端接入清单](../MTH-Server/docs/architecture/new-game-checklist.md)、[接入矩阵](../MTH-Server/docs/architecture/game-integration-matrix.md) 与 [后台清单](Docs/architecture/backend-new-game.md)，逐 G01–G23 记录“已完成/不适用/未完成”、真实入口、验证证据和发布依赖；覆盖桌配置、控制、奖池、记录、Robot、权限和迁移，不适用也须有依据。

## 2. 仓库与入口

| 路径 | 用途 |
|---|---|
| `MTH_Mgr_MySQL.sln` | ASP.NET MVC5、.NET Framework 4.8、EF6、MySQL 5.7 解决方案 |
| `TTY.Web/YYT.Web.csproj` | Web 主站：目录叫 TTY.Web，项目与程序集叫 YYT.Web |
| `TTY.Web/Controllers/` | 登录、框架入口与 `Api/` 玩家接口/支付回调 |
| `TTY.Web/Areas/Game/` | 电脑端运营接口与视图 |
| `TTY.Web/Areas/Mobile/` | 已投入使用的手机端运营页面 |
| `TTY.Web/Scripts/app/` | 共用配置脚本与 `phone/` 手机端脚本 |
| `YYT.BLL/EF/` | 实体、业务查询、资金/权限/桌台规则 |
| `YYT.BLL/Services/GameServer/` | 命令服务、发件箱与补偿重试 |
| `YYT.Remote/SConnect.cs` | 命名管道客户端；协议定义在 `TTY.Web/Config/MsgDefine.config` |
| `YYT.Entity/`、`YYT.Common/`、`YYT.DbUtility/` | 数据契约、基础设施与数据访问 |
| `UnitTestProj/`、`tests/` | C# 规则/视图契约、JS 与浏览器验证 |
| `Tools/dev/`、`Tools/db/`、`Tools/deploy/` | 本地构建/专项验证、数据库、打包部署 |
| `Docs/`、`Docs/sql/` | 专题方案、发布证据、按需迁移 |
| `../MTH-Server/`、`../MTH-git/` | 游戏服务端、Unity 客户端；跨仓改动先读对应 AGENTS.md |

老式 csproj 不自动包含新文件：新增 `.cs/.cshtml/.js/.css` 必须登记对应项目。
`Phone/` 为旧参考/预览资料，`Tools/one-off/` 为历史一次性脚本，使用前核对目标与副作用。
工具说明见 [Tools/README.md](Tools/README.md)；其中历史版本/迁移建议不能替代当前发布计划。

## 3. 最短有效验证

数据库唯一入口为 `Database/mth_full.sql`（线上完整快照）与 `Database/mth_clean.sql`（新环境初始化），范围、归档、校验与更新流程见 [数据库说明](Database/README.md)。两份含敏感数据/凭据，保留在本地但忽略 Git；Docker/新装/reset 与当前验证器只引用 clean，不叠加旧迁移。历史增量/修复/种子 SQL 已移到仓库外，原文见 [归档索引](Database/legacy-sql-archive.md)；`Tools/db/check-line-ownership.sql` 是保留的只读归属诊断，不是初始化库。

```powershell
# 在仓库根运行；已有有效构建时可跳过 Clean。
.\Tools\dev\build.bat noclean
# 本地 IIS Express；启动前核对配置，防止连接生产库或生产管道。
.\Tools\dev\start.ps1
# 示例：只跑对应领域的现有 JS 测试。
node tests/rabbit-rtp.test.js
```

- 全量重新构建用 `Tools/dev/build.bat`；脚本支持 `Debug`/`noclean`，并自动补 .NET 4.8 引用程序集与 Web targets。
- C# 变更运行受影响的 `AgencyRulesTest`、`LineScopeRulesTest`、`TotalControlRulesTest`、`RabbitRaceActivityTest` 或 `ViewContractTest`；用本机 VS 的 `vstest.console.exe` 按类/用例筛选 `UnitTestProj/bin/Release/UnitTestProj.dll`。
- 数据库/管道验证优先现有隔离入口：`Tools/dev/check-line-tables.ps1`、`check-rabbit-remaining.ps1`、`check-prize-pool.ps1` 等。先读参数、端口、临时库与清理范围，不复用生产连接。
- `UnitTestProj/App.config` 有历史 MySQL provider/旧连接配置问题。失败须区分环境与回归；不要写死“固定 24 项失败”或据此忽略新增失败。
- `.cshtml` 改动须验证 Razor 编译；登录页 HTTP 200 不说明受保护业务视图编译成功。使用隔离站点副本做 `aspnet_compiler` 预编译。
- 历史无引用 `_PartialYearMonthSelPage.cshtml` 依赖缺失的 `FengBo.BLL`；如仍存在，只在验证副本排除该明确遗留文件，并记录范围，不删除线上/仓库业务文件。
- JS 改动做语法与相关行为验证；涉及 EasyUI 显隐、保存、弹窗、滚动或多端交互时用真实浏览器检查，不只做字符串契约断言。
- 报告注明实际通过/失败、耗时、未验证范围；本地计算/模拟、实际 HTTP、真机与线上验证分别记载。

本地 MySQL 必须 `lower_case_table_names=1`，否则 EF 大写表名映射失败。容器配置在 `docker-compose.yml`，连接信息查当前配置，不复制进文档。
IIS 应用池使用 64 位 v4.0 Integrated（含 x64 SQLite 依赖）。`env-check.ps1` 默认会安装组件；只读检查需 `-CheckOnly`。

## 4. 身份、权限与查询约束

- Session 登录态是 `M_LoginUser`，业务用 `WebHelper.GetLoginInfo()`。POST 未登录按前端契约返回 `code=-1`，GET 跳对应电脑/手机登录页。
- 登录必须走 `admin` 记录校验；不得恢复按账号名绕过密码的旧超管分支。权限位与管理范围在服务端检查，前端显隐不能替代鉴权。
- 全局配置写入用现有超管授权与防伪机制；授权值不得高于操作者库中权限。建号/建代理按字段白名单，资金初值不得绑定客户端输入。
- 玩家接口 `UserTransAll`/`UpdateUsers` 保留 `pwd` 校验；注册/添加路径保留账号与密码 Trim 及重复判断。支付订单保留归属检查与幂等守卫。
- 代理范围由 `admin.ManageScope`（1 直属 / 2 整线）决定；“我的代理”按节点列直属下级只是浏览方式，不收紧查询/设置权限。
- 封禁/冻结可见及解除：操作人本人、特级本线、总台；审计过期无法定位操作人时只保留特级/总台规则。动作仍按管理范围，走有审计的封禁入口。
- 控制状态可见：总台/特级看全部，普通代理只看自己设置的；设置/覆盖按管理范围与权限位，不额外按旧控制的 `CreatedBy` 拦截。规则入口为 `AgencyRules`、`B_UserControl`。
- 代理密码只在授权出口按 `IsViewAgentPwd` 与管理范围脱敏；不要在前置路径无条件清空，也不要向无权限调用者透出。
- 玩家与流水查询的过滤、分页、排序、聚合下推 SQL。禁止全量 `ToList()` 后分页；EF 查询不得直接投影 `new M_实体`，先匿名类型再内存组装。
- `/Game`、`/Mobile` 使用只读 Session（历史注册例外）；新增写 Session 前核对会话行为，避免请求互锁。
- 列表 JSON 为 `{total, rows}`，操作为 `{code, msg}`。MVC JSON 返回需测试真实 `JsonResult.ExecuteResult`；不要假设 `JObject` 会按预期序列化成对象。

## 5. 资金、统计与控制口径

- 玩家今日/总输赢以 `user_daily_winloss` 为权威，赢正输负；不是充值减退分，也不是游戏服本局/本次在线 `TotalWinLoss`。
- 统一钻口径后的盈亏与控制进度依赖实际桌台兑换比、结算累计及幂等台账。历史混合口径不能全表除固定倍率；详见 [盈亏修复](Docs/玩家盈亏统一币口径修复-20261102.md)。
- 后台货币文案统一“钻”；字段名/协议、已落库中文历史、游戏名不随文案批量重写。当前押注报价按实际桌台兑换比，旧机台分显示与钻报价须区分。
- `ConsumedCoins` 是净进度，可为负，按原值显示。会员盈亏只含玩家：排除 `rechargerecords` 的代理充退；盈亏关联 `Users.ID` 账号串，不与数字平台 ID 混接。
- 手机“代理流水”传 `MONEY_ONLY=1`，在 SQL 计数/分页前过滤非资金记录；电脑代理记录保留登录/封禁审计。代理详情不展示剩余分，玩家查询仍显示 `users.GAME_SCORE`。
- 玩家最后登录取 `userloginrecord` 优先、旧日志兜底，排序同口径；在线卡片不额外查询最后登录。保留 `users.INHALL` 触发器，导出/迁移带 triggers。
- 吃分(4)/放水(5)互斥，新模式须解除被替换旧模式；控牌(6)与之共存。展示每人一条，控牌优先；通过 `TotalControlRules` 收口，不能在各端重写判断。
- 控牌命中后的实际净收益可进入放水进度；控制次数、单手完成、送奖扣池与总盈亏是不同链路，不得通过同一事件重复扣款。
- 奖池扣款按实际结算和控制编号处理，开奖/放水扣到 0 不为负，重叠不重复计费；不补扣历史。报价不足校验、真正扣款、离场收尾须成套验证。
- 中奖历史先按 `IsBroadcast=1 && Score>=0 && Multiplier>=50` 过滤再计数/分页；倍率用落库值，不重新推算，不删除原明细。
- 删除玩家先踢人，再按现有事务清账号关联数据；同名代理流水不能误删。存量 `userrelations` 可能重复，列表关联用 `B_Users.RelationsDedupSql`，不要假设已有唯一索引。
- 邀请码属于代理；玩家显示注册用码优先、所属代理邀请码兜底，不把玩家 ID 当邀请码。

资金/控制变更先读 [奖池与手机控制页](Docs/代理送奖奖池与手机控制页-20261102.md)、[手机操作管理与奖池记录](Docs/手机端操作管理与奖池记录-20261103.md) 及对应服务端证据。

## 6. 游戏、桌台与跨端契约

- `GameId`、`cardAction`、展示分类、参数族、真实桌号、显示序号各有含义，不能混用；控牌目录、映射、历史回显、后台校验与中心/游戏服能力须一致。
- 当前目录入口包含 `phone.core.js`、电脑用户管理/在线玩家视图及游戏共用脚本（如 `game.attmhb-controls.js`）；先查现有共用实现，不能按历史“三处写死”盲目复制。
- `games.Enable` 与代理线范围共同决定开放游戏；不能照抄旧“六款牌机/拉霸关闭”清单。停用牌型/游戏的历史记录仍须回显。
- 多包口令由 `clientpackage` 管理，代理 `PlayableGames` 为 NULL 表示不限；玩家接口带 `account` 时按代理线过滤，配置与控制保存也要服务端复核。
- 专属桌台归属在 `roomtableowner`，按 `admin.ID` 原样写入；新增先登记归属、失败撤销。公共桌复制到线走 `PlanTargetIndexes`，先复用标记 `#` 的收回桌号，再追加；单独新建走 `ReserveNewLineTable`。复制/收回/新建权限、上限与所选代理匹配，不能套用旧注释的统一追加规则。
- 桌台上限取 `LineTables.MaxTablesFor(paraType)`：牌机/拉霸 1000，押注/鱼机 256；1000 桌依赖中心分片与游戏服握手，不可配旧服务端单独回滚。
- 麻将胡了 game54：展示牌机 `gameType=1`，配置拉霸 `paraType=3`；所有配置接口的 `GAME_TYPE` 用 `paraType`，不要读写牌机参数表。
- 麻将代理线独立参数不存在时回退公共行 `*`；保存保留乐观版本锁、历史与 PC54 热更。复制公共配置/收回独立配置须验证权限与源/目标版本。
- 麻将 RTP 估算不能用于保存，正式复核精度不足继续或明确失败；调权重/规则、Worker/WASM/JS 与游戏服保持一致，验证完整免费再触发链。三秒复核的待发状态见第 8 节。
- 大白兔 game55/cardAction20：独立玩法按桌保存 `cardgamecfg`，与本桌参数同事务；留机字段隐藏但保留。旧“活动页保存全桌共用规则”入口已被替代，不能恢复。
- 全民赛跑为全服活动 `activityconfig`：用尽保持 0，到每天设定开始才恢复；改总量按新总量减本轮已用。线上后台/大厅通过 `RabbitRaceLedgerPath` 读取游戏服权威台账，配置后读取失败不能回退中奖记录而虚报剩余；未配置路径的环境保留记录统计。迁移站点时同步路径与只读权限，不能通过删除台账修复公示。
- 火凤凰独立规则为 game5，后台控牌编号另有映射；正宗倍率/权重与服务端校验一致。大白兔小四梅默认 50，连庄控牌 27–35；具体目录以现有代码及专题为准。
- 拉霸权重目录指纹关系到游戏服兼容，只改展示名不能随意换 hash；明星97/水浒传按总押注 8/9 线，水果左右幸运灯奖池独立、旧左池全 0 回退右池。
- 幸运六狮庄/闲/和最小押分跟随本桌 BET_MIN，最大按本桌；抢庄门槛 0 表示本桌关闭，不回退房间值。客户端旧登录快照与服务端热更时机须分别验证。
- ATT 满花版奖池、金拇指及牌型使用独立配置；点石成金的中文显示与真实游戏标识/目录不等同。改命名先核对存档与奖池路径。

专题入口见 [文档导航](Docs/README.md)，跨端新功能应写清后台/SQL/中心/游戏服/Robot/APK 各自依赖。

## 7. UI、通信与部署约束

**中转服务器（2026-11-05 用户确认）：现用 `185.180.17.57`；旧 `94.103.6.39`、`140.235.96.132` 均已弃用，不再作为主用或备用中转。** 后台/API 的域名、HTTPS 证书、CDN 回源与中转/源站角色分别核对；不要照抄历史中转 IP、放行规则或回滚目标。详见 [中转拓扑更新](../MTH-Server/docs/游戏TCP域名中转部署.md)。

- 新增 Razor 视图使用 UTF-8 BOM；保留 Web.config 编码，防止中文 Windows/PowerShell 5.1 误读。
- 手机 `M.modal` 保留固定 body/滚动归零与恢复、嵌套计数锁及长弹窗内部滚动；避免滚到中下部后按钮不可点。
- `M.post` 在 `pagehide` 统一 abort；隐藏页/主动 abort 不弹网络错误，裸轮询暂停。在线查询失败保留旧列表与人数，不能伪装成无人在线。
- 控牌浮层由 `M.upwardSelect` 呈现，隐藏 select 仍是值与 change 来源；选项重建调用 `M.upwardSelectRefresh`。
- LK/UL/UC 直发管道，失败再由 outbox 补偿；不要改回最长等待定时器一轮的纯排队模式。
- 管道读回复用 `SConnect.ReadLineWithTimeout`；异步命名管道不支持可依赖的 `ReadTimeout`，禁止裸 `ReadLine()` 无限等待。QA 快速失败返回 null，空列表表示查询成功无人在线。
- 清理日志仅定时任务执行（`CleanupExpiredRecordsThrottled`），不在列表/指令请求里内联 DELETE；不同记录保留期按现行实现，不能统一当作旧的 7 天。
- 发布以确认的线上基线做隔离包，`Tools/deploy/pack.ps1 -Version <版本> -SourcePath <完整隔离站点>` 支持此流程；核对真实 DLL 依赖，禁止只发 Web DLL 却漏 BLL 新方法。
- 递增 WebVer 并核对共享脚本 URL/CDN 实际内容；本地 Web.config 版本不等于线上版本，不能仅为文档同步而改版本号。
- 发布前核对数据库迁移、配置、完整站点/增量边界及回滚；保护 `App_Data/Logs/Upload`。`deploy.ps1` 会改站点/防火墙并回收应用池，先读脚本参数，不能当只读检查。
- 部署后按本次清单核对 WebVer、文件哈希、HTTP、服务进程/端口/日志与相关业务；脚本改动需同步实际执行副本，验证不能只看本机脚本。
- IIS/游戏服历史部署路径为 `C:\Backend`/`C:\Server`，端口、CDN回源、上传路径、应用池身份每次只读确认；不要沿用旧 443/8080/8081 用途推断当前状态。
- SSH 可能进入 32 位 PowerShell，IIS/进程查询异常时检查 WOW64，必要时经 Sysnative 用 64 位宿主；长脚本传文件执行，避免编码/命令行长度问题。

## 8. 最近证据与维护方式

| 事项 | 本地记录能证明的状态（截至 2026-11-05） |
|---|---|
| 后台 1.0.106 + 11 套服务端 | [17:14 发布记录](Docs/后台1.0.106与服务端发布-20261105.md)：专属桌台、按类型上限、全民赛跑剩余与大白兔连庄/过关已上线；无 SQL/APK |
| 麻将 RTP 正式复核加速 | [本地验证/独立包](Docs/麻将胡了RTP正式复核加速-20261105.md)：已提交、未部署；1.0.106 未包含该功能，发布须重核基线 |
| 退钻回弹/拉霸尾分/最低注 | [1.0.99 成套发布](../MTH-Server/docs/后台1.0.99与批量修复发布-20261103.md)：服务端已上线，中心与游戏回执协议须成套保留；客户端项仍分别看 APK 证据 |
| 活动建表/小四梅50与相关后台功能 | [1.0.101 发布记录](Docs/后台1.0.101与批量发布-20261103.md)：已上线且相应 SQL 已执行，不重复当待办 |

上述为文档证据摘要，不是本次线上探测；当前运行状态另行只读核实。

- 根 AGENTS 只留稳定约束、工作入口和少量待办/发布依赖；长测试清单、PID、备份目录、完整发布日志写专题文档。
- 新结论在对应专题顶部注明日期、代码/验证/发布状态、证据与替代关系；更新索引，不反复把旧“未上线”与新“已上线”并排堆到文件头。
- 技术实现以当前源码/配置为准，发布事实以有时间与产物清单的发布记录为准；文档冲突时说明证据，未核实就标“待核实”。
- 文档合并/删除依据与仓库外原文备份见 [整理记录](Docs/maintenance/README.md)；历史证据不能作为当前运行状态或额外授权。
