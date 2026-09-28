$ErrorActionPreference = 'Continue'
$base = 'http://127.0.0.1'
$h = @{ 'X-Requested-With' = 'XMLHttpRequest' }

$loginPage = Invoke-WebRequest -Uri "$base/zh-CN/Login/Index" -SessionVariable sess -UseBasicParsing -TimeoutSec 60
$lm = [regex]::Match($loginPage.Content, 'name="__RequestVerificationToken"[^>]*value="([^"]*)"')
$login = Invoke-WebRequest -Uri "$base/zh-CN/Login/Index" -Method POST -Body @{ uname = 'atmadmin'; upwd = '123456'; __RequestVerificationToken = $lm.Groups[1].Value } -WebSession $sess -UseBasicParsing -TimeoutSec 60
Write-Output ("LOGIN status=" + $login.StatusCode + " url=" + $login.BaseResponse.ResponseUri)

function Probe($url, $method, $body) {
    try {
        if ($method -eq 'GET') {
            $r = Invoke-WebRequest -Uri $url -WebSession $sess -UseBasicParsing -TimeoutSec 60
        } else {
            $r = Invoke-WebRequest -Uri $url -Method POST -Body $body -WebSession $sess -Headers $h -UseBasicParsing -TimeoutSec 60
        }
        Write-Host ("OK  " + $url + " status=" + $r.StatusCode + " len=" + $r.Content.Length)
        return $r
    } catch {
        $resp = $_.Exception.Response
        $code = if ($resp) { [int]$resp.StatusCode } else { -1 }
        $txt = ''
        if ($resp) {
            $sr = New-Object System.IO.StreamReader($resp.GetResponseStream())
            $txt = $sr.ReadToEnd()
        }
        Write-Host ("ERR " + $url + " code=" + $code + " ex=" + $_.Exception.Message)
        # 打印错误页里的 <title> 和错误信息摘要
        $t = [regex]::Match($txt, '<title>(.*?)</title>')
        if ($t.Success) { Write-Host ("  TITLE: " + $t.Groups[1].Value) }
        $i = $txt.IndexOf('说明')
        if ($i -ge 0) { Write-Host ("  BODY: " + $txt.Substring($i, [Math]::Min(300, $txt.Length - $i))) }
        else { Write-Host ("  BODY: " + $txt.Substring(0, [Math]::Min(300, $txt.Length))) }
        return $null
    }
}

$page = Probe "$base/zh-CN/Game/GameConfig/Index" 'GET' $null
if ($null -eq $page) { $page = Probe "$base/Game/GameConfig/Index" 'GET' $null }
if ($null -eq $page) { $page = Probe "$base/Mgr/Index?view=pc" 'GET' $null }
$cfg = Probe "$base/Game/GameConfig/GetTableConfig" 'POST' @{ GAME_TYPE = '0'; GAME_ID = '10' }
if ($cfg) { Write-Output ("  CFG head: " + $cfg.Content.Substring(0, [Math]::Min(200, $cfg.Content.Length))) }
