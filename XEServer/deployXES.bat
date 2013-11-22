@REM	
@echo off
setlocal
if not defined ECHudsonBuilds set ECHudsonBuilds=%ECRootPath%\HBuilds
path C:\dev-tools\FAR;%ECRootPath%\bin\;%ECHudsonBuilds%\bin;%path%
REM	goto Deploy

:create_backup_dirs
@call %~dp0create_bkp_dirs.bat
if ERRORLEVEL 2 @echo Some directories are missing, QUIT !!! && exit /b 2

:Backup_profiles
@REM @echo Creating image with profiles ...
@call %~dp0printbig Creating image with profiles ...
mkdir %ECHudsonBuilds% 2>nul
mkdir %ECHudsonBuilds%\profiles 2>nul
mkdir %ECHudsonBuilds%\backup 2>nul
move %ECHudsonBuilds%\profiles\*.zip %ECHudsonBuilds%\backup\ 2>nul
@call %~dp0printbig Creating profiles ... >>%ECHudsonBuilds%\profiles\profiles_backup.txt
for /f %%F in ('dir /b %XESRoot%\profiles') do @echo %%F >>%ECHudsonBuilds%\profiles\profiles_backup.txt
for /f %%F in ('dir /b %XESRoot%\profiles') do call echo y | "%EAMRoot%\Server\ConfigTool\exec\win\cfgtool.bat" -s ${XESRoot}/profiles/%%F -d %ECHudsonBuilds%\profiles\%%F.zip >>%ECHudsonBuilds%\profiles\profiles_backup.txt

:Download
del %ECHudsonBuilds%\XEServer*.zip 2>nul
set webfile=https://etbuild01.edifecs.local/view/8.4.0/job/XEngine Server 8.4.0/lastSuccessfulBuild/artifact/build-artifacts/%1
@REM	wget --read-timeout 2 -O %ECHudsonBuilds%\XEServer.zip --no-check-certificate "%webfile%"
@call %~dp0download %ECHudsonBuilds%\XEServer.zip "%webfile%" || exit /b 2

:Extract
del /S /Q %ECHudsonBuilds%\XEServer >nul
@REM @echo Extracting files in progress ...
@call %~dp0printbig Extracting files in progress ...
@REM	
7z x -y %ECHudsonBuilds%\XEServer*.zip -o%ECHudsonBuilds%\ >nul
@echo Extracting finished.
copy %XESRoot%\license.lic %ECHudsonBuilds%\XEServer\

:Deploy

@call %XESroot%\bin\shutdown_all_profiles.bat
sleep 3
@call %XESRoot%\..\XESManager\bin\stop.bat
sleep 9
@call %~dp0move_bkp.bat %XESRoot%
@echo on
@REM	attrib +h %XESRoot% && REM	This makes FAIL to move this directory with error "The system cannot find the file specified."
attrib +h %XESRoot%\profiles
move %XESRoot% %ECHudsonBuilds%\backup\ || (@call %~dp0printbig @echo Unable to move XEServer directory to %ECHudsonBuilds%\backup\. & exit /b 1)
@REM @echo.&@echo XEServer moved to %ECHudsonBuilds%\backup\XEServer
@call %~dp0printbig XEServer moved to %ECHudsonBuilds%\backup\XEServer
move %ECHudsonBuilds%\XEServer %XESRoot% || (@call %~dp0printbig @echo Unable to move new build to XEServer directory. & exit /b 1)
@call %~dp0printbig New build deployed to %XESRoot%\
@call %XESRoot%\..\XESManager\bin\start.bat
sleep 30

:Restore_profiles
@call %~dp0printbig Restoring profiles from image ...
for /f %%F in ('dir %ECHudsonBuilds%\profiles\*.zip /b') do @call %EAMRoot%\Server\ConfigTool\exec\win\deploy_xescfg.bat %ECHudsonBuilds%\profiles\%%F
for /f %%F in ('dir %ECHudsonBuilds%\profiles\*.zip /b') do echo %%~nF && @call %XESRoot%\bin\start.bat %%~nF <nul
exit /b

@call %XESRoot%\bin\agent\start-agent.bat
@call %XESRoot%\system\exec.bat com.edifecs.etools.xeserver.bootstrap.XESStarter lessons -wait

