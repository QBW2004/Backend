# Design Document: 手机端后台第二轮改造

## Overview

本设计在现有 MVC5/EF6/MySQL 结构上增量实现需求，不引入新框架。核心原则是：URL 显式决定端版本、共享格式化只保留一个真相源、权限默认值由服务端拥有、敏感字段使用专用 DTO、开奖历史使用结算事件而非事后推断。

核心决策：

1. 普通入口使用 `/Mgr/Index`，电脑版入口使用 `/Mgr/Index?view=pc`；登录页分别为 `/Login/Mobile` 与 `/Login/Index`。
2. `mth_view` Cookie 和 UA 仅停止参与路由，不保留“记住上次选择”的行为。
3. 非超管“查看代理密码/删除代理”采用超级管理员专属规则，不新增权限列。
4. 代理剩余分按该代理直属玩家的 `GAME_SCORE` 合计。
5. 16 个游戏不硬编码：查询 `games.Enable=1 AND games.GameType<>0`，当前数据自然得到 16 个。
6. 开奖历史新增结算记录表；现有 `UserOptLog` 继续作为游戏轨迹和最后活动时间数据源，不承担牌型/播报/手动送奖审计。
7. Builder 严格度采用 L3：核心权限、SQL 范围和路由必须有自动测试；视觉与真实交互以手机浏览器手工验收为主。

技术约束：

- ASP.NET MVC5 / .NET Framework 4.8 / EF6 / MySQL 5.7。
- 老式 csproj，新文件必须显式登记。
- 线上中心服不在当前 Web 服务器，开奖记录生产端需要单独联调。

## Architecture

```text
Browser
  ├─ /Mgr/Index ----------------------> Mobile_Router ----> /Mobile/Home/Index
  ├─ /Mgr/Index?view=pc --------------> Mobile_Router ----> Desktop Mgr View
  └─ /Mobile/Home/* ------------------> Mobile HomeController
                                                │
                                                ├─ UserInfoController -> B_Users
                                                ├─ AgencyInfoController -> B_Admin
                                                ├─ UserInfoController -> B_UserControl
                                                └─ UserRecordController -> B_PrizeRecord (new)
                                                                 │
Game server settlement -> Prize_Record_Source -> gameprizerecord ┘
```

关键时序：

```text
玩家详情点击中奖历史
  -> GET /Mobile/Home/PrizeHistory?id=U
  -> POST /Game/UserRecord/GetPrizeHistory
  -> 校验登录人能否查看 U
  -> 查询 enabled non-bet games
  -> 按 UserID + 日期范围读取 gameprizerecord
  -> 按 GameId 分组返回
  -> 页面渲染 16 个游戏卡片（含 0 条空卡）
```

## Components and Interfaces

### 1. Mobile_Router

修改位置：

- `TTY.Web/Controllers/MgrController.cs`
- `TTY.Web/Controllers/LoginController.cs`
- `TTY.Web/Controllers/BaseController.cs`
- `TTY.Web/Filters/MobileOnlyAttribute.cs`
- `TTY.Web/Filters/MemberAuthorizeAttribute.cs`

行为：

```csharp
// /Mgr/Index: default mobile; only view=pc renders desktop.
public ActionResult Index();

// Desktop login is explicit and never UA-redirected.
public ActionResult Index();

// Mobile login is explicit and never UA-redirected.
public ActionResult Mobile();
```

`MemberAuthorizeAttribute` 对 `/Mgr/Index` 的未登录 GET 特判：显式 `view=pc` 去 `/Login/Index`，否则去 `/Login/Mobile`。Mobile Area 继续固定去 `/Login/Mobile`；Game Area 桌面页面继续去 `/Login/Index`。

### 2. Mobile_Number_Formatter

修改 `phone.core.js`：

```javascript
M.num = function (value) { /* integer, no grouping */ };
M.gold = function (value) { /* RMB conversion preserved, no grouping */ };
M.signed = function (value) { /* +positive / -negative / 0 */ };
```

通过共享函数覆盖玩家、会员、代理、充退、记录和弹窗，避免逐页出现不同格式。

### 3. Member_WinLoss_Page

接口保留现有路径，调整参数语义：

```csharp
public ActionResult GetMemberWinLoss(FormCollection form);
public ActionResult GetMemberWinLossStats(FormCollection form);
```

- `srch_Agency` 作为明确的代理账号，SQL 使用 `c.AGENCY = @agency`，禁止 `LIKE '%agency%'`。
- 非超管先校验目标代理是否在管理范围内；无参数时目标为当前登录代理。
- 超管无参数时保持平台全量。
- 账号单元格输出详情链接，排序继续 SQL 下推。

### 4. Player_List_Page

`OnlinePlayerInfo` 新增：

```csharp
[JsonProperty("LastLoginTime")]
public DateTime? LastLoginTime { get; set; }
```

`GetOnlineUsers` 在已有盈利/今日盈亏批量补充后，再按账号集合一次查询 `UserOptLog` 最新时间。在线页顶部总额直接对本次在线响应的 `TodayWinLoss` 求和；离线页调用现有 `GetTodayWinLoss` 获取权限范围全部玩家总额。

