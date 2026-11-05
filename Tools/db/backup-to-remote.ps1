param([Parameter(Mandatory = $true)][string]$Config)

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
Set-StrictMode -Version 2

function Assert-Value($Value, [string]$Pattern, [string]$Name) {
    if ([string]$Value -notmatch $Pattern) { throw "Invalid $Name in backup configuration." }
}

function Invoke-Transfer([string]$Executable, [string[]]$Arguments) {
    # All arguments are paths or public connection settings. Credentials use the key file.
    $process = New-Object Diagnostics.Process
    $process.StartInfo.FileName = $Executable
    $process.StartInfo.Arguments = (($Arguments | ForEach-Object {
        '"' + ($_ -replace '(\\*)"', '$1$1\"' -replace '(\\+)$', '$1$1') + '"'
    }) -join ' ')
    $process.StartInfo.UseShellExecute = $false
    $process.StartInfo.CreateNoWindow = $true
    $process.StartInfo.RedirectStandardOutput = $true
    $process.StartInfo.RedirectStandardError = $true
    try {
        [void]$process.Start()
        $stdout = $process.StandardOutput.ReadToEndAsync()
        $stderr = $process.StandardError.ReadToEndAsync()
        if (-not $process.WaitForExit(600000)) {
            $process.Kill()
            throw 'SSH transfer/verification exceeded 10 minutes.'
        }
        $output = $stdout.GetAwaiter().GetResult()
        $diagnostic = $stderr.GetAwaiter().GetResult()
        if ($process.ExitCode -ne 0) { throw "SSH transfer/verification failed (exit $($process.ExitCode)): $diagnostic" }
        return $output
    }
    finally { $process.Dispose() }
}

