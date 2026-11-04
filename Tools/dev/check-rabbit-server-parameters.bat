@echo off
setlocal
call "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat" >nul 2>&1
if errorlevel 1 exit /b 1
set "BACKEND=%~dp0..\.."
set "OUT=%BACKEND%\.build\rabbit-server-parameters"
set "SERVER=%BACKEND%\..\MTH-Server"
if not exist "%OUT%" mkdir "%OUT%"
pushd "%SERVER%"
msbuild ServerCardDaBaiTu\ServerCardDaBaiTu.vcxproj /m:2 /t:Build /p:Configuration=Release /p:Platform=x64 /p:PostBuildEventUseInBuild=false /v:minimal /nologo
if errorlevel 1 exit /b 1
set "OBJ=ServerCardDaBaiTu\obj\x64\Release"
cl /nologo /utf-8 /EHsc /MD /DMTH_DABAITU /I . /I third_party\pocolink\Foundation\include /I third_party\pocolink\Net\include /I third_party\pocolink\Data\include /I third_party\pocolink\Data\MySQL\include /I third_party\pocolink\JSON\include "%BACKEND%\Tools\dev\RabbitAllParametersValidation.cpp" "%OBJ%\ServerRun.obj" "%OBJ%\ServerHandler.obj" "%OBJ%\CardAlg.obj" "%OBJ%\RabbitProtocol.obj" "%OBJ%\ServerRunEx.obj" "%OBJ%\ServerHandlerEx.obj" "%OBJ%\UserApp.obj" "%OBJ%\UserInfo.obj" "%OBJ%\myLog.obj" "%OBJ%\myUtil.obj" /Fo"%OUT%\test.obj" /Fe"%OUT%\test.exe" /link /LTCG /LIBPATH:third_party\pocolink\lib PocoFoundation.lib PocoNet.lib PocoData.lib PocoDataMySQL.lib PocoJSON.lib ws2_32.lib
if errorlevel 1 exit /b 1
set "PATH=%CD%\third_party\pocolink\bin;%CD%\bat\Wei-Release\ServerCenterNew\x64\Release;%PATH%"
copy /Y third_party\pocolink\bin\PocoFoundation.dll "%OUT%\" >nul
copy /Y third_party\pocolink\bin\PocoNet.dll "%OUT%\" >nul
copy /Y third_party\pocolink\bin\PocoJSON.dll "%OUT%\" >nul
pushd "%OUT%"
test.exe "%BACKEND%\.build\rabbit-rules-validation\all-parameters.json"
exit /b %errorlevel%
