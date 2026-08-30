@echo off
chcp 65001 >nul
set PS_SCRIPT=%~dp0reset-db.ps1

echo Launching database reset tool ...
powershell -NoProfile -ExecutionPolicy Bypass -File "%PS_SCRIPT%"
if %ERRORLEVEL% NEQ 0 (
    echo.
    pause
)
