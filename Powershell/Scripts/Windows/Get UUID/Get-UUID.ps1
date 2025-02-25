<#
.DESCRIPTION
    This script will pull, if available, the UUID for the machine it is ran on. There is minor
    error checking and a backup method attempted. If still fails, returns blank.

.NOTES
    Version:            1.0
    Author:             Scott E. Royalty
    Last Modified Date: 2/16/2025
#>

$uuidCheck = "unknown"

try {
    $uuidCheck = get-wmiobject Win32_ComputerSystemProduct -ErrorAction Stop | Select-Object -ExpandProperty UUID
} catch {
    $uuidCheck = (Get-CimInstance -Class Win32_ComputerSystemProduct).UUID 
}

Write-Output $uuidCheck
