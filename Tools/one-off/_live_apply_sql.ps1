$ErrorActionPreference = 'Stop'
$dir = 'C:\MTH-Deploy\mjhl-default-line-20261103'
$sql = Join-Path $dir 'apply.sql'
& 'C:\mysql\bin\mysql.exe' --default-character-set=utf8mb4 -uroot -p123456 mth -e "source $($sql.Replace('\','/'))" 2>&1
