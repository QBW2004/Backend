# Requirements Document: 手机端后台第二轮改造

## Introduction

本次为现有 ASP.NET MVC5 手机端运营后台的增量改造，目标是统一手机端数字显示、完善会员与玩家列表、简化控制页、补齐代理详情与默认权限，并新增独立的开奖历史页。默认后台链接必须稳定进入手机端，电脑版仅通过显式链接进入，页面选择不再依赖 UA 或 `mth_view` Cookie。

范围边界：

- 保持桌面端既有业务页面和 JSON 响应约定不变，除显式电脑版入口、共享权限校验和敏感字段保护外不重做桌面 UI。
- 不新增“查看代理密码”“删除代理”数据库权限列；这两项采用超级管理员专属规则。
- 开奖历史的展示与查询在本仓库实现；“触发中奖播报/手动控牌送奖”的原始事件必须由游戏服在结算时写入新记录表，不能从现有 `UserOptLog` 准确反推。
- 现有未提交业务代码不得被覆盖或重置。

## Glossary

- **Mobile_Router**: 后台手机端与电脑版的显式 URL 导航规则，由登录、`Mgr` 入口和 Mobile 过滤器共同实现。
- **Mobile_Number_Formatter**: `Scripts/app/phone/phone.core.js` 中负责手机端数字、金额和盈亏格式化的共享组件。
- **Member_WinLoss_Page**: `/Mobile/Home/Huiyuan` 会员盈亏页面及其 `/Game/UserInfo/*` 数据接口。
- **Player_List_Page**: `/Mobile/Home/Index` 在线/离线玩家列表及相关接口。
- **Control_Page**: `/Mobile/Home/Control` 吃分、放水、控牌页面及总控接口。
- **Agency_Page**: `/Mobile/Home/Agents`、`/Mobile/Home/AddAgent` 及代理详情交互。
- **Agency_Service**: `AgencyInfoController`、`B_Admin` 和代理 DTO 组成的代理查询/创建/权限服务。
- **Agency_Permission_Policy**: 新代理与现有代理统一使用的默认权限规则。
- **Prize_History_Page**: 从玩家详情进入的独立手机端开奖历史页面。
- **Prize_Record_Source**: 游戏服结算路径写入的中奖播报/牌型/手动控制记录。
- **Game_DB**: MySQL 5.7 的 `mth` 数据库。

## Requirements

### Requirement 1: URL 决定手机端或电脑版

**User Story:**
As an operator, I want the normal backend link to always open the mobile backend and a separate explicit link to open the desktop backend, so that device detection never sends me to the wrong UI.

#### Acceptance Criteria

1. WHEN `/Mgr/Index` is opened without `view=pc`, THE Mobile_Router SHALL direct the request to `/Mobile/Home/Index` or `/Login/Mobile` according to login state.
2. WHEN `/Mgr/Index?view=pc` is opened, THE Mobile_Router SHALL render the desktop backend or redirect to the desktop login page.
3. THE Mobile_Router SHALL render `/Login/Mobile` as the mobile login page on every user agent.
4. THE Mobile_Router SHALL render `/Login/Index` as the desktop login page on every user agent.
5. THE Mobile_Router SHALL NOT use UA matching or the `mth_view` Cookie to choose a UI.
6. WHEN desktop login succeeds, THE Mobile_Router SHALL redirect to `/Mgr/Index?view=pc`.
7. WHEN mobile login succeeds, THE Mobile_Router SHALL redirect to `/Mobile/Home/Index`.

### Requirement 2: 手机端数字不使用千位分隔符

**User Story:**
As an operator, I want mobile values displayed as continuous digits, so that scores, coins and totals match the requested compact presentation.

#### Acceptance Criteria

1. THE Mobile_Number_Formatter SHALL display scores, coins, recharge values, withdrawal values and win/loss values without comma grouping.
2. THE Mobile_Number_Formatter SHALL preserve the configured RMB conversion and two decimal places while omitting comma grouping.
3. WHEN a win/loss value is greater than zero, THE Mobile_Number_Formatter SHALL prefix `+` and apply the positive color class.
4. WHEN a win/loss value is less than zero, THE Mobile_Number_Formatter SHALL preserve `-` and apply the negative color class.
5. WHEN a numeric value is zero, THE Mobile_Number_Formatter SHALL display `0` without a sign.

### Requirement 3: 直属会员盈亏页面

**User Story:**
As an agent, I want to inspect a selected agent's direct members and their win/loss details, so that subordinate performance is unambiguous.

#### Acceptance Criteria

