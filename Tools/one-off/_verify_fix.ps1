$mysql = 'C:\mysql\bin\mysql.exe'

Write-Output "=== PICK NEWEST UL ROW ==="
$cid = (& $mysql -uroot -p123456 -N -e "SELECT CommandId FROM mth.gamecommandoutbox WHERE CommandType='UL' ORDER BY CreatedAt DESC LIMIT 1" 2>$null)
$info = (& $mysql -uroot -p123456 -N -e "SELECT CONCAT(CommandType,' ',TargetUserId,' Status=',Status,' rc=',RetryCount,' ',Payload) FROM mth.gamecommandoutbox WHERE CommandId='$cid'" 2>$null)
Write-Output ("  CID=" + $cid)
Write-Output ("  ROW=" + $info)

Write-Output "=== RESET TO PENDING ==="
& $mysql -uroot -p123456 -e "UPDATE mth.gamecommandoutbox SET Status=0, RetryCount=0, ErrorMessage=NULL, NextRetryAt=NULL, UpdatedAt=NOW() WHERE CommandId='$cid'" 2>$null
& $mysql -uroot -p123456 -t -e "SELECT CommandType,Status,RetryCount,TargetUserId FROM mth.gamecommandoutbox WHERE CommandId='$cid'" 2>$null | Write-Output

Write-Output "=== POLL (timer runs every 60s) ==="
for ($i = 1; $i -le 10; $i++) {
    Start-Sleep -Seconds 20
    $r = (& $mysql -uroot -p123456 -N -e "SELECT CONCAT('Status=',Status,' rc=',RetryCount,' Resp=',IFNULL(LEFT(RawResponse,20),'-'),' Err=',IFNULL(LEFT(ErrorMessage,40),'-')) FROM mth.gamecommandoutbox WHERE CommandId='$cid'" 2>$null)
    Write-Output ("  t=" + ($i * 20) + "s : " + $r)
    if ($r -match 'Status=2') { Write-Output "  *** ACKED ***"; break }
}

Write-Output "=== CENTER LOG: WEB lines + UL recv (last 20) ==="
$cl = (Get-ChildItem 'C:\Server\Logs' -Filter '*.log' | Where-Object { $_.Length -gt 5000000 } | Sort-Object Length -Descending | Select-Object -First 1)
$fs = [System.IO.File]::Open($cl.FullName,'Open','Read','ReadWrite')
$t = 65536; if ($fs.Length -lt $t) { $t = $fs.Length }
$fs.Seek($fs.Length-$t,'Begin') | Out-Null
$b = New-Object byte[] $t
$fs.Read($b,0,$t) | Out-Null
$fs.Close()
$txt = [Text.Encoding]::GetEncoding(936).GetString($b)
$lines = $txt -split "`n"
$sel = @()
foreach ($l in $lines) { if ($l -match 'WEB|Rec:|UL|Unlock|\[\[玩家') { $sel += $l.Trim() } }
Write-Output ("  matched=" + $sel.Count)
foreach ($l in ($sel | Select-Object -Last 20)) {
    $a = ''; foreach ($c in $l.ToCharArray()) { if ([int][char]$c -lt 128) { $a += $c } }
    Write-Output ("  |" + ($a -replace '\s+',' '))
}
