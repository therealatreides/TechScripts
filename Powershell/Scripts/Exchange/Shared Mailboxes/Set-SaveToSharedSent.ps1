<#
.DESCRIPTION
    This script will enable/disable placing sent items by those with Send As and Send on Behalf into the Sent folder
	of the Shared Mailbox.
.NOTES
    Requires PowershellGet v2.x or higher - Install-Module -Name PowerShellGet -Repository PSGallery -Force -AllowClobber
    Requires ExchangeOnlineManagement Prerelease v2.05 or higher (so does not use Basic Auth) - Install-Module -Name ExchangeOnlineManagement -AllowPrerelease
	
.EXAMPLE
    This will disable saving them to the Sent Box of the Shared Mailbox
    Set-SaveToSharedSent.ps1 -WorkerEmail user@company.com -SharedEmail getuser@company.com -SaveToSent 0

.EXAMPLE
    This will disable saving them to the Sent Box of the Shared Mailbox
    Set-SaveToSharedSent.ps1 -WorkerEmail user@company.com -SharedEmail getuser@company.com -SaveToSent 1


    Version:            1.0
    Author:             Scott E. Royalty
    Last Modified Date: 4/24/2024
#>
param( [Parameter(Mandatory=$true)] $WorkerEmail, [Parameter(Mandatory=$true)] $SharedEmail, $SaveToSent="0")

Import-Module ExchangeOnlineManagement

Try {
    Connect-ExchangeOnline -UserPrincipalName "$WorkerEmail"

    if ($SaveToSent -eq "0") {
	Set-Mailbox -Identity "$SharedEmail" -MessageCopyForSentAsEnabled $False
	Set-Mailbox -Identity "$SharedEmail" -MessageCopyForSendOnBehalfEnabled $False
  }
  else {
	Set-Mailbox -Identity "$SharedEmail" -MessageCopyForSentAsEnabled $True
	Set-Mailbox -Identity "$SharedEmail" -MessageCopyForSendOnBehalfEnabled $True
  }

  Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
}
catch {
  Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
  Write-host "Error occured: $_" -f Red
}