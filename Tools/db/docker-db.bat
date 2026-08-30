@echo off
chcp 65001 >nul
set PS_SCRIPT=%~dp0docker-db.ps1

if "%1"=="" (
    echo Usage: docker-db.bat [start^|stop^|status^|reinit] [-Force]
    echo.
    echo   start   启动 MySQL 容器(首次自动导入 init SQL)
    echo   stop    停止容器(数据保留)
    echo   status  查看容器状态与 MySQL 版本
    echo   reinit  删除数据卷并重新初始化数据库(清空数据, 需输入 YES 确认)
    exit /b 1
)

powershell -NoProfile -ExecutionPolicy Bypass -File "%PS_SCRIPT%" %*
if %ERRORLEVEL% NEQ 0 (
    echo.
    pause
)
