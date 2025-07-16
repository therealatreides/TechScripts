<#
.DESCRIPTION
    This script will suspend bitlocker for one reboot. Typically used when deploying something like a BIOS update that
    will trigger Bitlocker to require the key.
.NOTES
    ** Must be ran as admin or system

    Version:            1.0
    Author:             Scott E. Royalty
    Last Modified Date: 7/23/2022
#>
param( $MountPoint="C:" )

try {
    Write-Host "Checking BitLocker status for mount point: $MountPoint" -ForegroundColor Yellow
    $BitLockerStatus = Get-BitLockerVolume -MountPoint "$MountPoint" -ErrorAction Stop
    
    if ($BitLockerStatus.ProtectionStatus -eq "On") {
        Write-Host "BitLocker Status: On - Encryption will be suspended for one reboot." -ForegroundColor Yellow
        Suspend-BitLocker -MountPoint "$MountPoint" -RebootCount 1 -ErrorAction Stop
        Write-Host "BitLocker successfully suspended for one reboot" -ForegroundColor Green
    } else {
        Write-Host "BitLocker Status: $($BitLockerStatus.ProtectionStatus) - No action needed" -ForegroundColor Green
    }
} catch {
    Write-Error "BitLocker operation failed: $($_.Exception.Message)"
    Write-Host "Common issues:" -ForegroundColor Yellow
    Write-Host "- Invalid mount point specified" -ForegroundColor Yellow
    Write-Host "- BitLocker is not enabled on this volume" -ForegroundColor Yellow
    Write-Host "- Insufficient privileges (run as administrator)" -ForegroundColor Yellow
    exit 1
}