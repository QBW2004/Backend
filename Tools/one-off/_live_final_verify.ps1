$ErrorActionPreference = 'Stop'
$wc = 'C:\Backend\Web.config'
(Get-Content $wc -Raw) -replace 'value="1\.0\.99"', 'value="1.0.100"' | Set-Content $wc -NoNewline -Encoding UTF8
& 'C:\Windows\System32\inetsrv\appcmd.exe' recycle apppool /apppool.name:DefaultAppPool | Out-Null
Start-Sleep -Seconds 3
"root=" + (Invoke-WebRequest -Uri 'http://127.0.0.1/' -UseBasicParsing -TimeoutSec 30).StatusCode
"api=" + (Invoke-WebRequest -Uri 'http://127.0.0.1/Api/Games' -UseBasicParsing -TimeoutSec 30).StatusCode
"webver=" + ([regex]::Match((Get-Content $wc -Raw), 'key="WebVer" value="([^"]+)"').Groups[1].Value)
Get-Process ServerCardMjhl, ServerCenterNew -ErrorAction SilentlyContinue | Select-Object Id, ProcessName, StartTime
$ini = Get-Content 'C:\Server\servers.ini'
$idx = ($ini | Select-String -Pattern 'CardMjhl' | Select-Object -First 1).LineNumber
if ($idx) { $ini[($idx-1)..([Math]::Min($idx+3, $ini.Count-1))] }
Get-NetTCPConnection -State Listen | Where-Object { $_.OwningProcess -eq (Get-Process ServerCardMjhl).Id } | Select-Object LocalAddress, LocalPort
