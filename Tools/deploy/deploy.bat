@echo off
setlocal enabledelayedexpansion

rem ============================================================
rem  MTH-Backend deployment script
rem  (All prompts are in Chinese, printed by deploy.ps1 - this .bat
rem   file intentionally contains ASCII only. Windows cmd.exe has a
rem   known bug where a batch file containing non-ASCII bytes gets
rem   its lines corrupted/truncated when run via a non-interactive
rem   pipe, e.g. SSH remote exec. Keeping this file pure ASCII avoids it.)
rem
rem  Usage:
rem    deploy.bat                          Check current deployment/IIS status only
rem    deploy.bat "C:\path\to\TTY.Web.zip" Check, then ask to confirm before deploying
rem                                        (default client port is 8081)
rem    deploy.bat "C:\path\to\TTY.Web.zip" -y
rem                                        Same, skip the confirmation prompt
rem    deploy.bat "C:\path\to\TTY.Web.zip" -y -nobackup
rem                                        Same, and skip backing up the existing
rem                                        deployment before overwriting it
rem    deploy.bat "C:\path\to\TTY.Web.zip" -y -port:8081
rem                                        Same, explicitly set the client port
rem
rem  The first argument (if not a flag) is treated as -SourcePath.
rem  Must be run as Administrator (right-click -> "Run as administrator").
rem ============================================================

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo [ERROR] This script must be run as Administrator.
    echo         Right-click this .bat file and choose "Run as administrator".
    echo.
    pause
    exit /b 1
)

set "SOURCE_PATH="
set "EXTRA_ARGS="

for %%A in (%*) do (
    set "ARG=%%~A"
    if /i "!ARG!"=="-y"          (
        set "EXTRA_ARGS=!EXTRA_ARGS! -Yes"
    ) else if /i "!ARG!"=="-yes" (
        set "EXTRA_ARGS=!EXTRA_ARGS! -Yes"
    ) else if /i "!ARG!"=="-checkonly" (
        set "EXTRA_ARGS=!EXTRA_ARGS! -CheckOnly"
    ) else if /i "!ARG!"=="-nobackup" (
        set "EXTRA_ARGS=!EXTRA_ARGS! -NoBackup"
    ) else if /i "!ARG:~0,6!"=="-port:" (
        set "EXTRA_ARGS=!EXTRA_ARGS! -Port !ARG:~6!"
    ) else (
        if not defined SOURCE_PATH set "SOURCE_PATH=%%~A"
    )
)

set "PS1=%~dp0deploy.ps1"
if not exist "%PS1%" (
    echo [ERROR] deploy.ps1 not found next to this .bat file.
    pause
    exit /b 1
)

if defined SOURCE_PATH (
    powershell -NoProfile -ExecutionPolicy Bypass -File "%PS1%" -SourcePath "%SOURCE_PATH%" %EXTRA_ARGS%
) else (
    powershell -NoProfile -ExecutionPolicy Bypass -File "%PS1%" %EXTRA_ARGS%
)
set "PSRESULT=%errorlevel%"

echo.
pause
exit /b %PSRESULT%
