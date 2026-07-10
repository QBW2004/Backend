# Shz（水浒传）桌台改名失效与拉霸配置链路问题诊断

> 状态：问题诊断 | 日期：2026-07-09
> 涉及游戏：水浒传（Shz，gameId=53，GameType=3 拉霸）
> 涉及范围：Web 后台「系统设置 -> 游戏配置」对拉霸类桌台的管理、Center 推送、Shz 子游戏接收

---

## 一、问题现象

在后台「游戏配置」页面，选择水浒传（gameId=53）的某张桌台，修改「桌名」后点「保存并热更新」，**桌名不生效**：数据库 `roomtableconfig` 表里桌名没更新，游戏端也看不到新桌名。

---

## 二、拉霸类桌台列表参数读取链路

### 2.1 读取方式：桌台维度（非大厅/房间）

Web 后台对拉霸类的桌台列表读取是**按桌台维度**的，但数据来源是**两张表拼接**：

```
桌台列表(左栏)         ← gameconfiglaba.TableIndex 去重
桌台参数(右栏)
  ├─ winRate/exchangeRate ← gameconfiglaba.OptKey/OptValue
  └─ 桌名(TableName)      ← roomtableconfig 表(SQL 直查)
```

**不走 pararoom/parabetroom**（鱼机/牌机/押注用的房间表），而是 `gameconfiglaba`（键值对表）+ `roomtableconfig`（桌名）。这是拉霸独有的混合读取模式。

### 2.2 读取代码

`GameConfigController.GetTableConfig` 拉霸分支（`:184-211`）：

```csharp
var tableList = labaBL.GetTableList(gameId);        // ① 桌台列表来自 gameconfiglaba
if (tableList.Count == 0) tableList.Add(0);
foreach (int tIdx in tableList)
{
    int tid = gameId * 1000 + tIdx;
    List<M_GameConfigLaba> labas = ...WHERE GameId==gameId AND TableIndex==tIdx;  // ② 参数从 gameconfiglaba
    int winRate = 0, exchangeRate = 0;
    foreach (M_GameConfigLaba l in labas) {
        if (l.OptKey == "ExchangeScore") exchangeRate = l.OptValue;
        else if (l.OptKey == "AIWinLuckyAtA2" || l.OptKey == "PlayerWin") winRate = l.OptValue;
    }
    string labaTableName = ef.Database.SqlQuery<string>(           // ③ 桌名从 roomtableconfig
        "SELECT TableName FROM roomtableconfig WHERE GAME_ID={0} AND RoomIndex=0 AND TableIndex={1} LIMIT 1",
        gameId, tIdx).FirstOrDefault();
    rows.Add(new { id = tid, tableName = ..., enabled = 1, winRate, exchangeRate });
}
```

`B_LabaGamePara.GetTableList`（`B_LabaGamePara.cs:143-150`）：

```csharp
return ef.GameConfigLabas.Where(c => c.GameId == gameId)
    .Select(c => c.TableIndex).Distinct().OrderBy(t => t).ToList();
```

> 桌台列表来自 `gameconfiglaba` 的 `TableIndex` 去重，不是房间表。

---

## 三、改名失效根因：两个断点叠加

改名要生效，需经 **Web -> Center -> 子游戏** 三段传递。逐段追踪发现**两个断点**：

### 3.1 断点 1：Web 侧 `val > 0` 门控挡住 TC

**位置**：`B_LabaGamePara.SaveTableFull`（`B_LabaGamePara.cs:152-214`）

```csharp
public Msg SaveTableFull(int tableId, int gameId, List<M_GameConfigLaba> paras, string tableName)
{
    int tableIndex = tableId % 1000;
    using (var ef = new GameDbContext())
    {
        var rst = ef.GameConfigLabas.Where(c => c.GameId == gameId && c.TableIndex == tableIndex).ToList();
        if (rst.Count == 0) {
            // 空表：插入 paras 里的键
            foreach (var p in paras) { ... ef.GameConfigLabas.Add(p); }
        } else {
            // 非空（Shz 实际情况）：按 OptKey 匹配更新
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
            srv.SendReadString(EScMsgType.RP, gameId);
            if (!string.IsNullOrEmpty(tableName))
                srv.SendTcCommand(...);  // ← 桌名热更新被挡在这里
        }
    }
}
```

