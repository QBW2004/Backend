# Is the easyui 'datagrid' module reachable? Compare a working day (09-17) vs the broken one (09-22).
$ErrorActionPreference = 'Continue'
$dir = 'C:\inetpub\logs\LogFiles\W3SVC1'

foreach ($name in @('u_ex260917.log', 'u_ex260922.log')) {
    $p = Join-Path $dir $name
    if (-not (Test-Path $p)) { Write-Output ("MISSING " + $name); continue }
    Write-Output ''
    Write-Output ("=== " + $name + " : easyui datagrid/pagination module requests ===")
    $hits = @(Select-String -Path $p -Pattern 'jquery\.datagrid|jquery\.pagination|jquery\.datalist|datagrid\.css|pagination\.css|datalist\.css|jquery\.menu\.js|jquery\.searchbox')
    $seen = @{}
    foreach ($h in $hits) {
        $line = $h.Line
        $parts = $line -split ' '
        $url = $parts[6]
        $status = $parts[11]
        $key = $url + ' -> ' + $status
        if ($seen.ContainsKey($key)) { $seen[$key]++ } else { $seen[$key] = 1 }
    }
    if ($seen.Count -eq 0) { Write-Output '  (no requests at all)' }
    foreach ($k in ($seen.Keys | Sort-Object)) { Write-Output ("  " + $k + "   x" + $seen[$k]) }
}

Write-Output ''
Write-Output '=== 404 on /Content/easyui or /Scripts/easyloader (both days) ==='
foreach ($name in @('u_ex260917.log', 'u_ex260922.log')) {
    $p = Join-Path $dir $name
    if (-not (Test-Path $p)) { continue }
    Write-Output ("--- " + $name + " ---")
    foreach ($h in (Select-String -Path $p -Pattern ' 404 ')) {
        if ($h.Line -match '/Content/easyui|/Scripts/|/Content/css') { Write-Output ($h.Line) }
    }
}
