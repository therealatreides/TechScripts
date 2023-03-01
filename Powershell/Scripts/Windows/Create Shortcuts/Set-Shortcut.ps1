<#
.SYNOPSIS
	Creation of shortcut files
.DESCRIPTION
	Allows create of shortcuts with params to set target, optional arguments, icon, and destination path.
.EXAMPLE
	Set-Shortcut.ps1 -TargetFile "C:\Test\MyFile.exe" -DestinationPath "C:\Users\Public\Desktop\Myfile.lnk" -TargetArguments "/f /s" -IconFile "C:\Test\icon.ico"
.NOTES
    Version:            1.0
    Author:             Scott E. Royalty
    Last Modified Date: 3/1/2023
#>

param ( [Parameter(Mandatory=$true)]$TargetFile, [Parameter(Mandatory=$true)]$DestinationPath, [string]$TargetArguments, [string]$IconFile )
$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut($DestinationPath)
$Shortcut.TargetPath = $TargetFile
if($IconFile.Length -gt 1) {
    $Shortcut.Arguments = $TargetArguments
}
if($IconFile.Length -gt 1) {
    $Shortcut.IconLocation = $IconFile
}
$Shortcut.Save()