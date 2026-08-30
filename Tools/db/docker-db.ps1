# ============================================================
#  MTH-Backend Docker MySQL 一键管理脚本
#
#  用法:
#    .\docker-db.ps1 [start|stop|status|reinit] [-Force]
#
#    start   启动 MySQL 容器(首次会自动导入 docker/mysql/init 下的 SQL)
#    stop    停止容器(数据保留, 下次 start 秒启)
#    status  查看容器状态与 MySQL 版本
#    reinit  删除数据卷并重新初始化数据库(危险, 会清空所有数据)
#
#  说明:
#    - Docker Desktop 已安装但 docker/docker-compose 可能不在 PATH,
#      脚本内置完整路径, 无需手动添加 PATH。
#    - 端口/账号/密码与 TTY.Web\Web.config 的 DbConnString 一致:
#      localhost:3306, root / 123456, database mth
# ============================================================

param(
    [ValidateSet("start", "stop", "status", "reinit")]
    [string]$Action = "start",
    [switch]$Force
)

$ErrorActionPreference = "Continue"

$root = Resolve-Path (Join-Path $PSScriptRoot "..")
$composeFile = Join-Path $root "docker-compose.yml"

# Docker 可执行文件(固定路径, 规避 PATH 问题)
$dockerBin = "C:\Program Files\Docker\Docker\resources\bin\docker.exe"
$composeBin = "C:\Program Files\Docker\Docker\resources\cli-plugins\docker-compose.exe"
$desktopExe = "C:\Program Files\Docker\Docker\Docker Desktop.exe"

# docker-compose.exe 内部会调用 docker CLI / docker-credential-desktop 等辅助程序,
# 必须把它们所在目录加入 PATH, 否则会报 "executable file not found in %PATH%"。
$env:PATH = "C:\Program Files\Docker\Docker\resources\bin;C:\Program Files\Docker\Docker\resources\cli-plugins;" + $env:PATH

function Test-DockerEngine {
    try {
        & $dockerBin info 2>$null | Out-Null
        return $LASTEXITCODE -eq 0
    } catch {
        return $false
    }
}

function Wait-DockerEngine {
    Write-Host "Waiting for Docker engine ..." -ForegroundColor DarkGray
    for ($i = 1; $i -le 60; $i++) {
        if (Test-DockerEngine) {
            Write-Host "  Docker engine ready ($i s)" -ForegroundColor DarkGray
            return $true
        }
        Start-Sleep -Seconds 1
    }
    Write-Host "  [ERROR] Docker engine did not start within 60s." -ForegroundColor Red
    return $false
}

function Start-DockerDesktop {
    if (Test-DockerEngine) { return $true }
    if (-not (Test-Path $desktopExe)) {
        Write-Host "[ERROR] Docker Desktop not found: $desktopExe" -ForegroundColor Red
        return $false
    }
    Write-Host "Starting Docker Desktop ..." -ForegroundColor Green
    Start-Process $desktopExe
    return Wait-DockerEngine
}

function Invoke-Compose {
    param([string[]]$ComposeArgs)
    & $composeBin -f $composeFile @ComposeArgs
    return $LASTEXITCODE
}

