<#
.SYNOPSIS
    打包 TTY.Web 为部署 zip（排除 Logs/obj/.vs，并校验关键文件齐全）。
.EXAMPLE
    powershell -NoProfile -ExecutionPolicy Bypass -File Tools\_pack.ps1 -Version 1.0.14
#>
param(
    [Parameter(Mandatory = $true)]
    [string]$Version
)

$ErrorActionPreference = 'Stop'
$stage = Join-Path $env:TEMP 'mth_pack_stage'
if (Test-Path $stage) { Remove-Item $stage -Recurse -Force }
New-Item -ItemType Directory -Path $stage | Out-Null

robocopy 'E:\MTH\MHT-Backend\TTY.Web' (Join-Path $stage 'TTY.Web') /E /NFL /NDL /NP /NJH /XD Logs obj .vs | Out-Null
if ($LASTEXITCODE -ge 8) { throw "robocopy failed: $LASTEXITCODE" }

$zip = Join-Path $stage "TTY.Web_$Version.zip"
Compress-Archive -Path (Join-Path $stage 'TTY.Web') -DestinationPath $zip -Force

# 关键文件校验（PS5.1 Compress-Archive 的条目分隔符是反斜杠）
Add-Type -AssemblyName System.IO.Compression.FileSystem
$z = [System.IO.Compression.ZipFile]::OpenRead($zip)
$must = @(
    'TTY.Web\Web.config',
    'TTY.Web\bin\YYT.Web.dll',
    'TTY.Web\Scripts\app\phone\phone.core.js',
    'TTY.Web\Content\css\phone.css'
)
$missing = @()
foreach ($m in $must) {
    if (-not ($z.Entries | Where-Object { $_.FullName -eq $m })) { $missing += $m }
}
$total = $z.Entries.Count
$z.Dispose()
if ($missing.Count -gt 0) { throw ("zip 缺关键文件: " + ($missing -join ', ')) }

'{0}  {1:N1} MB  ({2} entries)' -f $zip, ((Get-Item $zip).Length / 1MB), $total
