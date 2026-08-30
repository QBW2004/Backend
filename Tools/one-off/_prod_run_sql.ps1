# Generic one-off SQL runner for production (credential from Web.config, memory only).
param([string]$SqlPath = 'C:\Temp\run.sql')
$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch {}
$mysqlExe = 'C:\mysql\bin\mysql.exe'
if (-not (Test-Path $mysqlExe)) { Write-Output 'ERR mysql client not found'; exit 2 }
if (-not (Test-Path $SqlPath)) { Write-Output ('ERR sql file missing: ' + $SqlPath); exit 2 }

$cfg = Get-Content 'C:\Backend\Web.config' -Raw
$ms = [regex]::Matches($cfg, 'connectionString\s*=\s*"([^"]*)"')
$conn = $null
foreach ($m in $ms) {
  $v = $m.Groups[1].Value
  if ($v -match '(?i)(database|initial catalog)=mth') { $conn = $v; break }
}
if (-not $conn -and $ms.Count -gt 0) { $conn = $ms[0].Groups[1].Value }
$uid = 'root'
if ($conn -match '(?i)(uid|user id|username)=([^;]+)') { $uid = $Matches[2].Trim() }
$pwdv = $null
if ($conn -match '(?i)(pwd|password)=([^;]*)') { $pwdv = $Matches[2].Trim() }
if (-not $pwdv) { Write-Output 'ERR password not found'; exit 2 }
$env:MYSQL_PWD = $pwdv

$out = 'C:\Temp\run_out.txt'
$err = 'C:\Temp\run_err.txt'
$p = Start-Process -FilePath $mysqlExe -ArgumentList @('-u', $uid, '--default-character-set=utf8mb4', 'mth') `
  -RedirectStandardInput $SqlPath -RedirectStandardOutput $out -RedirectStandardError $err `
  -NoNewWindow -Wait -PassThru
Write-Output ('SQL_EXIT=' + $p.ExitCode)
$e = Get-Content $err -Raw
if ($e) { Write-Output ('STDERR: ' + $e.Trim()) }
$o = Get-Content $out -Raw
if ($o) { Write-Output ('STDOUT: ' + $o.Trim()) }
