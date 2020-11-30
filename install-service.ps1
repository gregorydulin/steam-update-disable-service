# Download and install winsw, then use it to periodically run our script

# Turn debugging on/off
$DebugPreference = "Continue"

# Set vars
$installdir = "$Env:ProgramFiles\steam-update-disable-service"
Write-Debug $installdir

# Ensure installdir exists
if ( -not (Test-Path $installdir) ) {
  New-Item -ItemType Directory -Path $installdir
}

# Download winsw
$winsw_url = "https://github.com/winsw/winsw/releases/download/v2.10.3/WinSW.NETCore31.x86.exe"
$winsw_dest = "$installdir\steam-update-disable-service.exe"
if ( -not (Test-Path $winsw_dest) ) {
  Invoke-WebRequest -Uri $winsw_url -OutFile $winsw_dest
}

# Install our files
$scripts = @(
  "steam-update-disable-service.ps1"
)
ForEach ($script in $scripts) {
  Copy-Item -Path "$PSScriptRoot\$script" -Destination "$installdir\$script"
}

# write steam-update-disable-service.yml
$winsw_yaml = @"
id: DisableSteamAutoUpdate
name: DisableSteamAutoUpdate
description: Service to periodically disable Steam Auto-Update on all Steam Games
onFailure:
  - action: 'restart'
    delay: '60 sec'
  - action: 'restart'
    delay: '300 sec'
  - action: 'restart'
    delay: '600 sec'
resetfailure: '1 hour'
#securityDescriptor: security descriptor string
executable: 'PowerShell.exe'
arguments: >-
  -ExecutionPolicy Bypass
  -File "$installdir\steam-update-disable-service.ps1"
#startArguments: start arguments
#workingdirectory: C:\myApp\work
priority: 'Normal'
stopTimeout: '15 sec'
stopParentProcessFirst: true 
#stopExecutable: '%BASE%\stop.exe'
#stopArguments: -stop true
startMode: 'Automatic'
#delayedAutoStart: true
#serviceDependencies:
#    - Eventlog
#    - W32Time
waitHint: '15 sec'
sleepTime: '1 sec'
#interactive: true
log:
#    logpath: '%BASE%\logs'
  mode: 'append'
#beepOnShutdown: true
"@
$winsw_yaml | Out-File "$installdir\steam-update-disable-service.yml"

# install service
& $installdir\steam-update-disable-service.exe stop
& $installdir\steam-update-disable-service.exe uninstall
& $installdir\steam-update-disable-service.exe install
$installcode = $LastExitCode
if ($installcode -ne 0) {
  & $installdir\steam-update-disable-service.exe uninstall
  throw "Couldn't install.  Exit code is $installcode"
}
& $installdir\steam-update-disable-service.exe start
