<#
.SYNOPSIS
    Windows Server 2012 R2 / Windows 8.1 遗留 Universal C Runtime(UCRT)依赖链修复脚本。

.DESCRIPTION
    这台服务器长期未做 Windows Update, 导致 VC++ 2015-2022 Redistributable 和
    .NET Framework 4.8 都装不上(缺 ucrtbase.dll 等 UCRT 组件)。UCRT 在
    Windows 10 / Server 2016+ 上是系统自带的, 但 Windows 8.1 / Server 2012 R2
    需要手动打一条补丁链才会有:

        KB2919442 -> clearcompressionflag.exe -> KB2919355(2014年4月更新汇总,
        又称 S14, 约 690MB) -> KB2932046 -> KB2959977 -> KB2937592 ->
        KB2938439 -> KB2934018 -> KB2999226(Universal C Runtime 本体)

    默认行为: 直接运行(不加参数)就会检测 8 个补丁的安装状态并打印结果;
    如果发现有缺失, 会先问一句 "现在要看安装说明并继续吗? (Y/N)" —— 这只是
    决定要不要往下走, 真正会改动系统之前还有下面这道更强的关卡:

    本脚本与 env-check.ps1 完全解耦、独立运行, 原因:
      - env-check.ps1 是可反复安全重跑的常规环境检测/修复工具
      - 本脚本是一次性的系统级变更, 必然重启, 且 KB2919355 在少数特定
        SAS/RAID 存储控制器(如 Dell H200 PERC、部分 LSI 2308/9211 系列、
        Supermicro X10SL7-F 主板)上有微软自己记录的"重启循环"已知问题
        (KB2966870)。云服务器虚拟化存储不在该已知问题列表中, 但无法
        100% 排除, 因此这里的风险确认要求手动输入确切的单词, 不因为
        脚本"默认检测后就问"的这层改动而被弱化。

    KB2999226(UCRT 本体)在官方下载中心是 JS 动态页面, 抓不到稳定直链,
    脚本不会替你猜一个链接去自动下载它。需要你手动从官方页面下载后放到
    -PatchDir 指定目录, 脚本会检测文件是否已就位再继续。

.PARAMETER CheckOnly
    仅检测每个补丁的安装状态并输出结果, 不询问、不做任何修复。

.PARAMETER Yes
    跳过"现在要看安装说明并继续吗"这一顶层询问, 以及每个补丁的下载/安装
    逐项询问。不会跳过风险横幅之后要求手动输入 CONTINUE 的确认, 也不会
    跳过重启前的确认 —— 这两道关卡是刻意设计成不能用 -Yes 绕过的。

.PARAMETER AutoReboot
    全部补丁装完后, 若需要重启, 提供自动重启的选项(仍会额外单独确认一次)。
    不指定时脚本只会提示"需要手动重启", 不会自己重启服务器。

.PARAMETER PatchDir
    补丁下载/存放目录, 默认脚本同级目录下的 ucrt-patches 文件夹。
    重复运行会跳过已下载的文件, 也是放置手动下载的 KB2999226 的地方。

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File fix-legacy-ucrt.ps1
    # 默认: 检测补丁状态, 有缺失则询问是否继续安装(仍需通过风险确认)
.EXAMPLE
    powershell -ExecutionPolicy Bypass -File fix-legacy-ucrt.ps1 -CheckOnly
    # 仅检测, 不询问, 不做任何修改
.EXAMPLE
    powershell -ExecutionPolicy Bypass -File fix-legacy-ucrt.ps1 -Yes
    # 跳过逐项询问直接安装所有缺失补丁(仍需手动输入 CONTINUE 确认风险)
#>
param(
    [switch]$CheckOnly,
    [switch]$Yes,
    [switch]$AutoReboot,
    [string]$PatchDir = (Join-Path $PSScriptRoot 'ucrt-patches')
)

$ErrorActionPreference = 'Stop'