function Remove-ExpiredLocalBackups([string]$Directory, [datetime]$Cutoff) {
    $root = [IO.Path]::GetFullPath($Directory).TrimEnd('\') + '\'
    foreach ($file in Get-ChildItem -LiteralPath $Directory -File) {
        if ($file.Name -notmatch '^(?:mth_(?<date>\d{8})_\d{6}\.sql(?:\.sha256)?|backup_(?<date>\d{8})_\d{6}\.log|result_(?<date>\d{8})_\d{6}\.json)$') { continue }
        if ($file.Attributes -band [IO.FileAttributes]::ReparsePoint) { continue }
        $date = [datetime]::MinValue
        if (-not [datetime]::TryParseExact($Matches['date'], 'yyyyMMdd', [Globalization.CultureInfo]::InvariantCulture,
                [Globalization.DateTimeStyles]::None, [ref]$date)) { continue }
        if ($date -ge $Cutoff) { continue }
        $resolved = [IO.Path]::GetFullPath($file.FullName)
        if (-not $resolved.StartsWith($root, [StringComparison]::OrdinalIgnoreCase)) { throw 'Unsafe local cleanup path.' }
        Remove-Item -LiteralPath $resolved -Force
    }
}

$timer = [Diagnostics.Stopwatch]::StartNew()
$lock = $null
$logPath = $null
$cfg = $null
$status = [ordered]@{ state = 'running'; startedUtc = [datetime]::UtcNow.ToString('o') }
try {
    $cfg = Get-Content -LiteralPath $Config -Raw -Encoding UTF8 | ConvertFrom-Json
    $backupDir = [IO.Path]::GetFullPath([string]$cfg.LocalDirectory)
    if ($backupDir -eq [IO.Path]::GetPathRoot($backupDir)) { throw 'Backup directory must not be a drive root.' }
    [void][IO.Directory]::CreateDirectory($backupDir)
    if ((Get-Item -LiteralPath $backupDir).Attributes -band [IO.FileAttributes]::ReparsePoint) { throw 'Backup directory must not be a link.' }
    $lock = [IO.File]::Open((Join-Path $backupDir 'backup.lock'), [IO.FileMode]::OpenOrCreate, [IO.FileAccess]::ReadWrite, [IO.FileShare]::None)
    $now = [TimeZoneInfo]::ConvertTimeBySystemTimeZoneId([datetime]::UtcNow, 'China Standard Time')
    $stamp = $now.ToString('yyyyMMdd_HHmmss')
    $fileName = "mth_$stamp.sql"
    $sqlPath = Join-Path $backupDir $fileName
    $logPath = Join-Path $backupDir "backup_$stamp.log"
    Start-Transcript -LiteralPath $logPath | Out-Null

    Assert-Value $cfg.RemoteHost '^[A-Za-z0-9][A-Za-z0-9.-]*$' 'remote host'
    Assert-Value $cfg.RemoteUser '^[a-z_][a-z0-9_-]*$' 'remote user'
    Assert-Value $cfg.RemoteDirectory '^/[A-Za-z0-9_/-]+$' 'remote directory'
    Assert-Value $cfg.RemoteReceiver '^/[A-Za-z0-9_./-]+$' 'remote receiver'
    if ($cfg.RemoteDirectory -match '/\.\.?(/|$)' -or $cfg.RemoteReceiver -match '/\.\.?(/|$)') { throw 'Relative remote paths are forbidden.' }
    if ([int]$cfg.RemotePort -lt 1 -or [int]$cfg.RemotePort -gt 65535) { throw 'Invalid SSH port.' }
    if ([int]$cfg.KeepDays -lt 1 -or [int]$cfg.KeepDays -gt 365) { throw 'Invalid retention period.' }
    foreach ($path in @($cfg.WebConfig, $cfg.MySqlAssembly, $cfg.MySqlDumpExe, $cfg.SshExe, $cfg.ScpExe, $cfg.IdentityFile, $cfg.KnownHostsFile)) {
        if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw 'A required backup dependency is missing.' }
    }
    [xml]$webConfig = Get-Content -LiteralPath $cfg.WebConfig -Raw -Encoding UTF8
    [void][Reflection.Assembly]::LoadFrom($cfg.MySqlAssembly)
    $node = @($webConfig.configuration.connectionStrings.add | Where-Object { $_.name -eq 'DbConnString' })
    if ($node.Count -ne 1) { throw 'Exactly one DbConnString is required.' }
    $db = New-Object MySql.Data.MySqlClient.MySqlConnectionStringBuilder([string]$node[0].connectionString)
    if ($db.Database -ne 'mth' -or $db.Server -notin @('localhost', '127.0.0.1', '::1', '.')) {
        throw 'This scheduled backup requires the local mth database.'
    }
    # Never print the connection string or put the database password on a process command line.
    & (Join-Path $PSScriptRoot 'export-db.ps1') -DbName $db.Database -Server $db.Server -Port $db.Port -User $db.UserID `
        -Password $db.Password -MySqlDumpExe $cfg.MySqlDumpExe -Output $sqlPath
    $hash = (Get-FileHash -LiteralPath $sqlPath -Algorithm SHA256).Hash.ToLowerInvariant()
    $status['file'] = $fileName
    $status['sha256'] = $hash
    $status['bytes'] = (Get-Item -LiteralPath $sqlPath).Length
    [IO.File]::WriteAllText("$sqlPath.sha256", "$hash  $fileName`n", [Text.Encoding]::ASCII)

    $common = @('-i', [string]$cfg.IdentityFile, '-o', "UserKnownHostsFile=$($cfg.KnownHostsFile)",
        '-o', 'StrictHostKeyChecking=yes', '-o', 'BatchMode=yes', '-o', 'IdentitiesOnly=yes',
        '-o', 'ConnectTimeout=20', '-o', 'ServerAliveInterval=15', '-o', 'ServerAliveCountMax=3')
    $destination = "$($cfg.RemoteUser)@$($cfg.RemoteHost)"
    $remoteFile = "$($cfg.RemoteDirectory)/$fileName.partial"
    $command = "python3 $($cfg.RemoteReceiver) --directory $($cfg.RemoteDirectory) --filename $fileName --sha256 $hash --keep-days $($cfg.KeepDays)"
    $remoteResult = $null
    for ($attempt = 1; $attempt -le 3; $attempt++) {
        try {
            Invoke-Transfer $cfg.ScpExe ($common + @('-P', [string]$cfg.RemotePort, $sqlPath, "${destination}:$remoteFile")) | Out-Null
            $result = Invoke-Transfer $cfg.SshExe ($common + @('-p', [string]$cfg.RemotePort, $destination, $command))
            $remoteResult = $result | ConvertFrom-Json
            if ($remoteResult.sha256 -ne $hash -or $remoteResult.file -ne $fileName -or [long]$remoteResult.size -ne $status.bytes) {
                throw 'Remote verification response did not match the exported backup.'
            }
            break
        }
        catch {
            if ($attempt -eq 3) { throw }
            Write-Output "Transfer attempt $attempt failed; retrying in 10 seconds."
            Start-Sleep -Seconds 10
        }
    }
    # Retention is applied only after a complete, hash-verified copy exists on the other server.
    Remove-ExpiredLocalBackups $backupDir $now.Date.AddDays(1 - [int]$cfg.KeepDays)
    $status['state'] = 'success'
    $status['remoteHost'] = $cfg.RemoteHost
    $status['remoteDirectory'] = $cfg.RemoteDirectory
    $status['remoteDeleted'] = @($remoteResult.deleted)
    Write-Output "Backup uploaded and verified: $($cfg.RemoteHost):$($cfg.RemoteDirectory)/$fileName"
}
catch {
    $status['state'] = 'failed'
    # Report operational errors, never serialize config/builders or full invocation context.
    $status['error'] = $_.Exception.Message
    [Console]::Error.WriteLine("Backup failed: $($_.Exception.Message)")
}
finally {
    $status['finishedUtc'] = [datetime]::UtcNow.ToString('o')
    $status['elapsedSeconds'] = [math]::Round($timer.Elapsed.TotalSeconds, 3)
    if ($logPath) { Stop-Transcript | Out-Null }
    if ($lock) {
        try {
            $json = $status | ConvertTo-Json -Depth 4
            [IO.File]::WriteAllText((Join-Path $backupDir 'last-result.json'), $json, [Text.UTF8Encoding]::new($false))
            [IO.File]::WriteAllText((Join-Path $backupDir "result_$stamp.json"), $json, [Text.UTF8Encoding]::new($false))
        }
        finally { $lock.Dispose() }
    }
}
if ($status.state -ne 'success') { exit 1 }
