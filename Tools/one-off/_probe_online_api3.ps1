$ErrorActionPreference='Stop'
$base='http://127.0.0.1'
$p = Invoke-WebRequest -Uri "$base/zh-CN/Login/Mobile" -SessionVariable sess -UseBasicParsing -TimeoutSec 30
$m = [regex]::Match($p.Content, 'name="__RequestVerificationToken"[^>]*value="([^"]*)"')
if (-not $m.Success) { $m = [regex]::Match($p.Content, 'value="([^"]*)"[^>]*name="__RequestVerificationToken"') }
$tok = $m.Groups[1].Value
$h = @{ 'X-Requested-With'='XMLHttpRequest' }
$r = Invoke-WebRequest -Uri "$base/zh-CN/Login/Mobile" -Method POST -Body @{ uname='atmadmin'; upwd='123456'; __RequestVerificationToken=$tok } -WebSession $sess -Headers $h -UseBasicParsing -TimeoutSec 30
Write-Output ("LOGIN=" + $r.Content)
function PostQ($url, $body) {
  try {
    $x = Invoke-WebRequest -Uri "$base$url" -Method POST -Body $body -WebSession $sess -Headers $h -UseBasicParsing -TimeoutSec 90
    $j = $x.Content | ConvertFrom-Json
    Write-Output ("$url " + ($body | ConvertTo-Json -Compress) + " => total=" + $j.total + " ids=" + (($j.rows | ForEach-Object { $_.ID + ':' + $_.INHALL }) -join ','))
  } catch { Write-Output ("$url ERR " + $_.Exception.Message) }
}
PostQ '/Game/UserInfo/GetUsers' @{ page=1; rows=20 }
PostQ '/Game/UserInfo/GetUsers' @{ srch_ID='aa1122'; page=1; rows=20 }
PostQ '/Game/UserInfo/GetUsers' @{ srch_ID='a1314'; page=1; rows=20 }
PostQ '/Game/UserInfo/GetOnlinePlayers' @{ page=1; rows=20 }
PostQ '/Game/UserInfo/GetOnlineUsers' @{}
$o = Invoke-WebRequest -Uri "$base/zh-CN/Login/LoginOut" -WebSession $sess -UseBasicParsing -TimeoutSec 30
Write-Output ("LOGOUT_OK")
