# One-off probe: collect prod facts for building a deployment template + skill. ASCII only.
$ErrorActionPreference = 'Continue'
try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch {}

Write-Output "===== CONN ====="
$cfg = Get-Content 'C:\Backend\Web.config' -Raw
$m = [regex]::Match($cfg, 'connectionString\s*=\s*"([^"]*mth[^"]*)"')
if ($m.Success) { Write-Output ($m.Groups[1].Value -replace '(Pwd=)[^;]*', '$1***') }

$pwdv = $null
if ($m.Success -and $m.Groups[1].Value -match '(?i)Pwd=([^;]*)') { $pwdv = $Matches[1] }
$env:MYSQL_PWD = $pwdv
$mysql = 'C:\mysql\bin\mysql.exe'

Write-Output "===== DB ====="
& $mysql -uroot -N -B -e "SELECT CONCAT('VER=',@@version,' LCTN=',@@lower_case_table_names); SELECT CONCAT('SIZE_MB=',ROUND(SUM(data_length+index_length)/1048576,1),' TABLES=',COUNT(*)) FROM information_schema.tables WHERE table_schema='mth'; SELECT CONCAT('TRIGGERS=',COUNT(*)) FROM information_schema.triggers WHERE trigger_schema='mth'; SELECT CONCAT('USERS=',COUNT(*)) FROM mth.users; SELECT CONCAT('ADMIN=',COUNT(*)) FROM mth.admin; SELECT CONCAT('RECHARGE=',COUNT(*)) FROM mth.rechargerecords;" 2>&1

Write-Output "===== BIGTABLES ====="
& $mysql -uroot -N -B -e "SELECT CONCAT(table_name,'|',ROUND((data_length+index_length)/1048576,1),'MB|~',table_rows) FROM information_schema.tables WHERE table_schema='mth' ORDER BY data_length+index_length DESC LIMIT 12;" 2>&1

Write-Output "===== SERVER DIR SIZES (MB) ====="
$total = 0
Get-ChildItem 'C:\Server' -Directory | Where-Object { $_.Name -like 'Server*' } | ForEach-Object {
  $s = (Get-ChildItem $_.FullName -Recurse -File -EA SilentlyContinue | Measure-Object Length -Sum).Sum
  $mb = [math]::Round($s/1MB,1); $total += $mb
  Write-Output ($_.Name + ' = ' + $mb)
}
Write-Output ('TOTAL_ServerDirs_MB = ' + [math]::Round($total,1))

Write-Output "===== DAEMON / AUTOSTART ====="
Get-Process | Where-Object { $_.Name -match 'Daemon|Admin|ServerMgr' } | ForEach-Object { Write-Output ('PROC ' + $_.Name + ' pid=' + $_.Id + ' start=' + $_.StartTime) }
Get-ScheduledTask -EA SilentlyContinue | Where-Object { $_.TaskName -match 'Server|Daemon|MTH|Admin' } | ForEach-Object { Write-Output ('TASK ' + $_.TaskName + ' -> ' + ($_.Actions.Execute) + ' ' + ($_.Actions.Arguments)) }

Write-Output "===== LISTEN PORTS (server procs) ====="
$procs = @{}
Get-Process | ForEach-Object { $procs[$_.Id] = $_.Name }
netstat -ano | Select-String 'LISTENING' | ForEach-Object {
  $parts = ($_.Line -split '\s+') | Where-Object { $_ -ne '' }
  $addr = $parts[1]; $pidv = [int]$parts[-1]
  $pname = $procs[$pidv]
  if ($pname -match 'Server|mysqld|w3wp|Daemon') { Write-Output ($addr + ' pid=' + $pidv + ' ' + $pname) }
}

Write-Output "===== SERVER ROOT FILES ====="
Get-ChildItem 'C:\Server' -File | ForEach-Object { Write-Output ('FILE ' + $_.Name + ' ' + $_.Length) }

Write-Output "===== BACKEND ====="
Write-Output ('Backend size MB = ' + [math]::Round((Get-ChildItem 'C:\Backend' -Recurse -File -EA SilentlyContinue | Measure-Object Length -Sum).Sum/1MB,1))
Get-ChildItem 'C:\MTH-Deploy' -File -EA SilentlyContinue | Sort-Object LastWriteTime -Desc | Select-Object -First 5 | ForEach-Object { Write-Output ('DEPLOY ' + $_.Name + ' ' + $_.LastWriteTime) }

Write-Output "===== IIS ====="
Import-Module WebAdministration -EA SilentlyContinue
Get-Website -EA SilentlyContinue | ForEach-Object { Write-Output ('SITE ' + $_.Name + ' bind=' + (($_.Bindings.Collection | ForEach-Object { $_.bindingInformation }) -join ';')) }
Get-ChildItem IIS:\AppPools -EA SilentlyContinue | ForEach-Object { Write-Output ('POOL ' + $_.Name + ' rt=' + $_.managedRuntimeVersion + ' 32bit=' + $_.enable32BitAppOnWin64) }

Write-Output "===== DONE ====="
