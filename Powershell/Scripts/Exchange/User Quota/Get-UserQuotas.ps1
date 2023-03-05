<#
.DESCRIPTION
    This script will get the various Quotas for a user mailbox based on the passed user identity
.NOTES
    Requires PowershellGet v2.x or higher - Install-Module -Name PowerShellGet -Repository PSGallery -Force -AllowClobber
    Requires ExchangeOnlineManagement Prerelease v2.05 or higher (so does not use Basic Auth) - Install-Module -Name ExchangeOnlineManagement -AllowPrerelease
.EXAMPLE
    Get-UserQuotas.ps1 -WorkerEmail user@company.com -UserEmail getuser@company.com

    Version:            1.0
    Author:             Scott E. Royalty
    Last Modified Date: 3/3/2023
#>
param( [Parameter(Mandatory=$true)] $WorkerEmail, [Parameter(Mandatory=$true)] $UserEmail)

Import-Module ExchangeOnlineManagement

Try {
  Connect-ExchangeOnline -UserPrincipalName $WorkerEmail

  Get-Mailbox $UserEmail | Select *quota*

  Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
}
catch {
  Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
  Write-host "Error occured: $_" -f Red
}