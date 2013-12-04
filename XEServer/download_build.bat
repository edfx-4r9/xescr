@REM	
@echo off
setlocal
@call %~dp0printbig Project web page: %~2
del /S /Q %ECHudsonBuilds%\%~n1 >nul
wget -q -O %~dp0link.htm --no-check-certificate "%~2" || (@call %~dp0printbig Unable to open project page on Hudson. & exit /b 23)
java.exe HudsonBuildLink <%~dp0link.htm >%~dp0link.txt || (@call %~dp0printbig Unable to parse link to build. & exit /b 23)
for /f %%F in ('type %~dp0link.txt') do set filename=%%F
echo %~2%filename% >%~dp0link.txt
@call %~dp0printbig Loading file: %filename% ...
wget -O %1 --no-check-certificate "%~2%filename%" || (@call %~dp0printbig Unable to load file. & exit /b 23)
@call %~dp0printbig Unpacking file ...
7z x %1 -y -o%~dp1\ >nul && @@call %~dp0printbig Archive is successfully unpacked. || (@call %~dp0printbig Archive is damaged. & exit /b 23)
exit /b 0

:Load_error
echo #=========================================================================#
echo #	%*
echo #=========================================================================#
