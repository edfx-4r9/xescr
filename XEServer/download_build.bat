@REM	
@echo off
setlocal
del /S /Q %ECHudsonBuilds%\%~n1 >nul
wget -q -O %~dp0link.htm --no-check-certificate "%~2" || (call :Load_error Unable to open project page on Hudson. & exit /b 2)
java.exe HudsonBuildLink <%~dp0link.htm >%~dp0link.txt
for /f %%F in ('type %~dp0link.txt') do set filename=%%F
echo %~2%filename% >%~dp0link.txt
@call :Load_error Loading file: %filename% ...
wget -O %1 --no-check-certificate "%~2%filename%" || (call :Load_error Unable to load file. & exit /b 2)
@call :Load_error Unpacking file ...
7z x %1 -y -o%~dp1\ >nul && @call :Load_error Archive is successfully unpacked. || (call :Load_error Archive is damaged. & exit /b 3)
exit /b 0

:Load_error
echo #=========================================================================#
echo #	%*
echo #=========================================================================#
