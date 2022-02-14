<#
.DESCRIPTION
    This script will clear all known locations where Teams stores local cache.
    This is ran across all users of the PC, thus requires elevated permissions.
.NOTES
    Version:            1.1
    Author:             Scott E. Royalty
    Last Modified Date: 7/7/2021
#>


If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" $PSCommandArgs" -Verb RunAs
    Exit
}

#------------------------------------------------------------------#
#- Clear-TeamsCacheFiles                                           #
#------------------------------------------------------------------#
Function Clear-TeamsCacheFiles {
    get-process | ?{ $_.ProcessName -eq 'teams' } | ?{ "" -ne $_.MainWindowTitle } | Stop-Process
    Start-Sleep -s 3
    Get-ChildItem "C:\Users\*\AppData\Roaming\Microsoft\Teams\*" -directory | Where name -in ('application cache','blob storage','databases','GPUcache','IndexedDB','Local Storage','tmp') | ForEach{Remove-Item $_.FullName -Recurse -Force}
}

#------------------------------------------------------------------#
#- MAIN                                                            #
#------------------------------------------------------------------#

Write-Output "Clearing Teams Cache..."
Clear-TeamsCacheFiles
