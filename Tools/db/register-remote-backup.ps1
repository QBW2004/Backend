param(
    [Parameter(Mandatory = $true)][string]$Config,
    [string]$TaskName = 'MTH_DatabaseBackup_Daily'
)
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
if (-not [Environment]::Is64BitProcess) { throw 'Run this installer in 64-bit Windows PowerShell.' }
if ([TimeZoneInfo]::Local.Id -notin @('China Standard Time', 'Taipei Standard Time')) {
    throw 'This daily 04:00 task requires a UTC+8 China/Taipei server time zone.'
}
$configPath = (Resolve-Path -LiteralPath $Config).Path
$runner = Join-Path $PSScriptRoot 'backup-to-remote.ps1'
if (-not (Test-Path -LiteralPath $runner -PathType Leaf)) { throw 'Backup runner is missing.' }
if (Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue) {
    throw "Task $TaskName already exists. Inspect it before replacing it."
}
$cfg = Get-Content -LiteralPath $configPath -Raw -Encoding UTF8 | ConvertFrom-Json
if (-not (Test-Path -LiteralPath $cfg.IdentityFile -PathType Leaf)) { throw 'Dedicated backup SSH key is missing.' }
# OpenSSH rejects a key owned/readable by the interactive administrator when the task runs as SYSTEM.
$system = New-Object Security.Principal.SecurityIdentifier('S-1-5-18')
$keyAcl = New-Object Security.AccessControl.FileSecurity
$keyAcl.SetOwner($system)
$keyAcl.SetAccessRuleProtection($true, $false)
$keyAcl.AddAccessRule((New-Object Security.AccessControl.FileSystemAccessRule($system, 'FullControl', 'Allow')))
Set-Acl -LiteralPath $cfg.IdentityFile -AclObject $keyAcl
$action = New-ScheduledTaskAction -Execute "$env:WINDIR\System32\WindowsPowerShell\v1.0\powershell.exe" `
    -Argument "-NoProfile -NonInteractive -ExecutionPolicy Bypass -File `"$runner`" -Config `"$configPath`""
$trigger = New-ScheduledTaskTrigger -Daily -At '04:00'
$settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -MultipleInstances IgnoreNew `
    -ExecutionTimeLimit (New-TimeSpan -Minutes 45) -RestartCount 3 -RestartInterval (New-TimeSpan -Minutes 15)
Register-ScheduledTask -TaskName $TaskName -Action $action -Trigger $trigger -Settings $settings `
    -User 'SYSTEM' -RunLevel Highest -Description "Daily 04:00 UTC+8 full mth SQL backup, SSH transfer, SHA-256 verification; retain $($cfg.KeepDays) Beijing calendar days." | Out-Null
Get-ScheduledTaskInfo -TaskName $TaskName | Select-Object TaskName, NextRunTime, LastTaskResult
