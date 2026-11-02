$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
$out = Join-Path $repo '.build/prize-record-remove-validation'
New-Item -ItemType Directory -Path $out -Force | Out-Null
Copy-Item -Path (Join-Path $repo 'TTY.Web/bin/*.dll') -Destination $out
[xml]$config = New-Object xml
$config.Load((Join-Path $repo 'TTY.Web/Web.config'))
$schema = 'mth_prize_remove_validation_' + (Get-Date -Format 'yyyyMMdd_HHmmss')
($config.configuration.connectionStrings.add | Where-Object name -eq 'DbConnString').connectionString = "Server=127.0.0.1;Port=33308;Database=$schema;Uid=root;Pwd=;SslMode=None;"
$exe = Join-Path $out 'PrizeRecordRemovalValidation.exe'
$config.Save($exe + '.config')
$compiler = 'C:/Program Files/Microsoft Visual Studio/2022/Community/MSBuild/Current/Bin/Roslyn/csc.exe'
$references = Get-ChildItem (Join-Path $out '*.dll') | Where-Object Name -In 'YYT.BLL.dll','YYT.Entity.dll','YYT.Common.dll','YYT.Remote.dll','MySql.Data.dll','EntityFramework.dll','Newtonsoft.Json.dll' | ForEach-Object { '/r:' + $_.FullName }
& $compiler /nologo /t:exe ('/out:' + $exe) /r:System.Configuration.dll /r:System.Data.dll @references (Join-Path $PSScriptRoot 'PrizeRecordRemovalValidation.cs')
if ($LASTEXITCODE -ne 0) { throw 'Removal validation compile failed' }
& $exe
if ($LASTEXITCODE -ne 0) { throw 'Removal validation failed' }
