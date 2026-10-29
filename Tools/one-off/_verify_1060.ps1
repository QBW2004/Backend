[xml]$x = Get-Content C:\Backend\Web.config -Raw
$ver = @($x.configuration.appSettings.add) | Where-Object { $_.key -eq 'WebVer' } | Select-Object -First 1
Write-Output ('WebVer = ' + $ver.value)
$core = Get-Content C:\Backend\Scripts\app\phone\phone.core.js -Raw -Encoding UTF8
Write-Output ('postInFlight = ' + $core.Contains('postInFlight'))
Write-Output ('abortInFlightPosts = ' + $core.Contains('abortInFlightPosts'))
Write-Output ('hidden-guard = ' + $core.Contains("status !== 'abort' && !document.hidden"))
$pl = Get-Content C:\Backend\Scripts\app\phone\phone.players.js -Raw -Encoding UTF8
Write-Output ('players aborted-guard = ' + $pl.Contains('if (aborted || document.hidden) return;'))
$ctrl = Get-Content C:\Backend\Scripts\app\phone\phone.control.js -Raw -Encoding UTF8
Write-Output ('control hidden-guard = ' + $ctrl.Contains('if (!document.hidden) refreshCtrlStatus(true);'))
$det = Get-Content C:\Backend\Scripts\app\phone\phone.playerdetail.js -Raw -Encoding UTF8
Write-Output ('detail hidden-guard = ' + $det.Contains('if (!account || document.hidden) return;'))
$resp = Invoke-WebRequest -Uri 'http://127.0.0.1:8080/Scripts/app/phone/phone.core.js' -UseBasicParsing -TimeoutSec 20
Write-Output ('http status = ' + $resp.StatusCode + ' live = ' + $resp.Content.Contains('abortInFlightPosts'))
