<#
.DESCRIPTION
    This script will enable/disable the Trust Contacts option on a user's mailbox for junk email filtering.
.NOTES
    Requires PowershellGet v2.x or higher - Install-Module -Name PowerShellGet -Repository PSGallery -Force -AllowClobber
    Requires ExchangeOnlineManagement Prerelease v2.05 or higher (so does not use Basic Auth) - Install-Module -Name ExchangeOnlineManagement -AllowPrerelease
.EXAMPLE
    Trusting Contacts Enabled (sending anything other than 0 enables it)
    Add-TrustedSender.ps1 -WorkerEmail user@company.com -UserEmail getuser@company.com -TrustContacts 1

.EXAMPLE
    Trusting Contacts Disabled
    Add-TrustedSender.ps1 -WorkerEmail user@company.com -UserEmail getuser@company.com -TrustContacts 0

.EXAMPLE
    Trusting Contacts Default Option of Disabled
    Add-TrustedSender.ps1 -WorkerEmail user@company.com -UserEmail getuser@company.com

    Version:            1.0
    Author:             Scott E. Royalty
    Last Modified Date: 4/28/2023
#>
param( [Parameter(Mandatory=$true)] $WorkerEmail, [Parameter(Mandatory=$true)] $UserEmail, $TrustContacts="0")

Import-Module ExchangeOnlineManagement

Try {
  Connect-ExchangeOnline -UserPrincipalName $WorkerEmail

  if ($TrustContacts -eq "0") {
    Set-MailboxJunkEmailConfiguration -Identity "$UserEmail" -ContactsTrusted $false
  }
  else {
    Set-MailboxJunkEmailConfiguration -Identity "$UserEmail" -ContactsTrusted $true
  }

  Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
}
catch {
  Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
  Write-host "Error occured: $_" -f Red
}