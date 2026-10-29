---
name: mth-server-deploy
description: >
  MTH 游戏平台服务端整站部署：在一台全新的 Windows Server 上从零搭起「MySQL 5.7 (mth 库)
  + 运营后台 TTY.Web/YYT.Web (IIS, ASP.NET MVC5/.NET 4.8) + 游戏服集群
  (ServerCenterNew 中心服 + 14 款子游戏 + ServerManager Daemon/Admin + ServerRobot)」。
  使用现成产物：游戏服二进制 zip（线上在跑版本）、Web 部署 zip、清档版数据库模板
  mth_template.sql（表结构+全部游戏配置，玩家/代理/流水已清空，仅留 atmadmin/123456）。
  触发词："部署服务端"、"搭建游戏服"、"装服务器"、"部署 MTH"、"server deploy"、
  "新机器部署"、"整站部署"、"把游戏部署到服务器"、"服务端安装"、"部署包"、"上线部署"。
  只要是把这套游戏平台装到一台新 Windows 服务器上，就用本 skill。
---

# MTH 服务端整站部署（DB + 后台 + 游戏服）

> 目标：把一台**全新 Windows Server**（2016/2019/2022，4C8G 起步，生产建议 8C/16G）
> 变成可运营的 MTH 整套服务端。全程约 30~60 分钟，取决于网络与下载速度。
> 所有步骤在**目标服务器上、管理员 PowerShell** 里执行（SSH 远程也行，注意第 8 节的坑）。

## 0. 产物清单（先确认这些文件在手）

