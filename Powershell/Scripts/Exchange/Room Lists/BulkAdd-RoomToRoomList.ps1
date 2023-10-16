<#
.DESCRIPTION
    This script will use a csv to add rooms to a room list based on a Name column to match up with resource mailboxes.

    One example for use:
    This could be used with the exported members of a group that was On Premise, to re-add them when migrating from On Premise to the Cloud
    or simply changings lists around entirely.
.NOTES
    Requires PowershellGet v2.x or higher - Install-Module -Name PowerShellGet -Repository PSGallery -Force -AllowClobber
    Requires ExchangeOnlineManagement Prerelease v2.05 or higher (so does not use Basic Auth) - Install-Module -Name ExchangeOnlineManagement -AllowPrerelease

    Version:            1.0
    Author:             Scott E. Royalty
    Last Modified Date: 8/06/2022
#>
param( [Parameter(Mandatory=$true)] $WorkerEmail, [Parameter(Mandatory=$true)] $RoomList, [Parameter(Mandatory=$true)] $RoomFile)

Import-Module ExchangeOnlineManagement

Try {
  Connect-ExchangeOnline -UserPrincipalName $WorkerEmail

  Import-CSV "$RoomFile" | ForEach {Add-DistributionGroupMember -Identity $RoomList -Member $_.Name}

  Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
}
catch {
  Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
  Write-host "Error occured: $_" -f Red
}