<#
.DESCRIPTION
    This script will pull the members of a standard Distribution Group in Exchange Online. Optional parameter to export the members list to CSV for review/sharing.
.NOTES
    Requires PowershellGet v2.x or higher - Install-Module -Name PowerShellGet -Repository PSGallery -Force -AllowClobber
    Requires ExchangeOnlineManagement Prerelease v2.05 or higher (so does not use Basic Auth) - Install-Module -Name ExchangeOnlineManagement -AllowPrerelease

    Version:            1.1
    Author:             Scott E. Royalty
    Last Modified Date: 6/06/2025

    Changes:
        1.1 - Formatting, additional error handling for connection issues and improved output messages.
        1.0 - Initial version.

.PARAMETER WorkerEmail
    The email address of the worker who will perform the operation. This is used to connect to Exchange Online.
.PARAMETER DistGroupName
    The name of the distribution group from which the members will be retrieved.
.PARAMETER Export
    Optional parameter to export the members list to a CSV file. If set to "Yes", the script will create a CSV file with the members' details.
    Default is "No", which will simply display the members in the console.
.PARAMETER ExportFilePath
    The path where the CSV file will be saved if the Export parameter is set to "Yes". The file will be named as "<DistGroupName>_Members.csv" in the script's directory.
#>
param(
    [Parameter(Mandatory=$true)]
    $WorkerEmail,
    
    [Parameter(Mandatory=$true)]
    $DistGroupName,
    
    $Export="No",
    
    [string]$ExportFilePath = "$PSScriptRoot\$DistGroupName`_Members.csv"
)

if (-not (Get-Module -Name ExchangeOnlineManagement)) {
  Import-Module ExchangeOnlineManagement
}

if ($Export -ne "No") {
  if (!(Test-Path -Path (Split-Path -Path "$ExportFilePath" -Parent))) {
    Write-Host "The specified export file path is invalid or inaccessible: $ExportFilePath" -ForegroundColor Red
    Exit
  }
}

Try {
  Connect-ExchangeOnline -UserPrincipalName $WorkerEmail -ErrorAction Stop
}
catch {
  Write-Host "Failed to connect to Exchange Online. Please check the credentials or email address: $WorkerEmail" -ForegroundColor Red
  Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
  Exit
}

Try {
  If ($Export -eq "No") {
    Get-DistributionGroupMember -Identity $DistGroupName | Select Name, Title, PrimarySMTPAddress
  }
  else {
    Get-DistributionGroupMember -Identity $DistGroupName | Select-Object Name, Title, PrimarySMTPAddress | Export-Csv -Path "$ExportFilePath" -NoTypeInformation
  }

  Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
}
catch {
  Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
  Write-host "Error occured: $_" -ForegroundColor Red
}