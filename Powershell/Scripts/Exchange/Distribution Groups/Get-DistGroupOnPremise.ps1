<#
.DESCRIPTION
    This script will get a list of all distribution groups still On Premise and synced over to the cloud. This can
    help with migrating them to the cloud for a more native cloud-based environment.
.NOTES
    Requires PowershellGet v2.x or higher - Install-Module -Name PowerShellGet -Repository PSGallery -Force -AllowClobber
    Requires ExchangeOnlineManagement Prerelease v2.05 or higher (so does not use Basic Auth) - Install-Module -Name ExchangeOnlineManagement -AllowPrerelease

.EXAMPLE
    Get-DistGroupOnPremise.ps1 -WorkerEmail user@company.com -ExportPath "C:\temp\export.csv"

    Version:            1.1
    Author:             Scott E. Royalty
    Last Modified Date: 6/06/2025

    Changes:
        1.1 - Formatting, additional error handling for connection issues and improved output messages.
        1.0 - Initial version.

.PARAMETER WorkerEmail
    The email address of the worker who will perform the operation. This is used to connect to Exchange Online.
.PARAMETER ExportPath
    The path where the output CSV file will be saved. This file will contain details of the distribution groups that are still On Premise and synced to the cloud.
#>
param(
    [Parameter(Mandatory=$true)]
    $WorkerEmail,
    
    [Parameter(Mandatory=$true)]
    $ExportPath
)

if (-not (Get-Module -Name ExchangeOnlineManagement)) {
  Import-Module ExchangeOnlineManagement
}

Try {
  Connect-ExchangeOnline -UserPrincipalName $WorkerEmail -ErrorAction Stop
}
catch {
  Write-Host "Failed to connect to Exchange Online. Please check the credentials or email address: $WorkerEmail" -ForegroundColor Red
  Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
  Exit
}

Try {
  Get-DistributionGroup | Where {$_.IsDirSynced -eq $true} | Select GroupType, Name, DisplayName, Alias, Description, HiddenFromAddressListsEnabled, RequireSenderAuthenticationEnabled, EmailAddresses, WindowsEmailAddress, RecipientType, PrimarySmtpAddress | Export-Csv "$ExportPath" -NoTypeInformation

  Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
}
catch {
  Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
  Write-host "Error occured: $_" -ForegroundColor Red
}
