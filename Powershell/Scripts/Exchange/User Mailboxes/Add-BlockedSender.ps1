<#
.DESCRIPTION
    This script will Add a new email address or domain to the blocked senders list for a mailbox. This
    will NOT replace the existing customized Trusted and Blocked list the end user already has in place.
.NOTES
    Requires PowershellGet v2.x or higher - Install-Module -Name PowerShellGet -Repository PSGallery -Force -AllowClobber
    Requires ExchangeOnlineManagement Prerelease v2.05 or higher (so does not use Basic Auth) - Install-Module -Name ExchangeOnlineManagement -AllowPrerelease
.EXAMPLE
    Blocking an Email Address
    Add-BlockedSender.ps1 -WorkerEmail user@company.com -UserEmail getuser@company.com -BlockedSender user@annoying.com

.EXAMPLE
    Blocking a Domain
    Add-BlockedSender.ps1 -WorkerEmail user@company.com -UserEmail getuser@company.com -BlockedSender annoying.com

    Version:            1.0
    Author:             Scott E. Royalty
    Last Modified Date: 4/28/2023
#>
param( [Parameter(Mandatory=$true)] $WorkerEmail, [Parameter(Mandatory=$true)] $UserEmail, [Parameter(Mandatory=$true)] $BlockedSender)

Import-Module ExchangeOnlineManagement

Try {
  Connect-ExchangeOnline -UserPrincipalName $WorkerEmail

  Set-MailboxJunkEmailConfiguration -Identity "$UserEmail" -BlockedSendersAndDomains @{Add="$BlockedSender"}

  Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
}
catch {
  Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
  Write-host "Error occured: $_" -f Red
}