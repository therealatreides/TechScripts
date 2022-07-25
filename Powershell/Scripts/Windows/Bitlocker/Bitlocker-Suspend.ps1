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

$BitLockerStatus = (Get-BitLockerVolume -MountPoint "$MountPoint" | Select-Object ProtectionStatus)

if ($BitLockerStatus = "On") {
    Write-Host "BitLocker Status:$BitLockerStatus - Encryption will be suspended for one reboot."
    Suspend-BitLocker -MountPoint "$MountPoint" -RebootCount 1
} else {
    Write-Host "BitLocker Status: $BitLockerStatus"
}