# 新增子游戏：后台接入与验收清单

先建立 [三端接入任务](../../../MTH-Server/docs/architecture/new-game-checklist.md)，在 [游戏接入矩阵](../../../MTH-Server/docs/architecture/game-integration-matrix.md) 登记能力；按 [影响模板](../../../MTH-Server/docs/architecture/change-impact-template.md) 为下面每项记录“已接入+证据”或“不适用+依据”。不能只完成游戏配置页就宣称接入完成。本页补后台实际文件，通用三端顺序以共享清单为准。

## 1. 编号、名称、开放与代理线

- [ ] 确定平台 `GameId`、客户端枚举/`games.Name`、中文显示名、`GameType`、`paraType`、控牌 action/value 范围。对比中心枚举、项目/端口和客户端，不复用仍有历史数据的旧编号。
- [ ] `M_Games.cs`/`B_Games.cs`、`GameSettingController.cs` 与幂等迁移登记；核对 `gamemo/gamepara/paragame` 及对应参数基础行，缺行时明确失败，不隐式创建错类型默认值。
- [ ] 需要中文别名时改 `GameDisplayNames.GetName`，不将显示名直接写成客户端无法识别的 `games.Name`。
- [ ] 验证 `Api/GamesController`、中心 AA01 白名单、客户端大厅/打包入口一致；关闭游戏不能在其它菜单继续下发控制。
- [ ] `LineScopeRules`、`admin.PlayableGames`、`ClientPackages`：默认不限/显式空集、直属代理继承、旧包不传 account、新包带 account 都核对；不把其它代理线的桌/记录/玩法展示给玩家。

## 2. 桌台与完整参数保存

- [ ] `GameConfigController.GetGameList/GetParaGameType`：展示分类与配置参数族正确（game54是现有例外范例）。
- [ ] `GetTableConfig/SaveTableConfig/DeleteTableConfig` 与 `EF/shit/B_BetGamePara/B_CardGamePara/B_FishGamePara/B_LabaGamePara.cs`：读取、创建、编辑、删除、无桌默认、参数校验、数据库事务、热更失败提示均覆盖。
- [ ] `ConfigEditor.cshtml`、`game.acc.js` 及类型专属分部/脚本：字段显隐、回读、预填、恢复默认、自动桌名、单张/批量新建、表单有效后再询问数量；不覆盖人工桌名或未提交的另一桌参数。
- [ ] `LineTables`：公共桌复制到代理线、已有专属线继续新建、收回、删桌与失败撤销；归属使用实际 `admin.ID`。复制走 `PlanTargetIndexes` 优先复用已标记 `#` 的收回桌号，单独新建走 `ReserveNewLineTable`，分别核对归属与旧按桌数据。`MaxTablesFor` 上限要与子游戏/中心编码和客户端容量一致。
- [ ] 单位契约逐字段记录：显示/入库/协议单位、倍率缩放、上下限、默认值、0/缺字段/空串语义、热更生效时点；下注、兑换、入场门槛、最高输赢不可混用。
- [ ] 权重/倍率/附加玩法若不能复用已有规则，新增独立 `Models` 解析与校验、Controller/视图/脚本，保留兼容未知键和旧配置；禁止直接拼 JSON 绕过服务端同口径校验。
- [ ] `cardpayoutprofile` 的 HandType/哨兵、`cardgamecfg/betgamecfg` 或 `gameconfiglaba` 键空间不与已有功能冲突；独立规则按桌，麻将类按代理线的版本锁/历史/公共回退需明确。
- [ ] 保存/热更链路按 [功能指南](backend-features.md) 的数据库→RP/TC/PC→中心→子游戏→客户端逐段验证；新增协议回执或分片能力与旧服兼容/回滚成套记录。

## 3. 控牌、吃分、放水、报价与奖池