1. WHEN an agent row's “查看会员” action is selected, THE Member_WinLoss_Page SHALL query only users whose `users.AGENCY` exactly equals the selected agent account.
2. WHEN a non-super agent opens “我的会员” without an agent parameter, THE Member_WinLoss_Page SHALL query only users whose `users.AGENCY` exactly equals the logged-in agent account.
3. WHEN a super administrator opens “我的会员” without an agent parameter, THE Member_WinLoss_Page SHALL preserve the platform-wide view.
4. THE Member_WinLoss_Page SHALL display total win/loss, total recharge, total withdrawal, today win/loss, today recharge and today withdrawal.
5. THE Member_WinLoss_Page SHALL display player account, remaining coins, remaining game score, total win/loss, total recharge and total withdrawal.
6. WHEN a player account is selected, THE Member_WinLoss_Page SHALL navigate to `/Mobile/Home/PlayerDetail?id=<account>`.
7. THE Member_WinLoss_Page SHALL keep “赢的最多” and “输的最多” as side-by-side server-side sort controls.
8. THE Member_WinLoss_Page SHALL enforce the logged-in operator's managed-agent scope before applying the exact direct-agent filter.

### Requirement 4: 在线/离线玩家列表

**User Story:**
As an operator, I want online and offline player cards to show the same operational fields and correct totals, so that I can inspect players without opening multiple pages.

#### Acceptance Criteria

1. WHILE the online tab is active, THE Player_List_Page SHALL display the sum of `TodayWinLoss` for the currently returned online players.
2. WHILE the offline tab is active, THE Player_List_Page SHALL display the permission-scoped total win/loss for all players for the current day.
3. THE Player_List_Page SHALL display account, shortened nickname, agent account, current game, remaining score and remaining coins in the player header area.
4. THE Player_List_Page SHALL display game, room/scene, table/machine and current bet in the location row.
5. THE Player_List_Page SHALL display today win/loss and total win/loss with sign and color formatting.
6. THE Player_List_Page SHALL display active control status after the win/loss row.
7. THE Player_List_Page SHALL display the latest `UserOptLog.REC_TIME` as the last-login-time operating value for both online and offline players.
8. WHEN the player account is selected, THE Player_List_Page SHALL navigate to the player detail page; other card actions may continue to use the existing action modal.
9. THE Player_List_Page SHALL batch-load last-login and active-control data and SHALL NOT issue one database request per player.

### Requirement 5: 简化控制页面

**User Story:**
As an authorized operator, I want a compact control form that retains all three control types, so that common controls can be applied quickly on mobile.

#### Acceptance Criteria

1. THE Control_Page SHALL retain selectable control types: 吃分, 放水 and 控牌, filtered by the logged-in operator's permission bits.
2. THE Control_Page SHALL remove the redundant inner “控制” heading while retaining the page header.
3. THE Control_Page SHALL retain account query, remaining coins, today win/loss, total win/loss, online state and current control.
4. THE Control_Page SHALL display each current-control description on one visual line with horizontal overflow or truncation instead of wrapping.
5. WHERE control type is 吃分 or 放水, THE Control_Page SHALL remove the enable/disable selector and submit the enabled control with the entered target.
6. WHERE control type is 控牌, THE Control_Page SHALL retain game type and card type selectors and SHALL hide editable count/total-count inputs.
7. WHERE control type is 控牌, THE Control_Page SHALL submit `cardNumber=1` and `cardTotal=5`, meaning one controlled result within five rounds.
8. THE Control_Page SHALL label the destructive action “移除当前控制” and invoke the existing close-total-control operation.
9. THE Control_Page SHALL remove the complete bottom control-record/date-filter section.
10. THE Control_Page SHALL continue enforcing agent-line and permission checks in the server endpoint, regardless of hidden UI fields.

### Requirement 6: 代理详情、创建与权限

**User Story:**
As a super administrator or agent, I want a minimal add-agent form and a secure agent detail view, so that agent administration is consistent and sensitive actions remain restricted.

#### Acceptance Criteria

1. THE Agency_Page SHALL create a new agent using one account field and one password field, without displaying permission or child-agent switches.
2. WHEN an agent is created, THE Agency_Permission_Policy SHALL set `IsCreateAgent=1` and all other defaults defined in Requirement 7.
3. WHEN an agent account is selected, THE Agency_Page SHALL open an agent detail view instead of using the account click as hierarchy navigation.
4. THE Agency_Page SHALL keep the subordinate-count action as the explicit hierarchy drill-down control.
5. THE Agency_Page SHALL display agent account, password visibility result, registration time, agent level, invite code, parent agent, remaining coins, remaining score and last login time.
6. THE Agency_Service SHALL calculate remaining score as the sum of `users.GAME_SCORE` for users directly assigned to the selected agent.
7. THE Agency_Service SHALL calculate agent last login from the latest `AgencyOptLog.REC_TIME` whose target account is the selected agent and whose operation is login (`OPT=2`).
8. WHEN the remaining-coins recharge action is selected, THE Agency_Page SHALL navigate to the existing agent recharge/flow page with the agent account prefilled.
9. THE Agency_Service SHALL omit agent passwords from list/search JSON responses.
10. IF the logged-in operator is not a super administrator, THEN THE Agency_Service SHALL omit the selected agent password from the detail response.
11. IF the logged-in operator is not a super administrator, THEN THE Agency_Service SHALL reject agent deletion at the server endpoint.
12. WHERE the standalone “控制管理” drawer entry is hidden for non-super agents, THE Agency_Page SHALL still allow permission-scoped player control entry from player details; a default agent can therefore access only 吃分.

