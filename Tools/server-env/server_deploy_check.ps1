<#
.SYNOPSIS
    一键收集 MTH 线上服务器部署情况（后台 Web + 中心服），供远程排查使用。
    在服务器上以管理员身份运行：
        powershell -ExecutionPolicy Bypass -File server_deploy_check.ps1
    运行结束后把控制台输出（或桌面生成的 server_info.txt）贴回给我。
#>
$ErrorActionPreference = 'SilentlyContinue'
$out = New-Object System.Collections.ArrayList

function Add-Out([string]$s) { [void]$out.Add($s) }

Add-Out ("===== 0. TIME =====" + (Get-Date).ToString('yyyy-MM-dd HH:mm:ss'))
Add-Out ("HOSTNAME: " + $env:COMPUTERNAME)
Add-Out ("OS: " + [System.Environment]::OSVersion.VersionString)

# ===== 1. IIS 站点与应用池 =====
Add-Out ""
Add-Out "===== 1. IIS SITES / APP POOLS ====="
Import-Module WebAdministration -ErrorAction SilentlyContinue
if (Get-Command Get-WebSite -ErrorAction SilentlyContinue) {
    Add-Out (Get-WebSite | Select-Object Name, State, PhysicalPath | Format-Table -AutoSize | Out-String)
    Add-Out (Get-ChildItem IIS:\AppPools | Select-Object Name, State | Format-Table -AutoSize | Out-String)
} else {
    Add-Out "WebAdministration module NOT available. W3SVC service:"
    Add-Out (Get-Service -Name W3SVC -ErrorAction SilentlyContinue | Format-Table -AutoSize | Out-String)
}

# ===== 2. 关键进程 =====
Add-Out ""
Add-Out "===== 2. PROCESSES (w3wp / center / manager / mysql / nginx) ====="
Add-Out (Get-Process -Name w3wp, ServerCenterNew, ServerManager, mysqld, nginx -ErrorAction SilentlyContinue |
    Select-Object ProcessName, Id, Path, StartTime | Format-Table -AutoSize | Out-String)

# ===== 3. 后台 Web 部署目录 =====
Add-Out ""
Add-Out "===== 3. BACKEND WEB DEPLOY DIR ====="
$webDir = $null
if (Get-Command Get-WebSite -ErrorAction SilentlyContinue) {
    foreach ($p in ((Get-WebSite).PhysicalPath)) {
        if (Test-Path (Join-Path $p "bin\YYT.Web.dll")) { $webDir = $p; break }
    }
}
if (-not $webDir) {
    foreach ($p in @("C:\inetpub\wwwroot", "D:\Project\Web", "D:\workspace\Web", "E:\Project\Web", "D:\web", "E:\web", "C:\wwwroot")) {
        if (Test-Path (Join-Path $p "bin\YYT.Web.dll")) { $webDir = $p; break }
    }
}
if (-not $webDir) {
    $f = Get-ChildItem -Path C:\, D:\, E:\ -Filter "YYT.Web.dll" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($f) { $webDir = $f.Directory.Parent.FullName }
}
Add-Out "WebRoot: $webDir"
if ($webDir) {
    Add-Out ""
    Add-Out "--- bin\YYT*.dll timestamps ---"
    Add-Out (Get-ChildItem (Join-Path $webDir "bin\YYT*.dll") | Select-Object Name, LastWriteTime, Length | Format-Table -AutoSize | Out-String)
    Add-Out "--- Web.config key settings ---"
    $cfg = Join-Path $webDir "Web.config"
    if (Test-Path $cfg) {
        try {
            [xml]$x = Get-Content $cfg -Raw
            $x.configuration.appSettings.add | ForEach-Object {
                if ($_.key -in @('serverName', 'pipeName', 'robotPipeName', 'Timer')) {
                    Add-Out ("  {0} = {1}" -f $_.key, $_.value)
                }
            }
            $conn = @($x.configuration.connectionStrings.add) | Where-Object { $_.name -eq 'DbConnString' }
            if ($conn) { Add-Out ("  DbConnString = " + $conn.connectionString) }
        } catch { Add-Out "  (Web.config parse failed)" }
    }
}

# ===== 4. 中心服部署 =====
Add-Out ""
Add-Out "===== 4. SERVER CENTER ====="
$centerExe = Get-ChildItem -Path C:\, D:\, E:\ -Filter "ServerCenterNew.exe" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
if ($centerExe) {
    Add-Out "CenterExe: $($centerExe.FullName)"
    Add-Out (Get-Item $centerExe.FullName | Select-Object LastWriteTime, Length | Format-Table -AutoSize | Out-String)
    $cd = $centerExe.DirectoryName
    Add-Out "--- bat files in center dir ---"
    Add-Out (Get-ChildItem $cd -Filter "*.bat" | Select-Object Name | Format-Table -AutoSize | Out-String)
    Add-Out "--- recent log files in center dir (top 5) ---"
    Add-Out (Get-ChildItem $cd -Recurse -Filter "*.log" | Sort-Object LastWriteTime -Descending | Select-Object -First 5 |
        Select-Object FullName, LastWriteTime, Length | Format-Table -AutoSize | Out-String)
} else {
    Add-Out "ServerCenterNew.exe NOT found on C:/D:/E: (search may be slow / permission denied)"
}

# ===== 5. 命名管道是否存在 =====
Add-Out ""
Add-Out "===== 5. NAMED PIPE (mynamedpipe) ====="
$pipeHit = ([System.IO.Directory]::GetFiles('\\.\pipe\') | Where-Object { $_ -match 'mynamedpipe|MTH|Robot' })
if ($pipeHit) { $pipeHit | ForEach-Object { Add-Out $_ } } else { Add-Out "(no mynamedpipe / MTH pipe found)" }

# ===== 6. 中心服端口监听 =====
Add-Out ""
Add-Out "===== 6. LISTENING PORTS (8020/8021/8030/9000/3306/80/8080/443) ====="
Add-Out (netstat -ano | Select-String ':8020|:8021|:8030|:9000|:3306|:80 |:8080|:443' | Out-String)

# ===== 7. 后台日志文件（最近3个）=====
Add-Out ""
Add-Out "===== 7. RECENT BACKEND LOGS (yyt_*.log) ====="
Add-Out (Get-ChildItem -Path C:\, D:\, E:\ -Filter "yyt_*.log" -Recurse -ErrorAction SilentlyContinue |
    Sort-Object LastWriteTime -Descending | Select-Object -First 3 |
    Select-Object FullName, LastWriteTime, Length | Format-Table -AutoSize | Out-String)

$output = $out -join "`r`n"
$savePath = Join-Path ([Environment]::GetFolderPath('Desktop')) "server_info.txt"
$output | Out-File -FilePath $savePath -Encoding UTF8
Write-Host $output
Write-Host ""
Write-Host "======== 结果已保存到: $savePath ========"
