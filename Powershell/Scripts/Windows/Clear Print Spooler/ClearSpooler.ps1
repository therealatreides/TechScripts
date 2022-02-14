<#
.DESCRIPTION
    This script will clear all print documents currently in the queue.
.NOTES
    Version:            1.0
    Author:             Scott E. Royalty
    Last Modified Date: 7/7/2021
#>

If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" $PSCommandArgs" -Verb RunAs
    Exit
}

Stop-Service spooler
Sleep 10
Get-ChildItem -Path "C:\Windows\System32\spool\PRINTERS" -Include *.* | Remove-Item -Verbose
Start-Service spooler