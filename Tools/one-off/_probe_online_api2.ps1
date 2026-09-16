$ErrorActionPreference='Stop'
$base='http://127.0.0.1'
$p = Invoke-WebRequest -Uri "$base/zh-CN/Login/Mobile" -SessionVariable sess -UseBasicParsing -TimeoutSec 30
$m = [regex]::Match($p.Content, 'name="__RequestVerificationToken"[^>]*value="([^"]*)"')
if (-not $m.Success) { $m = [regex]::Match($p.Content, 'value="([^"]*)"[^>]*name="__RequestVerificationToken"') }
$tok = $m.Groups[1].Value
$h = @{ 'X-Requested-With'='XMLHttpRequest' }
$r = Invoke-WebRequest -Uri "$base/zh-CN/Login/Mobile" -Method POST -Body @{ uname='atmadmin'; upwd='123456'; __RequestVerificationToken=$tok } -WebSession $sess -Headers $h -UseBasicParsing -TimeoutSec 30
Write-Output ("LOGIN=" + $r.Content)
$q1 = Invoke-WebRequest -Uri "$base/Game/UserInfo/GetUsers" -Method POST -Body @{ srch_ID='a1314'; srch_NAME=''; srch_Agency=''; page=1; rows=5 } -WebSession $sess -Headers $h -UseBasicParsing -TimeoutSec 90
Write-Output ("GETUSERS=" + $q1.Content)
$q2 = Invoke-WebRequest -Uri "$base/Game/UserInfo/GetOfflineUsers" -Method POST -Body @{ page=1; rows=5 } -WebSession $sess -Headers $h -UseBasicParsing -TimeoutSec 90
Write-Output ("OFFLINE=" + $q2.Content)
$q3 = Invoke-WebRequest -Uri "$base/Game/UserInfo/GetOnlineUsers" -Method POST -Body @{} -WebSession $sess -Headers $h -UseBasicParsing -TimeoutSec 90
Write-Output ("QA=" + $q3.Content)
$q4 = Invoke-WebRequest -Uri "$base/Game/UserInfo/GetOnlinePlayers" -Method POST -Body @{ page=1; rows=5 } -WebSession $sess -Headers $h -UseBasicParsing -TimeoutSec 90
Write-Output ("DBONLINE=" + $q4.Content)
$o = Invoke-WebRequest -Uri "$base/zh-CN/Login/LoginOut" -WebSession $sess -UseBasicParsing -TimeoutSec 30
Write-Output ("LOGOUT_OK")
