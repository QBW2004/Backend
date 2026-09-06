# 押注类游戏统一随机倍率改造 — 方案A+B+C 执行说明

> 生成日期：2026-08-11（方案C实施后修订）
> 适用范围：押注类**四个**游戏 —— 彩金单挑（GAME_ID=2）、幸运六狮（GAME_ID=10）、金鲨银鲨（GAME_ID=29）、奔驰宝马（GAME_ID=47）
> 最终方案：**A（后台关开关）+ C（服务端代码强制随机）**；**B（SQL/表操作）已明确不做** —— C 代码级兜底后，表里配置如何都无效，B 无必要

---

## 一、背景与目标

后台 Web 的"桌台参数 → 押注赔率"里配置的倍率（出现率 ProbabilityBasis + 倍数 PayoutMultiplier），在部分桌台会作为**固定倍率**下发到服务端并覆盖服务端内置的随机倍率逻辑。

**需求**：让所有押注类游戏的所有桌台**统一使用服务端内置倍率**（六狮/金鲨/宝马为内置随机倍率，彩金单挑为内置固定倍率），后台无法再配置固定倍率。

---

## 二、方案C（已实施，核心保障）— 服务端代码强制随机

**已修改**（`MTH-Server`，四个押注服务端）：

| 文件 | 位置 | 改动 |
|---|---|---|
| `ServerBetAnimal/ServerRun.cpp` | RunPrepare 内（原 1542-1551） | `bool payOn = GetBetPayoutSnapshot(...)` → `bool payOn = false;`，AlgSetPayout 传 `nullptr` |
| `ServerBetJSYS/ServerRun.cpp` | RunPrepare 内（原 1566-1572） | 同上 |
| `ServerBetBMW/ServerRun.cpp` | RunPrepare 内（原 1562-1568） | 同上 |
| `ServerBetDT/ServerRun.cpp` | RunPrepare 内（原 1532-1538） | 同上 |

**效果**：`cfg_payout_on` 恒为 false → 服务端**永远**走内置倍率分支（Animal 黄/绿/红三色低中高随机；JSYS/BMW 6 张预设倍率表 `rand()%6` 随机；DT 内置固定倍率表），无论 `cardpayoutprofile` 表里配置什么、后台开关是否打开，均不生效。

**注意**：
- 需要**重新编译并发布**四个服务端 exe（`ServerBetAnimal.exe` / `ServerBetJSYS.exe` / `ServerBetBMW.exe` / `ServerBetDT.exe`），并重启对应进程生效。
- `GetBetPayoutSnapshot` 函数体保留未删（防止后续恢复），但已无调用点；Center 推送的配置数据仍会接收进 `s_betPayoutProfiles`，只是不再被采用。
- 恢复固定倍率 = 改回 `GetBetPayoutSnapshot(...)` 调用并重编发布（方案C的代价：恢复需重编）。

---

## 三、方案A（可选加固）— 后台逐桌关闭开关

方案C 已保证代码层不被配置，方案A 为可选的界面层清理（避免后台页面残留"已开启"状态误导）：

对四个游戏（2/10/29/47）的**每一个桌台**重复：
1. 后台 Web → 游戏配置 → 选择游戏 → 选择桌台
2. **押注赔率**区块，将开关 **"启用后按下表控制各门出现率与倍数"** 置于**关闭**状态（`ConfigEditor.cshtml:174`）
3. 点击**保存**（`GameConfigController.cs:850-901` 正常保存流程，`Enabled` 写 0，不触碰其它桌台/游戏/牌机数据）

> 若不想逐桌操作，可跳过本步 —— 方案C 已兜底，后台开关是否关闭不影响服务端行为。

---

## 四、方案B（明确不做）— 不动数据库

**不执行任何 SQL、不删表、不建备份表、不 UPDATE `cardpayoutprofile`**。理由：方案C 代码级强制后，表数据（含历史遗留的 `Enabled=1` 配置）已无实际影响；保留数据便于将来恢复方案C改动后立即还原旧配置。

---

## 五、验证

### 5.1 服务端日志
- 四个服务端重启后，每局开局仍输出 `[RunPrepare] payout-snapshot done table=X`，各桌倍率走内置分支。

### 5.2 客户端验证（主要）
进入各游戏**所有桌台**，连续观察多局下发的倍率表 `magTab`：

- **六狮/金鲨/宝马**：每个桌台的 `magTab` 每局都变化（随机）
- **彩金单挑**：桌台间按内置固定倍率表，后台配置不生效
- 客户端日志参考：`BetPrrepare: magTab-> 30 60 120 ...`（`BMW_NetworkClient.cs:670` 附近）

### 5.3 后台验证
- 任意桌台重新开启"押注赔率"开关、填任意出现率/倍数并保存 → 服务端倍率**不变**（仍为内置倍率），证明方案C生效。

---

## 六、回滚 / 恢复

| 层 | 恢复方式 |
|---|---|
| 方案C | 四个 `ServerRun.cpp` 改回 `bool payOn = GetBetPayoutSnapshot(mTableID, payProb, payMag);`（恢复数组声明），重编发布 |
| 方案A | 后台重新开启开关即可 |
| 方案B | 无需回滚（未执行任何表操作） |

---

## 七、关键代码位置（备查）

| 位置 | 说明 |
|---|---|
| `TTY.Web/Areas/Game/Views/GameConfig/ConfigEditor.cshtml:169-191` | 押注赔率区块（开关 174 行、每门输入表 181-190 行） |
| `TTY.Web/Areas/Game/Controllers/GameConfigController.cs:850-901` | 保存押注赔率：DELETE+INSERT 该桌行，`Enabled=BetPayoutOn` |
| `TTY.Web/Areas/Game/Controllers/GameConfigController.cs:1231-1241` | `GetBetItemCount`：仅 2/10/29/47 有押注门数 |
| 服务端四个 `ServerRun.cpp` | `GetBetPayoutSnapshot`（已无调用点）+ `RunPrepare` 强制 `payOn=false` |
| 服务端 `ServerCenterRun.cpp:7920-7925` | Center 仅对 E_BET_DT/ANIMAL/JSYS/BMW 四游戏读表下发 |