**Shz 的实际执行**（`gameconfiglaba` 已有种子数据）：

| 现有行 OptKey（来自 mth.sql 种子） | 传入 paras 的 OptKey | 是否匹配 |
|---|---|---|
| Payout0~9 | - | 否 |
| betMin / betMax / coinsNeed / defaultBetIndex | - | 否 |
| - | ExchangeScore | **否**（现有行没有这个键） |

传入的 `paras` 只有 `ExchangeScore` 一个键，而 Shz 现有行里**没有 `ExchangeScore`**，update 分支遍历所有现有行都 `tmpObj = null`，**一行都没改**，`SaveChanges()` 返回 0。

-> `val > 0` 为假 -> **TC 命令（桌名热更新）被挡住不发** -> 桌名不生效。

**附加问题**：即使没有门控，WinRate 也存不进去：

```csharp
// GameConfigController.SaveTableConfig :401
string winKey = gameId == 39 ? "AIWinLuckyAtA2"
              : ((gameId == 40 || gameId == 41) ? "PlayerWin" : string.Empty);
```

Shz(53)不在 39/40/41 里，`winKey = string.Empty`，WinRate 根本不加进 `paras`。

### 3.2 断点 2：Shz 子游戏不处理 `COM_REQUEST_PARA_EX`

**位置**：`ServerLabaShz/ServerRun.cpp:402-421`

即使断点 1 修复（TC 能发出），Center 会用 `COM_REQUEST_PARA_EX`(0x551A) 推送桌台配置给 Shz。但 Shz 的消息路由 switch 里**没有这个 case**：

```cpp
switch (msgType)
{
case COM_CHECK_LOG_IN:    ... break;
case COM_LOG_OUT:         ... break;
case COM_LOCK_EXCHANGE:   ... break;
case COM_UNLOCK_EXCHANGE: ... break;
case COM_REQUEST_PARA:    ServerCenterRecvTablePara(br); break;   // 0x5507 ✅
case COM_TABLE_SET:       ServerCenterTableSetting(br);  break;   // 0x5508 ✅
case MSG_UPDATE_INFO:     ... break;
case MSG_UPDATE_USER_SCORE: ... break;
case COM_RECV_OTHER_GAME_MSG: ... break;
default:                  // 跳过未处理消息体           ← 【断点 2】
    for (UInt16 k = 0; k < msgLen; k++) { char c; br >> c; }
    break;
}
// COM_REQUEST_PARA_EX (0x551A) 没有 case，直接落 default 丢弃
```

Center 的 `SendExtendedPara`（`ServerCenterRun.cpp:6815-6861`）用 `COM_REQUEST_PARA_EX` 推送 `ts_RoomTableConfig` 列表（含 TableName），但 Shz **不认识这个消息类型**，直接落到 default 分支逐字节跳过，不解析。

### 3.3 两个断点的叠加效果

```
Web 改名
  │
  ├─ 断点1: SaveTableFull 的 val>0 门控
  │         gameconfiglaba update 空转 -> val=0 -> TC 不发
  │         (TC 是桌名热更新的唯一触发)
  │         ↓ 如果修了断点1 ↓
  │
  ├─ Center TC 处理 (本身没问题)
  │         写 roomtableconfig + SendExtendedPara(COM_REQUEST_PARA_EX)
  │         ↓
  │
  └─ 断点2: Shz 不处理 COM_REQUEST_PARA_EX
            即使 TC 到达 Center 并推送，Shz 也丢弃
            (Shz 没有 s_roomTableConfigs，没有 ServerCenterRecvExtendedPara)
```

**两个断点必须同时修，改名才能生效。**

---

## 四、深层原因：拉霸三服是热更新改造的"漏网之鱼"

对比所有子游戏对桌台配置块体系的支持：

