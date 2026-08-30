# One-off: apply the mobile test-data seed on production and verify page-level queries.
# Credential comes from C:\Backend\Web.config in memory only (MYSQL_PWD env var), never printed.
param([string]$SeedPath = 'C:\Temp\mth_seed_phone.sql')
$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch {}

$mysqlExe = 'C:\mysql\bin\mysql.exe'
if (-not (Test-Path $mysqlExe)) {
  $cmd = Get-Command mysql.exe -ErrorAction SilentlyContinue
  if ($cmd) { $mysqlExe = $cmd.Source } else { Write-Output 'ERR mysql client not found'; exit 2 }
}
if (-not (Test-Path $SeedPath)) { Write-Output ('ERR seed file missing: ' + $SeedPath); exit 2 }

$cfg = Get-Content 'C:\Backend\Web.config' -Raw
$ms = [regex]::Matches($cfg, 'connectionString\s*=\s*"([^"]*)"')
$conn = $null
foreach ($m in $ms) {
  $v = $m.Groups[1].Value
  if ($v -match '(?i)(database|initial catalog)=mth') { $conn = $v; break }
}
if (-not $conn -and $ms.Count -gt 0) { $conn = $ms[0].Groups[1].Value }
if (-not $conn) { Write-Output 'ERR connstring not found'; exit 2 }
$uid = 'root'
if ($conn -match '(?i)(uid|user id|username)=([^;]+)') { $uid = $Matches[2].Trim() }
$pwdv = $null
if ($conn -match '(?i)(pwd|password)=([^;]*)') { $pwdv = $Matches[2].Trim() }
if (-not $pwdv) { Write-Output 'ERR password not found'; exit 2 }
$env:MYSQL_PWD = $pwdv

$out = 'C:\Temp\seed_out.txt'
$err = 'C:\Temp\seed_err.txt'
$p = Start-Process -FilePath $mysqlExe -ArgumentList @('-u', $uid, '--default-character-set=utf8mb4', 'mth') `
  -RedirectStandardInput $SeedPath -RedirectStandardOutput $out -RedirectStandardError $err `
  -NoNewWindow -Wait -PassThru
Write-Output ('SEED_EXIT=' + $p.ExitCode)
$e = Get-Content $err -Raw
if ($e) { Write-Output ('SEED_STDERR: ' + $e.Trim()) }
if ($p.ExitCode -ne 0) { exit 3 }

$sql = @"
SELECT 'info_now', CAST(NOW() AS CHAR);
SELECT 'v_players', COUNT(*) FROM users WHERE ID LIKE '95000%';
SELECT 'v_agents96', COUNT(*) FROM admin WHERE ID LIKE '96%' AND PRIV > 0;
SELECT 'v_online', COUNT(*) FROM users WHERE ID LIKE '95000%' AND INHALL = 1;
SELECT 'v_frozen', COUNT(*) FROM users WHERE ID LIKE '95000%' AND FROZEN = 1;
SELECT 'v_today_wl_sum', IFNULL(SUM(WINLOSS),0) FROM user_daily_winloss WHERE DAY = CURDATE();
SELECT 'v_today_wl_rows', COUNT(*) FROM user_daily_winloss WHERE DAY = CURDATE();
SELECT 'v_flows_7d', COUNT(*) FROM rechargerecords WHERE OrderNo LIKE 'TS%';
SELECT 'v_flows_pending', COUNT(*) FROM rechargerecords WHERE OrderNo LIKE 'TS%' AND RechargeType IN (30,31) AND Processed = 0;
SELECT 'v_abnormal', COUNT(*) FROM loginmissrecord WHERE LoginResult = 0 AND MissCount > 4;
SELECT 'v_agency_banlog', COUNT(*) FROM agencyoptlog WHERE ID LIKE '96%' AND OPT IN (24,25);
SELECT 'v_controls_active', COUNT(*) FROM usercontrolstatus WHERE GameType = 9 AND Status = 0;
SELECT 'v_controls_all96', COUNT(*) FROM usercontrolstatus WHERE GameType = 9 AND UserID LIKE '95000%';
SELECT 'v_optlog', COUNT(*) FROM useroptlog WHERE UserID LIKE '95000%';
SELECT 'v_invites', COUNT(*) FROM invite_codes WHERE AgentID LIKE '96%';
SELECT 'v_banned_agent', COUNT(*) FROM admin WHERE RE_ENABLE = 0 AND ID = '96501';
SELECT 'v_paged_join_offline', COUNT(*) FROM users c INNER JOIN userrelations r ON r.ID = c.ID LEFT JOIN user_daily_winloss w ON w.UserID = c.ID AND w.DAY = CURDATE() WHERE NOT (c.INHALL = 1);
SELECT 'v_online_playing', COUNT(*) FROM users u JOIN useroptlog o ON o.UserID = u.ID LEFT JOIN games g ON g.GameId = o.GAME_TYPE WHERE u.INHALL = 1 AND u.ID LIKE '95000%' AND o.GAME_TYPE > 0;
SELECT 'v_detail_buy_today', (SELECT IFNULL(SUM(Coin),0) FROM rechargerecords WHERE GameID = '95000040' AND RechargeType IN (20,22) AND CreateTime >= CURDATE());
SELECT 'v_coins_atmadmin_after', (SELECT COINS FROM admin WHERE ID = 'atmadmin');
"@

& $mysqlExe -u $uid --connect-timeout=10 --default-character-set=utf8mb4 -N -e $sql mth
if ($LASTEXITCODE -ne 0) { Write-Output 'ERR verify failed'; exit 4 }
Write-Output 'APPLY_DONE'
