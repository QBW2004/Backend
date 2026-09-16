$bk = (Get-ChildItem 'C:\Users\Administrator\reset_20260916\mth_GOOD_*.sql' | Sort-Object LastWriteTime -Descending | Select-Object -First 1).FullName
Write-Output ("FILE=" + $bk)
$b = [System.IO.File]::ReadAllBytes($bk)
$found = 0
for ($i = 0; $i -lt $b.Length - 2; $i++) {
    if ($b[$i] -eq 0xE7 -and $b[$i+1] -eq 0x81 -and $b[$i+2] -eq 0xAB) { $found++ ; if ($found -ge 3) { break } }
}
Write-Output ("UTF8_火(E781AB)_OCCURRENCES=" + $found)
$found2 = 0
for ($i = 0; $i -lt $b.Length - 2; $i++) {
    if ($b[$i] -eq 0xE6 -and $b[$i+1] -eq 0xB0 -and $b[$i+2] -eq 0xB4) { $found2++ ; if ($found2 -ge 3) { break } }
}
Write-Output ("UTF8_水(E6B0B4)_OCCURRENCES=" + $found2)
Write-Output ("HAS_NUL_BYTES=" + (($b | Select-Object -First 2000) -contains 0))
