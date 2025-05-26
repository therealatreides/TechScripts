# WinISOConfig Scripts

This section of the repository is for examples of a Windows 11 configuration with the ability
to make easy adjustments for your own custom install. This example can be copied as-is right
into the root folder of your USB drive you are using. The list below of the provided config
files will highlight any recommended changes (such as password!!) to make before you copy it
over.

Let me know if you have any issues using them, as there is always space for improvement.

## Unattend.xml file settings:
Timezone configured for Eastern (EST)
Language/Locale is set to en-US
Accept EULA automatically
Use Configuration:
    This will cause Windows Install to copy all files and folders from \sources\$OEM$\$1
    directly over to the root of the C: that Windows is installed to. Handy for drivers
    or applications you always want copied over to install after Windows logs in.
Bypass TPM and Secure Boot Checks have been included
Bypass RAM check included
Creates the default account of "MyUser" with password listed in unattend.xml file
    (Search the XML to find all the places MyUser exists to update username and/or password)
Skips the settings screen during first boot
Skips all user interaction on first boot and logs into the auto created account
Skips wirless configuration
Logs into the user account on the first boot. Next reboot, it will prompt to update password
There is a section commented out that will set the password to never expire. Uncomment
    this if you don't want it to prompt to change on first reboot.

## Donations
To support this project, you can make a donation to the current maintainer:

### Paypal:

[![Paypal](https://github.com/therealatreides/TechScripts/blob/main/ImageRepository/paypal_btn_donateCC_LG_1.gif)](https://www.paypal.com/donate/?hosted_button_id=E6BPVFVTQ6TKU)

### Cashapp: $MuadDibttv

<img src="https://github.com/therealatreides/TechScripts/blob/main/ImageRepository/cashapp_qr.png" alt="Cashapp QR for $MuadDibttv" width="265px">
