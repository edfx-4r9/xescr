@REM	
@echo off
REM	setlocal
@call %~dp0printbig >>%~dp0deploy.log
@call %~dp0printbig %date% %time% >>%~dp0deploy.log
@call %~dp0printbig Starting %~f0 >>%~dp0deploy.log
@call %~dp0printlog %~dpn0
@call %~dp0printlog %~dpn0 %date% %time%
@call %~dp0printlog %~dpn0 Starting deploy script %~f0


@call %~dp0setenv.bat | tee -a %~dpn0.log
if ERRORLEVEL 1 @call %~dp0printlog %~dpn0 Some environment variables are not set, QUIT !!! && exit /b 2
set x
REM	pause
if not defined ECHudsonBuilds set ECHudsonBuilds=%ECRootPath%\HBuilds
set ArcFile=%ECHudsonBuilds%\EAM.zip
set ProjectPage=https://etbuild01.edifecs.local/view/8.4.0/job/EAM svn 8.4.0/


path %~dp0;%ECRootPath%\bin\;%ECHudsonBuilds%\bin;%path%
SET XESManagerWorkspace=%XESRoot%\..\XESmanager\workspace
SET CATALINA_HOME=%XESRoot%\..\XESmanager\tomcat

:create_backup_dirs
@call %~dp0create_bkp_dirs.bat
if ERRORLEVEL 1 @call %~dp0printlog %~dpn0 Some directories are missing, QUIT !!! && exit /b 2
:Managing_backups
call %~dp0move_bkp.bat %EAMRoot%
if ERRORLEVEL 2 echo Unable to manage backups, QUIT !!! && exit /b 2

:Backup_profiles
REM	not implemented

:Download
del %ECHudsonBuilds%\EAM*.zip 2>nul
(@call %~dp0download_build.bat %ArcFile% "%ProjectPage%" | tee -a %~dpn0.log) || exit /b 1

:Extract

:Copy_files
for %%F in (startEAMServer.bat stopEAMServer.bat) do copy %EAMRoot%\Server\bin\%%F %ECHudsonBuilds%\EAM\Server\bin\ >nul
copy %XESRoot%\features\batcher\config\db_1.properties  %ECHudsonBuilds%\XEServer\features\batcher\config\ 

:Deploy
sleep 2
@call %~dp0lockinfo %EAMRoot%\ >>%~dpn0.log
@REM	echo on
echo.&echo.&@call %~dp0printlog %~dpn0 Trying to move EAM to backup directory ...
move %EAMRoot% %ECHudsonBuilds%\backup\ || (@call %~dp0printlog %~dpn0 Unable to move EAM directory to %ECHudsonBuilds%\backup\. & exit /b 1)
@call %~dp0printlog %~dpn0 EAM moved to %ECHudsonBuilds%\backup\EAM
echo.&echo.&@call %~dp0printlog %~dpn0 Deploying new EAM build to directory %EAMRoot% ...
move %ECHudsonBuilds%\EAM %EAMRoot% || (@call %~dp0printlog %~dpn0 Unable to move EAM new build directory. & exit /b 1)
@call %~dp0printlog %~dpn0 New `EAM` build deployed to %EAMRoot%\

:Restore_profiles
REM	not implemented

@call %~dp0printbig Finished %~f0 at %time% >>%~dp0deploy.log
