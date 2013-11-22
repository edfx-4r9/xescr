@echo off
setlocal
set webhost=localhost:8080
FOR /F "tokens=2 delims=:{}" %%i in ('wget.exe --post-data "data={username:admin,password:admin}" "http://%webhost%/xes-manager/Service/Security Service/login" -O -') do wget.exe "http://%webhost%/xes-manager/Command/export?download=xesmanager_configuration.zip&configModules=Agents Configuration,Alert%%20rules&SessionId=%%i" -O download.zip && exit /b

REM	FOR /F "tokens=2 delims=:{}" %i in ('curl --data "data={username:admin,password:admin}" http://localhost:8080/xes-manager/Service/Security%20Service/login') do curl -O "http://localhost:8080/xes-manager/Command/export?download=xesmanager_configuration.zip&configModules=Agents%20Configuration,Alert%20rules" --data SessionId="%i" --get


@REM	#	DOWNLOAD SCENARIO
@REM	wget.exe --post-data "data={username:admin,password:admin}" "http://%webhost%/xes-manager/Service/Security Service/login" -O login.htm
@REM	#	returns JSON string as below
@REM	#	{"sessionId":"e5b8b0d8-0bf0-4213-b7d7-f46b676b6e67"}
@REM	#	ALAS ! It has DOUBLE QUOTES !
@REM	wget.exe "http://%webhost%/xes-manager/Command/export?download=xesmanager_configuration.zip&configModules=Agents Configuration,Alert rules&sessionId=830426d0-4ec7-4b5f-bafd-e0489e462d29" -O download.htm
@REM	#	Returns ZIP file or JSON with authentication error description



wget.exe --post-data "data={username:admin,password:admin}" "http://%webhost%/xes-manager/Service/Security Service/login" -O login.htm
FOR /F "tokens=2 delims=:{}" %%i in ('type login.htm') do echo SessID:: %%i
REM	FOR /F "tokens=2 delims=:{}" %%i in ('type login.htm') do wget "http://localhost:8080/xes-manager/Command/export?download=xesmanager_configuration.zip&configModules=Agents Configuration,Alert rules&SessionId="%i" -O xesmanager_configuration.zip
REM FOR /F "tokens=2 delims=:{}" %%i in ('type login.htm') do curl -v -o file1.zip "http://localhost:8080/xes-manager/Command/export?download=xesmanager_configuration.zip&configModules=Agents%20Configuration,Alert%20rules" --data SessionId="%%i" --get
REM FOR /F "tokens=2 delims=:{}" %%i in ('type login.htm') do curl -o file2.zip "http://localhost:8080/xes-manager/Command/export?download=xesmanager_configuration.zip&configModules=Agents Configuration,Alert rules" --data SessionId="%%i" --get

FOR /F "tokens=2 delims=:{}" %%i in ('type login.htm') do set SessID=%%i
set SessID=%SessID:~1,36%
echo %SessID%
REM	FOR /F "tokens=2 delims=:{}" %%i in ('type login.htm') do curl -v -o file3.zip "http://localhost:8080/xes-manager/Command/export?download=xesmanager_configuration.zip&configModules=Agents+Configuration,Alert%%20rules&"SessionId="%%i"
REM	FOR /F "tokens=2 delims=:{}" %%i in ('type login.htm') do curl -v -o file3.zip "http://localhost:8080/xes-manager/Command/export?download=xesmanager_configuration.zip&configModules=Agents+Configuration,Alert%%20rules" --data SessionId="%%i" --get
REM	curl -v -o file3.zip "http://localhost:8080/xes-manager/Command/export?download=xesmanager_configuration.zip&configModules=Agents%%20Configuration,Alert%%20rules" --data SessionId="%SessID%" --get
REM	FOR /F "tokens=2 delims=:{}" %%i in ('type login.htm') do wget.exe "http://%webhost%/xes-manager/Command/export?download=xesmanager_configuration.zip&configModules=Agents Configuration,Alert rules&SessionId=%%i" -O download.htm
REM	BAD	REM	FOR /F "tokens=2 delims=:{}" %%i in ('type login.htm') do wget.exe "http://%webhost%/xes-manager/Command/export?download=xesmanager_configuration.zip&configModules=Agents Configuration,Alert rules&SessionId=""%%i" -O download.htm
REM	FOR /F "tokens=2 delims=:{}" %%i in ('type login.htm') do wget.exe "http://%webhost%/xes-manager/Command/export?download=xesmanager_configuration.zip&configModules=Agents Configuration,Alert%%20rules&SessionId=%%i" -O download.htm

REM	exit /b
REM	FOR /F "tokens=2 delims=:{}" %%i in ('type login.htm') do curl -v -o file3.zip "http://localhost:8080/xes-manager/Command/export?download=xesmanager_configuration.zip&configModules=Agents%%20Configuration,Alert%%20rules" --data SessionId="%%i" --get
exit /b
wget.exe "http://%webhost%/xes-manager/Command/export?download=xesmanager_configuration.zip&configModules=Agents Configuration,Alert rules&sessionId=830426d0-4ec7-4b5f-bafd-e0489e462d29" -O download.htm

curl -O "http://localhost:8080/xes-manager/Command/export?download=xesmanager_configuration.zip&configModules=Agents%20Configuration,Alert%20rules" --data SessionId="%i" --get


REM	wget.exe -O login.htm --post-file=login.web "http://%webhost%/xes-manager/Service/Security%%20Service/login"
wget.exe -O download.htm "http://%webhost%/xes-manager/Command/export?download=xesmanager_configuration.zip&configModules=Agents Configuration,Alert rules&sessionId=830426d0-4ec7-4b5f-bafd-e0489e462d29"
wget.exe -O login.htm --post-file=login.web "http://%webhost%/xes-manager/Service/Security Service/login"
REM --post-file login.htm
