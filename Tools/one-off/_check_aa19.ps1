$cl = (Get-ChildItem 'C:\Server\Logs' -Filter '*.log' | Where-Object { $_.Length -gt 5000000 } | Sort-Object Length -Descending | Select-Object -First 1)
$fs = [System.IO.File]::Open($cl.FullName,'Open','Read','ReadWrite')
$t = 131072; if ($fs.Length -lt $t) { $t = $fs.Length }
$fs.Seek($fs.Length-$t,'Begin') | Out-Null
$b = New-Object byte[] $t
$fs.Read($b,0,$t) | Out-Null
$fs.Close()
$txt = [Text.Encoding]::GetEncoding(936).GetString($b)
$lines = $txt -split "`n"
$start = -1
for ($i = 0; $i -lt $lines.Count; $i++) { if ($lines[$i] -match 'Rec:UL') { $start = $i; break } }
Write-Output ("FOUND_REC_UL_AT_LINE=" + $start)
if ($start -ge 0) {
    $sel = $lines[([Math]::Max(0,$start-2))..([Math]::Min($lines.Count-1, $start+40))]
    $sb = ($sel -join "`n")
    Write-Output ([Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($sb)))
}
