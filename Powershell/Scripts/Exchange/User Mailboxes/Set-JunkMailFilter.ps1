<#
.DESCRIPTION
    This script will enable/disable the Junk Mail Filter for a user's mailbox.
.NOTES
    Requires PowershellGet v2.x or higher - Install-Module -Name PowerShellGet -Repository PSGallery -Force -AllowClobber
    Requires ExchangeOnlineManagement Prerelease v2.05 or higher (so does not use Basic Auth) - Install-Module -Name ExchangeOnlineManagement -AllowPrerelease
.EXAMPLE
    Enable Junk Mail Filter (sending anything other than 0 enables it)
    Add-TrustedSender.ps1 -WorkerEmail user@company.com -UserEmail getuser@company.com -JunkFilter 1

.EXAMPLE
    Junk Mail Filter Disabled
    Add-TrustedSender.ps1 -WorkerEmail user@company.com -UserEmail getuser@company.com -JunkFilter 0

.EXAMPLE
    Junk Mail Filter Default Option of Disabled
    Add-TrustedSender.ps1 -WorkerEmail user@company.com -UserEmail getuser@company.com

    Version:            1.0
    Author:             Scott E. Royalty
    Last Modified Date: 4/28/2023
#>
param( [Parameter(Mandatory=$true)] $WorkerEmail, [Parameter(Mandatory=$true)] $UserEmail, $JunkFilter="0")

Import-Module ExchangeOnlineManagement

Try {
  Connect-ExchangeOnline -UserPrincipalName $WorkerEmail

  if ($JunkFilter -eq "0") {
    Set-MailboxJunkEmailConfiguration -Identity "$UserEmail" -Enabled $false
  }
  else {
    Set-MailboxJunkEmailConfiguration -Identity "$UserEmail" -Enabled $true
  }

  Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
}
catch {
  Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
  Write-host "Error occured: $_" -f Red
}