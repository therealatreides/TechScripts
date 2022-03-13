<#
.DESCRIPTION
    This script will find and uninstall matches containing the passed SearchString.
    Due to user specific installs, when Elevation is NOT passed it assumes you are removing something from the user's hive instead since that does not require elevation.
.NOTES
    Version:            1.0
    Author:             Scott E. Royalty
    Last Modified Date: 03/13/2022
#>

param( [Parameter(Mandatory=$true)] $SearchString, $Elevation="True" )

If ( $Elevation -eq "True") {
    If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
        Start-Process powershell.exe "-ExecutionPolicy Bypass -File `"$PSCommandPath`" $PSCommandArgs -SearchString `"$SearchString`"" -Verb RunAs
        Exit
    }
}

If ( $Elevation -eq "True") {
    $AppSet = Get-ChildItem -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*, HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* -ErrorAction "SilentlyContinue" |
        Get-ItemProperty |
            Where-Object {$_.DisplayName -match $SearchString } |
                Select-Object -Property DisplayVersion, UninstallString, PSChildName
} else {
    $AppSet = Get-ChildItem -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*, HKCU:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* -ErrorAction "SilentlyContinue" |
        Get-ItemProperty |
            Where-Object {$_.DisplayName -match $SearchString } |
                Select-Object -Property DisplayVersion, UninstallString, PSChildName
}


ForEach ($app in $AppSet) {
    If ($app.UninstallString) {
        $uninst = $app.UninstallString
        & cmd /c $uninst /quiet /norestart
    }
}