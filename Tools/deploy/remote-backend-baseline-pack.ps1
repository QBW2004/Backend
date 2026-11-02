$src = 'C:\Backend'
$stage = 'C:\MTH-Deploy\_backend_baseline_20261102'
New-Item -ItemType Directory -Path $stage -Force | Out-Null
$zip = Join-Path $stage 'backend-baseline.zip'
if (Test-Path $zip) { Remove-Item -LiteralPath $zip -Force }
$items = Get-ChildItem -LiteralPath $src -Force | Where-Object { $_.Name -notin @('App_Data','Logs','Upload') }
Compress-Archive -Path ($items.FullName) -DestinationPath $zip -Force
Write-Output $zip
