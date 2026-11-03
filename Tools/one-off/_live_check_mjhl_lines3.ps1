$ErrorActionPreference = 'Stop'
$base = 'http://127.0.0.1'
$s = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$login = Invoke-WebRequest -Uri "$base/Login/Index" -UseBasicParsing -WebSession $s -TimeoutSec 30
$m = [regex]::Match($login.Content, 'name="__RequestVerificationToken"[^>]*value="([^"]+)"')
$body = @{ uname = 'atmadmin'; upwd = '123456'; __RequestVerificationToken = $m.Groups[1].Value }
$post = Invoke-WebRequest -Uri "$base/Login/Index" -Method Post -Body $body -UseBasicParsing -WebSession $s -TimeoutSec 30
$msg = [regex]::Match($post.Content, '(?s)<div[^>]*class="[^"]*(?:alert|error|msg)[^"]*"[^>]*>(.*?)</div>')
"alert=$($msg.Value -replace '\s+',' ')"
$m2 = [regex]::Matches($post.Content, '(?s)(登录失败|密码|验证码|锁定|不存在|禁用)[^<]{0,40}')
foreach ($x in $m2) { "hit=" + ($x.Value -replace '\s+',' ') }
