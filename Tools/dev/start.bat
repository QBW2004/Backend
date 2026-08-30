@echo off
chcp 65001 >nul
set "IIS=C:\Program Files\IIS Express\iisexpress.exe"

if not exist "%IIS%" (
    echo [ERROR] IIS Express not found: %IIS%
    echo         Install from: https://www.microsoft.com/en-us/download/details.aspx?id=48264
    exit /b 1
)

set "CONFIG=%~dp0..\..\apphost.config"
set "WEBROOT=%~dp0..\..\TTY.Web"

if exist "%CONFIG%" (
    echo Starting MTH-Backend (apphost.config) ...
    echo   http://localhost:8080/Login/Index
    echo   http://localhost:8080/zh-CN/Login/Index
    echo Press Q to stop
    echo.
    "%IIS%" /config:%CONFIG% /site:WebSite1
) else (
    echo [WARN] apphost.config not found, using direct path mode.
    echo Starting MTH-Backend ...
    echo   http://localhost:8080/Login/Index
    echo   http://localhost:8080/zh-CN/Login/Index
    echo Press Q to stop
    echo.
    "%IIS%" /path:"%WEBROOT%" /port:8080 /systray:false
)
pause
