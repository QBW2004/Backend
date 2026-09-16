$names = @('mynamedpipe','MTH_ServerPipe','MTH_RobotPipe')
foreach ($n in $names) {
    $p = '\.\pipe\' + $n
    $exists = Test-Path -LiteralPath $p
    Write-Output ("EXISTS " + $n + " = " + $exists)
}
$all = Get-ChildItem '\.\pipe\' -ErrorAction SilentlyContinue | Where-Object { $_.Name -notmatch '^(InitShutdown|lsass|ntsvcs|scerpc|epmapper|atsvc|eventlog|wkssvc|srvsvc|spoolss|ROUTER|trkwks|SessEnvPublicRpc|TermSrv_API_service|Ctx_WinStation_API_service|LSM_API_service|openssh-ssh-agent|Winsock2)' }
Write-Output ("NON_SYSTEM_PIPES=" + (($all | Measure-Object).Count))
$all | ForEach-Object { Write-Output ("P: " + $_.Name) }
