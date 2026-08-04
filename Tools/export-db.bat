@echo off
chcp 65001 >nul
set PS_SCRIPT=%~dp0export-db.ps1

echo Exporting MTH database ...
powershell -NoProfile -ExecutionPolicy Bypass -File "%PS_SCRIPT%" %*
if %ERRORLEVEL% NEQ 0 (
    echo.
    pause
)
