# Shz（水浒传）桌台改名失效修复方案

> 状态：待实施 | 日期：2026-07-09
> 涉及游戏：水浒传（Shz，gameId=53，GameType=3 拉霸）
> 涉及范围：Web 后台「系统设置 → 游戏配置」对 Shz 桌台名的管理

---

## 一、问题现象

在后台「游戏配置」页面，选择水浒传（gameId=53）的某张桌台，修改「桌名」后点「保存并热更新」，**桌名不生效**：数据库 `roomtableconfig` 表里桌名没更新，游戏端也看不到新桌名。

---

## 二、根因分析

### 2.1 改名的完整链路

```
UI: gcSave()                                   ConfigEditor.cshtml:618
   表单含 TableName + WinRate + ExchangeRate
        ↓ POST /Game/GameConfig/SaveTableConfig
GameConfigController.SaveTableConfig()         :393-405 (gameType==3 分支)
   读 TableName → 调 B_LabaGamePara.SaveTableFull(tableId, gameId, labaList, tableName)
        ↓
B_LabaGamePara.SaveTableFull()                 :152-214
   ① 写 gameconfiglaba（update 分支）
   ② if (val > 0) {                    ← 【门控点】
        发 RP 命令
        if (tableName 非空) 发 TC 命令  ← 桌名热更新被挡在这里
      }
        ↓ TC 命令（命名管道）
Center: 写 roomtableconfig.TableName + 全量重推
```

### 2.2 失效根因：`val > 0` 门控挡住了 TC

`B_LabaGamePara.SaveTableFull` 关键代码（`:168-180`）：

```csharp
var rst = ef.GameConfigLabas.Where(c => c.GameId == gameId && c.TableIndex == tableIndex).ToList();
if (rst.Count == 0) {
    // 空表：插入 paras 里的键
    foreach (var p in paras) { ... ef.GameConfigLabas.Add(p); }
} else {
    // 非空（Shz 的实际情况）：按 OptKey 匹配更新
    foreach (var row in rst) {
        tmpObj = paras.Find(_list => _list.OptKey == row.OptKey);
        if (tmpObj != null && tmpObj.OptValue > -1)
            row.OptValue = tmpObj.OptValue;
        ef.Entry(row).State = EntityState.Modified;
    }
}
int val = ef.SaveChanges();   // ← Shz 场景：无匹配行，val = 0
if (val > 0)                   // ← 门控：val=0 时整个块不执行
{
    // RP 命令 + TC 命令都在这个块里
}
```

**Shz 的实际执行**（`gameconfiglaba` 已有种子数据）：

| 现有行 OptKey（来自 mth.sql 种子） | 传入 paras 的 OptKey | 是否匹配 |
|---|---|---|
| Payout0~9 | - | 否 |
| betMin | - | 否 |
| betMax | - | 否 |
| coinsNeed | - | 否 |
| defaultBetIndex | - | 否 |
| - | ExchangeScore | **否**（现有行没有这个键） |
| - | (WinRate 没进来，见 2.3) | - |

传入的 `paras` 只有 `ExchangeScore` 一个键，而 Shz 现有行里**没有 `ExchangeScore`**，update 分支遍历所有现有行都 `tmpObj = null`，**一行都没改**，`SaveChanges()` 返回 0。

→ `val > 0` 为假 → **TC 命令（桌名热更新）被挡住不发** → 桌名不生效。

### 2.3 WinRate/ExchangeRate 对 Shz 本就是死逻辑

即使门控不挡，这两个字段对 Shz 也无效：

- **WinRate**：控制器 `:401` `winKey = gameId==39 ? "AIWinLuckyAtA2" : ((gameId==40||gameId==41) ? "PlayerWin" : string.Empty)`。**Shz(53) 不在 39/40/41 里，winKey=空，WinRate 根本不加进 paras**。
- **ExchangeRate**：即使加进 paras，Shz 现有 `gameconfiglaba` 无 `ExchangeScore` 行，update 空转；且 **Shz C++ 服务端不读 `gameconfiglaba`**（它从 `ParaBetRoom` 取兑换率，Center 的 `E_LABA_SHZ` 分支用 `GetBetPara` 而非 gameconfiglaba）。

