<#
.DESCRIPTION
    This script will trigger the install for .NET v3.5 SP1 using DISM

    This requires elevated permissions.
.NOTES
    Version:            1.0
    Author:             Scott E. Royalty
    Last Modified Date: 7/24/2022
#>
If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" $PSCommandArgs" -Verb RunAs
    Exit
}

if(Get-Childitem -Path "HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP" | Where-Object -FilterScript {$_.name -match "v3.5"}){
    Write-Output "Microsoft .NET v3.5 SP1 is already installed."
}else{
    $ErrorActionPreference = "Stop"
    $InstallProcess = Start-Process "DISM" -ArgumentList "/Online /Enable-Feature /FeatureName:NetFx3 /All /NoRestart" -Wait -PassThru

    if(Get-Childitem -Path "HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP" | Where-Object -FilterScript {$_.name -match "v3.5"}){
        $result = "successfully completed"
    }else{
        $result = "failed"
    }
    Write-Output "Installation of Microsoft .NET v3.5 SP1 has $result."
}
