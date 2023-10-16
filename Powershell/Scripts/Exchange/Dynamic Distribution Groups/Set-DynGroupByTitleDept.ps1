<#
.DESCRIPTION
    This script will set rules for single title and/or department to decide membership of a Dynamic Group.

    In order to use multiple titles, please refer to the example comments in the code to manually configure multiple titles or departments in the code.
    This is very simple to do, but I am too lazy to code in a way to do it, since commas, pipes, etc. have been used in titles and departments by some people
    unfortunately. I don't really want to set up a complicated delimiter to use when I can show you how to just configure a quick manual variable.
.NOTES
    Requires PowershellGet v2.x or higher - Install-Module -Name PowerShellGet -Repository PSGallery -Force -AllowClobber
    Requires ExchangeOnlineManagement Prerelease v2.05 or higher (so does not use Basic Auth) - Install-Module -Name ExchangeOnlineManagement -AllowPrerelease

    Version:            1.0
    Author:             Scott E. Royalty
    Last Modified Date: 7/20/2022
#>
param( [Parameter(Mandatory=$true)] $WorkerEmail, [Parameter(Mandatory=$true)] $DynGroupName, $Title="No", $Department="No")

Import-Module ExchangeOnlineManagement

Try {
  Connect-ExchangeOnline -UserPrincipalName $WorkerEmail

  $GroupObj = Get-DynamicDistributionGroup -Identity $DynGroupName

  If ($Title -eq "No") {
    If ($Department -eq "No") {
      # If both are set to now, let's show you how to manually add multiples here so it looks like you aren't just dumb and didn't pass anything.
      # You wouldn't be dumb and not pass Title AND Department right? Yeah, I know. We'll pretend it didn't happen :)
      #
      # Example for using multiple titles - () to surround all the "-or" sets you need in the filter, so they are grouped together:
      # ((Title -eq 'Associate') -or (Title -eq 'Stocker') -or (Title -eq 'Shift Leader'))
      #
      # Example for using multiple departments - It would be the same as above, except instead of Title, you use Department.
      #
      # Example to combine title and department is to be sure each set has the () around all the filters for each, with a single "-and" between them:
      # (((Title -eq 'Associate') -or (Title -eq 'Stocker') -or (Title -eq 'Shift Leader')) -and ((Department -eq 'Warehouse')))
    }
    else {
      # Ohhhhhh, so we just setting up a Departmental dynamic group eh? Ok, let's get this done.
      Set-DynamicDistributionGroup -Identity "$DynGroupName" -RecipientFilter {((Department -eq "$Department"))}
    }
  }
  else {
    # Ok, so we passed Title to the script. Let's first see if we also passed Department for processing.
    If ($Department -eq "No") {
      # Ok, no Department, so let's just set the filter to use Title and be done with it.
      Set-DynamicDistributionGroup -Identity "$DynGroupName" -RecipientFilter {((Title -eq "$Title"))}
    }
    else {
      # Ok, we got both to pass. Let's get this over with.
      Set-DynamicDistributionGroup -Identity "$DynGroupName" -RecipientFilter {((Title -eq "$Title") -and (Department -eq "$Department"))}
    }
  }

  Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
}
catch {
  Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue
  Write-host "Error occured: $_" -f Red
}