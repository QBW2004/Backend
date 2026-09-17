# 手机端后台改造开发任务

## 1. 交付原则

- 先完成服务端授权和查询边界，再调整 UI；任何前端显隐都必须有后端校验。
- 每个实现任务都配套测试或人工验收路径；高风险权限和清理逻辑优先写自动化测试。
- 保持当前工作区已有改动，不执行 reset/checkout；新增 C#、视图、脚本按老式 `.csproj` 规则登记。

## 2. Wave 0：基线与约束清点

- [ ] **Task 0.1** 固化现有权限字段、`ManageScope` 值域、`AgencyOptLog.OPT` 已占用值和三端接口清单。
  - 输出占用值表，确认玩家冻结/解冻新增日志常量无冲突。
  - _Requirements: 3.1, 5.1, 6.2_
- [ ] **Task 0.2** 建立手机端与电脑端回归账号矩阵：超级管理员、直属范围代理、整条线代理、无创建/无查看密码/无控制权限账号。
  - 给每个账号准备直属、二级、跨线玩家和代理目标。
  - _Requirements: 3.1, 3.2, 6.1_

## 3. Wave 1：范围和权限策略

- [x] **Task 1.1** 整理 `Agency_Scope_Resolver`，分离“可管理代理集合”和“会员所属代理集合”，并让玩家、代理、权限接口统一调用。
  - 覆盖 `B_Admin`、`B_Users`、`B_ReChargeRecords`、`B_Records_MySQL` 的 SQL 下推路径。
  - _Requirements: 3.1, 3.2, 3.3, 3.6, 6.1_
- [ ]* **Task 1.2 Property Test**：构造直属、整线、跨线和自身目标，验证范围集合及拒绝结果。
  - **Property 3: Scope separation for direct management**
  - **Property 4: Scope closure for line management**
  - **Property 11: Audit visibility scope**
  - **Validates: Requirements 3.1, 3.2, 3.3, 5.3**
- [x] **Task 1.3** 抽出统一 `Permission_Policy` 判断入口，修正玩家登录密码与安全密码的独立脱敏逻辑。
  - `IsViewPwd` 关闭时从投影和详情 JSON 移除登录密码；`IsViewSafePwd` 单独生效。
  - `IsViewPwd` 与 `IsModifyPwd` 同时保护手机和电脑端玩家密码修改接口。
  - _Requirements: 2.6, 2.7, 2.8, 3.3_
- [ ]* **Task 1.4 Property Test**：对玩家/代理详情、列表、复制和修改请求做密码不泄露与不变更断言。
  - **Property 5: Password-view non-disclosure**
  - **Property 6: Password-modify authorization**
  - **Validates: Requirements 2.6, 2.7, 2.8**

## 4. Wave 2：创建下级和代理页面

- [x] **Task 2.1** 修改 `AddAgencyInfo` 创建参数：默认 `IsCreateAgent=1`，显式关闭保存为 `0`；继续由服务端补齐单次密码所需字段。
  - 同步 `phone.addagent.js`、创建视图和接口校验。
  - _Requirements: 2.3, 2.4, 2.5_
- [x] **Task 2.2** 在代理详情加入创建下级开关、当前值和保存反馈，复用权限接口并做目标范围校验。
  - `GetAgencyDetail` 返回开关值；详情隐藏当前账号自身操作。
  - _Requirements: 2.1, 2.2, 2.5_
- [ ]* **Task 2.3 Property Test**：验证缺省开启、显式关闭、越权目标和无创建权限账号的四条路径。
  - **Property 7: Create-agent default and toggle**
  - **Validates: Requirements 2.2, 2.3, 2.4, 2.5**
- [x] **Task 2.4** 调整代理列表、侧栏和代理详情文案：显示账号本身，移除“代理：”前缀；补齐登录密码按权限显示/隐藏。
  - _Requirements: 2.1, 2.6, 6.1_

## 5. Wave 3：控制管理和会员展示

- [x] **Task 3.1** 调整控制接口投影和手机页面统计区，输出五项统计、状态行和逐项控制权限。
  - 无控制时保留空白行；全部控制权限关闭时无按钮/表单。
  - _Requirements: 1.1, 1.2, 1.3, 1.4_
- [ ]* **Task 3.2 Property Test**：对三种控制权限的任意组合，验证展示集合和接口拒绝结果。
  - **Property 1: Control permission projection**
  - **Property 2: Control empty-state invariant**
  - **Validates: Requirements 1.2, 1.3, 1.4**
- [x] **Task 3.3** 调整会员详情/会员列表：状态只展示不跳转设置；“所属代理”只显示账号；“查看全部”按范围解析；统一“今日退币”文案。
  - _Requirements: 1.6, 2.9, 3.6, 4.6_
- [x] **Task 3.4** 统一手机端控制、充值、代理、冻结等操作弹窗文案，保留日志详细信息但不展示内部参数。
  - _Requirements: 1.5, 5.5_
- [ ]* **Task 3.5 Property Test**：检查所有成功 mutation 的文案集合和控制无权限时的空状态。
  - **Property 12: Result-message normalization**
  - **Validates: Requirements 1.5, 5.5**

## 6. Wave 4：记录 7×24 小时窗口和自动清理

- [x] **Task 4.1** 在充值、玩家、中奖记录 BLL 入口统一加入 `Now-7×24h` 截止时间、跨界截断和空分页返回。
  - 默认查询最近 7×24 小时；移除中奖历史 30 天默认。
  - _Requirements: 4.1, 4.2, 4.3, 4.5_
- [ ]* **Task 4.2 Property Test**：覆盖完全过期、跨窗口、窗口内、未来结束时间四种区间。
  - **Property 8: Retention-window clamping**
  - **Validates: Requirements 4.1, 4.2, 4.3, 4.5**
- [x] **Task 4.3** 扩展 `CleanupExpiredRecords` 到中奖记录并核对六张既有日志表；补幂等索引 SQL，保持定时任务单飞/节流，不在读接口删除。
  - _Requirements: 4.4, 6.3_
- [ ]* **Task 4.4 Property Test / DB Test**：插入 cutoff 前、等于 cutoff、cutoff 后数据，执行清理并验证边界。
  - **Property 9: Retention cleanup boundary**
  - **Validates: Requirements 4.4, 6.3**
- [x] **Task 4.5** 同步手机端/电脑端日期控件、空结果提示和“退币”字段文案；中奖记录改为手动下滑加载全部窗口内数据。
  - _Requirements: 4.5, 4.6, 4.7, 6.1_
- [x] **Task 4.6** 中奖记录排除八爪鱼（`GameId=42`）：`GetPrizeHistory` 的游戏清单与记录查询同时过滤，卡片与总数都不再出现；不改 `games.Enable`（该字段同时控制游戏配置/游戏记录/鱼机控制等页面）。
  - _Requirements: 4.8_

## 7. Wave 5：冻结、禁用和审计

- [x] **Task 5.1** 为冻结/解冻、禁用/恢复代理建立命名操作常量，复用 `AgencyOptLog` 写入 `OptID/ID/REC_TIME/OPT`，并把状态更新与日志放入同一事务。
  - 实施前确认新增 OPT 值未与历史值冲突。
  - _Requirements: 5.1, 5.4_
- [x] **Task 5.2** 放开非超级管理员在自身管理范围内的冻结/解冻和代理禁用/恢复；控制器与 BLL 双重校验，禁止自身/跨线操作。
  - _Requirements: 3.3, 3.4, 5.3_
- [ ]* **Task 5.3 Property Test**：验证成功操作恰好一条状态变更+一条审计、越权不变更且不写成功日志。
  - **Property 10: Audit completeness and actor identity**
  - **Validates: Requirements 5.1, 5.3, 5.4**
- [x] **Task 5.4** 扩展冻结明细、冻结账号、禁用代理接口 DTO，返回操作人和操作时间；无历史日志返回“--”。
  - _Requirements: 5.2, 5.6_
- [x] **Task 5.5** 修改 `phone.abnormal.js`、`phone.banplayer.js`、`phone.banagent.js` 及电脑端对应表格，显示新增审计列并适配短提示。
  - _Requirements: 5.2, 5.5, 6.1_
- [ ]* **Task 5.6 Property Test**：验证审计列表只返回可管理目标，操作人和时间字段完整或为“--”。
  - **Property 11: Audit visibility scope**
  - **Validates: Requirements 5.2, 5.3, 5.6**

## 8. Wave 6：回归、构建和发布验收

- [x] **Task 6.1** 更新 `UnitTestProj/ViewContractTest.cs` 及新增 BLL/API 测试，覆盖权限、DTO 脱敏、时间窗口、日志和文案契约。
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 2.7, 2.8, 2.9, 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 4.1, 4.2, 4.3, 4.4, 4.5, 4.6, 4.7, 5.1, 5.2, 5.3, 5.4, 5.5, 5.6_
- [ ]* **Task 6.2 Property Test**：使用同一账号/目标/时间参数分别调用手机端和电脑端入口，比较授权结果和有效查询区间。
  - **Property 13: Mobile/Desktop policy parity**
  - **Validates: Requirements 6.1, 6.2**
