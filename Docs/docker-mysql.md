# MTH-Backend Docker 数据库环境

> 2026-11-05：数据库入口统一为 [Database](../Database/README.md) 中的全量库和干净库。旧快照与初始化副本退出当前入口；历史迁移保留作证据，不自动重跑。

Web 应用使用 .NET Framework 4.8、ASP.NET MVC5，运行在 Windows IIS/IIS Express；Docker 只运行 MySQL 5.7。连接凭据从本地配置读取，不在文档中复制。

## 唯一初始化来源

- `Database/mth_full.sql`：线上全量快照，用于受控恢复与核对，含业务数据。
- `Database/mth_clean.sql`：完整结构与必要配置，按随库清理清单移除测试/运营记录，用于全新环境。
- `docker-compose.yml` 直接只读挂载 clean 文件，不复制 SQL、不追加 `Docs/sql` 历史补丁。源文件不存在时拒绝创建挂载路径。
- Docker 只在**新数据卷首次启动**时导入。更新 clean 文件不会升级现有库；现有环境应按当前发布计划执行必要增量。

完整功能还需要与数据库兼容的后台、中心服、各游戏服、Robot，以及正确的连接/域名/管道配置和必需状态文件。数据库导入成功不能代替这些验证。游戏开关与清理后的管理员初始化方式以 `Database/README.md` 和本次验证证据为准。

## 本地启动

安装 Docker Desktop 并启用 WSL2 后端，在仓库根运行：

```powershell
.\Tools\db\docker-db.ps1 start
.\Tools\db\docker-db.ps1 status
.\Tools\db\docker-db.ps1 stop
```

连接位置、端口与凭据分别核对 `docker-compose.yml` 和本机 `TTY.Web/Web.config`，不要以文档示例覆盖实际配置。容器设置 `lower_case_table_names=1`，确保 EF 大写实体表名匹配小写数据库表名。

数据保存在命名卷 `mth_mysql_data`；stop/restart 不清数据。`docker-db.ps1 reinit` 和 `docker compose down -v` 会删除现有卷，只用于已授权的隔离环境。

## 重建指定本地库

先查看计划，确认库名和导入文件：

```powershell
.\Tools\db\reset-db.ps1 -DbName mth_validation -Port 33308 -DryRun
.\Tools\db\reset-db.ps1 -DbName mth_validation -Port 33308
```

脚本要求显式库名，只接受 `127.0.0.1`、`localhost` 或 `::1`，使用 TCP。默认 clean；`-SqlFile` 可选择不含 CREATE/DROP DATABASE 和 USE 的单库快照。正式执行前确认删除范围，密码由 `MYSQL_PWD` 或交互安全输入提供。`-DryRun` 不连接、不执行 SQL；`-Force` 仅跳过删除确认。

## 导出与新装

`Tools/db/export-db.ps1` 默认把完整单事务备份写到仓库外 `../MHT-Backend-db-archives/`，包含二进制列、存储过程、函数、触发器和事件，并打印 SHA256 与耗时。旧备份不会被覆盖；验证通过后按本次整合流程更新两个权威文件。

全新 Windows MySQL 环境可由 `Tools/server-env/env-check.ps1 -InitSchema` 在新安装时导入 clean；该脚本默认安装组件，纯检查用 `-CheckOnly`。不要在现有生产数据库运行重建命令。

## Web 与跨端验证

```powershell
.\Tools\dev\build.bat noclean
.\Tools\dev\start.ps1
```

起站前确认连接指向本地隔离库和隔离管道。登录页面返回 200 只证明入口可访问；还需核对受保护页面、游戏配置、触发器、存储过程及对应服务端行为。验证范围和耗时写入本次数据库证据。

如果 Docker 命令不在 PATH，使用 `Tools/db/docker-db.ps1` 的已配置入口。表名大小写参数在数据卷初始化时生效；不要为调整参数自动重建已有业务卷。MySQL 8 的旧快照不再作为替代初始化入口。
