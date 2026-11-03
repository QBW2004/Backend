$ErrorActionPreference = 'Stop'
$base = 'http://127.0.0.1'
$s = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$login = Invoke-WebRequest -Uri "$base/Login/Index" -UseBasicParsing -WebSession $s -TimeoutSec 30
"loginpage=$($login.StatusCode) len=$($login.Content.Length)"
$m = [regex]::Match($login.Content, 'name="__RequestVerificationToken"[^>]*value="([^"]+)"')
"tokenfound=$($m.Success)"
$body = @{ uname = 'atmadmin'; upwd = '123456'; __RequestVerificationToken = $m.Groups[1].Value }
try {
    $post = Invoke-WebRequest -Uri "$base/Login/Index" -Method Post -Body $body -UseBasicParsing -WebSession $s -TimeoutSec 30
    "post=$($post.StatusCode) uri=$($post.BaseResponse.ResponseUri)"
    $txt = $post.Content
    if ($txt.Length -gt 600) { $txt = $txt.Substring(0, 600) }
    "postbody=" + ($txt -replace '\s+', ' ')
} catch {
    "posterror=$($_.Exception.Message)"
}
$cookies = $s.Cookies.GetCookies($base) | ForEach-Object { $_.Name }
"cookies=$($cookies -join ',')"
