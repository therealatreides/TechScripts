<#
.DESCRIPTION
    This script will export the members of a Dynamic Distribution Group in Exchange Online. Optional parameter to export the members list to CSV for review/sharing.
.NOTES
    Requires PowershellGet v2.x or higher - Install-Module -Name PowerShellGet -Repository PSGallery -Force -AllowClobber
    Requires ExchangeOnlineManagement Prerelease v2.05 or higher (so does not use Basic Auth) - Install-Module -Name ExchangeOnlineManagement -AllowPrerelease

    Version:            1.0
    Author:             Scott E. Royalty
    Last Modified Date: 7/20/2022
#>
param( [Parameter(Mandatory=$true)] $WorkerEmail, [Parameter(Mandatory=$true)] $DynGroupName, $Export="No")

Import-Module ExchangeOnlineManagement

Try {
  Connect-ExchangeOnline -UserPrincipalName $WorkerEmail

  $GroupObj = Get-DynamicDistributionGroup -Identity $DynGroupName

  If ($Export -eq "No") {
    Get-Recipient -RecipientPreviewFilter $GroupObj.RecipientFilter | Select Name, Title, Department, Manager
  }
  else {
    $Path = $PSScriptRoot
    $Path = -join($Path, "`\", $DynGroupName, "_Members.csv")
    Get-Recipient -RecipientPreviewFilter $GroupObj.RecipientFilter | Select Name, Title, Department, Manager | Export-csv -Path "$Path"  -NoTypeInformation
  }

  Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
}
catch {
  Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
  Write-host "Error occured: $_" -f Red
}