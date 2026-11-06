# 后台功能影响面与源码入口

维护基线：2026-11-05 本地源码。先读 [三端功能影响图](../../../MTH-Server/docs/architecture/feature-impact-map.md)，每次改动按 [影响记录模板](../../../MTH-Server/docs/architecture/change-impact-template.md) 写清受影响项、排除依据和验证。新增游戏另读 [后台接入清单](backend-new-game.md)。下表路径相对仓库根，方法名用 `rg -n` 定位，避免长期行号漂移。

## 从需求定位调用链

| 需求 | 后台入口与数据 | 必须联查的影响面 |
|---|---|---|
| 开放/关闭/更名游戏 | `TTY.Web/Areas/Game/Controllers/GameSettingController.cs` → `YYT.BLL/EF/B_Games.cs`、`YYT.Entity/EF/M_Games.cs`；`GameDisplayNames.cs` | `Api/GamesController.cs`、代理可玩游戏、桌配置树、控牌、Robot、排行榜；中心登录白名单及客户端真实标识，不能只改显示中文 |
| 包与代理线隔离 | `ClientPackageController.cs`、`AgencyInfoController.cs` → `ClientPackages.cs`、`LineScopeRules.cs` | `admin.PlayableGames`、`clientpackage`、登录认证、账号带入的 API 筛选、桌归属、控牌写入权限、历史查询 |
| 新建/修改/复制/收回桌台 | `GameConfigController.GetTableConfig/SaveTableConfig/CopyPublicTablesToLine/DeleteTableConfig`、`Views/GameConfig/ConfigEditor.cshtml` → `LineTables.cs`、`EF/shit/B_*GamePara.cs` | 真实桌号/显示序号、默认继承、代理线、按类型上限、数据库事务、RP/TC/PC、游戏服实际接收/客户端刷新、Robot 目标容量 |
| 权重/倍率/特殊规则 | `GameConfigWeights/Rabbit/Phenix/Mjhl/MjhlAgentController.cs`（GameConfigController 分部）、相关 `_*.cshtml`、`Scripts/app/game.*.js`、`TTY.Web/Models/` | 规则解析、按桌与按线存储、概率数学、默认回退、目录指纹、热更、当局/下一局生效、控牌报价、存档兼容 |
| 玩家在线/离线/详情 | `UserInfoController.GetOnlineUsers/GetOfflineUsers/GetUserDetail` → `B_Users.cs`、`PipeGameServerClient.cs`；`phone.players.js`、`phone.playerdetail.js` | QA 实时状态、管理范围、游戏分/钱包/押注单位、盈亏/最后登录、控制状态可见性、缓存和迟到请求、电脑/手机两端 |
| 充退/转账/订单 | `Game/Controllers/RechargeController.cs`、`Controllers/Api/*Pay*Controller.cs`、`UserTransAllController.cs` → `B_Recharge.cs`、`B_ReChargeRecords.cs` | 权限/归属/订单幂等、LK/UL 与游戏确认、钱包及机台分、离场尾分、AA19/H5 推送、审计/流水；不得改余额一处算完成 |
| 吃分/放水/控牌/关闭控制 | `UserInfoController.cs`、`FishUserCtrlController.cs` → `B_UserControl.cs`、`TotalControlRules.cs`、`LineScopeRules.CardActionToGameId` | 电脑 `UserInfo/Index.cshtml`、`OnlineUsers.cshtml`，手机 `phone.core.js/phone.control.js`，共用牌型目录；中心 UC 校验/路由、游戏能力、中奖回写、进度、奖池 |
| 奖池与送奖记录 | `PrizePoolController.cs` → `B_PrizePool.cs`、`CardPrizeQuoteRules.cs`、`Config/card-prize-quotes.json` | 实际押注钻报价、预估/实际奖区分、ControlId、唯一开奖/支出、离场自动收尾、重复报文、资金审计与迁移过程 |
| 盈亏/流水/审计 | `GameRecord/UserRecord/AgencyRecord/AccountLogController.cs` → `B_Records_MySQL.cs`、`B_Users.cs` | 游戏原分与钻兑换、`user_daily_winloss`/幂等 ledger、账号串与数字平台 ID、代理过滤、时间区间、计数/分页、记录保留期 |
| 大奖榜/中奖历史/公告 | `Api/RankingListController.History`、`UserRecordController.GetPrizeHistory`、`NoticeController.cs` | 中心先落榜再播、游戏判大奖、IsBroadcast/Multiplier、真人/Robot、同一实际奖项、昵称隐私、代理线/关闭游戏筛选、机台号、客户端队列；不要假设旧客户端协议携带事件 ID |
| 全民赛跑/活动 | `ActivityConfigController.cs`、`Api/RabbitRaceActivityController.cs` → `RabbitRaceActivity.cs` | 活动日/北京时间、`RabbitRaceLedgerPath` 权威台账读取（未配置环境回退中奖记录统计）、按开始时间恢复、Robot 名额、代理可见性、客户端已入账演出与活动局禁止比倍 |
| 机器人 | `RobotController.cs`、`UserRobotController.cs` → `B_Robot.cs`、`SConnect.cs` | `robot_seat` 配额、`userrobot` 账户、实际在线/入座区别、代理线、机台/座位容量、自动调度/打乱/超时、ServerRobot 指令与持久化；鱼机/押注 `SetMultiSeatRobots` 按总数均分、`MAX_PER_TABLE` 保存每桌上限，至少预留一真人座，见[升级依赖](../鱼机押注机器人总数与每桌上限-20261106.md) |
| 客服/邀请码/昵称 | `Api/CustomerServiceUrl/AgencyInviteCode/UpdateUsersController.cs` → `B_Admin.cs`、`B_Users.cs` | 直属代理、注册归属、账号鉴权、空值 UI、昵称设置标记、AA01 快照/HTTP 刷新与旧 APK |
| 登录/菜单/权限 | `Controllers/LoginController.cs`、`Models/AuthorizeAttribute.cs`、`Filters/JsonAntiForgeryAttribute.cs`、`Views/Mgr/Index.cshtml`、`Areas/Mobile/Controllers/HomeController.cs` | Session、手机/电脑入口、后台授权与防伪、权限授予上限、管理范围、失败审计、登录计数冻结与解冻 |
| 指令投递与补偿 | `YYT.BLL/Services/GameServer/GameCommandService.cs`、`PipeGameServerClient.cs`、`GameCommandOutboxRetryService.cs` → `YYT.Remote/SConnect.cs`、`YYT.BLL/EF/B_GameCommandOutbox.cs` | LK/UL/UC即时发送、失败落发件箱、应用回执、重试幂等、Status与错误语义；QA失败不同于成功空列表，不能为探测重启中心 |