**结论**：对 Shz 而言，WinRate/ExchangeRate 两个字段从 UI 到 BLL 到服务端**整条链都是死逻辑**，既不落库也不影响游戏。

---

## 三、修复方案

### 3.1 核心修复：桌名热更新从 `val > 0` 门控中解耦

桌名写的是 `roomtableconfig` 表（经 TC 命令），与 `gameconfiglaba` 的写入**完全无关**。因此 TC 不应受 `gameconfiglaba` 是否有改动门控。

**修改 `B_LabaGamePara.SaveTableFull`（`B_LabaGamePara.cs:152-214`）**，将 TC 命令移出 `if (val > 0)` 块，改为：只要 `tableName` 非空就发 TC。

修复后逻辑结构：

```csharp
public Msg SaveTableFull(int tableId, int gameId, List<M_GameConfigLaba> paras, string tableName)
{
    Msg msg = new Msg(0, "保存失败！");
    int tableIndex = tableId % 1000;
    using (var ef = new GameDbContext())
    {
        // ① gameconfiglaba 写入（保持原逻辑）
        var rst = ef.GameConfigLabas.Where(c => c.GameId == gameId && c.TableIndex == tableIndex).ToList();
        if (rst == null || rst.Count == 0)
        {
            foreach (var p in paras) { p.GameId = gameId; p.TableIndex = tableIndex; ef.GameConfigLabas.Add(p); }
        }
        else
        {
            M_GameConfigLaba tmpObj = null;
            foreach (var row in rst)
            {
                tmpObj = paras.Find(_list => _list.OptKey == row.OptKey);
                if (tmpObj != null && tmpObj.OptValue > -1)
                    row.OptValue = tmpObj.OptValue;
                ef.Entry(row).State = EntityState.Modified;
            }
        }
        int val = ef.SaveChanges();

        // ② RP 命令：仅当 gameconfiglaba 有改动时发（保持原门控，RP 是参数重载）
        if (val > 0)
        {
            var srv = new SConnect();
            var tmpMsg = srv.SendReadString(EScMsgType.RP, gameId);
            msg.code = tmpMsg.code;
            msg.content = tmpMsg.content;
        }

        // ③ TC 命令（桌名热更新）：解耦！只要 tableName 非空就发，与 gameconfiglaba 改动无关
        if (!string.IsNullOrEmpty(tableName))
        {
            try
            {
                var srv2 = new SConnect();
                var tc = srv2.SendTcCommand((ushort)gameId, 0, (ushort)tableIndex,
                    tableName, 1, 0u, 0, 6);
                if (tc != null && tc.code == 1)
                {
                    // 桌名热更新成功；若 RP 未发（val==0），此处补成功状态
                    if (msg.code == 0 && val == 0) { msg.code = 1; msg.content = "桌名更新成功"; }
                    else if (!string.IsNullOrEmpty(tc.content))
                        msg.content = (string.IsNullOrEmpty(msg.content) ? "" : msg.content + " ") + tc.content;
                }
                else
                {
                    msg.datas = true;
                    string tcErr = tc == null ? "服务端无响应。" : tc.content;
                    msg.content = (string.IsNullOrEmpty(msg.content) ? "保存成功" : msg.content) + "，但桌名热更新失败：" + tcErr;
                }
            }
            catch (Exception exTc)
            {
                LogHelper.WriteLog(typeof(B_LabaGamePara), exTc);
                msg.datas = true;
                msg.content = (string.IsNullOrEmpty(msg.content) ? "保存成功" : msg.content) + "，但桌名热更新异常：" + exTc.Message;
            }
        }
        else if (val == 0)
        {
            // 无桌名、无参数改动
            msg.code = 0;
            msg.content = "无改动（桌名为空且参数未变化）";
        }
        else if (val > 0 && msg.code == 0)
        {
            msg.code = 1;
            msg.content = "参数保存成功";
        }
    }
    return msg;
}
```

**修复要点**：
- TC 命令块从 `if (val > 0)` 内移到外层，独立判 `if (!string.IsNullOrEmpty(tableName))`。
- RP 命令保留 `if (val > 0)` 门控（RP 是参数重载，无改动不必发）。
- 成功状态码处理：TC 成功而 RP 未发时，也要返回 `code=1`，否则前端以为失败。
- 调试日志（`:186,:192`）可保留或删除，建议保留便于排查。

