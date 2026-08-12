## 目标
把 MHT-Backend 所需的 **MySQL 5.7** 环境装进本机 Docker 容器（Web 应用继续用本机 VS2022/IIS Express 跑，因为 .NET Framework 4.8 无法在 Linux 容器运行）。

## 环境事实
- Docker Desktop v29.6.2 已安装但引擎未启动（WSL2 后端，Ubuntu-24.04 已就绪）
- `docker compose` 子命令当前不可用 → 脚本统一用 `C:\Program Files\Docker\Docker\resources\bin\docker-compose.exe` 的完整路径调用
- 本机无 MySQL、3306 端口空闲
- 项目连接串固定为 `Server=localhost;Port=3306;Database=mth;Uid=root;Pwd=123456`（`TTY.Web/Web.config`），容器将与之完全对齐

## 实施步骤

### 1. 启动 Docker 引擎
启动 Docker Desktop 并轮询 `docker info` 直到就绪（首次启动 WSL2 可能需 1-2 分钟）。

### 2. 新增 `docker-compose.yml`（项目根目录）
服务 `mysql`：
- 镜像 `mysql:5.7`
- 环境变量：`MYSQL_ROOT_PASSWORD=123456`、`MYSQL_DATABASE=mth`、`TZ=Asia/Shanghai`
- 启动参数：`--character-set-server=utf8mb4 --collation-server=utf8mb4_unicode_ci --default-time-zone=+08:00`
- 端口：`3306:3306`
- 数据卷：命名卷 `mth_mysql_data`（持久化，`down -v` 才重置）
- 初始化挂载：`./docker/mysql/init:/docker-entrypoint-initdb.d:ro`（首次启动自动导入）
- `healthcheck`：`mysqladmin ping`，并加 `depends_on.condition: service_healthy`

### 3. 准备初始化 SQL（`docker/mysql/init/`）
- 复制根目录 `mth.sql`（5.7.44 匹配导出）→ `00_mth.sql`
- 按项目 `reset-db.ps1` 的补丁流程复制 3 个补丁：
  - `Docs/sql/动态桌台字段扩展.sql` → `10_动态桌台字段扩展.sql`
  - `Docs/sql/fix_scoreswitch_decimal.sql` → `20_fix_scoreswitch_decimal.sql`
  - `Docs/sql/房间桌台配置表坐席扩列.sql` → `30_房间桌台配置表坐席扩列.sql`
- 目录放 `.gitignore` 忽略生成文件（由仓库文件复制生成）

### 4. 一键脚本 `Tools/docker-db.bat` + `Tools/docker-db.ps1`
沿用项目 Tools 脚本风格，支持 `start / stop / status / reinit`：
- `start`：启动 Docker 引擎 → `docker-compose up -d` → 等待 healthy
- `stop`：`docker-compose stop`
- `status`：`docker-compose ps` + MySQL 版本
- `reinit`：`docker-compose down -v` 后重新导入
- 内置 Docker 可执行文件完整路径，解决 PATH 问题

### 5. 验证
- 容器内 `mysql -uroot -p123456` 执行 `SELECT VERSION()` 应为 5.7.x
- 表数量 ≥ 51、存储过程存在（`SHOW PROCEDURE STATUS`）
- 用 Web.config 同款连接参数（root/123456, 3306, mth, utf8mb4）实际连接一次
- 补丁若有兼容性报错：查看容器 init 日志（`docker-compose logs mysql`）定位并修正

## 交付物
- `docker-compose.yml`
- `docker/mysql/init/`（含生成说明与 .gitignore）
- `Tools/docker-db.bat` / `Tools/docker-db.ps1`
- `Docs/docker-mysql.md`（使用说明：启动、停止、重置数据库）

## 不在范围内
- Web 应用容器化（.NET Framework 4.8 需 Windows 容器，本次不做）
- 数据库内容迁移到其他环境