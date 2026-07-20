@echo off
chcp 65001 >nul
set IIS="C:\Program Files\IIS Express\iisexpress.exe"
set CONFIG=%~dp0apphost.config

echo Starting MTH-Backend ...
echo   http://localhost:8080/Login/Index
echo   http://localhost:8080/zh-CN/Login/Index
echo Press Q to stop
echo.
%IIS% /config:%CONFIG% /site:WebSite1
pause
