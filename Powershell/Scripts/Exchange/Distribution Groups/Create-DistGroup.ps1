<#
.DESCRIPTION
    This script will create a new distribution group in Exchange Online.
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
    The name of the distribution group to be created.
.PARAMETER JoinRestriction
    The restriction for joining the distribution group. Default is "Closed".
.PARAMETER DepartRestriction  
    The restriction for leaving the distribution group. Default is "Closed".
.PARAMETER Owner  
    The owner of the distribution group. Default is "none", which means no owner is set.
.PARAMETER Members  
    A list of members to be added to the distribution group. Default is "none", which means no members are added initially.
    
    The members should be specified as a comma-separated string or an array of email addresses.
#>
param(
    [Parameter(Mandatory=$true)]
    $WorkerEmail,
    
    [Parameter(Mandatory=$true)]
    $DistGroupName,
    
    $JoinRestriction="Closed",
    
    $DepartRestriction="Closed",
    
    $Owner="none",
    
    $Members="none"
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
  # Check if the distribution group already exists
  if (Get-DistributionGroup -Identity $DistGroupName) {
    Write-Host "A distribution group with the name '$DistGroupName' already exists. Please choose a unique name." -ForegroundColor Yellow
    Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
    Exit
  }

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
  Write-host "Error occured: $_" -ForegroundColor Red
}