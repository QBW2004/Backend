$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
$out = Join-Path $repo '.build/player-table-display-validation'
New-Item -ItemType Directory -Path $out -Force | Out-Null
Copy-Item -Path (Join-Path $repo 'TTY.Web/bin/*.dll') -Destination $out
[xml]$config = New-Object xml
$config.Load((Join-Path $repo 'TTY.Web/Web.config'))
$schema = 'mth_table_display_validation_' + (Get-Date -Format 'yyyyMMdd_HHmmss')
($config.configuration.connectionStrings.add | Where-Object name -eq 'DbConnString').connectionString = "Server=127.0.0.1;Port=33416;Database=$schema;Uid=root;Pwd=;SslMode=None;CharSet=utf8mb4;"
$exe = Join-Path $out 'PlayerTableDisplayValidation.exe'
$config.Save($exe + '.config')
$compiler = 'C:/Program Files/Microsoft Visual Studio/2022/Community/MSBuild/Current/Bin/Roslyn/csc.exe'
$references = Get-ChildItem (Join-Path $out '*.dll') | Where-Object Name -In 'YYT.Web.dll','YYT.BLL.dll','YYT.Entity.dll','YYT.Common.dll','MySql.Data.dll','EntityFramework.dll','Newtonsoft.Json.dll','System.Web.Mvc.dll' | ForEach-Object { '/r:' + $_.FullName }
& $compiler /nologo /t:exe ('/out:' + $exe) /r:System.Configuration.dll /r:System.Data.dll /r:System.Web.dll /r:System.ComponentModel.DataAnnotations.dll /r:Microsoft.CSharp.dll @references (Join-Path $PSScriptRoot 'PlayerTableDisplayValidation.cs') (Join-Path $PSScriptRoot 'SqlSnapshot.cs')
if ($LASTEXITCODE -ne 0) { throw 'Player table display validation compile failed' }
& $exe $repo
if ($LASTEXITCODE -ne 0) { throw 'Player table display validation failed' }
