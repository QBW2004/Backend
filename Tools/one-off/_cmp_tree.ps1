$ErrorActionPreference = 'SilentlyContinue'
$root = 'C:\Backend'
$skip = '\\(Logs|App_Data|Upload|obj|\.vs)\\'
$files = Get-ChildItem $root -Recurse -File -Force | Where-Object { $_.FullName -notmatch $skip }
Write-Output ('COUNT=' + $files.Count)
$sum = 0
foreach ($f in $files) {
    $rel = $f.FullName.Substring($root.Length + 1)
    $h = (Get-FileHash -Algorithm MD5 -Path $f.FullName).Hash.ToLower()
    $sum += $f.Length
    Write-Output ($h + '  ' + $rel)
}
Write-Output ('SIZE_MB=' + [math]::Round($sum / 1MB, 1))
