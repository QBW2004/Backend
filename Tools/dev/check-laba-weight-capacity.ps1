param([string]$SitePath = '')
$ErrorActionPreference = 'Stop'
$root = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..'))
if (!$SitePath) { $SitePath = Join-Path $root 'TTY.Web' }
$out = Join-Path $root '.build\laba-capacity-validation'
$runtime = Join-Path $out 'runtime'
$data = Join-Path $out 'mysql-data'
$mysql = 'E:\MTH\mysql57\mysql-5.7.44-winx64\bin\mysqld.exe'
$timer = [Diagnostics.Stopwatch]::StartNew()
New-Item -ItemType Directory -Path $runtime,$data -Force | Out-Null
if (Get-NetTCPConnection -LocalPort 33406 -State Listen -ErrorAction SilentlyContinue) { throw 'Test port 33406 already in use' }
if (!(Test-Path (Join-Path $data 'mysql'))) {
    & $mysql --no-defaults --initialize-insecure --lower-case-table-names=1 "--datadir=$data" "--log-error=$out\mysql-init.log"
    if ($LASTEXITCODE -ne 0) { throw 'MySQL initialization failed' }
}
$proc = Start-Process -FilePath $mysql -ArgumentList @('--no-defaults',"--datadir=$data",'--port=33406','--bind-address=127.0.0.1','--lower-case-table-names=1',"--log-error=$out\mysql.log") -WindowStyle Hidden -PassThru
try {
    for($i=0;$i -lt 60;$i++) { if (Get-NetTCPConnection -LocalPort 33406 -State Listen -ErrorAction SilentlyContinue) { break }; Start-Sleep -Milliseconds 100 }
    Copy-Item -Path (Join-Path $SitePath 'bin\*.dll') -Destination $runtime
    $source=[xml](Get-Content -LiteralPath (Join-Path $SitePath 'Web.config') -Raw)
    $config=[xml]'<configuration><appSettings/><connectionStrings><add name="DbConnString" providerName="MySql.Data.MySqlClient" connectionString=""/></connectionStrings></configuration>'
    $settings=$config.SelectSingleNode('/configuration/appSettings')
    [void]$config.configuration.PrependChild($config.ImportNode($source.configuration.configSections,$true))
    foreach($section in @('runtime','entityFramework','system.data')){[void]$config.configuration.AppendChild($config.ImportNode($source.configuration[$section],$true))}
    foreach($entry in $source.configuration.appSettings.add | Where-Object key -in @('DbType','LoginTimeOut','ValideCodeKey')){[void]$settings.AppendChild($config.ImportNode($entry,$true))}
    $schema='mth_laba_capacity_'+[DateTime]::UtcNow.ToString('yyyyMMddHHmmss')
    $config.configuration.connectionStrings.add.connectionString="Server=127.0.0.1;Port=33406;Database=$schema;Uid=root;Pwd=;CharSet=utf8mb4;SslMode=None;"
    foreach($pair in @(@('pipeName','isolated_'+$schema),@('serverName','.'),@('repoRoot',$root),@('logSwitch','false'))) {
        $entry=$config.CreateElement('add');$entry.SetAttribute('key',$pair[0]);$entry.SetAttribute('value',$pair[1]);[void]$settings.AppendChild($entry)
    }
    $exe=Join-Path $runtime 'LabaWeightCapacityValidation.exe'
    $config.Save($exe+'.config')
    $refs=@('System.dll','System.Core.dll','System.Configuration.dll','System.Data.dll','System.Web.dll','System.Xml.dll','System.Web.Extensions.dll')
    $refs+=@('EntityFramework.dll','MySql.Data.dll','Newtonsoft.Json.dll','System.Web.Mvc.dll','YYT.BLL.dll','YYT.Common.dll','YYT.Entity.dll','YYT.Web.dll') | ForEach-Object {Join-Path $runtime $_}
    & 'C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe' /nologo /langversion:5 /target:exe "/out:$exe" @($refs | ForEach-Object {"/r:$_"}) (Join-Path $PSScriptRoot 'LabaWeightCapacityValidation.cs') (Join-Path $PSScriptRoot 'SqlSnapshot.cs')
    if($LASTEXITCODE -ne 0){throw 'Validation compilation failed'}
    & $exe
    if($LASTEXITCODE -ne 0){throw 'Validation failed'}
} finally {
    if(!$proc.HasExited){Stop-Process -Id $proc.Id; $proc.WaitForExit()}
    $timer.Stop();Write-Output ('ELAPSED_SECONDS='+$timer.Elapsed.TotalSeconds.ToString('F2'))
}
