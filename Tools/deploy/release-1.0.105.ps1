param([switch]$Apply, [switch]$Rollback, [switch]$AllowDisconnect)
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
[Console]::OutputEncoding = [Text.Encoding]::UTF8
$stage = 'C:\MTH-Deploy\release-1.0.105-20261105'
$manifest = Get-Content -LiteralPath "$stage\server-manifest.json" -Raw | ConvertFrom-Json
$webManifest = Get-Content -LiteralPath "$stage\web-manifest.json" -Raw | ConvertFrom-Json
$expectedPorts = @(9000,9102,9103,9200,9204,9206,9208,9209,9212,9300,9305,9400,9402,9403,9404)
$backup = "$stage\backup"
$source = "$stage\web\TTY.Web"
$stateFile = "$stage\result.json"
$startRobot = $false
function Log($message) { Write-Output ((Get-Date -Format 'yyyy-MM-dd HH:mm:ss')+' '+$message) }
function Hash($path) { (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash }
function Processes { @(Get-CimInstance Win32_Process | Where-Object { $_.Name -like 'Server*.exe' -and $_.ExecutablePath -like 'C:\Server\*' }) }
function Pipe([uint32]$command,[uint32]$target) {
    $client = New-Object IO.Pipes.NamedPipeClientStream('.','MTH_ServerPipe',[IO.Pipes.PipeDirection]::InOut,[IO.Pipes.PipeOptions]::Asynchronous)
    try {
        $client.Connect(8000)
        $request = New-Object byte[] 104
        [BitConverter]::GetBytes($command).CopyTo($request,0)
        [BitConverter]::GetBytes($target).CopyTo($request,4)
        $client.Write($request,0,104); $client.Flush()
        $reply = New-Object byte[] 1032
        $total=0
        while($total -lt $reply.Length) {
            $pending=$client.BeginRead($reply,$total,$reply.Length-$total,$null,$null)
            if(-not $pending.AsyncWaitHandle.WaitOne(8000)){throw 'Daemon reply timeout'}
            $count=$client.EndRead($pending)
            if($count -le 0){throw 'Incomplete daemon reply'}
            $total+=$count
        }
        if([BitConverter]::ToUInt32($reply,0) -ne 1){throw 'Daemon command rejected'}
        Log "daemon command=$command target=$target accepted"
    } finally { $client.Dispose() }
}
function Stop-Servers {
    if(@(Processes).Count -eq 0){return}
    Pipe 2 3
    Start-Sleep -Seconds 2
    Pipe 2 0
    $deadline=(Get-Date).AddSeconds(45)
    while(@(Processes).Count -gt 0 -and (Get-Date) -lt $deadline){Start-Sleep -Milliseconds 500}
    if(@(Processes).Count -ne 0){throw 'Servers did not stop'}
}
function Start-Servers {
    if(@(Processes).Count -ne 0){throw 'Start requires zero existing server processes'}
    Pipe 1 0
    $deadline=(Get-Date).AddSeconds(50)
    do {
        $ports=@(Get-NetTCPConnection -State Listen | Select-Object -ExpandProperty LocalPort -Unique)
        $missing=@($expectedPorts | Where-Object {$_ -notin $ports})
        if($missing.Count -eq 0){break}
        Start-Sleep -Seconds 2
    } while((Get-Date) -lt $deadline)
    if($missing.Count -gt 0){throw ('Missing ports: '+($missing -join ','))}
    if($startRobot -and -not (Get-Process ServerRobot -ErrorAction SilentlyContinue)){Pipe 1 3}
    $expectedCount=if($startRobot){16}else{15}
    $deadline=(Get-Date).AddSeconds(20)
    do {
        $p=@(Processes)
        if($p.Count -eq $expectedCount -and @($p | Group-Object Name | Where-Object Count -ne 1).Count -eq 0){return}
        Start-Sleep -Seconds 1
    } while((Get-Date) -lt $deadline)
    throw ('Expected unique server processes: '+$expectedCount)
}
function Copy-Tree($from,$to) {
    & robocopy $from $to /E /NFL /NDL /NP /NJH /NJS /R:2 /W:1 /XD Logs App_Data Upload obj .vs | Out-Null
    if($LASTEXITCODE -ge 8){throw ('robocopy failed: '+$LASTEXITCODE)}
}
function Recycle-Web {
    & C:\Windows\System32\inetsrv\appcmd.exe recycle apppool /apppool.name:DefaultAppPool | Out-Null
    if($LASTEXITCODE -ne 0){throw 'Application pool recycle failed'}
}
function Check-Web {
    foreach($url in @('http://127.0.0.1/','http://127.0.0.1/Api/Games','http://127.0.0.1:8081/')) {
        $ok=$false
        for($i=0;$i -lt 3;$i++) {
            try { $r=Invoke-WebRequest $url -UseBasicParsing -TimeoutSec 30; if($r.StatusCode -eq 200){$ok=$true;break} } catch { if($i -eq 2){throw};Start-Sleep -Seconds 2 }
        }
        if(-not $ok){throw ('HTTP probe failed: '+$url)}
        Log ('HTTP 200 '+$url)
    }
}
function Restore {
    Stop-Servers
    foreach($item in $manifest) {
        foreach($ext in @('exe','pdb')) {
            Copy-Item -LiteralPath "$backup\server\$($item.Name).$ext" -Destination "C:\Server\$($item.Name)\x64\Release\$($item.Name).$ext" -Force
        }
    }
    Copy-Tree "$backup\web" 'C:\Backend'
    if(Test-Path -LiteralPath 'C:\Backend\app_offline.htm'){Remove-Item -LiteralPath 'C:\Backend\app_offline.htm'}
    Recycle-Web
    Start-Servers
    Check-Web
    foreach($item in $manifest){if((Hash "C:\Server\$($item.Name)\x64\Release\$($item.Name).exe") -ne $item.OldExeHash){throw 'Rollback hash mismatch'}}
    Log 'ROLLBACK_COMPLETE'
}
if($Rollback) { if(-not (Test-Path -LiteralPath "$backup\ready.json")){throw 'No completed backup'}; $startRobot=(Get-Content "$backup\ready.json" -Raw | ConvertFrom-Json).robotWasRunning; Restore; exit 0 }
if(Test-Path -LiteralPath $stateFile){throw 'This release already ran; inspect result.json before retrying'}
if(Test-Path -LiteralPath 'C:\Backend\app_offline.htm'){throw 'Existing maintenance file'}
foreach($item in $manifest) {
    $path="C:\Server\$($item.Name)\x64\Release\$($item.Name).exe"
    if((Hash $path) -ne $item.OldExeHash){throw ('Live baseline changed: '+$item.Name)}
    if((Hash "$stage\server\$($item.Name).exe") -ne $item.NewExeHash){throw 'Staged exe hash mismatch'}
    if((Hash "$stage\server\$($item.Name).pdb") -ne $item.NewPdbHash){throw 'Staged pdb hash mismatch'}
}
foreach($item in $webManifest){if((Hash (Join-Path $source $item.File)) -ne $item.Hash){throw ('Staged web hash mismatch: '+$item.File)}}
$cfg=[xml](Get-Content -LiteralPath C:\Backend\Web.config -Raw)
$version=($cfg.configuration.appSettings.add | Where-Object key -eq 'WebVer').value
if($version -ne '1.0.104'){throw ('Unexpected WebVer: '+$version)}
$cs=($cfg.configuration.connectionStrings.add | Where-Object name -eq 'DbConnString').connectionString
if($cs -notmatch '(?i)(?:pwd|password)=([^;]*)'){throw 'Database credentials unavailable'}
$env:MYSQL_PWD=$Matches[1]
$online=& C:\mysql\bin\mysql.exe -uroot -N -B mth -e 'SELECT COUNT(*) FROM users WHERE INHALL=1;'
if($LASTEXITCODE -ne 0){throw 'Online player query failed'}
$initial=@(Processes)
Log ('PREFLIGHT webver='+$version+' online='+$online+' server_processes='+$initial.Count+' files='+$webManifest.Count)
if([int]$online -ne 0 -and -not $AllowDisconnect){throw 'Players online; deployment not started'}
if($initial.Count -notin @(0,15,16)){throw 'Unexpected partial running server state'}
$startRobot=@($initial | Where-Object Name -eq 'ServerRobot.exe').Count -eq 1
if(-not $Apply){Remove-Item Env:\MYSQL_PWD;exit 0}
New-Item -ItemType Directory -Path "$backup\server","$backup\web" -Force | Out-Null
& C:\mysql\bin\mysqldump.exe -uroot --single-transaction --hex-blob --routines --triggers --events --default-character-set=utf8mb4 mth "--result-file=$backup\database.sql"
if($LASTEXITCODE -ne 0 -or (Get-Item "$backup\database.sql").Length -lt 10000){throw 'Database backup failed'}
foreach($item in $manifest){foreach($ext in @('exe','pdb')){Copy-Item -LiteralPath "C:\Server\$($item.Name)\x64\Release\$($item.Name).$ext" -Destination "$backup\server\$($item.Name).$ext"}}
Copy-Tree 'C:\Backend' "$backup\web"
foreach($item in $manifest){if((Hash "$backup\server\$($item.Name).exe") -ne $item.OldExeHash){throw 'Backup hash mismatch'}}
@{ initial=$initial;robotWasRunning=$startRobot;online=[int]$online;webver=$version;timestamp=(Get-Date -Format o) } | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath "$backup\ready.json" -Encoding UTF8
Log ('BACKUP_READY db_bytes='+(Get-Item "$backup\database.sql").Length)
$changed=$false
try {
    $changed=$true
    Stop-Servers
    foreach($item in $manifest){foreach($ext in @('exe','pdb')){Copy-Item -LiteralPath "$stage\server\$($item.Name).$ext" -Destination "C:\Server\$($item.Name)\x64\Release\$($item.Name).$ext" -Force};Log ('UPDATED '+$item.Name)}
    Set-Content -LiteralPath 'C:\Backend\app_offline.htm' -Value 'Maintenance in progress' -Encoding ASCII
    # Preserve all current production settings; only change the cache version.
    $configText=[IO.File]::ReadAllText('C:\Backend\Web.config')
    $updated=[regex]::Replace($configText,'(<add\s+key="WebVer"\s+value=")1\.0\.104("\s*/>)','${1}1.0.105${2}')
    if($updated -eq $configText){throw 'Could not update WebVer'}
    [IO.File]::WriteAllText("$source\Web.config",$updated,(New-Object Text.UTF8Encoding($true)))
    Copy-Tree $source 'C:\Backend'
    foreach($item in $webManifest){if((Hash (Join-Path 'C:\Backend' $item.File)) -ne $item.Hash){throw ('Live web hash mismatch: '+$item.File)}}
    Remove-Item -LiteralPath 'C:\Backend\app_offline.htm'
    Recycle-Web
    Start-Servers
    Check-Web
    foreach($item in $manifest){if((Hash "C:\Server\$($item.Name)\x64\Release\$($item.Name).exe") -ne $item.NewExeHash){throw 'Live exe hash mismatch'}}
    $count=& C:\mysql\bin\mysql.exe -uroot -N -B mth -e 'SELECT COUNT(*) FROM games WHERE Enable=1;'
    if($LASTEXITCODE -ne 0 -or [int]$count -ne 14){throw 'Enabled games check failed'}
    @{status='DEPLOYED';timestamp=(Get-Date -Format o);backup=$backup;initialServerCount=$initial.Count;initialOnline=[int]$online;robotWasRunning=$startRobot;processes=(Processes | Select-Object Name,ProcessId,ExecutablePath);webVersion='1.0.105';webFiles=$webManifest.Count+1;servers=$manifest.Count;enabledGames=[int]$count} | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $stateFile -Encoding UTF8
    Log 'DEPLOYED 1.0.105'
} catch {
    $failure=$_.Exception.Message
    Log ('FAILED '+$failure)
    $rollbackStatus='not_needed'
    if($changed){try {Restore;$rollbackStatus='complete'}catch{$rollbackStatus='failed: '+$_.Exception.Message;Log $rollbackStatus}}
    @{status='FAILED';error=$failure;rollback=$rollbackStatus;timestamp=(Get-Date -Format o)} | ConvertTo-Json | Set-Content -LiteralPath $stateFile -Encoding UTF8
    throw
} finally {Remove-Item Env:\MYSQL_PWD -ErrorAction SilentlyContinue}
