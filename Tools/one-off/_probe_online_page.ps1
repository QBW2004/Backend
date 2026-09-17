$ErrorActionPreference='Stop'
$base='http://127.0.0.1'
$p = Invoke-WebRequest -Uri "$base/zh-CN/Login/Mobile" -SessionVariable sess -UseBasicParsing -TimeoutSec 30
$m = [regex]::Match($p.Content, 'name="__RequestVerificationToken"[^>]*value="([^"]*)"')
if (-not $m.Success) { $m = [regex]::Match($p.Content, 'value="([^"]*)"[^>]*name="__RequestVerificationToken"') }
$tok = $m.Groups[1].Value
$h = @{ 'X-Requested-With'='XMLHttpRequest' }
$r = Invoke-WebRequest -Uri "$base/zh-CN/Login/Mobile" -Method POST -Body @{ uname='atmadmin'; upwd='123456'; __RequestVerificationToken=$tok } -WebSession $sess -Headers $h -UseBasicParsing -TimeoutSec 30
Write-Output ("LOGIN_LEN=" + $r.Content.Length)
try {
  $pg = Invoke-WebRequest -Uri "$base/Mobile/Home/PlayerDetail?account=a1403" -WebSession $sess -UseBasicParsing -TimeoutSec 60
  Write-Output ("PAGE_STATUS=" + $pg.StatusCode + " LEN=" + $pg.Content.Length)
  ([regex]::Matches($pg.Content, 'phone\.[a-z]+\.js\?v=[0-9.]+') | ForEach-Object { $_.Value }) -join "`n" | Write-Output
  $m2 = [regex]::Match($pg.Content, 'id="dTotalWinLoss"[^>]*')
  Write-Output ("TOTALNODE=" + $m2.Value)
} catch { Write-Output ("PAGE ERR " + $_.Exception.Message) }
$o = Invoke-WebRequest -Uri "$base/zh-CN/Login/LoginOut" -WebSession $sess -UseBasicParsing -TimeoutSec 30
Write-Output "LOGOUT_OK"
