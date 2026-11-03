$ErrorActionPreference = 'Stop'
$base = 'http://127.0.0.1'
$s = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$login = Invoke-WebRequest -Uri "$base/Login/Index" -UseBasicParsing -WebSession $s -TimeoutSec 30
$m = [regex]::Match($login.Content, 'name="__RequestVerificationToken"[^>]*value="([^"]+)"')
if (-not $m.Success) { throw 'no antiforgery token on login page' }
$body = @{ uname = 'atmadmin'; upwd = '123456'; __RequestVerificationToken = $m.Groups[1].Value }
$post = Invoke-WebRequest -Uri "$base/Login/Index" -Method Post -Body $body -UseBasicParsing -WebSession $s -TimeoutSec 30
$check = Invoke-WebRequest -Uri "$base/Login/CheckLogin" -UseBasicParsing -WebSession $s -TimeoutSec 30
"checklogin=" + $check.Content
$hdr = @{ 'X-Requested-With' = 'XMLHttpRequest' }
$lines = Invoke-WebRequest -Uri "$base/Game/GameConfig/GetMjhlAgentLines" -Method Post -Body @{} -Headers $hdr -UseBasicParsing -WebSession $s -TimeoutSec 30
"lines=" + $lines.Content
$cfg = Invoke-WebRequest -Uri "$base/Game/GameConfig/GetMjhlAgentConfig" -Method Post -Body @{ lineAgent = '*' } -Headers $hdr -UseBasicParsing -WebSession $s -TimeoutSec 60
$cfgText = $cfg.Content
if ($cfgText.Length -gt 400) { $cfgText = $cfgText.Substring(0, 400) + '...' }
"defaultcfg=" + $cfgText
