function Install-Daemon
{
#.SYNOPSIS
# Author: Sabrina Andersen <sabrina@utd.tf>
# Author: Tyler McCann <tylerdotrar on github>
#
#.DESCRIPTION
# This script will install a cross-platform daemon for controlling the Framework 16 LED Matrixes
# Thank you tylerdotrar for helping me with this powershell installer!
# 
#.LINK
# https://github.com/NukingDragons/fw16-led-matrixd

  param(
    [switch]$Help
  )

  # Return Get-Help Information
  if ($Help) { return (Get-Help Install-Daemon) }

  # Determine if user has elevated privileges
  $User    = [Security.Principal.WindowsIdentity]::GetCurrent();
  $isAdmin = (New-Object Security.Principal.WindowsPrincipal $User).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
  if (!$isAdmin) { return (Write-Host '[-] This function requires elevated privileges.') }

  # Determine latest version number
  Write-Host "[+] Downloading & Installing 'fw16-led-matrixd'..." -ForegroundColor Yellow
  $url        = "https://github.com/NukingDragons/fw16-led-matrixd/releases/latest"
  $request    = [System.Net.WebRequest]::Create($url)
  $response   = $request.GetResponse()
  $realTagUrl = $response.ResponseUri.OriginalString
  $version    = $realTagUrl.split('/')[-1]

  # Download the latest version
  $latest = "https://github.com/NukingDragons/fw16-led-matrixd/releases/download/${version}/fw16-led-matrixd-${version}_windows.zip"
  [System.Net.WebClient]::new().DownloadFile($latest,"C:\Windows\Temp\fw16-led-matrixd.zip")
  Write-Host " o  Expanding 'fw16-led-matrixd' archive..."
  if (!(Test-Path -LiteralPath 'C:\Windows\Temp\fw16-led-matrixd.zip')) { return '[-] Failed to download fw16-led-matrixd.' }
  else { Expand-Archive -Path 'C:\Windows\Temp\fw16-led-matrixd.zip' -DestinationPath 'C:\Program Files\fw16-led-matrixd' }
  Remove-Item 'C:\Windows\Temp\fw16-led-matrixd.zip' -Force
  Remove-Item 'C:\Program Files\fw16-led-matrixd\README.txt' -Force
  Write-Host ' o  Done.'

  # Create the fw16-led-matrixd service
  Write-Host " o  Creating 'fw16-led-matrixd' service..."
  New-Service -Name "fw16-led-matrixd" -BinaryPathName '"C:\Program Files\fw16-led-matrixd\fw16-led-matrixd.exe"' -DisplayName "Framework 16 LED Matrix Service" -Description "A cross-platform daemon for controlling the Framework 16 LED Matrixes" -StartupType Auto
  Write-Host ' o  Done.'

  # Add 'ledcli' to PATH
  Write-Host " o  Adding 'ledcli' to global PATH..."
  $EnvPathKey = 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment'
  $Original   = (Get-ItemProperty -Path $EnvPathKey -Name path).path
  $Updated    = "$Original;C:\Program Files\fw16-led-matrixd"
  Set-ItemProperty -Path $EnvPathKey -Name path -Value $Updated
  Write-Host " o  Done`n" -ForegroundColor Yellow

  # Tell the user what to do
  Write-Host "Be sure to configure C:\Program Files\fw16-led-matrixd\config.toml, you can determine the ports by issuing this command at any time:" -ForegroundColor Green
  Write-Host "ledcli.exe list`n" -ForegroundColor Green
  Write-Host "Current ports on your system at this time" -ForegroundColor Green
  & "C:\Program Files\fw16-led-matrixd\ledcli.exe" list
  Write-Host "`nOnce you have updated the config, start the service with the following command:" -ForegroundColor Green
  Write-Host "sc.exe start fw16-led-matrixd" -ForegroundColor Green
}

# Install the daemon
Install-Daemon
