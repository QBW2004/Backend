param(
    [int]$Cmd,        # 1=Start 2=Stop 3=Status
    [int]$Target,     # 0=All 1=Category 2=Single 3=Robot
    [string]$Name = "",
    [string]$Category = ""
)
$pipe = New-Object System.IO.Pipes.NamedPipeClientStream(".", "MTH_ServerPipe", [System.IO.Pipes.PipeDirection]::InOut)
$pipe.Connect(5000)
$req = New-Object byte[] 104
[System.BitConverter]::GetBytes([int]$Cmd).CopyTo($req, 0)
[System.BitConverter]::GetBytes([int]$Target).CopyTo($req, 4)
$nameBytes = [System.Text.Encoding]::UTF8.GetBytes($Name)
[Array]::Copy($nameBytes, 0, $req, 8, [Math]::Min($nameBytes.Length, 63))
$catBytes = [System.Text.Encoding]::UTF8.GetBytes($Category)
[Array]::Copy($catBytes, 0, $req, 72, [Math]::Min($catBytes.Length, 31))
$pipe.Write($req, 0, 104)
$pipe.Flush()
$resp = New-Object byte[] 4096
$readTask = $pipe.ReadAsync($resp, 0, 4096)
if ($readTask.Wait(5000)) {
    $n = $readTask.Result
    if ($n -gt 0) { [System.Text.Encoding]::UTF8.GetString($resp, 0, $n) }
}
$pipe.Close()
