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
    try {
        Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" $PSCommandArgs" -Verb RunAs -ErrorAction Stop
        Exit
    } catch {
        Write-Error "Failed to elevate privileges: $($_.Exception.Message)"
        Write-Host "Please run this script as an administrator" -ForegroundColor Red
        exit 1
    }
}

try {
    Write-Host "Initializing TPM..." -ForegroundColor Yellow
    Initialize-Tpm -ErrorAction Stop
    Write-Host "TPM initialization completed successfully" -ForegroundColor Green
    
    Write-Host "Waiting 20 seconds before restart..." -ForegroundColor Yellow
    Start-Sleep -Seconds 20
    
    Write-Host "Restarting computer..." -ForegroundColor Yellow
    Restart-Computer -Force -ErrorAction Stop
} catch {
    Write-Error "TPM initialization failed: $($_.Exception.Message)"
    Write-Host "Please check TPM status in BIOS/UEFI settings" -ForegroundColor Red
    Write-Host "Common issues:" -ForegroundColor Yellow
    Write-Host "- TPM is disabled in BIOS" -ForegroundColor Yellow
    Write-Host "- TPM is already initialized" -ForegroundColor Yellow
    Write-Host "- Insufficient privileges" -ForegroundColor Yellow
    exit 1
}
