@echo off
setlocal enabledelayedexpansion

rem ============================================================
rem  Fix legacy UCRT dependency chain on Windows Server 2012 R2
rem  (All prompts are in Chinese, printed by fix-legacy-ucrt.ps1 - this
rem   .bat file intentionally contains ASCII only. Windows cmd.exe has
rem   a known bug where a batch file containing non-ASCII bytes gets
rem   its lines corrupted/truncated when run via a non-interactive
rem   pipe, e.g. SSH remote exec. Keeping this file pure ASCII avoids it.)
rem
rem  This is a SEPARATE, one-time system patch tool. It is intentionally
rem  NOT merged into env-check.bat: it requires a reboot and carries a
rem  documented (rare) restart-loop risk on certain SAS/RAID controllers
rem  (KB2966870). It must never share the same unattended "-y" switch
rem  as the routine, safely-repeatable env-check.bat.
rem
rem  Usage:
rem    fix-legacy-ucrt.bat            Check patch status; if any are missing,
rem                                   ask whether to view install notes and continue
rem                                   (a separate typed CONTINUE confirmation follows)
rem    fix-legacy-ucrt.bat -checkonly Check only, never ask, no changes to the server
rem    fix-legacy-ucrt.bat -y         Skip the per-item / top-level prompts and try to
rem                                   install everything missing (the CONTINUE risk
rem                                   confirmation and reboot confirmation still apply)
rem    fix-legacy-ucrt.bat -y -autoreboot
rem                                   Same, and offer to reboot automatically at the
rem                                   end (still requires a separate typed confirmation)
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
    if /i "%%A"=="-autoreboot" set "EXTRA_ARGS=!EXTRA_ARGS! -AutoReboot"
)

set "PS1=%~dp0fix-legacy-ucrt.ps1"
if not exist "%PS1%" (
    echo [ERROR] fix-legacy-ucrt.ps1 not found next to this .bat file.
    pause
    exit /b 1
)

powershell -NoProfile -ExecutionPolicy Bypass -File "%PS1%" %EXTRA_ARGS%
set "PSRESULT=%errorlevel%"

echo.
pause
exit /b %PSRESULT%
