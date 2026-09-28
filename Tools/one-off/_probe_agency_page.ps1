# Read-only probe: IIS access log + app log for the desktop agency management page.
$ErrorActionPreference = 'Continue'

$dir = 'C:\inetpub\logs\LogFiles\W3SVC1'
$files = Get-ChildItem "$dir\*.log" | Sort-Object LastWriteTime -Descending | Select-Object -First 3
Write-Output '=== IIS LOG FILES ==='
foreach ($f in $files) {
    Write-Output ("FILE " + $f.Name + "  size=" + $f.Length + "  last=" + $f.LastWriteTime.ToString('yyyy-MM-dd HH:mm:ss'))
}

Write-Output ''
Write-Output '=== AgencyInfo requests (last 40) ==='
$hits = @()
foreach ($f in $files) {
    $hits += Select-String -Path $f.FullName -Pattern 'AgencyInfo'
}
foreach ($h in ($hits | Select-Object -Last 40)) {
    Write-Output ($h.Line)
}
Write-Output ("TOTAL_HITS=" + $hits.Count)

Write-Output ''
Write-Output '=== Any 500/502 responses (last 20) ==='
$errs = @()
foreach ($f in $files) {
    $errs += Select-String -Path $f.FullName -Pattern ' 500 | 502 | 503 '
}
foreach ($e in ($errs | Select-Object -Last 20)) {
    Write-Output ($e.Line)
}
Write-Output ("TOTAL_ERR=" + $errs.Count)

Write-Output ''
Write-Output '=== App log: newest 3 files, full content if small ==='
$logs = Get-ChildItem 'C:\Backend\Logs\*.log' | Sort-Object LastWriteTime -Descending | Select-Object -First 3
foreach ($l in $logs) {
    Write-Output ("--- " + $l.Name + " (" + $l.Length + " bytes) ---")
    if ($l.Length -lt 8000) {
        Get-Content $l.FullName | ForEach-Object { Write-Output $_ }
    } else {
        Write-Output '(skipped, too large)'
    }
}