| 子游戏 | `s_roomTableConfigs` | `ServerCenterRecvExtendedPara` | `GetTableConfigSnapshot` | 处理 `COM_REQUEST_PARA_EX` |
|---|---|---|---|---|
| 鱼机（11 服） | ✅ | ✅ | ✅ | ✅ |
| 押注（4 服） | ✅ | ✅ | ✅ | ✅ |
| 牌机（6 服） | ✅ | ✅ | ✅ | ✅ |
| **Shz** | ❌ | ❌ | ❌ | ❌ |
| **Fruit** | ❌ | ❌ | ❌ | ❌ |
| **Mx97** | ❌ | ❌ | ❌ | ❌ |

**3 个拉霸服（ServerLabaShz / ServerLabaFruit / ServerLabaMx97）都是"最小实现"**：

```cpp
// ServerLabaShz/ServerRun.cpp:186，ServerLabaFruit/ServerRun.cpp:176，ServerLabaMx97/ServerRun.cpp:175
// 拉霸参数最小实现：中心服 COM_REQUEST_PARA 回执体各游戏不同；此处仅置就绪标志并采用默认房间配置。
void ServerRun::ServerCenterRecvTablePara(BinaryReader &br)
{
    // 采用默认档位；真实档位应由后台下发，后续按中心服协议补全。
    for (int i = 0; i < roomMax && i < 8; i++) {
        roomInfo[i].coinsNeed = 0;
        roomInfo[i].betMin = 100;           // 写死
        roomInfo[i].betMax = 10000;          // 写死
        roomInfo[i].betScores = "100,500,1000,5000,10000";  // 写死
        roomInfo[i].defaultBetIndex = 0;
    }
    isGameParaReceived = true;              // 根本不读 br 里的内容
}
```

它们只处理老的 `COM_REQUEST_PARA`(0x5507)，**完全没有实现**后来新增的 `COM_REQUEST_PARA_EX`(0x551A，桌台配置块)接收。这是拉霸服在桌台配置块热更新改造中被遗漏的结果--鱼机/牌机/押注都补了，拉霸三服没补。

具体缺失（3 个拉霸服共同）：
- 无 `s_roomTableConfigs` 静态向量（存储桌台配置快照）
- 无 `ServerCenterRecvExtendedPara` 函数（接收 `COM_REQUEST_PARA_EX`）
- 无 `ServerCenterRoomTableConfigUpdate` 函数（接收 `COM_TABLE_CONFIG_UPDATE`）
- 无 `GetTableConfig` / `GetTableConfigSnapshot` 函数（查询桌台配置）
- 消息路由 switch 无 `case COM_REQUEST_PARA_EX` / `case COM_TABLE_CONFIG_UPDATE`
- `SendLoginRet` 末尾不写桌台配置块（拉霸用 Protobuf 登录响应，不走 AA01 通用协议）

---

## 五、Center 侧链路（本身正确，供参考）

Center 的 TC 处理和推送链路本身是正确的，问题在于"上游不发"和"下游不收"。

### 5.1 TC 接收（`ServerCenterRun.cpp:5346-5397`）

```cpp
else if (pchRequest[0] == 'T' && pchRequest[1] == 'C')
{
    ts_RoomTableConfig cfg;
    memset(&cfg, 0, sizeof(cfg));
    br >> gameID >> roomIndex >> tableIndex >> tableName;
    br >> enabled >> idleFireTimeoutSec >> idleFireKickEnabled >> maxSeats;
    cfg.GameID = gameID;
    cfg.TableIndex = tableIndex;
    strncpy(cfg.TableName, tableName.c_str(), sizeof(cfg.TableName) - 1);  // ← 桌名填入
    ret = ServerCenterRun::GetInstance()->UpdateRoomTableConfig(cfg);
}
```

### 5.2 写库 + 推送（`ServerCenterRun.cpp:6868-6893`）

```cpp
bool ServerCenterRun::UpdateRoomTableConfig(const ts_RoomTableConfig& cfg)
{
    Database::GetInstance()->UpsertRoomTableConfig(cfg);     // ← 写 roomtableconfig 表
    SendExtendedPara((UserInfo::OnlineGame)cfg.GameID);     // ← 推 COM_REQUEST_PARA_EX 给子游戏
    return true;
}
```

