param(
    [Parameter(Mandatory = $true)]
    [ValidatePattern('^[A-Za-z0-9_]+$')][string]$DbName,
    [ValidateSet('127.0.0.1', 'localhost', '::1')][string]$Server = '127.0.0.1',
    [ValidateRange(1, 65535)][int]$Port = 3306,
    [ValidatePattern('^[A-Za-z0-9_.-]+$')][string]$User = 'root',
    [string]$Password = $env:MYSQL_PWD,
    [string]$SqlFile = '',
    [string]$MySqlExe = '',
    [switch]$Force,
    [switch]$DryRun
)

$ErrorActionPreference = 'Stop'
if (-not $SqlFile) { $SqlFile = Join-Path $PSScriptRoot '..\..\Database\mth_clean.sql' }
if ($DbName -in @('mysql', 'sys', 'information_schema', 'performance_schema')) {
    throw 'System databases cannot be reset.'
}
$SqlFile = (Resolve-Path -LiteralPath $SqlFile).Path
if (-not (Test-Path -LiteralPath $SqlFile -PathType Leaf)) { throw 'SQL input must be a file.' }
# A dump must use the explicitly selected database, never switch to a second schema.
if (Select-String -LiteralPath $SqlFile -Pattern '^\s*(USE\s|(?:CREATE|DROP)\s+DATABASE\s)' -Quiet) {
    throw 'Use a single-schema dump without CREATE/DROP DATABASE or USE statements.'
}
Write-Host "Target: ${Server}:$Port / $DbName"
Write-Host "Input : $SqlFile"
if ($DryRun) {
    Write-Host "[DRY-RUN] Drop/recreate '$DbName', import this file once, then count tables. No migration patches. No connection made."
    exit 0
}

if (-not $MySqlExe) {
    $MySqlExe = @('C:\mysql\bin\mysql.exe',
        'C:\Program Files\MySQL\MySQL Server 5.7\bin\mysql.exe',
        'C:\Program Files\MySQL\MySQL Server 8.4\bin\mysql.exe',
        'C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe') |
        Where-Object { Test-Path -LiteralPath $_ -PathType Leaf } | Select-Object -First 1
}
if (-not $MySqlExe -or -not (Test-Path -LiteralPath $MySqlExe -PathType Leaf)) { throw 'mysql.exe not found; pass -MySqlExe.' }
if (-not $Force) {
    Write-Host "WARNING: All data in local database '$DbName' will be deleted." -ForegroundColor Red
    if ((Read-Host 'Type YES to continue') -cne 'YES') { Write-Host 'Cancelled.'; exit 0 }
}
if (-not $PSBoundParameters.ContainsKey('Password') -and -not $Password) {
    $securePassword = Read-Host 'MySQL password' -AsSecureString
    $Password = (New-Object System.Net.NetworkCredential('', $securePassword)).Password
}
$previousPassword = $env:MYSQL_PWD
$timer = [Diagnostics.Stopwatch]::StartNew()
try {
    $env:MYSQL_PWD = $Password
    $mysqlArgs = @('--protocol=TCP', "--host=$Server", "--port=$Port", "--user=$User", '--default-character-set=utf8mb4')
    $caseMode = & $MySqlExe @mysqlArgs -N -B -e 'SELECT @@lower_case_table_names;'
    if ($LASTEXITCODE -ne 0) { throw 'MySQL connection failed.' }
    if (($caseMode -join '').Trim() -ne '1') { throw 'Requires lower_case_table_names=1.' }
    & $MySqlExe @mysqlArgs -e "DROP DATABASE IF EXISTS ``$DbName``; CREATE DATABASE ``$DbName`` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
    if ($LASTEXITCODE -ne 0) { throw 'Database recreation failed.' }

    $start = New-Object Diagnostics.ProcessStartInfo
    $start.FileName = $MySqlExe
    $start.Arguments = ($mysqlArgs + @("--database=$DbName", '--binary-mode=1')) -join ' '
    $start.UseShellExecute = $false
    $start.CreateNoWindow = $true
    $start.RedirectStandardInput = $true
    $start.RedirectStandardOutput = $true
    $start.RedirectStandardError = $true
    $process = New-Object Diagnostics.Process
    $process.StartInfo = $start
    try {
        [void]$process.Start()
        $outputTask = $process.StandardOutput.ReadToEndAsync()
        $errorTask = $process.StandardError.ReadToEndAsync()
        $inputFile = [IO.File]::OpenRead($SqlFile)
        try { $inputFile.CopyTo($process.StandardInput.BaseStream) }
        finally { $inputFile.Dispose(); $process.StandardInput.Close() }
        $process.WaitForExit()
        [void]$outputTask.GetAwaiter().GetResult()
        $importError = $errorTask.GetAwaiter().GetResult()
        if ($process.ExitCode -ne 0) { throw "Import failed (exit $($process.ExitCode)): $importError" }
    }
    finally { $process.Dispose() }
    $count = & $MySqlExe @mysqlArgs -N -B -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='$DbName';"
    if ($LASTEXITCODE -ne 0 -or [int]$count -eq 0) { throw 'Imported schema verification failed.' }
    Write-Host "Imported $count tables/views in $([math]::Round($timer.Elapsed.TotalSeconds, 2)) seconds."
}
finally { $env:MYSQL_PWD = $previousPassword }
