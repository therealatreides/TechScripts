<#
.DESCRIPTION
    This script will update the settings via registry for Adobe Reader to fix the blank esign window
    This is ran across current user.
.NOTES
    Version:            1.1
    Author:             Scott E. Royalty
    Last Modified Date: 06/05/2024

    Change Log:
        1.1 - Updated check to see if Adobe Reader is running and stop it before making changes
        1.0 - Initial release
#>

Try {
    If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
        Start-Process powershell.exe "-ExecutionPolicy Bypass -File `"$PSCommandPath`" $PSCommandArgs" -Verb RunAs
        Exit
    }
}
Catch {
    Write-Error "Failed to restart script as administrator: $_"
    Exit 1
}

#------------------------------------------------------------------#
#- Set-BlankSaveAs                                                 #
#------------------------------------------------------------------#
Function Set-BlankESign {
    $acroProcesses = Get-Process -Name AcroRd32 -ErrorAction SilentlyContinue
    if ($acroProcesses) {
        $acroProcesses | ForEach-Object {
            Write-Output "Stopping process: $($_.Name) with ID: $($_.Id)"
            Try {
                Stop-Process -Id $_.Id -Force -ErrorAction Stop
                Start-Sleep -Milliseconds 1000
            }
            Catch {
                Write-Warning "Failed to stop process ID $($_.Id): $_"
            }
        }
    }

    Set-ItemProperty -Path 'HKCU:\Software\Adobe\Acrobat Reader\DC\Security\cDigSig' -Name bPreviewModeBeforeSigning -Value 0 -Force
    Set-ItemProperty -Path 'HKCU:\Software\Adobe\Acrobat Reader\DC\Security\cPubSec' -Name aSignFormat -Value 'adbe.pkcs7.detached' -Force
    Set-ItemProperty -Path 'HKCU:\Software\Adobe\Acrobat Reader\DC\Security\cPubSec' -Name bAllowOtherInfoWhenSigning -Value 0 -Force
    Set-ItemProperty -Path 'HKCU:\Software\Adobe\Acrobat Reader\DC\Security\cPubSec' -Name bAllowReasonWhenSigning -Value 0 -Force
    Set-ItemProperty -Path 'HKCU:\Software\Adobe\Acrobat Reader\DC\Security\cPubSec' -Name bEnableCEFBasedUI -Value 0 -Force
    Set-ItemProperty -Path 'HKCU:\Software\Adobe\Acrobat Reader\DC\Security\cPubSec' -Name iRequireReviewWarnings -Value 1 -Force
    Set-ItemProperty -Path 'HKCU:\Software\Adobe\Acrobat Reader\DC\Security\cPubSec' -Name iShowDocumentWarnings -Value 1 -Force
}

#------------------------------------------------------------------#
#- MAIN                                                            #
#------------------------------------------------------------------#

Write-Output "Adjusting Adobe Acrobat Settings..."
Set-BlankESign
