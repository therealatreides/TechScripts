<#
.SYNOPSIS
    Checks all profiles from the ProfileList in the registry for cleaning up orphaned users.

.DESCRIPTION
    Script pulls list of profiles via ProfileList and checks them against Active Directory.
	If nothing is found, it removes the profile from the computer using CIM.

    If there is open files/tasks, then this must be ran at startup/login.

    This requires elevated permissions.

.EXAMPLE
    Remove-OrphanedProfiles.ps1 -Server MyDC01 -ProtectedUsers "Admin,defaultuser0,Administrator" -DomainName DomainPrefix

.EXAMPLE
    Remove-OrphanedProfiles.ps1 -Server MyDC06 -ProtectedUsers "defaultuser0,Administrator" -DomainName DomainPrefix

.NOTES
    Version:            1.0
    Author:             Scott E. Royalty
    Last Modified Date: 10/21/2023
#>

param( [Parameter(Mandatory=$true)] $Server, [Parameter(Mandatory=$true)] $ProtectedUsers, [Parameter(Mandatory=$true)] $DomainName )

Function Test-ADUser {
  param(
    [parameter(Mandatory=$true)]
    [string]$Username,
    [parameter(Mandatory=$true)]
    [string]$ServerName
    )
     Try {
       Get-ADUser -Identity $Username -Server $ServerName -ErrorAction Stop
       return $true
    } Catch {
        return $false
    }
}

# This should be set to an account that will always exist in AD, regardless.
# If account check fails, that means AD module not installed, so we install it.
 Try {
   Get-ADUser -Identity "Administrator" -ErrorAction Stop
} Catch {
	Add-WindowsCapability -online -Name "Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0"
}

$UserList = Get-ChildItem 'HKLM:\Software\Microsoft\Windows NT\CurrentVersion\ProfileList' | ForEach-Object { $_.GetValue('ProfileImagePath') }

foreach ($UserPath in $UserList) {
	$User = $UserPath.split('\')[-1]
	$PhysicalPath = $User

	# This check is done for those with two profile directories on the account.
	# Since we use ProfileList, that is the folder they SHOULD be using.
	# This pulls the actual AD Account with this method to check against
	# while preserving the entry to remove if the user does not exist.
	# We then try to remove BOTH if the user does not exist, for a full
	# and complete cleanup of terminated employees
	#
	# Example: If domain is mydocmain.work.com then you simply pass mydocmain
	# It will check to see if it contains that like user.mydocmain for profile list or folder.
	if (($User.IndexOf($DomainName) -gt -1)) {
		$User = $User.split('.')[-2]
	}

	if ($ProtectedUsers.IndexOf($User) -gt -1) {
		Write-Output "User [$User] is a protected account. Skipping it."
		continue
	}

	if ($UserPath.split('\')[-2] -eq "Users"){
		if (Test-ADUser -Username $User -ServerName $Server) {
			Write-Output "AD User [$User] exists in [$DomainName]"
			continue
		} else {
			Write-Output "User [$User] does not exist in AD."

			# First try to remove against just the AD username
			$ThisUser = Get-CimInstance win32_userprofile | Where-Object { $_.LocalPath.split('\')[-1] -eq "$User" } -ErrorAction SilentlyContinue
			If ($ThisUser.Loaded) {
				Write-Output "User is loaded. Skipping removal"
			} else {
				Get-CimInstance win32_userprofile | Where-Object { $_.LocalPath.split('\')[-1] -eq "$User" } | Remove-CimInstance
				Write-Output "User profile has been removed"
			}

			# Then try to remove against the PhysicalPath variable if it is different.
			if ($PhysicalPath.Length -gt $User.Length) {
				$ThisUser = Get-CimInstance win32_userprofile | Where-Object { $_.LocalPath.split('\')[-1] -eq "$PhysicalPath" } -ErrorAction SilentlyContinue
				If ($ThisUser.Loaded) {
					Write-Output "User is loaded. Skipping removal"
				} else {
					Get-CimInstance win32_userprofile | Where-Object { $_.LocalPath.split('\')[-1] -eq "$PhysicalPath" } | Remove-CimInstance
					Write-Output "User profile has been removed"
				}
			}
		}
	}

}