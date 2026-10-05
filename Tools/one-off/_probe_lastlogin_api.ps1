# Read-only probe: what does the mobile API return for 最后登录 now?
$ErrorActionPreference = 'Stop'
$base = 'http://127.0.0.1'

$p = Invoke-WebRequest -Uri "$base/zh-CN/Login/Mobile" -SessionVariable sess -UseBasicParsing -TimeoutSec 30
$m = [regex]::Match($p.Content, 'name="__RequestVerificationToken"[^>]*value="([^"]*)"')
if (-not $m.Success) { $m = [regex]::Match($p.Content, 'value="([^"]*)"[^>]*name="__RequestVerificationToken"') }
$tok = $m.Groups[1].Value
$h = @{ 'X-Requested-With' = 'XMLHttpRequest' }
$r = Invoke-WebRequest -Uri "$base/zh-CN/Login/Mobile" -Method POST -Body @{ uname = 'atmadmin'; upwd = '123456'; __RequestVerificationToken = $tok } -WebSession $sess -Headers $h -UseBasicParsing -TimeoutSec 30
Write-Output ("LOGIN_LEN=" + $r.Content.Length)
Write-Output ("SERVER_NOW=" + (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'))

$fx = Invoke-WebRequest -Uri "$base/Game/UserInfo/GetOfflineUsers" -Method POST -Body @{ srch_ID=''; srch_NAME=''; srch_Agency=''; sort='last-time'; page=1; rows=10 } -WebSession $sess -Headers $h -UseBasicParsing -TimeoutSec 120
$fj = $fx.Content | ConvertFrom-Json
Write-Output ("OFFLINE total=" + $fj.total)
foreach ($d in @($fj.rows)) {
  Write-Output ("  OFFLINE " + $d.ID + "  LastLoginTime=" + $d.LastLoginTime)
}

$dx = Invoke-WebRequest -Uri "$base/Game/UserInfo/GetUserDetail" -Method POST -Body @{ ID='a1403' } -WebSession $sess -Headers $h -UseBasicParsing -TimeoutSec 120
$dj = $dx.Content | ConvertFrom-Json
Write-Output ("DETAIL code=" + $dj.code + " LastLoginTime=" + $dj.datas.LastLoginTime + " TotalWinLoss=" + $dj.datas.TotalWinLoss)

# 在线卡片：2026-09-29（c7cd4cf）起不再下发/展示 LastLoginTime（应恒为空），口径只留离线列表与玩家详情
$ox = Invoke-WebRequest -Uri "$base/Game/UserInfo/GetOnlineUsers" -Method POST -Body @{} -WebSession $sess -Headers $h -UseBasicParsing -TimeoutSec 120
$oj = $ox.Content | ConvertFrom-Json
Write-Output ("ONLINE code=" + $oj.code + " count=" + @($oj.datas).Count)
foreach ($d in @($oj.datas)) {
  Write-Output ("  ONLINE " + $d.ID + "  LastLoginTime=" + $d.LastLoginTime)
}

$o = Invoke-WebRequest -Uri "$base/zh-CN/Login/LoginOut" -WebSession $sess -UseBasicParsing -TimeoutSec 30
Write-Output 'LOGOUT_OK'
