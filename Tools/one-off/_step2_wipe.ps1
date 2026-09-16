$mysql = 'C:\mysql\bin\mysql.exe'
$U = '-uroot'
$P = '-p123456'

# 清空：玩家/代理/流水/日志/状态（31 张）
$business = @(
 'users','userrelations','agent_hierarchy','invite_codes','rechargerecords','agencyoptlog',
 'manageropt','useroptlog','gamecommandoutbox','userlockrecord','loginmissrecord',
 'usercontrolstatus','usercontrolvalue','userscoresnapshotledger','user_daily_winloss','rank',
 'tablecoinrecord','safe_coins_log','sharebonus','transferlog','ex_change','clientexchangerecord',
 'accountlog','cashierinfo','uploadsimage','notice','activity','gameprizerecord',
 'games_money_spent','videogamecoinrecord','updateaddrnew'
)
# 清空：游戏与桌台配置（16 张）
$gamecfg = @(
 'games','gamemo','gamepara','paragame','parabet','parabetroom','paracard','parafish','paralaba',
 'pararoom','betgamecfg','cardpayoutprofile','gameconfiglaba','roomtableconfig',
 'roomtableconfig_bet','roomtableconfig_card'
)
$wipe = $business + $gamecfg

$sqlPath = 'C:\Users\Administrator\reset_20260916\wipe.sql'
$lines = New-Object System.Collections.ArrayList
[void]$lines.Add('SET FOREIGN_KEY_CHECKS=0;')
[void]$lines.Add('SET SQL_SAFE_UPDATES=0;')
foreach ($t in $wipe) { [void]$lines.Add('TRUNCATE TABLE `mth`.`' + $t + '`;') }
[void]$lines.Add("DELETE FROM ``mth``.``admin`` WHERE ID <> 'atmadmin';")
[void]$lines.Add('SET FOREIGN_KEY_CHECKS=1;')
Set-Content -Path $sqlPath -Value ($lines -join "`r`n") -Encoding ASCII

Write-Output ("SQL_FILE=" + $sqlPath + " STATEMENTS=" + $lines.Count)
Write-Output "=== BEFORE (行数) ==="
foreach ($t in $wipe) {
    $n = & $mysql $U $P -N -e ("SELECT COUNT(*) FROM mth.``" + $t + "``") 2>$null
    $a = & $mysql $U $P -N -e ("SELECT COUNT(*) FROM mth.admin WHERE ID='atmadmin'") 2>$null
    Write-Output ("BEFORE " + $t + "=" + $n)
}
Write-Output ("BEFORE admin_total=" + (& $mysql $U $P -N -e "SELECT COUNT(*) FROM mth.admin" 2>$null) + " atmadmin=" + $a)

Write-Output "=== EXECUTE ==="
Get-Content $sqlPath | & $mysql $U $P 2>&1 | Write-Output
Write-Output ("MYSQL_EXIT=" + $LASTEXITCODE)

Write-Output "=== AFTER ==="
foreach ($t in $wipe) {
    $n = & $mysql $U $P -N -e ("SELECT COUNT(*) FROM mth.``" + $t + "``") 2>$null
    Write-Output ("AFTER " + $t + "=" + $n)
}
& $mysql $U $P -t -e "SELECT ID,PRIV,RE_ENABLE FROM mth.admin;" 2>$null | Write-Output
Write-Output "=== KEPT TABLES ==="
foreach ($t in @('agent_permission_template','cardpayoutprofile_att3_bak_0907','gameacclaba','mgrpermission','parabetroom_bak_20260815','plattype','robot_seat','userrobot','userrobotnum')) {
    $n = & $mysql $U $P -N -e ("SELECT COUNT(*) FROM mth.``" + $t + "``") 2>$null
    Write-Output ("KEPT " + $t + "=" + $n)
}
