$sysnativePwsh = Join-Path $env:WINDIR 'Sysnative\WindowsPowerShell\v1.0\powershell.exe'
if ([Environment]::Is64BitOperatingSystem -and -not [Environment]::Is64BitProcess -and (Test-Path $sysnativePwsh)) {
    & $sysnativePwsh -NoProfile -File $PSCommandPath
    exit $LASTEXITCODE
}
$curl = "$env:SystemRoot\System32\curl.exe"
Write-Output "=== curl version ==="
& $curl --version
Write-Output "=== raw GET /Login/Index, with -L to follow redirects, verbose headers ==="
$out = & $curl -s -m 15 -L -D - "http://127.0.0.1:8081/Login/Index" -o "$env:TEMP\raw_login.html"
$out
Write-Output "=== body length and first 500 chars ==="
$body = Get-Content "$env:TEMP\raw_login.html" -Raw
"Length: $($body.Length)"
$body.Substring(0, [Math]::Min(500, $body.Length))
