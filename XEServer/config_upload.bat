@REM	@echo off
@setlocal
set filename=xesmanager_configuration.zip
if not "%1*" == "*" set filename=%1
@set webhost=localhost:5680
wget.exe --post-data "data={username:admin,password:admin}" "http://%webhost%/xes-manager/Service/Security Service/login" -O login.json
sleep 15
@FOR /F "tokens=2 delims=:{}" %%i in ('type login.json') do curl -v -i -F zipConfig=@%filename% "http://%webhost%/xes-manager/Upload/Command/import?SessionId=%%i"
exit /b

@REM	FOR /F "tokens=2 delims=:{}" %%i in ('type login.json') do curl -v -i -F name=zipConfig -F filedata=@xesmanager_configuration.zip "http://localhost:8080/xes-manager/Upload/Command/import?SessionId=%%i"
@REM	FOR /F "tokens=2 delims=:{}" %%i in ('type login.json') do wget.exe "http://%webhost%/xes-manager/Command/export?download=xesmanager_configuration.zip&configModules=Agents+Configuration,Alert rules&SessionId=%%i" -O xesmanager_configuration.zip

