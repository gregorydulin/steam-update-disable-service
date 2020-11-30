# Download and install winsw, then use it to periodically run our script

# Turn debugging on/off
$DebugPreference = "Continue"

# Set vars
$installdir = "$Env:ProgramFiles\steam-update-disable-service"
Write-Debug $installdir

# uninstall service
& $installdir\steam-update-disable-service.exe stop
Write-Debug "LastExitCode $LastExitCode"
& $installdir\steam-update-disable-service.exe uninstall
Write-Debug "LastExitCode $LastExitCode"
if ($LASTEXITCODE -ne 0) { throw "Couldn't uninstall.  Exit code is $LASTEXITCODE" }

# Ensure installdir is removed
if (Test-Path $installdir) {
  Remove-Item -LiteralPath "$installdir" -Force -Recurse
}

