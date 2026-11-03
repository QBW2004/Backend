$ErrorActionPreference = 'Stop'
$dir = 'C:\MTH-Deploy\mjhl-default-line-20261103'
Copy-Item (Join-Path $dir 'YYT.Web.dll') 'C:\Backend\bin\YYT.Web.dll' -Force
Copy-Item (Join-Path $dir 'ConfigEditor.cshtml') 'C:\Backend\Areas\Game\Views\GameConfig\ConfigEditor.cshtml' -Force
& 'C:\Windows\System32\inetsrv\appcmd.exe' recycle apppool /apppool.name:DefaultAppPool | Out-Null
Start-Sleep -Seconds 3
$r1 = Invoke-WebRequest -Uri 'http://127.0.0.1/' -UseBasicParsing -TimeoutSec 30
$r2 = Invoke-WebRequest -Uri 'http://127.0.0.1/Api/Games' -UseBasicParsing -TimeoutSec 30
$r3 = Invoke-WebRequest -Uri 'http://127.0.0.1:8081/' -UseBasicParsing -TimeoutSec 30
"root=$($r1.StatusCode) api=$($r2.StatusCode) p8081=$($r3.StatusCode)"
(Get-Item 'C:\Backend\bin\YYT.Web.dll').Length
(Get-Item 'C:\Backend\Areas\Game\Views\GameConfig\ConfigEditor.cshtml').Length