### 3.2 修复验证点

修复后，Shz 改桌名应满足：
1. 即使 `gameconfiglaba` 无任何匹配行被改（`val=0`），TC 仍发出。
2. Center 收到 TC，写入 `roomtableconfig.TableName`，`SendExtendedPara` 全量重推。
3. Shz 服务端 `s_roomTableConfigs` 桌名更新。
4. 回显接口 `GetTableConfig` 从 `roomtableconfig` 查到新桌名。

---

## 四、多余逻辑清理（建议删除）

以下对 Shz（及明星97/水果拉霸）是死逻辑或误导性逻辑，建议清理：

### 4.1 控制器：WinRate/ExchangeRate 构造（`GameConfigController.cs:396-403`）

**问题**：对 Shz(53)，`winKey=string.Empty`，WinRate 不进 paras；ExchangeRate 进了 paras 但 update 空转，且 Shz 服务端不读。

**建议**：保留 ExchangeRate（其他拉霸如 gameId 39/40 可能用），但 WinRate 的 winKey 硬编码漏了 16(明星97)/53(水浒)。若确认这些游戏不需要 winRate，建议：

```csharp
// 方案 A：若所有拉霸都不需要 winRate（推荐，最简）
// 删除 winRate/winKey 相关 4 行，只保留 ExchangeRate
int exchangeRate = form.Q<int>("ExchangeRate", -1);
string labaTableName = (form.Q<string>("TableName", string.Empty) ?? string.Empty).Trim();
List<M_GameConfigLaba> labaList = new List<M_GameConfigLaba>();
labaList.Add(new M_GameConfigLaba { GameId = gameId, OptKey = "ExchangeScore", OptValue = exchangeRate, TIME = DateTime.Now, Type = string.Empty });
msg = new B_LabaGamePara().SaveTableFull(tableId, gameId, labaList, labaTableName);

// 方案 B：若 winRate 确实只对 39/40/41 有效，保留但补注释说明
// （现状即可，但应注释 "winKey 仅对 39/40/41 生效，其余拉霸忽略 WinRate"）
```

> ⚠️ 删除前需确认 gameId 39(糖果派对)/40(水果拉霸)/41(财神发发发) 是否真在用 `AIWinLuckyAtA2`/`PlayerWin`。若在用，保留方案 B；若不在用，用方案 A。

### 4.2 UI：拉霸参数区块（`ConfigEditor.cshtml:307-319`）

**问题**：`.gc-only-3` 区块显示「玩家赢概率」和「金币兑换率」两个输入框，但对 Shz 这两个字段不落库、不影响游戏，属于**误导性 UI**--管理员以为能调，实际无效。

**建议**：
- 若保留 ExchangeRate（其他拉霸用）：保留「金币兑换率」输入框，删除「玩家赢概率」输入框（Shz/明星97 不用）。
- 若确认所有拉霸都不用这两个字段：整个 `.gc-only-3` 区块删除，拉霸只保留桌名编辑。

```html
<!-- 建议删除（若所有拉霸都不用 winRate） -->
<div class="gc-field">
    <label>玩家赢概率（0-10）</label>
    <input type="number" id="gcWinRate" name="WinRate" ... />
</div>

<!-- ExchangeRate 视其他拉霸需求决定保留与否 -->
```

### 4.3 UI：拉霸回显（`ConfigEditor.cshtml:554-557`）

```js
} else if (type === 3) {
    $('#gcWinRate').val(t.winRate);      // 若删 winRate 输入框，此行删
    $('#gcExRate').val(t.exchangeRate);  // 视保留与否
}
```

### 4.4 BLL：`SaveRoomPara` 方法（`B_LabaGamePara.cs:38-131`）

**问题**：`SaveRoomPara` 是另一条拉霸保存路径（旧控制器调用），同样有 `gameId==39/40/41` 硬编码 + ExchangeScore 逻辑。经核实，当前 `GameConfigController.SaveTableConfig` **不调 `SaveRoomPara`**，只调 `SaveTableFull`。

**建议**：确认无其他调用方后，`SaveRoomPara` 可标为废弃或删除（减少维护负担）。若不确定，保留但加 `[Obsolete]` 标注。

