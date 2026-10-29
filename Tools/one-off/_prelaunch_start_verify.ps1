$ErrorActionPreference = 'Continue'

Write-Host '==== D1. pipe Start-All (Center first, then games) ===='
powershell -NoProfile -ExecutionPolicy Bypass -File 'C:\Server\pipe_cmd.ps1' -Cmd 1 -Target 0

Write-Host '==== D2. pipe Start-Robot ===='
powershell -NoProfile -ExecutionPolicy Bypass -File 'C:\Server\pipe_cmd.ps1' -Cmd 1 -Target 3

Write-Host 'waiting 75s for staged startup ...'
Start-Sleep -Seconds 75

Write-Host '==== D3. Server*/Daemon processes ===='
$procs = Get-Process | Where-Object { $_.Name -match '^(Server|Daemon)' } | Sort-Object Name
$procs | Select-Object Name, Id, StartTime | Format-Table -AutoSize | Out-String -Width 200 | Write-Host
Write-Host ("count: " + @($procs).Count)

Write-Host '==== D4. listening game ports ===='
$ports = Get-NetTCPConnection -State Listen | Where-Object {
    $_.LocalPort -eq 9000 -or ($_.LocalPort -ge 9100 -and $_.LocalPort -le 9500) -or $_.LocalPort -eq 9600
} | Sort-Object LocalPort | Select-Object -ExpandProperty LocalPort -Unique
Write-Host ($ports -join ', ')

Write-Host '==== D5. recycle IIS apppool (flush stale sessions/caches) ===='
& "$env:WINDIR\system32\inetsrv\appcmd.exe" recycle apppool DefaultAppPool
Start-Sleep -Seconds 5

Write-Host '==== D6. backend probe ===='
try {
    $req = [System.Net.HttpWebRequest]::Create('http://127.0.0.1:8080/zh-CN/Login/Index')
    $req.Timeout = 30000
    $resp = $req.GetResponse()
    Write-Host ("Login page HTTP " + [int]$resp.StatusCode)
    $resp.Close()
} catch { Write-Host ("probe failed: " + $_.Exception.Message) }

Write-Host '==== D7. final DB spot-check ===='
& 'C:\mysql\bin\mysql.exe' -u root -p123456 --default-character-set=utf8mb4 mth -e @"
SELECT 'users' t, COUNT(*) c FROM users
UNION ALL SELECT 'admin', COUNT(*) FROM admin
UNION ALL SELECT 'admin.ID', ID FROM admin;
SELECT TABLE_NAME, TABLE_ROWS FROM information_schema.TABLES
WHERE TABLE_SCHEMA='mth' AND TABLE_TYPE='BASE TABLE' AND TABLE_ROWS > 0
ORDER BY TABLE_ROWS DESC LIMIT 20;
"@ 2>$null
