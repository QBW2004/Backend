# One-off deploy probe: read production Web.config (mask password) + dump mth schema.
# Run on server: powershell -ExecutionPolicy Bypass -File _deploy_probe.ps1
$ErrorActionPreference = 'Continue'
$web = 'C:\Backend'
$cfgPath = Join-Path $web 'Web.config'

Write-Output "===== SECTION: INFO ====="
if (-not (Test-Path $cfgPath)) { Write-Output "Web.config NOT FOUND at $cfgPath"; exit 1 }
[xml]$x = Get-Content $cfgPath -Raw
$conn = @($x.configuration.connectionStrings.add) | Where-Object { $_.name -eq 'DbConnString' } | Select-Object -First 1
$cs = $conn.connectionString
Write-Output ("CONN(masked): " + ($cs -replace '(Pwd=)[^;]*', '$1***'))
$pwdVal = $null
if ($cs -match 'Pwd=([^;]*)') { $pwdVal = $Matches[1] }

foreach ($k in @('WebVer','UploadPath','RecordDbPath','serverName','pipeName','robotPipeName','PayOrderNotify','DPayOrderNotify','notify_url','X2notify_url','WebHost','Timer','LoginTimeOut','logSwitch','RechargeType','IsRMB','payUrl','X2payUrl')) {
  $v = @($x.configuration.appSettings.add) | Where-Object { $_.key -eq $k } | Select-Object -First 1
  if ($v) { Write-Output ("APPSET " + $k + " = " + $v.value) }
}
Write-Output ("Web.config LastWriteTime: " + (Get-Item $cfgPath).LastWriteTime)
$dll = Join-Path $web 'bin\YYT.Web.dll'
if (Test-Path $dll) { Write-Output ("YYT.Web.dll LastWriteTime: " + (Get-Item $dll).LastWriteTime) }
Write-Output "--- C:\Backend top-level dirs ---"
Get-ChildItem $web -Directory | ForEach-Object { Write-Output ("DIR " + $_.Name) }

if ($null -eq $pwdVal -or $pwdVal -eq '') { Write-Output "NO PWD PARSED, skip mysql"; exit 0 }

$mysql = 'C:\mysql\bin\mysql.exe'
if (-not (Test-Path $mysql)) { $mysql = 'mysql' }
$env:MYSQL_PWD = $pwdVal

Write-Output "===== SECTION: MYSQL ====="
& $mysql -uroot -N -B -e "SELECT CONCAT('VERSION=',@@version); SELECT CONCAT('TABLE_COUNT=',COUNT(*)) FROM information_schema.tables WHERE table_schema='mth'; SELECT CONCAT('LC_TABLE_NAMES=',@@lower_case_table_names);"
Write-Output "===== SECTION: TABLES ====="
& $mysql -uroot -N -B -e "SELECT table_name FROM information_schema.tables WHERE table_schema='mth' ORDER BY table_name;"
Write-Output "===== SECTION: COLUMNS ====="
& $mysql -uroot -N -B -e "SELECT CONCAT(table_name,'|',column_name,'|',column_type,'|',is_nullable,'|',IFNULL(column_default,'<NULL>'),'|',column_key) FROM information_schema.columns WHERE table_schema='mth' ORDER BY table_name, ordinal_position;"
Write-Output "===== SECTION: END ====="
