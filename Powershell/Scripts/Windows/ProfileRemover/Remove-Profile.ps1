<#
.SYNOPSIS
    Find the last logoff for a user based on System Event Log and compares it to the time limit passed.
.DESCRIPTION
    Script looks through event logs to find the last time a user logged off. If a time is found
    and that time is greater than the days passed, it then uses CIM to remove the profile.

    If you pass ANYTHING to the -Cleanup parameter, it will cause it to Remove the profile when
    it finds a profile past the days last logged in that you passed. You have been warned.

    If there is open files/tasks, then this must be ran at startup/login.

    This requires elevated permissions.
.EXAMPLE
    Remove-Profile.ps1 -User seroyalty -Days 60
.EXAMPLE
    Remove-Profile.ps1 -User seroyalty -Days 60 -Cleanup True
.NOTES
    Version:            1.0
    Author:             Scott E. Royalty
    Last Modified Date: 1/8/2023
#>

param( [Parameter(Mandatory=$true)] $User, [Parameter(Mandatory=$true)] $Days, $Cleanup=$false )

If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" $PSCommandArgs" -Verb RunAs
    Exit
}

if ($Cleanup -ne $false) {
    $Cleanup = $true
}

function Get-LastLogoff {
    param (
        [string]$User = "ITWantsToKnow"
    )

    $found = 0
    $logoffTime = 0
    $today = get-date

    $filterXml = "
        <QueryList>
            <Query Id='0' Path='System'>
            <Select Path='System'>
                *[System[
			        Provider[@Name = 'Microsoft-Windows-Winlogon']
                    ]
                ]
            </Select>
            </Query>
        </QueryList>
    "
    $ELogs = Get-WinEvent -FilterXml $filterXml

    # $ELogs = Get-EventLog System -Source Microsoft-Windows-WinLogon -After (Get-Date).AddDays(-$Days) -ComputerName $Computer

    if ($ELogs) {
        foreach ($Log in $ELogs) {
            switch ($Log.id) {
                7001 {$ET = 'Logon'}
                7002 {$ET = 'Logoff'}
                default {continue}
            }

            # If it's not a logoff event, we don't care. User is still logged on if they have a logon, but no logoff
            if ($ET -ne 'Logoff') {
                continue
            }

            $evUser = (New-Object System.Security.Principal.SecurityIdentifier $Log.Properties.value.value).Translate([System.Security.Principal.NTAccount])
            if ($evUser -ne $User){
                # This is not the droid you are looking for
                continue
            } else {
                # Found last logon, since events are pulled in order of latest to oldest. We are done here.
                # Record what we need, and exit the loop.
                $found = 1
                $logoffTime = (New-TimeSpan -Start $Log.timecreated -End $today).days
                break
            }
        }
    } else {
        # Exit code 2 for "Error, since impossible for a deployed PC to have 0 logoff actions unless event logs were cleared right before running this script"
        exit 2
    }
    if ($found -eq 1) {
        # Person logged on and off of PC at least 1 time since last time the event logs were cleared.
        return $logoffTime
    } else {
        return $false
    }
}

$logCheck = Get-LastLogoff -User $User

if ($logCheck -is [System.Boolean]) {
    Write-Host "User has never logged on"
    exit 2
}

if ($logCheck -ge $Days) {
    # range is outside what we want, so we should remove the profile.
    Write-Host "Last logoff was greater than $Days days ago"
    if ($Cleanup -ne $false){
        Get-CimInstance win32_userprofile -filter "localpath like '%$User%'" | Remove-CimInstance
    }
    exit 0
} else {
    # range is within our defined time period, no need to remove the account
    Write-Host "Last logoff was less than $Days days ago"
    exit 1
}
