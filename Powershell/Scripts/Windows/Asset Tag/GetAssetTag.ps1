<#
.DESCRIPTION
    This script will pull, if available, the Asset Tag entry set in the BIOS (for example, from Dell motherboards)

.NOTES
    Version:            2.0
    Author:             Scott E. Royalty
    Last Modified Date: 4/23/2025
#>

Function Get-AssetTag {
    # Get manufacturer information
    $biosInfo = Get-WmiObject -Class win32_bios | Select-Object -ExpandProperty Manufacturer
    if (-not $biosInfo) {
        Write-Warning "Unable to retrieve BIOS manufacturer information."
        return "Unknown"
    }

    # Get chassis information
    $chassisInfo = Get-WmiObject -Class Cim_Chassis | Select-Object -ExpandProperty SMBIOSAssetTag

    if (-not $chassisInfo) {
        Write-Warning "Unable to retrieve chassis information."
        return "Unknown"
    }    

    # Determine asset tag based on manufacturer
    switch -Wildcard ($biosInfo) {
        "*Dell*" { return $chassisInfo }
        "*Surface*" { return "Undefined" }
        "*HP*" { return $chassisInfo }
        default { 
            Write-Warning "Manufacturer not recognized: $biosInfo"
            return "Unknown"
        }
    }
}

$TheAssetTag = Get-AssetTag
Write-Host $TheAssetTag
