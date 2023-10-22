<#
.DESCRIPTION
    This script will disable Netbios on all network adapters.

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

$NetBios = 2

if ($Enable) {
    $NetBios = 1
}

$Adapters = $(Get-WmiObject -Class win32_networkadapterconfiguration)
Foreach ($Adapter in $Adapters) {
    try {
        $Adapter.SetTcpipNetbios($NetBios)
    }
    catch {
        # Nothing to see here
    }
}