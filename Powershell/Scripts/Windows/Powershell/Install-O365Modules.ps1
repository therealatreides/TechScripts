<#
.SYNOPSIS
    Installs all of the Office 365 related Powershell Modules.
.DESCRIPTION
    Installs all of the Office 365 related Powershell Modules.
.EXAMPLE
    Install-O365Modules.ps1
.NOTES
    Version:            1.1
    Author:             Scott E. Royalty
    Last Modified Date: 4/28/2023
#>

If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
    try {
        Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" $PSCommandArgs" -Verb RunAs -ErrorAction Stop
        Exit
    } catch {
        Write-Error "Failed to elevate privileges: $($_.Exception.Message)"
        Write-Host "Please run this script as an administrator" -ForegroundColor Red
        exit 1
    }
}

$modules = @(
    @{ Name = "PowerShellGet"; Description = "PowerShell Package Manager"; Flags = @("-Force", "-AllowClobber") },
    @{ Name = "MSOnline"; Description = "Microsoft Online Services"; Flags = @("-Force") },
    @{ Name = "AzureAD"; Description = "Azure Active Directory"; Flags = @("-Force") },
    @{ Name = "ExchangeOnlineManagement"; Description = "Exchange Online Management"; Flags = @("-Force", "-AllowPrerelease") },
    @{ Name = "Microsoft.Online.SharePoint.PowerShell"; Description = "SharePoint Online"; Flags = @("-Force") },
    @{ Name = "MicrosoftTeams"; Description = "Microsoft Teams"; Flags = @("-Force") }
)

$successCount = 0
$failureCount = 0

foreach ($module in $modules) {
    try {
        Write-Host "Installing $($module.Description) module..." -ForegroundColor Yellow
        
        # Build the parameters for Install-Module
        $installParams = @{
            Name = $module.Name
            ErrorAction = "Stop"
        }
        
        # Add additional flags
        foreach ($flag in $module.Flags) {
            switch ($flag) {
                "-Force" { $installParams.Force = $true }
                "-AllowClobber" { $installParams.AllowClobber = $true }
                "-AllowPrerelease" { $installParams.AllowPrerelease = $true }
            }
        }
        
        Install-Module @installParams
        Write-Host "Successfully installed $($module.Name)" -ForegroundColor Green
        $successCount++
        
    } catch {
        Write-Error "Failed to install $($module.Name): $($_.Exception.Message)"
        Write-Host "Continuing with remaining modules..." -ForegroundColor Yellow
        $failureCount++
    }
}

Write-Host "`nModule Installation Summary:" -ForegroundColor Cyan
Write-Host "Successfully installed: $successCount modules" -ForegroundColor Green
Write-Host "Failed installations: $failureCount modules" -ForegroundColor Red

if ($failureCount -gt 0) {
    Write-Host "`nCommon issues:" -ForegroundColor Yellow
    Write-Host "- Internet connection required" -ForegroundColor Yellow
    Write-Host "- PowerShell execution policy restrictions" -ForegroundColor Yellow
    Write-Host "- Insufficient privileges" -ForegroundColor Yellow
    Write-Host "- Module repository not accessible" -ForegroundColor Yellow
}