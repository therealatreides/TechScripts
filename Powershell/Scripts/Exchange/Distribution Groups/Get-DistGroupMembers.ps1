<#
.DESCRIPTION
    This script will pull the members of a standard Distribution Group in Exchange Online. Optional parameter to export the members list to CSV for review/sharing.
.NOTES
    Requires PowershellGet v2.x or higher - Install-Module -Name PowerShellGet -Repository PSGallery -Force -AllowClobber
    Requires ExchangeOnlineManagement Prerelease v2.05 or higher (so does not use Basic Auth) - Install-Module -Name ExchangeOnlineManagement -AllowPrerelease

    Version:            1.0
    Author:             Scott E. Royalty
    Last Modified Date: 7/26/2022
#>
param( [Parameter(Mandatory=$true)] $WorkerEmail, [Parameter(Mandatory=$true)] $DistGroupName, $Export="No")

Import-Module ExchangeOnlineManagement

Try {
  Connect-ExchangeOnline -UserPrincipalName $WorkerEmail

  If ($Export -eq "No") {
    Get-DistributionGroupMember -Identity $DistGroupName | Select Name, Title, PrimarySMTPAddress
  }
  else {
    $Path = $PSScriptRoot
    $Path = -join($Path, "`\", $DistGroupName, "_Members.csv")
    $GroupObj = Get-DistributionGroupMember -Identity $DistGroupName | Select Name, Title, PrimarySMTPAddress | Export-csv -Path "$Path"  -NoTypeInformation
  }

  Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
}
catch {
  Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
  Write-host "Error occured: $_" -f Red
}