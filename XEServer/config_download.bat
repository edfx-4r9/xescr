@echo off
setlocal
set filename=xesmanager_configuration.zip
if not "%1*" == "*" set filename=%1
set webhost=localhost:8080
wget.exe --post-data "data={username:admin,password:admin}" "http://%webhost%/xes-manager/Service/Security Service/login" -O login.json
wget.exe --post-file=login.web "http://%webhost%/xes-manager/Service/Security Service/login" -O login.json
FOR /F "tokens=2 delims=:{}" %%i in ('type login.json') do wget.exe "http://%webhost%/xes-manager/Command/export?download=xesmanager_configuration.zip&configModules=Agents+Configuration,Alert rules&SessionId=%%i" -O %filename%
