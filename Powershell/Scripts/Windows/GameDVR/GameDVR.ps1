<#
.DESCRIPTION
    This script will enable or disable the GameDVR at the CU and LM level (LM is Policy based)

    Using flags, you can control the settings and even prevent from it being re-enabled.
    -Enable, -Disable, -Allow, -Block
.NOTES
    Version:            1.0
    Author:             Scott E. Royalty
    Last Modified Date: 12/12/2024

.CHANGELOG
    1.0
        Params set and initial release.
#>

param( [switch]$Enable, [switch]$Disable, [switch]$Allow, [switch]$Block )

$FullRegPath = 'HKCU:\System\GameConfigStore'
$Name         = 'GameDVR_Enabled'
$Value        = '1'

if ($Disable)
{
    $Value = '0'
} 

If (-NOT (Test-Path $FullRegPath)) {
    New-Item -Path $FullRegPath -Force | Out-Null
}
New-ItemProperty -Path $FullRegPath -Name $Name -Value $Value -PropertyType DWORD -Force

$FullRegPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR'
$Name         = 'AllowGameDVR'
$Value        = '1'

if ($Block)
{
    $Value = '0'
} 

If (-NOT (Test-Path $FullRegPath)) {
    New-Item -Path $FullRegPath -Force | Out-Null
}
New-ItemProperty -Path $FullRegPath -Name $Name -Value $Value -PropertyType DWORD -Force

