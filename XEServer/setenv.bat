@echo off
@call %~dp0printbig Checking environment variables.
if not defined ECRootPath echo ECRootPath environment variable not set && exit /b 1
if not defined XESRoot echo XESRoot environment variable not set && exit /b 1
if not defined EAMRoot echo EAMRoot environment variable not set && exit /b 1

if not defined ECRootPath set ECRootPath=C:\edifecs
if not defined ECHudsonBuilds set ECHudsonBuilds=%ECRootPath%\HBuilds
SET XESManagerWorkspace=%XESRoot%\..\XESmanager\workspace
SET CATALINA_HOME=%XESRoot%\..\XESmanager\tomcat

path %~dp0;%ECRootPath%\bin\;%ECHudsonBuilds%\bin;%path%
