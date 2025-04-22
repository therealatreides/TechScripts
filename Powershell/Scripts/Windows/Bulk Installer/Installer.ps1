<#
.DESCRIPTION
    This script will install applications based on a CSV you pass to it.
    See example CSV file for formatt. Each header self explains what the
    column is for. Enabled column uses 1 to install, anything else ignores
    that line.

    * This is a basic bulk installer, allowing you to push out multiple apps
    based on the CSV file you pass into it. Flags for installers can be included
    in order to customize the installs for silent or other options.

    On 3/24, added support for Winget by ensuring it is installed.
    
    This requires elevated permissions usually unless the application is user specific.
.NOTES
    Version:            1.1
    Author:             Scott E. Royalty
    Last Modified Date: 3/24/2025
#>
param( [Parameter(Mandatory=$true)] $CSVFile, $WorkPath="Default")

Set-Variable -Name 'ConfirmPreference' -Value 'None' -Scope Global
$ProgressPreference = 'SilentlyContinue'

# Let's import the CSV that contains our application's details needing installed
$applications = Import-CSV -path $CSVFile

# Set this to the general place you execute the script from. 
if ($WorkPath -eq "Default") {
    $WorkPath = $PSScriptRoot
}
Set-Location $WorkPath

# Check if WinGet is installed, as some installations may require this.
Write-Host ("Verifying Winget is installed. This allows Winget to be used for installs and updates.") -ForegroundColor Yellow
if (!(Get-AppPackage -AllUsers).Name -like "Microsoft.Winget.Source") {
    Write-Host ("Winget not installed. Downloading and installing packages....") -ForegroundColor Red
    Invoke-Webrequest -uri https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx -Outfile $ENV:TEMP\Microsoft.VCLibs.x64.14.00.Desktop.appx
    Invoke-Webrequest -uri https://aka.ms/getwinget -Outfile $ENV:TEMP\winget.msixbundle    
    Add-AppxPackage $ENV:TEMP\Microsoft.VCLibs.x64.14.00.Desktop.appx -ErrorAction $ProgressPreference
    Add-AppxPackage -Path $ENV:TEMP\winget.msixbundle -ErrorAction $ProgressPreference
}
Write-Host ("Winget verification completed.`n") -ForegroundColor Green

Write-Host ("Preparing to install applications and run commands from your CSV file....`n") -ForegroundColor Green

$applications | ForEach-Object {
    if ($_.Enabled -eq "1")
    {
        Set-Location $_.AppPath
        Write-Host "Preparing to install " $_.AppName "...." -ForegroundColor Yellow
        If ($_.AppFlags.Length -gt 0) {
            Start-Process -Wait -FilePath $_.AppFile -ArgumentList $_.AppFlags
        } else {
            Start-Process -Wait -FilePath $_.AppFile
        }
    }
}

Set-Location $WorkPath
#Clean-up downloaded Winget Packages
Remove-Item $ENV:TEMP\Winget -Recurse -Force:$True -ErrorAction:SilentlyContinue

Write-Host ("Application Installs and Commands completed.`n") -ForegroundColor Green