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

Disable-BitLocker -MountPoint "$MountPoint"
