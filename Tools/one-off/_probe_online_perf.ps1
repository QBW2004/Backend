# Read-only probe: where does "refresh online players" spend its time?
$ErrorActionPreference = 'Stop'
$base = 'http://127.0.0.1'

# ---- 1) login (same flow as previous probes) ----
$p = Invoke-WebRequest -Uri "$base/zh-CN/Login/Mobile" -SessionVariable sess -UseBasicParsing -TimeoutSec 30
$m = [regex]::Match($p.Content, 'name="__RequestVerificationToken"[^>]*value="([^"]*)"')
if (-not $m.Success) { $m = [regex]::Match($p.Content, 'value="([^"]*)"[^>]*name="__RequestVerificationToken"') }
$tok = $m.Groups[1].Value
$h = @{ 'X-Requested-With' = 'XMLHttpRequest' }
$r = Invoke-WebRequest -Uri "$base/zh-CN/Login/Mobile" -Method POST -Body @{ uname = 'atmadmin'; upwd = '123456'; __RequestVerificationToken = $tok } -WebSession $sess -Headers $h -UseBasicParsing -TimeoutSec 30
Write-Output ("LOGIN_LEN=" + $r.Content.Length)

function TimePost($url, $body, $label) {
  $sw = [Diagnostics.Stopwatch]::StartNew()
  try {
    $x = Invoke-WebRequest -Uri "$base$url" -Method POST -Body $body -WebSession $sess -Headers $h -UseBasicParsing -TimeoutSec 120
    $sw.Stop()
    $len = $x.Content.Length
    $head = $x.Content.Substring(0, [Math]::Min(160, $len))
    Write-Output ("[{0}] {1} ms  bytes={2}  head={3}" -f $label, $sw.ElapsedMilliseconds, $len, $head)
  } catch {
    $sw.Stop()
    Write-Output ("[{0}] {1} ms  ERR {2}" -f $label, $sw.ElapsedMilliseconds, $_.Exception.Message)
  }
}

# warm up the app (first hit compiles views / opens EF model)
$null = Invoke-WebRequest -Uri "$base/zh-CN/Mgr/Index?view=mobile" -WebSession $sess -UseBasicParsing -TimeoutSec 60

TimePost '/Game/UserInfo/GetTodayWinLoss'  @{} 'GetTodayWinLoss'
TimePost '/Game/UserInfo/GetOnlineUsers'   @{} 'GetOnlineUsers'
TimePost '/Game/UserInfo/GetOfflineUsers'  @{ srch_ID=''; srch_NAME=''; srch_Agency=''; sort='last-time'; page=1; rows=10 } 'GetOfflineUsers'

# repeat online twice: cold vs warm (pipe breaker / EF cache)
TimePost '/Game/UserInfo/GetOnlineUsers'   @{} 'GetOnlineUsers#2'

# extract ids from the online payload to time the secondary call
try {
  $x = Invoke-WebRequest -Uri "$base/Game/UserInfo/GetOnlineUsers" -Method POST -Body @{} -WebSession $sess -Headers $h -UseBasicParsing -TimeoutSec 120
  $j = $x.Content | ConvertFrom-Json
  $ids = @($j.datas | ForEach-Object { $_.ID })
  Write-Output ("ONLINE_COUNT=" + $ids.Count + " IDS=" + (($ids | Select-Object -First 20) -join ','))
  if ($ids.Count -gt 0) {
    TimePost '/Game/UserInfo/GetActiveTotalControls' @{ UserIDs = (ConvertTo-Json @($ids) -Compress) } 'GetActiveTotalControls'
    TimePost '/Game/UserInfo/GetVisibleUserRows' @{ UserIDs = (ConvertTo-Json @($ids | Select-Object -First 1) -Compress) } 'GetVisibleUserRows'
  }
} catch { Write-Output ("ONLINE_PARSE_ERR " + $_.Exception.Message) }

$o = Invoke-WebRequest -Uri "$base/zh-CN/Login/LoginOut" -WebSession $sess -UseBasicParsing -TimeoutSec 30
Write-Output 'LOGOUT_OK'
