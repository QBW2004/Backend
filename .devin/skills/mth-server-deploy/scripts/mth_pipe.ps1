param(
    [Parameter(Mandatory=$true)][string]$Cmd,      # Ping|Status|Start|Stop
    [string]$Name = '',
    [string]$Category = ''
)
$ErrorActionPreference = 'Stop'
$cmdMap = @{ Ping=0; Start=1; Stop=2; Status=3 }
$tgtMap = @{ All=0; Category=1; Single=2; Robot=3 }

$req = New-Object byte[] 104
[System.BitConverter]::GetBytes([uint32]$cmdMap[$Cmd]).CopyTo($req, 0)
# Robot is its own daemon target (3): -Name Robot/ServerRobot both map to it
# (Single would match nothing: the servers.ini key is "ServerRobot", and a bare
# "Robot" used to silently no-op while still printing "指令已下发").
# -Category alone MUST send target=Category: previously it fell through to All,
# which means "-Cmd Stop -Category Fish" actually ran Stop-All on every service.
if ($Name -match '^(Robot|ServerRobot)$') {
    $target = $tgtMap['Robot']
} elseif ($Name) {
    $target = $tgtMap['Single']
} elseif ($Category) {
    $target = $tgtMap['Category']
} else {
    $target = $tgtMap['All']
}
[System.BitConverter]::GetBytes([uint32]$target).CopyTo($req, 4)
if ($Name) {
    $nb = [System.Text.Encoding]::ASCII.GetBytes($Name)
    [Array]::Copy($nb, 0, $req, 8, [Math]::Min($nb.Length, 63))
}
if ($Category) {
    $cb = [System.Text.Encoding]::ASCII.GetBytes($Category)
    [Array]::Copy($cb, 0, $req, 72, [Math]::Min($cb.Length, 31))
}

$pipe = New-Object System.IO.Pipes.NamedPipeClientStream('.', 'MTH_ServerPipe', [System.IO.Pipes.PipeDirection]::InOut)
$pipe.Connect(5000)
$pipe.ReadMode = [System.IO.Pipes.PipeTransmissionMode]::Message
$pipe.Write($req, 0, $req.Length)
$pipe.Flush()

$buf = New-Object byte[] 65536
$total = 0
do {
    $n = $pipe.Read($buf, $total, $buf.Length - $total)
    $total += $n
} while (-not $pipe.IsMessageComplete -and $n -gt 0)
$pipe.Close()

if ($total -ge 8) {
    $ok = [System.BitConverter]::ToUInt32($buf, 0)
    $cnt = [System.BitConverter]::ToUInt32($buf, 4)
    $msgLen = [Array]::IndexOf($buf, [byte]0, 8)
    if ($msgLen -lt 0) { $msgLen = 1024 } else { $msgLen -= 8 }
    $msg = [System.Text.Encoding]::UTF8.GetString($buf, 8, $msgLen)
    Write-Output "ok=$ok count=$cnt msg=$msg"
    if ($Cmd -eq 'Status') {
        $off = 1032
        $entrySize = 64 + 32 + 512 + 4 + 4 + 4
        for ($i = 0; $i -lt $cnt; $i++) {
            $b = $off + $i * $entrySize
            $name = [System.Text.Encoding]::ASCII.GetString($buf, $b, 64).Trim([char]0)
            $state = [System.BitConverter]::ToUInt32($buf, $b + 608)
            $pid_ = [System.BitConverter]::ToUInt32($buf, $b + 612)
            $re = [System.BitConverter]::ToUInt32($buf, $b + 616)
            Write-Output ("{0,-16} state={1} pid={2} restarts={3}" -f $name, $state, $pid_, $re)
        }
    }
} else {
    Write-Output "short response: $total bytes"
}
