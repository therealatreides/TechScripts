<#
.DESCRIPTION
    This script will clear cache locations across the Windows install in order to clean up the PC.
    This is ran across all users of the PC, thus requires elevated permissions.
.NOTES
    Version:            1.1
    Author:             Scott E. Royalty
    Last Modified Date: 7/31/2022
.CHANGELOG
    1.1
        Removed storage checking stuff - This is for automation anyway, and not recording it.
        Added the following functions for additional cleanup
            Clear-RogueFolders - Used to clean up ghost folders from known packages
            Clear-WindowsOld - Clears out the Windows.Old folder left behind by Feature Updates and Upgrades
            Clear-EventLogs - Clears all the event logs
            Clear-ErrorReports - Clears the primary Error Report folder
#>

If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" $PSCommandArgs" -Verb RunAs
    Exit
}

#------------------------------------------------------------------#
#- Clear-RogueFolders                                              #
#------------------------------------------------------------------#
Function Clear-RogueFolders {
    Write-Host "Clearing Known Rogue Folders at C:\ ..."
    if (Test-Path C:\Config.Msi) {remove-item -Path C:\Config.Msi -force -recurse}
    if (Test-Path C:\Dell) {remove-item -Path C:\Dell -force -recurse}
	if (Test-Path c:\Intel) {remove-item -Path c:\Intel -force -recurse}
	if (Test-Path c:\PerfLogs) {remove-item -Path c:\PerfLogs -force -recurse}
    if (Test-Path $env:windir\memory.dmp) {remove-item $env:windir\memory.dmp -force}
}

#------------------------------------------------------------------#
#- Clear-WindowsUpdateCache                                                #
#------------------------------------------------------------------#
function Clear-WindowsUpdateCache {
    Write-Host "Clearing Windows Update cache..."
    Stop-Service -Name wuauserv -Force -ErrorAction SilentlyContinue
    Remove-Item "C:\Windows\SoftwareDistribution\Download\*" -Recurse -Force -ErrorAction SilentlyContinue
    Start-Service -Name wuauserv -ErrorAction SilentlyContinue
}

#------------------------------------------------------------------#
#- Clear-WindowsOld                                                #
#------------------------------------------------------------------#
Function Clear-WindowsOld {
    Write-Host "Clearing Windows.Old folder..."
    If(Test-Path C:\Windows.old)
    {
        New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Previous Installations" -Name "StateFlags1221" -PropertyType DWORD  -Value 2 -Force | Out-Null
        Start-Process -FilePath "cleanmgr" -ArgumentList /SAGERUN:1221 -Wait -WindowStyle Hidden
    }
}

#------------------------------------------------------------------#
#- Clear-EventLogs                                                 #
#------------------------------------------------------------------#
Function Clear-EventLogs {
    Write-Host "Clearing Event logs..."
    wevtutil el | Foreach-Object {wevtutil cl "$_"}
}

#------------------------------------------------------------------#
#- Clear-ErrorReports                                              #
#------------------------------------------------------------------#
Function Clear-ErrorReports {
    Write-Host "Clearing Error reports..."
    if (Test-Path C:\ProgramData\Microsoft\Windows\WER) {Get-ChildItem -Path C:\ProgramData\Microsoft\Windows\WER -Recurse | Remove-Item -force -recurse}
}

#------------------------------------------------------------------#
#- Clear-GlobalWindowsCache                                        #
#------------------------------------------------------------------#
Function Clear-GlobalWindowsCache {
    Write-Host "Clearing global OS cache..."
    Clear-RecycleBin -DriveLetter C -Force -ErrorAction SilentlyContinue
    Remove-CacheFiles 'C:\Windows\Temp'
#    Remove-CacheFiles "C:\Windows\Prefetch"
    C:\Windows\System32\rundll32.exe InetCpl.cpl, ClearMyTracksByProcess 255
    C:\Windows\System32\rundll32.exe InetCpl.cpl, ClearMyTracksByProcess 4351
}

#------------------------------------------------------------------#
#- Clear-UserCacheFiles                                            #
#------------------------------------------------------------------#
Function Clear-UserCacheFiles {
    Write-Host "Clearing base browser cache..."
    Stop-BrowserSessions
    ForEach($localUser in (Get-ChildItem 'C:\users').Name)
    {
        Clear-ChromeCache $localUser
        Clear-EdgeCacheFiles $localUser
        Clear-FirefoxCacheFiles $localUser
        Clear-WindowsUserCacheFiles $localUser
    }
}

#------------------------------------------------------------------#
#- Clear-WindowsUserCacheFiles                                     #
#------------------------------------------------------------------#
Function Clear-WindowsUserCacheFiles {
    Write-Host "Clearing User cache..."
    param([string]$user=$env:USERNAME)
    Remove-CacheFiles "C:\Users\$user\AppData\Local\Temp"
    Remove-CacheFiles "C:\Users\$user\AppData\Local\Microsoft\Windows\WER"
    Remove-CacheFiles "C:\Users\$user\AppData\Local\Microsoft\Windows\INetCache"
    Remove-CacheFiles "C:\Users\$user\AppData\Local\Microsoft\Windows\INetCookies"
    Remove-CacheFiles "C:\Users\$user\AppData\Local\Microsoft\Windows\IECompatCache"
    Remove-CacheFiles "C:\Users\$user\AppData\Local\Microsoft\Windows\IECompatUaCache"
    Remove-CacheFiles "C:\Users\$user\AppData\Local\Microsoft\Windows\IEDownloadHistory"
    Remove-CacheFiles "C:\Users\$user\AppData\Local\Microsoft\Windows\Temporary Internet Files"
}