- [x] **Task 6.3** 执行 `Tools\dev\build.bat`；检查新增视图 UTF-8 BOM、`.csproj` 登记、JSON 外层契约和无敏感信息日志。
  - _Requirements: 6.2, 6.4_
- [x] **Task 6.4** 先在目标 MySQL57 执行幂等 SQL，再部署整站，回收应用池后按验收矩阵手动验证手机/电脑端。
  - **2026-09-02 线上部署完成（WebVer 1.0.23）**：备份 `C:\Backend_backup_20260902_201631`；SQL 补丁（`Docs/sql/手机端后台权限与记录保留-20260902.sql`）已在线上 MySQL57 执行并验证（gameprizerecord 表 + 全部索引就位）；部署前库备份 `C:\mth_backup_20260902_201442.sql`。部署后 HTTP 200、定时任务日志正常无异常；Task 6.5 人工验收矩阵待执行。
  - _Requirements: 4.4, 6.1, 6.3_
- [ ] **Task 6.5** 发布验收：直属代理不能操作二级目标；整线代理可以操作整线目标；密码权限关闭无密码；创建开关默认开；记录只查 7×24 小时；冻结/禁用列表显示操作人和时间；弹窗为简短中文。
  - _Requirements: 2.2, 2.6, 3.1, 3.2, 4.1, 5.2, 5.5_

## 9. 依赖图

```json
{
  "wave0": ["0.1", "0.2"],
  "wave1": ["1.1", "1.3"],
  "wave1_tests": ["1.2 depends_on 1.1", "1.4 depends_on 1.3"],
  "wave2": ["2.1 depends_on 1.3", "2.2 depends_on 1.1", "2.4 depends_on 2.1,2.2"],
  "wave2_tests": ["2.3 depends_on 2.1,2.2"],
  "wave3": ["3.1 depends_on 1.3", "3.3 depends_on 1.1", "3.4"],
  "wave3_tests": ["3.2 depends_on 3.1", "3.5 depends_on 3.4"],
  "wave4": ["4.1 depends_on 1.1", "4.3", "4.5"],
  "wave4_tests": ["4.2 depends_on 4.1", "4.4 depends_on 4.3"],
  "wave5": ["5.1 depends_on 0.1", "5.2 depends_on 1.1", "5.4 depends_on 5.1", "5.5 depends_on 5.4"],
  "wave5_tests": ["5.3 depends_on 5.1,5.2", "5.6 depends_on 5.4"],
  "wave6": ["6.1 depends_on wave1-wave5", "6.2 depends_on 6.1", "6.3 depends_on 6.1", "6.4 depends_on 6.3", "6.5 depends_on 6.4"]
}
```

同一 wave 内没有相互依赖；Wave 1 完成后可并行推进 Wave 2、Wave 3、Wave 4，Wave 5 依赖范围策略和日志值清点。

## 11. 2026-09-03 本轮增量

- 玩家首页在线/离线列表先渲染第一页基础卡片，再异步补齐控制状态；在线接口复用可见性查询结果，减少重复数据库访问；账号搜索并发按账号和昵称查询。
- 手机端总控应用/移除以及玩家充值/退分的 `LK/UL` 指令先写入 `gamecommandoutbox`，接口返回“已受理，处理中”；电脑端继续同步等待中心服响应。充值页面输入限制为正整数，成功提示统一使用“金币”并明确充值/退分对象和数量。
- 充值记录固定只显示 `Processed=1` 的已生效流水，保留“全部/充值/退分”分类并移除备注列；会员盈亏列表和统计卡按最近 7x24 小时已生效流水计算。
- 新增复合索引 `rechargerecords(Processed,CreateTime,GameID)`；发布本轮代码前需在目标 MySQL57 执行两份幂等索引脚本（或确认该索引已存在）。
- **2026-09-03 已部署线上（WebVer 1.0.24）**：本地 Release 构建 + 契约回归（`ViewContractTest`/`AgencyRulesTest` 38/38 通过）后按既有流程打包整站上传；线上 MySQL57 已执行两份幂等索引脚本，`rechargerecords(Processed,CreateTime,GameID)` 复合索引确认就位；deploy.ps1 备份 `C:\Backend_backup_20260903_234819` 并部署，HTTP 200、公网 8081 可访问、`Web.config` 确认 WebVer=1.0.24。手机/电脑端人工验收（Task 6.5 矩阵）待执行。
- 2026-09-03 增量：控制页统计卡仅保留当前押注、今日盈亏、总盈亏；当前控制状态单行横向滚动显示，避免窄屏换行或挤压。
- 2026-09-03 增量：手机端代理级别按新称谓显示（`PRIV=1` 为“特级代理”，后续依次为 1 级、2 级代理）；手机退出显式携带 `view=mobile` 并回到 `/Login/Mobile`，桌面退出保持 `/Login/Index`。

## 12. 2026-09-12 本轮增量（返回玩家列表时刷新在线数据）

- 手机端"我的代理 / 我的会员 / 充值管理"进入即写入 `localStorage` 的 `m_players_stale` 标记；玩家列表页（在线玩家页）恢复时消费标记并重拉在线数据（头部总输赢 + 在线卡片 + 在线人数角标）。离线列表不重拉，避免把已翻到第 N 页的列表打回第一页。
- 打标记的时机只能取"进入页面"与"点返回按钮"两处，**不能放在 `pagehide`**：实测（Chromium 140）返回导航中恢复页面的 `pageshow` 先于离开页面的 `pagehide`，标记会晚一步写入、列表页看不到它（且会残留到下一次返回，造成白刷）。该结论以断言形式固化在 `ViewContractTest.MobilePlayerListRefreshesAfterReturningFromSubPages`。
- 在线人数角标改为在"暂无在线玩家"分支之前更新：原写法提前 `return`，人数会停在上一次的值。
- 验证：`Tools\dev\build.bat` Release 构建通过；`ViewContractTest` 38/38 通过；另用无后端桩页 + headless Chromium 跑通 13 项断言（进入即打标记、bfcache 恢复后恰好重拉一次在线数据、整页重载不重复请求、离线列表不重拉、标记无残留可重复刷新、非名单页面不标记）。
- WebVer 1.0.37（尚未部署）。

## 13. 2026-09-12 本轮增量（封禁/冻结记录的可见与解除口径）

- 口径从"管理范围可见"改为"按记录归属"：一条封禁/冻结记录，只有**记录的操作人本人、特级代理（`PRIV=1`，限自己整条线内）、总台（`PRIV=0`）**能查看和解除；中间任何层级都看不到——包括操作人的直接上级、被封账号的直接上级（1 级封的 2 级看不到，2 级封的 1 级也看不到）。
- 落地判据：记录的操作人 = `AgencyOptLog` 中该账号**最近一条封禁类操作**的 `OptID`（代理禁用 `OPT=24`，玩家冻结 `OPT=26`）。操作日志只保留 7 天，超期后查不到操作人的记录只有特级/总台可见可解除（操作人列显示 `--`，与现状一致）；本轮不加字段、不动表结构。
- 影响范围：手机端「禁用代理」列表与封禁记录、「冻结账号」列表、「冻结明细」里的玩家/代理行，以及对应的解除入口（代理解除禁用、玩家解冻、异常账号解封）。「冻结明细」里"连续登录失败"这类无操作人的风控行仍按原管理范围显示。
- **封禁/冻结这个动作本身的范围不变**：仍只能操作自己管理范围内的账号（`CanManageAgent`/`CanManagePlayer`，`ManageScope` 1 直属 / 2 整线）；改的只是看得见谁、能解除谁。
- 桌面端 `/Game/AgencyInfo/SetRecharge`（代理管理、权限设置页里的启用/禁用）原先既不校验权限也不写日志：既能绕过上述口径，产生的封禁记录又没有操作人（等于谁都看不到）；改为走 `B_Admin.SetAgentEnabledWithAudit`（同口径 + 写审计日志）。
- 口径只允许一处实现 `AgencyRules.CanAccessBanRecord`；纯规则用例见 `AgencyRulesTest.BanRecordAccessFollowsOperatorTopAgentAndSuperAdmin`，防回退契约见 `ViewContractTest.BanAndFreezeRecordsVisibleToOperatorTopAgentAndSuperAdminOnly`。
- 未做（需要时再提）：桌面端列表里"账号状态"列与启用/解冻按钮仍照旧渲染，越权点击由服务端拦下并提示"无权限操作！"，未做逐行隐藏；长期固化"谁封的 + 封号提示"需要给 `admin` 表加字段。
- 验证：`Tools\dev\build.bat` Release 构建通过；`AgencyRulesTest` + `ViewContractTest` 52/52 通过。走库路径未在本机实测（本机没有 MySQL/Docker 在运行，测试工程 `MySql.Data.MySqlClient` 未注册为既有环境问题）。

## 14. 2026-09-13 本轮增量（弹窗在页面滚动后点不动的修复）

