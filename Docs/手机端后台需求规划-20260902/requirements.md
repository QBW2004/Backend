# 手机端后台改造需求

## 1. 文档目的与范围

本需求用于指导 MTH-Backend 手机端后台改造，并同步约束电脑端接口行为。目标是把截图和已确认口径转换为可开发、可测试的需求；本阶段不改变游戏中心服指令协议，不扩展支付业务。

除非特别说明，以下需求均适用于管理员和代理账号，并要求手机端、电脑端共用服务端授权与数据留存规则。

## 2. 已确认口径

- 权限开关关闭后，服务端接口也必须拒绝操作，前端隐藏只是体验层。
- `ManageScope=1` 表示直属范围：直属会员、直属代理；`ManageScope=2` 表示整条线：所有下级会员、所有下级代理。
- 冻结、解冻、禁用代理、恢复代理只能操作当前账号管理范围内的目标，不能跨线，也不能操作自己。
- 记录按当前时间向前保留 7×24 小时；超过窗口自动清理。查询超出窗口时按无记录处理，并给出简短提示。
- 创建下级代理时只输入一次密码；创建页面的“创建下级”默认打开，创建完成后可在代理详情中继续开关。
- 操作结果弹窗使用简单中文，如“操作成功”“保存成功”“移除成功”“修改成功”。

## 3. Glossary

| 术语 | 含义 |
|---|---|
| `Mobile_Admin_UI` | 手机端后台页面、弹窗、菜单和交互脚本 |
| `Desktop_Admin_UI` | 电脑端后台页面和交互脚本 |
| `Permission_Policy` | 服务端统一权限判断，包括功能权限、密码权限和管理范围 |
| `Agency_Scope_Resolver` | 根据登录账号和 `ManageScope` 计算可管理代理/会员集合的组件 |
| `Agent_Management` | 代理列表、创建下级、代理详情、禁用/恢复代理 |
| `Player_Management` | 会员列表、会员详情、冻结/解冻、修改密码 |
| `Control_Management` | 吃分、放水、控牌等玩家控制功能 |
| `Record_Query` | 充值记录、玩家记录、中奖记录查询接口及页面 |
| `Record_Retention` | 7×24 小时查询窗口和定时清理任务 |
| `Operation_Audit_Log` | 记录操作人、目标、操作类型和操作时间的审计记录 |
| `Sensitive_Password_Field` | 玩家或代理登录密码等敏感字段 |
| `Simple_Result_Message` | 面向用户的简短成功/失败提示文本 |

## 4. Functional Requirements

### Requirement 1: Control_Management 页面

1. **When** `Mobile_Admin_UI` 打开控制管理并查询到玩家，**the system shall** 按截图顺序展示“当前押注、剩余分数、剩余金币、今日盈亏、总盈亏”五项统计。
2. **When** `Control_Management` 返回玩家当前控制状态，**the system shall** 在统计区下方展示状态行；没有控制时保留空白位置，不显示“无控制”按钮或跳转。
3. **If** `Permission_Policy` 判定某种控制权限关闭，**the system shall** 不在手机端和电脑端展示对应控制类型，也必须拒绝直接调用该控制接口。
4. **If** 吃分、放水、控牌三项控制权限全部关闭，**the system shall** 不展示控制按钮或可提交的控制表单。
5. **When** 控制成功、移除控制或失败，**the system shall** 使用 `Simple_Result_Message`；成功提示至少覆盖“操作成功”“移除成功”，不得向用户展示服务器参数、指令确认等内部术语。
6. **When** 玩家卡片展示所属代理，**the system shall** 只显示代理账号，不显示“代理：”前缀。

### Requirement 2: Agent_Management 与代理展示

1. **When** `Mobile_Admin_UI` 展示代理列表，**the system shall** 隐藏当前登录账号本身，只展示当前账号管理范围内的下级代理。
2. **When** 打开代理详情，**the system shall** 展示“创建下级”开关；该开关默认打开，并可由有权限的上级保存为关闭。
3. **When** 创建下级代理，**the system shall** 只要求输入一次登录密码，并以该密码完成创建；不得要求重复确认密码。
4. **When** 创建下级代理且未显式关闭创建权限，**the system shall** 将新代理的创建下级权限初始化为开启。
5. **If** 当前登录账号没有创建下级权限，**the system shall** 同时隐藏创建入口并拒绝创建接口请求。
6. **When** 展示代理登录密码，**if** `Permission_Policy` 的 `IsViewPwd` 关闭，**the system shall** 不返回、不渲染、不提供复制入口；开启时才允许展示。
7. **When** 修改玩家登录密码，**if** `Permission_Policy` 的 `IsViewPwd` 或 `IsModifyPwd` 任一关闭，**the system shall** 隐藏修改入口并拒绝接口请求。
8. **When** 展示安全密码，**the system shall** 继续独立遵守 `IsViewSafePwd`，不得因登录密码权限开启而自动泄露安全密码。
9. **When** 打开玩家详情，**the system shall** 将控制状态作为信息展示；只有存在对应控制权限时才显示对应设置入口。
10. **When** 展示“下级代理”数量，**the system shall** 只统计该代理的直属下级代理数量，不包含更深层级的下级代理。
11. **When** 点击“下级代理”数量下钻，**the system shall** 只展示该代理的直属下级代理，不展示更深层级的下级代理。
12. **When** 下钻某个代理后展示其下级列表，**the system shall** 让列表中的“下级代理”数量与该代理在下钻前显示的数量一致，不得因下钻而全部归零。

