$ErrorActionPreference = 'Stop'
$dir = 'C:\MTH-Deploy\mjhl-default-line-20261103'
New-Item -ItemType Directory -Force -Path $dir | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $dir 'backup') | Out-Null
$bak = Join-Path $dir 'backup'
Copy-Item 'C:\Backend\bin\YYT.Web.dll' (Join-Path $bak 'YYT.Web.dll.bak') -Force
Copy-Item 'C:\Backend\Areas\Game\Views\GameConfig\ConfigEditor.cshtml' (Join-Path $bak 'ConfigEditor.cshtml.bak') -Force
Copy-Item 'C:\Server\ServerCardMjhl\x64\Release\ServerCardMjhl.exe' (Join-Path $bak 'ServerCardMjhl.exe.bak') -Force
Copy-Item 'C:\Server\ServerCardMjhl\x64\Release\ServerCardMjhl.pdb' (Join-Path $bak 'ServerCardMjhl.pdb.bak') -Force
& 'C:\mysql\bin\mysqldump.exe' -uroot -p123456 --single-transaction --hex-blob mth mjhl_agent_config mjhl_agent_config_history parabetroom pararoom roomtableconfig roomtableconfig_bet > (Join-Path $dir 'mth_tables_before.sql')
Get-ChildItem $bak | Select-Object Name, Length | Format-Table -AutoSize
Get-Item (Join-Path $dir 'mth_tables_before.sql') | Select-Object Name, Length