- 现象（充值、控制两页最先暴露）：页面滚到中下部再点「充值 / 应用控制」弹出确认框，弹窗看着正常，但点「确定 / 取消」毫无反应；把页面滚回顶部后再点才有效。页面在顶部时一次都不会复现。
- 根因：部分老安卓内核（微信 X5 / 老 WebKit，本站已为同类问题打过 SVG 与头部按钮的命中测试补丁）给 `position: fixed` 元素做触摸命中测试时按**文档坐标**算，命中区不随页面滚动更新 —— 视觉位置在视口中央，可点区域却停在"滚动量为 0 时"的位置，两者相差正好一个滚动量。本地用页内探针复现该算法：滚动量非 0 时"文档坐标命中"与"视口坐标命中"命中的不是同一个元素。
- 修复（`phone.core.js` + `phone.css`）：`M.modal` 打开期间锁住背景滚动 —— `body` 置为 `position: fixed` 并用负 `top` 保留原视觉位置，同时把文档滚动量归零（命中区与视觉位置一致），关闭时清除样式并把滚动位置还原；弹窗会叠加（充值确认 → 结果提示），用计数配对，最后一个关闭才解锁。`.modal-overlay` 另加独立合成层（`translateZ(0)`，强制命中测试走屏幕坐标）与 `overflow-y: auto` + `.modal-content{margin:auto}`（超长弹窗可从头滚到底，原先内容超屏时顶部/底部会被裁掉且滚不到）。
- 防回退：`ViewContractTest.MobileModalLocksPageScrollSoDialogButtonsStayTappable`。
- 验证：`Tools\dev\build.bat` Release 构建通过；`ViewContractTest` + `AgencyRulesTest` 53/53 通过（全量 82 项中 58 通过、24 失败，失败仍为测试工程未注册 `MySql.Data.MySqlClient` 的既有环境问题）；另用真实 `phone.css` + `phone.core.js` 搭本地页在 Chromium 实测：滚动到页面底部打开确认框 → 锁定生效（文档滚动量 0、按钮在视口内命中测试正确）→ 点确定成功 → 嵌套结果框 → 关闭后滚动位置精确还原（1663 → 1663）；输入框弹窗自动聚焦与取消路径同样正常。
- 部署：WebVer 1.0.38，`C:\Backend`（备份 `C:\Backend_backup_20260913_141256`）；线上 `phone.core.js` / `phone.css` MD5 与仓库一致，CDN `?v=1.0.38` 已取到新内容。

## 15. 2026-09-13 本轮增量（「我的代理」按节点浏览；代理权限范围保持不变）

- 需求：**权限范围不变**（每个代理的可见范围仍是自己整条代理线），但**页面**要按节点逐级浏览 —— 根节点只列自己的直属代理、行内显示该代理的下属数量，点进某个代理（如 1688）只看 1688 的直属代理，一层层下钻。这样每屏只出现少量代理，层级更明确。
- 落地（`phone.agents.js`）：新增 `OWN_ACCOUNT`（取 `MConfig.user.accounts`），面包屑根节点与首屏加载都锚定登录账号自己 —— `loadNode(OWN_ACCOUNT, '所有代理')`。后端 `GetAgencies` 语义不变（不传 `Agency` = 权限范围全量、传了 = 该节点的直属代理）；"下级代理 N 个"本来就按权限范围内的全量代理统计，所以下钻后数量仍是真实值、可以继续点进去。
- **权限范围未做任何收窄**：`B_Admin.GetManagedAgencyAccounts` 仍是 `ManageScope` 语义（1 仅直属 / 2 全部下级；线上所有代理都是 2 = 整条代理线），总台为全部。列表/详情/启用禁用/代理充值可选代理/代理流水/异常账号/代理权限设置的范围与改动前一致；账号与邀请码搜索仍在整个权限范围内查，桌面端代理管理仍是整条线的平铺列表。
- 插曲（已回退）：本轮曾先做过一版"代理侧范围收紧为非特级仅直属下级"（`AgencyRules.IsWholeLineAgencyScope`），随 1.0.39 / 1.0.40 上线过；需求确认后已整体回退（`AgencyRules.cs` / `B_Admin.cs` / `B_Reports.cs` 回到收窄前），只在页面呈现上做节点化。
- 测试：`ViewContractTest.MobileAgentListShowsDirectChildrenOnly` 补 `OWN_ACCOUNT` 锚点断言，并锁定 `GetManagedAgencyIds(loginUser.Accounts, loginUser.ManageScope`（防止代理侧范围再被收窄）；`RechargeAgencyOptionsFollowManageScope` 恢复原名与断言。
- 验证：Release 构建通过；全量测试通过数回到既有基线（24 项走库失败仍是测试工程未注册 `MySql.Data.MySqlClient` 的既有环境问题）。

## 16. 2026-09-13 本轮增量（手机端「代理流水」不再展示无金额记录）

- 需求：手机端「代理流水」页里那些「币 / 剩余币」显示 `--` 的记录（登录、退出、封禁/解冻审计）整条不要展示，只留真正有资金变动的流水。
- 线上实况核对（`mth.AgencyOptLog` 代理 1688 当天）：`--` 行确为 `OPT=2`（登录）、`OPT=3`（退出）、`OPT=25`（解冻审计，`COINS=0/BEF=0/AFT=1`）；全表 `OPT` 取值只有 2/3/20/21/24/25/26/27，与前端 OPT 表一致。
- 口径：手机端流水页传 `MONEY_ONLY=1`，服务端按**白名单** `OPT IN (0,1,20,21,22,23)` 过滤（0/1 为历史遗留的充值/兑换）。过滤放服务端，`total` 与分页才对得上；前端过滤会出现"整页空行 + 页码虚高"。
- 落地：`M_S_Record.MONEY_ONLY` → `AgencyRecordController.GetAgencyRecords` 读表单 `MONEY_ONLY` → `B_Records_MySQL.Get_AgencyRecords` 加 `int?[] moneyOpts`（实体里 `OPT` 是可空列，用 `int[]` 编译不过）。**桌面「代理记录」不传该参数**，登录/退出明细照旧展示，口径未变。
- 测试：`ViewContractTest.AgentFlowOnlyShowsRecordsWithMoneyMovement` 新增（脚本传参、实体字段、控制器读参、BLL 白名单 + 桌面页不得带该参数）。
- 验证：Release 构建通过；全量 84 项中 60 通过、24 失败（失败仍为测试工程未注册 `MySql.Data.MySqlClient` 的既有环境问题）。
- 部署：WebVer 1.0.40，`C:\Backend`（备份 `C:\Backend_backup_20260913_165155`）。线上 11 个文件（6 个 `YYT.*.dll` + `Game.Utils.dll` + `phone.agentflow.js` + `phone.core.js` + `phone.css` + `Web.config`）的 MD5 与仓库构建产物/源码逐字节一致；80/8080/8081 与 `https://abc.12.sqrdwj.top`、`https://x.52.dyj.wang` 登录页均 200；CDN `?v=1.0.40` 取到的 `phone.agentflow.js` MD5 与仓库一致且含 `MONEY_ONLY`；改动接口未登录访问返回既有登录超时 JSON（无 500）。
- 顺带发现（**与本次改动无关的既有问题**）：后台→中心服的命名管道自 **2026-08-27** 起就没有成功过（`gamecommandoutbox` 最后一条 Acked 是 08-26 11:26，之后 LK/UL/UC/KU 全部失败、重试耗尽）。证据与修法方向见 `AGENTS.md`「已知未闭合项」第 8 条与坑清单「后台与游戏服同机」条。

## 17. 2026-09-13 本轮增量（返回玩家列表时顺手收起抽屉菜单）

- 需求：抽屉菜单展开状态下点进「我的代理 / 我的会员 / 充值管理」，点返回回到玩家列表页时，菜单要自动缩回去。
- 现象与原因：`#sidebar` / `#sidebarOverlay` 的展开态就是 DOM 上的 `active` 类，返回导航多为 bfcache 恢复、DOM 原样保留，菜单会一直盖在列表上；遮罩的 `active` 还会吃掉列表区域的点击（点哪都没反应，得再点一次菜单按钮）。
- 落地：`phone.core.js` 的 `pageshow` 处理里加 `M.closeDrawer()`（首次加载与 bfcache 恢复都走这里；首屏本来就收起着，等于 no-op）。抽屉 DOM 只在玩家列表页存在，其他页面是空集合，调用安全。
- 验证：Release 构建通过；`ViewContractTest` 41/41；用无后端桩页 + headless Chromium 跑 11 项断言（展开抽屉 → 从抽屉点进「我的代理」→ 点返回：抽屉与遮罩都收起、在线数据恰好重拉一次、刷新标记无残留、可重复），并做了反向对照——把 `M.closeDrawer()` 那行去掉后抽屉断言立刻 FAIL（`sidebar active`），证明用例能真抓到这个问题。
- WebVer：随当前工作区版本（`Web.config` 1.0.40）一起发布，未单独升版本。

## 18. 2026-09-13 本轮增量（控牌牌型口径：牌机去杂牌/大四梅，拉霸补全并按 2000 倍封顶）

