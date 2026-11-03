$ErrorActionPreference = 'Stop'
$dir = 'C:\MTH-Deploy\mjhl-default-line-20261103'
$pipe = 'MTH_ServerPipe'
function Send-Pipe([uint32]$cmd, [uint32]$target, [string]$name) {
    $client = New-Object System.IO.Pipes.NamedPipeClientStream('.', $pipe, [System.IO.Pipes.PipeDirection]::InOut)
    $client.Connect(8000)
    $req = New-Object byte[] 104
    [BitConverter]::GetBytes($cmd).CopyTo($req, 0)
    [BitConverter]::GetBytes($target).CopyTo($req, 4)
    if ($name.Length -gt 0) {
        $nb = [Text.Encoding]::ASCII.GetBytes($name)
        [Array]::Copy($nb, 0, $req, 8, [Math]::Min($nb.Length, 63))
    }
    $client.Write($req, 0, 104)
    $client.Flush()
    $resp = New-Object byte[] 65536
    $total = 0
    while ($total -lt 1032) {
        $r = $client.Read($resp, $total, $resp.Length - $total)
        if ($r -le 0) { break }
        $total += $r
    }
    $client.Close()
    $msg = [Text.Encoding]::UTF8.GetString($resp, 8, 1024).Trim([char]0)
    return "ok=$([BitConverter]::ToUInt32($resp,0)) msg=$msg"
}
"before=" + (Get-Process ServerCardMjhl -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Id)
"stop: " + (Send-Pipe 2 2 'CardMjhl')
$deadline = (Get-Date).AddSeconds(30)
while ((Get-Process ServerCardMjhl -ErrorAction SilentlyContinue) -and (Get-Date) -lt $deadline) { Start-Sleep -Milliseconds 500 }
"stopped=" + (-not (Get-Process ServerCardMjhl -ErrorAction SilentlyContinue))
Copy-Item (Join-Path $dir 'ServerCardMjhl.exe') 'C:\Server\ServerCardMjhl\x64\Release\ServerCardMjhl.exe' -Force
Copy-Item (Join-Path $dir 'ServerCardMjhl.pdb') 'C:\Server\ServerCardMjhl\x64\Release\ServerCardMjhl.pdb' -Force
"exe=" + (Get-Item 'C:\Server\ServerCardMjhl\x64\Release\ServerCardMjhl.exe').Length
"start: " + (Send-Pipe 1 2 'CardMjhl')
Start-Sleep -Seconds 6
Get-Process ServerCardMjhl -ErrorAction SilentlyContinue | Select-Object Id, ProcessName, StartTime
Get-Content 'C:\Server\Logs\麻将胡了日志.log' -Tail 8
