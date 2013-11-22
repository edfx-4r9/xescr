@REM	
@echo off
setlocal
if not defined ECHudsonBuilds set ECHudsonBuilds=%ECRootPath%\HBuilds
path C:\dev-tools\FAR;%ECRootPath%\bin\;%ECHudsonBuilds%\bin;%path%
REM	path C:\dev-tools\FAR;%ECRootPath%\bin\;%path%
REM	goto extract

:create_backup_dirs
@call %~dp0create_bkp_dirs.bat
if ERRORLEVEL 2 echo Some directories are missing, QUIT !!! && exit /b 2

:Backup_profiles
REM	not implenented
REM	
REM	File xesmanager_configuration.zip should be saved in directory other than %ECHudsonBuilds%\
REM	File xesmanager_configuration.zip has the same mask xesmanager*.zip
REM     Attention!!! It will be deleted by mask from %ECHudsonBuilds%\
@call %~dp0config_download.bat %ECHudsonBuilds%\workspace\xesmanager_configuration.zip
pause

REM	echo %1
echo "https://etbuild01.edifecs.local/view/8.4.0/job/XES Manager 8.4.0/lastSuccessfulBuild/artifact/xes-manager/target/%1"

:Backup_alerts
@call %XESRoot%\..\XESManager\bin\stop.bat
mkdir %ECHudsonBuilds%\workspace\ >nul
mkdir %ECHudsonBuilds%\workspace\alerts\ >nul
copy %XESRoot%\..\XESManager\workspace\alerts\* %ECHudsonBuilds%\workspace\alerts\ >nul
copy %XESRoot%\..\XESManager\workspace\perms.h2.db %ECHudsonBuilds%\workspace\ >nul

:Download
del %ECHudsonBuilds%\XESManager*.zip 2>nul
set webfile=https://etbuild01.edifecs.local/view/8.4.0/job/XES Manager 8.4.0/lastSuccessfulBuild/artifact/xes-manager/target/%1
wget --read-timeout 2 -O %ECHudsonBuilds%\XESManager.zip --no-check-certificate "%webfile%"

:Extract
del /S /Q %ECHudsonBuilds%\XESManager >nul
echo Extracting files in progress ...
REM	
7z x -y %ECHudsonBuilds%\XESManager*.zip -o%ECHudsonBuilds%\ >nul
echo Extracting finished.
REM	pause

echo on
mkdir %ECHudsonBuilds%\XESManager\workspace\alerts\
copy %XESRoot%\..\XESManager\workspace\alerts\* %ECHudsonBuilds%\XESManager\workspace\alerts\ >nul
copy %XESRoot%\..\XESManager\workspace\perms.h2.db %ECHudsonBuilds%\XESManager\workspace\ >nul
REM	pause

:Deploy
call %~dp0move_bkp.bat %XESRoot%\..\XESManager
REM	call %XESRoot%\..\XESManager\bin\stop.bat
REM	pause && REM	We need some delay here, otherwise moving directory will be denied.
attrib +h %XESRoot%\..\XESManager\bin
echo.&echo Trying to move XESManager to backup directory ...
REM	
echo on
move %XESRoot%\..\XESManager %ECHudsonBuilds%\backup\ || (echo Unable to move XESManager directory to %ECHudsonBuilds%\backup\. && call %XESRoot%\..\XESManager\bin\start.bat && exit /b 1)
echo.&echo XESManager moved to %ECHudsonBuilds%\backup\XESManager
REM attrib +h %ECHudsonBuilds%\backup\XESManager
move %ECHudsonBuilds%\XESManager %XESRoot%\..\XESManager || (@call printbig Unable to move new build to XESManager directory. & @call printbig Trying to restore old verstion ... & pause && (move %ECHudsonBuilds%\backup\XESmanager %XESRoot%\..\XESManager && @call printbig Old version Restored. || @call printbig ERROR restoring previous version.) & @call printbig !!! New version was NOT deployed !!! && call %XESRoot%\..\XESManager\bin\start.bat & exit /b 1)
@call printbig New build deployed to %XESRoot%\..\XESmanager\
@REM	pause
call %XESRoot%\..\XESManager\bin\start.bat

:Restore_profiles
REM	We probably need some delay here too.
REM	not implemented
@REM	
pause
@call %~dp0config_upload.bat %ECHudsonBuilds%\workspace\xesmanager_configuration.zip