表中无目录前缀的后台 Controller 均在 `TTY.Web/Areas/Game/Controllers/`，BLL 在 `YYT.BLL/EF/`，手机脚本在 `TTY.Web/Scripts/app/phone/`。`Api/` 位于 `TTY.Web/Controllers/Api/`，普通 `Controllers/Models/Filters/Scripts` 相对 `TTY.Web/`；游戏配置/用户视图在 `TTY.Web/Areas/Game/Views/`。`GameConfigWeightsController.cs`、`GameConfigRabbitController.cs`、`GameConfigPhenixController.cs`、`GameConfigMjhlController.cs`、`GameConfigMjhlAgentController.cs` 是五个真实分部文件，表中斜线简写不表示嵌套目录。

## 参数保存必须走完整链路

1. 页面序列化 → Controller 校验身份、参数族、代理线、表单版本/边界 → 对应 BLL 事务落库。
2. 基础参数、按桌权重/独立规则必须按既有事务保存，不能先保存一半再独立写另一半。已有字段未携带与显式清空语义不同，旧页面不能清掉新配置。
3. 保存完成后通知中心。普通参数走 RP/PA，桌名/开关和扩展通过 `SConnect.SendTcCommand`，特殊规则按当前 PC 等入口；`GameConfigMjhlController.SendMjhlHotReload` 名称虽含麻将，当前也由火凤凰/大白兔分支调用，不能只按名字猜用途。
4. 中心落库/读取→扩展快照或分片→目标游戏服接收并应用→客户端获取。后台“保存成功”和运行时“新参数生效”要分别验证；热更失败但已落库的 `datas=true` 不能当作数据库回滚，前端仍需回读并显式提示。
5. 新桌/删桌还要核对 `ROOM_MAX`、`NUM`、归属、真实桌号和存档。牌机/拉霸上限由 `LineTables.MaxTablesFor` 返回 1000，押注/鱼机 256；跨端分片/握手依赖见共享指南。

