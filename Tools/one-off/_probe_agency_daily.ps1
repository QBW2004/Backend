# Day-by-day summary: agency page loads vs grid AJAX, plus 404 hunt for easyui modules.
$ErrorActionPreference = 'Continue'
$dir = 'C:\inetpub\logs\LogFiles\W3SVC1'
$files = Get-ChildItem "$dir\*.log" | Sort-Object LastWriteTime -Descending | Select-Object -First 8

Write-Output 'DATE       | pageGET | GetAgencies | otherAgencyAPI | 404s(any)'
foreach ($f in ($files | Sort-Object Name)) {
    $lines = Get-Content $f.FullName
    $pg = @($lines | Where-Object { $_ -match 'GET /Game/AgencyInfo ' }).Count
    $ga = @($lines | Where-Object { $_ -match 'POST /Game/AgencyInfo/GetAgencies' }).Count
    $other = @($lines | Where-Object { $_ -match '/Game/AgencyInfo/' -and $_ -notmatch 'GetAgencies' -and $_ -notmatch 'GET /Game/AgencyInfo/Index' }).Count
    $e404 = @($lines | Where-Object { $_ -match ' 404 ' }).Count
    Write-Output ("{0} | {1,7} | {2,11} | {3,14} | {4,8}" -f $f.Name, $pg, $ga, $other, $e404)
}

Write-Output ''
Write-Output '=== last GetAgencies lines with a real payload (>1000 bytes), newest log first ==='
foreach ($f in $files) {
    $hits = @(Select-String -Path $f.FullName -Pattern 'POST /Game/AgencyInfo/GetAgencies')
    if ($hits.Count -eq 0) { continue }
    Write-Output ("--- " + $f.Name + " : " + $hits.Count + " hits, first/last ---")
    Write-Output ($hits[0].Line)
    if ($hits.Count -gt 1) { Write-Output ($hits[-1].Line) }
}

Write-Output ''
Write-Output '=== 404 hits on easyui/scripts in the 2 newest logs ==='
foreach ($f in ($files | Select-Object -First 2)) {
    foreach ($h in (Select-String -Path $f.FullName -Pattern ' 404 ')) { Write-Output ($h.Line) }
}
