# Find Steam config file for each game, and turn off auto-updates

# Turn debugging on/off
$DebugPreference = "Continue"

Function RestoreFrom-Backup {
  $Drives = Get-PSDrive -PSProvider 'FileSystem'
  Write-Debug "Drives is $($Drives)"
  ForEach ($drive in $Drives) {
    Write-Debug "drive.root is $($drive.root)"
    $steamapps_dirs = $Drive.root | Get-ChildItem -Filter *steamapps* -Recurse -Directory
    Write-Debug "steamapps_dirs is $($steamapps_dirs)"
    ForEach ($steamapps_dir in $steamapps_dirs) {
      Write-Debug "steamapps_dir $($steamapps_dir)"
      $appmanifest_files = $steamapps_dir | Get-ChildItem -Filter appmanifest_*.acf
      Write-Debug "appmanifest_files is $($appmanifest_files)"
      ForEach ($appmanifest_file in $appmanifest_files) {

        Write-Debug "Restoring $($appmanifest_file.FullName) from backup"
        if (-not (Test-Path "$($appmanifest_file.FullName).bak") ) {
          Write-Debug "No .bak file found for $($appmanifest_file.FullName)."
          Copy-Item "$($appmanifest_file.FullName)" "$($appmanifest_file.FullName).bak"
        } else {
          Write-Debug "restoring from $($appmanifest_file.FullName).bak"
          Move-Item `
            -Path "$($appmanifest_file.FullName).bak" `
            -Destination "$($appmanifest_file.FullName)" `
            -Force
        }
      }
    }
  }
}

RestoreFrom-Backup
