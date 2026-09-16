Write-Output ("NOW=" + (Get-Date -Format 'HH:mm:ss'))
Write-Output "=== CENTER PROCESS ==="
Get-CimInstance Win32_Process -Filter "Name='ServerCenterNew.exe'" | Select-Object ProcessId,CreationDate,ExecutablePath | Format-List | Out-String | Write-Output
Write-Output "=== PIPES ==="
foreach ($n in @('mynamedpipe','MTH_ServerPipe')) { Write-Output ("  " + $n + "=" + (Test-Path -LiteralPath ('\\.\pipe\' + $n))) }
Write-Output "=== ALL NON-SYSTEM PIPES ==="
Get-ChildItem '\\.\pipe\' -ErrorAction SilentlyContinue | Where-Object { $_.Name -notmatch '^(InitShutdown|lsass|ntsvcs|scerpc|epmapper|atsvc|eventlog|wkssvc|srvsvc|spoolss|ROUTER|trkwks|SessEnvPublicRpc|TermSrv_API_service|Ctx_WinStation_API_service|LSM_API_service|openssh-ssh-agent|Winsock2)' } | ForEach-Object { Write-Output ("  P: " + $_.Name) }
Write-Output "=== DAEMON LOG (tail, ascii) ==="
$dl = 'C:\Server\ServerManager\x64\Release\MTH_Daemon.log'
if (Test-Path $dl) {
    $lines = Get-Content $dl -Encoding Default -ErrorAction SilentlyContinue
    foreach ($l in ($lines | Select-Object -Last 25)) {
        $a = ''; foreach ($c in $l.ToCharArray()) { if ([int][char]$c -lt 128) { $a += $c } }
        Write-Output ("  |" + ($a -replace '\s+',' '))
    }
}
Write-Output "=== CENTER LOG: last WEB lines + tail ==="
$cl = (Get-ChildItem 'C:\Server\Logs' -Filter '*.log' | Where-Object { $_.Length -gt 5000000 } | Sort-Object Length -Descending | Select-Object -First 1)
$fs = [System.IO.File]::Open($cl.FullName,'Open','Read','ReadWrite')
$t = 262144; if ($fs.Length -lt $t) { $t = $fs.Length }
$fs.Seek($fs.Length-$t,'Begin') | Out-Null
$b = New-Object byte[] $t
$fs.Read($b,0,$t) | Out-Null
$fs.Close()
$txt = [Text.Encoding]::GetEncoding(936).GetString($b)
$webLines = ([regex]::Matches($txt, '\[[^\]]*\]:> \*\*\*\* [^\r\n]*WEB[^\r\n]*')) | ForEach-Object { $_.Value }
Write-Output ("  WEB_LINE_COUNT_IN_LAST256KB=" + $webLines.Count)
foreach ($l in ($webLines | Select-Object -Last 8)) {
    $a = ''; foreach ($c in $l.ToCharArray()) { if ([int][char]$c -lt 128) { $a += $c } }
    Write-Output ("  |" + ($a -replace '\s+',' '))
}
Write-Output "  --- center log tail 8 (ascii) ---"
$ll = ($txt -split "`n") | Select-Object -Last 8
foreach ($l in $ll) {
    $a = ''; foreach ($c in $l.ToCharArray()) { if ([int][char]$c -lt 128) { $a += $c } }
    if ($a.Trim().Length -gt 0) { Write-Output ("  |" + ($a -replace '\s+',' ')) }
}
