<#
.DESCRIPTION
    This script will align the taskbar left or center, based on params

.NOTES
    Version:            1.0
    Author:             Scott E. Royalty
    Last Modified Date: 12/12/2024

.CHANGELOG
    1.0
        Params set for Left/Center. Center configured as the default to match OS.
#>

param( [switch]$Left, [switch]$Center )

$FullRegPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
$Name         = 'TaskbarAl'
$Value        = '1'

# Value key above is set to align center. So we only need to check for Left flag and change accordingly.
if ($Left)
{
    $Value = '0'
}
If (-NOT (Test-Path $FullRegPath)) {
    New-Item -Path $FullRegPath -Force | Out-Null
}  
New-ItemProperty -Path $FullRegPath -Name $Name -Value $Value -PropertyType DWORD -Force
