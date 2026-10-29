$ErrorActionPreference = 'Continue'
function Probe($name, $url, $body, $ctype) {
    try {
        if ($ctype) {
            $r = Invoke-WebRequest -Uri $url -Method POST -Body $body -ContentType $ctype -UseBasicParsing -TimeoutSec 15
        } else {
            $r = Invoke-WebRequest -Uri $url -Method POST -Body $body -UseBasicParsing -TimeoutSec 15
        }
        $c = $r.Content
        if ($c.Length -gt 160) { $c = $c.Substring(0,160) }
        Write-Output ("[$name] HTTP " + $r.StatusCode + " :: " + $c)
    } catch {
        Write-Output ("[$name] ERR " + $_.Exception.Message)
    }
}
Probe "AdminSetter-NoLogin"  "http://localhost:8080/Game/Admin/SetIsRelease" "ID=x&IsRelease=1" $null
Probe "GlobalWrite-NoLogin"  "http://localhost:8080/Game/Notice/SaveNotice"  "NOTICE=t&FONTSIZE=16" $null
Probe "OrderRefuseEx-NoLogin" "http://localhost:8080/Game/Recharge/OrderRefuseEx" "OrderNo=x" $null
Probe "UserTransAll-NoPwd"   "http://localhost:8081/api/UserTransAll" '{"playerId":"nonexist"}' "application/json"
Probe "UpdateUsers-NoPwd"    "http://localhost:8081/api/UpdateUsers" '{"playerId":"nonexist","name":"x"}' "application/json"
