$mysql = 'C:\mysql\bin\mysql.exe'
$dump = 'C:\mysql\bin\mysqldump.exe'
$dir = 'C:\Users\Administrator\reset_20260916'
$stamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$bk = Join-Path $dir ('mth_GOOD_' + $stamp + '.sql')

Write-Output "=== DUMP (byte-level redirect, no PS re-encoding) ==="
$p = Start-Process -FilePath $dump -ArgumentList '-uroot','-p123456','--single-transaction','--hex-blob','--routines','--triggers','--events','--default-character-set=utf8mb4','mth' -RedirectStandardOutput $bk -RedirectStandardError (Join-Path $dir 'dump.err') -NoNewWindow -Wait -PassThru
Write-Output ("  DUMP_EXIT=" + $p.ExitCode)
$f = Get-Item $bk
Write-Output ("  FILE=" + $f.FullName + " SIZE=" + $f.Length)

Write-Output "=== VERIFY ==="
$b = [System.IO.File]::ReadAllBytes($bk)
Write-Output ("  FIRST8=" + (($b[0..7] | ForEach-Object { '{0:X2}' -f $_ }) -join ' '))
$txt = [Text.Encoding]::UTF8.GetString($b)
Write-Output ("  CREATE_TABLE_COUNT=" + ([regex]::Matches($txt, 'CREATE TABLE')).Count)
$m = [regex]::Match($txt, "INSERT INTO ``games`` VALUES \(5,'([^']*)'")
if ($m.Success) {
    $nm = $m.Groups[1].Value
    $hex = ''
    foreach ($c in $nm.ToCharArray()) { $hex += ('{0:X2}{1:X2}{2:X2}' -f [int]($c -band 0xFF), [int](($c -shr 8) -band 0xFF), 0) }
    $bytes = [Text.Encoding]::UTF8.GetBytes($nm)
    $hx = ($bytes | ForEach-Object { '{0:X2}' -f $_ }) -join ''
    Write-Output ("  GAME5_NAME_UTF8_HEX=" + $hx + "  (expect E781ABE587A4E587B0 = 火凤凰)")
}
foreach ($t in @('games','cardpayoutprofile','gameconfiglaba','roomtableconfig','users','admin')) {
    $n = & $mysql -uroot -p123456 -N -e ("SELECT COUNT(*) FROM mth.``" + $t + "``") 2>$null
    Write-Output ("  LIVE " + $t.PadRight(20) + " = " + $n)
}
Write-Output "=== KEEP ==="
Write-Output ("  GOOD_BACKUP=" + $bk)