| 产物 | 位置 | 内容 |
|---|---|---|
| 数据库模板 | `assets/mth_template.sql`（本 skill 目录，~300KB） | mth 库：59 表 + 触发器 + 视图 + 存储过程；**保留**全部游戏/桌台/牌型/机器人配置与 games 开关；**已清空**玩家/代理/流水/日志；唯一账号 `atmadmin`/`123456` |
| 游戏服二进制 | `deploy-template/MTH-Server-Binaries_20261018.zip`（仓库根，~161MB） | 28 个 `Server*` 目录的 `x64\Release\`（exe + 15 个运行 DLL + 状态文件 + 中心服 pdb），含 `servers.ini` / `mth_pipe.ps1` / `pipe_cmd.ps1`。线上在跑版本 |
| 后台站点包 | `deploy-template/TTY.Web_1.0.61.zip`（~31MB） | 编译好的运营后台站点（含 Web.config 模板） |
| 部署脚本 | `scripts/`（本 skill 目录） | env-check / import-db / deploy-web / open-ports / install-autostart / verify-deploy / mth_pipe / pipe_cmd |

⚠️ `deploy-template/` 下的 zip 体积大**不入 git**，随 skill 目录一起拷贝分发。
源码侧参考：后台仓库 `MHT-Backend`（本仓）、游戏服仓库 `MTH-Server`（HTM77）——
本 skill 用二进制部署，**不需要**编译环境；如需自行编译见第 9 节。

## 1. 架构与端口（先看清再动手）

```
玩家 App ──裸 TCP──► :9000 中心服 + :91xx/92xx/93xx/94xx 各子游戏端口
玩家 App ──HTTP───► :8081 后台 /api/*（充值回调/客服/兑换码等）
运营/代理 ──HTTP──► :80   后台管理界面（可套 CDN/前置反代）
                 :8080 （可选）留给反向代理中转的受限端口
本机内部：MySQL :3306（仅本机！）· 命名管道 mynamedpipe（后台→中心服指令）
         · \\.\pipe\MTH_ServerPipe（Daemon 控制）· \\.\pipe\MTH_RobotPipe（机器人热更）
         · :9600 ServerRobot 监听 · :80xx/81xx 中心服↔子游戏 COM 回连（仅 127.0.0.1）
```

三件套**必须同机**：游戏服连 `127.0.0.1` MySQL 与本地管道是写死的。
目录约定（与线上一致，脚本默认值都是这套）：

| 用途 | 路径 |
|---|---|
| 游戏服 | `C:\Server\<Server*> \x64\Release\` + `C:\Server\servers.ini` |
| 后台站点 | `C:\Backend` |
| MySQL 5.7 | `C:\mysql`，服务名 `MySQL57` |
| 日志 | `C:\Server\Logs\*.log`（游戏服）、`C:\Backend\Logs`（站点） |

## 2. 部署步骤（按顺序）

### Step 0 — 上传产物

把整个 skill 目录 + `deploy-template/*.zip` 拷到服务器，例如 `C:\MTH-Deploy\`。
下文命令假设产物在 `C:\MTH-Deploy\`，实际路径相应替换。

### Step 1 — 系统环境（env-check.ps1）

```powershell
powershell -ExecutionPolicy Bypass -File scripts\env-check.ps1
# 自动检测+安装：.NET 4.8 / VC++ 2015-2022 x64 / IIS+ASP.NET 4.5 / MySQL 5.7（装到 C:\mysql，
# 服务 MySQL57，root 密码默认 123456）/ 防火墙 Web 端口。幂等，可重跑。
# 仅巡检不改动机子：加 -CheckOnly；MySQL 要换 root 密码：-MySqlRootPassword <pwd>（但见第 7 节警告）
```

Windows Server 2012 R2 缺 UCRT 时改用 `Tools/server-env/fix-legacy-ucrt.ps1`（KB 补丁链，需重启）。

### Step 2 — 数据库（import-db.ps1）

```powershell
powershell -ExecutionPolicy Bypass -File scripts\import-db.ps1 `
    -SqlFile C:\MTH-Deploy\mth_template.sql -Password 123456
```

- 模板文件自带 `CREATE DATABASE IF NOT EXISTS mth` + `USE`，直接灌。
- ⚠️ **它会把已有同名库整库覆盖**（脚本对非空 mth 会先拒绝，`-Force` 才放行）。
- 导入后应看到 `tables>=59 / games=14 / admin=1 / triggers>=1`。
- ⚠️ **千万别在已有生产数据的机器上跑这条**——就是全新部署用的。

### Step 3 — 游戏服（解压二进制 → 守护任务 → Start-All）

```powershell
# 3.1 解压到 C:\Server（zip 里第一层就是各 Server* 目录 + servers.ini + mth_pipe.ps1）
Expand-Archive C:\MTH-Deploy\MTH-Server-Binaries_20261018.zip C:\Server -Force

# 3.2 确认 servers.ini 里的 ServerRoot 与实际路径一致（默认 C:\Server，一般不用改）
#     [Flags] 段控制哪些子游戏参与一键启停；当前按线上开放清单=14 款，已配好。

# 3.3 装守护进程开机任务并立即拉起 Daemon（不自动拉起游戏——见下条）
powershell -ExecutionPolicy Bypass -File scripts\install-autostart.ps1 -StartAllOnBoot
#   -StartAllOnBoot 额外注册 MTH_StartAll：开机延时后经管道发 Start-All
#   （Daemon 自身开机不会拉起游戏，这是已知缺口，此任务补齐）

# 3.4 发“启动全部”：Daemon 先起中心服，等 10 秒再拉各子游戏
powershell -ExecutionPolicy Bypass -File C:\Server\mth_pipe.ps1 -Cmd Start

# 3.5 等 ~60 秒后验证：应有 15 个 Server* 进程、9000+14 个游戏端口在监听
powershell -ExecutionPolicy Bypass -File scripts\verify-deploy.ps1
```

要点：
- 每个 `x64\Release\` 里 exe 之外必须齐 **14 个 Poco*.dll + libmysql.dll**（zip 已带齐）；缺 DLL 表现为进程秒退或日志 `LocalCommu Break!!!` 死循环。
- `ServerCardDscj/DscjSave.bin`、`ServerCardDazhi/DaZiBan.bin`、`ServerCardNBA/NBASave.bin` 是**必需状态文件**（zip 已带），缺了会崩溃重启循环（Daemon 日志 `异常退出 3221226505`）。`ServerCardDscj\Dscj\CardDscj_Alg_Log-*.txt` 空占位文件同理。
- 启动顺序是 Daemon 内部保证的：中心服先起并等 10s；若手工启进程也必须中心服先行，否则子游戏一直 `re-request table para`。
- 机器人 `ServerRobot` 默认**不随 Start-All 拉起**（按需在后台「机器人监听进程」或管道 `-Cmd Start -Name` 单独启；多开会塞满牌桌，见第 8 节）。

### Step 4 — 运营后台（deploy-web.ps1）

```powershell
powershell -ExecutionPolicy Bypass -File scripts\deploy-web.ps1 `
    -SourcePath C:\MTH-Deploy\TTY.Web_1.0.61.zip -Port 8081 -Yes
#   自动：备份旧 C:\Backend → robocopy 新内容 → 应用池 v4.0/64位 →
#   Default Web Site 指向 C:\Backend → 补 8081 绑定 + 防火墙 → 回收池 → HTTP 探测。
```

- 应用池必须 **v4.0 / Integrated / 64 位**（不开 32 位兼容）——脚本已处理。
- 站点的 **80 端口**绑定 IIS 默认自带就有；客户端 API 走 8081；如需反代入口另加 8080（第 5 步用 `-TransitIp` 限源）。
- 部署完检查 `C:\Backend\Web.config` 的 `DbConnString`：默认 `Uid=root;Pwd=123456` 即可用；
  若 MySQL root 密码不是 123456，改这里（游戏服侧见第 7 节硬编码说明）。

### Step 5 — 防火墙（open-ports.ps1）+ 云安全组

```powershell
powershell -ExecutionPolicy Bypass -File scripts\open-ports.ps1
#   开：80、8081（后台）；9000 + 20 个子游戏端口（玩家 TCP）。
#   有 nginx 中转再跑：-TransitIp <中转IP>  （8080 只放行该 IP）
```

- ⚠️ 云主机是**双层防护**：Windows 防火墙之外还有**云安全组**，两边都放行才通。
- **3306（MySQL）不对外开放**；9600（机器人监听）不对外开放。
- 玩家连游戏是**裸 TCP 直连游戏端口**，不能只开 80/443——CDN/443 拦不住也转不了游戏流量。

### Step 6 — 总验证（verify-deploy.ps1）

```powershell
powershell -ExecutionPolicy Bypass -File scripts\verify-deploy.ps1
```

全绿后手工确认三件事：
1. `http://<服务器IP>/` 或 `:8081` 返回后台登录页（GET `/` 跳 `/Login/Index` 正常）。
2. 后台登录 `atmadmin / 123456` 成功 → **立刻改密**（后台「修改密码」或直接改 `admin.PWD`）。
3. `C:\Server\Logs\中心服务器日志.log` 滚动正常、无 DB 连接报错；各子游戏日志无 `connect 中心服失败`。

## 3. 部署后必改配置（上线清单）

`C:\Backend\Web.config` 里这些值随包带来，**按新环境改掉**：

| 键 | 说明 |
|---|---|
| `DbConnString` | MySQL 连接串（默认 root/123456 可用，生产建议换强密码——但要同步给游戏服，见第 7 节） |
| `WebHost` | 对外主域名 |
| `Andriod_Url` / `PC_Url` / `IOS_Url` | 客户端下载地址（配合 `C:\Backend\Upload\` 里的安装包） |
| `PayOrderNotify` / `DPayOrderNotify` | 支付回调，**必须指向本机**:8081（如 `http://<本机IP>:8081/api/PayOrderNotify`），且到支付商户后台同步登记 |
| `payUrl`/`shop_id`/`shop_key`、`X2*`、`api_*`/`secretKey`/`api_token`/`notify_token` | 三方支付/额度接口密钥，换成自己的商户参数 |
| `jiaxincloudURL` | 客服链接 |
| `UploadPath` | 上传目录，默认 `D:\Uploads`，单盘机器改 `C:\Backend\Upload`（deploy-web 保留该目录） |
| `JackpotDir_*`（Dscj/NBA/AttMhb） | 牌机奖池落盘目录，保持 `C:\Server\<对应>\x64\Release` |
| `WebVer` | 版本号自增即可 |
| `serverName`/`pipeName`/`robotPipeName` | 管道名 `.`/`mynamedpipe`/`MTH_RobotPipe`，不用动 |

客户端侧：游戏 APK 的服务器地址在 Unity 客户端 `Network.cs`/`DefaultServerIp`（MTH-git 仓）里，
换服务器要么改域名 A 记录（若客户端走域名）要么改 IP 重打包——**裸 TCP，不能套 CDN**。

## 4. 日常运维速查

```powershell
# 守护管道（在服务器本机跑；Daemon 必须活着）
powershell -File C:\Server\mth_pipe.ps1 -Cmd Status      # 全部进程状态
powershell -File C:\Server\mth_pipe.ps1 -Cmd Stop        # 停全部（⚠️ 不含 ServerRobot）
powershell -File C:\Server\mth_pipe.ps1 -Cmd Start       # 起全部（中心服先起+10s；⚠️ 不含 ServerRobot）
powershell -File C:\Server\mth_pipe.ps1 -Cmd Stop  -Name CardPhenix   # 停单个（-Name 用 servers.ini 键名）
powershell -File C:\Server\mth_pipe.ps1 -Cmd Start -Category Fish     # 按类起（Fish/Card/Bet/Laba）
powershell -File C:\Server\mth_pipe.ps1 -Cmd Start -Name Robot        # 机器人（Robot/ServerRobot 均可，映射 Target=3）
# 原始版（等价）：pipe_cmd.ps1 -Cmd <0Ping|1Start|2Stop|3Status> -Target <0All|1Category|2Single|3Robot>
```

- 「指令已下发」只是 Daemon **已受理**的异步应答，不代表执行完——每次 Start/Stop 后用 `-Cmd Status` + `Get-Process Server*` 复核实际存活数（防双开/假停止）。
- **全停（含机器人）顺序**：`-Cmd Stop -Name ServerRobot` → `-Cmd Stop` → `Get-Process | ? ProcessName -like 'Server*'` 应为空，有残余按 PID `Stop-Process -Force` 清场；恢复时 `-Cmd Start`（等 ~60s）→ 确认无双开 → 需要机器人再 `-Name Robot` 单起。
- **重启中心服 = 连锁重启全部游戏**：子游戏 COM 断链超时自行退出，Daemon 不会拉「正常退出」的进程；标准流程=停中心服→换件→起中心服→等15s→Start-All→等60s→确认无双开。
- **Daemon 重启会丢托管状态**：重启 Daemon 前先 Stop-All 清场（`KillProcessByExactPath` 按路径清孤儿），否则再 Start 必双开——**且 Stop-All 不含 ServerRobot**，重启 Daemon 前若它在跑要单独 `-Name ServerRobot` 停掉，否则之后 StartRobot 必双开塞满牌桌（线上实案）。
- **Admin.exe 只能在 RDP 桌面交互运行**——经 SSH/脚本拉起会在 stdin EOF 后狂建进程吃满 CPU（已修过，仍别试）。杀 Admin 前先确认它不是 Daemon 父进程（同会话 Job 会连带杀 Daemon+全部游戏）。
- 日志：`C:\Server\Logs\<中文名>日志.log`（UTF-8）、Daemon 日志 `C:\Server\ServerManager\x64\Release\MTH_Daemon.log`（GBK）、站点 `C:\Backend\Logs` + `C:\inetpub\logs\LogFiles`。
- 后台定时任务（60s）：指令发件箱重试 / 登录失败解封 / 6 张日志表 7 天滚动清理，IIS 回收后会随首个请求重新挂上。

## 5. 下线/上线某款游戏

- 下线：后台「游戏管理」关 `games.Enable=0` → `servers.ini` `[Flags]` 对应项改 false → 重启 Daemon（`Stop-Process Daemon` → `schtasks /run /tn MTH_Daemon`）。
- 上线（含已下线的拉霸/鱼机老游戏）：后台开 `games.Enable=1`（**缺行/Enable=0 的游戏永远连不上中心服**，AA01 会挂死）→ `servers.ini` 补条目+开 Flag → 防火墙确认该端口已放行 → 重启 Daemon → Start-All。
- 二进制包已含全部 28 款服务的文件；当前 servers.ini 只启 14 款（与 `games` 表一致）。

## 6. 数据库说明

- 模板是**清档版**：可开局的全部配置都在（games/para*/roomtableconfig*/cardpayoutprofile/betgamecfg/notice/机器人表…），玩家/代理/流水/日志为空，唯一账号 atmadmin/123456。
- 含 `trg_users_login_record` 触发器（玩家登录时间统计依赖它）与 `idx_*` 性能索引，直接灌即可，无需再跑补丁。
- 已有数据的新部署想保留数据：先 `mysqldump --routines --triggers mth > backup.sql` 再决定是否套模板。
- Windows MySQL 默认 `lower_case_table_names=1`，代码大写表名映射依赖它——若用 Linux/Docker MySQL 必须显式加 `--lower-case-table-names=1`。

