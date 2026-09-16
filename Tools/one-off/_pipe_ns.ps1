$all = Get-ChildItem '\.\pipe\' -ErrorAction SilentlyContinue
Write-Output ("PIPE_TOTAL=" + (($all | Measure-Object).Count))
foreach ($p in $all) { if ($p.Name -match 'myna|MTH') { Write-Output ("FOUND: " + $p.Name) } }
$c = Get-CimInstance Win32_Process -Filter "Name='ServerCenterNew.exe'"
Write-Output ("CENTER_SESSION=" + $c.SessionId + " PID=" + $c.ProcessId + " CREATED=" + $c.CreationDate)
$d = Get-CimInstance Win32_Process -Filter "Name='Daemon.exe'"
if ($d) { Write-Output ("DAEMON PID=" + $d.ProcessId + " SESSION=" + $d.SessionId) } else { Write-Output "DAEMON NOT RUNNING" }
Write-Output "=== child console hosts ==="
Get-CimInstance Win32_Process -Filter "Name='conhost.exe'" | Select-Object ProcessId,ParentProcessId,CommandLine | Format-Table -AutoSize | Out-String -Width 200 | Write-Output
