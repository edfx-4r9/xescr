@REM	C:\Edifecs\8.4\XEServer\features\batcher\config\ 
@REM	
@echo off
@call %~dp0printbig >>%~dp0deploy.log
@call %~dp0printbig %date% %time% >>%~dp0deploy.log
@call %~dp0printbig Starting %~f0 >>%~dp0deploy.log
@call %~dp0printlog %~dpn0
@call %~dp0printlog %~dpn0 %date% %time%
@call %~dp0printlog %~dpn0 Starting deploy script %~f0


setlocal
@call %~dp0setenv.bat | tee -a %~dpn0.log
if ERRORLEVEL 1 @call %~dp0printlog %~dpn0 Some environment variables are not set, QUIT !!! && exit /b 2
if not defined ECHudsonBuilds set ECHudsonBuilds=%ECRootPath%\HBuilds
set ArcFile=%ECHudsonBuilds%\XEServer.zip
set ProjectPage=https://etbuild01.edifecs.local/view/8.4.0/job/XEngine Server 8.4.0/
@REM	set ProjectPage=https://etbuild01.edifecs.local/view/8.4.0/job/XEngine Server 8.4.0/lastSuccessfulBuild/artifact/

path %~dp0;%ECRootPath%\bin\;%ECHudsonBuilds%\bin;%path%
SET XESManagerWorkspace=%XESRoot%\..\XESmanager\workspace
SET CATALINA_HOME=%XESRoot%\..\XESmanager\tomcat

:create_backup_dirs
@call %~dp0create_bkp_dirs.bat | tee -a %~dpn0.log
if ERRORLEVEL 1 @call %~dp0printlog %~dpn0 Some directories are missing, QUIT !!! && exit /b 2

:Backups
@call %~dp0move_bkp.bat %XESRoot% | tee -a %~dpn0.log
@call %~dp0move_bkp.bat statistics | tee -a %~dpn0.log


:Backup_profiles
@call %~dp0printlog %~dpn0 Creating image with profiles ...
mkdir %ECHudsonBuilds% 2>nul
mkdir %ECHudsonBuilds%\profiles 2>nul
mkdir %ECHudsonBuilds%\backup 2>nul
move %ECHudsonBuilds%\profiles\*.zip %ECHudsonBuilds%\backup\ 2>nul
@call %~dp0printlog %~dpn0 Creating profiles ... >>%ECHudsonBuilds%\profiles\profiles_backup.txt
for /f %%F in ('dir /b %XESRoot%\profiles') do @echo %%F >>%ECHudsonBuilds%\profiles\profiles_backup.txt
for /f %%F in ('dir /b %XESRoot%\profiles') do call echo y | "%EAMRoot%\Server\ConfigTool\exec\win\cfgtool.bat" -s ${XESRoot}/profiles/%%F -d %ECHudsonBuilds%\profiles\%%F.zip >>%ECHudsonBuilds%\profiles\profiles_backup.txt
mkdir %ECHudsonBuilds%\statistics\ > nul
xcopy /Y /E %XESRoot%\statistics %ECHudsonBuilds%\statistics\ >nul


:Download
if "%~1*" == "cache*" (set ProjectPage=cache) else del %ECHudsonBuilds%\XEServer*.zip 2>nul
(@call %~dp0download_build.bat %ArcFile% "%ProjectPage%" | tee -a %~dpn0.log) || exit /b 53
if not exist %ECHudsonBuilds%\XEServer (@call %~dp0printlog %~dpn0 Build download was unsuccessfull. & exit /b 1)
@echo on

:Extract

:Copy_files
copy %XESRoot%\license.lic %ECHudsonBuilds%\XEServer\
copy %XESRoot%\features\batcher\config\*.properties %ECHudsonBuilds%\XEServer\features\batcher\config\ 
mkdir %ECHudsonBuilds%\XEServer\statistics\ 2>nul
xcopy /Y /E %XESRoot%\statistics %ECHudsonBuilds%\XEServer\statistics\ >nul
copy %XESRoot%\platform\etc\startup.ini %ECHudsonBuilds%\XEServer\platform\etc\startup.ini

:Deploy
@call %~dp0printlog %~dpn0 Stopping EAM Service ...
@REM	
net1 stop EAMService
@call %~dp0printlog %~dpn0 Stopping XEServer ...
@call %XESroot%\bin\shutdown_all_profiles.bat || @call %~dp0printlog Unable to complete profiles shutdown.

sleep 29
@REM	@call %~dp0printlog %~dpn0 File locks information ...
@REM	handle %XESRoot%\ >>%~dpn0.log
@call %~dp0lockinfo %XESRoot%\ >>%~dpn0.log
@echo on
echo.&echo.&@call %~dp0printlog %~dpn0 Trying to move XEServer to backup directory ...
move %XESRoot% %ECHudsonBuilds%\backup\ || (@call %~dp0printlog %~dpn0 Unable to move XEServer directory to %ECHudsonBuilds%\backup\. & exit /b 1)
@call %~dp0printlog %~dpn0 XEServer moved to %ECHudsonBuilds%\backup\XEServer
echo.&echo.&@call %~dp0printlog %~dpn0 Deploying new XEServer build to directory %XESRoot% ...
move %ECHudsonBuilds%\XEServer %XESRoot% || (@call %~dp0printlog %~dpn0 Unable to move new build to XEServer directory.. & @call %~dp0printlog %~dpn0 Trying to restore old verstion ... & (move %ECHudsonBuilds%\backup\XEServer %XESRoot% >nul && @call %~dp0printlog %~dpn0 Old version Restored. || @call %~dp0printlog %~dpn0 ERROR restoring previous version.) & @call %~dp0printlog %~dpn0 !!! New version was NOT deployed !!! & exit /b 1)
@call %~dp0printlog %~dpn0 New build deployed to %XESRoot%\

:Restore_profiles
@call %~dp0printlog %~dpn0 Restoring profiles from image ...
@echo on
for /f %%F in ('dir %ECHudsonBuilds%\profiles\*.zip /b') do @call %EAMRoot%\Server\ConfigTool\exec\win\deploy_xescfg.bat %ECHudsonBuilds%\profiles\%%F
@REM	for /f %%F in ('dir %ECHudsonBuilds%\profiles\*.zip /b') do echo Starting profile `%%~nF` && @call %XESRoot%\bin\start.bat %%~nF <nul >nul
for /f %%F in ('dir /b %XESRoot%\profiles') do echo Starting profile `%%~nF` && @call %XESRoot%\bin\start.bat %%~nF <nul >nul && echo delay 45 sec. && sleep 45

@call %~dp0printlog %~dpn0 Deploy finished.
sleep 10

@call %~dp0printbig Finished %~f0 at %time% >>%~dp0deploy.log
exit /b

