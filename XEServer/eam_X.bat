@REM	
@echo off
setlocal
REM	set JAVA_HOME=C:\Java\jdk1.6.0_24
set PATH=%JAVA_HOME%\bin;%PATH%
SET ecf.feature.location=D:/Edifecs/ECF

set ECRootPath=C:\build
set EAMRoot=%ECRootPath%\EAM
set XESRoot=%ECRootPath%\XEServer
set XERoot=%ECRootPath%\XEngine
REM set XECRoot=%ECRootPath%\XEConnect


pushd %EAMRoot%\Client
start eam(64).exe 
popd
