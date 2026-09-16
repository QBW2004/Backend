$mysql = 'C:\mysql\bin\mysql.exe'
$tables = @('games','gamemo','gamepara','paragame','parabet','parabetroom','paracard','parafish','paralaba','pararoom','betgamecfg','cardpayoutprofile','gameconfiglaba','roomtableconfig','roomtableconfig_bet','roomtableconfig_card')

Write-Output "=== 1) HEX CHECK (games.Name) ==="
Write-Output "  火凤凰(expect E781ABE587A4E587B0), 水浒传(expect E6B0B4E6B5AEE4BCA0)"
& $mysql -uroot -p123456 -N -e "SELECT CONCAT(GameId,'=',HEX(Name)) FROM mth_stage.games WHERE GameId IN (5,53,6,16,44) ORDER BY GameId;" 2>$null | Write-Output

Write-Output "=== 2) SCHEMA COMPARE (columns per table: mth vs mth_stage) ==="
$sqlSchema = "SELECT TABLE_NAME, COUNT(*) c FROM information_schema.COLUMNS WHERE TABLE_SCHEMA='mth' GROUP BY TABLE_NAME"
$m1 = @{}; & $mysql -uroot -p123456 -N -e $sqlSchema 2>$null | ForEach-Object { $p = $_ -split "`t"; $m1[$p[0]] = $p[1] }
$m2 = @{}; & $mysql -uroot -p123456 -N -e ($sqlSchema -replace "TABLE_SCHEMA='mth'", "TABLE_SCHEMA='mth_stage'") 2>$null | ForEach-Object { $p = $_ -split "`t"; $m2[$p[0]] = $p[1] }
$bad = @()
foreach ($t in $tables) {
    $a = $m1[$t]; $b = $m2[$t]
    $s = if ($a -eq $b) { 'OK  ' } else { 'DIFF'; $bad += $t }
    Write-Output ("  " + $s + " " + $t.PadRight(24) + " mth=" + $a + " stage=" + $b)
}
Write-Output ("  SCHEMA_DIFF=" + ($bad -join ','))

Write-Output "=== 3) COPY CONFIG mth_stage -> mth ==="
foreach ($t in $tables) {
    & $mysql -uroot -p123456 -e ("DELETE FROM mth.``" + $t + "``;") 2>$null
    & $mysql -uroot -p123456 -e ("INSERT INTO mth.``" + $t + "`` SELECT * FROM mth_stage.``" + $t + "``;") 2>&1 | Where-Object { $_ -notmatch 'password on the command line' } | ForEach-Object { Write-Output ("  ERR " + $t + ": " + $_) }
    $n = & $mysql -uroot -p123456 -N -e ("SELECT COUNT(*) FROM mth.``" + $t + "``") 2>$null
    $s = & $mysql -uroot -p123456 -N -e ("SELECT COUNT(*) FROM mth_stage.``" + $t + "``") 2>$null
    $mark = if ([string]$n -eq [string]$s) { 'OK ' } else { 'DIFF' }
    Write-Output ("  " + $mark + " " + $t.PadRight(24) + " mth=" + $n + " stage=" + $s)
}

Write-Output "=== 4) VERIFY DATA IN mth ==="
& $mysql -uroot -p123456 -N -e "SELECT CONCAT(GameId,'=',HEX(Name),' enable=',Enable) FROM mth.games WHERE GameId IN (5,53,16) ORDER BY GameId;" 2>$null | Write-Output
& $mysql -uroot -p123456 -t -e "SELECT COUNT(*) AS games_total, SUM(Enable) AS enabled FROM mth.games;" 2>$null | Write-Output

Write-Output "=== 5) PLAYER TABLES STILL EMPTY ==="
& $mysql -uroot -p123456 -t -e "SELECT 'users' t, COUNT(*) n FROM mth.users UNION ALL SELECT 'admin', COUNT(*) FROM mth.admin UNION ALL SELECT 'rechargerecords', COUNT(*) FROM mth.rechargerecords UNION ALL SELECT 'agencyoptlog', COUNT(*) FROM mth.agencyoptlog UNION ALL SELECT 'userrobot', COUNT(*) FROM mth.userrobot;" 2>$null | Write-Output
