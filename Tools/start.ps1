param(
    [int]$Port = 8080,
    [switch]$Stop
)

$iis = "C:\Program Files\IIS Express\iisexpress.exe"
$config = Join-Path $PSScriptRoot "apphost.config"

if ($Stop) {
    Get-Process iisexpress -ErrorAction SilentlyContinue | Stop-Process -Force
    Write-Host "IIS Express stopped" -ForegroundColor Yellow
    return
}

Write-Host "Starting MTH-Backend on http://localhost:$Port ..." -ForegroundColor Green
Write-Host "Press Ctrl+C to stop" -ForegroundColor DarkGray

& $iis /config:$config /site:WebSite1
