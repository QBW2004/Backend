$ErrorActionPreference = 'Stop'
$ts = Get-Date -Format 'yyyyMMdd_HHmmss'
$dump = "C:\Users\Administrator\mth_prelaunch_backup_$ts.sql"

Write-Host "==== A. mysqldump backup -> $dump ===="
& 'C:\mysql\bin\mysqldump.exe' -u root -p123456 --single-transaction --hex-blob --routines --triggers --result-file="$dump" mth
if ($LASTEXITCODE -ne 0) { throw "mysqldump failed exit=$LASTEXITCODE" }
$fi = Get-Item $dump
Write-Host ("backup done: {0} bytes = {1:N1} MB" -f $fi.Length, ($fi.Length/1MB))
if ($fi.Length -lt 100KB) { throw 'backup file suspiciously small, abort' }

Write-Host '==== B. daemon status (before stop) ===='
powershell -NoProfile -ExecutionPolicy Bypass -File 'C:\Server\pipe_cmd.ps1' -Cmd 3 -Target 0

Write-Host '==== B1. Stop ALL game servers via pipe ===='
powershell -NoProfile -ExecutionPolicy Bypass -File 'C:\Server\pipe_cmd.ps1' -Cmd 2 -Target 0

Write-Host '==== B2. Stop robot via pipe ===='
powershell -NoProfile -ExecutionPolicy Bypass -File 'C:\Server\pipe_cmd.ps1' -Cmd 2 -Target 3

Start-Sleep -Seconds 8

Write-Host '==== B3. remaining Server* processes ===='
$left = Get-Process | Where-Object { $_.Name -match '^(Server|Daemon)' }
if ($left) {
    $left | Select-Object Name, Id | Format-Table -AutoSize | Out-String | Write-Host
} else {
    Write-Host 'none'
}
$games = Get-Process | Where-Object { $_.Name -match '^Server' }
if ($games) {
    Write-Host 'still running, taskkill fallback:'
    $games | ForEach-Object { Write-Host ("kill {0} pid={1}" -f $_.Name, $_.Id); Stop-Process -Id $_.Id -Force }
    Start-Sleep -Seconds 3
}
$still = Get-Process | Where-Object { $_.Name -match '^Server' }
Write-Host ("Server* processes remaining: {0}" -f @($still).Count)
