<#
.DESCRIPTION
    This script will create a rooms list for your conference rooms in the cloud (not for On-Premise).
.NOTES
    Requires PowershellGet v2.x or higher - Install-Module -Name PowerShellGet -Repository PSGallery -Force -AllowClobber
    Requires ExchangeOnlineManagement Prerelease v2.05 or higher (so does not use Basic Auth) - Install-Module -Name ExchangeOnlineManagement -AllowPrerelease

    Version:            1.0
    Author:             Scott E. Royalty
    Last Modified Date: 7/27/2022
#>
param( [Parameter(Mandatory=$true)] $WorkerEmail, [Parameter(Mandatory=$true)] $ListName, $MyOU="example.com/rooms")

Import-Module ExchangeOnlineManagement

Try {
  Connect-ExchangeOnline -UserPrincipalName $WorkerEmail

  if ($MyOU -eq "example.com/rooms")
  {
    # No OU was passed, so this is set in the Exchange OU Default
    New-DistributionGroup -Name "$ListName" -RoomList
  }
  else {
    New-DistributionGroup -Name "$ListName" -OrganizationalUnit "$MyOU" -RoomList
  }

  Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
}
catch {
  Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
  Write-host "Error occured: $_" -f Red
}