### 5.3 推送内容（`ServerCenterRun.cpp:6815-6861`）

```cpp
void ServerCenterRun::SendExtendedPara(UserInfo::OnlineGame gameID)
{
    std::vector<ts_RoomTableConfig> configs;
    Database::GetInstance()->GetRoomTableConfigs(gameID, configs);  // ← 从 roomtableconfig 读全量
    // ...
    bw << configCount;
    for (i ...) bw.writeRaw((const char*)&configs[i], sizeof(ts_RoomTableConfig));  // ← 含 TableName
    ComSendToGame(gameID, clob);   // ← 推给对应子游戏
}
```

> Center 这段没问题：收到 TC -> 写 roomtableconfig -> 全量重推 `COM_REQUEST_PARA_EX`（含 TableName）。但 Shz 不收。

---

## 六、完整问题清单

| # | 问题 | 位置 | 影响 | 严重度 |
|---|---|---|---|---|
| 1 | **TC 被 `val>0` 门控挡住** | `B_LabaGamePara.cs:180` | 桌名热更新不发，改名第一道断点 | 🔴 致命 |
| 2 | **Shz 不处理 `COM_REQUEST_PARA_EX`** | `ServerLabaShz/ServerRun.cpp:402-421` | 即使 TC 到 Center，Shz 也收不到桌名 | 🔴 致命 |
| 3 | **Shz 无 `s_roomTableConfigs` 存储及接收函数** | `ServerLabaShz/ServerRun.h` 全文 | 没有地方存收到的桌台配置 | 🔴 致命 |
| 4 | **winKey 硬编码漏掉 Shz(53)/Mx97(16)** | `GameConfigController.cs:401` | WinRate 存不进 | 🟡 次要(Shz 也不用) |
| 5 | **ExchangeScore 对 Shz 是死配置** | Shz 不读 gameconfiglaba | ExchangeRate 存了也没用 | 🟡 次要 |
| 6 | **payoutTable 写死** | `ServerRun.cpp:26` | 注释声称可覆盖但无写入路径 | 🟡 次要 |
| 7 | **Fruit/Mx97 同样缺失** | `ServerLabaFruit/`、`ServerLabaMx97/` | 3 个拉霸服都是最小实现，问题相同 | 🔴 致命(共性) |

---

## 七、修复方向（不改代码，仅给思路）

### 7.1 断点 1 修复：TC 解耦门控

`B_LabaGamePara.SaveTableFull` 中，将 TC 命令移出 `if (val > 0)` 块，改为只要 `tableName` 非空就发 TC。因为桌名写的是 `roomtableconfig` 表（经 TC），与 `gameconfiglaba` 写入完全无关，不应被它门控。

RP 命令保留 `if (val > 0)` 门控（参数无改动不必发 RP）。

详见已生成的 `Backend/Docs/Shz桌台改名失效修复方案.md`。

### 7.2 断点 2 修复：Shz 补齐桌台配置块接收

Shz 需要补齐与其他子游戏（鱼机/牌机/押注）相同的桌台配置块体系：

1. **新增 `s_roomTableConfigs`** 静态向量（`ServerRun.h`），存储 `ts_RoomTableConfig` 列表
2. **新增 `ServerCenterRecvExtendedPara`** 函数，接收 `COM_REQUEST_PARA_EX`，解析 `ts_RoomTableConfig` 列表存入 `s_roomTableConfigs`
3. **新增 `ServerCenterRoomTableConfigUpdate`** 函数，接收 `COM_TABLE_CONFIG_UPDATE` 单条更新
4. **新增 `GetTableConfig` / `GetTableConfigSnapshot`** 查询函数
5. **消息路由 switch 增加** `case COM_REQUEST_PARA_EX` / `case COM_TABLE_CONFIG_UPDATE`
6. **读写锁** `s_cfgLock` 保护并发访问

> 这套机制鱼机/牌机/押注都有现成实现可参考（如同源的 `ServerCenterRecvExtendedPara`），移植到 Shz 即可。Fruit/Mx97 同样需要补齐。

### 7.3 次要问题

