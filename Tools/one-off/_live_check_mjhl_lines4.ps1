$ErrorActionPreference = 'Stop'
$base = 'http://127.0.0.1'
$s = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$login = Invoke-WebRequest -Uri "$base/zh-CN/Login/Index" -UseBasicParsing -WebSession $s -TimeoutSec 30
$m = [regex]::Match($login.Content, 'name="__RequestVerificationToken"[^>]*value="([^"]+)"')
if (-not $m.Success) { throw 'no antiforgery token' }
$body = @{ uname = 'atmadmin'; upwd = '123456'; __RequestVerificationToken = $m.Groups[1].Value }
$post = Invoke-WebRequest -Uri "$base/zh-CN/Login/Index" -Method Post -Body $body -UseBasicParsing -WebSession $s -TimeoutSec 30
"post_uri=$($post.BaseResponse.ResponseUri)"
$check = Invoke-WebRequest -Uri "$base/Login/CheckLogin" -UseBasicParsing -WebSession $s -TimeoutSec 30
"checklogin=" + $check.Content
$hdr = @{ 'X-Requested-With' = 'XMLHttpRequest' }
$lines = Invoke-WebRequest -Uri "$base/Game/GameConfig/GetMjhlAgentLines" -Method Post -Body @{} -Headers $hdr -UseBasicParsing -WebSession $s -TimeoutSec 30
"lines=" + $lines.Content
$cfg = Invoke-WebRequest -Uri "$base/Game/GameConfig/GetMjhlAgentConfig" -Method Post -Body @{ lineAgent = '*' } -Headers $hdr -UseBasicParsing -WebSession $s -TimeoutSec 60
$t = $cfg.Content
if ($t.Length -gt 500) { $t = $t.Substring(0, 500) + '...' }
"defaultcfg=" + $t
