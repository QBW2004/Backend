param([string]$BinPath, [string]$Variant = 'fixed', [string]$OutputPath)
$ErrorActionPreference = 'Stop'
$root = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..'))
if (!$BinPath) { $BinPath = Join-Path $root 'TTY.Web\bin' }
$out = if ($OutputPath) { [IO.Path]::GetFullPath($OutputPath) } else { Join-Path $root '.build\rabbit-remaining-validation' }
$runtime = Join-Path $out $Variant
$data = Join-Path $out 'mysql-data'
$mysql = 'E:\MTH\mysql57\mysql-5.7.44-winx64\bin\mysqld.exe'
New-Item -ItemType Directory -Path $runtime,$data -Force | Out-Null
if (Get-NetTCPConnection -LocalPort 33416 -State Listen -ErrorAction SilentlyContinue) { throw 'Test port 33416 is already in use.' }
if (!(Test-Path (Join-Path $data 'mysql'))) {
    & $mysql --no-defaults --initialize-insecure --lower_case_table_names=1 "--datadir=$data" "--log-error=$out\mysql-init.log"
    if ($LASTEXITCODE -ne 0) { throw 'MySQL initialization failed.' }
}
$proc = Start-Process -FilePath $mysql -ArgumentList @('--no-defaults',"--datadir=$data",'--lower_case_table_names=1','--port=33416','--bind-address=127.0.0.1',"--log-error=$out\mysql.log") -WindowStyle Hidden -PassThru
try {
    for($i=0;$i -lt 50;$i++) { if (Get-NetTCPConnection -LocalPort 33416 -State Listen -ErrorAction SilentlyContinue) { break }; Start-Sleep -Milliseconds 100 }
    Copy-Item -Path (Join-Path $BinPath '*.dll') -Destination $runtime
    New-Item -ItemType Directory -Path (Join-Path $runtime 'Config') -Force | Out-Null
    Copy-Item -LiteralPath (Join-Path $root 'TTY.Web\Config\MsgDefine.config') -Destination (Join-Path $runtime 'Config')
    $source=[xml](Get-Content -LiteralPath (Join-Path $root 'TTY.Web\Web.config') -Raw)
    $config=[xml]'<configuration><appSettings/><connectionStrings><add name="DbConnString" providerName="MySql.Data.MySqlClient" connectionString=""/></connectionStrings></configuration>'
    $settings=$config.SelectSingleNode('/configuration/appSettings')
    [void]$config.configuration.PrependChild($config.ImportNode($source.configuration.configSections,$true))
    foreach($section in @('runtime','entityFramework','system.data')) { [void]$config.configuration.AppendChild($config.ImportNode($source.configuration[$section],$true)) }
    foreach($entry in $source.configuration.appSettings.add | Where-Object key -in @('DbType','LoginTimeOut','ValideCodeKey')) { [void]$settings.AppendChild($config.ImportNode($entry,$true)) }
    $schema='rabbit_remaining_test_'+[DateTime]::UtcNow.ToString('yyyyMMddHHmmss')
    ($config.configuration.connectionStrings.add | Where-Object name -eq 'DbConnString').connectionString="Server=127.0.0.1;Port=33416;Database=$schema;Uid=root;Pwd=;CharSet=utf8mb4;SslMode=None;"
    foreach($pair in @(@('pipeName','rabbit_remaining_test_'+$schema),@('serverName','.'),@('logSwitch','false'))) {
        $entry=$config.CreateElement('add'); $entry.SetAttribute('key',$pair[0]); $entry.SetAttribute('value',$pair[1]); [void]$settings.AppendChild($entry)
    }
    $config.Save((Join-Path $runtime 'RabbitRemainingValidation.exe.config'))
    $refs=@('System.dll','System.Core.dll','System.Configuration.dll','System.Data.dll','System.Web.dll','System.Xml.dll','System.Web.Extensions.dll','System.Net.Http.dll')
    $refs+=@('EntityFramework.dll','MySql.Data.dll','Newtonsoft.Json.dll','System.Web.Mvc.dll','System.Web.Http.dll','YYT.BLL.dll','YYT.Common.dll','YYT.Entity.dll','YYT.Web.dll') | ForEach-Object {Join-Path $runtime $_}
    $exe=Join-Path $runtime 'RabbitRemainingValidation.exe'
    & 'C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe' /nologo /langversion:5 /target:exe "/out:$exe" @($refs | ForEach-Object {"/r:$_"}) (Join-Path $PSScriptRoot 'RabbitRemainingValidation.cs')
    if($LASTEXITCODE -ne 0) { throw 'Validation compilation failed.' }
    & $exe
    if($LASTEXITCODE -ne 0) { throw 'Validation failed.' }
} finally { if(!$proc.HasExited) { Stop-Process -Id $proc.Id; $proc.WaitForExit() } }
