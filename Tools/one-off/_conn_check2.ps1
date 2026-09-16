$center = (Get-CimInstance Win32_Process -Filter "Name='ServerCenterNew.exe'").ProcessId
Write-Output ("CENTER_PID=" + $center)
$procs = Get-CimInstance Win32_Process -Filter "Name LIKE 'Server%'" | Where-Object { $_.ExecutablePath -like 'C:\Server\*' -and $_.ProcessId -ne $center }
$nameById = @{}
foreach ($p in $procs) { $nameById[[string]$p.ProcessId] = $p.Name }
$conns = Get-NetTCPConnection -State Established -ErrorAction SilentlyContinue | Where-Object { ($_.LocalPort -ge 8000 -and $_.LocalPort -le 8700) -or ($_.RemotePort -ge 8000 -and $_.RemotePort -le 8700) }
Write-Output ("CONN_ROWS_IN_RANGE=" + (($conns | Measure-Object).Count))
$connectedPids = @{}
foreach ($c in $conns) { $o = $c.OwningProcess; if ($o -ne $center -and $nameById.ContainsKey([string]$o)) { $connectedPids[[string]$o] = $true } }
Write-Output ("GAME_PROCS=" + $procs.Count + " CONNECTED_TO_CENTER=" + $connectedPids.Count)
Write-Output "--- not connected ---"
foreach ($p in $procs) { if (-not $connectedPids.ContainsKey([string]$p.ProcessId)) { Write-Output ("  MISSING " + $p.Name + " pid=" + $p.ProcessId) } }

Write-Output "=== 'connect failed' LINE TIMESTAMPS (last 3 per game log) ==="
$logs = Get-ChildItem 'C:\Server\Logs' -Filter '*.log' | Where-Object { $_.Length -lt 5000000 }
foreach ($f in $logs) {
    $fs = [System.IO.File]::Open($f.FullName,'Open','Read','ReadWrite')
    $t = 30000; if ($fs.Length -lt $t) { $t = $fs.Length }
    $fs.Seek($fs.Length - $t,'Begin') | Out-Null
    $b = New-Object byte[] $t
    $fs.Read($b,0,$t) | Out-Null
    $fs.Close()
    $txt = [Text.Encoding]::GetEncoding(936).GetString($b)
    $m = [regex]::Matches($txt, '\[(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2})[^\]]*\]:> \*\*\*\* \[RunServerCenter\] connect failed')
    if ($m.Count -gt 0) {
        $last = $m[$m.Count - 1].Groups[1].Value
        Write-Output ("  " + $f.Name.PadRight(22) + " count=" + $m.Count + " last_failed_at=" + $last)
    }
}
