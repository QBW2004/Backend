param(
    [string]$DbName = "mth",
    [string]$User = "root",
    [string]$Password = "123456",
    [switch]$Force,
    [switch]$DryRun
)

$mysql = "C:\mysql\bin\mysql.exe"

if (-not (Test-Path $mysql)) {
    # fallback
    $mysql = "C:\Program Files\MySQL\MySQL Server 8.4\bin\mysql.exe"
    if (-not (Test-Path $mysql)) {
        Write-Error "mysql.exe not found"
        exit 1
    }
}

# 弹窗选择 SQL 文件
Add-Type -AssemblyName System.Windows.Forms
$dialog = New-Object System.Windows.Forms.OpenFileDialog
$dialog.Title = "选择要导入的 SQL 文件"
$dialog.InitialDirectory = $PSScriptRoot
$dialog.Filter = "SQL files (*.sql)|*.sql|All files (*.*)|*.*"
$dialog.CheckFileExists = $true
$dialog.Multiselect = $false

if ($dialog.ShowDialog() -eq "OK") {
    $SqlFile = $dialog.FileName
} else {
    Write-Host "Cancelled." -ForegroundColor Yellow
    exit 0
}

Write-Host "Selected: $SqlFile"

$patches = @(
    "Docs/sql/动态桌台字段扩展.sql",
    "Docs/sql/fix_scoreswitch_decimal.sql",
    "Docs/sql/房间桌台配置表坐席扩列.sql"
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  MTH Database Reset Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  MySQL : $mysql"
Write-Host "  DB    : $DbName"
Write-Host "  User  : $User"
Write-Host "  Base  : $SqlFile"
Write-Host "  Size  : $((Get-Item $SqlFile).Length / 1KB) KB"
Write-Host ""

if (-not $Force) {
    Write-Host "WARNING: This will DROP database '$DbName' and recreate it!" -ForegroundColor Red
    $confirm = Read-Host "Type YES to continue"
    if ($confirm -ne "YES") { Write-Host "Cancelled."; exit 0 }
}

# Step 1: Drop & Create
Write-Host "[1/4] Dropping old database ..." -ForegroundColor Green
if ($DryRun) {
    Write-Host "  [DRY-RUN] DROP DATABASE IF EXISTS $DbName; CREATE DATABASE $DbName ..."
} else {
    $sql = "DROP DATABASE IF EXISTS $DbName; CREATE DATABASE $DbName DEFAULT CHARACTER SET utf8mb4;"
    & $mysql -u $User --password=$Password -e $sql 2>&1 | Where-Object { $_ -notmatch "Warning" }
    if ($LASTEXITCODE -ne 0) { Write-Host "  Failed!" -ForegroundColor Red; exit 1 }
    Write-Host "  OK" -ForegroundColor DarkGray
}

# Step 2: Import base SQL
Write-Host "[2/4] Importing $((Get-Item $SqlFile).Name) ..." -ForegroundColor Green
if (-not $DryRun) {
    Write-Host "  Running (may take a while) ..." -ForegroundColor DarkGray
    cmd /c "`"$mysql`" -u $User --password=$Password --default-character-set=utf8mb4 $DbName < `"$SqlFile`"" 2>&1 | Where-Object { $_ -notmatch "Warning" }
    if ($LASTEXITCODE -ne 0) { Write-Host "  Failed!" -ForegroundColor Red; exit 1 }
    Write-Host "  OK" -ForegroundColor DarkGray
}

# Step 3: Apply patches
Write-Host "[3/4] Applying migration patches ..." -ForegroundColor Green
foreach ($patch in $patches) {
    $pp = Join-Path $PSScriptRoot $patch
    if (Test-Path $pp) {
        Write-Host "  -> $patch" -ForegroundColor DarkGray
        if (-not $DryRun) {
            cmd /c "`"$mysql`" -u $User --password=$Password --default-character-set=utf8mb4 $DbName < `"$pp`"" 2>&1 | Where-Object { $_ -notmatch "Warning" }
        }
    }
}
Write-Host "  Done" -ForegroundColor DarkGray

# Step 4: Verify
Write-Host "[4/4] Verifying ..." -ForegroundColor Green
if (-not $DryRun) {
    $result = & $mysql -u $User --password=$Password --default-character-set=utf8 $DbName -e "SHOW TABLES;" 2>&1 | Where-Object { $_ -notmatch "Warning" }
    $count = ($result | Measure-Object -Line).Lines - 1
    Write-Host "  $count tables created" -ForegroundColor DarkGray
}

Write-Host ""
Write-Host "Done!" -ForegroundColor Cyan
