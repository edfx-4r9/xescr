@REM	@echo off
@setlocal
set filename=xesmanager_configuration.zip
if not "%1*" == "*" set filename=%1
@set webhost=localhost:5680
wget.exe --post-data "data={username:admin,password:admin}" "http://%webhost%/xes-manager/Service/Security Service/login" -O login.json
@FOR /F "tokens=2 delims=:{}" %%i in ('type login.json') do curl -v -F zipConfig=@%filename% "http://%webhost%/xes-manager/Upload/Command/import?SessionId=%%i" -o upload.json
@FOR /F "tokens=2 delims=:{,}" %%i in ('type upload.json') do if NOT "%%i" == "true" exit /b 1
exit /b

