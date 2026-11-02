param([switch]$SkipBuild)
$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
if (-not $SkipBuild) { & (Join-Path $PSScriptRoot 'build.bat') noclean }
$output = Join-Path $repo '.build/player-winloss-validation'
New-Item -ItemType Directory -Path $output -Force | Out-Null
Copy-Item -Path (Join-Path $repo 'TTY.Web/bin/*.dll') -Destination $output
[xml]$config = New-Object xml
$config.Load((Join-Path $repo 'TTY.Web/Web.config'))
$schema = 'mth_winloss_validation_' + (Get-Date -Format 'yyyyMMdd_HHmmss')
($config.configuration.connectionStrings.add | Where-Object name -eq 'DbConnString').connectionString = "Server=127.0.0.1;Port=33308;Database=$schema;Uid=root;Pwd=;"
$exe = Join-Path $output 'PlayerWinLossValidation.exe'
$config.Save($exe + '.config')
$compiler = 'C:/Program Files/Microsoft Visual Studio/2022/Community/MSBuild/Current/Bin/Roslyn/csc.exe'
$references = Get-ChildItem (Join-Path $output '*.dll') | Where-Object Name -In 'YYT.BLL.dll','YYT.Entity.dll','YYT.Common.dll','MySql.Data.dll','EntityFramework.dll','Newtonsoft.Json.dll' | ForEach-Object { '/r:' + $_.FullName }
& $compiler /nologo /t:exe ('/out:' + $exe) /r:System.Configuration.dll /r:System.Data.dll @references (Join-Path $PSScriptRoot 'PlayerWinLossValidation.cs')
if ($LASTEXITCODE -ne 0) { throw 'Player win/loss validation compile failed' }
& $exe $repo
if ($LASTEXITCODE -ne 0) { throw 'Player win/loss validation failed' }
