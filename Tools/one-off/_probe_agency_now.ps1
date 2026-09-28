# Did my in-browser POST (through the CDN) reach IIS just now?
$ErrorActionPreference = 'Continue'
$dir = 'C:\inetpub\logs\LogFiles\W3SVC1'
$f = Get-ChildItem "$dir\*.log" | Sort-Object LastWriteTime -Descending | Select-Object -First 1
Write-Output ("LOG " + $f.Name + "  last=" + $f.LastWriteTime.ToString('yyyy-MM-dd HH:mm:ss'))
Write-Output ("SERVER NOW " + (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'))
Write-Output ''
Write-Output '=== GetAgencies in this log file (all) ==='
$c = 0
foreach ($h in (Select-String -Path $f.FullName -Pattern 'GetAgencies')) {
    $p = $h.Line -split ' '
    Write-Output ("  " + $p[0] + " " + $p[1] + "  " + $p[3] + " " + $p[4] + "  ip=" + $p[8] + "  status=" + $p[11] + "  bytes=" + $p[14] + "  ms=" + $p[16] + "  ref=" + $p[10])
    $c++
}
Write-Output ("COUNT=" + $c)
Write-Output ''
Write-Output '=== every request in the last 15 minutes (url + ip + status) ==='
$cut = (Get-Date).AddMinutes(-15)
foreach ($h in (Select-String -Path $f.FullName -Pattern ' /')) {
    $p = $h.Line -split ' '
    $t = [datetime]::ParseExact($p[0] + ' ' + $p[1], 'yyyy-MM-dd HH:mm:ss', $null)
    if ($t -lt $cut) { continue }
    Write-Output ("  " + $p[1] + "  " + $p[3] + " " + $p[4] + "  ip=" + $p[8] + "  status=" + $p[11] + "  ms=" + $p[16])
}
