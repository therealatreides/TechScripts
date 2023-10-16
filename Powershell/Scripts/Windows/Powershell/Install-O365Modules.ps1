<#
.SYNOPSIS
    Installs all of the Office 365 related Powershell Modules.
.DESCRIPTION
    Installs all of the Office 365 related Powershell Modules.
.EXAMPLE
    Install-O365Modules.ps1
.NOTES
    Version:            1.1
    Author:             Scott E. Royalty
    Last Modified Date: 4/28/2023
#>

If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" $PSCommandArgs" -Verb RunAs
    Exit
}

Write-Host "Updating PowershellGet..."
Install-Module PowerShellGet -Force -AllowClobber

Write-Host "Installing MSonline..."
Install-Module -Name MSOnline -Force

Write-Host "Installing AzureAD and Azure Graph modules..."
Install-Module -Name AzureAD -Force

Write-Host "Installing Exchange Online modules..."
Install-Module -Name ExchangeOnlineManagement -Force -AllowPrerelease

Write-Host "Installing SharePoint Online modules..."
Install-Module -Name Microsoft.Online.SharePoint.PowerShell -Force

Write-Host "Installing Teams modules..."
Install-Module -Name MicrosoftTeams -Force