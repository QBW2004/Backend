# Tail the newest IIS log entries whose URI matches a pattern, printing
# time / method / uri / status / duration. ASCII only on purpose.
param(
    [string]$LogDir = 'C:\inetpub\logs\LogFiles\W3SVC1',
    [string]$Filter = 'messager',
    [int]$Tail = 25
)
$file = Get-ChildItem (Join-Path $LogDir '*.log') | Sort-Object LastWriteTime -Descending | Select-Object -First 1
Write-Output ("file=" + $file.Name + " lastwrite=" + $file.LastWriteTime)
Get-Content $file.FullName |
    Where-Object { $_ -notmatch '^#' -and $_ -match $Filter } |
    Select-Object -Last $Tail |
    ForEach-Object {
        $p = $_ -split ' '
        if ($p.Count -ge 15) {
            Write-Output ($p[0] + ' ' + $p[1] + '  ' + $p[3] + ' ' + $p[4] + '  status=' + $p[11] + '  dur=' + $p[14] + 'ms')
        } else {
            Write-Output $_
        }
    }
Write-Output "(end)"
