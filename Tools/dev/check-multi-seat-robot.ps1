$ErrorActionPreference = 'Stop'
$root = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..'))
$out = Join-Path $root '.build\multi-seat-robot-validation'
$runtime = Join-Path $out 'runtime'
$data = Join-Path $out 'mysql-data'
$mysql = 'E:\MTH\mysql57\mysql-5.7.44-winx64\bin\mysqld.exe'
New-Item -ItemType Directory -Path $runtime,$data -Force | Out-Null
if (Get-NetTCPConnection -LocalPort 33406 -State Listen -ErrorAction SilentlyContinue) { throw 'Test port 33406 is already in use.' }
if (!(Test-Path (Join-Path $data 'mysql'))) {
    & $mysql --no-defaults --initialize-insecure "--datadir=$data" "--log-error=$out\mysql-init.log"
    if ($LASTEXITCODE -ne 0) { throw 'MySQL initialization failed.' }
}
$proc = Start-Process -FilePath $mysql -ArgumentList @('--no-defaults',"--datadir=$data",'--port=33406','--bind-address=127.0.0.1','--lower_case_table_names=1',"--log-error=$out\mysql.log") -WindowStyle Hidden -PassThru
try {
    for($i=0;$i -lt 50;$i++) { if (Get-NetTCPConnection -LocalPort 33406 -State Listen -ErrorAction SilentlyContinue) { break }; Start-Sleep -Milliseconds 100 }
    Copy-Item -Path (Join-Path $root 'TTY.Web\bin\*.dll') -Destination $runtime
    New-Item -ItemType Directory -Path (Join-Path $runtime 'Config') -Force | Out-Null
    Copy-Item -LiteralPath (Join-Path $root 'TTY.Web\Config\MsgDefine.config') -Destination (Join-Path $runtime 'Config')
    $source=[xml](Get-Content -LiteralPath (Join-Path $root 'TTY.Web\Web.config') -Raw)
    $config=[xml]'<configuration><appSettings/><connectionStrings><add name="DbConnString" providerName="MySql.Data.MySqlClient" connectionString=""/></connectionStrings></configuration>'
    $settings=$config.SelectSingleNode('/configuration/appSettings')
    [void]$config.configuration.PrependChild($config.ImportNode($source.configuration.configSections,$true))
    foreach($section in @('runtime','entityFramework','system.data')){[void]$config.configuration.AppendChild($config.ImportNode($source.configuration[$section],$true))}
    foreach($entry in $source.configuration.appSettings.add | Where-Object key -in @('DbType','LoginTimeOut','ValideCodeKey')){[void]$settings.AppendChild($config.ImportNode($entry,$true))}
    $schema='mth_robot_limit_validation_'+[DateTime]::UtcNow.ToString('yyyyMMddHHmmss')
    ($config.configuration.connectionStrings.add | Where-Object name -eq 'DbConnString').connectionString="Server=127.0.0.1;Port=33406;Database=$schema;Uid=root;Pwd=;CharSet=utf8mb4;SslMode=None;Allow User Variables=True;"
    foreach($pair in @(@('pipeName','robot_limit_validation_'+$schema),@('serverName','.'),@('repoRoot',$root),@('logSwitch','false'))) {
        $entry=$settings.add | Where-Object key -eq $pair[0]
        if(!$entry){$entry=$config.CreateElement('add');$entry.SetAttribute('key',$pair[0]);[void]$settings.AppendChild($entry)}
        $entry.SetAttribute('value',$pair[1])
    }
    $config.Save((Join-Path $runtime 'MultiSeatRobotValidation.exe.config'))
    $refs=@('System.dll','System.Core.dll','System.Configuration.dll','System.Data.dll','System.Web.dll','System.Xml.dll','System.Web.Extensions.dll')
    $refs+=@('EntityFramework.dll','MySql.Data.dll','Newtonsoft.Json.dll','System.Web.Mvc.dll','YYT.BLL.dll','YYT.Common.dll','YYT.Entity.dll','YYT.Web.dll') | ForEach-Object {Join-Path $runtime $_}
    $exe=Join-Path $runtime 'MultiSeatRobotValidation.exe'
    & 'C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe' /nologo /langversion:5 /target:exe "/out:$exe" @($refs | ForEach-Object {"/r:$_"}) (Join-Path $PSScriptRoot 'MultiSeatRobotValidation.cs') (Join-Path $PSScriptRoot 'SqlSnapshot.cs')
    if($LASTEXITCODE -ne 0){throw 'Validation compilation failed.'}
    & $exe
    if($LASTEXITCODE -ne 0){throw 'Validation failed.'}
} finally { if(!$proc.HasExited){ Stop-Process -Id $proc.Id; $proc.WaitForExit() } }
