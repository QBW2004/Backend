# One-off: apply migration 20 (pararoom.scoreSwitch -> DECIMAL(10,2)) on production.
$ErrorActionPreference = 'Stop'
$cfg = [xml](Get-Content C:\Backend\Web.config -Raw)
$cs = ($cfg.configuration.connectionStrings.add | Where-Object { $_.name -eq 'DbConnString' } | Select-Object -First 1).connectionString
if ($cs -match 'Pwd=([^;]*)') { $env:MYSQL_PWD = $Matches[1] }
$mysql = 'C:\mysql\bin\mysql.exe'

$cur = & $mysql -uroot -N -B -e "SELECT column_type FROM information_schema.columns WHERE table_schema='mth' AND table_name='pararoom' AND column_name='scoreSwitch';"
Write-Output ("scoreSwitch BEFORE: " + $cur)
if ($cur -notmatch 'decimal') {
  & $mysql -uroot mth -e "ALTER TABLE pararoom MODIFY COLUMN scoreSwitch DECIMAL(10,2) NULL DEFAULT 1 COMMENT '加减炮幅度(支持小数0.1-0.9)';"
  $after = & $mysql -uroot -N -B -e "SELECT column_type FROM information_schema.columns WHERE table_schema='mth' AND table_name='pararoom' AND column_name='scoreSwitch';"
  Write-Output ("scoreSwitch AFTER: " + $after)
} else {
  Write-Output 'scoreSwitch already decimal, skip ALTER'
}

& $mysql -uroot -N -B -e "SELECT CONCAT('pararoom.MaxSeats=',column_type) FROM information_schema.columns WHERE table_schema='mth' AND table_name='pararoom' AND column_name='MaxSeats'; SELECT CONCAT('roomtableconfig.MaxSeats=',column_type) FROM information_schema.columns WHERE table_schema='mth' AND table_name='roomtableconfig' AND column_name='MaxSeats'; SELECT CONCAT('pararoom.Rows=',COUNT(*)) FROM mth.pararoom; SELECT CONCAT('users.Rows=',COUNT(*)) FROM mth.users;"
