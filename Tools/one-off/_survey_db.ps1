$ErrorActionPreference = 'Continue'
$mysql = 'C:\mysql\bin\mysql.exe'

Write-Host '==== 1. table count + key counts ===='
& $mysql -u root -p123456 --default-character-set=utf8mb4 mth -N -e @"
SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA='mth' AND TABLE_TYPE='BASE TABLE';
SELECT 'users', COUNT(*) FROM users
UNION ALL SELECT 'users_online(INHALL=1)', COUNT(*) FROM users WHERE INHALL = b'1'
UNION ALL SELECT 'admin', COUNT(*) FROM admin
UNION ALL SELECT 'admin_PRIV0', COUNT(*) FROM admin WHERE PRIV = 0
UNION ALL SELECT 'atmadmin', COUNT(*) FROM admin WHERE ID = 'atmadmin'
UNION ALL SELECT 'cashierinfo', COUNT(*) FROM cashierinfo
UNION ALL SELECT 'invite_codes', COUNT(*) FROM invite_codes
UNION ALL SELECT 'userrelations', COUNT(*) FROM userrelations
UNION ALL SELECT 'rechargerecords', COUNT(*) FROM rechargerecords;
"@ 2>$null

Write-Host '==== 2. admin accounts ===='
& $mysql -u root -p123456 --default-character-set=utf8mb4 mth -e "SELECT ID, PRIV, AGENCY, RE_ENABLE FROM admin ORDER BY PRIV, ID;" 2>$null

Write-Host '==== 3. users list ===='
& $mysql -u root -p123456 --default-character-set=utf8mb4 mth -e "SELECT ID, NAME, AGENCY, COINS, FROZEN, INHALL+0 AS online FROM users ORDER BY ID LIMIT 50;" 2>$null

Write-Host '==== 4. scheduled tasks that may auto-start servers ===='
Get-ScheduledTask | Where-Object { $_.State -ne 'Disabled' } | ForEach-Object {
    $act = ($_.Actions | ForEach-Object { $_.Execute + ' ' + $_.Arguments }) -join '; '
    [PSCustomObject]@{ Name = $_.TaskName; State = $_.State; Action = $act }
} | Where-Object { $_.Action -match 'Server|C:\\Server' -or $_.Name -match 'Server|MTH|Game' } |
    Format-Table -AutoSize | Out-String -Width 250 | Write-Host

Write-Host '==== 5. servers.ini head ===='
Get-Content 'C:\Server\servers.ini' -TotalCount 40 | Write-Host
