<#
.DESCRIPTION
    This script will toggle Taskbar Chat option in both Windows 10 and 11.

    OS is detected in the script.
.NOTES
    Version:            1.0
    Author:             Scott E. Royalty
    Last Modified Date: 12/12/2024

.CHANGELOG
    1.0
        Params set for Enable/Disable. Disable configured as the default.
        Detects between Windows 10 and 11 since feature uses different keys in each.
#>

param( [switch]$Enable, [switch]$Disable )

If (get-ciminstance -query "select caption from win32_operatingsystem where caption like '%Windows 11%'")
{
    $FullRegPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
    $Name         = 'TaskbarMn'
    $Value        = '1'

    # Value key above is set to Enable the chat. So we only need to check for Disable flag and change accordingly.
    if ($Disable)
    {
        $Value = '0'
    }
    If (-NOT (Test-Path $FullRegPath)) {
        New-Item -Path $FullRegPath -Force | Out-Null
    }  
    New-ItemProperty -Path $FullRegPath -Name $Name -Value $Value -PropertyType DWORD -Force
} else {
    $FullRegPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer'
    $Name         = 'HideSCAMeetNow'
    $Value        = '0'

    # Value key above is set to Enable the chat. So we only need to check for Disable flag and change accordingly.
    if ($Disable)
    {
        $Value = '1'
    }
    If (-NOT (Test-Path $FullRegPath)) {
        New-Item -Path $FullRegPath -Force | Out-Null
    }  
    New-ItemProperty -Path $FullRegPath -Name $Name -Value $Value -PropertyType DWORD -Force
}