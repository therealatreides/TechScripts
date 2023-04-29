<#
.DESCRIPTION
    This script will use a CSV to add domains and emails to trusted senders and domains.
    It will NOT replace the existing customized Trusted and Blocked list the end user already has in place.
.NOTES
    Requires PowershellGet v2.x or higher - Install-Module -Name PowerShellGet -Repository PSGallery -Force -AllowClobber
    Requires ExchangeOnlineManagement Prerelease v2.05 or higher (so does not use Basic Auth) - Install-Module -Name ExchangeOnlineManagement -AllowPrerelease
.EXAMPLE
    Trusting an Email Address list from csv file for a single user
    Add-TrustedSender.ps1 -WorkerEmail "user@company.com" -UserEmail "getuser@company.com" -ImportFile "C:\temp\tested.csv"

.EXAMPLE
    Trusting an Email Address list from csv file for all user mailboxes
    Add-TrustedSender.ps1 -WorkerEmail "user@company.com" -UserEmail "*" -ImportFile "C:\temp\tested.csv"

.EXAMPLE
    CSV File structure is specific. For this to work, the column for the email addresses/domains need to use the header
    "Address". You can have any number of columns, so long as the one that is the addresses to import is "Address".
    This allows you to use reports generated for a number of things without removing all the extra columns.

    *Note : TrustedSendersAndDomains does not allow you to add addresses from the same domain as the user. This will
            result in an error causing them all to fail in the csv.

    Version:            1.0
    Author:             Scott E. Royalty
    Last Modified Date: 4/29/2023
#>
param( [Parameter(Mandatory=$true)] $WorkerEmail, [Parameter(Mandatory=$true)] $UserEmail, [Parameter(Mandatory=$true)] $ImportFile)

Import-Module ExchangeOnlineManagement

Try {
  Connect-ExchangeOnline -UserPrincipalName $WorkerEmail

  # There has to be a better way to import and build the HASH that is compatible with the
  # MailboxJunkEmailConfiguration's TrustedSendersAndDomains, but in a ton of testing I just
  # have not found it yet. But, this works to apply them all at once so I am going with it
  # for the moment.
  $CSVContents = Import-CSV -Path "$ImportFile"
  $AddressList
  $Total = $CSVContents.count
  for ($i = 0; $i -lt $Total; $i++) {
    $Item = $CSVContents[$i].Address
    if($i -eq ($Total-1)) {
      $AddressList = -join ("$AddressList", ',', "$Item")
    } else {
      if ($i -eq 0) {
        $AddressList = -join ("$Item")
      } else {
        $AddressList = -join ("$AddressList", ',', "$Item")
      }
    }
  }

  $AddressHash = @{
    Add = $AddressList -split ","
  }

  if ($UserEmail -eq "*") {
    Get-Mailbox -ResultSize unlimited -RecipientTypeDetails UserMailbox | Set-MailboxJunkEmailConfiguration -TrustedSendersAndDomains $AddressHash -ErrorAction SilentlyContinue
  } else {
    Set-MailboxJunkEmailConfiguration -Identity "$UserEmail" -TrustedSendersAndDomains $AddressHash
  }

  Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
}
catch {
  Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
  Write-host "Error occured: $_" -f Red
}