$dirs = 'C:\Server\ServerCardDscj\x64\Release','C:\Server\ServerCardDazhi\x64\Release','C:\Server\ServerFishJC\x64\Release','C:\Server\ServerCenterNew\x64\Release','C:\Server\ServerManager\x64\Release','C:\Server\ServerRobot\x64\Release'
foreach ($d in $dirs) {
  Write-Output ("== " + $d + " ==")
  Get-ChildItem $d -Recurse -EA SilentlyContinue | ForEach-Object {
    $rel = $_.FullName.Substring($d.Length).TrimStart('\')
    Write-Output ('  ' + $rel + ' ' + $(if ($_.PSIsContainer) {'<DIR>'} else {$_.Length}))
  }
}
Write-Output "== admin table columns =="
$env:MYSQL_PWD = '123456'
& 'C:\mysql\bin\mysql.exe' -u root -N -B -e "SELECT CONCAT(column_name,'|',column_type) FROM information_schema.columns WHERE table_schema='mth' AND table_name='admin' ORDER BY ordinal_position;" 2>&1
& 'C:\mysql\bin\mysql.exe' -u root -N -B -e "SELECT ID,PRIV,COINS,RECHARGE,EXCHANGE FROM mth.admin;" 2>&1
