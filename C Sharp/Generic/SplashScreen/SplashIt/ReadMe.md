# Splash It!

This is a simple splash screen utility. It utilizes a .NET Web Browser control to display an HTML file of your choosing
for the splash screen. The screen will display until the name of the process you give it has exited.

You may also pass the resolution (Width Height) to the application for your HTML. The end user cannot close it until the
process you passed to it has ended.

This came to be due to the need to replace Internet Explorer style splash screens in older Map Drives logon systems
such as earlier versions of Kixtart and other headless utilities that may run at logon. These have typically stopped
working due to IE being put to rest by Microsoft in Windows 10 and not included with Windows 11.


## Usage

### SplashIt.exe (flags) | (options)

#### Flags:
* --help, -h      : Display a messagebox with the this help text

#### Options:
* process_name  : Name of the process to monitor. Once this process closes, the SplashIt app should close
* html_file     : Path and filename (or web url) of the html file to display as the splash screen
* width         : Width of the application (not web page displayed)
* height        : Height of the application (not web page displayed)

#### Examples:
* SplashIt.exe Telegram "http://www.example.com/LogonWindow.htm" 830 630
* SplashIt.exe Kix32 \\\server\logon\Logon.htm 633 490

An example HTM and gif are included in the Binaries zip.

## Donations
To support this project, you can make a donation to the current maintainer:

### Paypal:

[![Paypal](https://github.com/therealatreides/TechScripts/blob/main/ImageRepository/paypal_btn_donateCC_LG_1.gif)](https://www.paypal.com/donate/?hosted_button_id=E6BPVFVTQ6TKU)

### Cashapp: $MuadDibttv

<img src="https://github.com/therealatreides/TechScripts/blob/main/ImageRepository/cashapp_qr.png" alt="Cashapp QR for $MuadDibttv" width="265px">
