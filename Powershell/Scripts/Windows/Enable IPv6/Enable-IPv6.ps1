<#
.DESCRIPTION
    This script will enable IPv6 on all network adapters.

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

Write-Output "Enabling IPv6 on all adapters..."
Enable-NetAdapterBinding -Name "*" -ComponentID ms_tcpip6