# ------------------------------------------------------------
switch ($Action) {
    "start" {
        if (-not (Start-DockerDesktop)) { exit 1 }

        # 首次启动前确认初始化 SQL 存在
        $initDir = Join-Path $root "docker\mysql\init"
        $initFiles = @("00_mth.sql", "10_动态桌台字段扩展.sql", "20_fix_scoreswitch_decimal.sql", "30_房间桌台配置表坐席扩列.sql")
        foreach ($f in $initFiles) {
            if (-not (Test-Path (Join-Path $initDir $f))) {
                Write-Host "[WARN] Missing init file: $f" -ForegroundColor Yellow
                Write-Host "       参考 $initDir\README.md 重新生成后重试。" -ForegroundColor Yellow
            }
        }

        Write-Host "Starting MySQL container ..." -ForegroundColor Green
        $code = Invoke-Compose @("up", "-d")
        if ($code -ne 0) { Write-Host "[ERROR] docker-compose up failed." -ForegroundColor Red; exit 1 }

        # 等待健康检查通过
        Write-Host "Waiting for MySQL to be healthy ..." -ForegroundColor DarkGray
        for ($i = 1; $i -le 60; $i++) {
            $status = & $dockerBin inspect --format "{{.State.Health.Status}}" mth-mysql 2>$null
            if ($status -eq "healthy") {
                Write-Host "  MySQL is healthy" -ForegroundColor DarkGray
                break
            }
            if ($status -eq "unhealthy") {
                Write-Host "  [ERROR] MySQL container unhealthy. Check logs:" -ForegroundColor Red
                & $dockerBin logs --tail 50 mth-mysql 2>&1
                exit 1
            }
            Start-Sleep -Seconds 2
        }

        Write-Host ""
        Write-Host "MySQL started successfully!" -ForegroundColor Cyan
        Write-Host "  Host   : localhost" -ForegroundColor DarkGray
        Write-Host "  Port   : 3306" -ForegroundColor DarkGray
        Write-Host "  User   : root" -ForegroundColor DarkGray
        Write-Host "  Pass   : 123456" -ForegroundColor DarkGray
        Write-Host "  Schema : mth" -ForegroundColor DarkGray
        Write-Host ""
        Write-Host "Web 端连接串(Web.config)无需修改, 启动 VS 即可使用。" -ForegroundColor Green
    }
    "stop" {
        if (-not (Test-DockerEngine)) {
            Write-Host "Docker engine not running, nothing to stop." -ForegroundColor Yellow
            exit 0
        }
        Write-Host "Stopping MySQL container ..." -ForegroundColor Yellow
        $code = Invoke-Compose @("stop")
        if ($code -ne 0) { Write-Host "[ERROR] docker-compose stop failed." -ForegroundColor Red; exit 1 }
        Write-Host "MySQL stopped (data kept in volume mth_mysql_data)." -ForegroundColor Yellow
    }
    "status" {
        if (-not (Test-DockerEngine)) {
            Write-Host "Docker engine is NOT running." -ForegroundColor Red
            exit 0
        }
        Write-Host "== Container status ==" -ForegroundColor Cyan
        & $composeBin -f $composeFile ps
        Write-Host ""
        Write-Host "== MySQL version ==" -ForegroundColor Cyan
        $running = & $dockerBin inspect --format "{{.State.Running}}" mth-mysql 2>$null
        if ($running -eq "true") {
            & $dockerBin exec mth-mysql mysql -uroot -p123456 -N -e "SELECT VERSION();" 2>$null
        } else {
            Write-Host "  (container not running)" -ForegroundColor Yellow
        }
    }
    "reinit" {
        if (-not $Force) {
            Write-Host "WARNING: 这将删除数据卷并重新导入全部 SQL, 当前数据将全部丢失!" -ForegroundColor Red
            $confirm = Read-Host "Type YES to continue"
            if ($confirm -ne "YES") { Write-Host "Cancelled." -ForegroundColor Yellow; exit 0 }
        }
        if (-not (Start-DockerDesktop)) { exit 1 }

        Write-Host "[1/2] Removing container and volume ..." -ForegroundColor Green
        $code = Invoke-Compose @("down", "-v")
        if ($code -ne 0) { Write-Host "[ERROR] docker-compose down failed." -ForegroundColor Red; exit 1 }

        Write-Host "[2/2] Recreating and importing init SQL ..." -ForegroundColor Green
        $code = Invoke-Compose @("up", "-d")
        if ($code -ne 0) { Write-Host "[ERROR] docker-compose up failed." -ForegroundColor Red; exit 1 }

        Write-Host "Reinit done. Watch logs with: docker-compose logs -f mysql" -ForegroundColor Cyan
    }
}
