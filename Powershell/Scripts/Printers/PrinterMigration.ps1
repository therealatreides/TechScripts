<#
.DESCRIPTION
    This script will reinstall or migrate printers based only on the ones installed for the user it is being ran on.

    Run with Admin rights.
    
.EXAMPLE
	.\PrinterMigration -MigrationList.csv
	
.Example
	CSV File format:
		Old,New
		\\server1\Printer 1,\\newserver\Printer 1
	

.NOTES
    Version:            1.0
    Author:             Scott E. Royalty
    Last Modified Date: 10/15/2023
#>

param( [Parameter(Mandatory=$true)] $MigrationList)

$PrinterList = Import-CSV "$MigrationList"

For ($i=0; $i -lt $PrinterList.Length; $i++) {
    Try {
        Write-Host "Migrating Printer"
        Write-Host "----------------------------------------------"
        Write-Host "Old Printer: " $PrinterList[$i].Old
        Write-Host "New Printer: " $PrinterList[$i].New
        Get-Printer -Name $PrinterList[$i].Old -ErrorAction STOP
        Remove-Printer -Name $PrinterList[$i].Old
		Write-Host $PrinterList[$i].Old " has been removed"
        Add-Printer -ConnectionName $PrinterList[$i].New
		Write-Host $PrinterList[$i].New " has been added"
    } Catch {
        Write-Host "Printer not Found, skipping device - " $PrinterList[$i].Old
    }
}