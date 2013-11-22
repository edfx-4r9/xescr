@echo off
wget --read-timeout 2 -O %1 --no-check-certificate "%~2" || (call :Load_error Unable to load file. & exit /b 2)
7z t %1 >nul || (call :Load_error Archive is damaged. & exit /b 2)
exit /b 0

:Load_error
echo #=========================================================================#
echo #	%*
echo #=========================================================================#
