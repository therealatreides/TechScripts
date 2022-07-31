<#
.DESCRIPTION
    This script will use a csv to add members to a distribution group based on a Name column to match up with users.

    One example for use:
    This could be used with the exported members of a group that was On Premise, to re-add them when migrating a Distribution List
    from On Premise to the Cloud.
.NOTES
    Requires PowershellGet v2.x or higher - Install-Module -Name PowerShellGet -Repository PSGallery -Force -AllowClobber
    Requires ExchangeOnlineManagement Prerelease v2.05 or higher (so does not use Basic Auth) - Install-Module -Name ExchangeOnlineManagement -AllowPrerelease

    Version:            1.0
    Author:             Scott E. Royalty
    Last Modified Date: 7/26/2022
#>
param( [Parameter(Mandatory=$true)] $WorkerEmail, [Parameter(Mandatory=$true)] $DistGroupName, $Export="No")

Import-Module ExchangeOnlineManagement

Try {
  Connect-ExchangeOnline -UserPrincipalName $WorkerEmail

  Import-CSV "AddMembers.csv" | ForEach {Add-DistributionGroupMember -Identity $DistGroupName Member $_.Name}

  Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
}
catch {
  Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
  Write-host "Error occured: $_" -f Red
}