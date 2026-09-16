$ErrorActionPreference = 'Continue'
$is64 = [Environment]::Is64BitProcess
$appcmd = if ($is64) { "$env:windir\System32\inetsrv\appcmd.exe" } else { "$env:windir\Sysnative\inetsrv\appcmd.exe" }
$mysql = 'C:\mysql\bin\mysql.exe'

Write-Output "=== BEFORE ==="
& $appcmd list apppool /apppool.name:DefaultAppPool /text:processModel.identityType 2>&1 | Write-Output
& $mysql -uroot -p123456 -t -e "SELECT CommandType,Status,RetryCount,TargetUserId,LEFT(ErrorMessage,45) Err FROM mth.gamecommandoutbox ORDER BY CreatedAt DESC LIMIT 6;" 2>$null | Write-Output

Write-Output "=== SET IDENTITY LocalSystem + RECYCLE ==="
& $appcmd set apppool /apppool.name:DefaultAppPool /processModel.identityType:LocalSystem 2>&1 | Write-Output
& $appcmd recycle apppool /apppool.name:DefaultAppPool 2>&1 | Write-Output
Start-Sleep -Seconds 8
& $appcmd list apppool /apppool.name:DefaultAppPool /text:processModel.identityType 2>&1 | Write-Output
try { $r = Invoke-WebRequest -Uri 'http://127.0.0.1:8080/zh-CN/Login/Index' -UseBasicParsing -TimeoutSec 30; Write-Output ("HTTP=" + $r.StatusCode) } catch { Write-Output ("HTTP_ERR " + $_.Exception.Message) }

Write-Output "=== POLL OUTBOX (retry service sends every ~60s) ==="
for ($i = 1; $i -le 8; $i++) {
    Start-Sleep -Seconds 30
    $rows = & $mysql -uroot -p123456 -N -e "SELECT CONCAT(CommandType,' ',Status,' rc=',RetryCount,' ',TargetUserId,' ',IFNULL(LEFT(ErrorMessage,40),'')) FROM mth.gamecommandoutbox ORDER BY CreatedAt DESC LIMIT 6" 2>$null
    Write-Output ("  t=" + ($i * 30) + "s")
    foreach ($row in $rows) { Write-Output ("    " + $row) }
    $acked = & $mysql -uroot -p123456 -N -e "SELECT COUNT(*) FROM mth.gamecommandoutbox WHERE Status=2" 2>$null
    if ($acked -gt 0) { Write-Output ("  ACKED_REACHED=" + $acked); break }
}
Write-Output "=== FINAL ==="
& $mysql -uroot -p123456 -t -e "SELECT CommandType,Status,RetryCount,TargetUserId,LEFT(RawResponse,30) Resp,LEFT(ErrorMessage,45) Err,CreatedAt FROM mth.gamecommandoutbox ORDER BY CreatedAt DESC LIMIT 6;" 2>$null | Write-Output
