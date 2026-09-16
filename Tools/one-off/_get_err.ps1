$f = (Get-ChildItem 'C:\Backend\Logs\*.log' | Sort-Object LastWriteTime -Descending | Select-Object -First 1).FullName
Write-Output ("FILE=" + $f)
$lines = Get-Content $f -Encoding Default
$idx = @()
for ($i=0; $i -lt $lines.Count; $i++) { if ($lines[$i] -match 'FillCurrentPlayInfo') { $idx += $i } }
Write-Output ("HITS=" + $idx.Count)
if ($idx.Count -gt 0) {
  $start = [Math]::Max(0, $idx[0] - 25)
  $end = [Math]::Min($lines.Count - 1, $idx[0] + 20)
  for ($k = $start; $k -le $end; $k++) { Write-Output ($lines[$k]) }
}
