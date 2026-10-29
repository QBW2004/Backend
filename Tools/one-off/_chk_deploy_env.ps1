Get-Item C:\MTH-Deploy\TTY.Web_1.0.59.zip | Select-Object -ExpandProperty Length
foreach ($p in @('C:\Users\Administrator\Desktop\deploy\deploy.ps1','C:\Users\Administrator\Desktop\deploy.ps1','C:\deploy\deploy.ps1','C:\MTH-Deploy\deploy.ps1')) { Write-Output ($p + ' = ' + (Test-Path $p)) }
