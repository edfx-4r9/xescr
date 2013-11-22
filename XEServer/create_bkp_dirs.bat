@echo off
if not defined ECHudsonBuilds set ECHudsonBuilds=%ECRootPath%\HBuilds
if not exist %ECHudsonBuilds% mkdir %ECHudsonBuilds% 2>nul || echo Unable to create directory %ECHudsonBuilds%\ && exit /b 2
if not exist %ECHudsonBuilds%\backup mkdir %ECHudsonBuilds%\backup 2>nul || echo Unable to create directory %ECHudsonBuilds%\backup && exit /b 2
if not exist %ECHudsonBuilds%\recycler mkdir %ECHudsonBuilds%\recycler 2>nul || echo Unable to create directory %ECHudsonBuilds%\recycler && exit /b 2
if not exist %ECHudsonBuilds%\profiles mkdir %ECHudsonBuilds%\profiles 2>nul
