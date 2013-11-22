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
call %~dp0move_bkp.bat %EAMRoot%
if ERRORLEVEL 2 echo Unable to manage backups, QUIT !!! && exit /b 2

:Backup_profiles
REM	not implemented

REM	goto extract

:Download
del %ECHudsonBuilds%\EAM*.zip 2>nul
set webfile=https://etbuild01.edifecs.local/view/8.4.0/job/EAM svn 8.4.0/lastSuccessfulBuild/artifact/trunk/build-artifacts/%1
wget --read-timeout 2 -O %ECHudsonBuilds%\EAM.zip --no-check-certificate "%webfile%"

:Extract
del /S /Q %ECHudsonBuilds%\EAM >nul
echo Extracting files in progress ...
REM	
7z x -y %ECHudsonBuilds%\EAM*.zip -o%ECHudsonBuilds%\ >nul
echo Extracting finished.

:Copy_files
for %%F in (startEAMServer.bat stopEAMServer.bat) do copy %EAMRoot%\Server\bin\%%F %ECHudsonBuilds%\EAM\Server\bin\

:Deploy
echo on
attrib +h %EAMRoot%\ReadMe.htm
move %EAMRoot% %ECHudsonBuilds%\backup\ || (echo Unable to move EAM directory. && exit /b 1)
attrib +h %EAMRoot%\..\backup\EAM
move %ECHudsonBuilds%\EAM %EAMRoot%

:Restore_profiles
REM	not implemented
