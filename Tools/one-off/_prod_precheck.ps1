# One-off read-only precheck for seeding mobile test data on production (134.122.203.112).
# Extracts the DB credential from C:\Backend\Web.config in memory only (MYSQL_PWD env var),
# never prints it, and runs collision/informational checks for the seed account ranges.
$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch {}

$mysqlExe = 'C:\mysql\bin\mysql.exe'
if (-not (Test-Path $mysqlExe)) {
  $cmd = Get-Command mysql.exe -ErrorAction SilentlyContinue
  if ($cmd) { $mysqlExe = $cmd.Source } else { Write-Output 'ERR mysql client not found'; exit 2 }
}

$cfg = Get-Content 'C:\Backend\Web.config' -Raw
$ms = [regex]::Matches($cfg, 'connectionString\s*=\s*"([^"]*)"')
$conn = $null
foreach ($m in $ms) {
  $v = $m.Groups[1].Value
  if ($v -match '(?i)(database|initial catalog)=mth') { $conn = $v; break }
}
if (-not $conn -and $ms.Count -gt 0) { $conn = $ms[0].Groups[1].Value }
if (-not $conn) { Write-Output 'ERR connstring not found'; exit 2 }

$masked = [regex]::Replace($conn, '(?i)(pwd|password)=([^;]*)', '$1=***')
Write-Output ("CONN " + $masked)

$uid = 'root'
if ($conn -match '(?i)(uid|user id|username)=([^;]+)') { $uid = $Matches[2].Trim() }
$pwdv = $null
if ($conn -match '(?i)(pwd|password)=([^;]*)') { $pwdv = $Matches[2].Trim() }
if (-not $pwdv) { Write-Output 'ERR password not found'; exit 2 }
$env:MYSQL_PWD = $pwdv

$sql = @"
SELECT 'info_now', CAST(NOW() AS CHAR);
SELECT 'chk_admin_96', COUNT(*) FROM admin WHERE ID LIKE '96%';
SELECT 'chk_users_950', COUNT(*) FROM users WHERE ID LIKE '95000%';
SELECT 'chk_order_ts', COUNT(*) FROM rechargerecords WHERE OrderNo LIKE 'TS%';
SELECT 'chk_useroptlog_950', COUNT(*) FROM useroptlog WHERE UserID LIKE '95000%';
SELECT 'chk_daily_950', COUNT(*) FROM user_daily_winloss WHERE UserID LIKE '95000%';
SELECT 'chk_lock_950', COUNT(*) FROM userlockrecord WHERE ID LIKE '95000%';
SELECT 'chk_ctrl_950', COUNT(*) FROM usercontrolstatus WHERE UserID LIKE '95000%';
SELECT 'chk_ucv_950', COUNT(*) FROM usercontrolvalue WHERE USERID LIKE '95000%';
SELECT 'chk_agencyopt_96', COUNT(*) FROM agencyoptlog WHERE ID LIKE '96%';
SELECT 'chk_invite_7xxx', COUNT(*) FROM invite_codes WHERE InviteCode IN ('7001','7002','7003','7101','7102','7103','7111','7201','7202','7301','7302','7311','7321','7501','7502');
SELECT 'chk_miss_mine', COUNT(*) FROM loginmissrecord WHERE ID LIKE '95000%' OR ID IN ('ghost777','mtest001');
SELECT 'info_admin_total', COUNT(*) FROM admin;
SELECT 'info_users_total', COUNT(*) FROM users;
SELECT 'info_atmadmin_exists', COUNT(*) FROM admin WHERE ID='atmadmin';
SELECT 'info_coins_atmadmin', IFNULL((SELECT COINS FROM admin WHERE ID='atmadmin'),-1);
SELECT 'info_coins_mtest001', IFNULL((SELECT COINS FROM admin WHERE ID='mtest001'),-1);
SELECT 'info_coins_55555555', IFNULL((SELECT COINS FROM admin WHERE ID='55555555'),-1);
SELECT 'info_proc_findorglist', COUNT(*) FROM information_schema.ROUTINES WHERE ROUTINE_NAME='findOrgList';
SELECT 'info_charset', @@character_set_database, @@collation_database;
"@

& $mysqlExe -u $uid --connect-timeout=10 --default-character-set=utf8mb4 -N -e $sql mth
if ($LASTEXITCODE -ne 0) { Write-Output 'ERR mysql failed'; exit 3 }
Write-Output 'PRECHECK_DONE'
