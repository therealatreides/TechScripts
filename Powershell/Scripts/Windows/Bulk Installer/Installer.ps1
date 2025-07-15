<#
.DESCRIPTION
    This script will install applications based on a CSV you pass to it.
    See example CSV file for formatt. Each header self explains what the
    column is for. Enabled column uses 1 to install, anything else ignores
    that line.

    * This is a basic bulk installer, allowing you to push out multiple apps
    based on the CSV file you pass into it. Flags for installers can be included
    in order to customize the installs for silent or other options.

    On 3/24, added support for Winget by ensuring it is installed.
    
    This requires elevated permissions usually unless the application is user specific.
.NOTES
    Version:            1.1
    Author:             Scott E. Royalty
    Last Modified Date: 3/24/2025
#>
param( [Parameter(Mandatory=$true)] $CSVFile, $WorkPath="Default")

Set-Variable -Name 'ConfirmPreference' -Value 'None' -Scope Global
$ProgressPreference = 'SilentlyContinue'

# Let's import the CSV that contains our application's details needing installed
try {
    Write-Host "Importing application list from CSV: $CSVFile" -ForegroundColor Yellow
    $applications = Import-CSV -path $CSVFile -ErrorAction Stop
    Write-Host "Successfully imported $($applications.Count) applications from CSV" -ForegroundColor Green
} catch {
    Write-Error "Failed to import CSV file: $($_.Exception.Message)"
    Write-Host "Please ensure the CSV file exists and has proper formatting" -ForegroundColor Red
    exit 1
}

# Set this to the general place you execute the script from. 
if ($WorkPath -eq "Default") {
    $WorkPath = $PSScriptRoot
}

try {
    Set-Location $WorkPath -ErrorAction Stop
    Write-Host "Working directory set to: $WorkPath" -ForegroundColor Green
} catch {
    Write-Error "Failed to set working directory: $($_.Exception.Message)"
    exit 1
}

# Check if WinGet is installed, as some installations may require this.
Write-Host ("Verifying Winget is installed. This allows Winget to be used for installs and updates.") -ForegroundColor Yellow
try {
    $wingetPackage = Get-AppPackage -AllUsers -ErrorAction Stop | Where-Object { $_.Name -like "Microsoft.Winget.Source" }
    if (-not $wingetPackage) {
        Write-Host ("Winget not installed. Downloading and installing packages....") -ForegroundColor Red
        
        # Download required packages with error handling
        try {
            Write-Host "Downloading Microsoft.VCLibs..." -ForegroundColor Yellow
            Invoke-WebRequest -Uri "https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx" -OutFile "$ENV:TEMP\Microsoft.VCLibs.x64.14.00.Desktop.appx" -ErrorAction Stop
            
            Write-Host "Downloading Winget..." -ForegroundColor Yellow
            Invoke-WebRequest -Uri "https://aka.ms/getwinget" -OutFile "$ENV:TEMP\winget.msixbundle" -ErrorAction Stop
            
            Write-Host "Installing Microsoft.VCLibs..." -ForegroundColor Yellow
            Add-AppxPackage "$ENV:TEMP\Microsoft.VCLibs.x64.14.00.Desktop.appx" -ErrorAction Stop
            
            Write-Host "Installing Winget..." -ForegroundColor Yellow
            Add-AppxPackage -Path "$ENV:TEMP\winget.msixbundle" -ErrorAction Stop
            
            Write-Host "Winget installation completed successfully" -ForegroundColor Green
        } catch {
            Write-Error "Failed to download or install Winget: $($_.Exception.Message)"
            Write-Host "Please check your internet connection and try again" -ForegroundColor Red
            Write-Host "You may need to install Winget manually from the Microsoft Store" -ForegroundColor Yellow
            # Continue execution as not all installations require Winget
        }
    } else {
        Write-Host "Winget is already installed" -ForegroundColor Green
    }
} catch {
    Write-Warning "Could not verify Winget installation status: $($_.Exception.Message)"
    Write-Host "Continuing without Winget verification..." -ForegroundColor Yellow
}

Write-Host ("Winget verification completed.`n") -ForegroundColor Green

Write-Host ("Preparing to install applications and run commands from your CSV file....`n") -ForegroundColor Green

$successCount = 0
$failureCount = 0

$applications | ForEach-Object {
    if ($_.Enabled -eq "1") {
        try {
            # Validate application path and file exist
            if (-not (Test-Path $_.AppPath)) {
                Write-Error "Application path does not exist: $($_.AppPath)"
                $failureCount++
                return
            }
            
            Set-Location $_.AppPath -ErrorAction Stop
            
            $fullAppPath = Join-Path $_.AppPath $_.AppFile
            if (-not (Test-Path $fullAppPath)) {
                Write-Error "Application file does not exist: $fullAppPath"
                $failureCount++
                return
            }
            
            Write-Host "Installing $($_.AppName)..." -ForegroundColor Yellow
            
            if ($_.AppFlags.Length -gt 0) {
                Start-Process -Wait -FilePath $_.AppFile -ArgumentList $_.AppFlags -ErrorAction Stop
            } else {
                Start-Process -Wait -FilePath $_.AppFile -ErrorAction Stop
            }
            
            Write-Host "Successfully installed $($_.AppName)" -ForegroundColor Green
            $successCount++
            
        } catch {
            Write-Error "Failed to install $($_.AppName): $($_.Exception.Message)"
            Write-Host "Continuing with remaining applications..." -ForegroundColor Yellow
            $failureCount++
        }
    }
}

try {
    Set-Location $WorkPath -ErrorAction Stop
    
    # Clean-up downloaded Winget Packages
    Write-Host "Cleaning up temporary files..." -ForegroundColor Yellow
    Remove-Item "$ENV:TEMP\Microsoft.VCLibs.x64.14.00.Desktop.appx" -ErrorAction SilentlyContinue
    Remove-Item "$ENV:TEMP\winget.msixbundle" -ErrorAction SilentlyContinue
    Remove-Item "$ENV:TEMP\Winget" -Recurse -Force -ErrorAction SilentlyContinue
    
    Write-Host "`nApplication Installation Summary:" -ForegroundColor Cyan
    Write-Host "Successfully installed: $successCount applications" -ForegroundColor Green
    Write-Host "Failed installations: $failureCount applications" -ForegroundColor Red
    Write-Host ("Application Installs and Commands completed.`n") -ForegroundColor Green
    
} catch {
    Write-Warning "Failed to return to working directory or clean up files: $($_.Exception.Message)"
}