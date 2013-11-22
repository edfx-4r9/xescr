@echo off
path C:\dev-tools\FAR;C:\Edifecs\bin\;%path%

echo %0
echo %*
echo %0 %*
REM	

mkdir %XESRoot%\..\backup
mkdir C:\Edifecs\bin\backup
move C:\Edifecs\bin\*.zip C:\Edifecs\bin\backup\

REM	del XEServer*.zip
REM	del /S /Q C:\Edifecs\bin\bin\XEServer
REM	wget --no-check-certificate "https://etbuild01.edifecs.local/view/8.4.0/job/XEngine Server 8.4.0/lastSuccessfulBuild/artifact/build-artifacts/XEServer_8.4.0.3756_20131110.zip"
REM	
7z x -y XEServer*.zip
copy %XESRoot%\license.lic XEServer\
exit /b

call echo y | "%EAMRoot%\Server\ConfigTool\exec\win\cfgtool.bat" -s ${XESRoot}/profiles/pr-270-271 -d C:\Edifecs\bin\profiles-pr-270-271.zip
REM echo %errorlevel%
call echo y | "%EAMRoot%\Server\ConfigTool\exec\win\cfgtool.bat" -s ${XESRoot}/profiles/lessons -d C:\Edifecs\bin\profiles-lessons.zip
call %XESroot%\bin\shutdown_all_profiles.bat
REM %XESroot%\bin\stop.bat
REM %XESroot%\bin\start.bat pr-270-271
REM call %XESroot%\bin\start.bat lessons
exit /b
%EAMRoot%\Server\ConfigTool\exec\win\deploy_xescfg.bat C:\Edifecs\bin\profiles-lessons.zip -profile lessons
%XESroot%\bin\system\exec.bat com.edifecs.etools.xeserver.bootstrap.XESStarter lessons -wait

del XESManager.*-SNAPSHOT.*.zip
wget --no-check-certificate "https://etbuild01.edifecs.local/view/8.4.0/job/XES%20Manager%208.4.0/lastSuccessfulBuild/artifact/xes-manager/target/XESManager.8.4.0.0-SNAPSHOT.162.zip"
wget --no-check-certificate "https://etbuild01.edifecs.local/view/8.4.0/job/XES Manager 8.4.0/lastSuccessfulBuild/artifact/xes-manager/target/XESManager.8.4.0.0-SNAPSHOT.162.zip"
wget --no-check-certificate "https://etbuild01.edifecs.local/view/8.4.0/job/XEngine Server 8.4.0/lastSuccessfulBuild/artifact/build-artifacts/XEServer_8.4.0.3756_20131110.zip"
wget --no-check-certificate "https://etbuild01.edifecs.local/view/8.4.0/job/EAM svn 8.4.0/lastSuccessfulBuild/artifact/trunk/build-artifacts/EAM_8.4.0.5344_20131108.zip"

REM	Connecting to etbuild01.edifecs.local|10.30.18.30|:443... connected.                                                       
REM	ERROR: cannot verify etbuild01.edifecs.local's certificate, issued by `/C=US/ST=WA/L=XES/O=Edifecs/OU=Edifecs/CN=ETBuild': 
REM	  Self-signed certificate encountered.                                                                                     
REM	ERROR: certificate common name `ETBuild' doesn't match requested host name `etbuild01.edifecs.local'.                      

REM	Connecting to etbuild01.edifecs.local|10.30.18.30|:443... connected.                                                                                                 
REM	WARNING: cannot verify etbuild01.edifecs.local's certificate, issued by `/C=US/ST=WA/L=XES/O=Edifecs/OU=Edifecs/CN=ETBuild':                                         
REM	  Self-signed certificate encountered.                                                                                                                               
REM	WARNING: certificate common name `ETBuild' doesn't match requested host name `etbuild01.edifecs.local'.                                                              
REM	HTTP request sent, awaiting response... 404 Not Found                                                                                                                
REM	2013-11-11 05:22:50 ERROR 404: Not Found.                                                                                                                            
                                                                                                                                                                     
del /S /Q C:\Edifecs\bin\bin\XESmanager
7z x -y XESManager.*-SNAPSHOT.*.zip
%XESRoot%\..\XESManager\bin\stop.bat
