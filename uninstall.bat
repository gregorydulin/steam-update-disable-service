REM execute uninstall-service.ps1, while avoiding the $70/year script-signing requirement

REM Set scriptdir to this batch file's dir
REM https://stackoverflow.com/a/3827582/2895343
SET mypath=%~dp0
set scriptdir=%mypath:~0,-1%
echo scriptdir is "%scriptdir%"

PowerShell.exe -ExecutionPolicy Bypass -File "%scriptdir%\uninstall-service.ps1"
