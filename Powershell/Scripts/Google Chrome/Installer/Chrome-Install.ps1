<#
.SYNOPSIS
	Installs the latest Chrome browser
.DESCRIPTION
	This PowerShell script installs the latest Google Chrome browser.
.EXAMPLE
	Chrome-Install.ps1
.NOTES
    Version:            1.0
    Author:             Scott E. Royalty
    Last Modified Date: 1/7/2023
#>

try {
	$Path = $env:TEMP;
	$Installer = "chrome_installer.exe"
	Invoke-WebRequest "http://dl.google.com/chrome/install/latest/chrome_installer.exe" -OutFile $Path\$Installer
	Start-Process -FilePath $Path\$Installer -Args "/silent /install" -Verb RunAs -Wait
	Remove-Item $Path\$Installer
	exit 0
} catch {
	exit 1
}