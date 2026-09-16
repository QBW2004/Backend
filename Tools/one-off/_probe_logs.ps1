$ErrorActionPreference = 'SilentlyContinue'
Write-Output "=== recent files under C:\Backend (last 4h) ==="
Get-ChildItem C:\Backend -Recurse -File |
    Where-Object { $_.LastWriteTime -gt (Get-Date).AddHours(-4) } |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First 20 |
    ForEach-Object { Write-Output ($_.LastWriteTime.ToString('HH:mm:ss') + "  " + $_.Length + "  " + $_.FullName) }

Write-Output "=== log4net config in Web.config ==="
Select-String -Path C:\Backend\Web.config -Pattern 'log4net|rollingStyle|datePattern|file value|conversionPattern' |
    Select-Object -First 20 |
    ForEach-Object { Write-Output ($_.LineNumber.ToString() + ': ' + $_.Line.Trim()) }

Write-Output "=== appSettings Timer/WebVer ==="
Select-String -Path C:\Backend\Web.config -Pattern 'WebVer|Timer|IsRMB|ExchangeRate|serverName|pipeName|UploadPath' |
    ForEach-Object { Write-Output ($_.LineNumber.ToString() + ': ' + $_.Line.Trim()) }
