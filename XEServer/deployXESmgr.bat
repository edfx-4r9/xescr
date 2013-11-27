@REM	
@echo off
setlocal
if not defined ECHudsonBuilds set ECHudsonBuilds=%ECRootPath%\HBuilds
set ArcFile=%ECHudsonBuilds%\XESManager.zip
set ProjectPage=https://etbuild01.edifecs.local/view/8.4.0/job/XES Manager 8.4.0/


path %~dp0;%ECRootPath%\bin\;%ECHudsonBuilds%\bin;%path%
SET XESManagerWorkspace=%XESRoot%\..\XESmanager\workspace
SET CATALINA_HOME=%XESRoot%\..\XESmanager\tomcat

:create_backup_dirs
@call %~dp0create_bkp_dirs.bat
if ERRORLEVEL 1 @call %~dp0printbig Some directories are missing, QUIT !!! && exit /b 2

:Backup_profiles
@call %~dp0config_download.bat %ECHudsonBuilds%\workspace\xesmanager_configuration.zip
if ERRORLEVEL 1 @call %~dp0printbig Unable to create configuration backup file %ECHudsonBuilds%\workspace\xesmanager_configuration.zip & exit /b 1

:Download
del %ECHudsonBuilds%\XESManager*.zip 2>nul
set webfile=https://etbuild01.edifecs.local/view/8.4.0/job/XES Manager 8.4.0/lastSuccessfulBuild/artifact/xes-manager/target/%1
@call %~dp0download_build.bat %ArcFile% "%ProjectPage%" || exit /b 1
if not exist %ECHudsonBuilds%\XESManager (@call %~dp0printbig Build download was unsuccessfull. & exit /b 1)
if ERRORLEVEL 1 @call %~dp0printbig Error during build download / unpack. & exit /b 1

:Backup_alerts
echo %CATALINA_HOME%\bin\shutdown.bat
call %CATALINA_HOME%\bin\shutdown.bat
@call %~dp0printbig Delay ... waiting Tomcat to stop.
sleep 30
mkdir %ECHudsonBuilds%\workspace\ 2>nul
mkdir %ECHudsonBuilds%\workspace\alerts\ 2>nul
copy %XESRoot%\..\XESManager\workspace\alerts\* %ECHudsonBuilds%\workspace\alerts\ >nul
copy %XESRoot%\..\XESManager\workspace\perms.h2.db %ECHudsonBuilds%\workspace\ >nul

:Extract

:Copy_files
mkdir %ECHudsonBuilds%\XESManager\workspace\alerts\
copy %XESRoot%\..\XESManager\workspace\alerts\* %ECHudsonBuilds%\XESManager\workspace\alerts\ >nul
copy %XESRoot%\..\XESManager\workspace\perms.h2.db %ECHudsonBuilds%\XESManager\workspace\ >nul

:Deploy
call %~dp0move_bkp.bat %XESRoot%\..\XESManager
attrib +h %XESRoot%\..\XESManager\bin
echo.&echo.&@call %~dp0printbig Trying to move XESManager to backup directory ...
	
@REM	echo on
move %XESRoot%\..\XESManager %ECHudsonBuilds%\backup\ || (@call %~dp0printbig Unable to move XESManager directory to %ECHudsonBuilds%\backup\. & call %CATALINA_HOME%\bin\startup.bat >nul && exit /b 1)
echo.&echo.&@call %~dp0printbig XESManager moved to %ECHudsonBuilds%\backup\XESManager
echo.&echo.&@call %~dp0printbig Deploying new XESManager build to directory %XESRoot%\..\XESManager ...
move %ECHudsonBuilds%\XESManager %XESRoot%\..\XESManager >nul || (@call %~dp0printbig Unable to move new build to XESManager directory. & @call %~dp0printbig Trying to restore old verstion ... & (move %ECHudsonBuilds%\backup\XESmanager %XESRoot%\..\XESManager >nul && @call %~dp0printbig Old version Restored. || @call %~dp0printbig ERROR restoring previous version.) & @call %~dp0printbig !!! New version was NOT deployed !!! && call %CATALINA_HOME%\bin\startup.bat >nul & exit /b 1)
@call %~dp0printbig New build deployed to %XESRoot%\..\XESmanager\
@call %CATALINA_HOME%\bin\startup.bat

:Restore_profiles
@call %~dp0printbig Delay ... waiting Tomcat to start properly.
sleep 30
@call %~dp0config_upload.bat %ECHudsonBuilds%\workspace\xesmanager_configuration.zip