### 4.5 BLL：`GetGameParams` / `SaveDeskPara` / `GetGameRoomDeskPara`（`:15-30,132-140`）

```csharp
public Msg SaveDeskPara<T>(T t) { throw new NotImplementedException(); }       // :132
public List<M_GameRoomDeskPara> GetGameRoomDeskPara(int gameId) { throw new NotImplementedException(); } // :137
```

**问题**：`SaveDeskPara` 和 `GetGameRoomDeskPara` 直接抛 `NotImplementedException`，是接口 `IGamePara` 的空实现，从未被调用。

**建议**：若 `IGamePara` 接口要求保留签名，保留但加注释；否则删除。

### 4.6 调试日志（`B_LabaGamePara.cs:186,192`）

```csharp
LogHelper.WriteLog(typeof(B_LabaGamePara), string.Format("SaveTableFull TC: gameId={0} ..."));
LogHelper.WriteLog(typeof(B_LabaGamePara), "CALLING SendTcCommand NOW");
```

**问题**：临时调试日志，修复验证通过后建议删除，避免日志噪音。

---

## 五、清理项汇总表

| # | 位置 | 内容 | 处理 | 风险 |
|---|---|---|---|---|
| 1 | `B_LabaGamePara.cs:180` | `if (val>0)` 门控挡住 TC | **解耦 TC（核心修复）** | 低 |
| 2 | `GameConfigController.cs:396-403` | winRate/winKey 硬编码 | 确认后删除或补注释 | 需确认 39/40/41 是否在用 |
| 3 | `ConfigEditor.cshtml:307-319` | 拉霸参数 UI（winRate/exchangeRate） | 删 winRate；exchangeRate 视需求 | 低 |
| 4 | `ConfigEditor.cshtml:554-557` | 拉霸回显 | 跟 #3 同步 | 低 |
| 5 | `B_LabaGamePara.cs:38-131` | `SaveRoomPara` 旧方法 | 标废弃或删除 | 需确认无调用方 |
| 6 | `B_LabaGamePara.cs:132,137` | `SaveDeskPara`/`GetGameRoomDeskPara` 抛异常 | 保留签名或删除 | 低 |
| 7 | `B_LabaGamePara.cs:186,192` | 临时调试日志 | 验证后删除 | 无 |

---

## 六、实施顺序

1. **第一步（必修）**：修复 #1--`SaveTableFull` 里 TC 解耦。这是改名失效的直接根因，改完桌名即可生效。
2. **第二步（验证）**：测试 Shz 改桌名：保存 → 查 `roomtableconfig` 表 → 看游戏端是否更新。
3. **第三步（清理）**：确认 39/40/41 的 winKey 使用情况后，决定 #2/#3/#4 清理范围。
4. **第四步（可选）**：清理 #5/#6/#7 死代码和调试日志。

---

## 七、附：Shz 桌名管理的有效接口（修复后）

| 项 | 值 |
|---|---|
| 保存接口 | `POST /Game/GameConfig/SaveTableConfig` |
| 回显接口 | `POST /Game/GameConfig/GetTableConfig` |
| 桌名存储表 | `roomtableconfig`（`TableName` 列，`WHERE GAME_ID=53 AND RoomIndex=0 AND TableIndex=?`） |
| 热更新命令 | TC（二进制，命名管道 → Center → 写 roomtableconfig → SendExtendedPara 全量重推） |
| 定位键 | `tableIndex = tableId % 1000` |
| TC 参数(Shz 固定) | `enabled=1, idleFireTimeoutSec=0, idleFireKickEnabled=0, maxSeats=6` |

---

> **一句话总结**：Shz 桌台改名失效的根因是 `B_LabaGamePara.SaveTableFull` 用 `if (val > 0)` 把 TC（桌名热更新）和 gameconfiglaba 写入绑死了，而 Shz 的 gameconfiglaba update 空转导致 `val=0`，TC 被挡。修复方法：把 TC 命令块移出 `val > 0` 门控，改为只要 `tableName` 非空就发。同时 WinRate/ExchangeRate 对 Shz 是死逻辑，建议一并清理 UI 和控制器里的相关代码。