### Requirement 7: 统一代理默认权限并迁移现有代理

**User Story:**
As a super administrator, I want every normal agent to start with the same limited permission set, so that agent capabilities are predictable.

#### Acceptance Criteria

1. THE Agency_Permission_Policy SHALL apply to agent levels `PRIV` 1 through 8 and SHALL NOT change the super administrator (`PRIV=0`).
2. THE Agency_Permission_Policy SHALL set `IsFrozen=1`, `IsKill=1`, `IsUpDown=1`, `IsCreateAgent=1`, `KickScope=2` and `ManageScope=2`.
3. THE Agency_Permission_Policy SHALL set `IsProbability=0`, `IsRelease=0`, `IsDelete=0`, `IsViewPwd=0` and `IsKicking=0`.
4. THE Agency_Permission_Policy SHALL update both newly created agents and all existing agents with `PRIV` 1 through 8.
5. THE Agency_Permission_Policy SHALL update all level rows in `agent_permission_template` to the same defaults.
6. IF `IsKicking` is later enabled for an agent, THEN THE Agency_Service SHALL allow kicking only players inside that agent's full managed line and SHALL reject players outside the line.
7. THE Agency_Service SHALL treat viewing an agent password and deleting an agent as super-administrator-only operations without adding new permission columns.
8. THE Agency_Service SHALL ignore permission values supplied by the mobile add-agent request and SHALL apply server-owned defaults.

### Requirement 8: 独立开奖历史页面

**User Story:**
As an operator, I want a separate prize-history page grouped by non-betting game, so that notable wins and manually controlled prizes can be audited.

#### Acceptance Criteria

1. WHEN “中奖历史” is selected from a player page, THE Prize_History_Page SHALL navigate to `/Mobile/Home/PrizeHistory?id=<account>`.
2. THE Prize_History_Page SHALL list enabled games where `games.GameType <> 0`; the current seed contains 16 such enabled games.
3. THE Prize_History_Page SHALL exclude every game where `games.GameType = 0`.
4. WHERE a game is a card game (`GameType=1`), THE Prize_History_Page SHALL display hand type, score, scene/table, whether manually awarded and draw time.
5. WHERE a game is a fish or slot/other game (`GameType=2` or `3`), THE Prize_History_Page SHALL display only records whose settlement event triggered the game's winning broadcast.
6. THE Prize_History_Page SHALL support start date, end date and query, with a default range of the current day.
7. THE Prize_History_Page SHALL show an empty game card with count `0` when an enabled non-betting game has no matching records.
8. THE Prize_Record_Source SHALL store an explicit `IsManualControl` value at settlement time; THE Prize_History_Page SHALL NOT infer manual award state from later control status.
9. THE Prize_Record_Source SHALL store an explicit `IsBroadcast` value using the same condition that triggers the game winning broadcast.
10. THE Prize_History_Page SHALL enforce player visibility and agent-line permission before returning records.
11. THE Prize_History_Page SHALL paginate or bound record queries in SQL and SHALL NOT load an unbounded date range into memory.

### Requirement 9: 安全、性能与兼容性

**User Story:**
As a maintainer, I want the changes to preserve current contracts and prevent sensitive-data or query regressions, so that the mobile update is safe to deploy.

#### Acceptance Criteria

1. THE Agency_Service SHALL never serialize `M_Admin.PWD` in general agent list/search responses.
2. THE Member_WinLoss_Page SHALL use exact indexed agency filtering and SQL-side pagination, sorting and aggregation.
3. THE Player_List_Page SHALL batch-query online-player supplemental data.
4. THE Prize_History_Page SHALL use indexes covering `(UserID, CreatedTime)` and `(GameId, CreatedTime)`.
5. THE Game_DB migration SHALL be idempotent and SHALL preserve all existing accounts, balances, recharge records and game records.
6. THE mobile `.cshtml` files created by this change SHALL be UTF-8 with BOM and all new files SHALL be registered in `TTY.Web/YYT.Web.csproj`.
7. THE implementation SHALL preserve `{ total, rows }` for grid endpoints and `{ code, msg, datas }` for operation/detail endpoints.
