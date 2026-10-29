$ErrorActionPreference = 'Stop'
$target = 'C:\Server\ServerManager\x64\Release\Admin.exe'
$lnkPath = 'C:\Users\Administrator\Desktop\游戏服管理控制台(Admin).lnk'

$ws = New-Object -ComObject WScript.Shell
$lnk = $ws.CreateShortcut($lnkPath)
$lnk.TargetPath = $target
$lnk.WorkingDirectory = Split-Path $target
$lnk.Description = 'MTH game server management console (start/stop/status via MTH_ServerPipe)'
$lnk.Save()

Get-Item $lnkPath | Select-Object FullName, Length | Format-List | Out-String | Write-Host
Write-Host 'shortcut created'
