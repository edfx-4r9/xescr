@REM	
@echo off
setlocal
if not defined ECHudsonBuilds set ECHudsonBuilds=%ECRootPath%\HBuilds
set ArcFile=%ECHudsonBuilds%\EAM.zip
set ProjectPage=https://etbuild01.edifecs.local/view/8.4.0/job/EAM svn 8.4.0/


path %~dp0;%ECRootPath%\bin\;%ECHudsonBuilds%\bin;%path%
REM	path C:\dev-tools\FAR;%ECRootPath%\bin\;%path%
REM	goto extract

:create_backup_dirs
@call %~dp0create_bkp_dirs.bat
if ERRORLEVEL 2 echo Some directories are missing, QUIT !!! && exit /b 2
:Managing_backups
call %~dp0move_bkp.bat %EAMRoot%
if ERRORLEVEL 2 echo Unable to manage backups, QUIT !!! && exit /b 2

:Backup_profiles
REM	not implemented

:Download
del %ECHudsonBuilds%\EAM*.zip 2>nul
@call %~dp0download_build.bat %ArcFile% "%ProjectPage%" || exit /b 1

:Extract

:Copy_files
for %%F in (startEAMServer.bat stopEAMServer.bat) do copy %EAMRoot%\Server\bin\%%F %ECHudsonBuilds%\EAM\Server\bin\ >nul

:Deploy
echo on
attrib +h %EAMRoot%\ReadMe.htm
move %EAMRoot% %ECHudsonBuilds%\backup\ || (@call %~dp0printbig Unable to move EAM directory to %ECHudsonBuilds%\backup\. & exit /b 1)
move %ECHudsonBuilds%\EAM %EAMRoot% || (@call %~dp0printbig Unable to move EAM new build directory. & exit /b 1)
@call %~dp0printbig New `EAM` build deployed to %EAMRoot%\

:Restore_profiles
REM	not implemented
