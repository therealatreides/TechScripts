<#
.DESCRIPTION
    This script will run the commands to disable bitlocker (if enabled) and
    initialize the TPM. It will then force a reboot to clear the TPM and
    reinitialize it. This is useful when the TPM is in a bad state and needs
    to be reset. This is often the case when a computer is moved from one
    domain to another or when a computer is upgraded from one version of
    Windows to another.
    
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

Disable-BitLocker -MountPoint "C:" -ErrorAction SilentlyContinue
Start-Sleep -Seconds 5
Initialize-Tpm -AllowClear -ForceClear
Start-Sleep -Seconds 10
Restart-Computer -Force

