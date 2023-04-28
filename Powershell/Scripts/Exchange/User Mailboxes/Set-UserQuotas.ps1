<#
.DESCRIPTION
    This script will set the various Quotas for a user mailbox based on the passed user identity and numeric value (which is in GB)
.NOTES
    Requires PowershellGet v2.x or higher - Install-Module -Name PowerShellGet -Repository PSGallery -Force -AllowClobber
    Requires ExchangeOnlineManagement Prerelease v2.05 or higher (so does not use Basic Auth) - Install-Module -Name ExchangeOnlineManagement -AllowPrerelease
.EXAMPLE
    Set-UserQuotas.ps1 -WorkerEmail user@company.com -UserEmail getuser@company.com -Quota "100"

    Version:            1.0
    Author:             Scott E. Royalty
    Last Modified Date: 3/3/2023
#>
param( [Parameter(Mandatory=$true)] $WorkerEmail, [Parameter(Mandatory=$true)] $UserEmail, [Parameter(Mandatory=$true)] $QuotaValue)

Import-Module ExchangeOnlineManagement

Try {
  Connect-ExchangeOnline -UserPrincipalName $WorkerEmail

  # We set these up based on examples and defaults from Microsoft. We set each in the below order because
  # specific quotas must be relative to others. So we set them in that order.
  $quota1 = $QuotaValue
  $quota2 = $QuotaValue - .5
  $quota3 = $QuotaValue - 1

  Set-Mailbox $UserEmail -ProhibitSendReceiveQuota "$quota1 GB"
  Set-Mailbox $UserEmail -ProhibitSendQuota "$quota2 GB"
  Set-Mailbox $UserEmail -ProhibitSendReceiveQuota "$quota3 GB"

  Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
}
catch {
  Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
  Write-host "Error occured: $_" -f Red
}