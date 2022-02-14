<#
.DESCRIPTION
    This script will update the settings via registry for Adobe Reader to disable Online Storage via Save As
    This is ran across current user.
.NOTES
    Version:            1.0
    Author:             Scott E. Royalty
    Last Modified Date: 11/15/2021
#>


If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
    Start-Process powershell.exe "-ExecutionPolicy Bypass -File `"$PSCommandPath`" $PSCommandArgs" -Verb RunAs
    Exit
}

#------------------------------------------------------------------#
#- Set-BlankSaveAs                                                 #
#------------------------------------------------------------------#
Function Set-BlankSaveAs {
    Get-Process -Name AcroRd32 -ErrorAction SilentlyContinue | Stop-Process
    Start-Sleep -s 3
    Set-ItemProperty -Path 'HKCU:\Software\Adobe\Acrobat Reader\DC\AVGeneral' -Name bToggleCustomSaveExperience -Value 1 -Force
}

#------------------------------------------------------------------#
#- MAIN                                                            #
#------------------------------------------------------------------#

Write-Output "Adjusting Adobe Acrobat Settings..."
Set-BlankSaveAs
