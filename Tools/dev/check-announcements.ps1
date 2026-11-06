$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
$output = Join-Path $root '.build/announcement-http-validation'
$mysql = 'E:/MTH/mysql57/mysql-5.7.44-winx64/bin/mysqld.exe'
$data = Join-Path $output 'mysql-data'
$watch = [Diagnostics.Stopwatch]::StartNew()
if (Get-NetTCPConnection -LocalPort 33418 -State Listen -ErrorAction SilentlyContinue) { throw 'Isolated port 33418 is already in use.' }
New-Item -ItemType Directory -Path $output -Force | Out-Null
if (-not (Test-Path -LiteralPath (Join-Path $data 'mysql'))) {
    New-Item -ItemType Directory -Path $data -Force | Out-Null
    & $mysql --no-defaults --initialize-insecure --lower_case_table_names=1 "--datadir=$data" "--log-error=$output/mysql-init.log"
    if ($LASTEXITCODE -ne 0) { throw 'Isolated MySQL initialization failed.' }
}
$process = Start-Process -FilePath $mysql -ArgumentList @('--no-defaults',"--datadir=$data",'--lower_case_table_names=1','--port=33418','--bind-address=127.0.0.1',"--log-error=$output/mysql.log") -WindowStyle Hidden -PassThru
try {
    $ready = $false
    for ($i=0; $i -lt 40; $i++) {
        $socket = New-Object Net.Sockets.TcpClient
        try { $socket.Connect('127.0.0.1',33418); $ready=$true; break } catch { Start-Sleep -Milliseconds 100 } finally { $socket.Dispose() }
    }
    if (-not $ready) { throw 'Isolated MySQL failed to listen.' }
    Copy-Item -Path (Join-Path $root 'TTY.Web/bin/*.dll') -Destination $output
    New-Item -ItemType Directory -Path (Join-Path $output 'Config') -Force | Out-Null
    Copy-Item -LiteralPath (Join-Path $root 'TTY.Web/Config/MsgDefine.config') -Destination (Join-Path $output 'Config/MsgDefine.config')
    $configuration = [xml](Get-Content -LiteralPath (Join-Path $root 'TTY.Web/Web.config') -Raw)
    $database = 'mth_announcement_validation_' + [DateTime]::UtcNow.Ticks
    $configuration.configuration.appSettings.add | Where-Object key -eq 'serverName' | ForEach-Object { $_.value = '.' }
    $configuration.configuration.appSettings.add | Where-Object key -eq 'pipeName' | ForEach-Object { $_.value = $database }
    $configuration.configuration.connectionStrings.add | Where-Object name -eq 'DbConnString' | ForEach-Object {
        $_.connectionString = "Server=127.0.0.1;Port=33418;Database=$database;Uid=root;Pwd=;CharSet=utf8mb4;Allow User Variables=True;SslMode=None;"
    }
    $exe = Join-Path $output 'AnnouncementHttpValidation.exe'
    $configuration.Save($exe + '.config')
    $references = Get-ChildItem -Path (Join-Path $output '*.dll') | Where-Object Name -In 'YYT.Web.dll','YYT.BLL.dll','YYT.Entity.dll','YYT.Common.dll','MySql.Data.dll','Newtonsoft.Json.dll','System.Web.Http.dll','System.Net.Http.Formatting.dll','EntityFramework.dll','log4net.dll' | ForEach-Object { '/r:' + $_.FullName }
    & 'C:/Program Files/Microsoft Visual Studio/2022/Community/MSBuild/Current/Bin/Roslyn/csc.exe' /nologo /t:exe ('/out:'+$exe) /r:System.Configuration.dll /r:System.Net.Http.dll /r:System.Web.dll /r:System.Data.dll @references (Join-Path $PSScriptRoot 'AnnouncementHttpValidation.cs') (Join-Path $PSScriptRoot 'SqlSnapshot.cs')
    if ($LASTEXITCODE -ne 0) { throw 'Validation build failed.' }
    & $exe $root
    if ($LASTEXITCODE -ne 0) { throw 'Validation failed; isolated database retained.' }
}
finally {
    if (-not $process.HasExited) { Stop-Process -Id $process.Id -Force }
    $watch.Stop()
    'TOTAL_SECONDS=' + $watch.Elapsed.TotalSeconds
}
