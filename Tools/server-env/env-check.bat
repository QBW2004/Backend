@echo off
setlocal enabledelayedexpansion

rem ============================================================
rem  MTH-Backend server deployment environment check / installer
rem  (All prompts are in Chinese, printed by env-check.ps1 - this
rem   .bat file intentionally contains ASCII only. Windows cmd.exe
rem   has a known bug where a batch file containing non-ASCII bytes
rem   gets its lines corrupted/truncated when run via a non-interactive
rem   pipe, e.g. SSH remote exec. Keeping this file pure ASCII avoids it.)
rem
rem  Usage:
rem    env-check.bat                Check, then ask per missing item whether to fix it now
rem    env-check.bat -checkonly     Check only, never ask, no changes to the server
rem    env-check.bat -y             Check and auto-fix every missing item (unattended)
rem    env-check.bat -y -initschema
rem                                 Same, and import mth base schema from
rem                                 ..\docker\mysql\init\*.sql on fresh MySQL install
rem
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

set "EXTRA_ARGS="

for %%A in (%*) do (
    if /i "%%A"=="-y"          set "EXTRA_ARGS=!EXTRA_ARGS! -Yes"
    if /i "%%A"=="-yes"        set "EXTRA_ARGS=!EXTRA_ARGS! -Yes"
    if /i "%%A"=="-checkonly"  set "EXTRA_ARGS=!EXTRA_ARGS! -CheckOnly"
    if /i "%%A"=="-initschema" set "EXTRA_ARGS=!EXTRA_ARGS! -InitSchema"
)

set "PS1=%~dp0env-check.ps1"
if not exist "%PS1%" (
    echo [ERROR] env-check.ps1 not found next to this .bat file.
    pause
    exit /b 1
)

powershell -NoProfile -ExecutionPolicy Bypass -File "%PS1%" %EXTRA_ARGS%
set "PSRESULT=%errorlevel%"

echo.
pause
exit /b %PSRESULT%
