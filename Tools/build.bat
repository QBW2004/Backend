@echo off
setlocal enabledelayedexpansion

:: ============================================================
::  MTH-Backend Build Script
::  Usage:
::    build.bat                - Clean + Release build
::    build.bat Debug          - Clean + Debug build
::    build.bat noclean        - Release build (skip clean)
::    build.bat Debug noclean  - Debug build (skip clean)
::
::  环境自检(自动):
::    - .NET Framework 4.8 Developer Pack 缺失时, 自动下载 NuGet 引用程序集
::      (Microsoft.NETFramework.ReferenceAssemblies.net48) 到 .build\ 并设置
::      /p:FrameworkPathOverride, 无需管理员权限。
::    - VS 未安装 "ASP.NET 和 Web 开发" 工作负载(缺 Microsoft.WebApplication.targets)
::      时, 自动下载 MSBuild.Microsoft.VisualStudio.Web.targets 包并设置
::      /p:VSToolsPath。
:: ============================================================

set "SLN=%~dp0..\MTH_Mgr_MySQL.sln"
set "CONFIG=Release"
set "DO_CLEAN=1"

for %%A in (%*) do (
    if /i "%%A"=="Debug"   set "CONFIG=Debug"
    if /i "%%A"=="Release" set "CONFIG=Release"
    if /i "%%A"=="noclean" set "DO_CLEAN="
)

:: ------------------------------------------------------------
:: 1. Locate MSBuild (VS2022 > 2019 > 2017)
:: ------------------------------------------------------------
set "MSBUILD="

for %%V in (2022 2019 2017) do (
    for %%E in (Enterprise Professional Community BuildTools) do (
        for %%P in ("C:\Program Files\Microsoft Visual Studio\%%V\%%E" "C:\Program Files (x86)\Microsoft Visual Studio\%%V\%%E") do (
            if exist "%%~P\MSBuild\Current\Bin\MSBuild.exe" (
                set "MSBUILD=%%~P\MSBuild\Current\Bin\MSBuild.exe"
                goto :found_msbuild
            )
            if exist "%%~P\MSBuild\15.0\Bin\MSBuild.exe" (
                set "MSBUILD=%%~P\MSBuild\15.0\Bin\MSBuild.exe"
                goto :found_msbuild
            )
        )
    )
)

where msbuild >nul 2>&1 && set "MSBUILD=msbuild" && goto :found_msbuild

echo [ERROR] MSBuild not found. Install Visual Studio or Build Tools.
exit /b 1

:found_msbuild
echo ============================================================
echo   MSBuild  : %MSBUILD%
echo   Solution : %SLN%
echo   Config   : %CONFIG% ^| Any CPU
if defined DO_CLEAN echo   Clean    : Yes
echo ============================================================
echo.

:: ------------------------------------------------------------
:: 2. NuGet restore (skip if packages already present)
:: ------------------------------------------------------------
set "NUGET=%~dp0nuget.exe"
if not exist "%NUGET%" (
    where nuget >nul 2>&1 && set "NUGET=nuget"
)

if not exist "%~dp0..\packages\EntityFramework.6.4.4" (
    if exist "%NUGET%" (
        echo [NuGet] Restoring packages...
        "%NUGET%" restore "%SLN%" -NonInteractive
        if !errorlevel! neq 0 (
            echo [ERROR] NuGet restore failed.
            exit /b 1
        )
    ) else (
        echo [WARN] nuget.exe not found and packages incomplete.
        echo        Download nuget.exe to Tools\ and re-run, or restore manually.
    )
) else (
    echo [NuGet] Packages directory ready, skipping restore.
)
echo.

:: ------------------------------------------------------------
:: 2.5 环境自检: .NET Framework 4.8 引用程序集
:: ------------------------------------------------------------
set "FX48=%ProgramFiles(x86)%\Reference Assemblies\Microsoft\Framework\.NETFramework\v4.8"
if exist "%FX48%" (
    echo [Env] .NET Framework 4.8 Developer Pack : OK
) else (
    echo [Env] .NET Framework 4.8 Developer Pack not found.
    echo       Using NuGet reference assemblies instead - no admin needed.
    call :ensure_build_tool refasms Microsoft.NETFramework.ReferenceAssemblies.net48 1.0.3
    if errorlevel 1 exit /b 1
    set "FPO=%~dp0..\.build\refasms\build\.NETFramework\v4.8"
)
if defined FPO call :ensure_nlp_files "%FPO%"
echo.

