@echo off
setlocal EnableExtensions EnableDelayedExpansion
title MTH Backend - Start All Services

rem ============================================================
rem  MTH game platform - one-click startup after server reboot
rem  Order : MySQL57 -> IIS (W3SVC) -> Daemon -> Start-All -> Robot
rem  Safe by design: if game servers are already running it will
rem  NOT send Start-All again (avoids duplicate processes).
rem ============================================================

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Requesting administrator privileges...
    powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

echo.
echo ============================================================
echo   MTH Backend - Start All Services
echo ============================================================
echo.

echo [1/6] MySQL57 service ...
net start MySQL57 >nul 2>&1
sc query MySQL57 | find "RUNNING" >nul
if %errorlevel% equ 0 (echo       MySQL57: RUNNING) else (echo       WARNING: MySQL57 is NOT running)
ping -n 6 127.0.0.1 >nul

echo [2/6] IIS service (W3SVC) ...
net start W3SVC >nul 2>&1
sc query W3SVC | find "RUNNING" >nul
if %errorlevel% equ 0 (echo       W3SVC: RUNNING) else (echo       WARNING: W3SVC is NOT running)

echo [3/6] Game Daemon (watchdog) ...
tasklist /fi "imagename eq Daemon.exe" /nh 2>nul | find /i "Daemon.exe" >nul
if %errorlevel% equ 0 (
    echo       Daemon.exe already running.
) else (
    echo       Daemon not found - starting scheduled task MTH_Daemon ...
    schtasks /run /tn MTH_Daemon
)

echo       Waiting for Daemon control pipe ...
set PIPE_UP=0
for /l %%n in (1,1,12) do (
    if !PIPE_UP!==0 (
        powershell -NoProfile -ExecutionPolicy Bypass -File C:\Server\mth_pipe.ps1 -Cmd Status 2>nul | find "ok=" >nul
        if !errorlevel! equ 0 set PIPE_UP=1
        ping -n 4 127.0.0.1 >nul
    )
)
if !PIPE_UP!==0 (
    echo       ERROR: Daemon pipe MTH_ServerPipe did not respond.
    echo       Check C:\Server\ServerManager\x64\Release\MTH_Daemon.log
    goto :done
)
echo       Daemon pipe: OK

echo [4/6] Checking if game servers are already running ...
tasklist /fi "imagename eq ServerCenterNew.exe" /nh 2>nul | find /i "ServerCenterNew.exe" >nul
if %errorlevel% equ 0 goto :already_running

echo [5/6] Sending Start-All (center first, games follow after ~10s) ...
powershell -NoProfile -ExecutionPolicy Bypass -File C:\Server\mth_pipe.ps1 -Cmd Start

echo [6/6] Sending Start-Robot (remove this step if robots not wanted) ...
powershell -NoProfile -ExecutionPolicy Bypass -File C:\Server\pipe_cmd.ps1 -Cmd 1 -Target 3

echo.
echo Waiting 75s for staged startup ...
ping -n 76 127.0.0.1 >nul
goto :print_status

:already_running
echo.
echo ============================================================
echo   Game servers are ALREADY running - skipped Start-All to
echo   avoid duplicate processes. Showing status only.
echo ============================================================
ping -n 2 127.0.0.1 >nul

:print_status
echo.
echo ==================== Process status ====================
powershell -NoProfile -ExecutionPolicy Bypass -File C:\Server\mth_pipe.ps1 -Cmd Status
echo.
echo ==================== Backend HTTP probe ====================
powershell -NoProfile -Command "try { $r = Invoke-WebRequest -UseBasicParsing -Uri 'http://127.0.0.1/Login/Index' -TimeoutSec 15; Write-Output ('Login page HTTP ' + [int]$r.StatusCode) } catch { Write-Output ('probe failed: ' + $_.Exception.Message) }"

:done
echo.
pause
endlocal
