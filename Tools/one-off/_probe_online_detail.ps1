$ErrorActionPreference='Stop'
$base='http://127.0.0.1'
$p = Invoke-WebRequest -Uri "$base/zh-CN/Login/Mobile" -SessionVariable sess -UseBasicParsing -TimeoutSec 30
$m = [regex]::Match($p.Content, 'name="__RequestVerificationToken"[^>]*value="([^"]*)"')
if (-not $m.Success) { $m = [regex]::Match($p.Content, 'value="([^"]*)"[^>]*name="__RequestVerificationToken"') }
$tok = $m.Groups[1].Value
$h = @{ 'X-Requested-With'='XMLHttpRequest' }
$r = Invoke-WebRequest -Uri "$base/zh-CN/Login/Mobile" -Method POST -Body @{ uname='atmadmin'; upwd='123456'; __RequestVerificationToken=$tok } -WebSession $sess -Headers $h -UseBasicParsing -TimeoutSec 30
Write-Output ("LOGIN_LEN=" + $r.Content.Length)
function PostQ($url, $body) {
  try {
    $x = Invoke-WebRequest -Uri "$base$url" -Method POST -Body $body -WebSession $sess -Headers $h -UseBasicParsing -TimeoutSec 90
    $j = $x.Content | ConvertFrom-Json
    $d = $j.datas
    Write-Output ("$url " + ($body | ConvertTo-Json -Compress) + " => code=" + $j.code + " content=" + $j.content)
    if ($d) {
      Write-Output ("   ID=" + $d.ID + " COINS_BUY=" + $d.COINS_BUY + " COINS_BACK=" + $d.COINS_BACK + " TodayBuy=" + $d.TodayBuy + " TodayBack=" + $d.TodayBack + " TodayWinLoss=" + $d.TodayWinLoss + " TotalWinLoss=" + $d.TotalWinLoss)
    }
  } catch { Write-Output ("$url ERR " + $_.Exception.Message) }
}
PostQ '/Game/UserInfo/GetUserDetail' @{ ID='a1403' }
PostQ '/Game/UserInfo/GetUserDetail' @{ ID='a1401' }
PostQ '/Game/UserInfo/GetUserDetail' @{ ID='aa1122' }
$o = Invoke-WebRequest -Uri "$base/zh-CN/Login/LoginOut" -WebSession $sess -UseBasicParsing -TimeoutSec 30
Write-Output "LOGOUT_OK"
