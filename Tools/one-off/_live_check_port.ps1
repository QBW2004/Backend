$ErrorActionPreference = 'Stop'
Select-String -Path 'C:\Server\servers.ini' -Pattern 'CardMjhl' | ForEach-Object { "$($_.LineNumber): $($_.Line)" }
$p = Get-Process ServerCardMjhl -ErrorAction SilentlyContinue
if ($p) { Get-NetTCPConnection -State Listen | Where-Object { $_.OwningProcess -eq $p.Id } | Select-Object -ExpandProperty LocalPort }
Get-Process ServerCardMjhl,ServerCenterNew,ServerRobot -ErrorAction SilentlyContinue | Group-Object ProcessName | Select-Object Name, Count
