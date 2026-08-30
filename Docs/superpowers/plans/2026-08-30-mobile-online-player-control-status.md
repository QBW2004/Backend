# 手机端在线玩家控制状态展示 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 在手机端在线玩家卡片中批量加载并展示每个玩家全部正在执行的总控状态。

**Architecture:** 继续复用 `/Game/UserInfo/GetActiveTotalControls`，在线玩家列表成功后发起一次批量请求。前端按 `UserID` 建立状态数组映射，将映射挂到玩家对象并由卡片渲染器输出多行状态；控制状态请求失败不影响在线玩家卡片显示。

**Tech Stack:** ASP.NET MVC5、Razor、JavaScript、jQuery、现有 `MApp` 工具函数、项目现有 UnitTestProj/MSBuild。

---

### Task 1: 明确状态格式化的可测试行为

**Files:**
- Modify: `TTY.Web/Scripts/app/phone/phone.players.js`
- Test: `UnitTestProj/` 中现有 JavaScript/页面契约测试位置（若无可执行 JS 测试框架，改用静态契约检查脚本，不引入新测试框架）

- [ ] **Step 1: 检查现有测试能力和页面契约测试入口**

运行：

```powershell
rg -n "phone\.players|OnlineUsers|GetActiveTotalControls|ViewContractTest|JavaScript|node" UnitTestProj Tools TTY.Web
Get-Content UnitTestProj\ViewContractTest.cs -Raw
```

确认仓库是否有可直接运行的 JavaScript 测试运行器；优先复用现有测试能力，不为一个渲染函数引入新的依赖。

- [ ] **Step 2: 写出失败的行为检查**

若已有 JS 测试框架，为状态格式化函数增加以下行为测试：

```javascript
it('keeps every active control for the same player', function () {
    var map = groupControls([
        { UserID: 'u1', ControlMode: 4, TargetCoins: 20000, ConsumedCoins: 12300 },
        { UserID: 'u1', ControlMode: 5, TargetCoins: 50000, GrantedCoins: 200 }
    ]);
    expect(map.u1).toHaveLength(2);
});
```

若没有 JS 测试框架，则创建一个只读 PowerShell/Node 静态检查，先断言目标脚本尚不存在批量调用、状态分组和多行输出所需标记，使检查在实现前失败。

- [ ] **Step 3: 运行检查确认失败原因正确**

运行仓库实际可用的最小测试命令；预期失败原因应是目标行为或函数尚未存在，而不是环境路径或测试语法错误。

### Task 2: 实现在线玩家总控状态批量加载与归并

**Files:**
- Modify: `TTY.Web/Scripts/app/phone/phone.players.js`（`playerCardHTML`、`loadOnline` 附近）

- [ ] **Step 1: 添加状态格式化和按玩家归并函数**

实现以下行为：

```javascript
function activeControlText(r) {
    var mode = Number(r.ControlMode);
    if (mode === 4) {
        return '吃分中... 吃分目标 ' + M.gold(r.TargetCoins) + ' / 已吃 ' + M.gold(r.ConsumedCoins);
    }
    if (mode === 5) {
        return '放分中... 放分目标 ' + M.gold(r.TargetCoins) + ' / 已放 ' + M.gold(r.GrantedCoins);
    }
    if (mode === 6) {
        var total = Number(r.CardTotal || r.TargetCoins || 0);
        var remaining = Number(r.CardNumber || 0);
        if (total <= 0 || remaining <= 0) return '';
        return '控牌中... 控牌值 ' + M.num(r.LimitCoins) + ' / 次数 ' + (total - remaining) + ' / ' + total;
    }
    return '';
}

function groupActiveControls(rows) {
    var map = {};
    (rows || []).forEach(function (row) {
        var text = activeControlText(row);
        if (!text || !row.UserID) return;
        if (!map[row.UserID]) map[row.UserID] = [];
        map[row.UserID].push(text);
    });
    return map;
}
```

所有进入 HTML 的动态值继续经过 `M.gold`/`M.num`，最终状态文本输出前使用 `M.esc`，避免接口字段形成 HTML。

- [ ] **Step 2: 在 `loadOnline` 中增加一次批量请求**

在线玩家列表取得后：

1. 提取非空、去重的玩家账号。
2. 调用 `/Game/UserInfo/GetActiveTotalControls`，参数为 `UserIDs: JSON.stringify(ids)`。
3. 成功时将分组结果挂载到每个玩家的 `ActiveControls`。
4. 请求失败时将所有 `ActiveControls` 设为空数组，然后照常渲染在线列表。

不得在 `map` 渲染过程中逐玩家请求。

- [ ] **Step 3: 运行失败测试/静态检查，确认最小实现通过**

重新运行 Task 1 的测试命令，预期多状态归并和控牌耗尽过滤检查通过。

### Task 3: 在在线玩家卡片中渲染全部控制状态

**Files:**
- Modify: `TTY.Web/Scripts/app/phone/phone.players.js`（`playerCardHTML`）
- Modify: `TTY.Web/Areas/Mobile/Views/Home/Index.cshtml`（`@section head` 样式）

- [ ] **Step 1: 添加状态区域 HTML**

在在线玩家卡片内容底部追加：

```javascript
var controls = isOnline && p.ActiveControls ? p.ActiveControls : [];
var controlRow = controls.length
    ? '<div class="active-control-status">' +
        controls.map(function (text) {
            return '<div class="active-control-status-item">' + M.esc(text) + '</div>';
        }).join('') +
      '</div>'
    : '';
```

然后将 `controlRow` 放在 `player-info` 后面。空数组必须不生成容器。

- [ ] **Step 2: 添加移动端样式**

在 `Index.cshtml` 中增加：

```css
.active-control-status {
    margin-top: 8px;
    padding: 8px 10px;
    border-radius: 8px;
    background: #f8f9fa;
    color: #ff3b30;
    font-size: 13px;
    line-height: 1.6;
    text-align: center;
}

.active-control-status-item + .active-control-status-item {
    margin-top: 2px;
}
```

- [ ] **Step 3: 运行页面契约检查**

确认脚本包含单次批量接口路径、`UserID` 分组、`join('')` 多行输出和 `M.esc`；确认离线卡片不输出控制状态区域。

### Task 4: 构建与手动验收

**Files:**
- Verify: `TTY.Web/Scripts/app/phone/phone.players.js`
- Verify: `TTY.Web/Areas/Mobile/Views/Home/Index.cshtml`

- [ ] **Step 1: 执行完整构建**

运行：

```powershell
Tools\dev\build.bat
```

预期：MSBuild 退出码为 0，无新增编译错误。

- [ ] **Step 2: 做最小静态回归检查**

运行：

```powershell
rg -n "GetActiveTotalControls|groupActiveControls|active-control-status|ActiveControls|M\.esc" TTY.Web\Scripts\app\phone\phone.players.js TTY.Web\Areas\Mobile\Views\Home\Index.cshtml
```

确认只存在一次批量控制状态请求路径，且没有在玩家循环内发送请求。

- [ ] **Step 3: 手动验收手机端页面**

登录手机端后台，打开“玩家列表”，验证：

1. 无控制状态玩家不显示控制状态区域。
2. 单条总点杀显示“吃分目标 / 已吃”。
3. 单条总放水显示“放分目标 / 已放”。
4. 单条总控牌显示“控牌值 / 次数”。
5. 同一玩家同时存在多条控制状态时，所有状态逐行显示。
6. 控牌剩余次数为 0 时不显示已耗尽的控牌状态。
7. 游戏服或控制状态接口异常时，在线玩家列表仍可显示或按既有空列表逻辑处理，不出现脚本异常。

