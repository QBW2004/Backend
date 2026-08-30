# One-off: check games table (affects in-game name display), then remove temp scripts.
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
$uid = 'root'
if ($conn -match '(?i)(uid|user id|username)=([^;]+)') { $uid = $Matches[2].Trim() }
$pwdv = $null
if ($conn -match '(?i)(pwd|password)=([^;]*)') { $pwdv = $Matches[2].Trim() }
$env:MYSQL_PWD = $pwdv

$sql = @"
SELECT 'games_count', COUNT(*) FROM games;
SELECT 'games_ids', IFNULL(GROUP_CONCAT(GameId),'EMPTY') FROM games;
SELECT 'legacy_users_exist', COUNT(*) FROM users WHERE ID IN ('t1','test03');
"@

& $mysqlExe -u $uid --connect-timeout=10 --default-character-set=utf8mb4 -N -e $sql mth
if ($LASTEXITCODE -ne 0) { Write-Output 'ERR mysql failed'; exit 3 }

Remove-Item 'C:\Temp\precheck.ps1','C:\Temp\apply.ps1','C:\Temp\verify.ps1','C:\Temp\seed_out.txt','C:\Temp\seed_err.txt' -ErrorAction SilentlyContinue
Write-Output 'POSTCHECK_DONE (temp scripts removed, C:\Temp\mth_seed_phone.sql kept for re-runs)'
