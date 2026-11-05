# Import the canonical clean database on a new target server.
# Usage: powershell -File import-db.ps1 -SqlFile C:\MTH-Deploy\Database\mth_clean.sql
# Refuses an existing non-empty mth database unless -Force is explicitly supplied.
param(
  [string]$SqlFile = '',
  [string]$MySqlExe = 'C:\mysql\bin\mysql.exe',
  [string]$User = 'root',
  [string]$Password = $env:MYSQL_PWD,
  [switch]$Force
)
$ErrorActionPreference = 'Stop'
if (-not $SqlFile) { $SqlFile = Join-Path $PSScriptRoot '..\..\..\..\Database\mth_clean.sql' }
if (-not (Test-Path -LiteralPath $MySqlExe -PathType Leaf)) { throw 'mysql.exe not found.' }
$SqlFile = (Resolve-Path -LiteralPath $SqlFile).Path
if (-not (Test-Path -LiteralPath $SqlFile -PathType Leaf)) { throw 'SQL file missing.' }
if (Select-String -LiteralPath $SqlFile -Pattern '^\s*(USE\s|(?:CREATE|DROP)\s+DATABASE\s)' -Quiet) {
  throw 'Use the canonical single-schema dump without CREATE/DROP DATABASE or USE.'
}
if (-not $PSBoundParameters.ContainsKey('Password') -and -not $Password) {
  $securePassword = Read-Host 'MySQL password' -AsSecureString
  $Password = (New-Object System.Net.NetworkCredential('', $securePassword)).Password
}
$previousPassword = $env:MYSQL_PWD
try {
  $env:MYSQL_PWD = $Password
  $mysqlArgs = @('--protocol=TCP', '--host=127.0.0.1', "--user=$User", '--default-character-set=utf8mb4')
  $caseMode = & $MySqlExe @mysqlArgs -N -B -e 'SELECT @@lower_case_table_names;'
  if ($LASTEXITCODE -ne 0) { throw 'MySQL connection failed.' }
  if (($caseMode -join '').Trim() -ne '1') { throw 'Requires lower_case_table_names=1.' }
  $tableCount = & $MySqlExe @mysqlArgs -N -B -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='mth';"
  if ($LASTEXITCODE -ne 0) { throw 'Schema preflight failed.' }
  if ([int]$tableCount -gt 0 -and -not $Force) {
    throw "Database mth already contains $tableCount tables/views. Import refused; -Force is only for an explicitly authorized replacement."
  }
  & $MySqlExe @mysqlArgs -e 'CREATE DATABASE IF NOT EXISTS mth CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;'
  if ($LASTEXITCODE -ne 0) { throw 'Database creation failed.' }
  $source = $SqlFile.Replace('\', '/')
  & $MySqlExe @mysqlArgs --database=mth -e "source $source"
  if ($LASTEXITCODE -ne 0) { throw 'Clean database import failed.' }
  & $MySqlExe @mysqlArgs -N -B -e "SELECT CONCAT('tables/views=',COUNT(*)) FROM information_schema.tables WHERE table_schema='mth'; SELECT CONCAT('games=',COUNT(*)) FROM mth.games; SELECT CONCAT('admin=',COUNT(*)) FROM mth.admin; SELECT CONCAT('players=',COUNT(*)) FROM mth.users; SELECT CONCAT('triggers=',COUNT(*)) FROM information_schema.triggers WHERE trigger_schema='mth';"
  if ($LASTEXITCODE -ne 0) { throw 'Post-import verification failed.' }
  Write-Output 'Compare these counts with Database/README.md and the current validation evidence; program/configuration/state-file checks are still required.'
}
finally { $env:MYSQL_PWD = $previousPassword }
