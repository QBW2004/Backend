$sysnativePwsh = Join-Path $env:WINDIR 'Sysnative\WindowsPowerShell\v1.0\powershell.exe'
if ([Environment]::Is64BitOperatingSystem -and -not [Environment]::Is64BitProcess -and (Test-Path $sysnativePwsh)) {
    & $sysnativePwsh -NoProfile -File $PSCommandPath
    exit $LASTEXITCODE
}
Write-Output "=== admin table: ID and password field (need to know actual column name/values) ==="
& "C:\mysql\bin\mysql.exe" -u root --password=123456 --default-character-set=utf8 mth -e "SELECT * FROM admin WHERE ID='10010';" 2>&1 | Select-String -NotMatch "Warning"
