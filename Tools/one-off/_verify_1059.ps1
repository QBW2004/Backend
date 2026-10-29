$core = Get-Content C:\Backend\Scripts\app\phone\phone.core.js -Raw -Encoding UTF8
Write-Output ('CARD_ACTION_NAMES_OFFLINE = ' + $core.Contains('CARD_ACTION_NAMES_OFFLINE'))
Write-Output ('core removed-15 = ' + (-not $core.Contains("id: 15, text: '水浒传'")))
$idx = Get-Content C:\Backend\Areas\Game\Views\UserInfo\Index.cshtml -Raw -Encoding UTF8
Write-Output ('index removed-15 = ' + (-not $idx.Contains("id: 15, text: '水浒传'")))
$onl = Get-Content C:\Backend\Areas\Game\Views\UserInfo\OnlineUsers.cshtml -Raw -Encoding UTF8
Write-Output ('online removed-15 = ' + (-not $onl.Contains("id: 15, text: '水浒传'")))
[xml]$x = Get-Content C:\Backend\Web.config -Raw
$ver = @($x.configuration.appSettings.add) | Where-Object { $_.key -eq 'WebVer' } | Select-Object -First 1
Write-Output ('WebVer = ' + $ver.value)
$resp = Invoke-WebRequest -Uri 'http://127.0.0.1:8080/Scripts/app/phone/phone.core.js' -UseBasicParsing -TimeoutSec 20
Write-Output ('http core.js status = ' + $resp.StatusCode + ' offlineMap = ' + $resp.Content.Contains('CARD_ACTION_NAMES_OFFLINE'))
