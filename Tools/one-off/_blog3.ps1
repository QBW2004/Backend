$files = @('C:\Backend\Logs\yyt_20260916.log','C:\Backend\Logs\yyt_20260916.1.log')
foreach ($f in $files) {
    if (-not (Test-Path $f)) { continue }
    Write-Output ("### " + $f)
    $hits = Select-String -Path $f -Encoding UTF8 -Pattern 'NamedPipe|Timeout|pipe|Pipe|拒绝|denied|Connect' -ErrorAction SilentlyContinue
    Write-Output ("  hits=" + $hits.Count)
    foreach ($h in ($hits | Select-Object -Last 12)) {
        $a = ''; foreach ($c in $h.Line.ToCharArray()) { if ([int][char]$c -lt 128) { $a += $c } }
        Write-Output ("  |" + ($a -replace '\s+',' ').Trim())
    }
}
