# List all POST requests hitting the Notice endpoints (old and new URLs) from the
# IIS access logs, so we can tell whether a save ever reached the site.
# ASCII only (remote PowerShell reads non-BOM UTF-8 as GBK).
param(
    [string]$LogDir = 'C:\inetpub\logs\LogFiles\W3SVC1',
    [int]$Days = 3
)
$files = Get-ChildItem (Join-Path $LogDir '*.log') | Sort-Object LastWriteTime -Descending | Select-Object -First $Days
foreach ($f in $files) {
    $hits = Get-Content $f.FullName | Where-Object { $_ -match 'POST /Game/Notice/' }
    Write-Output ("=== " + $f.Name + "  POST /Game/Notice/* count=" + ($hits | Measure-Object).Count)
    $hits | Select-Object -Last 25 | ForEach-Object {
        # date time s-ip method uri query s-port user c-ip agent referer status substatus win32 time-taken
        $p = $_ -split ' '
        if ($p.Count -ge 15) {
            Write-Output ($p[0] + ' ' + $p[1] + '  ' + $p[4] + '  status=' + $p[10] + '  dur=' + $p[14] + 'ms  c-ip=' + $p[8])
        } else {
            Write-Output $_
        }
    }
}
