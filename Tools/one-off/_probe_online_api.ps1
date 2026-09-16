$ErrorActionPreference='Stop'
$base='http://127.0.0.1'
$p = Invoke-WebRequest -Uri "$base/zh-CN/Login/Mobile" -SessionVariable sess -UseBasicParsing -TimeoutSec 30
$m = [regex]::Match($p.Content, 'name="__RequestVerificationToken"[^>]*value="([^"]*)"')
if (-not $m.Success) { $m = [regex]::Match($p.Content, 'value="([^"]*)"[^>]*name="__RequestVerificationToken"') }
$tok = $m.Groups[1].Value
$h = @{ 'X-Requested-With'='XMLHttpRequest' }
$r = Invoke-WebRequest -Uri "$base/zh-CN/Login/Mobile" -Method POST -Body @{ uname='atmadmin'; upwd='123456'; __RequestVerificationToken=$tok } -WebSession $sess -Headers $h -UseBasicParsing -TimeoutSec 30
Write-Output ("LOGIN_RESP=" + $r.Content)
$q = Invoke-WebRequest -Uri "$base/Game/UserInfo/GetOnlineUsers" -Method POST -Body @{} -WebSession $sess -Headers $h -UseBasicParsing -TimeoutSec 90
Write-Output ("QA_RESP=" + $q.Content)
$q2 = Invoke-WebRequest -Uri "$base/Game/UserInfo/GetOnlinePlayers" -Method POST -Body @{page=1;rows=10} -WebSession $sess -Headers $h -UseBasicParsing -TimeoutSec 90
Write-Output ("DB_ONLINE_RESP=" + $q2.Content)
$o = Invoke-WebRequest -Uri "$base/zh-CN/Login/LoginOut" -WebSession $sess -UseBasicParsing -TimeoutSec 30
Write-Output ("LOGOUT_OK")
