# Read-only probe: does the online card get LastLoginTime, and how fresh is it?
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

$ox = Invoke-WebRequest -Uri "$base/Game/UserInfo/GetOnlineUsers" -Method POST -Body @{} -WebSession $sess -Headers $h -UseBasicParsing -TimeoutSec 120
$oj = $ox.Content | ConvertFrom-Json
Write-Output ("ONLINE code=" + $oj.code + " content=" + $oj.content + " count=" + @($oj.datas).Count)
Write-Output ("ONLINE_RAW_FIRST=" + ($ox.Content.Substring(0, [Math]::Min(600, $ox.Content.Length))))
foreach ($d in @($oj.datas)) {
  Write-Output ("  ONLINE ID=" + $d.ID + " INHALL=" + $d.INHALL + " Status=" + $d.Status + " GameID=" + $d.GameID + " LastLoginTime=" + $d.LastLoginTime)
}

$fx = Invoke-WebRequest -Uri "$base/Game/UserInfo/GetOfflineUsers" -Method POST -Body @{ srch_ID=''; srch_NAME=''; srch_Agency=''; sort='last-time'; page=1; rows=10 } -WebSession $sess -Headers $h -UseBasicParsing -TimeoutSec 120
$fj = $fx.Content | ConvertFrom-Json
Write-Output ("OFFLINE total=" + $fj.total + " rows=" + @($fj.rows).Count)
foreach ($d in @($fj.rows)) {
  Write-Output ("  OFFLINE ID=" + $d.ID + " LastLoginTime=" + $d.LastLoginTime)
}

$o = Invoke-WebRequest -Uri "$base/zh-CN/Login/LoginOut" -WebSession $sess -UseBasicParsing -TimeoutSec 30
Write-Output 'LOGOUT_OK'