- 需求：①所有牌机去掉 0 倍杂牌选项；②大字、NBA、ATT、金皇冠去掉大四梅选项；③补全拉霸类型的控牌牌型（拉霸牌型=「名称(倍数)」的简化写法，不要复杂描述）；④赔率超过 2000 倍的选项一律去掉。
- 现状核对：控牌下拉是**前后端各自硬编码**（数据库 `cardpayoutprofile` 只存每桌出现概率，不生成选项）。电脑端 `valSelDataPAIJI` 早已去掉杂牌(0)/五鬼(12)、大四梅(8) 只留火凤凰(14)，①②在电脑端已成立；手机端 `cardTypeDataForPaiji` 只过滤了"大字板+五鬼"，仍会出现「杂牌(0倍)」和所有游戏的「大四梅」。手机端拉霸三套列表还是 8 月底的旧口径：水浒传/明星97 只有 0-8 符号值（最高 30/80 倍），水果拉霸带"面板X ·"前缀且未按倍率排序。
- 落地（`phone.core.js`）：牌机过滤与电脑端对齐（`t.ht == 0 || t.ht == 12` 跳过、大四梅仅 `action == 14`）；水浒传换结果类 code 400-407/410-417/420-427/430-432/44x/450/451（共 34 项）、明星97 换 300-350 全量（30 项）、水果拉霸补 24 面板位（去前缀、按倍率升序）。旧控牌值仍要能回显：新增 `SHZ_LEGACY`（0-7=中间行五连符号）/`MX97_LEGACY`（0-8=单线三连符号），`M.cardTypeName` 对隐藏牌型（杂牌0/大四梅8/五鬼12）按该游戏倍率表回退，与电脑端 `labaTypeName` 同口径。
- 「超过 2000 倍去掉」的口径：拉霸全屏类倍率按**全屏奖+线奖叠加后的总赔率**显示（沿用 09-03 的 bd478e6 口径）。水浒传因此只到全屏·林冲 1840 倍，440(14000)/441(11500)/442(4600)/443(2300) 不下发；明星97 最高 660 倍、水果拉霸最高 120 倍，均未触顶。
- 文案简化：`纯万能线·3连(按忠义堂50倍)` → `纯万能线·3连(50倍)`；电脑端「在线用户」页此前残留的 `全屏·斧(50+180倍)`/`全屏·枪(100+360倍)` 统一为叠加后的 `230倍`/`460倍`（与玩家管理页一致）；水果拉霸去掉"面板X ·"前缀。
- 顺带清理：删除电脑端两个视图里的 `valSelDataPAIJI2/3` 死代码（含「杂牌(0倍)」「大四梅(65倍)」字面量，无调用点）。
- 测试：新增 `ViewContractTest.CardControlOptionsHideZeroPairAndJackpotsOverTwoThousand`（三处牌机过滤、`id: 440..443` 不得出现、拉霸 code 齐备、旧文案不得回归）；反向对照——把手机端过滤行临时改回旧条件后该用例立刻 FAIL，证明能抓回退。
- 验证：Release 构建通过；`ViewContractTest` 42/42；全量 84 项 60 通过、24 失败（失败仍为测试工程未注册 `MySql.Data.MySqlClient` 的既有环境问题）。
- 部署：**WebVer 1.0.42 已上线**（2026-09-13，`C:\Backend`，备份 `C:\Backend_backup_20260913_223905`）。线上 `Web.config`/`phone.core.js`/`UserInfo/Index.cshtml`/`UserInfo/OnlineUsers.cshtml`/`bin/YYT.Web.dll`/`bin/YYT.BLL.dll` 六个文件的 MD5 与仓库源码/构建产物逐字节一致；CDN `?v=1.0.42` 取到的 `phone.core.js` MD5 一致且含 `SHZ_LEGACY` 与新列表，旧文案「水浒传龙标」「面板X ·」已无；服务器本机 80/8080/8081 与 `https://abc.12.sqrdwj.top`、`https://x.52.dyj.wang` 登录页均 200（公网直连 8080 仍按设计被防火墙丢弃）；未登录调用 `ApplyTotalControl` 返回既有登录超时 JSON（无 500）；**`aspnet_compiler` 在站点副本上全站预编译无错误**（两个改动的桌面视图因此确认 Razor 语法可用，仅既存 CS0162 警告）。
- 追加修复（2026-09-14）：水果拉霸 24 面板位里 **9/21 是两个不同的送灯位**（9→免费局 1~3 次、21→免费局 3~6 次，见 `ConfigEditor` 的 `GC_LABA_WHEEL_META` 与机台设定面板表），控牌下拉里原来都写成「送灯位(免费局)」，运营分不出是哪一个。已按机台设定的同名口径改成 **「送灯位·免费局 1~3 次」/「送灯位·免费局 3~6 次」**（`phone.core.js` + 两个桌面视图三处同步，仍在排序末尾按面板位 9→21 排列）。契约测试补两条断言并禁止旧文案回归。**WebVer 1.0.43 已上线**（2026-09-14，备份 `C:\Backend_backup_20260914_025434`）：线上 5 个文件（`phone.core.js`/`Index.cshtml`/`OnlineUsers.cshtml`/`Web.config`/`YYT.Web.dll`）MD5 与仓库一致，CDN `?v=1.0.43` 一致且含两个新文案，80/8080/8081 与两个域名登录页 200，`aspnet_compiler` 副本预编译 `exit=0`。

## 19. 2026-09-14 本轮增量（手机端「控制牌型」改成默认向上展开）

- 需求：控制牌型的下拉要默认向上展开；目前牌机是向下展开，长列表有可能点不到后面的牌型。
- 原因：手机端控制页的「控制牌型」是原生 `<select>`，它和「应用控制」按钮一起在页面最底部 —— 原生弹出列表只会向下展开，牌机 11 项 / 水浒传 35 项的列表会被屏幕底部裁掉，后面的牌型点不到（桌面浏览器模拟器里同样如此，Chrome 的 `<select>` 弹出框不参与页面渲染，无法靠页面滚动补救）。
- 落地（`phone.core.js` + `phone.css` + `phone.control.js`）：新增 `M.upwardSelect($sel)` —— 把 select 换成「按钮 + 页面内浮层」：**默认向上展开**，上方空间不足（<160px）且下方更宽敞才向下；浮层高度取 min(可用空间, 60vh) 且不超过视口，长列表内部滚动；当前项高亮并自动滚到可见处；点外部/再点字段收起。**原生 select 保留为取值与 `change` 事件的唯一来源**（只是 `display:none`），`.val()` / `.trigger('change')` 语义不变，所以 `fillSelect` 重建选项后调 `M.upwardSelectRefresh` 同步按钮文案（已内联进 `fillSelect`）。`phone.css` 补 `.upsel*` 样式（浮层带 `overflow-y:auto` + `translateZ(0)` 独立合成层，沿用弹窗命中测试的老安卓处理）。目前只用在「控制牌型」，「游戏类型/控制类型」仍是原生 select。
- 测试：`ViewContractTest.MobileCardTypeSelectOpensUpwardAboveTheField`（组件/调用点/样式契约）；另用**无后端桩页 + headless Chromium（360×640）跑 22 项断言**：原生 select 已隐藏、按钮文案=首项、面板默认在字段上方且整体不出屏、项数=牌型数、点「同花顺(150倍)」后 select 取值=9 且 change 恰好 1 次、选完自动收起、点外部收起、再点收起、上方空间不足时向下、长列表（水果拉霸 25 项）高度封顶+内部滚动+当前项自动滚到可见。反向对照：去掉 `M.upwardSelect($('#ctrlCardValue'))` 调用后该用例立刻 FAIL。
- 验证：Release 构建通过；`ViewContractTest` 43/43；全量 85 项 61 通过、24 失败（失败仍为测试工程未注册 `MySql.Data.MySqlClient` 的既有环境问题）。
- 部署：**WebVer 1.0.44 已上线**（2026-09-14，备份 `C:\Backend_backup_20260914_031033`）：线上 `phone.core.js`/`phone.control.js`/`phone.css`/`Web.config`/`bin/YYT.Web.dll` 五个文件 MD5 与仓库一致；CDN `?v=1.0.44` 取到的三份资源 MD5 一致且含 `M.upwardSelect`；服务器本机 80/8080/8081 与 `abc.12.sqrdwj.top`、`x.52.dyj.wang` 登录页均 200。本轮未改 `.cshtml`，无需视图预编译。

## 20. 2026-09-16 本轮增量（运营反馈 9 项问题的排查与修复）

运营在线上（8.218.67.82，测试数据）反馈 9 条问题。逐条定位后：**8 条是后台代码缺陷**（已修复并上线 1.0.45），**1 条（中奖历史）根因在中心服未写表**，另有 1 条口径缺陷是排查过程中额外发现的（代理维度盈亏聚合恒为 0）。

### 20.1 定位方式（可复现）

- 用 `atmadmin/123456` 直连线上后台接口做只读复现（`/zh-CN/Login/Mobile` 取防伪令牌 → POST 查询接口），把线上库全量 `mysqldump` 导入本地 MySQL 5.7 容器（`mth-mysql`）后，在本地用探针程序 + IIS Express 复现并验证，避免改动线上数据。
- 探针：`Tools/one-off/_efprobe/Probe.cs`（引用 `TTY.Web/bin` 的 YYT.BLL/Entity/EF6/MySql.Data，直连库调 `B_Users` 方法，打印异常与内部异常），配置 `Probe.exe.config` 的连接串指向本地库；线上对比用 `Docs` 里的接口探测脚本思路（POST + 防伪令牌）。

