# Exact resource chain for the desktop agency page: filter by cs(Referer) == /Game/AgencyInfo
$ErrorActionPreference = 'Continue'
$dir = 'C:\inetpub\logs\LogFiles\W3SVC1'

function Show-Chain($file, $label) {
    $p = Join-Path $dir $file
    if (-not (Test-Path $p)) { Write-Output ("MISSING " + $file); return }
    Write-Output ''
    Write-Output ("=== " + $label + "  (" + $file + ") ===")
    $rows = @()
    foreach ($h in (Select-String -Path $p -Pattern 'Game/AgencyInfo')) {
        $f = $h.Line -split ' '
        if ($f.Count -lt 15) { continue }
        $ref = $f[10]
        $stem = $f[4]
        if ($ref -ne 'https://abc.12.sqrdwj.top/Game/AgencyInfo' -and $stem -notmatch '^/Game/AgencyInfo') { continue }
        $url = $stem
        if ($f[5] -ne '-') { $url = $url + '?' + $f[5] }
        $rows += [pscustomobject]@{ t = ($f[1] + ' ' + $f[0]); url = $url; status = $f[11]; ms = $f[14] }
    }
    foreach ($r in ($rows | Sort-Object t)) { Write-Output ("  " + $r.t + "  " + $r.status + "  " + $r.ms + "ms  " + $r.url) }
    Write-Output ("  ROWS=" + $rows.Count)
}

Show-Chain 'u_ex260917.log' 'WORKING DAY 09-17'
Show-Chain 'u_ex260922.log' 'BROKEN DAY 09-22'

Write-Output ''
Write-Output '=== whether jquery.datagrid.js / pagination ever fetched (whole newest log, by stem) ==='
$p = Join-Path $dir 'u_ex260922.log'
foreach ($h in (Select-String -Path $p -Pattern 'jquery\.datagrid\.js|jquery\.pagination\.js|jquery\.datalist\.js')) {
    $f = $h.Line -split ' '
    Write-Output ("  " + $f[1] + " " + $f[0] + "  ref=" + $f[10] + "  status=" + $f[11] + "  " + $f[4])
}