玩家账号点击与卡片点击分离：账号去详情，卡片空白区域保留操作弹窗。

### 5. Control_Page

前端：

- 删除内部标题和底部记录区。
- 吃分/放水只保留目标值。
- 控牌保留游戏和牌型，固定提交 `cardNumber=1`、`cardTotal=5`。
- “关闭当前功能”改为“移除当前控制”。

后端继续复用：

```csharp
public ActionResult ApplyTotalControl(FormCollection form);
public ActionResult GetTotalControlStatus(FormCollection form);
public ActionResult CloseTotalControl(FormCollection form);
```

服务端不能信任隐藏字段：控牌模式在 Controller/BLL 再次钳制为 1/5，避免伪造请求传入其他数量。

### 6. Agency_Service

新增专用 DTO，禁止直接返回 `M_Admin`：

```csharp
public sealed class M_AgencyPhoneListItem
{
    public string ID { get; set; }
    public long Coins { get; set; }
    public int SubAgencyCount { get; set; }
    public string InviteCode { get; set; }
    public DateTime? CreateTime { get; set; }
    public DateTime? LastLoginTime { get; set; }
}

public sealed class M_AgencyPhoneDetail
{
    public string ID { get; set; }
    public string Password { get; set; } // super only
    public int Level { get; set; }
    public string ParentAgency { get; set; }
    public string InviteCode { get; set; }
    public long Coins { get; set; }
    public long RemainingScore { get; set; }
    public DateTime? CreateTime { get; set; }
    public DateTime? LastLoginTime { get; set; }
}
```

新增接口：

```csharp
[AjaxOnly, HttpPost]
public ActionResult GetAgencyPhoneDetail(FormCollection form);
```

权限：目标代理必须在当前管理范围内；密码仅 `UserPriv==0` 回填。`DeleteAdmin` 直接拒绝所有非超管。通用列表至少在序列化前清空 `PWD`，手机端改用专用 DTO。

### 7. Agency_Permission_Policy

服务端单一方法负责新代理默认值，忽略移动端上传的权限：

```csharp
private static void ApplyDefaultAgencyPermissions(M_Admin entity)
{
    entity.IsFrozen = 1;
    entity.IsKill = 1;
    entity.IsUpDown = 1;
    entity.IsCreateAgent = 1;
    entity.KickScope = 2;
    entity.ManageScope = 2;
    entity.IsProbability = 0;
    entity.IsRelease = 0;
    entity.IsDelete = 0;
    entity.IsViewPwd = 0;
    entity.IsKicking = 0;
}
```

迁移只更新 `PRIV BETWEEN 1 AND 8`，不修改 `PRIV=0` 超管或 `PRIV=9/10` 的副管理/运营账号。

### 8. Prize_Record_Source 与 Prize_History_Page

新增实体：

```csharp
[Table("gameprizerecord")]
public sealed class M_GamePrizeRecord
{
    [Key]
    public long ID { get; set; }
    public string EventId { get; set; }
    public string UserID { get; set; }
    public int GameId { get; set; }
    public int GameType { get; set; }
    public int RoomId { get; set; }
    public int TableId { get; set; }
    public int? HandType { get; set; }
    public string HandName { get; set; }
    public long BetScore { get; set; }
    public long WinScore { get; set; }
    public decimal? PayoutMultiplier { get; set; }
    public bool IsBroadcast { get; set; }
    public bool IsManualControl { get; set; }
    public DateTime CreatedTime { get; set; }
}
```

读取 DTO：

```csharp
public sealed class M_GamePrizeHistoryGroup
{
    public int GameId { get; set; }
    public string GameName { get; set; }
    public int GameType { get; set; }
    public int Total { get; set; }
    public List<M_GamePrizeHistoryItem> Rows { get; set; }
}
```

数据规则：

- `GameType=1`：显示该玩家的牌机开奖记录。
- `GameType=2/3`：仅显示 `IsBroadcast=1`。
- `GameType=0`：永不进入返回结果。
- `IsManualControl` 由游戏服在实际采用控牌结果时写入，不能只根据“当时有控制记录”判断。
- `EventId` 唯一，用于游戏服重试时幂等。

## Data Models

迁移脚本建议：`Docs/sql/手机端后台第二轮改造-20260901.sql`。

