<#
.DESCRIPTION
    This script will initialize the TPM and then restart the PC.
    This is used when preparing to set up bitlocker on a machine.
    If you are having issues with bitlocker already enabled then you
    should run the TPM Repair script to suspend bitlocker and clear
    the TPM so everything can be reset and Bitlocker properly updated.
    Otherwise, you could lock your drive and require the recovery key
    or password.
    
    This requires elevated permissions.
.NOTES
    Version:            1.0
    Author:             Scott E. Royalty
    Last Modified Date: 4/23/2025
#>


If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" $PSCommandArgs" -Verb RunAs
    Exit
}

Initialize-Tpm
Start-Sleep -Seconds 20
Restart-Computer -Force
