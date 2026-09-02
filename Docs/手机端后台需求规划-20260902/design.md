# 手机端后台改造设计

## 1. 设计目标

本设计把已确认的手机端视觉调整与权限、审计、留存规则集中到服务端策略层，避免只改页面导致接口越权。电脑端继续复用同一组 BLL 查询和权限策略；现有命名管道控制协议保持不变。

## 2. 总体架构

```text
Mobile_Admin_UI / Desktop_Admin_UI
          │ HTTP JSON
          ▼
Mobile/Game Controllers
          │
          ├── Permission_Policy
          ├── Agency_Scope_Resolver
          ├── Record_Retention
          └── Operation_Audit_Log
          │
          ▼
       BLL / EF6 / MySQL
          │
          └── Control_Management → GameCommandService → 命名管道（不改协议）

Application_Start Timer → Record_Retention.CleanupExpiredRecordsThrottled
```

## 3. 核心组件设计

### 3.1 Agency_Scope_Resolver

不要直接复用“所有可管理代理账号”作为会员过滤条件，因为直属范围下“直属代理”和“直属会员”是两种不同集合。新增/整理以下策略方法（可先落在 `B_Admin`，后续再抽接口）：

```csharp
ISet<string> GetManagedAgentAccounts(M_LoginUser viewer);
ISet<string> GetManagedPlayerAgencyAccounts(M_LoginUser viewer);
bool CanManageAgent(M_LoginUser viewer, string targetAgent);
bool CanManagePlayer(M_LoginUser viewer, string playerId);
```

- 超级管理员返回全量范围，但仍由控制器决定是否允许对自身操作。
- `ManageScope=1`：代理集合为直属代理；会员所属代理集合只包含当前账号。
- `ManageScope=2`：代理集合为整条线代理；会员所属代理集合为当前账号及所有下级代理。
- `GetManagedAgentAccounts` 和 `GetManagedPlayerAgencyAccounts` 都必须在 SQL `IN`/连接条件中使用，禁止把全量用户加载到内存后过滤。
- `CanManagePermissionTarget`、冻结/解冻、代理禁用/恢复、密码修改统一调用同一范围判断，避免接口之间口径漂移。

### 3.2 Permission_Policy

权限判断拆成三个独立维度：

1. 功能权限：`IsFrozen`、`IsCreateAgent`、`IsKicking`、`IsProbability`、`IsRelease` 等。
2. 登录密码权限：`IsViewPwd` 控制玩家和代理登录密码返回、展示、复制；玩家修改登录密码要求 `IsViewPwd` 与 `IsModifyPwd` 同时开启。
3. 安全密码权限：`IsViewSafePwd`、`IsModifySafePwd` 独立判断。

`B_Users.GetUserPhoneDetail`、`GetUsersList`、`GetUserRowsByIds` 和 `AgencyInfoController.GetAgencyDetail` 必须在投影阶段脱敏。脱敏后的字段传到前端后不可恢复；控制器还要再次做写操作授权检查。

### 3.3 Control_Management

沿用现有 `GetVisibleUserRows` 数据源，增加/整理控制页专用投影：

```text
CurrentBetCoins, Score, Coins, TodayWinLoss, TotalWinLoss,
ControlType, ControlValue, HasControl, CanKill, CanProbability, CanRelease
```

`ControlType` 为空时仍输出状态行占位；`CanKill/CanProbability/CanRelease` 由服务端权限计算。手机脚本依据每个权限逐项渲染，不能用“任一权限为真”来显示三个控制入口。

控制结果保留详细日志，但用户弹窗通过统一映射：

| 场景 | 用户文案 |
|---|---|
| 应用控制成功 | 操作成功 |
| 移除控制成功 | 移除成功 |
| 保存普通设置 | 保存成功 |
| 修改密码/权限成功 | 修改成功 |
| 权限或范围失败 | 无权限 |
| 时间窗口失败 | 只能查询最近7天 |

### 3.4 Agent_Management