### 20.2 逐条结论

1. **充值退分有延迟** —— 手机端充值把 `LK`/`UL` 只写进 `gamecommandoutbox` 等定时重试下发（定时器 60s），充值金额最长要等一分钟才在游戏内生效。修复：`B_Recharge.LockUser/UnLockUser` 去掉手机端排队分支，**电脑端/手机端统一直发**，失败仍由发件箱 + 重试服务兜底（`MobileRequest` 仅保留为排查日志字段）。同类问题一并修掉：`B_UserControl.ApplyTotalControl/CloseTotalControl` 的 UC 指令也不再只排队（否则手机端点"应用控制"最长 60s 才生效），发送结果不改变接口语义（DB 已落库即成功，与电脑端一致）。
2. **在线玩家点玩家提示"获取不到玩家"** —— 复现：`/Game/UserInfo/GetVisibleUserRows` 对**在线玩家**恒返回 `{"code":0,"content":"刷新失败！"}`。根因：`B_Users.FillCurrentPlayInfo` 的回表投影写成了 `Select(c => new M_UserOptLog{...})`，**EF6 禁止在 LINQ to Entities 里构造实体类型**，抛 `NotSupportedException` 被 catch 吞掉、只留 code 0（该写法由性能优化提交 b027bd8 引入）。修复：投影改匿名类型，实体对象留到内存里组装。
3. **在线卡片 场次/机台号/押注/控制状态显示异常** —— ①押注：0.1 分炮鱼机内部单位是 0.1 分，电脑端 `isDecimalBetFish` 会 ÷10 保留 1 位小数，手机端直接 `M.gold` 显示，0.1 分显示成 1；新增 `M.betGold(v, gameId)`（与电脑端同一份游戏 ID 列表，契约测试卡同步）。②场次/机台号：服务端下发 0 基下标，电脑端一律 +1（`N号桌`），手机端显示 0，改为 +1。③控制状态：手机端把 `ConsumedCoins` 取反显示，`已吃分 2608` 变成 `已吃分 -2608`（控制页/玩家详情页同样取反），改为与电脑端一致的原样展示。
4. **中奖历史没有数据** —— `gameprizerecord` 线上 **0 行**，旧服 9/11 迁移导出里也没有任何该表 INSERT：**中心服从未写入过这张表**（接口/页面口径正确，`Docs/手机端中奖历史数据契约-20260901.md` 要求的写入方是游戏中心服）。属服务端待办，后台侧无改动。
5. **玩家盈亏数据异常** —— ①在线卡片的总输赢优先取游戏服 QA 的 `TotalWinLoss`（本局/本次在线口径，线上实测同一时刻为 -136610），与离线卡片、电脑端、会员盈亏的"实际游戏输赢"（同时刻 -6638）对不上；改为统一取 `Profit`。②离线列表的总输赢被 `UserInfoController.GetOfflineUsers` 用"充值-退币差额"覆盖（aa1122 显示 +21474，实际游戏输赢是 -12085）；`GetOfflineUsersList` 改走 `gameWinLossProfit=true`（SUM `user_daily_winloss`）并删除控制器里的覆盖。
6. **会员盈亏详情统计错乱** —— ①总充/总退把"总台给代理充值"也算成会员的：`rechargerecords` 里代理充值的 `GameID` 是代理账号（admin 表），若该账号名下恰好也有玩家行（线上 a1314 就是），按 `users.ID` 关联时会被计入；四段充退 SQL 全部加 `AND NOT EXISTS (SELECT 1 FROM admin ra WHERE ra.ID = <流水>.GameID)`。②排查中发现更严重的口径错误：代理维度盈亏聚合 `INNER JOIN UserRelations r ON r.UserID = w.UserID` —— `userrelations.UserID` 是数字平台 ID，与 `user_daily_winloss.UserID`（账号串）比较**恒不相等**，非超管看到的"今日总输赢/会员盈亏统计卡"永远是 0；改为直接 `INNER JOIN Users u ON u.ID = w.UserID`（`GetTodayTotalWinLoss`、`GetMemberWinLossStats` 两处）。
7. **用户管理里用户一会在一会不在** —— 与第 2 条同根因：只要列表里有在线玩家，`FillCurrentPlayInfo` 就抛异常，桌面端"用户管理/在线玩家"整页变空；没人在线时又正常，表现为"一会有一会没有"。第 2 条修复后一并解决（线上实测：修复前 `/Game/UserInfo/GetUsers` 返回 `total:0`，修复后返回 3 行）。
8. **代理看不到非直属会员** —— 手机端"我的代理 → 我的会员 → 查看"进来的会员页默认 `IncludeDescendants=0`（只出直属会员），与代理权限范围（`admin.ManageScope=2` 整条线）不一致；改为**默认整线**（范围为"全部会员"，按钮变成"仅看直属"可收窄），直接进会员盈亏页（无 `?agency=`）行为不变。
9. **总台/代理看不到代理密码** —— `AgencyInfoController.GetAgencies` 在权限判定之前无条件 `item.PWD = null`，后面的按权限脱敏形同虚设，**任何人都看不到代理密码**（含总台）。删除该行，只保留"超管可见 / 非超管需要 `IsViewAgentPwd=1` 且目标在管理范围内"的判定。

### 20.3 测试与验证

- 新增 7 个契约用例：`PlayerLookupQueryNeverProjectsEntityTypes`、`MobilePlayerCardShowsRealWinLossDecimalBetAndOneBasedPosition`、`MobileControlProgressIsNotNegated`、`MobileListsUseGameWinLossProfitAndExcludeAgentRecharges`、`MobileRechargeSendsLockUnlockImmediately`、`AgentPasswordVisibilityFollowsPermission`、`MobileMemberPageDefaultsToWholeLine`；同时更新旧的 `MobileFastPathAndEffectiveRechargeContractsRemainWired`（原来断言手机端必须走队列，现改为断言直发）。
- `Tools\dev\build.bat` Release 通过；`vstest` 全量 92 项 **68 通过 / 24 失败**（失败仍为测试工程未注册 `MySql.Data.MySqlClient` 的既有环境问题，与本次改动无关）。
- 本地端到端（IIS Express + 本地库）：在线卡片渲染断言 —— `神龙宝藏 1场 机台号1 押注0.1 今日输赢+6268 总输赢+6268`、`火凤凰 2场 机台号4 押注30 控制状态 吃分中... 目标 5555 已吃分 2608`（截图存本轮会话）；`M.betGold` 在 node 上单独跑 10 组断言（鱼机 `1→0.1`、非鱼机不变、真金版两位小数）；会员页 `?agency=b1314` 默认"全部会员"且列表含二级下级会员 p_c1314；代理 b1314 视角"今日总输赢"由 0 变 333。
- 线上（1.0.45）只读复验：`GetVisibleUserRows` 对在线玩家返回 code 1；`GetUsers` 由 0 行变 3 行；`GetAgencies` 总台可见 `PWD`；`GetMemberWinLossStats` 总充由 2,255,198 降到 245,197（排除 200 万代理充值）。

### 20.4 部署

- **WebVer 1.0.45 已上线**（2026-09-16 23:52，备份 `C:\Backend_backup_20260916_235236`，`deploy.ps1 -SourcePath TTY.Web_1.0.45.zip -Yes -Port 8080`）。
- 8 个文件 MD5 与仓库/构建产物逐字节一致：`Web.config`、`bin/YYT.Web.dll`、`bin/YYT.BLL.dll`、`Scripts/app/phone/phone.core.js`、`phone.players.js`、`phone.control.js`、`phone.playerdetail.js`、`phone.huiyuan.js`。
- CDN `abc.12.sqrdwj.top` 上 `?v=1.0.45` 的三份脚本（core/players/huiyuan）MD5 与本地一致且含 `M.betGold`/`全部会员`；80/8081/`abc.12.sqrdwj.top` 后台登录页 200，`x.52.dyj.wang/Login/Mobile` 302（既有行为），公网直连 8080 仍按设计被防火墙丢弃。
- 本轮未改 `.cshtml`，无需视图预编译。
- **已入库**：本轮（§20，1.0.45）连同 §18–§19 积压的 1.0.42–1.0.43–1.0.44 三轮改动，共四轮于 2026-09-17 一次性提交到 `Add-Phone-Support`；同日复核线上 `C:\Backend` 与仓库工作区 **1528 个文件 MD5 全一致**（线上仅多一个迁移留档 `Web.config.orig_before_migration`），CDN `?v=1.0.45` 取到的资源即这一份，故未重发部署。

### 20.5 未闭合

- **中奖历史仍会是空的**，直到中心服实现 `gameprizerecord` 写入（第 4 条，服务端仓库）。
- 线上 `Web.config` 的 `UploadPath=D:\Uploads` 在新机（只有 C 盘）不存在，上传类功能会失败；仓库与线上一致，需确认改到 `C:\Backend\Upload` 后再改（本轮未动，避免与运营确认前改变现状）。

