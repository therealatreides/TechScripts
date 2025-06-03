# WinISOConfig Scripts

This section of the repository provides examples of a Windows 11 configuration with the ability to make easy adjustments for your own custom install. This example can be copied as-is directly into the root folder of your USB drive. Below is a list of the provided configuration files, highlighting any recommended changes (such as passwords) to make before copying them over.

Let me know if you encounter any issues using them, as there is always room for improvement.

---

## Unattend.xml File Settings

- **Timezone**: Configured for Eastern (EST)
- **Language/Locale**: Set to `en-US`
- **EULA**: Automatically accepted
- **UseConfiguration**:
  - Windows Install will copy all files and folders from `\sources\$OEM$\$1` directly to the root of the `C:` drive where Windows is installed. This is handy for drivers or applications you always want copied over to install after Windows logs in.
- **Bypass Checks**:
  - TPM and Secure Boot checks included
  - RAM check included
- **Default Account**:
  - Creates the default account `MyUser` with the password listed in the `unattend.xml` file.
  - Search the XML file to find all instances of `MyUser` to update the username and/or password.
- **First Boot**:
  - Skips the settings screen during first boot
  - Skips all user interaction on first boot and logs into the auto-created account
  - Skips wireless configuration
  - Logs into the user account on the first boot. On the next reboot, it will prompt to update the password.
- **Password Expiration**:
  - There is a section commented out that will set the password to never expire. Uncomment this section if you don't want it to prompt for a password change on the first reboot.

---

## Donations

To support this project, you can make a donation to the current maintainer:

### PayPal

[![Donate via PayPal](https://github.com/therealatreides/TechScripts/blob/main/ImageRepository/paypal_btn_donateCC_LG_1.gif)](https://www.paypal.com/donate/?hosted_button_id=E6BPVFVTQ6TKU)

### CashApp

$MuadDibttv

<img src="https://github.com/therealatreides/TechScripts/blob/main/ImageRepository/cashapp_qr.png" alt="CashApp QR for $MuadDibttv" width="265px">