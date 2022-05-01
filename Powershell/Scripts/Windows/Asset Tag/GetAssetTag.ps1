<#
.DESCRIPTION
    This script will pull, if available, the Asset Tag entry set in the BIOS (for example, from Dell motherboards)

.NOTES
    Version:            1.0
    Author:             Scott E. Royalty
    Last Modified Date: 4/30/2022
#>

#------------------------------------------------------------------#
#- Get-AssetTag                                        #
#------------------------------------------------------------------#
Function Get-AssetTag {
    $manufacturer = Get-WmiObject -Class win32_bios  | Select-Object -Property Manufacturer

    If (Select-String -Pattern "Dell" -InputObject $manufacturer)
        {
            return (Get-WmiObject -Class Cim_Chassis | Select-Object -Property SMBIOSAssetTag).SMBiosAssetTag
        }
    If (Select-String -Pattern "Surface" -InputObject $manufacturer)
        {
            return "Undefined"
        }
    If (Select-String -Pattern "HP" -InputObject $manufacturer)
        {
            return "Undefined"
        }
}

$TheAssetTag = Get-AssetTag
Write-Host $TheAssetTag