- **winKey 硬编码**：确认 39/40/41 是否真在用 `AIWinLuckyAtA2`/`PlayerWin`（之前已核实全 Server 无引用，是死代码），若不用则删除 WinRate 相关逻辑
- **ExchangeScore**：Shz 不读 gameconfiglaba，ExchangeRate 是死配置，UI 可考虑移除或标注"无效"
- **payoutTable**：注释与实现不符，应修正注释或补全下发路径

---

## 八、修复优先级

| 优先级 | 修复项 | 效果 |
|---|---|---|
| P0 | 断点 1：TC 解耦门控 | 桌名能写入 roomtableconfig（Web 回显生效） |
| P0 | 断点 2：Shz 补齐 `COM_REQUEST_PARA_EX` 接收 | 桌名能推到 Shz 子游戏内存 |
| P1 | Fruit/Mx97 同步补齐 | 3 个拉霸服统一 |
| P2 | winKey/ExchangeScore 死代码清理 | 减少误导 |
| P3 | payoutTable 注释修正 | 代码一致性 |

> **P0 两项必须同时修**，单独修任一项改名都不生效：
> - 只修断点 1：TC 能发，Center 能写 roomtableconfig，但 Shz 收不到推送（Web 回显会显示新桌名，但游戏端不更新）
> - 只修断点 2：Shz 能收，但 TC 根本不发，Shz 永远收不到新数据

---

## 九、附：关键代码位置索引

### Web 后台
| 文件 | 行 | 函数/逻辑 |
|---|---|---|
| `GameConfigController.cs` | `:184-211` | 拉霸桌台列表读取（gameconfiglaba + roomtableconfig 拼接） |
| `GameConfigController.cs` | `:393-405` | 拉霸保存（winKey 硬编码 39/40/41） |
| `B_LabaGamePara.cs` | `:143-150` | `GetTableList`（gameconfiglaba.TableIndex 去重） |
| `B_LabaGamePara.cs` | `:152-214` | `SaveTableFull`（**断点1：val>0 门控**） |
| `SConnect.cs` | `:325-399` | `SendTcCommand`（TC 二进制命令组包） |

### Center
| 文件 | 行 | 函数/逻辑 |
|---|---|---|
| `ServerCenterRun.cpp` | `:5346-5397` | TC 接收（写 roomtableconfig） |
| `ServerCenterRun.cpp` | `:6815-6861` | `SendExtendedPara`（推 COM_REQUEST_PARA_EX） |
| `ServerCenterRun.cpp` | `:6868-6893` | `UpdateRoomTableConfig`（写库 + 推送） |
| `Database.cpp` | `:3439-3515` | `GetRoomTableConfigs`（读 roomtableconfig） |
| `Database.cpp` | `:3520-3577` | `UpsertRoomTableConfig`（写 roomtableconfig） |

### Shz 子游戏
| 文件 | 行 | 函数/逻辑 |
|---|---|---|
| `ServerRun.cpp` | `:402-421` | 消息路由 switch（**断点2：无 COM_REQUEST_PARA_EX**） |
| `ServerRun.cpp` | `:186-235` | `ServerCenterRecvTablePara`（最小实现，写死默认值） |
| `ServerRun.cpp` | `:237-257` | `ServerCenterTableSetting`（接收 dif/har 热更新） |
| `ServerRun.h` | 全文 | 无 `s_roomTableConfigs` / 无 `ServerCenterRecvExtendedPara` 声明 |
| `ServerRun.cpp` | `:26` | `payoutTable` 写死（注释声称可覆盖但无写入路径） |

---

> **一句话总结**：Shz 桌台改名失效根因是两个断点叠加--① Web 侧 `SaveTableFull` 的 `val>0` 门控让 TC 不发（gameconfiglaba update 空转导致 val=0）；② Shz 子游戏不处理 `COM_REQUEST_PARA_EX`（3 个拉霸服都是"最小实现"，未接入桌台配置块体系）。两个断点必须同时修，改名才能生效。拉霸类桌台列表参数读取是桌台维度（gameconfiglaba.TableIndex + roomtableconfig 桌名拼接），不走大厅/房间。
