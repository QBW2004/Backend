# One-off post-apply verification for the mobile test-data seed (production).
$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch {}

$mysqlExe = 'C:\mysql\bin\mysql.exe'
$cfg = Get-Content 'C:\Backend\Web.config' -Raw
$ms = [regex]::Matches($cfg, 'connectionString\s*=\s*"([^"]*)"')
$conn = $null
foreach ($m in $ms) {
  $v = $m.Groups[1].Value
  if ($v -match '(?i)(database|initial catalog)=mth') { $conn = $v; break }
}
if (-not $conn) { Write-Output 'ERR connstring not found'; exit 2 }
$uid = 'root'
if ($conn -match '(?i)(uid|user id|username)=([^;]+)') { $uid = $Matches[2].Trim() }
$pwdv = $null
if ($conn -match '(?i)(pwd|password)=([^;]*)') { $pwdv = $Matches[2].Trim() }
if (-not $pwdv) { Write-Output 'ERR password not found'; exit 2 }
$env:MYSQL_PWD = $pwdv

$sql = @"
SELECT 'name_95000001', NAME, HEX(LEFT(NAME,3)) FROM users WHERE ID='95000001';
SELECT 'abnormal_types', (CASE WHEN ID IN (SELECT ID FROM admin) THEN 'agency' WHEN ID IN (SELECT ID FROM users) THEN 'player' ELSE 'unknown' END) t, COUNT(*) FROM loginmissrecord WHERE LoginResult=0 AND MissCount>4 GROUP BY t;
SELECT 'ban_msg', DestUserTitle FROM agencyoptlog WHERE ID='96501' AND OPT=24 ORDER BY LID DESC LIMIT 1;
SELECT 'stats_today_buy_back', IFNULL(SUM(CASE WHEN RechargeType IN (20,22) OR (RechargeType=30 AND Processed=1) THEN Coin ELSE 0 END),0), IFNULL(SUM(CASE WHEN RechargeType IN (21,23) OR (RechargeType=31 AND Processed=1) THEN Coin ELSE 0 END),0) FROM rechargerecords WHERE CreateTime>=CURDATE();
SELECT 'detail_40_today_buy', (SELECT IFNULL(SUM(CASE WHEN RechargeType IN (20,22) OR (RechargeType=30 AND Processed=1) THEN Coin ELSE 0 END),0) FROM rechargerecords WHERE GameID='95000040' AND CreateTime>=CURDATE());
SELECT 'detail_29_invite', (SELECT InviteCode FROM invite_codes WHERE UsedBy='95000029' AND IsUsed=1 LIMIT 1);
SELECT 'ctl_active_rows', UserID, ControlMode, TargetCoins, ConsumedCoins, GrantedCoins, Status FROM usercontrolstatus WHERE GameType=9 AND Status=0 ORDER BY ID DESC LIMIT 6;
SELECT 'online_playing_top', u.ID, o.GAME_TYPE, g.Name, o.ROOM, o.TABLE_ID FROM users u JOIN useroptlog o ON o.UserID=u.ID LEFT JOIN games g ON g.GameId=o.GAME_TYPE WHERE u.INHALL=1 AND u.ID LIKE '95000%' AND o.GAME_TYPE>0 ORDER BY o.REC_TIME DESC LIMIT 3;
"@

& $mysqlExe -u $uid --connect-timeout=10 --default-character-set=utf8mb4 -N -e $sql mth
if ($LASTEXITCODE -ne 0) { Write-Output 'ERR mysql failed'; exit 3 }
Write-Output 'VERIFY_DONE'
