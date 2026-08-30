$sysnativePwsh = Join-Path $env:WINDIR 'Sysnative\WindowsPowerShell\v1.0\powershell.exe'
if ([Environment]::Is64BitOperatingSystem -and -not [Environment]::Is64BitProcess -and (Test-Path $sysnativePwsh)) {
    & $sysnativePwsh -NoProfile -File $PSCommandPath
    exit $LASTEXITCODE
}
& "C:\mysql\bin\mysql.exe" -u root --password=123456 --execute="USE mth; SHOW TABLES; SELECT COUNT(*) AS table_count FROM information_schema.tables WHERE table_schema='mth';"
