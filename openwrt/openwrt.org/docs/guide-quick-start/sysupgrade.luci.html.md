# Upgrading OpenWrt firmware using LuCI

Note that this article describes the basic upgrade process, for which more modern tools may better suit your needs. LuCI Attended Sysupgrade (or its command line alternative `auc`) combines the upgrade process described below with creation of a custom image containing any extra packages that you have installed, often streamlining the upgrade process considerably.

For more, see [Upgrade using Attended Sysupgrade](/docs/guide-user/installation/attended.sysupgrade "docs:guide-user:installation:attended.sysupgrade").

Your device must already have an older OpenWrt firmware installed, to be eligible for this “sysupgrade” procedure.

- Alternatively refer to the [factory installation](/docs/guide-quick-start/factory_installation "docs:guide-quick-start:factory_installation") howto, to install OpenWrt on a device that still has vendor factory firmware on it.
- If your current OpenWrt installation does not have web interface installed or if you prefer to upgrade from the command line (upgrade from command line provides more fine-grained control), refer to [Upgrading OpenWrt firmware using CLI](/docs/guide-user/installation/sysupgrade.cli "docs:guide-user:installation:sysupgrade.cli").
- If you have any questions about this description, ask for help on the [Installing and Using OpenWrt forum section](https://forum.openwrt.org/c/installation "https://forum.openwrt.org/c/installation") before beginning.
- Be aware of major config [incompatibilities](/docs/guide-quick-start/admingui_sysupgrade_keepsettings#upgrade_compatibility "docs:guide-quick-start:admingui_sysupgrade_keepsettings") and version compatibility.

## Back up OpenWrt configuration

Follow [Backup and restore](/docs/guide-user/troubleshooting/backup_restore "docs:guide-user:troubleshooting:backup_restore"), or skip this section if you do not want to preserve existing configuration.

## Locate and download the OpenWrt firmware

1. On the [Table of Hardware: Firmware downloads](/toh/views/toh_fwdownload "toh:views:toh_fwdownload") page, locate your specific device.
2. Download the sysupgrade file. **Please note that not all devices do have a firmware image called sysupgrade.bin.**

Troubleshooting:

- **Some devices lack a sysupgrade image** and require a special (and usually a bit more complex) installation procedure that is device-specific. This tutorial won't apply for such devices. Instead **follow the custom installation description on the corresponding device page** in the OpenWrt wiki.
- If you don't find your device in the Table of Hardware or Device Pages/Techdata pages, you can also try [alternative ways to find OpenWrt firmware images.](/docs/guide-quick-start/alternate-directory-search "docs:guide-quick-start:alternate-directory-search")
- If you have accidentally browsed the generic OpenWrt download folders to locate your device, you might see some more download files matching your device.

## Verify firmware file and flash the firmware

1. Connect to the device via Ethernet cable (Only use wireless if the device has no Ethernet connection options)
2. Log into the web interface and in the **System → Backup/Flash Firmware** menu, go to the “Flash new firmware image” section.
3. **Uncheck**/clear the **“Keep settings”** checkbox especially for major version upgrades, so that new defaults will get applied. Keeping settings may be possible for minor upgrades, but there is always a risk of incompatible settings. (more info regarding the ["Keep settings" checkbox](/docs/guide-quick-start/admingui_sysupgrade_keepsettings "docs:guide-quick-start:admingui_sysupgrade_keepsettings") and its use cases).
4. Ensure that the OpenWrt firmware file you are about to flash matches your router model and is called **“....sysupgrade.bin”** (the file type varies like .bin .tar.gz etc., but the key is “sysupgrade”), as you will **upgrade** an existing OpenWrt system towards a newer OpenWrt firmware version.
5. In the **“Flash new firmware image”** section, click **“Choose file”** to select the image file, then click “Flash image...”. This displays a “Flash Firmware - Verify“ page, containing a SHA256 checksum of the image file just uploaded to the router.
6. [Check](/docs/guide-quick-start/verify_firmware_checksum "docs:guide-quick-start:verify_firmware_checksum") that the firmware-checksum displayed in web interface matches the SHA256 checksum from the OpenWrt download page. If it does not match, do NOT continue, as it is a corrupt file and will likely brick your device. Note: If you are upgrading from OpenWrt 15.05, the 32 character displayed is an MD5 checksum, not SHA256. Please verify this MD5 checksum on your operating system before proceeding.
7. If the checksum matches, click “Proceed”. This starts the “System - Flashing ...” along with a spinning wheel and “Waiting for changes to be applied...”
8. It can take several minutes, while the router uploads the firmware image and write it into its flash ROM and finally reboots.
9. The new firmware has been installed. Continue with the next section to check the result.

Troubleshooting:

- if the checksum process failed, do NOT start flashing, as the download could be corrupt. A corrupt firmware file can brick your device! Instead repeat this howto with another download attempt from the download section.
- if the checksum step fails repeatedly, you can consult the [Installing and Using OpenWrt Forum](https://forum.openwrt.org/c/installation "https://forum.openwrt.org/c/installation") for help. Be sure to include the exact brand, model, and version of your device.

## Post-upgrade steps

- After your device has finished flashing and rebooting, check if you can access the LuCI web interface (or the IP that you know of).
- See **Post-upgrade steps** in [Upgrading OpenWrt firmware using CLI](/docs/guide-user/installation/sysupgrade.cli "docs:guide-user:installation:sysupgrade.cli")

Troubleshooting:

- If you have flashed a development/snapshot firmware of OpenWrt, you first need to manually enable the web interface: [development installation guide](/docs/guide-quick-start/developmentinstallation "docs:guide-quick-start:developmentinstallation"). Or verify the result by SSH-connecting to your OpenWrt device.
- The router may have succeeded, but gotten a different IP address than you expected. Either scan your local network, check your regular router's status page (to find out about the IP address it has assigned to your OpenWrt device) or use [failsafe mode](/docs/guide-user/troubleshooting/failsafe_and_factory_reset "docs:guide-user:troubleshooting:failsafe_and_factory_reset"), to manually reset OpenWrt's settings (which includes the network settings)
- If you have checkmarked the “Keep settings” checkbox in the previous section and the system fails to boot after flashing, you need to consult the [failsafe mode](/docs/guide-user/troubleshooting/failsafe_and_factory_reset "docs:guide-user:troubleshooting:failsafe_and_factory_reset"), to manually reset all settings.
- Otherwise you need to start configuring from scratch. In this case, remember to properly **set your country code in the OpenWrt Wi-Fi configuration** again, to comply with your country's Wi-Fi legal regulation, e.g. see in [basic Wi-Fi setup](/docs/guide-quick-start/basic_wifi "docs:guide-quick-start:basic_wifi").