**旧 SHZ 改名事故留下的约束**：桌名变化不能被另一张参数表 `SaveChanges()==0` 挡住；只写库/只发 TC/只有中心支持，任何一段缺失都会造成“后台改了，游戏不变”。当前 `B_LabaGamePara.SaveTableFull` 已在事务后独立发送 TC，不能照旧草案恢复 `val>0` 门控或把三款拉霸当未完成单桌原型。

## 单位、记录和权限不可混用

- 平台 `GameId`、控牌 `cardAction`、展示 `gameType`、存储 `paraType`、真实桌号、显示序号是不同字段。game54 展示牌机但 `paraType=3`；其他例外先查 `GetParaGameType`。
- `COIN_SC/EX_COIN` 是兑换参数，`COIN_NEED` 是入桌门槛，`DIF` 为机台难度；不能按早期误标说明互换。小数鱼机/麻将各有整数缩放，禁止统一盲乘/除 10 或 100。
- 钱包、上机台分、下注、实际派奖、盈亏、控制进度与奖池支出分别有权威；精度、累计量/增量、幂等标识和回滚必须记录。具体既定规则见根 [AGENTS](../../AGENTS.md)。
- 中奖历史 `GetPrizeHistory` 先按播报与50倍门槛过滤再计数/分页；大厅榜 `History` 读 `gamerankhistory` 最新30条，按开放牌机/拉霸及代理线过滤，明确排除 game54。后台历史与大厅榜不是一个筛选接口。
- 控制显示由 BLL 权限过滤后 `TotalControlRules.PickDisplayControls` 收敛每人一条、控牌优先；不能恢复旧“每人显示全部控制”的前端设计。普通代理只看自己设置的控制，不因此收紧其有权覆盖的管理范围。
- 在线/离线玩家控制均有显示路径。`phone.players.js` 优先消费列表同包 `controls`，兼容旧返回时批量补查，保留缓存失效/迟到响应隔离；不能为提速删除离线控制。
- 客服仅玩家直属代理，未配置返回空；不得恢复旧向上回退草案。邀请码是代理属性，玩家仅用码/查看。

## 常见遗漏与最短验收

| 容易漏掉 | 最短有效检查 |
|---|---|
| 只改电脑端 | 同账号手机/电脑各一遍正常、越权、空值、迟到回包；共用目录检查两端回显旧记录 |
| 只改前端显隐 | 直接调用实际 Controller 验证超管/普通代理/跨线/防伪失败，不以按钮隐藏代替授权 |
| 配置只用默认值验证 | 两张桌/两条线配置不同非默认值，回读、热更、重连/重启，确认互不覆盖 |
| 新编号只加一处 | 从页面 action/value → BLL 映射/报价 →中心校验→目标服→执行/扣次数/奖池逐段核对 |
| 发布漏程序集或静态资源 | 真实隔离站点做依赖与 Razor 检查，核对 csproj、WebVer、CDN脚本，不只检查HTTP200 |
| 新游戏功能不适用 | 在接入矩阵明确“不支持+界面隐藏/后端拒绝+验证”，不能留默认空档或继承错误能力 |

专题实施与发布证据从 [文档导航](../README.md) 查找；本指南描述影响面，不替代任一实际发布记录。
