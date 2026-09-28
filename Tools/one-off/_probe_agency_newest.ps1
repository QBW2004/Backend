# Focused probe on the NEWEST IIS log: agency page loads and grid AJAX only.
$ErrorActionPreference = 'Continue'
$dir = 'C:\inetpub\logs\LogFiles\W3SVC1'
$f = Get-ChildItem "$dir\*.log" | Sort-Object LastWriteTime -Descending | Select-Object -First 1
Write-Output ("NEWEST LOG: " + $f.Name + "  last=" + $f.LastWriteTime.ToString('yyyy-MM-dd HH:mm:ss'))

Write-Output ''
Write-Output '=== page GET /Game/AgencyInfo  (no trailing path) ==='
foreach ($h in (Select-String -Path $f.FullName -Pattern 'GET /Game/AgencyInfo ')) { Write-Output ($h.Line) }

Write-Output ''
Write-Output '=== POST GetAgencies ==='
$c = 0
foreach ($h in (Select-String -Path $f.FullName -Pattern 'POST /Game/AgencyInfo/GetAgencies')) { Write-Output ($h.Line); $c++ }
Write-Output ("COUNT=" + $c)

Write-Output ''
Write-Output '=== any other /Game/AgencyInfo/* (non-static) in newest log ==='
foreach ($h in (Select-String -Path $f.FullName -Pattern '/Game/AgencyInfo/')) {
    if ($h.Line -notmatch 'GET /Game/AgencyInfo/(Get|Set|Ban|Unban|Delete|Add|Can|Chg|Save|Index)\S* ') { continue }
    Write-Output ($h.Line)
}

Write-Output ''
Write-Output '=== all app-log lines from 09-20 onward (error hunt) ==='
$logs = Get-ChildItem 'C:\Backend\Logs\*.log' | Where-Object { $_.LastWriteTime -gt (Get-Date).AddDays(-4) } | Sort-Object LastWriteTime
foreach ($l in $logs) {
    if ($l.Length -eq 0) { continue }
    Write-Output ("--- " + $l.Name + " ---")
    Get-Content $l.FullName | ForEach-Object { Write-Output $_ }
}
