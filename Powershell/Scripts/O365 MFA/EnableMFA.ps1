<#
.DESCRIPTION
    This script will enable MFA for a user. *** Untested as I do not currently have Global Admin, which is required to Enable/Disable MFA completely.
.NOTES
    Requires the MSOnline module to be installed. - Install-Module MSOnline
    Based on blog entry from https://bolding.us/blog/2021/11/03/enable-disable-reset-mfa-with-powershell/
    Version:            1.0
    Author:             Scott E. Royalty
    Last Modified Date: 7/20/2022
#>
param( [Parameter(Mandatory=$true)] $WorkerEmail, [Parameter(Mandatory=$true)] $MFAUserName)

$MSOCred = Get-Credential -Message "Credentials required" -User $WorkerEmail
Connect-MsolService -Credential $MSOCred


$user = Get-MsolUser -UserPrincipalName $MFAUserName
$SAR = New-Object -TypeName Microsoft.Online.Administration.StrongAuthenticationRequirement
$sar.RelyingParty = "*"
$sar.State = "Disabled"
$sarobject = @($sar)
Set-MsolUser -UserPrincipalName $user.Userprincipalname -StrongAuthenticationRequirements $sarobject
Get-MsolUser -UserPrincipalName $MFAUserName | Set-MsolUser -StrongAuthenticationRequirements @()

Pause