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

## 10. 2026-09-02 本地验证记录

- `Tools\dev\build.bat` Release 构建成功，产物为 `TTY.Web\bin\YYT.Web.dll`。
- `ViewContractTest` 28/28、`AgencyRulesTest` 10/10 通过；手机端脚本均通过 `node --check`，`git diff --check` 无空白错误。
- 本地 MySQL 5.7 已重复执行幂等 SQL，中奖记录表存在，10 个本次要求的索引均存在。
- 使用本地真实登录会话验证：直属范围仅允许直属玩家和直属代理，拒绝二级玩家和二级代理；整线范围允许二级玩家和二级代理。
- 使用本地真实登录会话验证：关闭查看密码时玩家/代理密码均不返回，玩家改密请求被服务端拒绝。
- 使用本地真实登录会话验证：全部控制权限关闭时无控制入口且控制页重定向；只开吃分时仅渲染吃分选项。
- 使用超过 7 天的充值记录查询验证返回 `只能查询最近7天`；本地测试期间临时切换的权限值均已恢复。
- 全量 66 项测试中 42 项通过、24 项失败；失败均为测试工程未注册 `MySql.Data.MySqlClient` Provider，尚未进入业务断言。线上部署和发布验收仍对应 Task 6.4、6.5，未执行。
