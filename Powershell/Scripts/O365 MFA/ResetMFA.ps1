<#
.DESCRIPTION
    This script will reset the entries for MFA on a user's account so they can set up their number, app, etc. again.
.NOTES
    Requires the MSOnline module to be installed. - Install-Module MSOnline

    Version:            1.0
    Author:             Scott E. Royalty
    Last Modified Date: 7/20/2022
#>
param( [Parameter(Mandatory=$true)] $WorkerEmail, [Parameter(Mandatory=$true)] $MFAUserName)

$MSOCred = Get-Credential -Message "Credentials required" -User $WorkerEmail
Connect-MsolService -Credential $MSOCred

$user = Get-MsolUser -UserPrincipalName $MFAUserName

Reset-MsolStrongAuthenticationMethodByUpn -UserPrincipalName $user.Userprincipalname

pause