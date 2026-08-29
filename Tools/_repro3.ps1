$sysnativePwsh = Join-Path $env:WINDIR 'Sysnative\WindowsPowerShell\v1.0\powershell.exe'
if ([Environment]::Is64BitOperatingSystem -and -not [Environment]::Is64BitProcess -and (Test-Path $sysnativePwsh)) {
    & $sysnativePwsh -NoProfile -File $PSCommandPath
    exit $LASTEXITCODE
}

$cookieJar = "$env:TEMP\mth_cookies.txt"
Remove-Item $cookieJar -Force -ErrorAction SilentlyContinue
$base = "http://127.0.0.1:8081"
$curl = "$env:SystemRoot\System32\curl.exe"

Write-Output "=== Step 1: GET login page with curl, save cookies ==="
$loginPage = & $curl -s -m 15 -c $cookieJar -b $cookieJar "$base/Login/Index"
$tokenMatch = [regex]::Match($loginPage, 'name="__RequestVerificationToken" type="hidden" value="([^"]+)"')
if (-not $tokenMatch.Success) { "no token found"; exit 1 }
$token = $tokenMatch.Groups[1].Value
"Token: $($token.Substring(0,20))..."

Write-Output "=== Step 2: POST login (curl follows cookies automatically) ==="
$loginResp = & $curl -s -m 15 -c $cookieJar -b $cookieJar -X POST "$base/Login/Index" `
    --data-urlencode "uname=atmadmin" `
    --data-urlencode "upwd=123456" `
    --data-urlencode "__RequestVerificationToken=$token" `
    -D "$env:TEMP\mth_login_headers.txt" -o "$env:TEMP\mth_login_body.txt" -w "HTTPSTATUS:%{http_code} REDIRECT:%{redirect_url}\n"
$loginResp
"--- Login response headers ---"
Get-Content "$env:TEMP\mth_login_headers.txt"

Write-Output "=== Step 3: GET /Mobile/Home with the saved cookies ==="
$mobileResp = & $curl -s -m 20 -c $cookieJar -b $cookieJar "$base/Mobile/Home" -D "$env:TEMP\mth_mobile_headers.txt" -o "$env:TEMP\mth_mobile_body.txt" -w "HTTPSTATUS:%{http_code}\n"
$mobileResp
"--- Mobile/Home response headers ---"
Get-Content "$env:TEMP\mth_mobile_headers.txt"
"--- Mobile/Home response body (first 100 lines or 4000 chars) ---"
$body = Get-Content "$env:TEMP\mth_mobile_body.txt" -Raw
$body.Substring(0, [Math]::Min(4000, $body.Length))

Write-Output "=== Cookie jar contents ==="
Get-Content $cookieJar
