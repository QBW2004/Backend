param(
    [string]$User = "root",
    [string]$Password = "123456",
    [int]$Port = 3306,
    [switch]$Stop,
    [switch]$Status
)

$mysqlPaths = @(
    "C:\mysql\bin",
    "C:\Program Files\MySQL\MySQL Server 8.4\bin",
    "C:\Program Files\MySQL\MySQL Server 8.0\bin",
    "C:\Program Files\MySQL\MySQL Server 5.7\bin"
)

$mysqlDir = $null
foreach ($p in $mysqlPaths) {
    if (Test-Path (Join-Path $p "mysql.exe")) {
        $mysqlDir = $p
        break
    }
}

if (-not $mysqlDir) {
    Write-Error "mysql.exe not found in any known path"
    exit 1
}

$mysqld = Join-Path $mysqlDir "mysqld.exe"
$mysql  = Join-Path $mysqlDir "mysql.exe"

# --- Status check ---
if ($Status) {
    $result = & $mysql -u $User --password=$Password -P $Port -e "SELECT 1;" 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "MySQL is RUNNING on port $Port" -ForegroundColor Green
        $ver = & $mysql -u $User --password=$Password -P $Port -e "SELECT VERSION();" 2>&1 | Select-Object -Last 1
        Write-Host "  Version: $ver" -ForegroundColor DarkGray
    } else {
        Write-Host "MySQL is NOT running" -ForegroundColor Red
    }
    return
}

# --- Stop ---
if ($Stop) {
    Write-Host "Stopping MySQL ..." -ForegroundColor Yellow
    & $mysql -u $User --password=$Password -P $Port -e "SHUTDOWN;" 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "MySQL stopped" -ForegroundColor Yellow
    } else {
        # fallback: try net stop
        net stop MySQL 2>$null | Out-Null
        net stop MySQL84 2>$null | Out-Null
        Write-Host "Attempted service stop" -ForegroundColor Yellow
    }
    return
}

# --- Start ---
# Check if already running
$check = & $mysql -u $User --password=$Password -P $Port -e "SELECT 1;" 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "MySQL is already running on port $Port" -ForegroundColor Green
    return
}

Write-Host "Starting MySQL ..." -ForegroundColor Green
Write-Host "  Path: $mysqld"
Write-Host "  Port: $Port"

# Try starting as Windows service first
$svcNames = @("MySQL", "MySQL84", "MySQL80", "MySQL57")
$started = $false
foreach ($svc in $svcNames) {
    $service = Get-Service -Name $svc -ErrorAction SilentlyContinue
    if ($service) {
        if ($service.Status -ne "Running") {
            Write-Host "  Starting service '$svc' ..." -ForegroundColor DarkGray
            Start-Service -Name $svc
            Start-Sleep -Seconds 2
        }
        $started = $true
        break
    }
}

if (-not $started) {
    # No service found, start mysqld directly
    Write-Host "  No MySQL service found, starting mysqld directly ..." -ForegroundColor DarkGray
    Start-Process -FilePath $mysqld -ArgumentList "--port=$Port" -WindowStyle Hidden
    Start-Sleep -Seconds 3
}

# Verify
$verify = & $mysql -u $User --password=$Password -P $Port -e "SELECT VERSION();" 2>&1
if ($LASTEXITCODE -eq 0) {
    $ver = $verify | Select-Object -Last 1
    Write-Host ""
    Write-Host "MySQL started successfully!" -ForegroundColor Cyan
    Write-Host "  Version: $ver" -ForegroundColor DarkGray
    Write-Host "  Port   : $Port" -ForegroundColor DarkGray
} else {
    Write-Host ""
    Write-Host "MySQL may not have started. Check logs." -ForegroundColor Red
    exit 1
}
