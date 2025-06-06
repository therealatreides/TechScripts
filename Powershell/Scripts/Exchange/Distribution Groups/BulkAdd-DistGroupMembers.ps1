<#
.DESCRIPTION
    This script will use a csv to add members to a distribution group based on a Name column to match up with users.

    One example for use:
    This could be used with the exported members of a group that was On Premise, to re-add them when migrating a Distribution List
    from On Premise to the Cloud.
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
    The name of the distribution group to which the members will be added.
.PARAMETER ImportFile
    The path to the CSV file containing the members to be added. The CSV should have a column named "Name" that contains the names of the members.
#>
param(
    [Parameter(Mandatory=$true)]
    $WorkerEmail,
    
    [Parameter(Mandatory=$true)]
    $DistGroupName,
    
    [Parameter(Mandatory=$true)]
    $ImportFile
)

if (-not (Get-Module -Name ExchangeOnlineManagement)) {
  Import-Module ExchangeOnlineManagement
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
  if (-not (Test-Path -Path $ImportFile)) {
    Write-Host "The specified import file does not exist: $ImportFile" -ForegroundColor Red
    Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
    Exit
  }
  Import-CSV "$ImportFile" | ForEach {Add-DistributionGroupMember -Identity $DistGroupName Member $_.Name}

  Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
}
catch {
  Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
  Write-host "Error occured: $_" -ForegroundColor Red
}