## 7. ⚠️ 硬编码与安全红线

- **游戏服二进制把 DB 连接写死在编译期**（`Common/Config.h` → `host=127.0.0.1;user=root;password=123456;db=mth`）。
  新机器要么 MySQL root 密码就是 `123456`，要么改源码重新编译——运维上就是"root/123456 是这个二进制包的要求"。
  至少做到：3306 不对公网开放（Windows 防火墙 + 云安全组双确认）、后台 Web.config 的 Pwd 与 MySQL 实际密码一致。
- atmadmin 默认密码 123456，**首登必改**；admin 表密码是**明文**存储，谁拿到库谁看到全部代理密码。
- 8080 在生产是「只放行 nginx 中转 IP」的受限端口，别对公网放开。
- 模板来自线上快照，Web.config 里残留的三方密钥（shop_key/api_token 等）上线前必须替换或清除。

## 8. 远程执行注意（SSH 部署时）

- 远程跑 ps1：**文件必须纯 ASCII**（PS5.1 把无 BOM UTF-8 当 GBK 读，中文注释会炸）；
  或用 `-EncodedCommand`（UTF-16 base64，命令行有 ~8KB 上限）/ scp 上传后 `-File`。
- SSH 里 `Start-Process` 拉起的进程随会话结束被回收——常驻进程一律走计划任务（MTH_Daemon 已是）。
- Admin.exe 严禁非交互启动（见第 4 节）。

