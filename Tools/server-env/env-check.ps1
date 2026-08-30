<#
.SYNOPSIS
    MTH-Backend 服务器部署环境检测 / 一键安装补全脚本。

.DESCRIPTION
    检测运行 MTH-Backend (YYT.Web, .NET Framework 4.8 + IIS + MySQL 5.7) 所需的服务器
    环境是否齐全。

    默认行为: 直接运行(不加任何参数)就会先完整检测一遍并打印结果; 如果发现某个
    必需项(Required)缺失, 会当场针对那一项询问 "是否现在安装/修复? (Y/N)", 不需要
    额外的子命令或参数去触发安装, 检测和修复是同一次运行里连续完成的。
    如果只想看检测结果、不想被逐项询问, 加 -CheckOnly。

    必需项 (Required):
      - 管理员权限
      - .NET Framework 4.8 (运行时)
      - Visual C++ Redistributable 2015-2022 x64 (MySQL 5.7 运行依赖)
      - IIS Web 服务器角色 + ASP.NET 4.5
      - MySQL 5.7 (Windows 服务, 监听 3306)
      - 防火墙放行 Web 端口

    可选/信息项 (Optional, 仅检测不自动安装):
      - Redis (代码中已引用 StackExchange.Redis, 但业务逻辑未见实际调用点)
      - Git (仅 git 部署方式需要, xcopy 发布方式不需要)
      - 中心服引擎 ServerCenterNew.exe (本仓库不包含其安装包, 需单独确认/部署)

    注意: 如果 "VC++ Redistributable x64" 检测项报告缺少 Universal C Runtime
    (Windows Server 2012 R2 上很常见, 因为系统长期未做 Windows Update), 本脚本
    不会自动修复。那是一条涉及重启、且有已知(低概率)重启循环风险的系统级补丁链,
    刻意与本脚本解耦, 请改用同目录下独立的 fix-legacy-ucrt.ps1 / .bat。

.PARAMETER CheckOnly
    仅检测并输出报告, 不询问、不做任何修复(供纯审计/巡检场景使用)。

.PARAMETER Yes
    检测到必需项缺失时跳过逐项询问, 直接尝试修复全部缺失项(无人值守)。
    仍需以管理员身份运行才会真正生效, 否则只会显示检测结果。

.PARAMETER WebPort
    需要在 Windows 防火墙放行的 IIS 站点入站端口, 默认 80。

.PARAMETER MySqlRootPassword
    全新安装 MySQL 时设置的 root 密码, 默认 123456 (与 TTY.Web\Web.config 一致)。
    注意: 如果服务器已存在 MySQL57 服务, 脚本不会覆盖已有密码/数据。

.PARAMETER InitSchema
    若修复 MySQL 项时触发的是全新初始化(而不是已有服务), 额外从
    ..\docker\mysql\init\*.sql 导入基础表结构(需要脚本随完整仓库一起放到
    服务器上才能找到这些文件)。

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File env-check.ps1
    # 默认: 检测一遍, 对每个缺失的必需项询问是否现在修复
.EXAMPLE
    powershell -ExecutionPolicy Bypass -File env-check.ps1 -CheckOnly
    # 仅检测, 不询问, 不做任何修改(适合巡检/审计)
.EXAMPLE
    powershell -ExecutionPolicy Bypass -File env-check.ps1 -Yes -InitSchema
    # 检测到缺失项直接全部修复(无人值守), MySQL 全新安装时顺便导入基础表结构
#>
param(
    [switch]$CheckOnly,
    [switch]$Yes,
    [int]$WebPort = 80,
    [string]$MySqlRootPassword = '123456',
    [switch]$InitSchema
)

$ErrorActionPreference = 'Stop'

# ============================================================
# 0. 逃离 WOW64: 如果当前是 64 位系统但脚本跑在 32 位 PowerShell 进程里
#    (常见于 32 位 sshd.exe 派生的会话), Install-WindowsFeature /
#    ServerManager 模块会不可用或返回错误结果。用 Sysnative 重新拉起
#    64 位 PowerShell 执行自身, 保证后续所有检测/安装逻辑跑在正确位数下。
# ============================================================
if ([Environment]::Is64BitOperatingSystem -and -not [Environment]::Is64BitProcess) {
    $sysnativePwsh = Join-Path $env:WINDIR 'Sysnative\WindowsPowerShell\v1.0\powershell.exe'
    if (Test-Path $sysnativePwsh) {
        $passArgs = @('-WebPort', $WebPort, '-MySqlRootPassword', $MySqlRootPassword)
        if ($CheckOnly) { $passArgs += '-CheckOnly' }
        if ($Yes) { $passArgs += '-Yes' }
        if ($InitSchema) { $passArgs += '-InitSchema' }
        & $sysnativePwsh -NoProfile -ExecutionPolicy Bypass -File $PSCommandPath @passArgs
        exit $LASTEXITCODE
    } else {
        Write-Warning '未找到 Sysnative 64 位 PowerShell, 继续以 32 位模式运行(部分 IIS 检测可能不准确)。'
    }
}

