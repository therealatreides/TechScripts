<#
.DESCRIPTION
    This script will check all Distribution Groups to find any without any members. Only checks against Members.
.NOTES
    Requires PowershellGet v2.x or higher - Install-Module -Name PowerShellGet -Repository PSGallery -Force -AllowClobber
    Requires ExchangeOnlineManagement Prerelease v2.05 or higher (so does not use Basic Auth) - Install-Module -Name ExchangeOnlineManagement -AllowPrerelease

.EXAMPLE
    Get-DistGroupEmpty.ps1 -WorkerEmail user@company.com -ExportPath "C:\temp\export.csv"

    Version:            1.0
    Author:             Scott E. Royalty
    Last Modified Date: 4/28/2023
#>
param( [Parameter(Mandatory=$true)] $WorkerEmail, [Parameter(Mandatory=$true)] $ExportPath)

Import-Module ExchangeOnlineManagement

Try {
  Connect-ExchangeOnline -UserPrincipalName $WorkerEmail

  $emptyGroups = foreach ($grp in Get-DistributionGroup -ResultSize Unlimited) {
    if (@(Get-DistributionGroupMember -Identity $grp.DistinguishedName -ResultSize Unlimited).Count -eq 0 ) {
      [PsCustomObject]@{
        DisplayName        = $grp.DisplayName
        PrimarySMTPAddress = $grp.PrimarySMTPAddress
        DistinguishedName  = $grp.DistinguishedName
        }
    }
  }
  $emptyGroups | Export-Csv "$ExportPath" -NoTypeInformation

  Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
}
catch {
  Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
  Write-host "Error occured: $_" -f Red
}