## 9. 自行编译（可选路径）

- 后台：`MHT-Backend` 仓 `Tools\dev\build.bat` → `Tools\deploy\pack.ps1 -Version x.y.z` 出 zip。
- 游戏服：`MTH-Server` 仓 `bat\Manage-BNXX.bat build all`（需 VS2022+v143、git-lfs、third_party pocolink/protobuf/thrift、
  `mklink /J PocoLink third_party\pocolink`；细节见该仓 AGENTS.md/README）。
  编译前在 `Common/Config.h` 选品牌宏/改 DB 串，端口常量也在那里。

## 10. 排障速查

| 现象 | 先看 |
|---|---|
| 子游戏秒退/反复重启 | Release 目录 15 个 DLL 是否齐；状态文件（DscjSave.bin 等）是否在；`MTH_Daemon.log` |
| 子游戏起来了但玩家登录无回包 | `mth.games` 里该 gameID 是否 Enable=1；COM 口 80xx 是否监听 |
| 后台打开报表白/500 | 应用池是否 v4.0/64 位；`C:\Backend\Logs`；DbConnString 密码 |
| 后台改配置游戏不生效 | `mynamedpipe` 是否通（后台→中心服管道）；中心服日志 |
| 某端口外网不通 | 先分清 Windows 防火墙还是云安全组（开 `pfirewall.log` 看有没有 DROP 记录） |
| 重启后游戏全没起 | MTH_Daemon 只拉 Daemon 不拉游戏——装 `-StartAllOnBoot` 或手工 Start |
| 牌桌全是机器人 | ServerRobot 双开了（两实例座位计划取并集→全桌机器人）：`Get-Process ServerRobot` 确认实例数 → `-Cmd Stop -Name Robot` 清场（KillServer 按路径杀孤儿）→ 复核 0 存活 → `-Cmd Start -Name Robot` 起一个 |