```sql
CREATE TABLE IF NOT EXISTS gameprizerecord (
    ID BIGINT NOT NULL AUTO_INCREMENT,
    EventId VARCHAR(64) NOT NULL,
    UserID VARCHAR(50) NOT NULL,
    GameId INT NOT NULL,
    GameType TINYINT NOT NULL,
    RoomId INT NOT NULL DEFAULT 0,
    TableId INT NOT NULL DEFAULT 0,
    HandType INT NULL,
    HandName VARCHAR(50) NULL,
    BetScore BIGINT NOT NULL DEFAULT 0,
    WinScore BIGINT NOT NULL DEFAULT 0,
    PayoutMultiplier DECIMAL(18,4) NULL,
    IsBroadcast TINYINT NOT NULL DEFAULT 0,
    IsManualControl TINYINT NOT NULL DEFAULT 0,
    CreatedTime DATETIME NOT NULL,
    PRIMARY KEY (ID),
    UNIQUE KEY UX_gameprizerecord_EventId (EventId),
    KEY IX_gameprizerecord_User_Time (UserID, CreatedTime),
    KEY IX_gameprizerecord_Game_Time (GameId, CreatedTime)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

同一迁移脚本幂等执行：

```sql
UPDATE admin
SET IsFrozen=1, IsKill=1, IsUpDown=1, IsCreateAgent=1,
    KickScope=2, ManageScope=2,
    IsProbability=0, IsRelease=0, IsDelete=0, IsViewPwd=0, IsKicking=0
WHERE PRIV BETWEEN 1 AND 8;

UPDATE agent_permission_template
SET IsFrozen=1, IsKill=1, IsUpDown=1, IsCreateAgent=1,
    KickScope=2, ManageScope=2,
    IsProbability=0, IsRelease=0, IsDelete=0, IsViewPwd=0, IsKicking=0
WHERE Level BETWEEN 1 AND 8;
```

## Correctness Properties

### Property 1: URL routing is deterministic

*For any* user agent and `mth_view` Cookie value, the Mobile_Router SHALL choose the same UI for the same explicit URL.

**Validates: Requirements 1.1, 1.2, 1.3, 1.4, 1.5**

### Property 2: Mobile numeric output has no grouping comma

*For any* numeric input accepted by Mobile_Number_Formatter, its rendered numeric substring SHALL contain no comma.

**Validates: Requirements 2.1, 2.2**

### Property 3: Direct-member exactness

*For any* selected agent account A, every row returned by Member_WinLoss_Page SHALL satisfy `users.AGENCY = A` and no row with a merely similar account string SHALL be returned.

**Validates: Requirements 3.1, 3.2, 3.8**

### Property 4: Player total semantics

*For any* online response set P, the online header total SHALL equal `sum(P.TodayWinLoss)`, while the offline header total SHALL equal the permission-scoped daily aggregate.

**Validates: Requirements 4.1, 4.2**

### Property 5: Card control invariant

*For any* valid card-control submission from the mobile page, the persisted and dispatched values SHALL be `cardNumber=1` and `cardTotal=5` regardless of client-supplied alternatives.

**Validates: Requirements 5.6, 5.7, 5.10**

### Property 6: Default agent permission invariant

*For any* newly created or migrated normal agent with `PRIV` 1 through 8, its permission tuple SHALL equal the values defined by Requirement 7.2 and 7.3.

**Validates: Requirements 7.1, 7.2, 7.3, 7.4, 7.5, 7.8**

### Property 7: Agent secrets never leak to non-super users

*For any* agent list, search or detail request by a non-super user, the serialized response SHALL NOT contain an agent password.

**Validates: Requirements 6.9, 6.10, 7.7, 9.1**

### Property 8: Agent deletion is super-only

*For any* DeleteAdmin request by a user whose `UserPriv != 0`, the Agency_Service SHALL reject the operation without deleting a row.

**Validates: Requirements 6.11, 7.7**

### Property 9: Prize history game filter

*For any* prize-history response, every group SHALL have an enabled game with `GameType<>0`, and every fish/slot row SHALL have `IsBroadcast=1`.

**Validates: Requirements 8.2, 8.3, 8.5, 8.9**

### Property 10: Manual prize attribution is event-based

*For any* displayed prize record, the “是否送奖” value SHALL equal the settlement event's stored `IsManualControl` value and SHALL be independent of current control status.

**Validates: Requirements 8.4, 8.8**

## Testing Strategy

- C# 单元/集成测试：权限默认值、代理密码脱敏、删除代理拒绝、直属会员精确过滤、控牌 1/5 钳制、开奖历史过滤。
- JavaScript 轻量测试或可执行浏览器断言：数字无逗号、页签总额切换、账号链接与卡片点击互不冲突。
- 手工浏览器验收：MVC5 视图布局、手机尺寸滚动、弹窗、日期控件和 PC/mobile URL 行为。该部分手测比搭建完整 UI 自动化更快且更准。
- 数据库验证：迁移前后统计 `admin` 行数、余额总和、权限列分布；迁移必须只改变目标权限列并创建新表。

## Requirements Mapping

| Requirement | Design Section |
|---|---|
| Req 1 | Mobile_Router |
| Req 2 | Mobile_Number_Formatter |
| Req 3 | Member_WinLoss_Page |
| Req 4 | Player_List_Page |
| Req 5 | Control_Page |
| Req 6 | Agency_Service |
| Req 7 | Agency_Permission_Policy, Data Models |
| Req 8 | Prize_Record_Source, Prize_History_Page, Data Models |
| Req 9 | DTO 设计, SQL 索引, Testing Strategy |
