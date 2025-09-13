# Factory Install: First Time Installation

Your device still needs to have the vendor's firmware installed to be eligible for this so-called “factory install” procedure.

\- Go to the [Supported Devices](/supported_devices "supported_devices") page and click on the question that best fits your search. - Familiarize yourself with the **Devices Page** (listed in the linked devices table above). There you will find specific installation information, caveats, tips, tricks, and other important information that you need to know BEFORE you go out and buy a device. It also serves as a way to gauge the “popularity” of the device, as more popular devices usually have more comprehensive pages. - If you are looking to buy a new router for OpenWrt, look for devices with a compatible integrated circuit (SoC), 16 MB of Flash, and 128 MB of RAM at minimum.

## Download the appropriate OpenWrt firmware

1. On the [Table of Hardware: Firmware downloads](/toh/views/toh_fwdownload "toh:views:toh_fwdownload") page, locate your specific device. If you are a newcomer, use the stable release version for your first-time device installation. Do not initially use the (clearly marked) snapshot versions from other subfolders. This ensures that you get the easiest possible first-time OpenWrt installation experience.
2. When you have located your device in this list, click on the “View/edit data” link of the device record. We recommend to bookmark that page, as it has lots of helpful information about your router.
3. On this device-specific **Techdata** page, at the bottom locate the line called **“Firmware OpenWrt Install URL“** that links to a downloadable file called **”...factory.bin”** or **“...factory.img”** file.  
   Please mind that only 30% of all supported devices have “factory” in their installation image name. The other 70% have different names.
4. You may also use the [Firmware Selector](https://firmware-selector.openwrt.org/ "https://firmware-selector.openwrt.org/") to download this file.

### Troubleshooting

- If your device already has an older OpenWrt firmware on it, refer to the [sysupgrade](/docs/guide-quick-start/sysupgrade.luci "docs:guide-quick-start:sysupgrade.luci") howto instead.
- If you have any questions ask for help on the [Installing and Using OpenWrt forum](https://forum.openwrt.org/c/installation "https://forum.openwrt.org/c/installation").
- If you are an advanced user (you probably wouldn't be reading this page) consider installing an [OpenWrt Development Snapshot](/docs/guide-quick-start/developmentinstallation "docs:guide-quick-start:developmentinstallation").
- If you can not find “factory.bin” firmware file (true for 70% of all supported devices), a device-specific custom installation procedure is required (assuming your device does not already have an older OpenWrt version installed). You can find custom installation instructions at the following locations:
  
  1. On the OpenWrt Techdata page of the device, check the fields “Forum Topic URL” and “Comment” for any external links or comments regarding custom installation procedures.
  2. Look for the corresponding device page in the OpenWrt wiki, if that has any custom installation descriptions.
  3. Search the OpenWrt forum for existing discussion threads about the device name or open a new topic in the OpenWrt forum, asking for instructions.
- If you can't find your device in the Table of Hardware, you can consult the ["Installing and Using OpenWrt" Forum](https://forum.openwrt.org/c/installation "https://forum.openwrt.org/c/installation") for help. You can also try [alternative ways to locate OpenWrt firmware images.](/docs/guide-quick-start/alternate-directory-search "docs:guide-quick-start:alternate-directory-search")

## Verify the downloaded firmware file

You will now use a checksum tool, to calculate a checksum from your downloaded file and then compare this calculated checksum with the file-specific checksum listed on the firmware download site. This ensures that you will not brick your device due to a faulty download.

1. Check your downloaded “...factory.bin” file according to [checksum verification of downloaded OpenWrt firmware files](/docs/guide-quick-start/verify_firmware_checksum "docs:guide-quick-start:verify_firmware_checksum").
2. Only continue with flashing, if the firmware checksum of your download matches the checksum stated on the download site!

Troubleshooting:

- If the checksum process has reported a checksum mismatch, do NOT start flashing, as the download could be corrupt. A corrupt firmware file can brick your device! Instead retry with another download attempt and retry the checksum step.
- If the checksum step fails repeatedly, you can consult the ["Installing and Using OpenWrt" Forum](https://forum.openwrt.org/c/installation "https://forum.openwrt.org/c/installation") for help. Be sure to include the exact brand, model, and version of your device.

## Flash the firmware

1. Connect to the device via Ethernet cable (Only fallback to wireless, if the device has no Ethernet connection options).
2. Ensure that the OpenWrt firmware file that you are about to flash, matches your router model. It is usually (but not always) called **“....factory.bin”** as you will use it to modify a vendor's **factory** firmware towards OpenWrt.
3. Log into the device's admin web interface and locate the firmware installation page. Follow the OpenWrt specific instructions of your device user guide for installing the firmware.
4. Wait while the device writes the firmware image to its flash memory. This can take several minutes (the Device Page may state an expected time for this process). At the end, the device will reboot automatically.
5. The new firmware has been installed.

[**Next step: Log into your Router Running OpenWrt -&gt;**](/docs/guide-quick-start/walkthrough_login "docs:guide-quick-start:walkthrough_login")
