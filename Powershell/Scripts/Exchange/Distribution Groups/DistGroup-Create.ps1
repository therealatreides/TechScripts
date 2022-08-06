<#
.DESCRIPTION
    This script will create a new distribution group in Exchange Online.
.NOTES
    Requires PowershellGet v2.x or higher - Install-Module -Name PowerShellGet -Repository PSGallery -Force -AllowClobber
    Requires ExchangeOnlineManagement Prerelease v2.05 or higher (so does not use Basic Auth) - Install-Module -Name ExchangeOnlineManagement -AllowPrerelease

    Version:            1.0
    Author:             Scott E. Royalty
    Last Modified Date: 8/6/2022
#>
param( [Parameter(Mandatory=$true)] $WorkerEmail, [Parameter(Mandatory=$true)] $DistGroupName, $JoinRestriction="Closed", $DepartRestriction="Closed", $Owner="none", $Members="none")

Import-Module ExchangeOnlineManagement

Try {
  Connect-ExchangeOnline -UserPrincipalName $WorkerEmail

  if ($Owner -eq "none")
  {
    Add-DistributionGroup -Name $DistGroupName -MemberJoinRestriction "$JoinRestriction" -MemberDepartRestriction "$DepartRestriction"
  }
  else
  {
    Add-DistributionGroup -Name $DistGroupName  -MemberJoinRestriction "$JoinRestriction" -MemberDepartRestriction "$DepartRestriction" -ManagedBy "$Owner" -CopyOwnerToMember
  }

  if ($Members -ne "none")
  {
      $Members | Add-DistributionGroupMember -Identity "$DistGroupName"
  }

  Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
}
catch {
  Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
  Write-host "Error occured: $_" -f Red
}