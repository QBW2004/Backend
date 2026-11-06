param([switch]$NoBrowser, [switch]$Stop)
$ErrorActionPreference = 'Stop'
$config = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'config.json') -Raw | ConvertFrom-Json
$url = 'http://127.0.0.1:' + $config.port + '/'
$running = $false
try {
    $health = Invoke-RestMethod ($url + 'api/health') -TimeoutSec 2
    if ($health.service -ne 'mth-network-monitor-v1') { throw 'Port is used by another service.' }
    $running = $true
} catch {
    if ($_.Exception.Message -eq 'Port is used by another service.') { throw }
}
if ($Stop) {
    if ($running) {
        Invoke-RestMethod ($url + 'api/shutdown') -Method Post -Headers @{ 'X-MTH-Control' = 'local' } | Out-Null
        Write-Output 'MTH network monitor is stopping.'
    }
    return
}
if (!$running) {
    $python = (Get-Command python.exe -ErrorAction Stop).Source
    $script = Join-Path $PSScriptRoot 'monitor.py'
    $process = Start-Process -FilePath $python -ArgumentList @('"' + $script + '"') -WindowStyle Hidden -PassThru
    for ($attempt = 0; $attempt -lt 30; $attempt++) {
        Start-Sleep -Milliseconds 200
        try {
            $health = Invoke-RestMethod ($url + 'api/health') -TimeoutSec 1
            $running = $health.service -eq 'mth-network-monitor-v1'
            if ($running) { break }
        } catch {}
        if ($process.HasExited) { break }
    }
    if (!$running) { throw 'Monitor did not start. Check .build/network-monitor/monitor.log.' }
}
if (!$NoBrowser) { Start-Process -FilePath $url -WindowStyle Hidden }
Write-Output $url
