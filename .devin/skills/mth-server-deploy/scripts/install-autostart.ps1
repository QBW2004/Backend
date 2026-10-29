# install-autostart.ps1 — register the MTH_Daemon boot task (and optional Start-All task).
# Run as administrator on the target server AFTER C:\Server is in place.
#   -StartAllOnBoot also registers MTH_StartAll which waits, then asks Daemon to start all games
#   (Daemon itself never auto-starts games on boot - this is the known gap this task covers).
param(
  [string]$ServerRoot = 'C:\Server',
  [string]$TaskXml = '',           # optional: path to MTH_Daemon.xml exported from prod
  [switch]$StartAllOnBoot,
  [int]$StartAllDelaySec = 90
)
$ErrorActionPreference = 'Stop'
$daemonExe = Join-Path $ServerRoot 'ServerManager\x64\Release\Daemon.exe'
if (-not (Test-Path $daemonExe)) { Write-Output "ERR Daemon.exe not found at $daemonExe"; exit 2 }

if ($TaskXml -and (Test-Path $TaskXml)) {
  schtasks /create /tn MTH_Daemon /xml $TaskXml /f | Out-Null
  Write-Output "TASK MTH_Daemon created from XML"
} else {
  schtasks /create /tn MTH_Daemon /sc onstart /ru SYSTEM /rl HIGHEST /tr "`"$daemonExe`"" /f | Out-Null
  Write-Output "TASK MTH_Daemon created (onstart, SYSTEM): $daemonExe"
}
schtasks /run /tn MTH_Daemon | Out-Null
Write-Output "TASK MTH_Daemon triggered now (daemon is up; games NOT started yet)"

if ($StartAllOnBoot) {
  $sa = Join-Path $ServerRoot 'mth_startall.ps1'
  @"
Start-Sleep -Seconds $StartAllDelaySec
& "$ServerRoot\mth_pipe.ps1" -Cmd Start
"@ | Out-File -Encoding ascii $sa
  schtasks /create /tn MTH_StartAll /sc onstart /ru SYSTEM /rl HIGHEST /tr "powershell -NoProfile -ExecutionPolicy Bypass -File `"$sa`"" /f | Out-Null
  Write-Output "TASK MTH_StartAll created (boot +${StartAllDelaySec}s -> pipe Start All)"
}
Write-Output "Done. Verify: schtasks /query /tn MTH_Daemon"
