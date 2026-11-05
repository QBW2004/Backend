param()

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
Set-StrictMode -Version 2
$windowsPowerShell = Join-Path $env:WINDIR 'System32\WindowsPowerShell\v1.0\powershell.exe'
if ($PSVersionTable.PSVersion.Major -ne 5) {
    & $windowsPowerShell -NoProfile -NonInteractive -ExecutionPolicy Bypass -File $PSCommandPath
    exit $LASTEXITCODE
}

$timer = [Diagnostics.Stopwatch]::StartNew()
$script:passed = 0
function Assert-True([bool]$Condition, [string]$Message) {
    if (-not $Condition) { throw "FAIL: $Message" }
    $script:passed++
}
function Assert-Throws([scriptblock]$Action, [string]$Expected) {
    $caught = $false
    try { & $Action | Out-Null }
    catch {
        if ($_.Exception.Message -notlike "*$Expected*") { throw }
        $caught = $true
    }
    Assert-True $caught "Expected failure containing '$Expected'."
}

$repoRoot = Split-Path $PSScriptRoot -Parent
$runner = Join-Path $repoRoot 'Tools\db\backup-to-remote.ps1'
$tokens = $null
$parseErrors = $null
$ast = [Management.Automation.Language.Parser]::ParseFile($runner, [ref]$tokens, [ref]$parseErrors)
Assert-True (@($parseErrors).Count -eq 0) 'Backup script must parse in Windows PowerShell 5.1.'
foreach ($name in @('Invoke-Transfer', 'Remove-ExpiredLocalBackups')) {
    $definition = @($ast.FindAll({ param($node)
        $node -is [Management.Automation.Language.FunctionDefinitionAst] -and $node.Name -eq $name
    }, $true))
    Assert-True ($definition.Count -eq 1) "Exactly one $name function is required."
    . ([scriptblock]::Create($definition[0].Extent.Text))
}

