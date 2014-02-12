@echo off
if "%1*" == "*" (for /L %%F in (1,1,3) do @echo. ) & exit /b 0
@REM	echo #=========================================================================#
@REM	echo #	Lock information for dir %~dpnx1
setlocal
set OpenHandles=yes
@REM	Double qoutes in handle.exe call are FORBIDDEN (handle.exe "%~1" is incorrect)
for /F "tokens=*" %%F in ('handle %~f1 ^| %~dp0tail -n 1') do if "%%F"=="No matching handles found." set OpenHandles=no
if not %OpenHandles%==yes exit /b
echo #=========================================================================#
echo #	Lock info for dir %1
echo #
@REM	echo #=========================================================================#
%~dp0handle %~f1
echo.&&echo.
@call %~dp0printlog %~dpn0 Some files locked. Additional time delay.
%~dp0sleep 30