- `AddAgent` 页面保留一个密码输入框，提交时只传 `PWD`；服务端如果需要 `RE_PWD`，由 BLL 从 `PWD` 补齐，不再做二次输入校验。
- `AddAgencyInfo` 的 `IsCreateAgent` 使用请求值，缺省值为 `1`；不能继续无条件硬编码为开启。
- 代理详情返回 `CanCreateChildAgent` 和当前代理的 `IsCreateAgent`，详情开关保存调用已有 `SetIsCreateAgent`，但其目标范围必须经过 `Agency_Scope_Resolver`。
- 代理列表查询排除当前登录账号；显示账号时不拼接“代理：”。
- `GetAgencyDetail.PWD` 只在超级管理员或 `IsViewPwd=1` 时返回，否则为 `null`/脱敏值；前端不渲染复制按钮。

### 3.5 Record_Query 与 Record_Retention

统一在 BLL 入口计算本地服务器时间截止点：

```csharp
DateTime cutoff = DateTime.Now.AddDays(-7);
```

查询规则：

- 请求区间完全早于 `cutoff`：直接返回空分页。
- 请求区间与窗口相交：`start = max(requestStart, cutoff)`，`end = min(requestEnd, DateTime.Now)`。
- 未传时间：默认最近 7×24 小时，而不是自然日或 30 天。
- 服务端先套范围和截止时间，再做排序、分页、汇总。

`B_Records_MySQL.CleanupExpiredRecords` 增加 `gameprizerecord` 删除；仍只由现有定时任务调用，保留进程内每小时节流。针对 `REC_TIME/CreateTime/TIME` 的日志表建立复合索引，中奖记录补充用户+时间索引。部署 SQL 必须幂等。

### 3.6 Operation_Audit_Log

优先复用现有 `AgencyOptLog`，因为它已经包含 `OptID`（操作人）、`ID`（目标）、`REC_TIME`（操作时间）、`OPT`（类型）和目标类型字段，避免新增一套无法被旧后台读取的日志表。

- 现有代理禁用/恢复继续使用 `OPT=24/25`。
- 玩家冻结/解冻使用新的命名常量（实施前扫描现有取值，建议从未占用值开始，例如 `26/27`），禁止在业务代码散落魔法数字。
- 冻结/解冻和禁用/恢复在同一 `GameDbContext` 事务中更新状态并新增日志。
- 列表查询按目标账号取最近一条对应审计记录，返回 `Operator`、`OperatedAt`；没有历史日志显示“--”。
- 审计查询也套 `Agency_Scope_Resolver` 与 7×24 小时窗口，索引由迁移脚本补齐。

## 4. 接口与数据契约调整

| 接口/区域 | 调整 |
|---|---|
| `Game/UserInfo` 玩家列表、详情、密码、冻结 | 统一范围检查；密码字段按 `IsViewPwd` 脱敏；冻结写审计 |
| `Game/AgencyInfo` 代理列表、详情、创建、禁用 | 排除当前账号；创建权限默认/开关；密码脱敏；禁用权限跟随管理范围 |
| `Game/Admin` 权限设置 | 所有权限目标继续调用范围策略；创建下级开关使用请求值 |
| `Game/UserRecord` 玩家/中奖记录 | 截止时间和范围 SQL 下推；中奖默认最近 7×24 小时 |
| `Game/Recharge` 充值记录 | 截止时间和范围 SQL 下推 |
| `Game/Abnormal`、`Mobile/BanPlayer`、`Mobile/BanAgent` | 代理可在管理范围内操作；返回操作人/操作时间 |
| `Mobile/Home/Control` | 五项统计、逐项权限、空状态占位、简短弹窗 |
| `Mobile/Home/Huiyuan`、`PlayerDetail`、`Agents` | 今日退币文案、查看全部范围、账号展示、密码/创建权限开关 |

新增字段只追加到现有 JSON，不删除旧字段；客户端先兼容空值，便于分阶段部署。

## 5. 数据库与部署设计

新增幂等脚本：`Docs/sql/手机端后台权限与记录保留-20260902.sql`，内容至少包括：

1. `AgencyOptLog(ID, REC_TIME, OPT)` 查询索引（按实际现有索引先检查再创建）。
2. `gameprizerecord` 的用户/时间索引。
3. 充值、玩家、管理操作日志所需的时间及范围索引。
4. 不新增明文密码列，不修改生产密钥。

