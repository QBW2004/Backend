$ErrorActionPreference = 'Stop'
$env:MYSQL_PWD = '123456'
$mysql = 'C:\mysql\bin\mysql.exe'
$dump = 'C:\mysql\bin\mysqldump.exe'
$outDir = 'C:\MTH-Deploy\template_build'
New-Item -ItemType Directory -Force $outDir | Out-Null

Write-Output "== 1) full dump mth =="
& $dump -u root --single-transaction --routines --triggers --default-character-set=utf8mb4 --hex-blob mth -r "$outDir\mth_full_raw.sql" 2>&1
Write-Output ('dump_exit=' + $LASTEXITCODE + ' size=' + (Get-Item "$outDir\mth_full_raw.sql").Length)

Write-Output "== 2) scratch import to mth_tpl =="
& $mysql -u root -e "DROP DATABASE IF EXISTS mth_tpl; CREATE DATABASE mth_tpl CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;" 2>&1
& $mysql -u root --default-character-set=utf8mb4 mth_tpl -e "SOURCE $outDir/mth_full_raw.sql" 2>&1
Write-Output ('import_exit=' + $LASTEXITCODE)

Write-Output "== 3) apply cleanup sql =="
& $mysql -u root --default-character-set=utf8mb4 mth_tpl -e "SOURCE C:/MTH-Deploy/template_build/cleanup.sql" 2>&1 | Select-Object -Last 45

Write-Output "== 4) finalize: reset atmadmin pwd + zero counters + clear invite =="
& $mysql -u root --default-character-set=utf8mb4 mth_tpl -e "UPDATE admin SET PWD='123456', COINS=0, RECHARGE=0, EXCHANGE=0, COINS_BUY=0, COINS_BACK=0, InviteCode=NULL WHERE ID='atmadmin'; SELECT ID,PWD,PRIV,COINS,InviteCode FROM admin;" 2>&1

Write-Output "== 5) dump template from mth_tpl =="
& $dump -u root --routines --triggers --default-character-set=utf8mb4 --hex-blob mth_tpl -r "$outDir\mth_tpl_data.sql" 2>&1
Write-Output ('tpldump_exit=' + $LASTEXITCODE + ' size=' + (Get-Item "$outDir\mth_tpl_data.sql").Length)

Write-Output "== 6) verify counts in mth_tpl =="
& $mysql -u root -N -B mth_tpl -e "SELECT CONCAT('users=',COUNT(*)) FROM users; SELECT CONCAT('admin=',COUNT(*)) FROM admin; SELECT CONCAT('recharge=',COUNT(*)) FROM rechargerecords; SELECT CONCAT('cardpayout=',COUNT(*)) FROM cardpayoutprofile; SELECT CONCAT('games=',COUNT(*)) FROM games; SELECT CONCAT('triggers=',COUNT(*)) FROM information_schema.triggers WHERE trigger_schema='mth_tpl';" 2>&1

Write-Output "== 7) drop scratch =="
& $mysql -u root -e "DROP DATABASE mth_tpl;" 2>&1
Write-Output "== 8) daemon task xml + pipe scripts =="
schtasks /query /tn MTH_Daemon /xml | Out-File -Encoding unicode "$outDir\MTH_Daemon.xml"
Write-Output ("taskxml=" + (Get-Item "$outDir\MTH_Daemon.xml").Length)
Copy-Item 'C:\Server\pipe_cmd.ps1' "$outDir\pipe_cmd.ps1" -EA SilentlyContinue
Copy-Item 'C:\Server\servers.ini' "$outDir\servers.ini" -EA SilentlyContinue
Write-Output DONE
