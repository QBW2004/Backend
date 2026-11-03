$ErrorActionPreference = 'Stop'
$client = New-Object System.IO.Pipes.NamedPipeClientStream('.', 'mynamedpipe', [System.IO.Pipes.PipeDirection]::InOut)
$client.Connect(8000)
$req = [byte[]](0x50, 0x43, 0x00, 0x36)
$client.Write($req, 0, 4)
$client.Flush()
$client.Close()
"pc sent gameId=54"
Start-Sleep -Seconds 3
Get-Content 'C:\Server\Logs\麻将胡了日志.log' -Tail 14
