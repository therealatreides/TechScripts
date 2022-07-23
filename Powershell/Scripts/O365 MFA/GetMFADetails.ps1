<#
.DESCRIPTION
    This script will pull and display the MFA related details for a user on your tenant.
.NOTES
    Requires the MSOnline module to be installed. - Install-Module MSOnline

    Version:            1.0
    Author:             Scott E. Royalty
    Last Modified Date: 7/20/2022
#>
param( [Parameter(Mandatory=$true)] $WorkerEmail, [Parameter(Mandatory=$true)] $MFAUserName)

$MSOCred = Get-Credential -Message "Credentials required" -User $WorkerEmail
Connect-MsolService -Credential $MSOCred

$vUser = Get-MsolUser -UserPrincipalName $MFAUserName -ErrorAction SilentlyContinue
If ($vUser) {
    Write-Host
    Write-Host User Details for $vUser.UserPrincipalName
    Write-Host
    Write-Host "Self-Service Password Feature (SSP)..: " -NoNewline;
    If ($vUser.StrongAuthenticationUserDetails) {  Write-Host -ForegroundColor Green "Enabled"}Else{ Write-Host -ForegroundColor Yellow "Not Configured"}
    Write-Host "MFA Feature (Portal) ................: " -NoNewline;
    If ((($vuser | Select-Object -ExpandProperty StrongAuthenticationRequirements).State) -ne $null) { Write-Host -ForegroundColor Yellow "Enabled! It overrides Conditional"}Else{ Write-Host -ForegroundColor Green "Not Configured"}
        Write-Host "MFA Feature (Conditional)............: " -NoNewline;
        If ($vUser.StrongAuthenticationMethods){
        Write-Host -ForegroundColor Green "Enabled"
        Write-Host
        Write-host "Authentication Methods:"
        for ($i=0;$i -lt $vuser.StrongAuthenticationMethods.Count;++$i){
            Write-host $vUser.StrongAuthenticationMethods[$i].MethodType "(" $vUser.StrongAuthenticationMethods[$i].IsDefault ")"
        }
        Write-Host
        Write-Host "Phone entered by the end-user:"
        Write-Host "Phone Number.........: " $vuser.StrongAuthenticationUserDetails.PhoneNumber
        Write-Host "Alternative Number...: "$vuser.StrongAuthenticationUserDetails.AlternativePhoneNumber
    }Else{
        Write-Host -ForegroundColor Yellow "Not Configured"
    }
    Write-Host
    Write-Host "License Requirements.................: " -NoNewline;
    $vLicense = $False
    for ($i=0;$i -lt $vuser.Licenses.Count;++$i){
        if (($vuser.licenses[$i].AccountSkuid) -like '*P1*') { $vLicense = $true }
    }
    If ($vLicense){Write-Host -ForegroundColor Green "Enabled"}Else{ Write-Host -ForegroundColor Yellow "Not Licensed"}
}Else{
    write-host
    write-host -ForegroundColor Red "[Error]: User $MFAUserName couldn't be found. Check the username and try again"
}

Pause