## 21. 2026-09-17 本轮增量（手机端充值页取不到代理账号的「剩余分数」）

**现象**（运营截图，线上 1.0.45）：充值管理页「角色类型=下级代理」查询 a1314，**剩余币 1988699 正常、剩余分数恒为 `--`**；同一页面查玩家时两行都有值。

**根因**：`phone.recharge.js` 的代理分支把分数硬编码成 `null`：

```js
return row ? { coins: Number(row.COINS || 0), score: null } : null;      // 代理：永远是 null
$('#accountScore').text(info.score === null ? '--' : M.num(info.score));  // 于是永远显示 --
```

数据侧并不缺：`/Game/AgencyInfo/GetAgencies` 本来就在同一次查询里下发 `RemainingScore`（`AgencyInfoController` 用 `users.GAME_SCORE` 按 `AGENCY` 分组求和），前端没有取。

**口径**（与既有页面一致，未新造概念）：代理的「剩余分数」= 该代理**直属玩家** `users.GAME_SCORE` 合计，即列表接口的 `RemainingScore`，与手机端「代理详细信息」弹窗的「剩余分」、`GetAgencyDetail` 同一口径（仅直属、不含更深层级的分）。玩家仍取 `users.GAME_SCORE`。

**修复**：只改 `TTY.Web/Scripts/app/phone/phone.recharge.js`（2 行）——代理分支返回 `score: Number(row.RemainingScore || 0)`，渲染去掉只给代理走的 `--` 分支。**无服务端改动**（接口本来就返回该字段）。

### 21.1 测试与验证

- 新增契约用例 `MobileRechargeQueryFillsAgentScoreFromRemainingScore`：锁住「代理取 `RemainingScore`、玩家取 `GAME_SCORE`」，并断言不得再出现 `score: null` 与 `info.score === null`（否则代理又会退回 `--`）。
- `Tools\dev\build.bat` Release 通过；全量 `vstest` **93 项 69 通过 / 24 失败**（失败仍是测试工程未注册 `MySql.Data.MySqlClient` 的既有环境问题，比 §20 多出的 1 项即本次新增用例）。
- Node 桩件跑改动后的模块（`node --check` + 桩件捕获请求与渲染）：代理 a1314 → `剩余币 1988699 / 剩余分数 1`；代理名下无玩家 → `0`（不再 `--`）；玩家 a1401 → `1484 / 4`。

### 21.2 部署与线上复验（WebVer 1.0.46）

- 2026-09-17 19:11 部署（备份 `C:\Backend_backup_20260917_191101`，`deploy.ps1 -SourcePath TTY.Web_1.0.46.zip -Yes -Port 8080`），部署后 8080 探测 HTTP 200。
- `C:\Backend\Scripts\app\phone\phone.recharge.js` 与仓库 **MD5 逐字节一致**（`1b88489fe318a12b23c17e9d5c9b9d0a`），`C:\Backend\Web.config` WebVer=1.0.46；CDN `abc.12.sqrdwj.top/Scripts/app/phone/phone.recharge.js?v=1.0.46` 取到的正是这一份（同 MD5，含 `RemainingScore` 赋值行）。
- 线上页面 HTML 已引用 `phone.recharge.js?v=1.0.46`（`/Mobile/Home/Recharge?id=a1314&role=agent` → 200）。
- 用总台只读会话复验接口（`atmadmin/123456`，`/zh-CN/Login/Mobile` 取防伪令牌后 POST）：`GetAgencies(ID=a1314)` → `COINS=1988699, RemainingScore=1`；`GetVisibleUserRows(["a1401"])` → `GAME_SCORE=4`。即运营再查 a1314，剩余分数会显示 **1**。
- 本轮只改 1 个 JS + `Web.config`（版本号），未改 `.cshtml`，无需视图预编译；80/8081 探测 200。

### 21.3 未闭合

- **充退/查询期间游戏服栈被整体停止过一次（与本轮部署无关，备查）**：部署后 19:15–19:17 后台日志出现 `QA transport failure: 无法连接中心服管道（管道尚未连接）`（QA = 玩家列表的在线玩家查询）。查 daemon 日志 `C:\Server\ServerManager\x64\Release\MTH_Daemon.log`：**19:12:54 是「优雅停止」整个游戏服栈**（21 个子游戏 + CenterServer，`[INFO] 尝试优雅停止: …` → `[SUCC] CenterServer 已优雅退出。`），**19:19:29 才重新启动**（`启动成功: CenterServer [PID: 5928]`，随后 21 个子游戏），期间在线玩家会被踢下线、后台查在线玩家必然失败；19:27 复验 QA 指令已正常下发（日志 `指令内容：QA`），管道正常。`C:\Server\dumps` 无崩溃转储 → 是**主动停止**而非崩溃。本轮后台部署只回收了 IIS 应用池、未触碰 `C:\Server`。**看 19:15–19:19 的后台日志别误判成后台回归。**
- **充值页代理分支取的是模糊匹配结果的 `rows[0]`**（`GetAgencies` 的 `ID` 是 `LIKE '%kw%'`，行序按代理树排列）：运营习惯输入完整账号，实测命中正确（本轮复验 `rows` 只有 a1314 一行），但输入片段时有显示到别的账号余额/分数的风险（玩家分支是精确匹配）。本轮未改，待运营确认是否要统一成精确匹配。
- 本轮改动**已部署但未入库**（`Add-Phone-Support` 工作区：`phone.recharge.js`、`ViewContractTest.cs`、`Web.config`），需与后续轮次一起提交。

## 22. 2026-09-17 本轮增量（手机端玩家详情页「总盈亏」口径错误）

**现象**（运营截图，线上 1.0.46）：手机端「玩家详细信息」页（`/Mobile/Home/PlayerDetail?account=a1403`），账号 a1403 **今日充值 30000 / 今日退分 2000 / 今日盈亏 -4000**，但底部「总盈亏」显示 **+28000** —— 恰好等于「总充值 30000 - 总退分 2000」。运营口径：总盈亏只应统计玩家玩游戏产生的输赢，没玩过就是 0。

**根因**：`phone.playerdetail.js` 前端自己拿充退累计现算盈亏：

```js
setSigned('#dTotalWinLoss', Number(d.COINS_BUY || 0) - Number(d.COINS_BACK || 0));   // 资金差额，不是游戏输赢
```

即 §20 第 5 条修「离线列表被控制器用充退差额覆盖」时漏掉的最后一处同类问题（在线卡片/离线卡片/会员盈亏/控制页统计卡当时都改成了 `Profit`，只有玩家详情页还是前端现算）。

**修复口径**（与既有页面一致，未新造概念）：总盈亏 = 实际游戏输赢 = `SUM(user_daily_winloss.WINLOSS)`（赢正输负），即列表页的 `Profit`。改动四层，缺任一段前端都只会拿到 `undefined` 显示 0：

| 层 | 文件 | 改动 |
|---|---|---|
| 实体 | `YYT.Entity/EF/M_Users.cs` | `M_UserPhoneDetail` 增加 `TotalWinLoss` |
| 数据 | `YYT.BLL/EF/B_Users.cs` | `GetUserPhoneDetail` 的 SQL 增加 `(SELECT IFNULL(SUM(w2.WINLOSS),0) FROM user_daily_winloss w2 WHERE w2.UserID = c.ID) AS TotalWinLoss` |
| 接口 | `TTY.Web/Areas/Game/Controllers/UserInfoController.cs` | `GetUserDetail` 下发 `detail.TotalWinLoss` |
| 前端 | `TTY.Web/Scripts/app/phone/phone.playerdetail.js` | `setSigned('#dTotalWinLoss', d.TotalWinLoss)`，删掉充退差额算法 |

「今日充值/今日退分/总充值/总退分」四行仍是资金口径（本就是这个含义），未动。

### 22.1 测试与验证

- 新增契约用例 `MobilePlayerDetailTotalWinLossIsGameWinLoss`：锁住「前端不得再出现 `Number(d.COINS_BUY || 0) - Number(d.COINS_BACK || 0)`」「必须 `setSigned('#dTotalWinLoss', d.TotalWinLoss)`」，并同时断言 SQL 子查询、`M_UserPhoneDetail.TotalWinLoss` 字段、控制器下发三段都在（防止只改一头）。
- `Tools\dev\build.bat` Release 通过；`vstest` 过滤 `ViewContractTest` **52 项全通过**。全量失败项仍是测试工程未注册 `MySql.Data.MySqlClient` 的既有环境问题。
- Node 桩件跑改动后的模块（假 `window.MApp` + jQuery 桩，捕获 `#dTotalWinLoss` 的写入）：充 30002/退 2000 + 游戏输赢 -4000 → `-4000`（红色，不再是 +28002）；游戏赢 63035 → `+63035`（绿色）；无 `user_daily_winloss` 记录 → `0`；字段缺失 → `0`。
- **线上只读 SQL 验证**（`Tools/one-off/_prod_run_sql.ps1`，按 C# 实际拼接的整条详情 SQL 跑）：`a1403` → `BuyMinusBack=28002` vs `TotalWinLoss=63035`（带 `Days=1`，与今日一致）；`aa1122` → `64807` vs `-55698`。语法在 MySQL 5.7 上通过、值符合口径。
- 部署后**线上接口实调复验**（总台只读会话，`Tools/one-off/_probe_online_detail.ps1`）：`GetUserDetail(a1403)` → `code=1, TotalWinLoss=71450`（同刻 `COINS_BUY-COINS_BACK`=28002）；`a1401` → `2813`；`aa1122` → `-55698`。即页面上的总盈亏从此与在线/离线卡片、会员盈亏、电脑端同一口径。

