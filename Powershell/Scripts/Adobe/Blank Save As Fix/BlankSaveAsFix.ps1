<#
.DESCRIPTION
    This script will update the settings via registry for Adobe Reader to disable Online Storage via Save As
    This is ran across current user.
.NOTES
    Version:            1.1
    Author:             Scott E. Royalty
    Last Modified Date: 06/05/2025

    Change Log:
        1.1 - Updated check to see if Adobe Reader is running and stop it before making changes
        1.0 - Initial release
#>


If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
    Start-Process powershell.exe "-ExecutionPolicy Bypass -File `"$PSCommandPath`" $PSCommandArgs" -Verb RunAs
    Exit
}

#------------------------------------------------------------------#
#- Set-BlankSaveAs                                                 #
#------------------------------------------------------------------#
Function Set-BlankSaveAs {
    $acroProcesses = Get-Process -Name AcroRd32 -ErrorAction SilentlyContinue
    if ($acroProcesses) {
        $acroProcesses | ForEach-Object {
            Write-Output "Stopping process: $($_.Name) with ID: $($_.Id)"
            Stop-Process -Id $_.Id -Force
            Start-Sleep -Milliseconds 1000
        }
    }
    Set-ItemProperty -Path 'HKCU:\Software\Adobe\Acrobat Reader\DC\AVGeneral' -Name bToggleCustomSaveExperience -Value 1 -Force
}

#------------------------------------------------------------------#
#- MAIN                                                            #
#------------------------------------------------------------------#

Write-Output "Adjusting Adobe Acrobat Settings..."
Set-BlankSaveAs