部署顺序：先在 MySQL57 的 `mth` 库执行 SQL，再部署 Web 文件，最后回收应用池并验证移动/电脑端。

## 6. Correctness Properties

### Property 1: Control permission projection

*For any* viewer and player, every rendered control action is a member of the server-returned allowed control set; a denied control cannot be submitted successfully.

**Validates: Requirements 1.3, 1.4**

### Property 2: Control empty-state invariant

*For any* player without an active control, the response contains an empty status state and the UI keeps the status row without a control action.

**Validates: Requirements 1.2**

### Property 3: Scope separation for direct management

*For any* viewer with `ManageScope=1`, managed player agency accounts contain only the viewer account and managed agent accounts contain only direct child agents; deeper descendants are rejected.

**Validates: Requirements 3.1, 3.3, 3.6**

### Property 4: Scope closure for line management

*For any* viewer with `ManageScope=2`, every descendant agent and every player whose agency is in that descendant set is manageable, while targets outside the line are rejected.

**Validates: Requirements 3.2, 3.3, 5.3**

### Property 5: Password-view non-disclosure

*For any* response produced while `IsViewPwd=0`, no player or agent login password value appears in JSON, HTML, copy data, or client state.

**Validates: Requirements 2.6, 3.5**

### Property 6: Password-modify authorization

*For any* player password modification request while `IsViewPwd=0`、`IsModifyPwd=0` or the target is outside scope, the database password remains unchanged and no success audit is written.

**Validates: Requirements 2.7, 3.3**

### Property 7: Create-agent default and toggle

*For any* valid new child-agent request omitting the switch, `IsCreateAgent=1`; an explicit off value persists as `0`, and the parent can later toggle only a managed child.

**Validates: Requirements 2.2, 2.3, 2.4, 2.5**

### Property 8: Retention-window clamping

*For any* record query interval, the effective interval is the intersection with `[Now-7×24h, Now]`; a non-intersecting interval returns zero rows.

**Validates: Requirements 4.1, 4.2, 4.3, 4.5**

### Property 9: Retention cleanup boundary

*For any* retained table, after a successful cleanup run no row with its business timestamp earlier than the cutoff remains, and no row at or after the cutoff is deleted.

**Validates: Requirements 4.4, 6.3**

### Property 10: Audit completeness and actor identity

*For any* successful freeze/unfreeze or agent disable/restore operation, exactly one state change and one audit row are committed with the actual operator, target, operation type, and timestamp.

**Validates: Requirements 5.1, 5.4**

### Property 11: Audit visibility scope

*For any* audit list response, every row belongs to a target in the viewer's management scope and exposes operator/time, or `--` only when no legacy audit exists.

**Validates: Requirements 5.2, 5.3, 5.6**

### Property 12: Result-message normalization

*For any* successful mutation, the client-visible message belongs to the approved `Simple_Result_Message` set and contains no server command detail.

**Validates: Requirements 1.5, 5.5, 6.2**

### Property 13: Mobile/Desktop policy parity

*For any* viewer, target, operation, and time interval, mobile and desktop entry points yield the same authorization decision and effective record interval.

**Validates: Requirements 6.1, 6.2**

## 7. Requirements Mapping

| Requirement | Design Section |
|---|---|
| Requirement 1: Control_Management 页面 | 3.3 Control_Management、Property 1-2、12 |
| Requirement 2: Agent_Management 与代理展示 | 3.4 Agent_Management、Property 5-7 |
| Requirement 3: Permission_Policy 与管理范围 | 3.1 Agency_Scope_Resolver、3.2 Permission_Policy、Property 3-6 |
| Requirement 4: Record_Query 与 7×24 小时留存 | 3.5 Record_Query 与 Record_Retention、Property 8-9 |
| Requirement 5: Operation_Audit_Log 与冻结/禁用 | 3.6 Operation_Audit_Log、Property 10-12 |
| Requirement 6: Mobile/Desktop 一致性与兼容性 | 4 接口契约、5 数据库与部署、Property 9、13 |