### Requirement 3: Permission_Policy 与管理范围

1. **When** `ManageScope=1`，**the system shall** 允许目标为直属会员或直属代理，不允许目标为更深层级会员/代理。
2. **When** `ManageScope=2`，**the system shall** 允许目标为当前账号整条线内的会员和代理。
3. **If** 目标不在 `Agency_Scope_Resolver` 返回的管理集合内，**the system shall** 拒绝查询敏感详情、密码修改、冻结/解冻、禁用/恢复代理和权限修改。
4. **If** 目标账号等于当前登录账号，**the system shall** 拒绝对自身执行冻结、解冻、禁用、恢复或管理权限修改。
5. **When** 页面显示操作按钮，**the system shall** 只根据服务端返回的有效权限渲染按钮；前端隐藏不得作为唯一安全措施。
6. **When** 使用“查看全部”查看会员，**the system shall** 先校验选定代理在当前管理范围内，再按 `ManageScope` 返回该代理本身或其整条线会员。

### Requirement 4: Record_Query 与 7×24 小时留存

1. **When** 查询充值记录、玩家记录或中奖记录，**the system shall** 将查询范围限制在 `Now-7×24h` 到 `Now`，手机端和电脑端规则一致。
2. **If** 请求结束时间早于留存截止时间，**the system shall** 返回 `{ total: 0, rows: [] }`，不读取窗口外数据。
3. **If** 请求时间区间跨过留存截止时间，**the system shall** 将开始时间截断到留存截止时间后再查询。
4. **When** `Record_Retention` 定时任务运行，**the system shall** 删除充值、玩家、中奖及现有运营日志表中早于留存截止时间的数据。
5. **If** 用户查询窗口超过 7×24 小时，**the system shall** 使用简短提示（如“只能查询最近7天”），不得展示数据库异常或内部 SQL 信息。
6. **When** `Mobile_Admin_UI` 展示退币统计，**the system shall** 使用“今日退币”文案；不得继续显示“今日退钻”。
7. **When** 展示充值记录中的操作类型，**the system shall** 沿用现有数据含义，仅统一用户可见文案，不改变历史记录数值。
8. **When** 展示中奖记录，**the system shall** 不展示八爪鱼（`GameId=42`）的游戏卡片与记录，也不计入总数；该排除只作用于中奖记录页，不得通过修改 `games.Enable` 实现。

### Requirement 5: Operation_Audit_Log 与冻结/禁用

1. **When** 执行冻结账号、解冻账号、禁用代理或恢复代理，**the system shall** 原子地保存状态变更与 `Operation_Audit_Log`。
2. **When** 展示冻结明细、冻结账号或禁用代理列表，**the system shall** 展示目标账号、操作人和操作时间；无法追溯的历史数据显示“--”。
3. **If** 操作人无目标管理范围权限，**the system shall** 拒绝状态变更并不写入成功审计记录。
4. **When** 代理执行冻结/解冻会员或禁用/恢复直属代理，**the system shall** 将操作人记录为实际登录账号，而不是被操作目标的上级名称。
5. **When** 操作完成，**the system shall** 返回 `Simple_Result_Message`，至少支持“操作成功”“修改成功”“移除成功”。
6. **When** 查询审计记录，**the system shall** 使用 SQL 条件和索引下推范围、权限及时间过滤，不得先全表加载到内存。

### Requirement 6: Mobile/Desktop 一致性与兼容性

1. **When** `Mobile_Admin_UI` 和 `Desktop_Admin_UI` 调用同一业务接口，**the system shall** 使用同一 `Permission_Policy`、`Agency_Scope_Resolver` 和 `Record_Retention` 规则。
2. **When** 改造接口返回成功或失败，**the system shall** 保持现有 JSON 外层契约（列表为 `total/rows`，操作为 `code/msg`），仅补充必要的操作人/操作时间字段。
3. **When** `Record_Retention` 由 `Application_Start` 定时任务触发，**the system shall** 保持单飞和节流机制；任何列表接口不得内联执行删除。
4. **When** 编译旧式项目，**the system shall** 将新增 C#、视图、脚本和样式文件登记到对应 `.csproj`，新增中文 `.cshtml` 使用 UTF-8 BOM。
