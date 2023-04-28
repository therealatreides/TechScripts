<#
.DESCRIPTION
    This script will get a list of all distribution groups still On Premise and synced over to the cloud. This can
    help with migrating them to the cloud for a more native cloud-based environment.
.NOTES
    Requires PowershellGet v2.x or higher - Install-Module -Name PowerShellGet -Repository PSGallery -Force -AllowClobber
    Requires ExchangeOnlineManagement Prerelease v2.05 or higher (so does not use Basic Auth) - Install-Module -Name ExchangeOnlineManagement -AllowPrerelease

.EXAMPLE
    Get-DistGroupOnPremise.ps1 -WorkerEmail user@company.com -ExportPath "C:\temp\export.csv"

    Version:            1.0
    Author:             Scott E. Royalty
    Last Modified Date: 4/28/2023
#>
param( [Parameter(Mandatory=$true)] $WorkerEmail, [Parameter(Mandatory=$true)] $ExportPath)

Import-Module ExchangeOnlineManagement

Try {
  Connect-ExchangeOnline -UserPrincipalName $WorkerEmail

  Get-DistributionGroup | Where {$_.IsDirSynced -eq $true} | Select GroupType, Name, DisplayName, Alias, Description, HiddenFromAddressListsEnabled, RequireSenderAuthenticationEnabled, EmailAddresses, WindowsEmailAddress, RecipientType, PrimarySmtpAddress | Export-Csv "$ExportPath" -NoTypeInformation

  Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
}
catch {
  Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
  Write-host "Error occured: $_" -f Red
}
