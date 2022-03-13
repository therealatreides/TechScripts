<#
.DESCRIPTION
    This script will trigger various file health scan and repairs and reboot for a checkdisk

    This requires elevated permissions.
.NOTES
    Version:            1.0
    Author:             Scott E. Royalty
    Last Modified Date: 2/3/2022
#>


If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" $PSCommandArgs" -Verb RunAs
    Exit
}


Write-Host "Performing Image cleanup..."
DISM.exe /Online /Cleanup-image /Restorehealth

Write-Host "Performing System file check and repair..."
Start-Sleep 5
sfc /scannow

Write-Host "Configuring Check Disk on next reboot..."
Start-Sleep 5
chkdsk C: /f /r

Write-Host "All operations have been ran. Please reboot the computer to complete the process."

while ($rebootConfirm -ne "n" -and $rebootConfirm -ne "y") {
	$rebootConfirm = Read-Host "Reboot now? [y/n]"
}
if ($rebootConfirm -eq "y") {
	Restart-Computer
}