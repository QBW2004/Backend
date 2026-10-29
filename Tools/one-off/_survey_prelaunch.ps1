$ErrorActionPreference = 'Continue'
Write-Host '==== 1. Game server processes ===='
Get-Process | Where-Object { $_.Name -match '^(Server|Game|Fish|Card|Laba|Robot)' } |
    Select-Object Name, Id, StartTime | Sort-Object Name | Format-Table -AutoSize | Out-String -Width 200 | Write-Host

Write-Host '==== 2. C:\Server listing ===='
if (Test-Path 'C:\Server') {
    Get-ChildItem 'C:\Server' | Select-Object Name, Length | Format-Table -AutoSize | Out-String -Width 200 | Write-Host
}

Write-Host '==== 3. MySQL binaries ===='
foreach ($p in @('C:\mysql\bin\mysql.exe','C:\mysql\bin\mysqldump.exe',
                 'C:\Program Files\MySQL\MySQL Server 5.7\bin\mysql.exe',
                 'C:\Program Files\MySQL\MySQL Server 8.4\bin\mysql.exe')) {
    if (Test-Path $p) { Write-Host "FOUND: $p" }
}
Get-Service | Where-Object { $_.Name -match 'mysql|MySQL' } | Select-Object Name, Status, StartType | Format-Table -AutoSize | Out-String | Write-Host

Write-Host '==== 4. Web.config DbConnString ===='
[xml]$x = Get-Content 'C:\Backend\Web.config' -Raw
$conn = @($x.configuration.connectionStrings.add) | Where-Object { $_.name -eq 'DbConnString' } | Select-Object -First 1
Write-Host ("ConnStr: " + $conn.connectionString)
$ver = @($x.configuration.appSettings.add) | Where-Object { $_.key -eq 'WebVer' } | Select-Object -First 1
Write-Host ("WebVer: " + $ver.value)