:: ------------------------------------------------------------
:: 2.6 环境自检: VS Web targets (Microsoft.WebApplication.targets)
:: ------------------------------------------------------------
set "VSTP="
set "WEBTARGETS_FOUND="
for %%V in (17.0 16.0 15.0) do (
    if exist "%ProgramFiles(x86)%\MSBuild\Microsoft\VisualStudio\%%V\WebApplications\Microsoft.WebApplication.targets" (
        set "WEBTARGETS_FOUND=1"
    )
)
if defined WEBTARGETS_FOUND (
    echo [Env] VS Web targets : OK
) else (
    echo [Env] Microsoft.WebApplication.targets not found ^(VS ASP.NET workload missing^).
    echo       Using NuGet MSBuild.Microsoft.VisualStudio.Web.targets instead.
    call :ensure_build_tool webtargets MSBuild.Microsoft.VisualStudio.Web.targets 14.0.0.3
    if errorlevel 1 exit /b 1
    set "VSTP=%~dp0..\.build\webtargets\tools\VSToolsPath"
)
echo.

:: ------------------------------------------------------------
:: 3. Clean (optional)
:: ------------------------------------------------------------
if defined DO_CLEAN (
    echo [Clean] Cleaning old output...
    "%MSBUILD%" "%SLN%" /t:Clean /p:Configuration=%CONFIG% /p:Platform="Any CPU" /v:minimal /nologo
    echo.
)

:: ------------------------------------------------------------
:: 4. Build
:: ------------------------------------------------------------
echo [Build] Compiling (%CONFIG%)...
echo.

set "EXTRA_ARGS="
if defined FPO  set "EXTRA_ARGS=%EXTRA_ARGS% /p:FrameworkPathOverride=%FPO%"
if defined VSTP set "EXTRA_ARGS=%EXTRA_ARGS% /p:VSToolsPath=%VSTP%"

"%MSBUILD%" "%SLN%" /t:Build /p:Configuration=%CONFIG% /p:Platform="Any CPU" /m /v:minimal /nologo %EXTRA_ARGS%

if %errorlevel% neq 0 (
    echo.
    echo ============================================================
    echo   BUILD FAILED - check errors above.
    echo ============================================================
    exit /b 1
)

echo.
echo ============================================================
echo   BUILD SUCCEEDED (%CONFIG%)
echo ============================================================

set "WEB_BIN=%~dp0..\TTY.Web\bin"
if exist "%WEB_BIN%" (
    echo   Output: %WEB_BIN%
)

endlocal
echo.
pause
exit /b 0

:: ------------------------------------------------------------
:: 下载并解压构建工具包到 .build\<name> (仅首次执行)
::   %1 = 目录名   %2 = NuGet 包 ID   %3 = 版本
:: ------------------------------------------------------------
:ensure_build_tool
set "PKG_DIR=%~dp0..\.build\%1"
if exist "%PKG_DIR%" (
    echo [Env] %1 already cached.
    exit /b 0
)
echo [Env] Downloading %2 v%3 ...
powershell -NoProfile -Command "$ErrorActionPreference='Stop'; [Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12; $id='%2'.ToLowerInvariant(); $ver='%3'; $dir='%~dp0..\.build\%1'; New-Item -ItemType Directory -Force -Path $dir | Out-Null; $pkg='%~dp0..\.build\%1.zip'; Invoke-WebRequest -Uri ('https://api.nuget.org/v3-flatcontainer/' + $id + '/' + $ver + '/' + $id + '.' + $ver + '.nupkg') -OutFile $pkg; Expand-Archive -Path $pkg -DestinationPath $dir -Force; Remove-Item $pkg -Force"
if errorlevel 1 (
    echo [ERROR] Failed to download %2. Check network or install the VS component manually.
    rmdir /s /q "%~dp0..\.build\%1" 2>nul
    exit /b 1
)
exit /b 0

:: ------------------------------------------------------------
:: 补齐 NuGet 引用程序集包缺失的 .nlp 数据文件
:: (从 .NET Framework 运行时目录复制真实文件, 否则 MSB3030)
::   %1 = 引用程序集目录 (FrameworkPathOverride)
:: ------------------------------------------------------------
:ensure_nlp_files
set "NLPSRC=%SystemRoot%\Microsoft.NET\Framework64\v4.0.30319"
set "NLP_TARGET=%~1"
if exist "%NLP_TARGET%" (
    for %%N in (normidna.nlp normnfc.nlp normnfd.nlp normnfkc.nlp normnfkd.nlp) do (
        if not exist "%NLP_TARGET%\%%N" (
            if exist "%NLPSRC%\%%N" (
                copy /y "%NLPSRC%\%%N" "%NLP_TARGET%\%%N" >nul
                echo [Env] Copied %%N from runtime.
            ) else (
                type nul > "%NLP_TARGET%\%%N"
                echo [Env] Created placeholder %%N ^(runtime copy not found^).
            )
        )
    )
)
exit /b 0
