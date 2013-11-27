@REM	
@echo off
setlocal
if not defined ECHudsonBuilds set ECHudsonBuilds=%ECRootPath%\HBuilds
set ArcFile=%ECHudsonBuilds%\XEServer.zip
set ProjectPage=https://etbuild01.edifecs.local/view/8.4.0/job/XEngine Server 8.4.0/


path %~dp0;%ECRootPath%\bin\;%ECHudsonBuilds%\bin;%path%
SET XESManagerWorkspace=%XESRoot%\..\XESmanager\workspace
SET CATALINA_HOME=%XESRoot%\..\XESmanager\tomcat

:create_backup_dirs
@call %~dp0create_bkp_dirs.bat
if ERRORLEVEL 2 @echo Some directories are missing, QUIT !!! && exit /b 2

:Backup_profiles
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
@call %~dp0download_build.bat %ArcFile% "%ProjectPage%" || exit /b 1
if not exist %ECHudsonBuilds%\XEServer (@call %~dp0printbig Build download was unsuccessfull. & exit /b 1)
@echo on

:Extract

:Copy_files
copy %XESRoot%\license.lic %ECHudsonBuilds%\XEServer\

:Deploy
@call %XESroot%\bin\shutdown_all_profiles.bat
sleep 9
@call %~dp0move_bkp.bat %XESRoot%
@echo on
attrib +h %XESRoot%\profiles
move %XESRoot% %ECHudsonBuilds%\backup\ || (@call %~dp0printbig @echo Unable to move XEServer directory to %ECHudsonBuilds%\backup\. & exit /b 1)
@call %~dp0printbig XEServer moved to %ECHudsonBuilds%\backup\XEServer
move %ECHudsonBuilds%\XEServer %XESRoot% || (@call %~dp0printbig @echo Unable to move new build to XEServer directory.. & @call %~dp0printbig Trying to restore old verstion ... & (move %ECHudsonBuilds%\backup\XEServer %XESRoot% >nul && @call %~dp0printbig Old version Restored. || @call %~dp0printbig ERROR restoring previous version.) & @call %~dp0printbig !!! New version was NOT deployed !!! & exit /b 1)
@call %~dp0printbig New build deployed to %XESRoot%\

:Restore_profiles
@call %~dp0printbig Restoring profiles from image ...
@echo on
for /f %%F in ('dir %ECHudsonBuilds%\profiles\*.zip /b') do @call %EAMRoot%\Server\ConfigTool\exec\win\deploy_xescfg.bat %ECHudsonBuilds%\profiles\%%F
for /f %%F in ('dir %ECHudsonBuilds%\profiles\*.zip /b') do echo Starting profile `%%~nF` && @call %XESRoot%\bin\start.bat %%~nF <nul >nul
exit /b

