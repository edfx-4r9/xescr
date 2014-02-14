@REM	
@echo off
@call %~dp0printbig >>%~dp0deploy.log
@call %~dp0printbig %date% %time% >>%~dp0deploy.log
@call %~dp0printbig Starting %~f0 >>%~dp0deploy.log
@call %~dp0printlog %~dpn0
@call %~dp0printlog %~dpn0 %date% %time%
@call %~dp0printlog %~dpn0 Starting deploy script %~f0


REM	setlocal
echo ---
REM	@call 
%~dp0setenv.bat | tee -a %~dpn0.log


set ECRootPath=C:\edifecs\8
set XESRoot=%ECRootPath%\XEServer
set EAMRoot=%ECRootPath%\EAM
if not defined ECHudsonBuilds set ECHudsonBuilds=%ECRootPath%\HBuilds
SET XESManagerWorkspace=%XESRoot%\..\XESmanager\workspace
SET CATALINA_HOME=%XESRoot%\..\XESmanager\tomcat


echo ECRootPath == %ECRootPath%
echo %XESRoot%
echo %EAMRoot%
echo ECHudsonBuilds == %ECHudsonBuilds%

REM	echo %ECHudsonBuilds%
REM	echo %ECRootPath%
REM	exit /b
if ERRORLEVEL 1 @call %~dp0printlog %~dpn0 Some environment variables are not set, QUIT !!! && exit /b 2
if not defined ECHudsonBuilds set ECHudsonBuilds=%ECRootPath%\HBuilds
set ArcFile=%ECHudsonBuilds%\XEServer.zip
set ProjectPage=https://etbuild01.edifecs.local/view/8.4.0/job/XEngine Server 8.4.0/

path %~dp0;%ECRootPath%\bin\;%ECHudsonBuilds%\bin;%path%

:create_backup_dirs

:Backups

:Backup_profiles

:Download
if "%~1*" == "cache*" (set ProjectPage=cache) else del %ECHudsonBuilds%\XEServer*.zip 2>nul
set webfile=https://etbuild01.edifecs.local/view/8.4.0/job/XEngine Server 8.4.0/lastSuccessfulBuild/artifact/build-artifacts/%1
(@call %~dp0download_build.bat %ArcFile% "%ProjectPage%" | tee -a %~dpn0.log) || exit /b 53
if not exist %ECHudsonBuilds%\XEServer (@call %~dp0printlog %~dpn0 Build download was unsuccessfull. & exit /b 1)

:Extract

:Copy_files
copy %XESRoot%\license.lic %ECHudsonBuilds%\XEServer\

:Deploy
@call %~dp0printlog %~dpn0 Stopping XEServer ...
@call %XESroot%\bin\shutdown_all_profiles.bat
sleep 29
echo.&echo.&@call %~dp0printlog %~dpn0 Deploying new XEServer build to directory %XESRoot% ...
move %ECHudsonBuilds%\XEServer %XESRoot% || (@call %~dp0printlog %~dpn0 Unable to move new build to XEServer directory.. & @call %~dp0printlog %~dpn0 !!! XEServer was NOT deployed !!! & exit /b 1)
@call %~dp0printlog %~dpn0 New build deployed to %XESRoot%\

:Restore_profiles
@call %~dp0printlog %~dpn0 Restoring profiles from image ...
@echo on
for /f %%F in ('dir %ECHudsonBuilds%\profiles\*.zip /b') do @call %EAMRoot%\Server\ConfigTool\exec\win\deploy_xescfg.bat %ECHudsonBuilds%\profiles\%%F
for /f %%F in ('dir %ECHudsonBuilds%\profiles\*.zip /b') do echo Starting profile `%%~nF` && @call %XESRoot%\bin\start.bat %%~nF <nul >nul

:Final
@call %~dp0printlog %~dpn0 Deploy finished.
sleep 10
exit /b

