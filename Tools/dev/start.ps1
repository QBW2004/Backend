param(
    [int]$Port = 8080,
    [switch]$Stop
)

$iis = "C:\Program Files\IIS Express\iisexpress.exe"
$config = Join-Path (Resolve-Path (Join-Path $PSScriptRoot "..\..")) "apphost.config"
$webroot = Join-Path (Resolve-Path (Join-Path $PSScriptRoot "..\..")) "TTY.Web"

if ($Stop) {
    Get-Process iisexpress -ErrorAction SilentlyContinue | Stop-Process -Force
    Write-Host "IIS Express stopped" -ForegroundColor Yellow
    return
}

if (-not (Test-Path $iis)) {
    Write-Host "[ERROR] IIS Express not found: $iis" -ForegroundColor Red
    Write-Host "        Install from: https://www.microsoft.com/en-us/download/details.aspx?id=48264" -ForegroundColor Red
    exit 1
}

if (Test-Path $config) {
    Write-Host "Starting MTH-Backend on http://localhost:$Port ..." -ForegroundColor Green
    Write-Host "Press Ctrl+C to stop" -ForegroundColor DarkGray
    & $iis /config:$config /site:WebSite1
} else {
    Write-Host "[WARN] apphost.config not found, using direct path mode." -ForegroundColor Yellow
    Write-Host "Starting MTH-Backend on http://localhost:$Port ..." -ForegroundColor Green
    Write-Host "Press Ctrl+C to stop" -ForegroundColor DarkGray
    & $iis /path:$webroot /port:$Port /systray:false
}
