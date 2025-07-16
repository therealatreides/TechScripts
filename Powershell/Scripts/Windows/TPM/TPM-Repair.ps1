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
    try {
        Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" $PSCommandArgs" -Verb RunAs -ErrorAction Stop
        Exit
    } catch {
        Write-Error "Failed to elevate privileges: $($_.Exception.Message)"
        Write-Host "Please run this script as an administrator" -ForegroundColor Red
        exit 1
    }
}

Write-Host "Starting TPM repair process..." -ForegroundColor Yellow
Write-Host "This process will:" -ForegroundColor Cyan
Write-Host "1. Disable BitLocker (if enabled)" -ForegroundColor Cyan
Write-Host "2. Clear and reinitialize TPM" -ForegroundColor Cyan
Write-Host "3. Force a system reboot" -ForegroundColor Cyan
Write-Host ""

try {
    Write-Host "Step 1: Checking BitLocker status..." -ForegroundColor Yellow
    $bitlockerVolumes = Get-BitLockerVolume -ErrorAction SilentlyContinue
    
    if ($bitlockerVolumes) {
        foreach ($volume in $bitlockerVolumes) {
            if ($volume.ProtectionStatus -eq "On") {
                Write-Host "Disabling BitLocker on volume $($volume.MountPoint)..." -ForegroundColor Yellow
                Disable-BitLocker -MountPoint $volume.MountPoint -ErrorAction Stop
                Write-Host "BitLocker disabled on volume $($volume.MountPoint)" -ForegroundColor Green
            }
        }
    } else {
        Write-Host "No BitLocker volumes found or BitLocker is not enabled" -ForegroundColor Green
    }
    
    Write-Host "Waiting 5 seconds for BitLocker operations to complete..." -ForegroundColor Yellow
    Start-Sleep -Seconds 5
    
    Write-Host "Step 2: Clearing and reinitializing TPM..." -ForegroundColor Yellow
    Initialize-Tpm -AllowClear -ForceClear -ErrorAction Stop
    Write-Host "TPM cleared and reinitialized successfully" -ForegroundColor Green
    
    Write-Host "Waiting 10 seconds for TPM operations to complete..." -ForegroundColor Yellow
    Start-Sleep -Seconds 10
    
    Write-Host "Step 3: Restarting computer..." -ForegroundColor Yellow
    Write-Host "The system will restart in 10 seconds..." -ForegroundColor Red
    Start-Sleep -Seconds 10
    
    Restart-Computer -Force -ErrorAction Stop
    
} catch {
    Write-Error "TPM repair process failed: $($_.Exception.Message)"
    Write-Host "Common issues:" -ForegroundColor Yellow
    Write-Host "- TPM is not available or supported on this system" -ForegroundColor Yellow
    Write-Host "- TPM is disabled in BIOS/UEFI settings" -ForegroundColor Yellow
    Write-Host "- BitLocker recovery key may be required" -ForegroundColor Yellow
    Write-Host "- Insufficient privileges" -ForegroundColor Yellow
    Write-Host "- System may require manual intervention" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Please check BIOS/UEFI settings and ensure TPM is enabled" -ForegroundColor Red
    exit 1
}

