@echo off
setlocal enabledelayedexpansion

:: ============================================================
::  MTH-Backend Build Script
::  Usage:
::    build.bat                - Clean + Release build
::    build.bat Debug          - Clean + Debug build
::    build.bat noclean        - Release build (skip clean)
::    build.bat Debug noclean  - Debug build (skip clean)
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
if not exist "%~dp0..\packages\EntityFramework.6.4.4" (
    where nuget >nul 2>&1
    if !errorlevel! equ 0 (
        echo [NuGet] Restoring packages...
        nuget restore "%SLN%" -NonInteractive
        if !errorlevel! neq 0 (
            echo [ERROR] NuGet restore failed.
            exit /b 1
        )
    ) else (
        echo [WARN] nuget.exe not found and packages incomplete.
        echo        Download nuget.exe and add to PATH, or restore manually.
    )
) else (
    echo [NuGet] Packages directory ready, skipping restore.
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

"%MSBUILD%" "%SLN%" /t:Build /p:Configuration=%CONFIG% /p:Platform="Any CPU" /m /v:minimal /nologo

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
