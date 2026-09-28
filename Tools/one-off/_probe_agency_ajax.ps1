# Read-only probe: did the desktop grid AJAX (POST /Game/AgencyInfo/GetAgencies) ever fire, and what came back?
$ErrorActionPreference = 'Continue'
$dir = 'C:\inetpub\logs\LogFiles\W3SVC1'
$files = Get-ChildItem "$dir\*.log" | Sort-Object LastWriteTime -Descending | Select-Object -First 6

Write-Output '=== POST /Game/AgencyInfo/GetAgencies (all logs) ==='
$n = 0
foreach ($f in $files) {
    $hits = Select-String -Path $f.FullName -Pattern 'GetAgencies'
    if ($hits) {
        Write-Output ("--- " + $f.Name + " ---")
        foreach ($h in $hits) { Write-Output ($h.Line); $n++ }
    }
}
Write-Output ("TOTAL_GetAgencies=" + $n)

Write-Output ''
Write-Output '=== GET /Game/AgencyInfo page hits (all logs) ==='
$m = 0
foreach ($f in $files) {
    $hits = Select-String -Path $f.FullName -Pattern 'GET /Game/AgencyInfo '
    foreach ($h in $hits) { Write-Output ($h.Line); $m++ }
}
Write-Output ("TOTAL_PAGE=" + $m)

Write-Output ''
Write-Output '=== distinct client IPs hitting /Game/AgencyInfo (all request kinds) ==='
$ips = @{}
foreach ($f in $files) {
    foreach ($h in (Select-String -Path $f.FullName -Pattern '/Game/AgencyInfo')) {
        $parts = $h.Line -split ' '
        $c = $parts[8]
        if ($ips.ContainsKey($c)) { $ips[$c]++ } else { $ips[$c] = 1 }
    }
}
foreach ($k in $ips.Keys) { Write-Output ("  " + $k + "  x" + $ips[$k]) }
