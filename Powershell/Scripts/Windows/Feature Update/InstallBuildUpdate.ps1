<#
.DESCRIPTION
    This script will download the Windows 10 Update Assistant from Microsoft and launch it in an automated manner.
    Simplifying the process for network deployment even if the user is working Remote and doesn't have intranet
    access for your server at the time of execution.
.NOTES
    Run with elevated permissions
    $SilentInstall flag is used for headless install.

    Version:            1.0
    Author:             Scott E. Royalty
    Last Modified Date: 7/31/2022
#>
param( $SilentInstall="No")

$FUFolder = "C:\Temp\FeatureUpdate"
if (-not (Test-Path -LiteralPath $FUFolder)) {

    try {
        New-Item -Path $FUFolder -ItemType Directory -ErrorAction Stop | Out-Null #-Force
    }
    catch {
        Write-Error -Message "Unable to create directory '$FUFolder'. Error was: $_" -ErrorAction Stop
    }
    "Successfully created directory '$FUFolder'."

}

$webClient = New-Object System.Net.WebClient
$updateURL = 'https://go.microsoft.com/fwlink/?LinkID=799445'
$file = "$($FUFolder)\Win10Upgrade.exe"
$webClient.DownloadFile($updateURL,$file)

If ($SilentInstall -eq "No") {
    Start-Process -FilePath $file -ArgumentList '/skipeula /SkipCompatCheck /auto upgrade /copylogs $FUFolder'
}
else {
    Start-Process -FilePath $file -ArgumentList '/quietinstall /skipeula /SkipCompatCheck /auto upgrade /copylogs $FUFolder'
}
