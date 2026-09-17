$ErrorActionPreference = 'Stop'
$base = 'http://127.0.0.1'
$p = Invoke-WebRequest -Uri "$base/zh-CN/Login/Mobile" -SessionVariable sess -UseBasicParsing -TimeoutSec 30
$m = [regex]::Match($p.Content, 'name="__RequestVerificationToken"[^>]*value="([^"]*)"')
if (-not $m.Success) { $m = [regex]::Match($p.Content, 'value="([^"]*)"[^>]*name="__RequestVerificationToken"') }
$tok = $m.Groups[1].Value
$h = @{ 'X-Requested-With' = 'XMLHttpRequest' }
$null = Invoke-WebRequest -Uri "$base/zh-CN/Login/Mobile" -Method POST -Body @{ uname = 'atmadmin'; upwd = '123456'; __RequestVerificationToken = $tok } -WebSession $sess -Headers $h -UseBasicParsing -TimeoutSec 30

$page = Invoke-WebRequest -Uri "$base/Mobile/Home/Index" -WebSession $sess -Headers $h -UseBasicParsing -TimeoutSec 60
$m2 = [regex]::Matches($page.Content, 'phone\.players\.js\?v=([0-9.]+)')
Write-Output ("PAGE_JS_VER=" + (($m2 | ForEach-Object { $_.Groups[1].Value }) -join ','))

$js = Invoke-WebRequest -Uri "$base/Scripts/app/phone/phone.players.js" -WebSession $sess -UseBasicParsing -TimeoutSec 60
Write-Output ("JS_HAS_6S_TIMEOUT=" + ($js.Content -match 'timeoutMs: 6000'))
Write-Output ("JS_HAS_KEEP_LIST=" + ($js.Content -match "'warning', 2000"))
Write-Output ("JS_HAS_CODE_CHECK=" + ($js.Content -match 'Number\(res\.code\) === 1'))

$online = Invoke-WebRequest -Uri "$base/Game/UserInfo/GetOnlineUsers" -Method POST -Body @{} -WebSession $sess -Headers $h -UseBasicParsing -TimeoutSec 60
Write-Output ("ONLINE_RESP=" + $online.Content)
$null = Invoke-WebRequest -Uri "$base/zh-CN/Login/LoginOut" -WebSession $sess -UseBasicParsing -TimeoutSec 30
Write-Output "LOGOUT_OK"
