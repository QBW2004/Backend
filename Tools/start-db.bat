@echo off
chcp 65001 >nul
set PS_SCRIPT=%~dp0start-db.ps1

if "%1"=="--stop" (
    powershell -NoProfile -ExecutionPolicy Bypass -File "%PS_SCRIPT%" -Stop
    goto :end
)
if "%1"=="--status" (
    powershell -NoProfile -ExecutionPolicy Bypass -File "%PS_SCRIPT%" -Status
    goto :end
)

echo Starting MySQL database ...
powershell -NoProfile -ExecutionPolicy Bypass -File "%PS_SCRIPT%"
if %ERRORLEVEL% NEQ 0 (
    echo.
    pause
)

:end
