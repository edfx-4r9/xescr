@REM	@echo off
@setlocal
set filename=xesmanager_configuration.zip
if not "%1*" == "*" set filename=%1
@set webhost=localhost:5680
wget.exe -q --post-data "data={username:admin,password:admin}" "http://%webhost%/xes-manager/Service/Security Service/login" -O %~dp0login.json || exit /b 2
FOR /F "tokens=2 delims=:{}" %%i in ('type %~dp0login.json') do wget.exe -q "http://%webhost%/xes-manager/Command/export?download=xesmanager_configuration.zip&configModules=All&SessionId=%%i" -O %filename%

if not exist %filename% exit /b 2
