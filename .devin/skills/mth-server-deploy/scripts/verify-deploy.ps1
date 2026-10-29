# verify-deploy.ps1 — post-deployment health check. Run on the target server.
# Checks: MySQL, IIS site HTTP, game server processes + listening ports, daemon pipe.
param(
  [string]$ServerRoot = 'C:\Server',
  [string]$BackendRoot = 'C:\Backend',
  [int[]]$WebPorts = @(80, 8081),
  [string]$MySqlExe = 'C:\mysql\bin\mysql.exe',
  [string]$DbPwd = '123456'
)
$ErrorActionPreference = 'Continue'
$fail = 0
function OK($n,$d){ Write-Output ("[OK]   " + $n + " : " + $d) }
function BAD($n,$d){ Write-Output ("[FAIL] " + $n + " : " + $d); $script:fail++ }

Write-Output "===== MySQL ====="
$env:MYSQL_PWD = $DbPwd
$null = & $MySqlExe -u root -N -B -e "SELECT 1" 2>&1
if ($LASTEXITCODE -eq 0) {
  $t = & $MySqlExe -u root -N -B -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='mth'"
  OK 'mysql auth' "root login ok, mth tables=$t"
} else { BAD 'mysql auth' "cannot login as root@$DbPwd" }

Write-Output "===== IIS / Backend ====="
Import-Module WebAdministration -EA SilentlyContinue
$site = Get-Website | Where-Object { (Get-WebConfigurationProperty -PSPath "IIS:\Sites\$($_.Name)" -Filter . -Name physicalPath -EA SilentlyContinue) -eq $BackendRoot -or $_.physicalPath -eq $BackendRoot }
if (-not $site) { $site = Get-Website -Name 'Default Web Site' -EA SilentlyContinue }
if ($site) { OK 'site' ($site.Name + ' -> ' + $site.physicalPath) } else { BAD 'site' 'no IIS site found' }
foreach ($p in $WebPorts) {
  try {
    $r = Invoke-WebRequest -Uri "http://127.0.0.1:$p/" -UseBasicParsing -TimeoutSec 15
    OK "HTTP :$p" ("status " + [int]$r.StatusCode)
  } catch {
    if ($_.Exception.Response) { OK "HTTP :$p" ("status " + [int]$_.Exception.Response.StatusCode + " (reachable)") }
    else { BAD "HTTP :$p" $_.Exception.Message }
  }
}
$dll = Join-Path $BackendRoot 'bin\YYT.Web.dll'
if (Test-Path $dll) { OK 'YYT.Web.dll' (Get-Item $dll).LastWriteTime } else { BAD 'YYT.Web.dll' 'missing' }

Write-Output "===== Game servers ====="
$procs = Get-Process | Where-Object { $_.Name -like 'Server*' }
Write-Output ("running Server* processes: " + $procs.Count)
$dupes = $procs | Group-Object Name | Where-Object { $_.Count -gt 1 }
if ($dupes) {
  BAD 'dup check' (('double-open: ' + ($dupes | ForEach-Object { $_.Name + ' x' + $_.Count }) -join ', ') + ' -- e.g. 2x ServerRobot fills all table seats')
} else {
  OK 'dup check' 'no duplicate Server* processes'
}
$expected = @{
  9000='ServerCenterNew'; 9100='ServerBetBMW'; 9102='ServerBetDT'; 9103='ServerBetAnimal';
  9200='ServerCardPhenix'; 9203='ServerCardKing3'; 9204='ServerCardDazhi'; 9206='ServerCardAttMhb';
  9208='ServerCardDscj'; 9209='ServerCardNBA'; 9300='ServerFishJC'; 9302='ServerFishCow';
  9305='ServerFishLikui'; 9315='ServerFishSlbz'; 9316='ServerFishSqje'
}
foreach ($port in ($expected.Keys | Sort-Object)) {
  $hit = netstat -ano | Select-String (":" + $port + "\s+.*LISTENING")
  if ($hit) { OK "port $port" $expected[$port] } else { BAD "port $port" ($expected[$port] + " not listening") }
}

Write-Output "===== Daemon pipe status ====="
$pipeScript = Join-Path $ServerRoot 'mth_pipe.ps1'
if (Test-Path $pipeScript) {
  & $pipeScript -Cmd Status
} else { Write-Output "mth_pipe.ps1 not found under $ServerRoot (copy it from the skill scripts/)" }

Write-Output ""
if ($fail -eq 0) { Write-Output "ALL CHECKS PASSED" } else { Write-Output "$fail check(s) FAILED - see above" }
