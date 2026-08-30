# One-off: inspect games.Name values on production (are they empty/mojibake?).
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
SELECT GameId, CHAR_LENGTH(Name) len, HEX(Name) hx FROM games ORDER BY GameId LIMIT 25;
"@
& $mysqlExe -u $uid --connect-timeout=10 --default-character-set=utf8mb4 -N -e $sql mth
if ($LASTEXITCODE -ne 0) { Write-Output 'ERR mysql failed'; exit 3 }
Write-Output 'GAMESCHECK_DONE'
