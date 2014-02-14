@REM 
@echo off
@if not defined ECHudsonBuilds set ECHudsonBuilds=%ECRootPath%\HBuilds
mkdir %ECHudsonBuilds% 2>nul
mkdir %ECHudsonBuilds%\backup 2>nul
mkdir %ECHudsonBuilds%\recycler 2>nul

@call %~dp0printbig Organizing backup versions for %~nx1.
@if exist %ECHudsonBuilds%\recycler\%~nx1 echo Found trash.
@if exist %ECHudsonBuilds%\backup\%~nx1 echo Found backup copy.
@if exist %ECHudsonBuilds%\recycler\%~nx1 if exist %ECHudsonBuilds%\backup\%~nx1 echo Removing trash ... && rmdir /S /Q %ECHudsonBuilds%\recycler\%~nx1 >nul
@if exist %ECHudsonBuilds%\backup\%~nx1 echo Sending backup to trash ... && move %ECHudsonBuilds%\backup\%~nx1 %ECHudsonBuilds%\recycler\ >nul
exit /b

echo Sending %1 to backup
move %1 %ECHudsonBuilds%\backup\ >nul

exit /b

