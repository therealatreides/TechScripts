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

try {
    Write-Host "Connecting to Microsoft Online Service..." -ForegroundColor Yellow
    $MSOCred = Get-Credential -Message "Credentials required" -User $WorkerEmail
    Connect-MsolService -Credential $MSOCred -ErrorAction Stop
    Write-Host "Successfully connected to Microsoft Online Service" -ForegroundColor Green
    
    Write-Host "Retrieving user information for: $MFAUserName" -ForegroundColor Yellow
    $vUser = Get-MsolUser -UserPrincipalName $MFAUserName -ErrorAction Stop
    
    if ($vUser) {
        Write-Host
        Write-Host "User Details for $($vUser.UserPrincipalName)" -ForegroundColor Cyan
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
    } else {
        Write-Host
        Write-Host -ForegroundColor Red "[Error]: User $MFAUserName couldn't be found. Check the username and try again"
    }
    
} catch {
    Write-Error "Failed to retrieve MFA details: $($_.Exception.Message)"
    Write-Host "Common issues:" -ForegroundColor Yellow
    Write-Host "- Invalid credentials" -ForegroundColor Yellow
    Write-Host "- User does not exist" -ForegroundColor Yellow
    Write-Host "- Insufficient permissions" -ForegroundColor Yellow
    Write-Host "- MSOnline module not installed (Install-Module MSOnline)" -ForegroundColor Yellow
    exit 1
}

Write-Host
Write-Host "Press any key to continue..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')