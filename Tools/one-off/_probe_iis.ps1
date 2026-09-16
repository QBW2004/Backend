$ErrorActionPreference = 'SilentlyContinue'
Write-Output "=== IIS sites ==="
Import-Module WebAdministration
Get-Website | ForEach-Object { Write-Output ($_.Name + " | state=" + $_.State + " | path=" + $_.physicalPath + " | bindings=" + ($_.bindings.Collection | ForEach-Object { $_.bindingInformation }) -join ',') }
Write-Output "=== app pools ==="
Get-ChildItem IIS:\AppPools | ForEach-Object { Write-Output ($_.Name + " | state=" + $_.State + " | v4=" + $_.managedRuntimeVersion + " | pipeline=" + $_.managedPipelineMode) }

Write-Output "=== yyt_*.log modified in last 8h (all drives) ==="
foreach ($drv in (Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Name -match '^[A-Z]$' })) {
    Get-ChildItem ($drv.Name + ':\') -Recurse -File -Filter 'yyt_*.log' -ErrorAction SilentlyContinue |
        Where-Object { $_.LastWriteTime -gt (Get-Date).AddHours(-8) } |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 10 |
        ForEach-Object { Write-Output ($_.LastWriteTime.ToString('HH:mm:ss') + "  " + $_.Length + "  " + $_.FullName) }
}

Write-Output "=== drives ==="
Get-PSDrive -PSProvider FileSystem | ForEach-Object { Write-Output ($_.Name + ' root=' + $_.Root + ' free=' + $_.Free) }
