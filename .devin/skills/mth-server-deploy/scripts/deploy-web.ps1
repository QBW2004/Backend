<#
.SYNOPSIS
    MTH-Backend (TTY.Web) 服务器部署脚本。

.DESCRIPTION
    把打包好的 TTY.Web 文件夹部署为 IIS 站点。默认行为: 检测当前部署/IIS
    状态并打印, 如果需要部署会询问 "是否现在部署? (Y/N)", 不需要额外的
    子命令。跟 env-check.ps1 / fix-legacy-ucrt.ps1 是同一套风格。

    典型使用方式(你本地的习惯是把整份 TTY.Web 文件夹打包上传, 而不是走
    VS 的"发布"流程单独产出精简站点), 因此本脚本的输入是:
      - 一个已经在服务器上解压好的 TTY.Web 文件夹(源码+bin+Views+Web.config
        全部在一起), 或者
      - 一个包含 TTY.Web 文件夹的 .zip 包

    部署目标固定为 C:\Backend, 由 IIS 的 "Default Web Site" 指向它(这台
    服务器上的 Default Web Site 目前只是默认欢迎页, 没有真实内容, 复用它
    比新建站点抢占端口风险更小)。

    客户端(游戏端/回调接口)访问的是 8081 端口(历史上这套系统就固定用
    8081, 参考 Web.config 里 PayOrderNotify/DPayOrderNotify 回调地址和
    历史数据里的图片外链, 都是 :8081), 因此本脚本默认给站点新增一个
    8081 端口绑定, 并放行防火墙。这台服务器目前 80 端口已经有绑定(IIS
    默认自带), 脚本不会动它, 只是新增 8081, 两个端口会同时可用。

    执行步骤:
      1. 检测: IIS/WebAdministration 模块、MySQL 3306、.NET v4.5 应用池、
         C:\Backend 是否已存在旧版本、Web.config 里的数据库连接串、站点
         是否已绑定目标端口、防火墙是否已放行该端口
      2. 如果 C:\Backend 已存在旧版本, 备份到 C:\Backend_backup_<时间戳>
         (不会自动删除旧备份, 你需要自己清理)
      3. 部署新内容到 C:\Backend(从 -SourcePath 指定的 zip 或文件夹)
      4. 确保 IIS 应用池运行时版本正确(v4.0, 64 位, Integrated 模式 ——
         这台应用同时依赖 x86/x64 两份 SQLite.Interop.dll, 64 位应用池会
         自动挑 x64 那份, 不需要也不应该开 32 位兼容模式)
      5. 把 "Default Web Site" 的物理路径指向 C:\Backend, 补上目标端口的
         绑定(如果还没有), 放行防火墙, 回收应用池
      6. 用真实 HTTP 请求探测站点是否响应(不只是看进程/端口, 要看页面
         真的能返回内容)

.PARAMETER SourcePath
    要部署的内容来源: 可以是一个 .zip 文件, 也可以是一个已经解压好的文件夹。
    两种情况都要求其中直接就是站点内容(即 SourcePath 本身或 zip 解压后的
    唯一顶层目录下能找到 Web.config 和 bin\YYT.Web.dll)。

.PARAMETER TargetPath
    部署目标路径, 默认 C:\Backend。

.PARAMETER SiteName
    要指向部署内容的 IIS 站点名, 默认 "Default Web Site"。

.PARAMETER Port
    客户端访问的端口, 默认 8081(这套系统历史上固定用这个端口)。
    脚本会给 -SiteName 指定的站点新增这个端口的绑定(不会移除已有的
    80 端口绑定), 并放行 Windows 防火墙。

.PARAMETER CheckOnly
    仅检测当前状态并输出报告, 不询问、不做任何改动。

.PARAMETER Yes
    跳过"是否现在部署"的询问, 直接执行(仍会先打印将要做的改动)。

.PARAMETER NoBackup
    跳过旧版本备份步骤(默认会备份, 除非 C:\Backend 不存在)。

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File deploy.ps1 -CheckOnly
    # 仅检测当前 IIS / 部署状态, 不做任何改动
