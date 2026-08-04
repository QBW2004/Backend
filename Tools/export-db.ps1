param(
    [string]$DbName = "mth",
    [string]$User = "root",
    [string]$Password = "123456",
    [int]$Port = 3306,
    [string]$Output = ""
)

$mysqlPaths = @(
    "C:\mysql\bin",
    "C:\Program Files\MySQL\MySQL Server 8.4\bin",
    "C:\Program Files\MySQL\MySQL Server 8.0\bin",
    "C:\Program Files\MySQL\MySQL Server 5.7\bin"
)

$mysqlDir = $null
foreach ($p in $mysqlPaths) {
    if (Test-Path (Join-Path $p "mysqldump.exe")) {
        $mysqlDir = $p
        break
    }
}

if (-not $mysqlDir) {
    Write-Error "mysqldump.exe not found in any known path"
    exit 1
}

$mysqldump = Join-Path $mysqlDir "mysqldump.exe"

# 默认输出到 Tools 目录: mth_YYYYMMDD_HHMMSS.sql
if (-not $Output) {
    $Output = Join-Path $PSScriptRoot ("{0}_{1}.sql" -f $DbName, (Get-Date -Format "yyyyMMdd_HHmmss"))
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  MTH Database Export Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  mysqldump : $mysqldump"
Write-Host "  DB        : $DbName"
Write-Host "  User      : $User"
Write-Host "  Port      : $Port"
Write-Host "  Output    : $Output"
Write-Host ""

# 单事务快照导出(不锁 InnoDB 表)；含存储过程/函数/触发器/事件；去掉 GTID 便于其他环境导入
$dumpArgs = @(
    "-u$User",
    "--password=$Password",
    "-P$Port",
    "--default-character-set=utf8mb4",
    "--single-transaction",
    "--routines",
    "--triggers",
    "--events",
    "--set-gtid-purged=OFF",
    $DbName
)

Write-Host "Exporting ..." -ForegroundColor Green
# 用 cmd 重定向，避免 PowerShell 把输出写成 UTF-16
cmd /c "`"$mysqldump`" $($dumpArgs -join ' ') > `"$Output`""

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "Export failed!" -ForegroundColor Red
    if (Test-Path $Output) { Remove-Item $Output -Force }
    exit 1
}

$sizeKB = [math]::Round((Get-Item $Output).Length / 1KB, 1)
Write-Host ""
Write-Host "Export completed!" -ForegroundColor Cyan
Write-Host "  File : $Output" -ForegroundColor DarkGray
Write-Host "  Size : $sizeKB KB" -ForegroundColor DarkGray
Write-Host ""
Write-Host "Restore with:" -ForegroundColor DarkGray
Write-Host "  mysql -u $User -p $DbName < `"$Output`"" -ForegroundColor DarkGray
