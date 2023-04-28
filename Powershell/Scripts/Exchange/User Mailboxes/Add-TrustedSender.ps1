<#
.DESCRIPTION
    This script will Add a new email address or domain to the trusted senders list for a mailbox. This
    will NOT replace the existing customized Trusted and Blocked list the end user already has in place.
.NOTES
    Requires PowershellGet v2.x or higher - Install-Module -Name PowerShellGet -Repository PSGallery -Force -AllowClobber
    Requires ExchangeOnlineManagement Prerelease v2.05 or higher (so does not use Basic Auth) - Install-Module -Name ExchangeOnlineManagement -AllowPrerelease
.EXAMPLE
    Trusting an Email Address
    Add-TrustedSender.ps1 -WorkerEmail user@company.com -UserEmail getuser@company.com -TrustedSender user@annoying.com

.EXAMPLE
    Trusting a Domain
    Add-TrustedSender.ps1 -WorkerEmail user@company.com -UserEmail getuser@company.com -TrustedSender annoying.com

    Version:            1.0
    Author:             Scott E. Royalty
    Last Modified Date: 4/28/2023
#>
param( [Parameter(Mandatory=$true)] $WorkerEmail, [Parameter(Mandatory=$true)] $UserEmail, [Parameter(Mandatory=$true)] $TrustedSender)

Import-Module ExchangeOnlineManagement

Try {
  Connect-ExchangeOnline -UserPrincipalName $WorkerEmail

  Set-MailboxJunkEmailConfiguration -Identity "$UserEmail" -TrustedSendersAndDomains @{Add="$TrustedSender"}

  Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
}
catch {
  Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
  Write-host "Error occured: $_" -f Red
}