# ============================================================
# 0. 逃离 WOW64: 32 位 sshd/命令行派生的会话里, wusa.exe 装 x64 补丁、
#    注册表 64 位视图查询都会因 WOW64 重定向而不准确。跟 env-check.ps1
#    用同样的手法, 显式拉起 64 位 PowerShell 重跑自身。
# ============================================================
if ([Environment]::Is64BitOperatingSystem -and -not [Environment]::Is64BitProcess) {
    $sysnativePwsh = Join-Path $env:WINDIR 'Sysnative\WindowsPowerShell\v1.0\powershell.exe'
    if (Test-Path $sysnativePwsh) {
        $passArgs = @('-PatchDir', $PatchDir)
        if ($CheckOnly) { $passArgs += '-CheckOnly' }
        if ($Yes) { $passArgs += '-Yes' }
        if ($AutoReboot) { $passArgs += '-AutoReboot' }
        & $sysnativePwsh -NoProfile -ExecutionPolicy Bypass -File $PSCommandPath @passArgs
        exit $LASTEXITCODE
    } else {
        Write-Warning '未找到 Sysnative 64 位 PowerShell, 继续以 32 位模式运行(可能不准确)。'
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

function Test-SupportedOS {
    # 这条补丁链是 Windows 8.1 / Server 2012 R2(内部版本号 6.3, Build 9600)
    # 专属的。装到别的系统版本上补丁根本不适用, 装错了没有意义, 直接拒绝。
    $os = Get-CimInstance Win32_OperatingSystem
    $isTarget = $os.Version -like '6.3.9600*'
    return @{ Ok = $isTarget; Caption = $os.Caption; Version = $os.Version }
}

function Invoke-DownloadFile {
    param([string]$Url, [string]$OutFile, [int]$Retries = 5)
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls11 -bor [Net.SecurityProtocolType]::Tls
    for ($i = 1; $i -le $Retries; $i++) {
        try {
            $wc = New-Object System.Net.WebClient
            $wc.Headers.Add('User-Agent', 'Mozilla/5.0 (Windows NT 6.3; Win64; x64) MTH-FixUcrt')
            $wc.DownloadFile($Url, $OutFile)
            $wc.Dispose()
            if (Test-Path $OutFile) { return $true }
        } catch {
            Write-Host "    下载失败(WebClient, 第 $i/$Retries 次): $($_.Exception.Message)" -ForegroundColor Yellow
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

function Test-KbInstalled {
    # 注意: Get-HotFix(底层是 Win32_QuickFixEngineering WMI 类)只能看到
    # 通过 CBS(基于组件的服务) 安装的更新, 像 KB2932046/KB2934018/
    # KB2937592/KB2938439 这类通过 wusa.exe 独立安装程序装的 "Feature
    # Pack" 更新走的是不同的服务通道, Get-HotFix 天生看不到它们 ——
    # 这不代表没装成功, 只是检测手段选错了。DISM 的包列表(直接查询
    # CBS 存储本身)才是权威真相源, 兼容全部更新类型, 因此这里两者都查,
    # 命中任一个就判定为已安装。
    param([string]$KbId)
    if (Get-HotFix -Id $KbId -ErrorAction SilentlyContinue) { return $true }

    if (-not $script:DismPackageCache) {
        $dismExe = Join-Path $env:SystemRoot 'System32\dism.exe'
        $script:DismPackageCache = & $dismExe /online /Get-Packages /Format:Table 2>$null
    }
    $pattern = "for_$KbId~"
    return [bool]($script:DismPackageCache | Select-String -SimpleMatch $pattern -Quiet)
}

# ============================================================
# 补丁清单(顺序不可调换, 每一个都依赖前一个)
# ============================================================
function Get-PatchList {
    $folderGuid = '256CCCFB-5341-4A8D-A277-8A81B21A1E35'
    return @(
        [PSCustomObject]@{
            KbId = 'KB2919442'; DisplayName = 'KB2919442 (前置更新, 为安装2014年4月更新汇总做准备)'
            FileName = 'Windows8.1-KB2919442-x64.msu'
            Url = 'https://download.microsoft.com/download/D/6/0/D60ED3E0-93A5-4505-8F6A-8D0A5DA16C8A/Windows8.1-KB2919442-x64.msu'
            Type = 'msu'; SizeHint = '约 10MB'
        }
        [PSCustomObject]@{
            KbId = $null; DisplayName = 'clearcompressionflag.exe (安装准备工具, 非 KB 补丁, 不计入 Get-HotFix 检测)'
            FileName = 'clearcompressionflag.exe'
            Url = 'https://download.microsoft.com/download/2/5/6/256CCCFB-5341-4A8D-A277-8A81B21A1E35/clearcompressionflag.exe'
            Type = 'exe'; SizeHint = '约 40KB'
        }
        [PSCustomObject]@{
            KbId = 'KB2919355'; DisplayName = 'KB2919355 (2014年4月更新汇总, 又称 S14, 本链路体积最大的一个)'
            FileName = 'Windows8.1-KB2919355-x64.msu'
            Url = "https://download.microsoft.com/download/2/5/6/$folderGuid/Windows8.1-KB2919355-x64.msu"
            Type = 'msu'; SizeHint = '约 690MB'
        }
        [PSCustomObject]@{
            KbId = 'KB2932046'; DisplayName = 'KB2932046'
            FileName = 'Windows8.1-KB2932046-x64.msu'
            Url = "https://download.microsoft.com/download/2/5/6/$folderGuid/Windows8.1-KB2932046-x64.msu"
            Type = 'msu'; SizeHint = '约 50MB'
        }
        [PSCustomObject]@{
            KbId = 'KB2959977'; DisplayName = 'KB2959977'
            FileName = 'Windows8.1-KB2959977-x64.msu'
            Url = "https://download.microsoft.com/download/2/5/6/$folderGuid/Windows8.1-KB2959977-x64.msu"
            Type = 'msu'; SizeHint = '约 3MB'
        }
        [PSCustomObject]@{
            KbId = 'KB2937592'; DisplayName = 'KB2937592'
            FileName = 'Windows8.1-KB2937592-x64.msu'
            Url = "https://download.microsoft.com/download/2/5/6/$folderGuid/Windows8.1-KB2937592-x64.msu"
            Type = 'msu'; SizeHint = '约 0.3MB'
        }
        [PSCustomObject]@{
            KbId = 'KB2938439'; DisplayName = 'KB2938439'
            FileName = 'Windows8.1-KB2938439-x64.msu'
            Url = "https://download.microsoft.com/download/2/5/6/$folderGuid/Windows8.1-KB2938439-x64.msu"
            Type = 'msu'; SizeHint = '约 20MB'
        }
        [PSCustomObject]@{
            KbId = 'KB2934018'; DisplayName = 'KB2934018'
            FileName = 'Windows8.1-KB2934018-x64.msu'
            Url = "https://download.microsoft.com/download/2/5/6/$folderGuid/Windows8.1-KB2934018-x64.msu"
            Type = 'msu'; SizeHint = '约 133MB'
        }
        [PSCustomObject]@{
            KbId = 'KB2999226'; DisplayName = 'KB2999226 (Universal C Runtime 本体, 本链路的最终目标)'
            FileName = 'Windows8.1-KB2999226-x64.msu'
            Url = $null  # 官方下载中心是 JS 动态页面, 抓不到稳定直链, 需手动下载
            ManualPageUrl = 'https://www.microsoft.com/download/details.aspx?id=49063'
            Type = 'msu'; SizeHint = '约 1MB'
        }
    )
}

function Show-RiskBanner {
    param([array]$Patches, [string]$PatchDir)
    $autoDownloadMb = 0
    foreach ($p in $Patches) {
        if ($p.Url -and $p.SizeHint -match '([\d.]+)\s*MB') { $autoDownloadMb += [double]$Matches[1] }
    }
    Write-Host ''
    Write-Host '============================================================' -ForegroundColor Red
    Write-Host '  风险确认: 即将对系统做补丁级变更' -ForegroundColor Red
    Write-Host '============================================================' -ForegroundColor Red
    Write-Host "这台机器是 Windows Server 2012 R2, UCRT 不是系统自带的,"
    Write-Host "需要按顺序装 8 个系统补丁才能补齐, 大约下载 $([math]::Round($autoDownloadMb)) MB (自动部分,"
    Write-Host "KB2999226 需另外手动下载约 1MB)。"
    Write-Host ''
    Write-Host '请注意以下几点:' -ForegroundColor Yellow
    Write-Host '  1. 装完这条补丁链后必然需要重启服务器一次。'
    Write-Host '  2. 其中 KB2919355 在少数特定 SAS/RAID 存储控制器上(如 Dell'
    Write-Host '     H200 PERC、部分 LSI 2308/9211 系列、Supermicro X10SL7-F 主板)'
    Write-Host '     有微软自己记录的"重启循环"已知问题(KB2966870/KB2967162)。'
    Write-Host '     云服务器用虚拟化存储, 不在已知问题列表里, 但脚本无法从'
    Write-Host '     软件层 100% 确认底层存储驱动栈, 不能保证概率为零。'
    Write-Host '  3. 如果真的卡进重启循环, 需要通过服务商的救援模式/单用户模式'
    Write-Host '     手动修复(参考 KB2966870 的 workaround), 这不是脚本能自动'
    Write-Host '     处理的故障恢复场景。'
    Write-Host '  4. 强烈建议在继续之前给这台机器打一个快照/备份。'
    Write-Host ''
    Write-Host "补丁将下载到: $PatchDir"
    Write-Host ''
    if (-not [Environment]::UserInteractive) {
        Write-Host '[ABORT] 当前是非交互式会话, 无法完成手动风险确认, 为安全起见拒绝继续。' -ForegroundColor Red
        return $false
    }
    $answer = Read-Host '如果已经了解以上风险并要继续, 请输入完整单词 CONTINUE (大小写不限)'
    if ($answer -ne 'CONTINUE' -and $answer -ne 'continue') {
        Write-Host '未输入确认词, 已取消, 未对系统做任何改动。' -ForegroundColor Yellow
        return $false
    }
    return $true
}

function Install-SinglePatch {
    param($Patch, [string]$PatchDir, [switch]$Yes)

    if ($Patch.KbId -and (Test-KbInstalled -KbId $Patch.KbId)) {
        Write-Host "[SKIP] $($Patch.DisplayName) 已安装" -ForegroundColor DarkGray
        return @{ Ok = $true; RebootNeeded = $false; Skipped = $true }
    }

    $localPath = Join-Path $PatchDir $Patch.FileName

    if (-not $Patch.Url) {
        # KB2999226: 需要手动下载, 检测文件是否已放到位
        if (Test-Path $localPath) {
            Write-Host "[FOUND] $($Patch.FileName) 已存在于补丁目录, 继续安装 ..." -ForegroundColor Cyan
        } else {
            Write-Host ''
            Write-Host "[需要手动操作] $($Patch.DisplayName)" -ForegroundColor Yellow
            Write-Host "  官方下载中心页面是动态渲染的, 脚本无法自动抓取稳定直链。"
            Write-Host "  请手动完成:"
            Write-Host "    1. 打开: $($Patch.ManualPageUrl)"
            Write-Host "    2. 下载文件 $($Patch.FileName)"
            Write-Host "    3. 放到: $localPath"
            Write-Host "    4. 重新运行本脚本(之前已装好的补丁会被跳过, 会直接从这一步继续)"
            return @{ Ok = $false; RebootNeeded = $false; ManualPending = $true }
        }
    } elseif (-not (Test-Path $localPath)) {
        if (-not $Yes) {
            $ans = Read-Host "  -> 下载并安装 [$($Patch.DisplayName)] ($($Patch.SizeHint))? (Y/N)"
            if ($ans -notmatch '^[Yy]') {
                Write-Host '     已跳过' -ForegroundColor DarkGray
                return @{ Ok = $false; RebootNeeded = $false; Skipped = $true }
            }
        }
        Write-Host "  下载 $($Patch.FileName) ($($Patch.SizeHint)) ..." -ForegroundColor DarkGray
        if (-not (Invoke-DownloadFile -Url $Patch.Url -OutFile $localPath)) {
            return @{ Ok = $false; RebootNeeded = $false; Detail = '下载失败' }
        }
    } else {
        Write-Host "  $($Patch.FileName) 已下载, 跳过重复下载" -ForegroundColor DarkGray
    }

    Write-Host "  安装 $($Patch.DisplayName) ..." -ForegroundColor Cyan
    if ($Patch.Type -eq 'exe') {
        # clearcompressionflag.exe: 官方文档描述为"静默准备工具", 非核心补丁,
        # 失败时记录警告但不中断整条链路。
        try {
            $p = Start-Process -FilePath $localPath -ArgumentList '/s' -Wait -PassThru
            if ($p.ExitCode -ne 0) {
                Write-Host "    警告: clearcompressionflag 退出码 $($p.ExitCode)(非核心补丁, 继续)" -ForegroundColor Yellow
            }
            return @{ Ok = $true; RebootNeeded = $false }
        } catch {
            Write-Host "    警告: clearcompressionflag 执行异常: $($_.Exception.Message)(继续)" -ForegroundColor Yellow
            return @{ Ok = $true; RebootNeeded = $false }
        }
    } else {
        $wusa = Join-Path $env:SystemRoot 'System32\wusa.exe'
        $p = Start-Process -FilePath $wusa -ArgumentList "`"$localPath`" /quiet /norestart" -Wait -PassThru
        switch ($p.ExitCode) {
            0 { return @{ Ok = $true; RebootNeeded = $false } }
            3010 { return @{ Ok = $true; RebootNeeded = $true } }
            2359302 { return @{ Ok = $true; RebootNeeded = $false; Detail = '已安装过(WU_S_ALREADY_INSTALLED)' } }
            default { return @{ Ok = $false; RebootNeeded = $false; Detail = "wusa 退出码 $($p.ExitCode)" } }
        }
    }
}

# ============================================================
# 主流程
# ============================================================
Write-Host '============================================================'
Write-Host '  Windows Server 2012 R2 遗留 UCRT 依赖链修复'
Write-Host "  时间: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')   主机: $env:COMPUTERNAME"
Write-Host '============================================================'

$osCheck = Test-SupportedOS
Write-Host "操作系统: $($osCheck.Caption) (Version $($osCheck.Version))"
if (-not $osCheck.Ok) {
    Write-Host '[ABORT] 本脚本专为 Windows 8.1 / Server 2012 R2(内部版本 6.3.9600)编写。' -ForegroundColor Red
    Write-Host '        当前系统版本不匹配, 这条补丁链对其他系统版本没有意义, 已拒绝执行。' -ForegroundColor Red
    exit 1
}

$isAdmin = Test-IsAdmin
if (-not $CheckOnly -and -not $isAdmin) {
    Write-Host '[WARN] 当前非管理员权限, 无法安装补丁, 本次仅显示检测结果。' -ForegroundColor Yellow
}

if (-not (Test-Path $PatchDir)) {
    New-Item -ItemType Directory -Path $PatchDir -Force | Out-Null
}

$patches = Get-PatchList

Write-Host ''
Write-Host '===== 补丁状态 ====='
foreach ($p in $patches) {
    if ($p.KbId) {
        $installed = Test-KbInstalled -KbId $p.KbId
        $tag = if ($installed) { '[OK]  ' } else { '[FAIL]' }
        $color = if ($installed) { 'Green' } else { 'Red' }
    } else {
        $tag = '[N/A] '
        $color = 'DarkGray'
    }
    Write-Host "$tag $($p.DisplayName)" -ForegroundColor $color
}
$missingKbCount = ($patches | Where-Object { $_.KbId -and -not (Test-KbInstalled -KbId $_.KbId) } | Measure-Object).Count
Write-Host ''

if ($missingKbCount -eq 0) {
    Write-Host '结论: 所有补丁均已安装, UCRT 依赖链已补齐。' -ForegroundColor Green
    exit 0
}

Write-Host "发现 $missingKbCount 个补丁未安装。" -ForegroundColor Yellow

if ($CheckOnly) {
    Write-Host '当前为仅检测模式(-CheckOnly), 未做任何改动。' -ForegroundColor Yellow
    exit 1
}
if (-not $isAdmin) {
    exit 1
}

# ---- 顶层询问: 是否要看安装说明并继续 ----
# 这一步只是决定"要不要往下走看风险说明", 真正会改动系统的关卡是
# 下面 Show-RiskBanner 里那个必须手动输入 CONTINUE 才能通过的确认。
if (-not $Yes) {
    if (-not [Environment]::UserInteractive) {
        Write-Host '非交互式会话且未指定 -Yes, 不会询问, 本次到此为止(仅报告缺失)。' -ForegroundColor DarkGray
        exit 1
    }
    $topAnswer = Read-Host '现在要查看安装说明并继续吗? (Y/N)'
    if ($topAnswer -notmatch '^[Yy]') {
        Write-Host '已取消, 未对系统做任何改动。' -ForegroundColor DarkGray
        exit 1
    }
}

if (-not (Show-RiskBanner -Patches $patches -PatchDir $PatchDir)) {
    exit 1
}

$logPath = Join-Path $PatchDir "install-log-$(Get-Date -Format 'yyyyMMdd-HHmmss').txt"
try { Start-Transcript -Path $logPath -Append | Out-Null } catch {}

$rebootNeeded = $false
$stoppedForManual = $false
$failedPatch = $null

foreach ($p in $patches) {
    $result = Install-SinglePatch -Patch $p -PatchDir $PatchDir -Yes:$Yes
    if ($result.RebootNeeded) { $rebootNeeded = $true }
    if ($result.ManualPending) {
        $stoppedForManual = $true
        break
    }
    if (-not $result.Ok -and -not $result.Skipped) {
        Write-Host "[FAIL] $($p.DisplayName): $($result.Detail)" -ForegroundColor Red
        $failedPatch = $p
        break
    }
}

Write-Host ''
Write-Host '============================================================'
if ($stoppedForManual) {
    Write-Host '结论: 需要你先手动下载 KB2999226 放到补丁目录, 再重新运行本脚本。' -ForegroundColor Yellow
    $exitCode = 2
} elseif ($failedPatch) {
    Write-Host "结论: 安装在 [$($failedPatch.DisplayName)] 处失败, 请查看上方日志。" -ForegroundColor Red
    Write-Host "      日志文件: $logPath"
    $exitCode = 1
} else {
    Write-Host '结论: 补丁链安装流程已跑完。' -ForegroundColor Green
    $exitCode = 0
}

if ($rebootNeeded) {
    Write-Host ''
    Write-Host '[提示] 至少有一个补丁需要重启才能生效。' -ForegroundColor Yellow
    if ($AutoReboot) {
        if ([Environment]::UserInteractive) {
            $confirm = Read-Host '即将重启这台服务器, 输入 REBOOT NOW 确认执行, 其他任意输入取消'
            if ($confirm -eq 'REBOOT NOW') {
                Write-Host '正在重启 ...' -ForegroundColor Cyan
                try { Stop-Transcript | Out-Null } catch {}
                Restart-Computer -Force
            } else {
                Write-Host '已取消自动重启, 请记得手动重启后重新运行本脚本确认结果。' -ForegroundColor Yellow
            }
        } else {
            Write-Host '非交互式会话, 为安全起见不会自动重启, 请手动重启服务器。' -ForegroundColor Yellow
        }
    } else {
        Write-Host '请手动重启服务器, 重启后重新运行本脚本确认 UCRT 是否已就位,' -ForegroundColor Yellow
        Write-Host '然后回到 env-check.bat 继续修复 VC++ Redist / .NET Framework 4.8 / MySQL。' -ForegroundColor Yellow
    }
}

try { Stop-Transcript | Out-Null } catch {}
Write-Host "详细日志已保存: $logPath"
exit $exitCode
