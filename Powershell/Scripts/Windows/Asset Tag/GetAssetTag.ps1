<#
.DESCRIPTION
    This script will pull, if available, the Asset Tag entry set in the BIOS (for example, from Dell motherboards)

.NOTES
    Version:            2.0
    Author:             Scott E. Royalty
    Last Modified Date: 4/23/2025
#>

Function Get-AssetTag {
    try {
        Write-Host "Retrieving BIOS manufacturer information..." -ForegroundColor Yellow
        # Get manufacturer information
        $biosInfo = Get-WmiObject -Class win32_bios -ErrorAction Stop | Select-Object -ExpandProperty Manufacturer
        if (-not $biosInfo) {
            Write-Warning "Unable to retrieve BIOS manufacturer information."
            return "Unknown"
        }
        
        Write-Host "BIOS Manufacturer: $biosInfo" -ForegroundColor Green
        
        # Get chassis information
        Write-Host "Retrieving chassis information..." -ForegroundColor Yellow
        $chassisInfo = Get-WmiObject -Class Cim_Chassis -ErrorAction Stop | Select-Object -ExpandProperty SMBIOSAssetTag

        if (-not $chassisInfo) {
            Write-Warning "Unable to retrieve chassis information."
            return "Unknown"
        }
        
        Write-Host "Processing asset tag for manufacturer: $biosInfo" -ForegroundColor Yellow
        
        # Determine asset tag based on manufacturer
        switch -Wildcard ($biosInfo) {
            "*Dell*" { 
                Write-Host "Dell system detected" -ForegroundColor Green
                return $chassisInfo 
            }
            "*Surface*" { 
                Write-Host "Surface system detected" -ForegroundColor Green
                return "Undefined" 
            }
            "*HP*" { 
                Write-Host "HP system detected" -ForegroundColor Green
                return $chassisInfo 
            }
            default { 
                Write-Warning "Manufacturer not recognized: $biosInfo"
                return "Unknown"
            }
        }
    } catch {
        Write-Error "Failed to retrieve asset tag: $($_.Exception.Message)"
        Write-Host "Common issues:" -ForegroundColor Yellow
        Write-Host "- WMI service is not running" -ForegroundColor Yellow
        Write-Host "- Insufficient privileges" -ForegroundColor Yellow
        Write-Host "- Hardware does not support asset tag" -ForegroundColor Yellow
        return "Error"
    }
}

try {
    $TheAssetTag = Get-AssetTag
    Write-Host "Asset Tag Result: $TheAssetTag" -ForegroundColor Cyan
} catch {
    Write-Error "Script execution failed: $($_.Exception.Message)"
    exit 1
}
