# Full request window around the user's failed attempts (UTC 16:30:00-16:40:00 = local 00:30-00:40).
$ErrorActionPreference = 'Continue'
$dir = 'C:\inetpub\logs\LogFiles\W3SVC1'
$f = Get-ChildItem "$dir\*.log" | Sort-Object LastWriteTime -Descending | Select-Object -First 1

$from = [datetime]::ParseExact('2026-09-22 16:30:00', 'yyyy-MM-dd HH:mm:ss', $null)
$to   = [datetime]::ParseExact('2026-09-22 16:40:00', 'yyyy-MM-dd HH:mm:ss', $null)

$rows = @()
foreach ($h in (Get-Content $f.FullName)) {
    $p = $h -split ' '
    if ($p.Count -lt 17) { continue }
    $t = $null
    try { $t = [datetime]::ParseExact($p[0] + ' ' + $p[1], 'yyyy-MM-dd HH:mm:ss', $null) } catch { continue }
    if ($t -lt $from -or $t -gt $to) { continue }
    $ref = $p[10] -replace 'https://abc\.12\.sqrdwj\.top', ''
    $rows += [pscustomobject]@{ t = $t; m = $p[3]; url = $p[4]; st = $p[11]; ms = $p[16]; ref = $ref }
}

Write-Output ("TOTAL IN WINDOW = " + $rows.Count)
Write-Output ''
Write-Output '--- grouped by referer page ---'
$rows | Group-Object ref | Sort-Object Count -Descending | ForEach-Object { Write-Output ("  " + $_.Count.ToString().PadLeft(4) + "  " + $_.Name) }
Write-Output ''
Write-Output '--- easyui plugin/js requests in window (time, url, referer) ---'
foreach ($r in ($rows | Where-Object { $r.url -match '\.js$|\.css$' } | Sort-Object t)) {
    Write-Output ("  " + $r.t.ToString('HH:mm:ss') + "  " + $r.st + "  " + $r.url + "   ref=" + $r.ref)
}
