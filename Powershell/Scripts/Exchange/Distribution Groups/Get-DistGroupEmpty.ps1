<#
.DESCRIPTION
    This script will check all Distribution Groups to find any without any members. Only checks against Members.
.NOTES
    Requires PowershellGet v2.x or higher - Install-Module -Name PowerShellGet -Repository PSGallery -Force -AllowClobber
    Requires ExchangeOnlineManagement Prerelease v2.05 or higher (so does not use Basic Auth) - Install-Module -Name ExchangeOnlineManagement -AllowPrerelease

.EXAMPLE
    Get-DistGroupEmpty.ps1 -WorkerEmail user@company.com -ExportPath "C:\temp\export.csv"

    Version:            1.1
    Author:             Scott E. Royalty
    Last Modified Date: 6/06/2025

    Changes:
        1.1 - Formatting, additional error handling for connection issues and improved output messages.
        1.0 - Initial version.

.PARAMETER WorkerEmail
    The email address of the worker who will perform the operation. This is used to connect to Exchange Online.
.PARAMETER ExportPath
    The path where the results will be exported as a CSV file. The directory must exist before running the script.
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

if (-not (Test-Path (Split-Path -Path $ExportPath -Parent))) {
  Write-Host "The directory for the export path does not exist: $ExportPath" -ForegroundColor Red
  Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
  Exit
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
  $emptyGroups = foreach ($grp in Get-DistributionGroup -ResultSize Unlimited) {
    if (@(Get-DistributionGroupMember -Identity $grp.DistinguishedName -ResultSize Unlimited).Count -eq 0 ) {
      [PsCustomObject]@{
        DisplayName        = $grp.DisplayName
        PrimarySMTPAddress = $grp.PrimarySMTPAddress
        DistinguishedName  = $grp.DistinguishedName
        }
    }
  }
  
  Try {
    $emptyGroups | Export-Csv "$ExportPath" -NoTypeInformation
  }
  catch {
    Write-Host "Failed to export data to the specified path: $ExportPath" -ForegroundColor Red
    Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
    Exit
  }

  Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
}
catch {
  Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
  Write-host "Error occured: $_" -ForegroundColor Red
}