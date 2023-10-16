<#
.DESCRIPTION
    This script will process a CSV file filled with Room emails and clear their automappting. Handy for mass clearing them from
    your room resources.

    CSV File must contain a column with the header Email that contains the emails of all the rooms to remove automapping for
.NOTES
    Requires PowershellGet v2.x or higher - Install-Module -Name PowerShellGet -Repository PSGallery -Force -AllowClobber
    Requires ExchangeOnlineManagement Prerelease v2.05 or higher (so does not use Basic Auth) - Install-Module -Name ExchangeOnlineManagement -AllowPrerelease

    Version:            1.0
    Author:             Scott E. Royalty
    Last Modified Date: 10/15/2023
#>
param( [Parameter(Mandatory=$true)] $WorkerEmail, [Parameter(Mandatory=$true)] $ImportFile )

Import-Module ExchangeOnlineManagement

Try {
  Connect-ExchangeOnline -UserPrincipalName $WorkerEmail

  Import-CSV "$ImportFile" | ForEach {Remove-MailboxPermission -Identity $_.Email -ClearAutoMapping -Confirm:$false}

  Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
}
catch {
  Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
  Write-host "Error occured: $_" -f Red
}