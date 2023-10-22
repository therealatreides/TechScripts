<#
.DESCRIPTION
    This script will disable IPv6 on all network adapters.

    This requires elevated permissions.
.NOTES
    Version:            1.0
    Author:             Scott E. Royalty
    Last Modified Date: 10/21/2023
#>

param( [switch]$Enable, [switch]$Disable )

If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" $PSCommandArgs" -Verb RunAs
    Exit
}

if ($Enable) {
    Write-Output "Enabling IPv6 on all adapters..."
    Enable-NetAdapterBinding -Name "*" -ComponentID ms_tcpip6
} else {
    Write-Output "Disabling IPv6 on all adapters..."
    Disable-NetAdapterBinding -Name "*" -ComponentID ms_tcpip6
}
