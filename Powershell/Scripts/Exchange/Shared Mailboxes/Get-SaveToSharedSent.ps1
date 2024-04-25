<#
.DESCRIPTION
    This script will display the settings that determine if the shared mailbox saves sent items to it's own sent box when
	done by those with Send As and Send on Behalf permissions.
.NOTES
    Requires PowershellGet v2.x or higher - Install-Module -Name PowerShellGet -Repository PSGallery -Force -AllowClobber
    Requires ExchangeOnlineManagement Prerelease v2.05 or higher (so does not use Basic Auth) - Install-Module -Name ExchangeOnlineManagement -AllowPrerelease
	
.EXAMPLE
    This will view the settings.
    Get-SaveToSharedSent.ps1 -WorkerEmail user@company.com -SharedEmail getuser@company.com

    Version:            1.0
    Author:             Scott E. Royalty
    Last Modified Date: 4/24/2024
#>
param( [Parameter(Mandatory=$true)] $WorkerEmail, [Parameter(Mandatory=$true)] $SharedEmail)

Import-Module ExchangeOnlineManagement

Try {
  Connect-ExchangeOnline -UserPrincipalName "$WorkerEmail"

  Get-Mailbox -Identity "$SharedEmail" | select MessageCopyForSentAsEnabled,MessageCopyForSendOnBehalfEnabled
  
  Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
}
catch {
  Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
  Write-host "Error occured: $_" -f Red
}