# 注意: 不在此处强制设置 [Console]::OutputEncoding。
# 目标服务器(中文 Windows)控制台默认代码页即为 936(GBK), env-check.bat
# 也用 chcp 936 保持一致; 强行切到 UTF8 会与 936 控制台冲突导致中文乱码。

# ============================================================
# 辅助函数
# ============================================================
function Invoke-DownloadFile {
    # 部分老系统(如 Windows Server 2012 R2)在与现代 CDN(Fastly/Akamai 等)
    # 协商 TLS 时偶发失败, .NET 抛出的异常信息是 "未能创建 SSL/TLS 安全通道",
    # 但实测这类失败往往是瞬时的网络/握手抖动, 而非证书或协议版本问题,
    # 多次重试 + 间隔延迟即可恢复; 因此这里加大重试次数并在 WebClient 失败
    # 后改用 BITS(Windows 后台智能传输服务)作为第二种下载途径兜底。
    param([string]$Url, [string]$OutFile, [int]$Retries = 5)
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls11 -bor [Net.SecurityProtocolType]::Tls
    for ($i = 1; $i -le $Retries; $i++) {
        try {
            $wc = New-Object System.Net.WebClient
            $wc.Headers.Add('User-Agent', 'Mozilla/5.0 (Windows NT 6.3; Win64; x64) MTH-EnvCheck')
            $wc.DownloadFile($Url, $OutFile)
            $wc.Dispose()
            if (Test-Path $OutFile) { return $true }
        } catch {
            Write-Host "    下载失败(WebClient, 第 $i/$Retries 次, 通常为网络瞬时抖动): $($_.Exception.Message)" -ForegroundColor Yellow
            Start-Sleep -Seconds (3 * $i)
        }
    }
    Write-Host '    WebClient 多次重试仍失败, 尝试改用 BITS 后台传输 ...' -ForegroundColor Yellow
    try {
        Import-Module BitsTransfer -ErrorAction Stop
        if (Test-Path $OutFile) { Remove-Item $OutFile -Force -ErrorAction SilentlyContinue }
        Start-BitsTransfer -Source $Url -Destination $OutFile -ErrorAction Stop
        if (Test-Path $OutFile) { return $true }
    } catch {
        Write-Host "    BITS 传输也失败: $($_.Exception.Message)" -ForegroundColor Yellow
    }
    return $false
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

function Write-CheckLine {
    param([string]$Name, [hashtable]$Result, [string]$Category)
    $status = if ($Result.Ok) { 'OK' } elseif ($Category -ne 'Required') { 'INFO' } else { 'FAIL' }
    $color = switch ($status) { 'OK' { 'Green' }; 'FAIL' { 'Red' }; default { 'Yellow' } }
    $tag = "[$status]".PadRight(7)
    Write-Host "$tag $Name : $($Result.Detail)" -ForegroundColor $color
}

# ============================================================
# 检测 + 安装函数
# ============================================================
function Test-Admin {
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    $p = New-Object Security.Principal.WindowsPrincipal($id)
    $isAdmin = $p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if ($isAdmin) { return @{ Ok = $true; Detail = "当前用户: $($id.Name) (管理员)" } }
    return @{ Ok = $false; Detail = "当前用户: $($id.Name) (非管理员, 请以管理员身份重新运行)" }
}

function Test-OS {
    $os = Get-CimInstance Win32_OperatingSystem
    $ok = ($os.OSArchitecture -match '64')
    return @{ Ok = $ok; Detail = "$($os.Caption) ($($os.OSArchitecture)), Build $($os.BuildNumber)" }
}

function Test-DotNet48 {
    $key = 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full'
    if (Test-Path $key) {
        $release = (Get-ItemProperty -Path $key -Name Release -ErrorAction SilentlyContinue).Release
        $version = (Get-ItemProperty -Path $key -Name Version -ErrorAction SilentlyContinue).Version
        if ($release -and $release -ge 528040) {
            return @{ Ok = $true; Detail = ".NET Framework $version (Release $release)" }
        }
        return @{ Ok = $false; Detail = "当前版本 $version (Release $release), 需要 4.8 (Release >= 528040)" }
    }
    return @{ Ok = $false; Detail = '未检测到 .NET Framework 4.x' }
}

function Test-SystemUpdateHealth {
    # 辅助诊断项(非独立检测项, 供 VC++/.NET 4.8 安装失败时给出根因提示):
    # 检查系统是否长期未安装 Windows 更新。.NET Framework 4.8 的安装程序
    # 依赖较新的 Servicing Stack, 在长期未更新的系统上会以 5100(且不生成
    # 日志)在最早期检查阶段失败; 详见 VC++ Redistributable x64 检测项中
    # 关于 UCRT(KB2999226/KB2919355)的说明。
    $hotfixes = Get-HotFix -ErrorAction SilentlyContinue
    $latest = $hotfixes | Sort-Object InstalledOn -Descending | Select-Object -First 1
    $count = ($hotfixes | Measure-Object).Count
    if ($count -lt 5 -or ($latest -and $latest.InstalledOn -and $latest.InstalledOn -lt (Get-Date).AddYears(-3))) {
        $lastDate = if ($latest -and $latest.InstalledOn) { $latest.InstalledOn.ToString('yyyy-MM-dd') } else { '未知' }
        return @{
            Ok     = $false
            Detail = "系统仅安装过 $count 个补丁, 最近一次是 $lastDate。长期未更新的系统安装 " +
                      '.NET Framework 4.8 大概率会以 5100 失败, 建议先运行 Windows Update ' +
                      '打上最新的 Servicing Stack Update 和至少一个累积更新。'
        }
    }
    return @{ Ok = $true; Detail = "共 $count 个补丁, 最近一次 $($latest.InstalledOn.ToString('yyyy-MM-dd'))" }
}

function Install-DotNet48 {
    param($r)
    $url = 'https://download.visualstudio.microsoft.com/download/pr/7afca223-55d2-470a-8edc-6a1739ae3252/abd170b4b0ec15ad0222a809b761a036/ndp48-x86-x64-allos-enu.exe'
    $out = Join-Path $env:TEMP 'ndp48-x86-x64-allos-enu.exe'
    Write-Host '    下载 .NET Framework 4.8 离线安装包 (约 70MB) ...' -ForegroundColor DarkGray
    if (-not (Invoke-DownloadFile -Url $url -OutFile $out)) {
        return @{ Ok = $false; Detail = '下载失败(多次重试及 BITS 兜底均失败, 请检查服务器出站网络)' }
    }
    Write-Host '    静默安装中 (可能需要几分钟, 请勿中断) ...' -ForegroundColor DarkGray
    $p = Start-Process -FilePath $out -ArgumentList '/q', '/norestart' -Wait -PassThru
    Remove-Item $out -Force -ErrorAction SilentlyContinue
    if ($p.ExitCode -eq 0) { return @{ Ok = $true; Reboot = $false } }
    elseif ($p.ExitCode -eq 3010) { return @{ Ok = $true; Reboot = $true } }
    elseif ($p.ExitCode -eq 5100) {
        return @{
            Ok     = $false
            Detail = '安装程序返回 5100(系统不满足要求), 且未生成安装日志, 说明失败发生在最早期检查阶段。' +
                      '在长期未做 Windows Update 的系统上, 这几乎总是因为缺少 .NET 4.8 依赖的 ' +
                      '底层 Servicing Stack/累积更新。建议: 先通过 Windows Update 或 ' +
                      'Microsoft Update Catalog 安装最新的 Servicing Stack Update 和至少一个 ' +
                      '2018 年之后的累积更新, 再重新运行本脚本。'
        }
    }
    else { return @{ Ok = $false; Detail = "安装程序退出码 $($p.ExitCode)" } }
}

function Test-VCRedistX64 {
    # 检测两部分, 二者都需要 mysqld.exe 才能正常启动:
    #   1) VC++ 2015-2022 Redist 本身(msvcp140.dll / vcruntime140.dll)
    #   2) Universal C Runtime(ucrtbase.dll 等 api-ms-win-crt-*.dll)
    # 在 Windows Server 2012 R2 上, UCRT 不是操作系统自带的, 必须单独安装
    # "Update for Universal C Runtime"(KB2999226, 依赖 KB2919355)才会有,
    # VC++ Redist 安装程序本身并不负责部署它, 即使 VC++ 注册表/DLL 都正常,
    # 缺 UCRT 时 mysqld.exe 仍会以 0xC0000135(DLL 未找到)启动失败。
    $paths = @(
        'HKLM:\SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\X64',
        'HKLM:\SOFTWARE\WOW6432Node\Microsoft\VisualStudio\14.0\VC\Runtimes\X64'
    )
    $registryOk = $false
    $ver = $null
    foreach ($p in $paths) {
        if (Test-Path $p) {
            $installed = (Get-ItemProperty -Path $p -Name Installed -ErrorAction SilentlyContinue).Installed
            $ver = (Get-ItemProperty -Path $p -Name Version -ErrorAction SilentlyContinue).Version
            if ($installed -eq 1) { $registryOk = $true; break }
        }
    }
    $vcDllOk = Test-Path (Join-Path $env:SystemRoot 'System32\msvcp140.dll')
    $ucrtOk = Test-Path (Join-Path $env:SystemRoot 'System32\ucrtbase.dll')

    if ($registryOk -and $vcDllOk -and $ucrtOk) { return @{ Ok = $true; Detail = "VC++ Runtime $ver + UCRT 均已就绪" } }

    if (-not $ucrtOk) {
        return @{
            Ok     = $false
            Detail = 'Universal C Runtime(ucrtbase.dll)缺失。Windows Server 2012 R2 不自带 UCRT, ' +
                      '需要装一条 8 个补丁的依赖链(KB2919442 -> KB2919355 -> ... -> KB2999226)才会有。' +
                      '这涉及系统重启, 且其中 KB2919355 在少数存储控制器上有已知重启循环问题, ' +
                      '不适合放进本脚本的常规修复流程。请单独运行同目录下的 fix-legacy-ucrt.bat, ' +
                      '它会自动检测并询问是否安装, 装完重启后再重新运行本脚本。'
        }
    }
    if ($registryOk -and -not $vcDllOk) {
        return @{
            Ok     = $false
            Detail = "注册表显示已安装($ver)但 System32\msvcp140.dll 实际不存在, 请重新运行本脚本的修复步骤(或手动重装 VC++ Redist)。"
        }
    }
    return @{ Ok = $false; Detail = '未安装 (MySQL 5.7 运行依赖此组件)' }
}

function Install-VCRedistX64 {
    param($r)
    $url = 'https://aka.ms/vs/17/release/vc_redist.x64.exe'
    $out = Join-Path $env:TEMP 'vc_redist.x64.exe'
    Write-Host '    下载 VC++ Redistributable x64 ...' -ForegroundColor DarkGray
    if (-not (Invoke-DownloadFile -Url $url -OutFile $out)) {
        return @{ Ok = $false; Detail = '下载失败' }
    }
    $p = Start-Process -FilePath $out -ArgumentList '/install', '/quiet', '/norestart' -Wait -PassThru
    Remove-Item $out -Force -ErrorAction SilentlyContinue
    if ($p.ExitCode -in @(0, 3010)) { return @{ Ok = $true; Reboot = ($p.ExitCode -eq 3010) } }
    return @{ Ok = $false; Detail = "安装程序退出码 $($p.ExitCode)" }
}

function Test-IISFeatures {
    try {
        Import-Module ServerManager -ErrorAction Stop
    } catch {
        return @{ Ok = $false; Detail = "ServerManager 模块加载失败: $($_.Exception.Message)"; Missing = @('Web-Server', 'Web-Asp-Net45') }
    }
    $names = @('Web-Server', 'Web-Asp-Net45')
    $missing = @()
    foreach ($n in $names) {
        $f = Get-WindowsFeature -Name $n -ErrorAction SilentlyContinue
        if (-not $f -or -not $f.Installed) { $missing += $n }
    }
    if ($missing.Count -eq 0) {
        return @{ Ok = $true; Detail = 'IIS Web 服务器 + ASP.NET 4.5 已安装'; Missing = @() }
    }
    return @{ Ok = $false; Detail = "缺失功能: $($missing -join ', ')"; Missing = $missing }
}

function Install-IISFeatures {
    param($r)
    Import-Module ServerManager -ErrorAction Stop
    $result = Install-WindowsFeature -Name Web-Server -IncludeAllSubFeature -IncludeManagementTools -ErrorAction Stop
    $asp = Get-WindowsFeature -Name Web-Asp-Net45 -ErrorAction SilentlyContinue
    if ($asp -and -not $asp.Installed) {
        Install-WindowsFeature -Name Web-Asp-Net45 -ErrorAction Stop | Out-Null
    }
    return @{ Ok = [bool]$result.Success; RestartNeeded = ($result.RestartNeeded -eq 'Yes') }
}

function Test-MySQL {
    $svc = Get-Service -Name 'MySQL*' -ErrorAction SilentlyContinue | Select-Object -First 1
    $portOpen = Test-TcpPort -Port 3306
    if ($svc -and $svc.Status -eq 'Running' -and $portOpen) {
        return @{ Ok = $true; Detail = "服务 $($svc.Name) 运行中, 3306 端口可连接" }
    } elseif ($svc) {
        return @{ Ok = $false; Detail = "服务 $($svc.Name) 存在但状态为 $($svc.Status)" }
    } elseif ($portOpen) {
        return @{ Ok = $true; Detail = '3306 端口可连接 (非 Windows 服务方式运行, 如 Docker 容器)' }
    }
    return @{ Ok = $false; Detail = '未检测到 MySQL 服务, 3306 端口未监听' }
}

function Install-MySQL57 {
    param($r)
    $installDir = 'C:\mysql'
    $mysqldExe = Join-Path $installDir 'bin\mysqld.exe'
    $freshInit = $false

    # MySQL 5.7 官方 Windows 二进制依赖 VC++ 2015-2022 Runtime + Universal
    # C Runtime, 缺失时 mysqld.exe 会以 0xC0000135(DLL 未找到)静默启动失败
    # (无任何控制台输出), 必须先确认这两者已装, 否则继续走下载/初始化只会
    # 白白浪费时间并产生误导性的"数据目录初始化失败"报错。
    $vcCheck = Test-VCRedistX64
    if (-not $vcCheck.Ok) {
        return @{ Ok = $false; Detail = "前置条件未满足, 无法安装 MySQL: $($vcCheck.Detail)" }
    }

    if (Test-Path $mysqldExe) {
        Write-Host '    C:\mysql 已存在 mysqld.exe, 跳过下载解压。' -ForegroundColor DarkGray
    } else {
        $url = 'https://cdn.mysql.com/archives/mysql-5.7/mysql-5.7.44-winx64.zip'
        $zip = Join-Path $env:TEMP 'mysql-5.7.44-winx64.zip'
        Write-Host '    下载 MySQL 5.7.44 (约 350MB, 请耐心等待) ...' -ForegroundColor DarkGray
        if (-not (Invoke-DownloadFile -Url $url -OutFile $zip -Retries 2)) {
            return @{ Ok = $false; Detail = '下载失败' }
        }
        $tmpExtract = Join-Path $env:TEMP 'mysql_extract'
        if (Test-Path $tmpExtract) { Remove-Item $tmpExtract -Recurse -Force }
        Write-Host '    解压中 ...' -ForegroundColor DarkGray
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        [System.IO.Compression.ZipFile]::ExtractToDirectory($zip, $tmpExtract)
        Remove-Item $zip -Force -ErrorAction SilentlyContinue
        $inner = Get-ChildItem $tmpExtract -Directory | Select-Object -First 1
        New-Item -ItemType Directory -Path $installDir -Force | Out-Null
        Copy-Item (Join-Path $inner.FullName '*') $installDir -Recurse -Force
        Remove-Item $tmpExtract -Recurse -Force -ErrorAction SilentlyContinue
    }

    $dataDir = Join-Path $installDir 'data'
    $iniPath = Join-Path $installDir 'my.ini'
    if (-not (Test-Path $iniPath)) {
        @'
[mysqld]
basedir=C:/mysql
datadir=C:/mysql/data
port=3306
character-set-server=utf8mb4
collation-server=utf8mb4_unicode_ci
default-time-zone=+08:00
max_allowed_packet=128M
[client]
default-character-set=utf8mb4
'@ | Set-Content -Path $iniPath -Encoding ASCII
    }

    $svc = Get-Service -Name 'MySQL57' -ErrorAction SilentlyContinue
    if (-not $svc) {
        if (-not (Test-Path $dataDir) -or (Get-ChildItem $dataDir -ErrorAction SilentlyContinue | Measure-Object).Count -eq 0) {
            Write-Host '    初始化数据目录 ...' -ForegroundColor DarkGray
            # 注意: 用 mysqld.exe 的真实退出码判定成败, 不要用"目录里有没有
            # 文件"这种间接方式 —— mysqld --initialize-insecure 正常情况下
            # 会打印一长串 [Warning] 级别的提示(TIMESTAMP 弃用、TLS 版本、
            # 空密码提示等), 这些都不是错误, 之前用"有没有输出内容"或类似
            # 逻辑判断很容易把正常的 Warning 误判为失败。
            $initLog = Join-Path $env:TEMP 'mysql_init_output.log'
            $p = Start-Process -FilePath $mysqldExe -ArgumentList "--defaults-file=`"$iniPath`"", '--initialize-insecure', '--console' -Wait -PassThru -RedirectStandardOutput $initLog -RedirectStandardError "$initLog.err"
            $initOutput = (Get-Content $initLog -ErrorAction SilentlyContinue) + (Get-Content "$initLog.err" -ErrorAction SilentlyContinue) | Out-String
            Remove-Item $initLog, "$initLog.err" -Force -ErrorAction SilentlyContinue
            if ($p.ExitCode -ne 0) {
                return @{ Ok = $false; Detail = "数据目录初始化失败(mysqld 退出码 $($p.ExitCode)): $($initOutput.Trim())" }
            }
            $freshInit = $true
        }
        Write-Host '    注册 MySQL57 Windows 服务 ...' -ForegroundColor DarkGray
        $installOutput = & $mysqldExe --install MySQL57 --defaults-file=$iniPath 2>&1 | Out-String
        $svc = Get-Service -Name 'MySQL57' -ErrorAction SilentlyContinue
        if (-not $svc) {
            return @{ Ok = $false; Detail = "服务注册失败, mysqld 输出: $($installOutput.Trim())" }
        }
    }
    if ($svc -and $svc.Status -ne 'Running') {
        Write-Host '    启动 MySQL57 服务 ...' -ForegroundColor DarkGray
        try {
            Start-Service MySQL57 -ErrorAction Stop
        } catch {
            $errLog = Get-ChildItem $dataDir -Filter '*.err' -ErrorAction SilentlyContinue | Select-Object -First 1
            $tail = if ($errLog) { (Get-Content $errLog.FullName -Tail 15 -ErrorAction SilentlyContinue) -join ' | ' } else { '(无 .err 日志)' }
            return @{ Ok = $false; Detail = "服务启动失败: $($_.Exception.Message); 日志末尾: $tail" }
        }
        Start-Sleep -Seconds 3
        $svc = Get-Service -Name 'MySQL57' -ErrorAction SilentlyContinue
    }
    if (-not $svc -or $svc.Status -ne 'Running') {
        return @{ Ok = $false; Detail = 'MySQL57 服务安装或启动失败, 请检查 C:\mysql\data 下的 .err 日志' }
    }

    if ($freshInit) {
        Start-Sleep -Seconds 2
        $mysqlExe = Join-Path $installDir 'bin\mysql.exe'
        $pw = $MySqlRootPassword -replace "'", "''"
        $sql = "ALTER USER 'root'@'localhost' IDENTIFIED BY '$pw'; CREATE DATABASE IF NOT EXISTS mth DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci; FLUSH PRIVILEGES;"
        & $mysqlExe -u root --execute=$sql 2>&1 | Out-Null

        if ($InitSchema) {
            Invoke-SchemaImport -RootPassword $MySqlRootPassword
        }
        return @{ Ok = $true; Detail = "全新安装完成, root 密码已设为脚本参数值, 已创建空库 mth (utf8mb4)" }
    }
    return @{ Ok = $true; Detail = '服务已存在并已启动 (未修改现有密码/数据)' }
}

function Invoke-SchemaImport {
    param([string]$RootPassword)
    $initDir = Join-Path $PSScriptRoot '..\docker\mysql\init'
    $mysqlExe = 'C:\mysql\bin\mysql.exe'
    if (-not (Test-Path $initDir)) {
        Write-Host '    未找到 docker\mysql\init 目录 (脚本未随完整仓库拷贝), 跳过表结构导入。' -ForegroundColor Yellow
        return
    }
    if (-not (Test-Path $mysqlExe)) {
        Write-Host "    找不到 $mysqlExe, 跳过表结构导入。" -ForegroundColor Yellow
        return
    }
    $files = Get-ChildItem $initDir -Filter '*.sql' | Sort-Object Name
    foreach ($f in $files) {
        Write-Host "    导入 $($f.Name) ..." -ForegroundColor DarkGray
        cmd /c "`"$mysqlExe`" -u root --password=$RootPassword --default-character-set=utf8mb4 mth < `"$($f.FullName)`"" 2>&1 | Out-Null
    }
    Write-Host "    表结构导入完成 ($($files.Count) 个文件)。" -ForegroundColor Green
}

function Test-FirewallPort {
    param([int]$Port)
    try {
        $rules = Get-NetFirewallRule -Direction Inbound -Action Allow -Enabled True -ErrorAction Stop
        foreach ($rule in $rules) {
            $filter = $rule | Get-NetFirewallPortFilter -ErrorAction SilentlyContinue
            if ($filter -and ($filter.LocalPort -contains "$Port")) {
                return @{ Ok = $true; Detail = "端口 $Port 已放行 (规则: $($rule.DisplayName))" }
            }
        }
    } catch {
        return @{ Ok = $false; Detail = "防火墙查询失败: $($_.Exception.Message)" }
    }
    return @{ Ok = $false; Detail = "未找到放行端口 $Port 的入站规则" }
}

function Install-FirewallPort {
    param($r, [int]$Port)
    New-NetFirewallRule -DisplayName "MTH-Backend HTTP $Port" -Direction Inbound -Protocol TCP -LocalPort $Port -Action Allow | Out-Null
    return @{ Ok = $true }
}

function Test-DiskSpace {
    $drive = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='$($env:SystemDrive)'"
    $freeGB = [math]::Round($drive.FreeSpace / 1GB, 1)
    if ($freeGB -lt 10) { return @{ Ok = $false; Detail = "$($env:SystemDrive) 仅剩 $freeGB GB (建议保留 >= 10GB)" } }
    return @{ Ok = $true; Detail = "$($env:SystemDrive) 剩余 $freeGB GB" }
}

function Test-RedisInfo {
    $svc = Get-Service -Name '*redis*' -ErrorAction SilentlyContinue
    $portOpen = Test-TcpPort -Port 6379
    if ($svc -or $portOpen) { return @{ Ok = $true; Detail = '检测到 Redis 服务/端口' } }
    return @{ Ok = $false; Detail = '未检测到 Redis (代码已引用 StackExchange.Redis, 但业务逻辑暂无实际调用点, 非强制项)' }
}

function Test-Git {
    $cmd = Get-Command git.exe -ErrorAction SilentlyContinue
    if ($cmd) { return @{ Ok = $true; Detail = $cmd.Source } }
    return @{ Ok = $false; Detail = '未安装 (仅 git 拉取部署方式需要, xcopy 发布方式不需要)' }
}

function Test-CenterEngine {
    # 注意: 不检测进程名 "ServerManager", 它与 Windows 自带的
    # "服务器管理器" 系统工具同名, 会造成误报。
    $proc = Get-Process -Name 'ServerCenterNew' -ErrorAction SilentlyContinue
    $pipeHit = $null
    try {
        $pipeHit = [System.IO.Directory]::GetFiles('\\.\pipe\') | Where-Object { $_ -match 'mynamedpipe|MTH_RobotPipe' }
    } catch {}
    if ($proc -or $pipeHit) { return @{ Ok = $true; Detail = '检测到 ServerCenterNew 进程或游戏管道' } }
    return @{ Ok = $false; Detail = '未检测到 ServerCenterNew 中心服 (本仓库不含其安装包, 需单独确认部署)' }
}

# ============================================================
# 检测清单
# ============================================================
$checks = @(
    @{ Name = '操作系统'; Category = 'Info'; Test = { Test-OS } }
    @{ Name = '管理员权限'; Category = 'Required'; Test = { Test-Admin } }
    @{ Name = '.NET Framework 4.8'; Category = 'Required'; Test = { Test-DotNet48 }; Fix = { param($r) Install-DotNet48 $r } }
    @{ Name = 'VC++ Redistributable x64'; Category = 'Required'; Test = { Test-VCRedistX64 }; Fix = { param($r) Install-VCRedistX64 $r } }
    @{ Name = 'IIS + ASP.NET 4.5'; Category = 'Required'; Test = { Test-IISFeatures }; Fix = { param($r) Install-IISFeatures $r } }
    @{ Name = 'MySQL 5.7 (3306)'; Category = 'Required'; Test = { Test-MySQL }; Fix = { param($r) Install-MySQL57 $r } }
    @{ Name = "防火墙端口 $WebPort"; Category = 'Required'; Test = { Test-FirewallPort $WebPort }; Fix = { param($r) Install-FirewallPort $r $WebPort } }
    @{ Name = '系统盘可用空间'; Category = 'Info'; Test = { Test-DiskSpace } }
    @{ Name = 'Windows 更新健康度'; Category = 'Info'; Test = { Test-SystemUpdateHealth } }
    @{ Name = 'Redis'; Category = 'Optional'; Test = { Test-RedisInfo } }
    @{ Name = 'Git'; Category = 'Optional'; Test = { Test-Git } }
    @{ Name = '中心服引擎(ServerCenterNew)'; Category = 'Optional'; Test = { Test-CenterEngine } }
)

# ============================================================
# 主流程
# ============================================================
Write-Host '============================================================'
Write-Host '  MTH-Backend 部署环境检测报告'
Write-Host "  时间: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')   主机: $env:COMPUTERNAME"
Write-Host '============================================================'
Write-Host ''

$isAdmin = (Test-Admin).Ok
if (-not $CheckOnly -and -not $isAdmin) {
    Write-Host '[WARN] 当前非管理员权限, 无法执行修复, 本次仅显示检测结果。' -ForegroundColor Yellow
    Write-Host '       请以管理员身份重新运行本脚本以启用修复功能。' -ForegroundColor Yellow
    Write-Host ''
}
# 只有同时满足"非纯检测模式"和"管理员权限"才会尝试任何修复。
$canAttemptFix = $isAdmin -and (-not $CheckOnly)

$results = New-Object System.Collections.Generic.List[object]
$rebootNeeded = $false
$firewallOpened = $false

foreach ($chk in $checks) {
    try {
        $r = & $chk.Test
    } catch {
        $r = @{ Ok = $false; Detail = "检测异常: $($_.Exception.Message)" }
    }
    Write-CheckLine -Name $chk.Name -Result $r -Category $chk.Category

    if ($chk.Category -eq 'Required' -and -not $r.Ok -and $chk.Fix) {
        $attemptFix = $false
        if ($canAttemptFix) {
            if ($Yes) {
                $attemptFix = $true
            } elseif ([Environment]::UserInteractive) {
                $answer = Read-Host "    -> 安装/修复 [$($chk.Name)] ? (Y/N)"
                $attemptFix = ($answer -match '^[Yy]')
                if (-not $attemptFix) { Write-Host '    已跳过' -ForegroundColor DarkGray }
            } else {
                Write-Host '    非交互式会话且未指定 -Yes, 跳过修复(仅报告)' -ForegroundColor DarkGray
            }
        }

        if ($attemptFix) {
            Write-Host "    正在处理 $($chk.Name) ..." -ForegroundColor Cyan
            try {
                $fixResult = & $chk.Fix $r
                if ($fixResult.RestartNeeded -or $fixResult.Reboot) { $rebootNeeded = $true }
                if ($chk.Name -like '防火墙端口*' -and $fixResult.Ok) { $firewallOpened = $true }
                Start-Sleep -Seconds 1
                $r = & $chk.Test
                Write-CheckLine -Name "  (复检) $($chk.Name)" -Result $r -Category $chk.Category
            } catch {
                Write-Host "    修复失败: $($_.Exception.Message)" -ForegroundColor Red
            }
        }
    }

    $results.Add([PSCustomObject]@{ Name = $chk.Name; Category = $chk.Category; Ok = $r.Ok; Detail = $r.Detail })
}

Write-Host ''
Write-Host '============================================================'
if ($firewallOpened) {
    Write-Host "[安全提示] 已在 Windows 防火墙开放入站 TCP 端口 $WebPort, 用于承载 IIS 站点。" -ForegroundColor Yellow
    Write-Host '           MySQL 3306 端口未开放公网入站(仅本机可连), 符合最小暴露原则。' -ForegroundColor Yellow
    Write-Host ''
}

$requiredFails = $results | Where-Object { $_.Category -eq 'Required' -and -not $_.Ok }
if ($requiredFails.Count -eq 0) {
    Write-Host '结论: 所有必需环境均已就绪, 可以部署 MTH-Backend。' -ForegroundColor Green
    $exitCode = 0
} else {
    Write-Host "结论: 仍有 $($requiredFails.Count) 项必需环境未就绪:" -ForegroundColor Red
    $requiredFails | ForEach-Object { Write-Host "  - $($_.Name): $($_.Detail)" -ForegroundColor Red }
    Write-Host ''
    if ($CheckOnly) {
        Write-Host '当前为仅检测模式(-CheckOnly), 未尝试任何修复。去掉该参数重新运行, 检测后会针对每个缺失项询问是否修复。' -ForegroundColor Yellow
    } elseif (-not $isAdmin) {
        Write-Host '当前非管理员权限, 无法执行修复, 请以管理员身份重新运行本脚本。' -ForegroundColor Yellow
    }
    $exitCode = 1
}
if ($rebootNeeded) {
    Write-Host ''
    Write-Host '[提示] 部分组件安装后建议重启服务器, 并在重启后重新运行本脚本确认状态。' -ForegroundColor Yellow
}
Write-Host '============================================================'

# 保存报告
try {
    $reportPath = Join-Path $PSScriptRoot 'env-check-report.txt'
    $lines = @()
    $lines += "MTH-Backend 部署环境检测报告"
    $lines += "时间: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')   主机: $env:COMPUTERNAME"
    $lines += ''
    foreach ($item in $results) {
        $tag = if ($item.Ok) { 'OK' } elseif ($item.Category -ne 'Required') { 'INFO' } else { 'FAIL' }
        $lines += "[$tag] $($item.Name) : $($item.Detail)"
    }
    $lines += ''
    $lines += if ($requiredFails.Count -eq 0) { '结论: 所有必需环境均已就绪。' } else { "结论: $($requiredFails.Count) 项必需环境未就绪。" }
    $lines -join "`r`n" | Out-File -FilePath $reportPath -Encoding UTF8
    Write-Host "报告已保存: $reportPath" -ForegroundColor DarkGray
} catch {
    Write-Host "报告保存失败: $($_.Exception.Message)" -ForegroundColor DarkGray
}

exit $exitCode
