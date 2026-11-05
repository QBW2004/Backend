param(
    [ValidatePattern('^[A-Za-z0-9_]+$')][string]$DbName = 'mth',
    [ValidatePattern('^[A-Za-z0-9_.-]+$')][string]$User = 'root',
    [string]$Password = $env:MYSQL_PWD,
    [string]$Server = '127.0.0.1',
    [ValidateRange(1, 65535)][int]$Port = 3306,
    [string]$Output = '',
    [string]$MySqlDumpExe = ''
)

$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..')).Path
if (-not $Output) {
    $archiveRoot = Join-Path (Split-Path $repoRoot -Parent) ((Split-Path $repoRoot -Leaf) + '-db-archives')
    $Output = Join-Path $archiveRoot ("{0}_{1}.sql" -f $DbName, (Get-Date -Format 'yyyyMMdd_HHmmss'))
}
$Output = [IO.Path]::GetFullPath($Output)
if (Test-Path -LiteralPath $Output) { throw 'Output already exists. Choose a new archive path; existing backups are never overwritten.' }
if ($Output.StartsWith($repoRoot + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase)) {
    throw 'Export to an archive outside the repository. Refresh the two canonical Database files only after verification.'
}
if (-not $MySqlDumpExe) {
    $MySqlDumpExe = @('C:\mysql\bin\mysqldump.exe',
        'C:\Program Files\MySQL\MySQL Server 5.7\bin\mysqldump.exe',
        'C:\Program Files\MySQL\MySQL Server 8.4\bin\mysqldump.exe',
        'C:\Program Files\MySQL\MySQL Server 8.0\bin\mysqldump.exe') |
        Where-Object { Test-Path -LiteralPath $_ -PathType Leaf } | Select-Object -First 1
}
if (-not $MySqlDumpExe -or -not (Test-Path -LiteralPath $MySqlDumpExe -PathType Leaf)) { throw 'mysqldump.exe not found; pass -MySqlDumpExe.' }
if (-not $PSBoundParameters.ContainsKey('Password') -and -not $Password) {
    $securePassword = Read-Host 'MySQL password' -AsSecureString
    $Password = (New-Object System.Net.NetworkCredential('', $securePassword)).Password
}
[void][IO.Directory]::CreateDirectory((Split-Path $Output -Parent))
$previousPassword = $env:MYSQL_PWD
$timer = [Diagnostics.Stopwatch]::StartNew()
try {
    $env:MYSQL_PWD = $Password
    $dumpArgs = @('--protocol=TCP', "--host=$Server", "--port=$Port", "--user=$User",
        '--default-character-set=utf8mb4', '--single-transaction', '--hex-blob',
        '--routines', '--triggers', '--events', '--set-gtid-purged=OFF',
        '--result-file', $Output, $DbName)
    & $MySqlDumpExe @dumpArgs
    if ($LASTEXITCODE -ne 0) {
        if (Test-Path -LiteralPath $Output -PathType Leaf) { Remove-Item -LiteralPath $Output -Force }
        throw 'Database export failed.'
    }
    if ((Get-Item -LiteralPath $Output).Length -eq 0) { throw 'Database export is empty.' }
    Write-Host "Exported: $Output"
    Write-Host "SHA256: $((Get-FileHash -LiteralPath $Output -Algorithm SHA256).Hash)"
    Write-Host "Elapsed: $([math]::Round($timer.Elapsed.TotalSeconds, 2)) seconds."
}
finally { $env:MYSQL_PWD = $previousPassword }
