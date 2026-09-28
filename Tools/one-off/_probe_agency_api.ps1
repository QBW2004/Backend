# Read-only probe: desktop login -> agency page HTML -> GetAgencies JSON; plus asset hashes.
$ErrorActionPreference = 'Stop'
$base = 'http://127.0.0.1'

$p = Invoke-WebRequest -Uri "$base/zh-CN/Login/Index" -SessionVariable sess -UseBasicParsing -TimeoutSec 30
$m = [regex]::Match($p.Content, 'name="__RequestVerificationToken"[^>]*value="([^"]*)"')
if (-not $m.Success) { $m = [regex]::Match($p.Content, 'value="([^"]*)"[^>]*name="__RequestVerificationToken"') }
$tok = $m.Groups[1].Value
$h = @{ 'X-Requested-With' = 'XMLHttpRequest' }
$body = @{ uname = 'atmadmin'; upwd = '123456' }
if ($tok) { $body['__RequestVerificationToken'] = $tok }
$r = Invoke-WebRequest -Uri "$base/zh-CN/Login/Index" -Method POST -Body $body -WebSession $sess -Headers $h -UseBasicParsing -TimeoutSec 30
Write-Output ("LOGIN len=" + $r.Content.Length + " status=" + $r.StatusCode)

$pg = Invoke-WebRequest -Uri "$base/Game/AgencyInfo" -WebSession $sess -Headers @{ 'X-Requested-With' = 'XMLHttpRequest' } -UseBasicParsing -TimeoutSec 60
Write-Output ("PAGE status=" + $pg.StatusCode + " len=" + $pg.Content.Length)
Write-Output ("PAGE has_datagrid_module=" + $pg.Content.Contains("'datagrid'"))
Write-Output ("PAGE has_gridurl=" + $pg.Content.Contains('/Game/AgencyInfo/GetAgencies'))

$sw = [System.Diagnostics.Stopwatch]::StartNew()
$g = Invoke-WebRequest -Uri "$base/Game/AgencyInfo/GetAgencies" -Method POST -Body @{ page = 1; rows = 20 } -WebSession $sess -Headers $h -UseBasicParsing -TimeoutSec 120
$sw.Stop()
Write-Output ("GETAGENCIES status=" + $g.StatusCode + " ms=" + $sw.ElapsedMilliseconds + " bytes=" + $g.Content.Length)
$j = $g.Content | ConvertFrom-Json
Write-Output ("GETAGENCIES total=" + $j.total + " rows=" + @($j.rows).Count)
foreach ($d in @($j.rows | Select-Object -First 3)) {
    Write-Output ("   row ID=" + $d.ID + " PRIV=" + $d.PRIV + " RE_ENABLE=" + $d.RE_ENABLE + " PWD=" + $d.PWD + " RemainingScore=" + $d.RemainingScore + " SubAgencyCount=" + $d.SubAgencyCount)
}

Write-Output ''
Write-Output '=== asset hashes on disk ==='
foreach ($f in @('Scripts\easyloader.js', 'Content\easyui\plugins\jquery.datagrid.js', 'Content\easyui\plugins\jquery.pagination.js', 'Content\easyui\plugins\jquery.resizable.js', 'Areas\Game\Views\AgencyInfo\Index.cshtml')) {
    $p2 = Join-Path 'C:\Backend' $f
    if (Test-Path $p2) {
        $md5 = (Get-FileHash $p2 -Algorithm MD5).Hash
        $len = (Get-Item $p2).Length
        Write-Output ("  " + $md5 + "  " + $len + "  " + $f)
    } else {
        Write-Output ("  MISSING  " + $f)
    }
}
