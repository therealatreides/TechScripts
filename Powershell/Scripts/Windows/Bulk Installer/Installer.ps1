<#
.DESCRIPTION
    This script will install applications based on a CSV you pass to it.
    See example CSV file for formatt. Each header self explains what the
    column is for. Enabled column uses 1 to install, anything else ignores
    that line.

    * This is a basic bulk installer, allowing you to push out multiple apps
    based on the CSV file you pass into it. Flags for installers can be included
    in order to customize the installs for silent or other options.
    
    This requires elevated permissions usually unless the application is user specific.
.NOTES
    Version:            1.0a
    Author:             Scott E. Royalty
    Last Modified Date: 3/11/2025
#>
param( [Parameter(Mandatory=$true)] $CSVFile, $WorkPath="C:\PCApplications")

# Let's import the CSV that contains our application's details needing installed
$applications = Import-CSV -path $CSVFile

# Set this to the general place you execute the script from. 
Set-Location $WorkPath

$applications | ForEach-Object {
    if ($_.Enabled -eq "1")
    {
        Set-Location $_.AppPath
        Write-Host Preparing to install $_.AppName

        If ($_.AppFlags.Length -gt 0) {
            Start-Process -Wait -FilePath $_.AppFile -ArgumentList $_.AppFlags
        } else {
            Start-Process -Wait -FilePath $_.AppFile
        }
    }
}