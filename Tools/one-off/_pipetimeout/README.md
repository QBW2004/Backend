# 管道超时排查/验证工具（一次性）

验证「游戏服（中心服）活着但卡住、不回话」时，后台会不会被拖住。

背景：`NamedPipeClientStream` **不支持** `ReadTimeout/WriteTimeout`（`CanTimeout=false`，
赋值直接抛 `InvalidOperationException: 此流上不支持超时`），所以 2026-09-18 之前
`SConnect` 的读操作**没有上限**——游戏服卡住时请求线程会一直挂着（线上表现为
玩家列表「刷新在线玩家」卡 10 秒+，且连静态文件一起卡）。修复见
`Docs/手机端后台需求规划-20260902/tasks.md` 第 24 节。

`Program.cs` 是这个工具的源码，几个模式：

| 模式 | 作用 |
|---|---|
| `server` | 扮演"占着管道不回话"的游戏服：`\\.\pipe\mynamedpipe` 接受连接后既不读也不回 |
| `probe <connectMs> <readMs>` | 直接构造 `SConnect(connectMs, readMs)` 发 QA，打印超时字段与耗时 |
| `client` | 走完整链路 `PipeGameServerClient.QueryAllOnlinePlayers()`，连调两次（第 2 次应走熔断 0ms） |
| `raw` / `manual` / `caps` / `unblock` | 分层定位用（原始字节写、StreamWriter+ReadLineAsync、逐项探测超时 API、验证 Close 能否解开阻塞） |

## 跑法（Windows，用 .NET Framework 自带的 csc）

```powershell
cd Tools\one-off\_pipetimeout
mkdir bin\Config -Force
copy ..\..\..\TTY.Web\bin\*.dll bin\
copy ..\..\..\TTY.Web\Config\MsgDefine.config bin\Config\
copy _pipetimeout.exe.config bin\
C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe -nologo -out:bin\_pipetimeout.exe `
  -r:bin\YYT.BLL.dll -r:bin\YYT.Remote.dll -r:bin\YYT.Common.dll -r:bin\YYT.Entity.dll Program.cs

# 窗口 1：假游戏服（消息管道缓冲必须给 4096，与中心服 WEB_COMMU_SIZE 一致；给 0 连小写入都会阻塞）
bin\_pipetimeout.exe server

# 窗口 2：
bin\_pipetimeout.exe probe 1000 3000     # QA 档：应 ~3000ms 返回「等待中心服回复超时」
bin\_pipetimeout.exe probe 5000 10000    # 默认档：应 ~10000ms（改前这两档都是无限等待）
bin\_pipetimeout.exe client              # 第 1 次 ~3s 返回 null，第 2 次 0ms（30s 熔断）
```

实测（2026-09-18，修复后）：`probe 1000 3000` = 3076ms、`probe 5000 10000` = 10075ms、
`client` 第 1 次 3100ms → `null`、第 2 次 0ms。

⚠️ **假服务器开着的时候别跑单元测试**：`UnitTestProj` 里有走管道的用例（充退 LK/UL），
会连到这个假服务器上卡住，`vstest` 会一直不返回。跑测试前先 `taskkill /F /IM _pipetimeout.exe`。

⚠️ `bin\` 是 gitignore 的构建产物目录，`Program.cs` + 本 README 才是入库内容。
