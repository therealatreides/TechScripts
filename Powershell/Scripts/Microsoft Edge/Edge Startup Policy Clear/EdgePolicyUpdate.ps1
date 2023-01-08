<#
.DESCRIPTION
    Clears the RestoreOnStartup Policy keys
.NOTES
    Version:            1.0
    Author:             Scott E. Royalty
    Last Modified Date: 6/9/2022
#>


If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" $PSCommandArgs" -Verb RunAs
    Exit
}

reg delete HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Edge /v RestoreOnStartup /f
reg delete HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Edge\RestoreOnStartupURLs /f