- [ ] `LineScopeRules.CardActionToGameId` 与中心 `cardActionToGameId` 一致；`B_UserControl` 的 action/value 校验放行到预期上限，并拒绝未实现编号。
- [ ] 手机 `phone.core.js` 的目录/映射/名称和电脑 `UserInfo/Index.cshtml`、`OnlineUsers.cshtml` 同步；已有共用脚本优先复用。实际运行的下拉、选择后切换游戏、关闭选项、历史旧值回显分别验证。
- [ ] `CardPrizeQuoteRules` 读取的 `TTY.Web/Config/card-prize-quotes.json` 加入报价；准确奖金与随机奖金预估上界分别标记，按实际押注钻与桌台比例算，不只更改前端文字。
- [ ] `B_UserControl/TotalControlRules` 的吃分/放水互斥、控牌共存与显示优先、设置权限/读取权限、关闭旧控制/替换新控制及跨游戏恢复保持一致。
- [ ] 游戏服真正支持的吃分/放水/控牌/比倍能力与后台目录一致；不支持项明确隐藏且服务端拒绝，不能继承模板的“看似可用”按钮。
- [ ] `B_PrizePool`、奖池存储过程、ControlId 生命周期、`gameprizerecord`、唯一支出与报价串联；未命中、普通局、重复报文、控牌与放水重叠、离场/断线自动收奖及活动奖不重复记账。

## 4. 钱包、盈亏、流水、大奖榜

- [ ] 后台充退与游戏钱包/机台分同步：LK/UL、中心应用确认、游戏服同步、客户端 AA19/H5、尾分换率及退出再次入账全部核对；旧版本安全降级与成套发布写明。
- [ ] `B_Users/B_Records_MySQL` 查询、`GameRecordController` 的游戏名称/筛选/单位；中心结算携实际兑换比和累计量/增量，`user_winloss_ledger` 幂等与离场补记可复验。
- [ ] `UserRecordController.GetPrizeHistory`、`Api/RankingListController.History/DisplayScore/DisplayMachine`：新游戏分类、大奖筛选、50倍历史门槛、机台号基数、原分/钻单位、昵称隐私、代理线范围。
- [ ] 游戏服大奖事件→中心落榜/明细→广播→客户端跑马灯为同一事件；真人/机器人策略分别确认，不能后台另外猜倍率拼一个“大奖”。
- [ ] 审计接口、流水过滤、时间范围、玩家/代理账户区分、记录保留期与删号清理均覆盖新增数据；历史数据迁移/回填单列授权，代码发布不自动补账。

## 5. Robot、活动、菜单、客户端接口

- [ ] `RobotController/UserRobotController/B_Robot` 的游戏列表、机台容量、配额/账户/实际入座、随机找空位、代理线、每日打乱/超时接替、派奖公告均匹配新游戏；例如game54既定不接机器人，须明确排除。
- [ ] 有全服活动时确认 `ActivityConfigController`、独立 API、活动时间/台账/配额与 Robot 关系；客户端领奖是演出还是再次请求结算要明确，不能重复派奖。
- [ ] 游戏配置/控制/记录菜单在电脑 `Views/Mgr/Index.cshtml` 与手机 `HomeController`/视图可达；`Models/AuthorizeAttribute.cs`、防伪、服务端权限位、管理范围与操作审计同步。
- [ ] 公告、客服/邀请码、昵称/钱包/充值等公共接口在该游戏中仍可达；登录快照、HTTP刷新和退出回大厅的生命周期不要因新场景漏接。
- [ ] 所有新增源码/视图/JS/CSS/JSON 在老式 `TTY.Web/YYT.Web.csproj` 或对应项目登记；Web/BLL/Entity/Remote公开方法依赖、BOM与静态缓存版本核对。

## 6. 交付证据

至少两张桌、两条代理线和一组非默认配置；一条正常链路加一条失败/重试链路。具体选择与耗时按 [开发验证指南](backend-development.md)，不要机械运行全部旧测试。

交付须能回答：哪份SQL初始化了哪些表；哪个API保存到哪张表；哪条指令触发哪个服的实际应用；客户端用什么字段；哪些功能明确不支持；后台/中心/目标服/Robot/APK各自需发布什么；失败时恢复哪些兼容版本。

实际源码例子：大白兔 [按桌规则](../大白兔配置重排与牌型RTP-20261103.md)、[控牌最终验收](../大白兔控牌修复与双端实测-20261104.md)；麻将 [代理线参数](../麻将胡了默认代理线与桌台参数-20261103.md)；专属桌 [创建与按钮](../专属桌台新建与按钮显隐修复-20261105.md)。这些是参考实现，不是让所有新游戏继承相同玩法。
