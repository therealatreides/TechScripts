<#
.DESCRIPTION
    This script will check for and disable the annoying browser notifications for Chome and Edge Chromium at the Current User level.
    
.NOTES
    Version:            1.0
    Author:             Scott E. Royalty
    Last Modified Date: 8/1/2022
#>

if ((Test-Path -LiteralPath "Registry::\HKEY_CURRENT_USER\Software\Policies\Google\Chrome") -ne $true) {
    New-Item "Registry::\HKEY_CURRENT_USER\Software\Policies\Google\Chrome" -force -ea SilentlyContinue
}
New-ItemProperty -LiteralPath 'Registry::\HKEY_CURRENT_USER\Software\Policies\Google\Chrome' -Name 'DefaultNotificationsSetting' -Value '2' -PropertyType DWord

if ((Test-Path -LiteralPath "Registry::\HKEY_CURRENT_USER\Software\Policies\Microsoft\Edge") -ne $true) {
    New-Item "Registry::\HKEY_CURRENT_USER\Software\Policies\Microsoft\Edge" -force -ea SilentlyContinue
}
New-ItemProperty -LiteralPath 'Registry::\HKEY_CURRENT_USER\Software\Policies\Microsoft\Edge' -Name 'DefaultNotificationsSetting' -Value '2' -PropertyType DWord