### 22.2 部署与线上复验（WebVer 1.0.47）

- 2026-09-17 22:04 部署（备份 `C:\Backend_backup_20260917_220422`，`deploy.ps1 -SourcePath TTY.Web_1.0.47.zip -Yes -Port 8080`），部署后 8080 探测 HTTP 200。
- 5 个关键文件 MD5 与仓库/构建产物逐字节一致：`Scripts/app/phone/phone.playerdetail.js` = `52b26ecb738122958a088feea17c31b8`、`bin/YYT.BLL.dll` = `10a40ca690e96b8edf42ed2747b5a132`、`bin/YYT.Web.dll` = `53a3d730e0631b30df2c0482f8296797`、`bin/YYT.Entity.dll` = `b6674385e01e38da108b6242568931b2`、`Web.config`（WebVer=1.0.47） = `f83bdfe72acf90bf4b56db9c21a357be`。
- CDN `abc.12.sqrdwj.top/Scripts/app/phone/phone.playerdetail.js?v=1.0.47` 取回内容 MD5 与本地一致（含 `setSigned('#dTotalWinLoss', d.TotalWinLoss);`）；线上页面 HTML 已引用 `phone.playerdetail.js?v=1.0.47`（`/Mobile/Home/PlayerDetail?account=a1403` → 200）。
- 本轮未改 `.cshtml`，无需视图预编译；部署后 `C:\Backend\Logs\yyt_20260917.log` 为空（无异常）。

### 22.3 未闭合

- 本轮（1.0.47）与上一轮（1.0.46）**均已部署但未入库**，需一起提交（改动文件见 AGENTS.md「分支现状」）。
- 运营截图里的「总盈亏」数值随测试玩家继续游戏已变化（a1403 今日由 -4000 变为赢），复验时请以同一时刻的接口返回为准，不要拿旧截图对数字。

## 23. 2026-09-18 本轮增量（「最后登录」在玩家在线时不更新）

**现象**（运营截图，线上 1.0.46/1.0.47）：玩家列表的在线卡片上，「最后登录」不是本次登录时间；运营原话「玩家在线的时候这里是没有登入时间的显示，只有在离线玩家的时候，才会显示出来登录时间」。

**根因**（读游戏服源码 + 线上库实况确认）：后台的「最后登录」一直取 `useroptlog` 的 `MAX(REC_TIME)`，而这张表**根本没有登录事件**——游戏服 `SaveUserLog` 只在四处写它（`ServerCenterNew/ServerCenterRun.cpp`）：

| OPT | 写入时机 | 调用点（游戏服源码） |
|---|---|---|
| 0-6 | 充值/兑换/赠送/扣币（type 即 OPT） | `ServerCenterRun.cpp:1449`、`:1574` |
| 8 | 进入桌台（坐下） | `ServerCenterRun.cpp:7825` |
| 7 | 离开桌台（带本局盈亏结算） | `ServerCenterRun.cpp:4784` |
| 99 | 回退玩家临时分数 | `ServerCenterRun.cpp:10312`、`:10328` |

线上 7 天窗口内 `useroptlog` 的 OPT 取值只有 0/1/3/7/8（`OPT=3` 是"减金币"的兑换类型，不是退出）。于是：

- **在线玩家**显示的是「最后一次进桌台的时间」——人一直坐在桌上就不动（实测 a1403 09-17 19:48:36 进桌、20:51 换桌，卡片就一直显示上一次进桌的时刻），看着就是"登录时间不更新"；
- 只在大厅挂机（没进桌台）的玩家显示上一局的旧时间，7 天内无记录的账号显示前端兜底 `2000-01-01`；
- **离线玩家**的最后一条记录恰好是"离开桌台"，时间看着像"最近一次上线"，所以运营得出"只有离线玩家才显示登录时间"。

**修法**（不改游戏服：不重启中心服/子游戏，不踢在线玩家）：玩家上线时游戏服一定会写 `users.INHALL`（HallLogin → `SetUserOnlineImmediate`，20s 脏检查兜底），因此在库内挂触发器把 0→1 的瞬间记进新表，后台优先读它：

| 层 | 文件 | 改动 |
|---|---|---|
| SQL | `Docs/sql/玩家登录时间-20260918.sql`（副本 `docker/mysql/init/41_玩家登录时间.sql`） | 建 `userloginrecord(ID, LoginTime)` + `users` 表 `AFTER UPDATE` 触发器：`INHALL` 0→1 时插一条；体内带 `CONTINUE HANDLER FOR SQLEXCEPTION`，**触发器内任何异常都被吞掉，不可能影响游戏服对 users 的写入** |
| 接口 | `TTY.Web/Areas/Game/Controllers/UserInfoController.cs` | `FillPlayerLastLogin`：先查 `userloginrecord`（在线卡片/在线列表），查不到的账号再查 `useroptlog` 兜底；登录记录查询单独 try/catch，补丁表缺失也只是回退旧口径 |
| 数据 | `YYT.BLL/EF/B_Users.cs` | 离线列表 `QueryUsersPaged` 与玩家详情 `GetUserPhoneDetail`：`COALESCE(lr.LastLoginTime, l.LastLoginTime)`，排序也用同一表达式 |
| 前端 | 无改动 | `phone.players.js` 仍只渲染服务端下发值（在线/离线同一条渲染路径） |

SQL 补丁 2026-09-18 02:49 已在线上 mth 库执行（幂等）；WebVer 1.0.48 于 03:01 部署。

### 23.1 测试与验证

- 新增契约用例 `PlayerLastLoginComesFromLoginRecordWithUserOptLogFallback`：锁住「补丁表 + 触发器 0→1 条件 + CONTINUE HANDLER 兜底」「控制器两段查询」「离线列表 COALESCE 与排序同表达式」「详情页同口径」，防止以后有人只改一头。
- `msbuild TTY.Web/YYT.Web.csproj` + `UnitTestProj` Release 构建通过；`vstest --TestCaseFilter:FullyQualifiedName~ViewContractTest` **54 项全通过**（含本轮新增 1 项）。
- **触发器线上实弹验证**（`Tools/one-off/_probe_login_trigger.sql`，事务 + ROLLBACK，零残留）：对真实 `users.test02` 模拟游戏服语句 `UPDATE users SET INHALL=b'1'` →
  - INHALL `0→1` 记 1 条登录（`2026-09-18 02:50:41`）；
  - `1→1` 不重复（同一秒内重复上线被 `uk_userloginrecord_user_time` 去重，MAX 仍是同一时刻）；
  - 期间 `ROLLBACK` 后 `userloginrecord` 0 行、`INHALL` 回到 0，确认不留痕。
- **接口线上实弹验证**（`Tools/one-off/_probe_lastlogin_api.ps1`，只读会话 atmadmin）：
  - 无登录记录时（现状）：`GetOfflineUsers`/`GetUserDetail` 回落 `useroptlog` 口径（a1403 = `09-17 16:44:28` UTC = 本地 00:44:28），列表顺序不变；
  - 临时插入 `a1403 = 2026-09-18 03:05:00` 后：离线列表与 `GetUserDetail` 都变成 `09-17 19:05:00` UTC（= 本地 03:05），**且 a1403 被排到列表第一位**（排序也走同一表达式）；随后 DELETE 还原，接口回到 `16:44:28`，表 0 行。
  - `GetOnlineUsers` 复验 `{"code":1,...,"datas":[]}`（此刻无人在线），未因本轮改动异常。
- 部署核对：`Web.config`/`bin/YYT.Web.dll`/`bin/YYT.BLL.dll`/`bin/YYT.Remote.dll`/`Scripts/app/phone/phone.players.js` 五个文件线上与构建产物 MD5 逐字节一致（`d3dd2d21…`/`a8b34ebb…`/`77b71057…`/`7c5f6d8b…`/`0457aa02…`）。

### 23.2 部署（WebVer 1.0.48）

- 2026-09-18 03:01 部署（备份 `C:\Backend_backup_20260918_030146`，`deploy.ps1 -SourcePath TTY.Web_1.0.48.zip -Yes -Port 8080`），部署后 8080 探测 HTTP 200。
- **1.0.48 同时包含本轮之前的未入库改动**（在线玩家接口快速失败/管道读超时/线程池兜底）——这批改动此前只差一次部署，本轮一并上线；完整根因、证据与验证见第 24 节。
- 本轮未改 `.cshtml`，无需视图预编译。

### 23.3 未闭合

