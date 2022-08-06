<#
.DESCRIPTION
    This script will output all the room lists. Options for output are full details or simple formatted.
.NOTES
    Requires PowershellGet v2.x or higher - Install-Module -Name PowerShellGet -Repository PSGallery -Force -AllowClobber
    Requires ExchangeOnlineManagement Prerelease v2.05 or higher (so does not use Basic Auth) - Install-Module -Name ExchangeOnlineManagement -AllowPrerelease

    Version:            1.0
    Author:             Scott E. Royalty
    Last Modified Date: 8/6/2022
#>
param( [Parameter(Mandatory=$true)] $WorkerEmail, $OutputFormat="full")

Import-Module ExchangeOnlineManagement

Try {
  Connect-ExchangeOnline -UserPrincipalName $WorkerEmail

  if ($OutputFormat -eq "simple")
  {
    Get-DistributionGroup -ResultSize Unlimited | Where {$_.RecipientTypeDetails -eq "RoomList"} | Format-Table DisplayName,Identity -AutoSize
  }
  else {
    Get-DistributionGroup -ResultSize Unlimited | Where {$_.RecipientTypeDetails -eq "RoomList"}
  }

  Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
}
catch {
  Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
  Write-host "Error occured: $_" -f Red
}