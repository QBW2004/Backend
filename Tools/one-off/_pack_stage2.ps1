$ErrorActionPreference = 'Stop'
$src = 'C:\Server'
$stage = 'C:\MTH-Deploy\template_build\Server'
$zip = 'C:\MTH-Deploy\MTH-Server-Binaries_20261018.zip'
if (Test-Path $stage) { Remove-Item $stage -Recurse -Force }
New-Item -ItemType Directory -Force $stage | Out-Null

$keep = @('*.exe','Poco*.dll','libmysql.dll','*.bin','JackpotState.txt','JackpotSet.txt*','robotError.txt')
$serverDirs = Get-ChildItem $src -Directory | Where-Object { $_.Name -like 'Server*' }
foreach ($d in $serverDirs) {
  $rel = Join-Path $d.FullName 'x64\Release'
  if (-not (Test-Path $rel)) { Write-Output ('SKIP(noRelease) ' + $d.Name); continue }
  $dst = Join-Path $stage ($d.Name + '\x64\Release')
  New-Item -ItemType Directory -Force $dst | Out-Null
  Get-ChildItem $rel -File | Where-Object {
    $n = $_.Name
    if ($n -match '\.bak|\.old|\.log$') { return $false }
    if ($n -like '*.pdb' -and $d.Name -ne 'ServerCenterNew') { return $false }
    foreach ($k in $keep) { if ($n -like $k) { return $true } }
    return $false
  } | ForEach-Object { Copy-Item $_.FullName $dst }
  # Dscj empty placeholder logs are required (crash-loop guard)
  $dscjph = Join-Path $rel 'Dscj'
  if (Test-Path $dscjph) {
    $dstA = Join-Path $dst 'Dscj'
    New-Item -ItemType Directory -Force $dstA | Out-Null
    Get-ChildItem $dscjph -File -Filter 'CardDscj_Alg_Log-*.txt' | ForEach-Object { Copy-Item $_.FullName $dstA }
  }
  $cnt = (Get-ChildItem $dst -File -Recurse).Count
  Write-Output ('PACK ' + $d.Name + ' files=' + $cnt)
}
Copy-Item "$src\servers.ini" "$stage\servers.ini" -Force
Copy-Item "$src\mth_pipe.ps1" "$stage\mth_pipe.ps1" -Force -EA SilentlyContinue
Copy-Item "$src\pipe_cmd.ps1" "$stage\pipe_cmd.ps1" -Force -EA SilentlyContinue
if (Test-Path $zip) { Remove-Item $zip -Force }
Compress-Archive -Path "$stage\*" -DestinationPath $zip -CompressionLevel Optimal
Write-Output ('ZIP=' + $zip + ' size=' + [math]::Round((Get-Item $zip).Length/1MB,1) + 'MB')
