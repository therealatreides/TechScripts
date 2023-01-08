<#
.SYNOPSIS
	Installs the Enterprise Chrome browser
.DESCRIPTION
	This PowerShell script installs the Enterprise version of Google Chrome browser.
.EXAMPLE
	EnterpriseChrome-Install.ps1
.NOTES
    Version:            1.0
    Author:             Scott E. Royalty
    Last Modified Date: 1/7/2023
#>

try {
	$Path = $env:TEMP;
	$Installer = "chrome_installer.exe"
	Invoke-WebRequest "https://dl.google.com/tag/s/appguid%3D%7B8A69D345-D564-463C-AFF1-A69D9E530F96%7D%26iid%3D%7BEA2A91D8-E0FD-89B7-9CD4-D09536B45278%7D%26lang%3Den%26browser%3D4%26usagestats%3D1%26appname%3DGoogle%2520Chrome%26needsadmin%3Dtrue%26ap%3Dx64-stable-statsdef_0%26brand%3DGCEJ/dl/chrome/install/googlechromestandaloneenterprise64.msi" -OutFile $Path\$Installer
	Start-Process -FilePath $Path\$Installer -Args "/silent /install" -Verb RunAs -Wait
	Remove-Item $Path\$Installer
	exit 0
} catch {
	exit 1
}