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
set ArcFile=%ECHudsonBuilds%\XESManager.zip
set ProjectPage=https://etbuild01.edifecs.local/view/8.4.0/job/XES Manager 8.4.0/

path %~dp0;%ECRootPath%\bin\;%ECHudsonBuilds%\bin;%path%
SET XESManagerWorkspace=%XESRoot%\..\XESmanager\workspace
SET CATALINA_HOME=%XESRoot%\..\XESmanager\tomcat

:create_backup_dirs
@call %~dp0create_bkp_dirs.bat | tee -a %~dpn0.log
if ERRORLEVEL 1 @call %~dp0printlog %~dpn0 Some directories are missing, QUIT !!! && exit /b 2

:Backups
@call %~dp0move_bkp.bat %XESRoot%\..\XESManager | tee -a %~dpn0.log


:Backup_profiles
@call %~dp0printlog %~dpn0 Downloading configuration (alerts, agents, etc.) ...
@call %~dp0config_download.bat %ECHudsonBuilds%\workspace\xesmanager_configuration.zip
if ERRORLEVEL 1 @call %~dp0printlog %~dpn0 Unable to create configuration backup file %ECHudsonBuilds%\workspace\xesmanager_configuration.zip & exit /b 1

:Download
del %ECHudsonBuilds%\XESManager*.zip 2>nul
set webfile=https://etbuild01.edifecs.local/view/8.4.0/job/XES Manager 8.4.0/lastSuccessfulBuild/artifact/xes-manager/target/%1
(@call %~dp0download_build.bat %ArcFile% "%ProjectPage%" | tee -a %~dpn0.log) || exit /b 1
if not exist %ECHudsonBuilds%\XESManager (@call %~dp0printlog %~dpn0 Build download was unsuccessfull. & exit /b 1)
if ERRORLEVEL 1 @call %~dp0printlog %~dpn0 Error during build download / unpack. & exit /b 1

:Backup_alerts
@call %~dp0printlog %~dpn0 Stopping Tomcat application.
echo %CATALINA_HOME%\bin\shutdown.bat
call %CATALINA_HOME%\bin\shutdown.bat
@call %~dp0printlog %~dpn0 Delay ... waiting Tomcat to stop.
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
attrib +h %XESRoot%\..\XESManager\bin
echo.&echo.&@call %~dp0printlog %~dpn0 Trying to move XESManager to backup directory ...
	
@REM	echo on
move %XESRoot%\..\XESManager %ECHudsonBuilds%\backup\ || (@call %~dp0printlog %~dpn0 Unable to move XESManager directory to %ECHudsonBuilds%\backup\. & call %CATALINA_HOME%\bin\startup.bat >nul && exit /b 1)
echo.&echo.&@call %~dp0printlog %~dpn0 XESManager moved to %ECHudsonBuilds%\backup\XESManager
echo.&echo.&@call %~dp0printlog %~dpn0 Deploying new XESManager build to directory %XESRoot%\..\XESManager ...
move %ECHudsonBuilds%\XESManager %XESRoot%\..\XESManager >nul || (@call %~dp0printlog %~dpn0 Unable to move new build to XESManager directory. & @call %~dp0printlog %~dpn0 Trying to restore old verstion ... & (move %ECHudsonBuilds%\backup\XESmanager %XESRoot%\..\XESManager >nul && @call %~dp0printlog %~dpn0 Old version Restored. || @call %~dp0printlog %~dpn0 ERROR restoring previous version.) & @call %~dp0printlog %~dpn0 !!! New version was NOT deployed !!! && call %CATALINA_HOME%\bin\startup.bat >nul & exit /b 1)
@call %~dp0printlog %~dpn0 New build deployed to %XESRoot%\..\XESmanager\
@REM	start cmd /c %CATALINA_HOME%\bin\startup.bat >nul 2>nul
@call %CATALINA_HOME%\bin\startup.bat >nul

:Restore_profiles
@call %~dp0printlog %~dpn0 Delay ... waiting Tomcat to start properly.
sleep 30
@call %~dp0printlog %~dpn0 Uploading configuration (alerts, agents, etc.) ...
@call %~dp0config_upload.bat %ECHudsonBuilds%\workspace\xesmanager_configuration.zip
if ERRORLEVEL 1 @call %~dp0printlog %~dpn0 Configuration upload FAILED. && sleep 10 && exit /b 2
@call %~dp0printlog %~dpn0 Configuration SUCCESSFULLY uploaded.
@call %~dp0printbig Script finished.

@call %~dp0printlog %~dpn0 Deploy finished.
sleep 10
exit /b
