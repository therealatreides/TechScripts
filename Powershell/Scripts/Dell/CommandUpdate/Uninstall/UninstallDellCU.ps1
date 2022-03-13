<#
.DESCRIPTION
    This script will find and uninstall matches containging Command | Update in the application name.
.NOTES
    Version:            1.0
    Author:             Scott E. Royalty
    Last Modified Date: 03/13/2022
#>

If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
    Start-Process powershell.exe "-ExecutionPolicy Bypass -File `"$PSCommandPath`" $PSCommandArgs" -Verb RunAs
    Exit
}

$CUVer = Get-ChildItem -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*, HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*  |
    Get-ItemProperty |
        Where-Object {$_.DisplayName -match "Command | Update" } |
            Select-Object -Property DisplayVersion, UninstallString, PSChildName

ForEach ($ver in $CUVer) {
    If ($ver.UninstallString) {
        $uninst = $ver.UninstallString
        & cmd /c $uninst /quiet /norestart
    }
}