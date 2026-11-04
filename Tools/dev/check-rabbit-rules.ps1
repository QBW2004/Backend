param([int]$Port = 33308, [string]$Password = '')
$ErrorActionPreference = 'Stop'
if ($Port -notin 33308,33395) { throw 'Only dedicated local test MySQL ports are allowed' }
$repo = (Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
$out = Join-Path $repo '.build/rabbit-rules-validation'
New-Item -ItemType Directory -Path $out -Force | Out-Null
Copy-Item -Path (Join-Path $repo 'TTY.Web/bin/*.dll') -Destination $out
New-Item -ItemType Directory -Path (Join-Path $out 'Config') -Force | Out-Null
Copy-Item -LiteralPath (Join-Path $repo 'TTY.Web/Config/MsgDefine.config') -Destination (Join-Path $out 'Config')
[xml]$config = New-Object xml
$config.Load((Join-Path $repo 'TTY.Web/Web.config'))
$schema = 'mth_rabbit_rules_fixture_' + (Get-Date -Format 'yyyyMMdd_HHmmss')
($config.configuration.connectionStrings.add | Where-Object name -eq 'DbConnString').connectionString = "Server=127.0.0.1;Port=$Port;Database=$schema;Uid=root;Pwd=$Password;SslMode=None;"
($config.configuration.appSettings.add | Where-Object key -eq 'serverName').value = '.'
($config.configuration.appSettings.add | Where-Object key -eq 'pipeName').value = 'rabbit_rules_fixture_' + [guid]::NewGuid().ToString('N')
($config.configuration.appSettings.add | Where-Object key -eq 'robotPipeName').value = 'rabbit_rules_fixture_robot_' + [guid]::NewGuid().ToString('N')
$exe = Join-Path $out 'RabbitRulesValidation.exe'
$config.Save($exe + '.config')
$compiler = 'C:/Program Files/Microsoft Visual Studio/2022/Community/MSBuild/Current/Bin/Roslyn/csc.exe'
$references = Get-ChildItem (Join-Path $out '*.dll') | Where-Object Name -In 'YYT.Web.dll','YYT.BLL.dll','YYT.Entity.dll','YYT.Common.dll','YYT.Remote.dll','MySql.Data.dll','EntityFramework.dll','Newtonsoft.Json.dll','System.Web.Mvc.dll','System.Web.Razor.dll','System.Web.WebPages.dll' | ForEach-Object { '/r:' + $_.FullName }
& $compiler /nologo /t:exe ('/out:' + $exe) /r:System.Configuration.dll /r:System.Data.dll /r:System.Web.dll /r:System.Xml.dll @references (Join-Path $PSScriptRoot 'RabbitRulesValidation.cs')
if ($LASTEXITCODE -ne 0) { throw 'Rabbit rules validation compile failed' }
& $exe
if ($LASTEXITCODE -ne 0) { throw 'Rabbit rules validation failed' }
