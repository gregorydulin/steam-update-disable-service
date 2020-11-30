# Find Steam config file for each game, and turn off auto-updates

# Turn debugging on/off
$DebugPreference = "Continue"

# https://community.idera.com/database-tools/powershell/powertips/b/tips/posts/get-text-file-encoding
function Get-Encoding
{
  param
  (
    [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName)]
    [Alias('FullName')]
    [string]
    $Path
  )

  process
  {
    $bom = New-Object -TypeName System.Byte[](4)

    $file = New-Object System.IO.FileStream($Path, 'Open', 'Read')

    $null = $file.Read($bom,0,4)
    $file.Close()
    $file.Dispose()

    $enc = [Text.Encoding]::ASCII
    if ($bom[0] -eq 0x2b -and $bom[1] -eq 0x2f -and $bom[2] -eq 0x76)
      { $enc =  [Text.Encoding]::UTF7 }
    if ($bom[0] -eq 0xff -and $bom[1] -eq 0xfe)
      { $enc =  [Text.Encoding]::Unicode }
    if ($bom[0] -eq 0xfe -and $bom[1] -eq 0xff)
      { $enc =  [Text.Encoding]::BigEndianUnicode }
    if ($bom[0] -eq 0x00 -and $bom[1] -eq 0x00 -and $bom[2] -eq 0xfe -and $bom[3] -eq 0xff)
      { $enc =  [Text.Encoding]::UTF32}
    if ($bom[0] -eq 0xef -and $bom[1] -eq 0xbb -and $bom[2] -eq 0xbf)
      { $enc =  [Text.Encoding]::UTF8}

    [PSCustomObject]@{
      Encoding = $enc
      Path = $Path
    }
  }
}

Function Disable-AutoUpdate {
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

        Write-Debug "Backing up .acf file if necessary"
        if (-not (Test-Path "$($appmanifest_file.FullName).bak") ) {
          Write-Debug "Copying $($appmanifest_file.FullName) to $($appmanifest_file.FullName).bak"
          Copy-Item "$($appmanifest_file.FullName)" "$($appmanifest_file.FullName).bak"
        } else {
          Write-Debug "$($appmanifest_file.FullName).bak already exists"
        }

        Write-Debug "Reading text encoding"
        $encoding = ($appmanifest_file | Get-Encoding).Encoding
        if ($encoding.ToString() -eq "System.Text.ASCIIEncoding") {
          $encoding_string = "ascii"
        } else {
          Write-Output "encoding named $($encoding) hasn't been translated into something that 'Write-Out -Encoding' understands yet.  Please submit an issue at https://github.com/gregorydulin/steam-update-disable-service/issues"
          exit 1
        }

        Write-Debug "Encoding is $($encoding)"

        Write-Debug 'Replacing "AutoUpdateBehavior"\t\t"0" with "AutoupdateBehavior"\t\t"1"'
        $file_content = $appmanifest_file | Get-Content -Raw
        $file_content `
          -replace '"AutoUpdateBehavior"		"0"', '"AutoUpdateBehavior"		"1"' `
	  -replace "`r`n", "`n" `
            | Out-File "$($appmanifest_file.FullName)" -NoNewline -Encoding $encoding_string
      }
    }
  }
}

While ($true) {
  Disable-AutoUpdate
  Start-Sleep -Seconds (60 * 60)
}
