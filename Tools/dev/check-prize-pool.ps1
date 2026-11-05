param([switch]$SkipBuild)
$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
$server = (Resolve-Path (Join-Path $repo '../MTH-Server')).Path
if (-not $SkipBuild) {
    & (Join-Path $PSScriptRoot 'build.bat') noclean
    if ($LASTEXITCODE -ne 0) { throw 'Backend build failed' }
}
$out = Join-Path $repo '.build/prize-pool-validation'
New-Item -ItemType Directory -Path $out -Force | Out-Null
Copy-Item -Path (Join-Path $repo 'TTY.Web/bin/*.dll') -Destination $out
New-Item -ItemType Directory -Path (Join-Path $out 'Config') -Force | Out-Null
Copy-Item -LiteralPath (Join-Path $repo 'TTY.Web/Config/card-prize-quotes.json') -Destination (Join-Path $out 'Config')
[xml]$config = New-Object xml
$config.Load((Join-Path $repo 'TTY.Web/Web.config'))
$schema = 'mth_prize_validation_' + (Get-Date -Format 'yyyyMMdd_HHmmss')
($config.configuration.connectionStrings.add | Where-Object name -eq 'DbConnString').connectionString = "Server=127.0.0.1;Port=33308;Database=$schema;Uid=root;Pwd=;SslMode=None;"
$exe = Join-Path $out 'PrizePoolValidation.exe'
$config.Save($exe + '.config')
$compiler = 'C:/Program Files/Microsoft Visual Studio/2022/Community/MSBuild/Current/Bin/Roslyn/csc.exe'
$references = Get-ChildItem (Join-Path $out '*.dll') | Where-Object Name -In 'YYT.BLL.dll','YYT.Entity.dll','YYT.Common.dll','MySql.Data.dll','EntityFramework.dll','Newtonsoft.Json.dll' | ForEach-Object { '/r:' + $_.FullName }
& $compiler /nologo /t:exe ('/out:' + $exe) /r:System.Configuration.dll /r:System.Data.dll @references (Join-Path $PSScriptRoot 'PrizePoolValidation.cs') (Join-Path $PSScriptRoot 'SqlSnapshot.cs')
if ($LASTEXITCODE -ne 0) { throw 'Prize-pool validation compile failed' }
python (Join-Path $PSScriptRoot 'prepare-prize-pool-cpp.py') $out
if ($LASTEXITCODE -ne 0) { throw 'Prize-pool C++ preparation failed' }
& (Join-Path $out 'build-prize-pool.bat')
if ($LASTEXITCODE -ne 0) { throw 'Prize-pool C++ compile failed' }
Copy-Item -LiteralPath (Join-Path $server '../local-run/ServerCenterNew/x64/Release/libmysql.dll') -Destination $out
Copy-Item -Path (Join-Path $server 'third_party/pocolink/bin/Poco*.dll') -Destination $out
$env:PATH = (Join-Path $server 'third_party/pocolink/bin') + ';' + $env:PATH
& $exe $repo (Join-Path $out 'prize-pool-cpp.exe')
if ($LASTEXITCODE -ne 0) { throw 'Prize-pool validation failed' }
