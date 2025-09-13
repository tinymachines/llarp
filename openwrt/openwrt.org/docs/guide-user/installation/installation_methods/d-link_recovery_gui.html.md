# D-Link Recovery GUI

Most D-Link devices have an emergency recovery mode embedded on the bootloader. This recovery mode provides a basic web page that allows flashing a new firmware even when the device is bricked, which is very handy not only for recovering from bricks but also to install OpenWrt on supported D-Link devices. The emergency recovery mode is normally accessed by holding the reset button for a few seconds while powering up the device.

## Accessing the recovery mode

Before following the steps below, make sure you already have a local copy of the firmware file you want to flash, as you won't have any kind of internet connectivity while the device is in the emergency recovery mode. If the file you want to flash is from the stock firmware, make sure it is unencrypted (refer to the section below for more details). Also, the computer you'll use to access the recovery mode must be directly plugged to one of the LAN ports of the device.

1. Power down the device
2. Press and hold the reset button on the device and re-plug the power without releasing the reset button
3. Continue to hold the reset button until the red/orange power light starts blinking
4. On the computer, manually assign a static IP address on the 192.168.0.xxx subnet, other than 192.168.0.1 (e.g. 192.168.0.2)
5. Open a web browser and navigate to [http://192.168.0.1](http://192.168.0.1 "http://192.168.0.1")
6. Choose the firmware file you want to flash and click on “Upload”
7. After the file has been uploaded, you should see a “Device is upgrading the firmware” message on the web browser
8. Wait while the device verify the uploaded file and flash the firmware
9. The device will reboot automatically after the flashing process finishes

[![File upload form from step 5](/_media/media/dlink/recovery_gui_step1.png?w=200&tok=77c014 "File upload form from step 5")](/_detail/media/dlink/recovery_gui_step1.png?id=docs%3Aguide-user%3Ainstallation%3Ainstallation_methods%3Ad-link_recovery_gui "media:dlink:recovery_gui_step1.png") [!["Device is upgrading the firmware" message from step 7](/_media/media/dlink/recovery_gui_step2.png?w=200&tok=be1528 '"Device is upgrading the firmware" message from step 7')](/_detail/media/dlink/recovery_gui_step2.png?id=docs%3Aguide-user%3Ainstallation%3Ainstallation_methods%3Ad-link_recovery_gui "media:dlink:recovery_gui_step2.png") [!["Upgrade successfully" message from step 9](/_media/media/dlink/recovery_gui_step3.png?w=200&tok=1a6fd7 '"Upgrade successfully" message from step 9')](/_detail/media/dlink/recovery_gui_step3.png?id=docs%3Aguide-user%3Ainstallation%3Ainstallation_methods%3Ad-link_recovery_gui "media:dlink:recovery_gui_step3.png")

## Troubleshooting

### Recovery page doesn't load

- **Check the Ethernet cable:** the computer must be connected directly to one of the LAN ports from the device.
- **Check the network settings:** the computer must have a static IP address under the 192.168.0.xxx range (other than 192.168.0.1). Also make sure the subnet mask is set to 255.255.255.0 otherwise the recovery page will be inaccessible even when using a proper IP address.
- **Try another LAN port:** connect the computer to a different LAN port of the device.

### File upload never completes or fail with a timeout

- **Power the device down and start again:** sometimes the emergency recovery mode just hangs and a reboot solves the problem.
- **Try a different web browser:** depending of the combination of OS and web browser of the computer, the upload might always timeout. There isn't a clear pattern, and a combination of OS and browser that worked before might stop working and vice-versa. Using an older web browser (like IE) seems to help too. Also make sure to repeat the process from start whenever this happens, as the recovery mode goes completely unresponsible when an upload error or timeout occurs.
- **Upload the file with cURL:** if everything else fails, you can upload the firmware file through cURL. Repeat the steps 1 to 5 above, then use the following cURL command:

```
curl -v -i -F "firmware=@my_firmware_file.bin" 192.168.0.1
```

## About encrypted firmwares

Starting from 2018, D-Link added a layer of encryption to its stock firmware files. Most firmware updates published since then, both for new and for existing D-Link devices, are available only on this encrypted format, generally referenced as D-Link SHRS format. Although the stock firmware from D-Link can flash these SHRS files without issues, **the emergency recovery mode from the bootloader only recognizes unencrypted firmware files**, actively refusing SHRS firmware files if you try to flash them.

For some devices (like the [DIR-878](/toh/d-link/dir-878_a1 "toh:d-link:dir-878_a1") and [DIR-882](/toh/d-link/dir-882_a1 "toh:d-link:dir-882_a1")), older firmware versions, from before the encryption was added, are often obtainable in unencrypted format directly from [D-Link Support](https://www.dlink.com/en/support "https://www.dlink.com/en/support"), and these can be flashed in emergency recovery mode without issues if you ever need to recover from a brick or want to go back from OpenWrt to the stock firmware.

For newer devices, however, this isn't an option, as only encrypted SHRS firmwares are publicly available. If you own one of these devices and needs the firmware in unencrypted format to use with the emergency recovery mode, you'll have to resort to tools like [dlink-decrypt](https://github.com/0xricksanchez/dlink-decrypt "https://github.com/0xricksanchez/dlink-decrypt") in order to manually decrypt the SHRS firmwares provided by D-Link.

As of November 2020, [dlink-decrypt](https://github.com/0xricksanchez/dlink-decrypt "https://github.com/0xricksanchez/dlink-decrypt") seems to successfully decrypt the stock firmware files of all devices currently using the D-Link SHRS format.

## Devices with this installation method

Devices listed on this table have the emergency recovery mode on their bootloaders and are able to use this installation method not only to install OpenWrt but also to recover from bricks and even to go back to the stock firmware (as long as an unencrypted firmware file is provided).

## Notes

- [D-Link Forum: Emergency Flashing HOW-TO](http://forums.dlink.com/index.php?topic=44909.msg163599#msg163599 "http://forums.dlink.com/index.php?topic=44909.msg163599#msg163599")
- [D-Link Emergency Recovery Mode Usage Instructions for the DIR-600 (in German)](ftp://ftp.dlink.de/dir/dir-600/documentation/DIR-600_revb12_howto_de_FirmwareRecovery.pdf "ftp://ftp.dlink.de/dir/dir-600/documentation/DIR-600_revb12_howto_de_FirmwareRecovery.pdf")
- [0x00sec: Breaking the D-Link DIR3060 Firmware Encryption](https://0x00sec.org/t/breaking-the-d-link-dir3060-firmware-encryption-recon-part-1/21943 "https://0x00sec.org/t/breaking-the-d-link-dir3060-firmware-encryption-recon-part-1/21943")
- [dlink-decrypt on GitHub](https://github.com/0xricksanchez/dlink-decrypt "https://github.com/0xricksanchez/dlink-decrypt")
