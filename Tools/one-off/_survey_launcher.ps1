$ErrorActionPreference = 'Continue'

Write-Host '==== 1. management/launcher processes ===='
Get-CimInstance Win32_Process | Where-Object {
    $_.Name -match 'Admin|Daemon|Manager|Launch|Console' -and $_.Name -notmatch 'svchost|Lsass|winlogon|fontdrv|dwm|conhost$'
} | Select-Object Name, ProcessId, ExecutablePath, CommandLine |
    Format-List | Out-String -Width 250 | Write-Host

Write-Host '==== 2. Daemon.exe detail ===='
Get-CimInstance Win32_Process -Filter "Name='Daemon.exe'" |
    Select-Object ProcessId, ExecutablePath, CommandLine, @{N='Parent';E={ (Get-Process -Id $_.ParentProcessId -ErrorAction SilentlyContinue).Name }} |
    Format-List | Out-String -Width 250 | Write-Host

Write-Host '==== 3. Admin.exe running? ===='
Get-CimInstance Win32_Process -Filter "Name='Admin.exe'" |
    Select-Object ProcessId, ExecutablePath | Format-Table -AutoSize | Out-String | Write-Host

Write-Host '==== 4. ServerManager dir layout ===='
Get-ChildItem 'C:\Server\ServerManager' -Recurse -Filter '*.exe' |
    Select-Object FullName, Length, LastWriteTime | Format-Table -AutoSize | Out-String -Width 250 | Write-Host

Write-Host '==== 5. MTH_Daemon scheduled task ===='
$t = Get-ScheduledTask -TaskName 'MTH_Daemon' -ErrorAction SilentlyContinue
if ($t) {
    $t.Actions | ForEach-Object { Write-Host ("action: " + $_.Execute + ' ' + $_.Arguments) }
    $t.Triggers | ForEach-Object { Write-Host ("trigger: " + $_.CimClass.CimClassName) }
    Write-Host ("state: " + $t.State)
}

Write-Host '==== 6. desktop paths ===='
Write-Host ("Admin desktop : " + [Environment]::GetFolderPath('Desktop'))
Write-Host ("Public desktop: " + [Environment]::GetFolderPath('CommonDesktopDirectory'))
Get-ChildItem 'C:\Users\Administrator\Desktop' -ErrorAction SilentlyContinue | Select-Object Name | Format-Table -AutoSize | Out-String | Write-Host
