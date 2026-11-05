param([switch]$SkipBuild, [switch]$ServeFixture)
$ErrorActionPreference = 'Stop'
$rankRepo = (Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
$rankServerRepo = Join-Path (Split-Path $rankRepo -Parent) 'MTH-Server'
$rankOutput = Join-Path $rankRepo '.build/rank-history-validation'
$rankBin = Join-Path $rankRepo 'TTY.Web/bin'
# 仅连接本机隔离端口 33308，创建独立临时库；库已存在时拒绝运行，失败现场可留给开发者检查。
if (-not $SkipBuild) { & (Join-Path $PSScriptRoot 'build.bat') noclean }
New-Item -ItemType Directory -Path $rankOutput -Force | Out-Null
Copy-Item -Path (Join-Path $rankBin '*.dll') -Destination $rankOutput
$rankConfiguration = [xml](Get-Content -LiteralPath (Join-Path $rankRepo 'TTY.Web/Web.config') -Raw)
$rankConfiguration.configuration.connectionStrings.add | Where-Object name -eq 'DbConnString' | ForEach-Object {
    $_.connectionString = 'Server=localhost;Port=33308;Database=mth_rankhistory_validation;Uid=root;Pwd=123456;'
}
$rankExe = Join-Path $rankOutput 'RankHistoryValidation.exe'
$rankConfiguration.Save($rankExe + '.config')
$rankVsWhere = Join-Path ${env:ProgramFiles(x86)} 'Microsoft Visual Studio/Installer/vswhere.exe'
$rankVs = & $rankVsWhere -latest -products '*' -property installationPath
$rankCompiler = Join-Path $rankVs 'MSBuild/Current/Bin/Roslyn/csc.exe'
$rankReferences = Get-ChildItem (Join-Path $rankOutput '*.dll') | Where-Object Name -In 'YYT.Web.dll','YYT.BLL.dll','YYT.Entity.dll','YYT.Common.dll','MySql.Data.dll','Newtonsoft.Json.dll','System.Web.Http.dll','System.Net.Http.Formatting.dll' | ForEach-Object { '/r:' + $_.FullName }
& $rankCompiler /nologo /t:exe ('/out:' + $rankExe) /r:System.Configuration.dll /r:System.Net.Http.dll /r:System.Web.dll /r:System.Xml.Linq.dll /r:System.Data.dll @rankReferences (Join-Path $PSScriptRoot 'RankHistoryValidation.cs') (Join-Path $PSScriptRoot 'SqlSnapshot.cs')
if ($LASTEXITCODE -ne 0) { throw '排行榜验证程序编译失败' }
$rankArguments = @($rankRepo, $rankServerRepo)
if ($ServeFixture) {
    $rankStoreTest = Join-Path $rankServerRepo 'tests/_out/rank_history_store_test.exe'
    if (-not (Test-Path -LiteralPath $rankStoreTest)) { throw '实际 HTTP 联调必须先构建 tests/rank_history_store_test.cpp' }
    $rankClientRoot = Join-Path (Split-Path $rankRepo -Parent) 'MTH-git'
    if (-not (Test-Path -LiteralPath (Join-Path $rankClientRoot 'Assets'))) { throw '未找到配套 Unity 客户端 MTH-git' }
    $rankFixtureDirectory = Join-Path $rankClientRoot 'Temp/RankHistory'
    New-Item -ItemType Directory -Path $rankFixtureDirectory -Force | Out-Null
    [IO.File]::WriteAllText((Join-Path $rankFixtureDirectory 'http-fixture-url.txt'), 'http://127.0.0.1:18081', (New-Object Text.UTF8Encoding($false)))
    $rankArguments += '--serve-fixture'
}
& $rankExe @rankArguments
if ($LASTEXITCODE -ne 0) { throw '排行榜验证失败；请检查临时库 mth_rankhistory_validation 中的失败现场' }
