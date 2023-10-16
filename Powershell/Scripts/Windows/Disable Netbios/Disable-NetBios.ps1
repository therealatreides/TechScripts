<#
.DESCRIPTION
    This script will disable Netbios on all network adapters.

    This requires elevated permissions.
.NOTES
    Version:            1.0
    Author:             Scott E. Royalty
    Last Modified Date: 8/3/2023

Set-DnsClientServerAddress -InterfaceAlias "*" -ServerAddresses "8.8.8.8"
Set-DnsClientServerAddress -InterfaceAlias "*" -ResetServerAddresses
#>


If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" $PSCommandArgs" -Verb RunAs
    Exit
}

Write-Output "Disabling Netbios on all adapters..."
(Get-WmiObject Win32_NetworkAdapterConfiguration -Filter IpEnabled="true").SetTcpipNetbios(2)