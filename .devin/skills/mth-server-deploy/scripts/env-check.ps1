# Compatibility entry point. Keep environment checks and clean initialization in one place.
# This wrapper requires the complete backend repository, just like its previous installer copy.
param(
    [switch]$CheckOnly,
    [switch]$Yes,
    [int]$WebPort,
    [string]$MySqlRootPassword,
    [switch]$InitSchema
)
$ErrorActionPreference = 'Stop'
$canonical = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..\..\..\Tools\server-env\env-check.ps1'))
if (-not (Test-Path -LiteralPath $canonical -PathType Leaf)) {
    throw 'Missing Tools/server-env/env-check.ps1. Carry the complete backend repository; initialization cannot be skipped.'
}
& $canonical @PSBoundParameters
