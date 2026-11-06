# Read-only probe: a19002 mentions in the center-server log (file name located by char code).
[Console]::OutputEncoding = [Text.Encoding]::UTF8
$ErrorActionPreference = 'Stop'

$center = Get-ChildItem 'C:\Server\Logs' -Filter '*.log' | Where-Object { $_.Name.IndexOf([char]0x4E2D) -ge 0 -and $_.Name -notmatch '\.\d+\.log$' } | Select-Object -First 1
if (-not $center) { Write-Output 'NO_CENTER_LOG'; exit }
Write-Output ("CENTER_LOG " + $center.FullName + " " + $center.Length + " bytes")

$hits = Select-String -Path $center.FullName -Pattern 'a19002'
Write-Output ("TOTAL_HITS=" + $hits.Count)
foreach ($h in $hits) {
    if ($h.Line -match '2026-11-06 0[01]:') {
        Write-Output ($h.LineNumber.ToString() + '| ' + $h.Line)
    }
}
