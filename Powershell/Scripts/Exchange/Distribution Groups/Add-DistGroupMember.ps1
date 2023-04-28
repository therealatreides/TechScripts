<#
.DESCRIPTION
    This script will add a single member to a distribution group.
.NOTES
    Requires PowershellGet v2.x or higher - Install-Module -Name PowerShellGet -Repository PSGallery -Force -AllowClobber
    Requires ExchangeOnlineManagement Prerelease v2.05 or higher (so does not use Basic Auth) - Install-Module -Name ExchangeOnlineManagement -AllowPrerelease

    Version:            1.0
    Author:             Scott E. Royalty
    Last Modified Date: 8/6/2022
#>
param( [Parameter(Mandatory=$true)] $WorkerEmail, [Parameter(Mandatory=$true)] $DistGroupName, [Parameter(Mandatory=$true)] $AddMember)

Import-Module ExchangeOnlineManagement

Try {
  Connect-ExchangeOnline -UserPrincipalName $WorkerEmail

  Add-DistributionGroupMember -Identity $DistGroupName -Member $AddMember

  Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
}
catch {
  Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
  Write-host "Error occured: $_" -f Red
}