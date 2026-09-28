# Corrected: request sequence per referer page in the user's window (UTC 16:30-16:40).
$ErrorActionPreference = 'Continue'
$dir = 'C:\inetpub\logs\LogFiles\W3SVC1'
$f = Get-ChildItem "$dir\*.log" | Sort-Object LastWriteTime -Descending | Select-Object -First 1

$from = [datetime]::ParseExact('2026-09-22 16:30:00', 'yyyy-MM-dd HH:mm:ss', $null)
$to   = [datetime]::ParseExact('2026-09-22 16:40:00', 'yyyy-MM-dd HH:mm:ss', $null)

$rows = New-Object System.Collections.ArrayList
foreach ($line in (Get-Content $f.FullName)) {
    $p = $line -split ' '
    if ($p.Count -lt 17) { continue }
    $t = $null
    try { $t = [datetime]::ParseExact($p[0] + ' ' + $p[1], 'yyyy-MM-dd HH:mm:ss', $null) } catch { continue }
    if ($t -lt $from -or $t -gt $to) { continue }
    [void]$rows.Add([pscustomobject]@{
        t = $t; m = $p[3]; url = $p[4]; st = $p[11]; ms = $p[16]
        ref = ($p[10] -replace 'https://abc\.12\.sqrdwj\.top', '')
    })
}

foreach ($page in @('/Game/AgencyInfo', '/Game/UserInfo')) {
    Write-Output ("===== referer " + $page + " =====")
    $sub = @($rows | Where-Object { $_.ref -eq $page } | Sort-Object t)
    Write-Output ("  count=" + $sub.Count)
    foreach ($r0 in $sub) {
        $short = $r0.url -replace '^/Content/easyui/(plugins/|themes/[^/]+/|locale/)', 'easyui:'
        $short = $short -replace '^/Content/css/', 'css:'
        $short = $short -replace '^/Scripts/', 'js:'
        Write-Output ("    " + $r0.t.ToString('HH:mm:ss') + "  " + $r0.m + " " + $r0.st + "  " + $r0.ms + "ms  " + $short)
    }
    Write-Output ''
}