$tempBase = [IO.Path]::GetFullPath([IO.Path]::GetTempPath()).TrimEnd('\')
$testRoot = Join-Path $tempBase ('mth-backup-test-' + [guid]::NewGuid().ToString('N'))
[void][IO.Directory]::CreateDirectory($testRoot)
try {
    $probe = Join-Path $testRoot 'argument probe.exe'
    Add-Type -TypeDefinition @'
using System;
using System.Text;
public static class ArgumentProbe {
    public static int Main(string[] args) {
        if (args.Length > 0 && args[0] == "stderr") {
            Console.Error.WriteLine("benign SSH banner");
            Console.Out.WriteLine("verified");
            return 0;
        }
        if (args.Length > 0 && args[0] == "fail") {
            Console.Error.WriteLine("expected transfer failure");
            return 7;
        }
        foreach (string arg in args) {
            Console.WriteLine(Convert.ToBase64String(Encoding.UTF8.GetBytes(arg)));
        }
        return 0;
    }
}
'@ -OutputAssembly $probe -OutputType ConsoleApplication

    $arguments = @('plain', '', ' ', 'with spaces', 'quote"inside', '"', '\', '\\',
        'C:\folder with spaces\', 'two trailing\\', 'C:\folder\"quoted"\', 'escaped\\"quote')
    $expected = ($arguments | ForEach-Object { [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($_)) }) -join "`r`n"
    $received = Invoke-Transfer $probe $arguments
    Assert-True ($received.TrimEnd("`r", "`n") -ceq $expected) 'Native argv must preserve spaces, quotes, empty arguments and trailing backslashes.'
    Assert-True ((Invoke-Transfer $probe @('stderr')).Trim() -ceq 'verified') 'Exit 0 must return stdout without the stderr banner.'
    Assert-Throws { Invoke-Transfer $probe @('fail') } 'exit 7'

    $backupDir = Join-Path $testRoot 'retention'
    [void][IO.Directory]::CreateDirectory($backupDir)
    $expired = @('mth_20261102_040000.sql', 'mth_20261102_040000.sql.sha256',
        'backup_20261102_040000.log', 'result_20261102_040000.json')
    $retained = @('mth_20261103_040000.sql', 'mth_20261104_040000.sql', 'mth_20261105_040000.sql',
        'backup_20261103_040000.log', 'result_20261103_040000.json', 'mth_20261106_040000.sql',
        'mth_20260231_040000.sql', 'mth_20261102_040000.sql.partial', 'notes.sql', 'last-result.json',
        'backup_20261102_040000.sql', 'mth_20261102_040000.json', 'result_20261102_040000.log')
    foreach ($file in ($expired + $retained)) {
        [IO.File]::WriteAllText((Join-Path $backupDir $file), 'test marker')
    }
    $unrelatedDirectory = Join-Path $backupDir 'mth_20261101_040000.sql'
    [void][IO.Directory]::CreateDirectory($unrelatedDirectory)
    [IO.File]::WriteAllText((Join-Path $unrelatedDirectory 'untouched.txt'), 'nested marker')
    Remove-ExpiredLocalBackups $backupDir ([datetime]'2026-11-03')
    foreach ($file in $expired) {
        Assert-True (-not (Test-Path -LiteralPath (Join-Path $backupDir $file))) "Expired artifact $file must be removed."
    }
    foreach ($file in $retained) {
        Assert-True (Test-Path -LiteralPath (Join-Path $backupDir $file) -PathType Leaf) "Retained or unrelated file $file must remain."
    }
    Assert-True (Test-Path -LiteralPath (Join-Path $unrelatedDirectory 'untouched.txt') -PathType Leaf) 'Cleanup must not recurse into directories.'

    # A missing key must fail before loading MySQL or opening any connection, and replace stale status.
    $failureDir = Join-Path $testRoot 'failure-status'
    [void][IO.Directory]::CreateDirectory($failureDir)
    [IO.File]::WriteAllText((Join-Path $failureDir 'last-result.json'), '{"state":"success"}')
    $oldBackup = Join-Path $failureDir 'mth_20261101_040000.sql'
    [IO.File]::WriteAllText($oldBackup, 'must survive failure')
    $dependency = Join-Path $testRoot 'placeholder.txt'
    [IO.File]::WriteAllText($dependency, 'not loaded')
    $configPath = Join-Path $testRoot 'failure-config.json'
    $config = [ordered]@{
        LocalDirectory = $failureDir
        RemoteHost = '127.0.0.1'; RemoteUser = 'mthbackup'; RemotePort = 22
        RemoteDirectory = '/var/backups/mth'; RemoteReceiver = '/usr/local/libexec/mth-backup.py'; KeepDays = 3
        WebConfig = $dependency; MySqlAssembly = $dependency; MySqlDumpExe = $dependency
        SshExe = $dependency; ScpExe = $dependency; KnownHostsFile = $dependency
        IdentityFile = (Join-Path $testRoot 'missing-key')
    }
    [IO.File]::WriteAllText($configPath, ($config | ConvertTo-Json), [Text.UTF8Encoding]::new($false))
    Assert-Throws { Invoke-Transfer $windowsPowerShell @('-NoProfile', '-NonInteractive', '-ExecutionPolicy', 'Bypass', '-File', $runner, '-Config', $configPath) } 'required backup dependency is missing'
    $result = Get-Content -LiteralPath (Join-Path $failureDir 'last-result.json') -Raw -Encoding UTF8 | ConvertFrom-Json
    Assert-True ($result.state -eq 'failed') 'Dependency failure must replace the previous success status.'
    Assert-True (Test-Path -LiteralPath $oldBackup -PathType Leaf) 'Failure must not clean old backups.'
    Assert-True (@(Get-ChildItem -LiteralPath $failureDir -Filter 'result_*.json' -File).Count -eq 1) 'Dependency failure must write an individual result record.'

    [pscustomobject]@{
        result = 'PASS'
        assertions = $script:passed
        powershellVersion = $PSVersionTable.PSVersion.ToString()
        elapsedSeconds = [math]::Round($timer.Elapsed.TotalSeconds, 3)
    } | ConvertTo-Json -Compress
}
finally {
    $resolvedRoot = [IO.Path]::GetFullPath($testRoot)
    if ([IO.Path]::GetDirectoryName($resolvedRoot) -ne $tempBase -or
        [IO.Path]::GetFileName($resolvedRoot) -notmatch '^mth-backup-test-[0-9a-f]{32}$' -or
        (Get-Item -LiteralPath $resolvedRoot).Attributes -band [IO.FileAttributes]::ReparsePoint) {
        throw 'Refusing unsafe temporary test cleanup.'
    }
    Remove-Item -LiteralPath $resolvedRoot -Recurse -Force
}
