$sysnativePwsh = Join-Path $env:WINDIR 'Sysnative\WindowsPowerShell\v1.0\powershell.exe'
if ([Environment]::Is64BitOperatingSystem -and -not [Environment]::Is64BitProcess -and (Test-Path $sysnativePwsh)) {
    & $sysnativePwsh -NoProfile -File $PSCommandPath
    exit $LASTEXITCODE
}

Write-Output "=== Raw HTTP response headers for GET /Login/Index (does Set-Cookie for ASP.NET_SessionId appear at all?) ==="
$req = [System.Net.HttpWebRequest]::Create("http://127.0.0.1:8081/Login/Index")
$req.Method = "GET"
$resp = $req.GetResponse()
foreach ($h in $resp.Headers.AllKeys) {
    "$h : $($resp.Headers[$h])"
}
$resp.Close()

Write-Output "=== IIS applicationHost.config: session state module enabled? ==="
$appcmd = "$env:SystemRoot\System32\inetsrv\appcmd.exe"
& $appcmd list config "Default Web Site" /section:system.webServer/modules 2>&1 | Select-String -Pattern "Session"

Write-Output "=== Global modules (server level) ==="
& $appcmd list modules 2>&1 | Select-String -Pattern "Session"

Write-Output "=== .NET machine.config sessionState default ==="
$netfxConfig = "$env:WINDIR\Microsoft.NET\Framework64\v4.0.30319\Config\machine.config"
if (Test-Path $netfxConfig) {
    Select-String -Path $netfxConfig -Pattern "sessionState"
}

Write-Output "=== App pool identity (session state relies on IIS worker process correctly) ==="
Import-Module WebAdministration -ErrorAction SilentlyContinue
Get-Item "IIS:\AppPools\DefaultAppPool" | Select-Object Name, managedRuntimeVersion, managedPipelineMode
(Get-Item "IIS:\AppPools\DefaultAppPool").processModel | Select-Object identityType
