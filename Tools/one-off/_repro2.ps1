$sysnativePwsh = Join-Path $env:WINDIR 'Sysnative\WindowsPowerShell\v1.0\powershell.exe'
if ([Environment]::Is64BitOperatingSystem -and -not [Environment]::Is64BitProcess -and (Test-Path $sysnativePwsh)) {
    & $sysnativePwsh -NoProfile -File $PSCommandPath
    exit $LASTEXITCODE
}

$base = "http://127.0.0.1:8081"

function Try-LoginAndVisit($account, $label) {
    Write-Output "=== [$label] Login as $account, then visit /Mobile/Home ==="
    $session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
    $r1 = Invoke-WebRequest -Uri "$base/Login/Index" -WebSession $session -UseBasicParsing -TimeoutSec 20
    $tokenMatch = [regex]::Match($r1.Content, 'name="__RequestVerificationToken" type="hidden" value="([^"]+)"')
    if (-not $tokenMatch.Success) { "  Could not find antiforgery token"; return }
    $token = $tokenMatch.Groups[1].Value

    $body = @{ uname = $account; upwd = "123456"; __RequestVerificationToken = $token }
    try {
        $r2 = Invoke-WebRequest -Uri "$base/Login/Index" -Method Post -Body $body -WebSession $session -UseBasicParsing -TimeoutSec 20 -ErrorAction Stop
        "  Login POST status: $($r2.StatusCode), final url: $($r2.BaseResponse.ResponseUri)"
        if ($r2.Content -match 'uname') {
            "  Still on login page (login likely failed) - content snippet:"
            $msgMatch = [regex]::Match($r2.Content, "alert-msg[^>]*>([^<]*)")
        }
    } catch {
        "  Login POST failed: $($_.Exception.Message)"
        return
    }

    try {
        $r3 = Invoke-WebRequest -Uri "$base/Mobile/Home" -WebSession $session -UseBasicParsing -TimeoutSec 20 -ErrorAction Stop
        "  Mobile/Home status: $($r3.StatusCode), length: $($r3.Content.Length)"
    } catch {
        "  Mobile/Home FAILED: $($_.Exception.Message)"
        if ($_.Exception.Response) {
            "  Response status code: $([int]$_.Exception.Response.StatusCode)"
            $stream = $_.Exception.Response.GetResponseStream()
            $reader = New-Object System.IO.StreamReader($stream)
            $errBody = $reader.ReadToEnd()
            "  --- Error body (first 3000 chars) ---"
            $errBody.Substring(0, [Math]::Min(3000, $errBody.Length))
        }
    }
    return $session
}

# Test 1: real DB account, no app pool recycle in between
Try-LoginAndVisit -account "10010" -label "Real DB account 10010, normal flow"

Write-Output ""
Write-Output "=== Now recycle the app pool to simulate session loss, THEN visit with an OLD session cookie ==="
$oldSession = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$r1 = Invoke-WebRequest -Uri "$base/Login/Index" -WebSession $oldSession -UseBasicParsing -TimeoutSec 20
$tokenMatch = [regex]::Match($r1.Content, 'name="__RequestVerificationToken" type="hidden" value="([^"]+)"')
$token = $tokenMatch.Groups[1].Value
$body = @{ uname = "10010"; upwd = "123456"; __RequestVerificationToken = $token }
$r2 = Invoke-WebRequest -Uri "$base/Login/Index" -Method Post -Body $body -WebSession $oldSession -UseBasicParsing -TimeoutSec 20
"Logged in, cookies: $($oldSession.Cookies.GetCookies('http://127.0.0.1:8081') | ForEach-Object { $_.Name })"

Import-Module WebAdministration -ErrorAction SilentlyContinue
Restart-WebAppPool -Name "DefaultAppPool"
Start-Sleep -Seconds 5
"App pool recycled."

try {
    $r4 = Invoke-WebRequest -Uri "$base/Mobile/Home" -WebSession $oldSession -UseBasicParsing -TimeoutSec 20 -ErrorAction Stop
    "Mobile/Home (stale session) status: $($r4.StatusCode), length: $($r4.Content.Length)"
    $r4.Content.Substring(0, [Math]::Min(300, $r4.Content.Length))
} catch {
    "Mobile/Home (stale session) FAILED: $($_.Exception.Message)"
    if ($_.Exception.Response) {
        "Response status code: $([int]$_.Exception.Response.StatusCode)"
        $stream = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($stream)
        $errBody = $reader.ReadToEnd()
        "--- Error body (first 4000 chars) ---"
        $errBody.Substring(0, [Math]::Min(4000, $errBody.Length))
    }
}
