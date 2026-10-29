# import-db.ps1 — import the mth template SQL on the target server.
# Usage: powershell -ExecutionPolicy Bypass -File import-db.ps1 -SqlFile .\mth_template.sql
# Safe-guard: refuses to overwrite a non-empty existing mth db unless -Force.
param(
  [Parameter(Mandatory=$true)][string]$SqlFile,
  [string]$MySqlExe = 'C:\mysql\bin\mysql.exe',
  [string]$User = 'root',
  [string]$Password = '123456',
  [switch]$Force
)
$ErrorActionPreference = 'Stop'
if (-not (Test-Path $MySqlExe)) { Write-Output "ERR mysql.exe not found at $MySqlExe"; exit 2 }
if (-not (Test-Path $SqlFile)) { Write-Output "ERR sql file missing: $SqlFile"; exit 2 }
$env:MYSQL_PWD = $Password

& $MySqlExe -u $User -N -B -e "SELECT 1" 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0) { Write-Output "ERR cannot login mysql as $User (check -Password / service MySQL57 running)"; exit 2 }

$tbl = & $MySqlExe -u $User -N -B -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='mth'" 2>$null
$users = 0
if ([int]$tbl -gt 0) {
  $users = [int](& $MySqlExe -u $User -N -B -e "SELECT COUNT(*) FROM mth.users" 2>$null)
}
if ([int]$tbl -gt 0 -and -not $Force) {
  Write-Output "ABORT: database 'mth' already exists ($tbl tables, users=$users)."
  Write-Output "       The template import DROPS and recreates every table -> existing data would be lost."
  Write-Output "       Re-run with -Force to overwrite, or drop the db yourself first."
  exit 3
}
if ([int]$tbl -gt 0) { Write-Output "WARN: overwriting existing mth db ($tbl tables, users=$users) because -Force." }

Write-Output "Importing $SqlFile ..."
& $MySqlExe -u $User --default-character-set=utf8mb4 -e "SOURCE $($SqlFile -replace '\\','/')" 2>&1 | Select-Object -Last 10
if ($LASTEXITCODE -ne 0) { Write-Output "ERR import failed (exit=$LASTEXITCODE)"; exit 2 }

Write-Output "== post-import check =="
& $MySqlExe -u $User -N -B -e "SELECT CONCAT('tables=',COUNT(*)) FROM information_schema.tables WHERE table_schema='mth'; SELECT CONCAT('games=',COUNT(*)) FROM mth.games; SELECT CONCAT('admin=',COUNT(*)) FROM mth.admin; SELECT CONCAT('cardpayoutprofile=',COUNT(*)) FROM mth.cardpayoutprofile; SELECT CONCAT('triggers=',COUNT(*)) FROM information_schema.triggers WHERE trigger_schema='mth';"
Write-Output "Expected: tables>=59, games=14, admin=1 (atmadmin/123456), cardpayoutprofile>2000, triggers>=1"