#Region HelperFunctions

#------------------------------------------------------------------#
#- Stop-BrowserSessions                                            #
#------------------------------------------------------------------#
Function Stop-BrowserSessions {
   Stop-Process -Name 'chrome*' -Force
   Stop-Process -Name 'iexplore*' -Force
   Stop-Process -Name 'msedge*' -Force
   Stop-Process -Name 'firefox*' -Force
}

#------------------------------------------------------------------#
#- Remove-CacheFiles                                               #
#------------------------------------------------------------------#
Function Remove-CacheFiles {
    param([Parameter(Mandatory=$true)][string]$path)
    BEGIN
    {
        $originalVerbosePreference = $VerbosePreference
        $VerbosePreference = 'Continue'
    }
    PROCESS
    {
        if((Test-Path $path))
        {
            if([System.IO.Directory]::Exists($path))
            {
                try
                {
                    if($path[-1] -eq '\')
                    {
                        [int]$pathSubString = $path.ToCharArray().Count - 1
                        $sanitizedPath = $path.SubString(0, $pathSubString)
                        Remove-Item -Path "$sanitizedPath\*" -Recurse -Force -ErrorAction SilentlyContinue
                    }
                    else
                    {
                        Remove-Item -Path "$path\*" -Recurse -Force -ErrorAction SilentlyContinue
                    }
                } catch { }
            }
            else
            {
                try
                {
                    Remove-Item -Path $path -Force -ErrorAction SilentlyContinue
                } catch { }
            }
        }
    }
    END
    {
        $VerbosePreference = $originalVerbosePreference
    }
}

#Endregion HelperFunctions

#Region Browsers

#Region ChromiumBrowsers

#------------------------------------------------------------------#
#- Clear-ChromeCache                                               #
#------------------------------------------------------------------#
Function Clear-ChromeCache {
    param([string]$user=$env:USERNAME)
    if((Test-Path "C:\users\$user\AppData\Local\Google\Chrome\User Data\Default"))
    {
        $chromeAppData = "C:\Users\$user\AppData\Local\Google\Chrome\User Data\Default"
        $possibleCachePaths = @('Cache','Cache2\entries\','Cookies','History','Top Sites','VisitedLinks','Web Data','Media Cache','Cookies-Journal','ChromeDWriteFontCache')
        ForEach($cachePath in $possibleCachePaths)
        {
            Remove-CacheFiles "$chromeAppData\$cachePath"
        }
    }
}

#------------------------------------------------------------------#
#- Clear-EdgeCacheFiles                                            #
#------------------------------------------------------------------#
Function Clear-EdgeCacheFiles {
    param([string]$user=$env:USERNAME)
    if((Test-Path "C:\Users$user\AppData\Local\Microsoft\Edge\User Data\Default"))
    {
        $EdgeAppData = "C:\Users$user\AppData\Local\Microsoft\Edge\User Data\Default"
        $possibleCachePaths = @('Cache','Cache2\entries','Cookies','History','Top Sites','Visited Links','Web Data','Media History','Cookies-Journal')
        ForEach($cachePath in $possibleCachePaths)
        {
            Remove-CacheFiles "$EdgeAppData$cachePath"
        }
        }
}

#Endregion ChromiumBrowsers

#Region FirefoxBrowsers

#------------------------------------------------------------------#
#- Clear-FirefoxCacheFiles                                         #
#------------------------------------------------------------------#
Function Clear-FirefoxCacheFiles {
    param([string]$user=$env:USERNAME)
    if((Test-Path "C:\users\$user\AppData\Local\Mozilla\Firefox\Profiles"))
    {
        $possibleCachePaths = @('cache','cache2\entries','thumbnails','cookies.sqlite','webappsstore.sqlite','chromeappstore.sqlite')
        $firefoxAppDataPath = (Get-ChildItem "C:\users\$user\AppData\Local\Mozilla\Firefox\Profiles" | Where-Object { $_.Name -match 'Default' }[0]).FullName
        ForEach($cachePath in $possibleCachePaths)
        {
            Remove-CacheFiles "$firefoxAppDataPath\$cachePath"
        }
    }
}

#------------------------------------------------------------------#
#- Clear-WaterfoxCacheFiles                                        #
#------------------------------------------------------------------#
Function Clear-WaterfoxCacheFiles {
    param([string]$user=$env:USERNAME)
    if((Test-Path "C:\users\$user\AppData\Local\Waterfox\Profiles"))
    {
        $possibleCachePaths = @('cache','cache2\entries','thumbnails','cookies.sqlite','webappsstore.sqlite','chromeappstore.sqlite')
        $waterfoxAppDataPath = (Get-ChildItem "C:\users\$user\AppData\Local\Waterfox\Profiles" | Where-Object { $_.Name -match 'Default' }[0]).FullName
        ForEach($cachePath in $possibleCachePaths)
        {
            Remove-CacheFiles "$waterfoxAppDataPath\$cachePath"
        }
    }
}

#Endregion FirefoxBrowsers

#Endregion Browsers

#------------------------------------------------------------------#
#- MAIN                                                            #
#------------------------------------------------------------------#

Clear-UserCacheFiles
Clear-GlobalWindowsCache
Clear-RogueFolders
Clear-WindowsUpdateCache
Clear-WindowsOld
Clear-EventLogs
Clear-ErrorReports