.EXAMPLE
    powershell -ExecutionPolicy Bypass -File deploy.ps1 -SourcePath C:\Users\Administrator\Desktop\TTY.Web.zip
    # 检测后询问是否部署, 确认后备份旧版本并部署新内容, 绑定 8081 端口
.EXAMPLE
    powershell -ExecutionPolicy Bypass -File deploy.ps1 -SourcePath C:\Users\Administrator\Desktop\TTY.Web.zip -Yes
    # 跳过确认直接部署(无人值守)
#>
param(
    [string]$SourcePath,
    [string]$TargetPath = 'C:\Backend',
    [string]$SiteName = 'Default Web Site',
    [int]$Port = 8081,
    [switch]$CheckOnly,
    [switch]$Yes,
    [switch]$NoBackup
)

$ErrorActionPreference = 'Stop'

# ============================================================
# 0. 逃离 WOW64: 站点/应用池管理(WebAdministration 模块)在 32 位
#    进程里可能不可用或返回错误结果。跟 env-check.ps1 用同样的手法。
# ============================================================
if ([Environment]::Is64BitOperatingSystem -and -not [Environment]::Is64BitProcess) {
    $sysnativePwsh = Join-Path $env:WINDIR 'Sysnative\WindowsPowerShell\v1.0\powershell.exe'
    if (Test-Path $sysnativePwsh) {
        $passArgs = @('-TargetPath', $TargetPath, '-SiteName', $SiteName, '-Port', $Port)
        if ($SourcePath) { $passArgs += @('-SourcePath', $SourcePath) }
        if ($CheckOnly) { $passArgs += '-CheckOnly' }
        if ($Yes) { $passArgs += '-Yes' }
        if ($NoBackup) { $passArgs += '-NoBackup' }
        & $sysnativePwsh -NoProfile -ExecutionPolicy Bypass -File $PSCommandPath @passArgs
        exit $LASTEXITCODE
    } else {
        Write-Warning '未找到 Sysnative 64 位 PowerShell, 继续以 32 位模式运行(IIS 检测可能不准确)。'
    }
}

