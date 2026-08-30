# MTH-Backend Docker 数据库环境

本项目 Web 应用基于 .NET Framework 4.8（ASP.NET MVC），**无法在 Linux Docker 容器中运行**。
因此只将 **MySQL 5.7** 容器化，Web 应用继续用本机 VS2022 + IIS Express 运行。

```
┌─────────────────────────────────────────┐
│  Windows 本机                            │
│  ┌────────────────┐   ┌──────────────┐  │
│  │ VS2022 / IIS   │   │ Docker       │  │
│  │ Express        │──▶│ MySQL 5.7    │  │
│  │ (MTH-Backend)  │   │ :3306        │  │
│  └────────────────┘   └──────────────┘  │
└─────────────────────────────────────────┘
```

## 环境要求

- Docker Desktop（已安装，v29+），WSL2 后端
- 首次使用前需启动 Docker Desktop（脚本会自动启动）

## 一键管理

在项目根目录（或任意位置）执行：

```bat
Tools\db\docker-db.bat start     :: 启动 MySQL(首次自动导入数据库)
Tools\db\docker-db.bat stop      :: 停止容器(数据保留)
Tools\db\docker-db.bat status    :: 查看容器状态与 MySQL 版本
Tools\db\docker-db.bat reinit    :: 重置数据库(清空数据后重新导入, 需输入 YES)
```

PowerShell 等价命令：

```powershell
.\Tools\db\docker-db.ps1 start
.\Tools\db\docker-db.ps1 stop
.\Tools\db\docker-db.ps1 status
.\Tools\db\docker-db.ps1 reinit -Force
```

## 手动 Docker 命令

```bash
# 在项目根目录
docker compose up -d          # 启动
docker compose stop           # 停止(保留数据)
docker compose down -v        # 删除容器并清空数据卷
docker compose logs -f mysql  # 查看 MySQL 日志
```

## 连接参数

与 `TTY.Web\Web.config` 中 `DbConnString` 完全一致，**无需修改任何配置**：

| 项     | 值                 |
|--------|--------------------|
| Host   | localhost          |
| Port   | 3306               |
| User   | root               |
| Pwd    | 123456             |
| Schema | mth                |
| Charset| utf8mb4           |

## 数据库初始化

首次启动时，容器会自动按文件名顺序执行 `docker/mysql/init/` 下的 SQL：

| 文件 | 来源 | 内容 |
|------|------|------|
| `00_mth.sql` | 根目录 `mth.sql` | MySQL 5.7.44 导出：51 张表 + 1 视图 + 3 存储过程 + 全部初始化数据 |
| `10_动态桌台字段扩展.sql` | `Docs/sql/动态桌台字段扩展.sql` | pararoom/parabetroom 动态桌台字段 |
| `20_fix_scoreswitch_decimal.sql` | `Docs/sql/fix_scoreswitch_decimal.sql` | scoreSwitch int → decimal(10,2) |
| `30_房间桌台配置表坐席扩列.sql` | `Docs/sql/房间桌台配置表坐席扩列.sql` | roomtableconfig 追加 MaxSeats |

> 这些文件为生成副本（.gitignore 已忽略），源文件在仓库根目录与 `Docs/sql/`。
> 如源文件更新，需重新复制后再 `reinit`（见 `docker/mysql/init/README.md`）。

## 数据持久化

- 数据存放在 Docker 命名卷 `mth_mysql_data`，`stop`/`restart` 不丢失
- 只有 `down -v` 或 `reinit` 才会清空并重新导入
- 首次初始化失败时：`docker compose logs mysql` 查看错误，修复 init SQL 后 `reinit`

## 编译与部署

### 一键编译

```bat
Tools\dev\build.bat        :: Clean + Release 编译
Tools\dev\build.bat Debug  :: Clean + Debug 编译
Tools\dev\build.bat noclean :: 跳过 Clean
```

`build.bat` 会自动检测并自愈环境缺口（无需管理员权限）：

| 环境缺口 | 自动处理方式 |
|----------|-------------|
| 未装 .NET Framework 4.8 Developer Pack | 自动下载 NuGet 包 `Microsoft.NETFramework.ReferenceAssemblies.net48` 到 `.build\`，并设置 `/p:FrameworkPathOverride` |
| VS 未装「ASP.NET 和 Web 开发」工作负载（缺 WebApplication.targets） | 自动下载 `MSBuild.Microsoft.VisualStudio.Web.targets` 到 `.build\`，并设置 `/p:VSToolsPath` |
| 首次构建需 NuGet 还原 | 自动调用 `Tools\dev\nuget.exe restore`（若存在） |

> 机器**已装** Developer Pack / Web 工作负载时，脚本走原生路径，行为不变。
> `.build\` 已加入 .gitignore。

### 部署（本机 IIS Express 运行）

```bat
Tools\dev\start.bat    :: 启动 IIS Express，站点 WebSite1，端口 8080
```

访问 `http://localhost:8080/Login/Index`。
数据库即本 Docker 容器（`localhost:3306`），Web.config 无需修改。

> 首次使用前需安装 IIS Express（本机已装）：
> https://www.microsoft.com/en-us/download/details.aspx?id=48264
> `start.bat` 在无 apphost.config 时会自动改用 `/path:` 直启模式。

### 部署（生产 IIS 服务器）

1. 服务器安装 IIS + .NET Framework 4.8（含 ASP.NET 功能），创建应用池（.NET v4.0 / 集成模式）
2. 将 `TTY.Web\` 整个目录（含 `bin\`、`Views\`、`Content\`、`Scripts\`、`Global.asax`、`Web.config`）复制到 IIS 站点目录
3. 按生产环境修改 `Web.config`：`connectionStrings`、`appSettings` 中的 `WebHost`、支付回调、`UploadPath`、`RecordDbPath` 等
4. 生产数据库用 `mth.sql`（或 `Tools\db\reset-db.ps1` 流程）初始化

## 常见问题

**Q: `docker compose` 命令不存在？**
Docker Desktop 的 compose 插件位于 `resources\cli-plugins\docker-compose.exe`，
一键脚本已内置完整路径，请优先使用 `Tools\db\docker-db.bat`。

**Q: 启动报 `error getting credentials`？**
需将 `C:\Program Files\Docker\Docker\resources\bin` 加入 PATH，
脚本已自动处理；手动执行 docker 命令时可先 `set PATH=...`。

**Q: 表名大小写问题？**
Linux 容器中 MySQL 默认区分表名大小写（`lower_case_table_names=0`），而项目 EF 代码
用大写表名映射（`[Table("Admin")]` 等），mth.sql 导出为小写表名，会导致所有 EF
查询报 `Table doesn't exist`。docker-compose.yml 已加 `--lower-case-table-names=1`
对齐 Windows 行为解决。**该参数在数据卷首次初始化时生效，改完需 `reinit`。**

**Q: 想换 MySQL 8.0？**
将 `docker-compose.yml` 中镜像改为 `mysql:8.0`，并用
`mth_8.0_backup_20260804.sql` 作为 00 号初始化文件后 `reinit`。
注意老驱动 MySql.Data 6.8.8 对 8.0 默认认证插件可能不兼容。
