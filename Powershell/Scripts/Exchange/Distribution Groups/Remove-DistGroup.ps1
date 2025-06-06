<#
.DESCRIPTION
    This script will remove a distribution group from Exchange Online.
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
    The name of the distribution group to be removed. 
#>
param(
    [Parameter(Mandatory=$true)]
    $WorkerEmail,
    
    [Parameter(Mandatory=$true)]
    $DistGroupName
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
  Remove-DistributionGroup -Identity $DistGroupName -ErrorAction Stop

  Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
}
catch {
  Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
  Write-host "Error occured: $_" -ForegroundColor Red
}