- **触发器的"真实登录"尚未观察到**：补丁 02:49 上线后到 03:09 线上无玩家登录（`userloginrecord` 0 行）。验证方法（下次有人登录后执行）：`SELECT * FROM userloginrecord ORDER BY LID DESC LIMIT 5;`，或直接看手机端玩家列表该玩家的「最后登录」= 本次登录时间。若长时间无记录：`SHOW TRIGGERS` 确认 `trg_users_login_record` 在，再看游戏服日志有无 `UpdateUserInHall !@@@@ ERR`。
- **数据库迁移/导出必须带 `--triggers`**（线上 09-11 迁移用的 `mysqldump --routines --triggers` 已满足）。触发器丢失时后台只是回退 `useroptlog` 旧口径，不会报错；重新执行本补丁即可恢复。
- 历史上传目录 `UploadPath=D:\Uploads`（新机无 D 盘）问题仍未动，见「已知未闭合项」10。
- 本轮（1.0.46/1.0.47/1.0.48）**均已部署未入库**，需一起提交。

## 24. 2026-09-18 本轮增量（玩家列表「刷新在线玩家」卡很久）

**现象**（运营反馈）：手机端玩家列表点刷新（或每次进页面）「在线玩家」要转圈很久才出来，游戏服一停整个后台都跟着卡。

**排查（全部是线上只读证据，未改任何线上的东西）**

1. **IIS 访问日志按 `time-taken` 统计**（`C:\inetpub\logs\LogFiles\W3SVC1\u_ex260917.log`，09-17 全天，取 `GetOnlineUsers` 527 次）：中位数 9ms、**p90 516ms、最大 11053ms**，103 次 ≥480ms。正常时它就是毫秒级——所以"卡"是少数请求被整块拖住。
2. **停顿是 ~500ms 的整数倍**（约 496/505/1013/2021/9986/11053ms），且**同一秒内完全无关的静态文件一起卡**：`19:15–19:17`（游戏服停机窗口）`GetOnlineUsers` 9986/9996/10011/11053ms，而 `/Scripts/jquery.min.map` 10086/10052/**10548**ms、`/Mobile/Home/Recharge` 9048ms 都在同一批秒里。不同 CDN 边缘节点、不同接口、连静态文件同时中招 → **不是某个接口慢，是整站请求被排住**（500ms 台阶正是 CLR 线程池每 ~500ms 补一个线程的爬坡节奏）。
3. **反证**：在服务器本机 `localhost` 连打 550 次（静态 CSS + 视图页）**零停顿**（p50 = min = 23ms，max 44ms），而 CDN 链路 7.7% 的请求 ≥480ms → 与业务代码、数据库无关，就是"请求线程被占住"。
4. **根因（真凶）**：`YYT.Remote.SConnect` 的**读操作根本没有超时**。`NamedPipeClientStream`（`PipeOptions.Asynchronous`）`CanTimeout` 返回 **false**，`ReadTimeout/WriteTimeout` 赋值会直接抛 `InvalidOperationException: 此流上不支持超时`——老代码把它包在 `if (PipeClient.CanTimeout)` 里，是**死代码**。于是游戏服不回话时 `sr.ReadLine()` 一直挂着，线上那 9–11 秒是中心服进程停机、管道断开才返回的；如果中心服是"活着但卡住"，请求会永久挂住。QA（查询在线玩家）又是玩家列表**首屏/刷新/bfcache 返回**三处都会调的接口，几个请求同时挂住就把线程池占满，连静态文件一起排队。
5. **失败态丢失**：QA 失败时 `QueryAllOnlinePlayers` 返回空列表，控制器照常回 `code=1`，端上把"游戏服没响应"和"没人在线"显示成同一句「暂无在线玩家」。

**修复（1.0.48）**

- `YYT.Remote/SConnect.cs`：新增 `ReadLineWithTimeout`（异步读 + `Task.Wait(上限)`，超时即关管道并返回 null，调用方按"数据发送失败"处理）；`SendNotTranlation`/`SendReadString`/`SendTcCommand` 三处裸 `ReadLine()` 全部改走它；连接上限仍用真实生效的 `Connect(timeout)`。默认档 5000/10000（**以前读是无上限**），新增 `SConnect(connectTimeoutMs, readTimeoutMs)` 供短超时指令使用。
- `YYT.BLL/Services/GameServer/PipeGameServerClient.cs`：QA 用 `SConnect(1000, 3000)`；`QueryAllOnlinePlayers` 失败返回 **null**。
- `TTY.Web/Areas/Game/Controllers/UserInfoController.cs`：`GetOnlineUsers` 拿到 null 时回 `code=0 + "游戏服暂无响应，请稍后重试！"`（电脑端在线用户页 `code!=1` 会弹文案；手机端保留旧列表）。L/UC 等指令失败仍由 `gamecommandoutbox` + 重试服务兜底，语义不变。
- `TTY.Web/Global.asax.cs`：`ThreadPool.SetMinThreads(200,200)` 兜底，单条慢指令不再连带整站。
- `TTY.Web/Scripts/app/phone/phone.players.js`：请求超时 12s→**6s**；失败（网络失败或 `code!=1`）时**保留上一次的列表与人数**、提示"游戏服暂无响应，列表为上次结果"，只有从没加载成功过才显示提示占位，不再清空成「暂无在线玩家」。

### 24.1 测试与验证

- 契约用例 `OnlinePlayersQueryFailsFastWhenGameServerIsUnreachable`：锁住短超时常量、`ReadLineWithTimeout` 的存在（并断言不得再出现 `PipeClient.ReadTimeout =`）、控制器文案、前端 6s 超时与"失败不清空列表"。
- 全量 `vstest`：**96 项 72 通过 / 24 失败**（失败仍是测试工程未注册 `MySql.Data.MySqlClient` 的既有环境问题，与 §21/§23 基线一致）。
- **假管道服务器实测**（`Tools/one-off/_pipetimeout/`：`Program.cs` 起一个 `mynamedpipe`，接受连接后既不读也不回话，模拟"游戏服活着但卡住"）：
  - `probe 1000 3000` → **3076ms** 返回 `数据发送失败！等待中心服回复超时（3000ms）。`；`probe 5000 10000` → 10075ms（默认档也封顶了；改前这两档都是**无限等待**）。
  - `client` → `QueryAllOnlinePlayers` 第 1 次 **3100ms 返回 null**，第 2 次 **0ms**（走 30s 熔断冷却）。
  - 顺带查明：假服务器若用 0 缓冲建管道，小写入也会阻塞——那是模拟不真实（真中心服是 `WEB_COMMU_SIZE`=4096 缓冲），已改成同样缓冲。
- Node `--check` 通过；`.cshtml` 未改，无需视图预编译。
- 线上 1.0.48 部署后复验：`GetOnlineUsers` 仍 `code=1`（管道正常时不受影响，14–35ms）、`GetOfflineUsers`/`GetUserDetail` 正常、页面已引用 `phone.players.js?v=1.0.48`、CDN `abc.12.sqrdwj.top` 取到的脚本含 `timeoutMs: 6000`；线上 6 个关键文件与构建产物 MD5 逐字节一致（`7c5f6d8b…` / `d3dd2d21…` / `a8b34ebb…` / `77b71057…` / `b6674385…` / `0457aa02…`）。

### 24.2 未闭合

- **CDN 链路上 ~500ms 的偶发停顿仍在**（占 CDN 请求约 7.7%，静态文件同样中招；`nginx` 链路 4750 次请求几乎为 0）——本次只掐断了"游戏服不可达 → 整站卡 10 秒"这条放大链路，CDN 回源连接/TCP 层面的抖动没动（与业务代码无关，需 CDN 侧或网络层排查）。
- 管道**写**没有上限（`WriteTimeout` 同样不支持）：命令都很小（≤4KB，小于中心服 4096 入缓冲）所以未出问题；将来若有超大命令要自己包一层限时写。
- 其它走管道的接口（踢人/充退/控制/TC 热更）现在读上限是默认 10 秒（改前**无上限**）；若运营觉得仍偏长，可再按指令分级调小。

## 10. 2026-09-02 本地验证记录

- `Tools\dev\build.bat` Release 构建成功，产物为 `TTY.Web\bin\YYT.Web.dll`。
- `ViewContractTest` 28/28、`AgencyRulesTest` 10/10 通过；手机端脚本均通过 `node --check`，`git diff --check` 无空白错误。
- 本地 MySQL 5.7 已重复执行幂等 SQL，中奖记录表存在，10 个本次要求的索引均存在。
- 使用本地真实登录会话验证：直属范围仅允许直属玩家和直属代理，拒绝二级玩家和二级代理；整线范围允许二级玩家和二级代理。
- 使用本地真实登录会话验证：关闭查看密码时玩家/代理密码均不返回，玩家改密请求被服务端拒绝。
- 使用本地真实登录会话验证：全部控制权限关闭时无控制入口且控制页重定向；只开吃分时仅渲染吃分选项。
- 使用超过 7 天的充值记录查询验证返回 `只能查询最近7天`；本地测试期间临时切换的权限值均已恢复。
- 全量 66 项测试中 42 项通过、24 项失败；失败均为测试工程未注册 `MySql.Data.MySqlClient` Provider，尚未进入业务断言。线上部署和发布验收仍对应 Task 6.4、6.5，未执行。