# ============================================================
# 辅助函数
# ============================================================
function Test-IsAdmin {
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    $p = New-Object Security.Principal.WindowsPrincipal($id)
    return $p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Test-TcpPort {
    param([string]$ComputerName = '127.0.0.1', [int]$Port, [int]$TimeoutMs = 1000)
    try {
        $client = New-Object System.Net.Sockets.TcpClient
        $iar = $client.BeginConnect($ComputerName, $Port, $null, $null)
        $ok = $iar.AsyncWaitHandle.WaitOne($TimeoutMs, $false) -and $client.Connected
        $client.Close()
        return [bool]$ok
    } catch { return $false }
}

function Get-SiteContentInfo {
    # 从 Web.config 里读出关键信息, 用于检测阶段展示、部署后核对。
    param([string]$WebRoot)
    $info = [PSCustomObject]@{
        HasWebConfig  = $false
        HasWebDll     = $false
        DbConnection  = $null
        WebVersion    = $null
    }
    $cfgPath = Join-Path $WebRoot 'Web.config'
    if (Test-Path $cfgPath) {
        $info.HasWebConfig = $true
        try {
            [xml]$x = Get-Content $cfgPath -Raw
            $conn = @($x.configuration.connectionStrings.add) | Where-Object { $_.name -eq 'DbConnString' } | Select-Object -First 1
            if ($conn) { $info.DbConnection = $conn.connectionString }
            $ver = @($x.configuration.appSettings.add) | Where-Object { $_.key -eq 'WebVer' } | Select-Object -First 1
            if ($ver) { $info.WebVersion = $ver.value }
        } catch {}
    }
    $info.HasWebDll = Test-Path (Join-Path $WebRoot 'bin\YYT.Web.dll')
    return $info
}

function Resolve-SourceContentDir {
    # SourcePath 可能是 zip 或文件夹, 也可能压缩包里多包了一层目录
    # (例如解压出 TTY.Web\TTY.Web\Web.config 这种)。这里统一展开到
    # 一个临时目录, 返回真正包含 Web.config 的那一层路径。
    param([string]$SourcePath)

    if (-not (Test-Path $SourcePath)) {
        throw "找不到 -SourcePath 指定的路径: $SourcePath"
    }

    $workDir = $SourcePath
    $isTempExtract = $false
    if ((Get-Item $SourcePath).PSIsContainer -eq $false) {
        if ($SourcePath -notmatch '\.zip$') {
            throw "SourcePath 是一个文件但不是 .zip: $SourcePath"
        }
        $extractDir = Join-Path $env:TEMP "deploy_extract_$(Get-Date -Format 'yyyyMMddHHmmss')"
        New-Item -ItemType Directory -Path $extractDir -Force | Out-Null
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        [System.IO.Compression.ZipFile]::ExtractToDirectory($SourcePath, $extractDir)
        $workDir = $extractDir
        $isTempExtract = $true
    }

    # 直接在当前层找, 找不到就往下钻一层(最多两层, 避免死循环)
    for ($depth = 0; $depth -lt 3; $depth++) {
        if (Test-Path (Join-Path $workDir 'Web.config')) {
            return @{ Path = $workDir; IsTemp = $isTempExtract; TempRoot = $extractDir }
        }
        $subDirs = Get-ChildItem $workDir -Directory -ErrorAction SilentlyContinue
        if ($subDirs.Count -eq 1) {
            $workDir = $subDirs[0].FullName
        } else {
            break
        }
    }

    throw "在 $SourcePath 中(包括子目录)找不到 Web.config, 请确认打包内容正确。"
}

# ============================================================
# 检测函数
# ============================================================
function Test-WebAdminModule {
    try {
        Import-Module WebAdministration -ErrorAction Stop
        return @{ Ok = $true; Detail = 'WebAdministration 模块可用' }
    } catch {
        return @{ Ok = $false; Detail = "加载失败: $($_.Exception.Message)" }
    }
}

function Test-AppPoolRuntime {
    param([string]$SiteName)
    try {
        Import-Module WebAdministration -ErrorAction Stop
        $site = Get-Website -Name $SiteName -ErrorAction Stop
        $poolName = $site.applicationPool
        $pool = Get-Item "IIS:\AppPools\$poolName" -ErrorAction Stop
        $bitness = if ($pool.enable32BitAppOnWin64) { '32 位' } else { '64 位' }
        $ok = ($pool.managedRuntimeVersion -eq 'v4.0') -and (-not $pool.enable32BitAppOnWin64)
        return @{
            Ok     = $ok
            Detail = "站点 [$SiteName] 应用池 [$poolName]: 运行时 $($pool.managedRuntimeVersion), $bitness, $($pool.state)"
            PoolName = $poolName
        }
    } catch {
        return @{ Ok = $false; Detail = "检测失败: $($_.Exception.Message)" }
    }
}

function Test-ExistingDeployment {
    param([string]$TargetPath)
    if (-not (Test-Path $TargetPath)) {
        return @{ Ok = $true; Detail = "$TargetPath 不存在(全新部署)"; Exists = $false }
    }
    $info = Get-SiteContentInfo -WebRoot $TargetPath
    if ($info.HasWebDll) {
        $ver = if ($info.WebVersion) { "版本 $($info.WebVersion)" } else { '版本未知' }
        return @{ Ok = $true; Detail = "已存在部署, $ver"; Exists = $true; Info = $info }
    }
    return @{ Ok = $true; Detail = "$TargetPath 存在但内容不完整(缺 bin\YYT.Web.dll)"; Exists = $true; Info = $info }
}

function Test-SiteBinding {
    param([string]$SiteName, [int]$Port)
    try {
        Import-Module WebAdministration -ErrorAction Stop
        $site = Get-Website -Name $SiteName -ErrorAction Stop
        $bindings = $site.bindings.Collection | ForEach-Object { $_.bindingInformation }
        $hasPort = $bindings | Where-Object { $_ -match ":$Port`:" }
        if ($hasPort) {
            return @{ Ok = $true; Detail = "已绑定端口 $Port" }
        }
        return @{ Ok = $false; Detail = "尚未绑定端口 $Port(当前绑定: $($bindings -join ', '))" }
    } catch {
        return @{ Ok = $false; Detail = "检测失败: $($_.Exception.Message)" }
    }
}

function Test-FirewallPort {
    param([int]$Port)
    try {
        $rules = Get-NetFirewallRule -Direction Inbound -Action Allow -Enabled True -ErrorAction Stop
        foreach ($rule in $rules) {
            $filter = $rule | Get-NetFirewallPortFilter -ErrorAction SilentlyContinue
            if ($filter -and ($filter.LocalPort -contains "$Port")) {
                return @{ Ok = $true; Detail = "端口 $Port 已放行(规则: $($rule.DisplayName))" }
            }
        }
    } catch {
        return @{ Ok = $false; Detail = "防火墙查询失败: $($_.Exception.Message)" }
    }
    return @{ Ok = $false; Detail = "未找到放行端口 $Port 的入站规则" }
}

function Test-SiteReachable {
    # 注意: ASP.NET MVC 应用首次请求需要 JIT 编译整个站点 + 初始化连接池,
    # 刚回收完应用池之后第一次探测经常要好几秒到十几秒才有响应, 不是
    # 部署失败。因此这里给较长的单次超时, 并在超时/失败时重试几次
    # (每次间隔递增), 而不是探测一次就判定"无响应"。
    param([int]$Port = 80, [string]$Path = '/', [int]$Retries = 4, [int]$TimeoutMs = 20000)
    for ($i = 1; $i -le $Retries; $i++) {
        try {
            $req = [System.Net.HttpWebRequest]::Create("http://127.0.0.1:$Port$Path")
            $req.Timeout = $TimeoutMs
            $req.Method = 'GET'
            $resp = $req.GetResponse()
            $code = [int]$resp.StatusCode
            $resp.Close()
            return @{ Ok = $true; Detail = "HTTP $code" }
        } catch [System.Net.WebException] {
            if ($_.Exception.Response) {
                $code = [int]$_.Exception.Response.StatusCode
                # 4xx/5xx 说明 IIS/应用已经在处理请求(能返回状态码), 只是
                # 具体路由 404 或应用报错, 这跟"完全连不上"是两种不同的
                # 信号, 判定为可达, 报告里带上状态码方便你自行判断。
                return @{ Ok = $true; Detail = "HTTP $code(有响应, 具体页面请自行确认)" }
            }
            if ($i -eq $Retries) { return @{ Ok = $false; Detail = "无响应(重试 $Retries 次后仍失败): $($_.Exception.Message)" } }
            Start-Sleep -Seconds (2 * $i)
        } catch {
            if ($i -eq $Retries) { return @{ Ok = $false; Detail = "无响应(重试 $Retries 次后仍失败): $($_.Exception.Message)" } }
            Start-Sleep -Seconds (2 * $i)
        }
    }
}

# ============================================================
# 部署函数
# ============================================================
function Backup-ExistingDeployment {
    param([string]$TargetPath)
    $backupPath = "$TargetPath`_backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
    Write-Host "  备份现有内容到 $backupPath ..." -ForegroundColor DarkGray
    Copy-Item -Path $TargetPath -Destination $backupPath -Recurse -Force
    return $backupPath
}

function Publish-Content {
    param([string]$ContentDir, [string]$TargetPath)
    if (-not (Test-Path $TargetPath)) {
        New-Item -ItemType Directory -Path $TargetPath -Force | Out-Null
    }
    Write-Host "  复制内容到 $TargetPath ..." -ForegroundColor DarkGray
    # robocopy /MIR 会把目标目录同步成和源一致(包括删除目标里源没有的
    # 文件), 比 Copy-Item 更适合"整份替换"场景, 且对大量小文件更快。
    # /XD 排除运行时会自己生成、不该被覆盖/清空的目录。
    $excludeDirs = @('App_Data', 'Logs', 'Upload')
    $xdArgs = @()
    foreach ($d in $excludeDirs) { $xdArgs += @('/XD', (Join-Path $TargetPath $d)) }
    $robocopyArgs = @($ContentDir, $TargetPath, '/E', '/NFL', '/NDL', '/NP', '/R:2', '/W:2') + $xdArgs
    & robocopy @robocopyArgs | Out-Null
    # robocopy 退出码 0-7 都算成功(8+ 才是真正失败), 这是它的既定行为。
    if ($LASTEXITCODE -ge 8) {
        throw "robocopy 复制失败, 退出码 $LASTEXITCODE"
    }
}

function Set-AppPoolRuntime {
    param([string]$PoolName)
    Import-Module WebAdministration -ErrorAction Stop
    Set-ItemProperty "IIS:\AppPools\$PoolName" -Name managedRuntimeVersion -Value 'v4.0'
    # 显式设为 64 位(不开 32 位兼容)。这个应用同时打包了 x86/x64 两份
    # SQLite.Interop.dll, 64 位应用池会自动加载 x64 那份, 不需要也不该
    # 开 enable32BitAppOnWin64, 否则会去找 x86 版本, 尽管这份也存在,
    # 但整个进程模型会变成 32 位, 与其他组件(MySQL Connector 等)的
    # 假设不一致。
    Set-ItemProperty "IIS:\AppPools\$PoolName" -Name enable32BitAppOnWin64 -Value $false
}

function Set-SitePhysicalPath {
    param([string]$SiteName, [string]$TargetPath)
    Import-Module WebAdministration -ErrorAction Stop
    Set-ItemProperty "IIS:\Sites\$SiteName" -Name physicalPath -Value $TargetPath
}

function Add-SiteBinding {
    # 新增一个端口绑定, 不动已有的绑定(比如 IIS 默认自带的 80)。
    param([string]$SiteName, [int]$Port)
    Import-Module WebAdministration -ErrorAction Stop
    $existing = Test-SiteBinding -SiteName $SiteName -Port $Port
    if ($existing.Ok) { return }
    New-WebBinding -Name $SiteName -Protocol http -Port $Port -IPAddress '*'
}

function Add-FirewallPort {
    param([int]$Port)
    if ((Test-FirewallPort -Port $Port).Ok) { return }
    New-NetFirewallRule -DisplayName "MTH-Backend HTTP $Port" -Direction Inbound -Protocol TCP -LocalPort $Port -Action Allow | Out-Null
}

function Restart-AppPool {
    param([string]$PoolName)
    Import-Module WebAdministration -ErrorAction Stop
    Restart-WebAppPool -Name $PoolName
}

# ============================================================
# 主流程
# ============================================================
Write-Host '============================================================'
Write-Host '  MTH-Backend 部署检测报告'
Write-Host "  时间: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')   主机: $env:COMPUTERNAME"
Write-Host '============================================================'
Write-Host ''

$isAdmin = Test-IsAdmin
if (-not $isAdmin) {
    Write-Host '[WARN] 当前非管理员权限, 无法执行部署, 请以管理员身份重新运行。' -ForegroundColor Yellow
}

$checks = [ordered]@{
    'WebAdministration 模块' = (Test-WebAdminModule)
    "应用池运行时($SiteName)" = (Test-AppPoolRuntime -SiteName $SiteName)
    "站点端口绑定($Port)"     = (Test-SiteBinding -SiteName $SiteName -Port $Port)
    "防火墙端口($Port)"       = (Test-FirewallPort -Port $Port)
    'MySQL 3306'             = (@{ Ok = (Test-TcpPort -Port 3306); Detail = if (Test-TcpPort -Port 3306) { '端口可连接' } else { '未监听, 部署后应用会连不上数据库' } })
    "现有部署($TargetPath)"   = (Test-ExistingDeployment -TargetPath $TargetPath)
    '站点当前可达性'          = (Test-SiteReachable -Port $Port)
}

foreach ($name in $checks.Keys) {
    $r = $checks[$name]
    $tag = if ($r.Ok) { '[OK]  ' } else { '[FAIL]' }
    $color = if ($r.Ok) { 'Green' } else { 'Red' }
    Write-Host "$tag $name : $($r.Detail)" -ForegroundColor $color
}

Write-Host ''

if ($CheckOnly) {
    Write-Host '当前为仅检测模式(-CheckOnly), 未做任何改动。' -ForegroundColor Yellow
    exit 0
}

if (-not $isAdmin) {
    exit 1
}

if (-not $SourcePath) {
    Write-Host '[ABORT] 未指定 -SourcePath, 不知道要部署什么内容, 已停止。' -ForegroundColor Red
    Write-Host '        用法: deploy.bat "C:\Users\Administrator\Desktop\TTY.Web.zip"' -ForegroundColor Yellow
    exit 1
}

Write-Host "解析部署来源: $SourcePath ..." -ForegroundColor Cyan
$resolved = Resolve-SourceContentDir -SourcePath $SourcePath
$contentDir = $resolved.Path
$newInfo = Get-SiteContentInfo -WebRoot $contentDir
if (-not $newInfo.HasWebDll) {
    Write-Host "[ABORT] $contentDir 下找不到 bin\YYT.Web.dll, 这不像是一份完整的编译产物, 已停止。" -ForegroundColor Red
    if ($resolved.IsTemp) { Remove-Item $resolved.TempRoot -Recurse -Force -ErrorAction SilentlyContinue }
    exit 1
}

Write-Host ''
Write-Host '即将执行以下操作:' -ForegroundColor Yellow
Write-Host "  1. 来源: $contentDir $(if ($newInfo.WebVersion) { "(WebVer=$($newInfo.WebVersion))" })"
$existingCheck = $checks["现有部署($TargetPath)"]
if ($existingCheck.Exists -and -not $NoBackup) {
    Write-Host "  2. 备份现有 $TargetPath 到 ${TargetPath}_backup_<时间戳>"
    Write-Host "  3. 用新内容覆盖 $TargetPath(保留 App_Data/Logs/Upload 目录不被清空)"
} else {
    Write-Host "  2. 部署到 $TargetPath(保留 App_Data/Logs/Upload 目录不被清空)"
}
Write-Host "  4. 确认 IIS 站点 [$SiteName] 应用池运行时为 v4.0 / 64 位"
Write-Host "  5. 把站点 [$SiteName] 物理路径指向 $TargetPath"
if (-not $checks["站点端口绑定($Port)"].Ok) {
    Write-Host "  6. 给站点 [$SiteName] 新增端口 $Port 绑定(不影响已有的 80 端口)"
}
if (-not $checks["防火墙端口($Port)"].Ok) {
    Write-Host "  7. 放行 Windows 防火墙入站端口 $Port"
}
Write-Host '  8. 回收应用池'
Write-Host "  9. 用 HTTP 请求(端口 $Port)验证站点是否响应"
Write-Host ''

if (-not $Yes) {
    if (-not [Environment]::UserInteractive) {
        Write-Host '非交互式会话且未指定 -Yes, 不会询问, 已停止(未做任何改动)。' -ForegroundColor DarkGray
        if ($resolved.IsTemp) { Remove-Item $resolved.TempRoot -Recurse -Force -ErrorAction SilentlyContinue }
        exit 1
    }
    $answer = Read-Host '确认执行以上部署操作吗? (Y/N)'
    if ($answer -notmatch '^[Yy]') {
        Write-Host '已取消, 未对系统做任何改动。' -ForegroundColor DarkGray
        if ($resolved.IsTemp) { Remove-Item $resolved.TempRoot -Recurse -Force -ErrorAction SilentlyContinue }
        exit 1
    }
}

$deployFailed = $false
$firewallOpened = $false
try {
    if ($existingCheck.Exists -and -not $NoBackup) {
        $backupPath = Backup-ExistingDeployment -TargetPath $TargetPath
        Write-Host "  已备份到: $backupPath" -ForegroundColor Green
    }

    Publish-Content -ContentDir $contentDir -TargetPath $TargetPath

    $poolCheck = $checks["应用池运行时($SiteName)"]
    if ($poolCheck.PoolName) {
        Write-Host "  配置应用池 [$($poolCheck.PoolName)] ..." -ForegroundColor DarkGray
        Set-AppPoolRuntime -PoolName $poolCheck.PoolName
    }

    Write-Host "  设置站点 [$SiteName] 物理路径 ..." -ForegroundColor DarkGray
    Set-SitePhysicalPath -SiteName $SiteName -TargetPath $TargetPath

    if (-not $checks["站点端口绑定($Port)"].Ok) {
        Write-Host "  新增端口 $Port 绑定 ..." -ForegroundColor DarkGray
        Add-SiteBinding -SiteName $SiteName -Port $Port
    }

    if (-not $checks["防火墙端口($Port)"].Ok) {
        Write-Host "  放行防火墙端口 $Port ..." -ForegroundColor DarkGray
        Add-FirewallPort -Port $Port
        $firewallOpened = $true
    }

    if ($poolCheck.PoolName) {
        Write-Host "  回收应用池 [$($poolCheck.PoolName)] ..." -ForegroundColor DarkGray
        Restart-AppPool -PoolName $poolCheck.PoolName
    }

    Start-Sleep -Seconds 3
} catch {
    Write-Host "[FAIL] 部署过程出错: $($_.Exception.Message)" -ForegroundColor Red
    $deployFailed = $true
} finally {
    if ($resolved.IsTemp) { Remove-Item $resolved.TempRoot -Recurse -Force -ErrorAction SilentlyContinue }
}

Write-Host ''
Write-Host '============================================================'
if ($deployFailed) {
    Write-Host '结论: 部署过程出错, 请查看上方日志。' -ForegroundColor Red
    Write-Host '============================================================'
    exit 1
}

$reachable = Test-SiteReachable -Port $Port
Write-Host "部署后站点可达性(端口 $Port) : $($reachable.Detail)" -ForegroundColor $(if ($reachable.Ok) { 'Green' } else { 'Red' })

$dbInfo = Get-SiteContentInfo -WebRoot $TargetPath
if ($dbInfo.DbConnection) {
    Write-Host "数据库连接串(来自部署内容的 Web.config): $($dbInfo.DbConnection)" -ForegroundColor DarkGray
}

if ($reachable.Ok) {
    Write-Host '结论: 部署完成, 站点已响应 HTTP 请求。' -ForegroundColor Green
    Write-Host ''
    if ($firewallOpened) {
        Write-Host "[安全提示] 刚新增开放了防火墙入站端口 $Port。这台服务器现在 80 和 $Port" -ForegroundColor Yellow
        Write-Host '           两个端口都对公网开放, MTH-Backend 后台可以被公网访问到。' -ForegroundColor Yellow
        Write-Host '           请确认管理员账号密码、验证码等已经妥善配置, 不要让后台裸奔在公网上。' -ForegroundColor Yellow
    } else {
        Write-Host "[安全提示] 端口 $Port(以及 80)已对公网开放, MTH-Backend 后台可以被公网访问到。" -ForegroundColor Yellow
        Write-Host '           请确认管理员账号密码、验证码等已经妥善配置, 不要让后台裸奔在公网上。' -ForegroundColor Yellow
    }
    exit 0
} else {
    Write-Host '结论: 部署已执行, 但站点目前无法响应 HTTP 请求, 请检查应用池状态和' -ForegroundColor Red
    Write-Host "      Windows 事件日志(应用程序日志)排查启动错误。" -ForegroundColor Red
    exit 1
}
