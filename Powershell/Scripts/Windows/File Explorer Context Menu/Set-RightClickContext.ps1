<#
.DESCRIPTION
    This script will help you change the behavior of the right click context
    menu in the Windows/File Explorer interface.
    
.NOTES
    Version:            1.0
    Author:             Scott E. Royalty
    Last Modified Date: 4/22/2025
#>
param($ClassicMenu="0")

if ($ClassicMenu -eq "0") {
    reg.exe delete "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}" /f
} Else {
    reg.exe add "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /f /ve
}