<#
.DESCRIPTION
    This script will find and uninstall matches containging SupportAssist in the application name.
.NOTES
    Version:            1.0
    Author:             Scott E. Royalty
    Last Modified Date: 11/15/2021
#>

If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
    Start-Process powershell.exe "-ExecutionPolicy Bypass -File `"$PSCommandPath`" $PSCommandArgs" -Verb RunAs
    Exit
}

$SAVer = Get-ChildItem -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*, HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*  |
    Get-ItemProperty |
        Where-Object {$_.DisplayName -match "SupportAssist" } |
            Select-Object -Property DisplayVersion, UninstallString, PSChildName

ForEach ($ver in $SAVer) {
    If ($ver.UninstallString) {
        $uninst = $ver.UninstallString
        & cmd /c $uninst /quiet /norestart
    }
}