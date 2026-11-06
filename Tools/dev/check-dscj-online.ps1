$logPath = 'C:\Server\Logs'
$fs = New-Object System.IO.FileStream((Join-Path $logPath ([char]0x70B9+[char]0x77F3+[char]0x6210+[char]0x91D1+[char]0x65E5+[char]0x5FD7+'.log')), [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite)
$sr = New-Object System.IO.StreamReader($fs, [System.Text.Encoding]::UTF8)
$tail = New-Object System.Collections.Generic.List[string]
while (-not $sr.EndOfStream) { $tail.Add($sr.ReadLine()); if ($tail.Count -gt 400) { $tail.RemoveAt(0) } }
$sr.Close(); $fs.Close()
Write-Output ('=== LAST 15 LINES ===')
$tail | Select-Object -Last 15
$recent = $tail | Where-Object { $_ -match 'SIT_DOWN|COM_LOG_OUT|ForceShutdown|OnReadable|LOG_IN|LOG_OUT' } | Select-Object -Last 25
Write-Output ('=== RECENT SESSION EVENTS ===')
$recent
