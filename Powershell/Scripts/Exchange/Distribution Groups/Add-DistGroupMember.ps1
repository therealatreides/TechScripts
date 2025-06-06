<#
.DESCRIPTION
    This script will add a single member to a distribution group.
.NOTES
    Requires PowershellGet v2.x or higher - Install-Module -Name PowerShellGet -Repository PSGallery -Force -AllowClobber
    Requires ExchangeOnlineManagement Prerelease v2.05 or higher (so does not use Basic Auth) - Install-Module -Name ExchangeOnlineManagement -AllowPrerelease

    Version:            1.1
    Author:             Scott E. Royalty
    Last Modified Date: 6/5/2025

    Changes:
        1.1 - Formatting, additional error handling for connection issues and improved output messages.
        1.0 - Initial version.

.PARAMETER WorkerEmail
    The email address of the worker who will perform the operation. This is used to connect to Exchange Online.
.PARAMETER DistGroupName
    The name of the distribution group to which the member will be added.
.PARAMETER AddMember
    The email address of the member to be added to the distribution group.
.EXAMPLE
    .\Add-DistGroupMember.ps1 -WorkerEmail "your@email.com" -DistGroupName "MyDistributionGroup" -AddMember "that@email.com"
    This command will add "that@email.com" to the distribution group "MyDistributionGroup" using the credentials of "your@email.com".
#>
param(
    [Parameter(Mandatory=$true)] 
    $WorkerEmail,

    [Parameter(Mandatory=$true)] 
    $DistGroupName,

    [Parameter(Mandatory=$true)] 
    $AddMember
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
  # Validate if the distribution group exists
  $DistGroup = Get-DistributionGroup -Identity $DistGroupName -ErrorAction SilentlyContinue
  if (-not $DistGroup) {
    Write-Host "Distribution group '$DistGroupName' does not exist." -ForegroundColor Red
    Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
    Exit
  }

  # Validate if the member email exists
  $Member = Get-Mailbox -Identity $AddMember -ErrorAction SilentlyContinue
  if (-not $Member) {
    Write-Host "Member email '$AddMember' does not exist." -ForegroundColor Red
    Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
    Exit
  }

  # Add the member to the distribution group
  Add-DistributionGroupMember -Identity $DistGroupName -Member $AddMember

  Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
}
catch {
  Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
  Write-host "Error occured: $_" -ForegroundColor Red
}