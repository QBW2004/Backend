$sysnativePwsh = Join-Path $env:WINDIR 'Sysnative\WindowsPowerShell\v1.0\powershell.exe'
if ([Environment]::Is64BitOperatingSystem -and -not [Environment]::Is64BitProcess -and (Test-Path $sysnativePwsh)) {
    & $sysnativePwsh -NoProfile -File $PSCommandPath
    exit $LASTEXITCODE
}

$base = "http://127.0.0.1:8081"
$session = New-Object Microsoft.PowerShell.Commands.WebRequestSession

Write-Output "=== Step 1: GET login page ==="
$r1 = Invoke-WebRequest -Uri "$base/Login/Index" -WebSession $session -UseBasicParsing -TimeoutSec 20
"Cookies after GET: $($session.Cookies.GetCookies([Uri]"$base/Login/Index") | ForEach-Object { $_.Name })"
$tokenMatch = [regex]::Match($r1.Content, 'name="__RequestVerificationToken" type="hidden" value="([^"]+)"')
$token = $tokenMatch.Groups[1].Value
"Token found: $($token.Length -gt 0)"

Write-Output "=== Step 2: POST login as atmadmin ==="
$body = @{ uname = "atmadmin"; upwd = "123456"; __RequestVerificationToken = $token }
$r2 = Invoke-WebRequest -Uri "$base/Login/Index" -Method Post -Body $body -WebSession $session -UseBasicParsing -TimeoutSec 20
"POST status: $($r2.StatusCode)"
"Final URI: $($r2.BaseResponse.ResponseUri)"
"Cookies after POST: $($session.Cookies.GetCookies([Uri]"$base/Login/Index") | ForEach-Object { "$($_.Name)=$($_.Value.Substring(0,[Math]::Min(15,$_.Value.Length)))" })"

# 判断是否真的登录成功：登录页会显示 uname/upwd 输入框，Mgr 首页不会
$stillOnLoginPage = $r2.Content -match 'id="uname"'
"Still shows login form (uname input): $stillOnLoginPage"
if ($r2.Content -match 'alert-msg[^>]*>\s*([^<]*)\s*<') { "Message shown: $($Matches[1])" }

Write-Output "=== Step 3: GET /Mobile/Home with this session ==="
try {
    $r3 = Invoke-WebRequest -Uri "$base/Mobile/Home" -WebSession $session -UseBasicParsing -TimeoutSec 20 -ErrorAction Stop
    "Status: $($r3.StatusCode), length: $($r3.Content.Length)"
    $isLoginForm = $r3.Content -match 'id="uname"'
    "Redirected back to login form: $isLoginForm"
    if (-not $isLoginForm) {
        "--- SUCCESS: real Mobile/Home content ---"
        $r3.Content.Substring(0, [Math]::Min(1000, $r3.Content.Length))
    }
} catch {
    "Mobile/Home FAILED: $($_.Exception.Message)"
    if ($_.Exception.Response) {
        "Response status code: $([int]$_.Exception.Response.StatusCode)"
        $stream = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($stream)
        $errBody = $reader.ReadToEnd()
        "--- Error body (first 5000 chars) ---"
        $errBody.Substring(0, [Math]::Min(5000, $errBody.Length))
    }
}
