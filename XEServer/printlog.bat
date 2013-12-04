@echo off
setlocal
set logfile=%~pn1.log
shift
if "%1*" == "*" (for /L %%F in (1,1,7) do @echo. | tee -a %logfile%) & exit /b 0
echo #=========================================================================# | tee -a %logfile%
REM	echo #	%* | tee -a %logfile%
echo #	%1 %2 %3 %4 %5 %6 %7 %8 %9 | tee -a %logfile%
echo #=========================================================================# | tee -a %logfile%
