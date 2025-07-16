<#
.DESCRIPTION
    This script will initiate a decrypt for the specified mount point.
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
        Write-Host "BitLocker Status: On - Initiating decryption..." -ForegroundColor Yellow
        Disable-BitLocker -MountPoint "$MountPoint" -ErrorAction Stop
        Write-Host "BitLocker decryption initiated successfully" -ForegroundColor Green
        Write-Host "Note: Decryption will continue in the background" -ForegroundColor Yellow
    } else {
        Write-Host "BitLocker Status: $($BitLockerStatus.ProtectionStatus) - No decryption needed" -ForegroundColor Green
    }
} catch {
    Write-Error "BitLocker decryption failed: $($_.Exception.Message)"
    Write-Host "Common issues:" -ForegroundColor Yellow
    Write-Host "- Invalid mount point specified" -ForegroundColor Yellow
    Write-Host "- BitLocker is not enabled on this volume" -ForegroundColor Yellow
    Write-Host "- Insufficient privileges (run as administrator)" -ForegroundColor Yellow
    Write-Host "- Recovery key may be required" -ForegroundColor Yellow
    exit 1
}
