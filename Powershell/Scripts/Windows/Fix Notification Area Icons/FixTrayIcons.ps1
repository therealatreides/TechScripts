<#
.DESCRIPTION
    This script will fix missing icons in the systray area. It then force
    restarts explorer in order to show them. A reboot is recommended once
    this completes to verify the fix took hold.

    This requires elevated permissions.
.NOTES
    Version:            1.1
    Author:             Scott E. Royalty
    Last Modified Date: 7/7/2021
#>


If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" $PSCommandArgs" -Verb RunAs
    Exit
}

Write-Output "Fixing Missing Tray Icons..."
Remove-ItemProperty -Path "HKCU:\SOFTWARE\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\TrayNotify" -Name "IconStreams"
Remove-ItemProperty -Path "HKCU:\SOFTWARE\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\TrayNotify" -Name "PastIconsStream"

Write-Output "Restarting Explorer..."
Stop-Process -Name 'explorer*' -Force