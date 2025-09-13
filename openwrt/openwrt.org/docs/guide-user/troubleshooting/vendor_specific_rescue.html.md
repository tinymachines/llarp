# Rescue from failed firmware upgrade

If you can't reach the OpenWrt interface after installing packages, changing the password or the network configuration, try using [failsafe mode and factory reset](/docs/guide-user/troubleshooting/failsafe_and_factory_reset "docs:guide-user:troubleshooting:failsafe_and_factory_reset") first.

Some device vendors provide built-in rescue functions in their device's flash ROM boot partition that remain there, even after a OpenWrt firmware upgrade, so a OpenWrt upgrade will not overwrite this rescue function.

These rescue functions can be used to recover a failed flash update (no matter if the failed flash was vendor firmware or OpenWrt) or recover from an otherwise dead device, as long as the device hardware and the rescue function is still intact. These rescue partitions do consume a tiny piece of the flash, but renders a device mostly unbrickable.

Unfortunately such rescue functions are not available from all vendors, sometimes not for all models from a vendor and the actual rescue process is mostly vendor specific. This page is meant to collect the known rescue methods of different router vendors or router models.

## Check first: Device-specific firmware recovery procedures

Check the “device page” of your device (look for a link in the last columns of the Table of Hardware). The device page may describe a rescue method for your specific device.

- [Table of Hardware](/toh/start "toh:start")

Some of the methods may require creating a custom RS232-serial-cable or soldering-skills, while most newer devices require just a certain software trick to remote flash the device from a PC client.

## Manufacturer-generic firmware recovery procedures

Many devices of the following manufacturers support a recovery procedures as listed here:

Manufacturer Procedure Links ASUS TFTP-like rescue procedure with a manufacturer utility to be installed on a client PC. [Official ASUS recovery documentation](https://www.asus.com/support/faq/1000814/ "https://www.asus.com/support/faq/1000814/") D-Link Several devices have a dedicated [rescue firmware partition](#rescue_firmware_partition "docs:guide-user:troubleshooting:vendor_specific_rescue ↵") in their flash ROM. Linksys Several older devices support a remote TFTP recovery procedure.  
Several newer devices have [2 independent firmware partitions](#dual_firmware_partition "docs:guide-user:troubleshooting:vendor_specific_rescue ↵"). - [Official Linksys TFTP recovery documentation](https://www.linksys.com/us/support-article?articleNum=137928 "https://www.linksys.com/us/support-article?articleNum=137928")  
\- For Linksys dual firmware, [see below](#dual_firmware_partition "docs:guide-user:troubleshooting:vendor_specific_rescue ↵") Mikrotik TFTP-like rescure procedure with a manufacturer utility called 'netinstall' installed on a client PC. [Official Microtik recovery documentation](https://wiki.mikrotik.com/wiki/Manual:Netinstall "https://wiki.mikrotik.com/wiki/Manual:Netinstall") Netgear TFTP on a PC client can be used to rescue the firmware. [Official Netgear TFTP recovery documentation](https://kb.netgear.com/000059633/How-to-upload-firmware-to-a-NETGEAR-router-using-TFTP-client "https://kb.netgear.com/000059633/How-to-upload-firmware-to-a-NETGEAR-router-using-TFTP-client") nmrpflash [https://github.com/jclehner/nmrpflash](https://github.com/jclehner/nmrpflash "https://github.com/jclehner/nmrpflash") TP-Link TFTP on a PC client can be used to rescue the firmware.  
Several newer devices provide a [rescue partition](#rescue_firmware_partition "docs:guide-user:troubleshooting:vendor_specific_rescue ↵"). [TP-Link forum TFTP recovery documentation](https://community.tp-link.com/en/home/forum/topic/81462?page=1 "https://community.tp-link.com/en/home/forum/topic/81462?page=1") Webpage firmware recovery  
See link for models which support this method. [https://www.tp-link.com/us/faq-1482.html](https://www.tp-link.com/us/faq-1482.html "https://www.tp-link.com/us/faq-1482.html") Ubiquiti (UBNT) [TFTP on a PC client](/docs/guide-user/installation/recovery_methods/ubiquiti_tftp "docs:guide-user:installation:recovery_methods:ubiquiti_tftp") can be used to rescue the firmware. [Official UBNT site: site search for 'firmware recovery'](https://help.ubnt.com/hc/en-us/search?utf8=%E2%9C%93&query=firmware%20recovery&commit=Search "https://help.ubnt.com/hc/en-us/search?utf8=%E2%9C%93&query=firmware+recovery&commit=Search") Xiaomi Several devices with USB port support a [rescue USB stick](#rescue_usb_stick "docs:guide-user:troubleshooting:vendor_specific_rescue ↵") method. ZBT (ZBTLink) Several devices support a [rescue partition](#rescue_firmware_partition "docs:guide-user:troubleshooting:vendor_specific_rescue ↵").  
On some devices, TFTP on a PC client can be used to rescue the firmware.

## Recovery for disk-image-based devices (e.g. SD-cards)

Examples: the different Raspberry PI's, devices of PC Engines).

OpenWrt devices that use a drive-installed image.gz or sdcard.img.gz are not an issue to recover. The OpenWrt OS is not applied to flash ROM, but installed on a removable drive, e.g. an SD-card. For recovery, mount the removable drive in a working PC and reapply the OpenWrt image to the removable drive according to the device-specific instructions.

## TFTP recovery mode

In several of these recovery procedures you will need a working TFTP server on your PC, see how to install and configure it in [Set up a TFTP Server](/docs/guide-user/troubleshooting/tftpserver "docs:guide-user:troubleshooting:tftpserver") article.

## Rescue USB stick

Supported by some Xiaomi devices process for [Xiaomi Mi](http://en.miui.com/thread-157895-1-1.html "http://en.miui.com/thread-157895-1-1.html"):

1. Download firmware and store as `miwifi.bin` on an USB flash drive (must be FAT or FAT32)
2. Plug USB flash drive into device USB port
3. Unplug device cord
4. Press and hold the reset button and then re-plug the power cord
5. Release reset button, when the orange status LED starts blinking
6. Flashing is finished, when LED turns blue

## Rescue firmware partition

Supported by several devices at least of the following vendors: D-Link, TP-Link, ZBTLink

This function is based on extra code in the boot partition in the flash ROM and it is still available on the device, even after the device has been flashed to OpenWrt. No further tools are needed, to trigger this rescue function.

Procedure, to boot into rescue partition:

1. Switch device power off (or pull the power cord).
2. Connect a client to the device via Ethernet to LAN1
3. Trigger the rescue function by pressing and holding the reset button of the device and then turning the device on (or plug in the power cord).
4. You can release the reset button after a few seconds.
5. The device will take ~15-20 seconds to boot a mini-web server, that provides only a single function: it can upload a firmware file and has a button to trigger the flash process. The web-server will usually be available under either (if in doubt, try both)
   
   1. [http://192.168.0.1](http://192.168.0.1 "http://192.168.0.1") (TP-Link and newer D-Link devices) or [http://192.168.0.254](http://192.168.0.254 "http://192.168.0.254") (newer TP-Link devices)
   2. [http://192.168.1.1](http://192.168.1.1 "http://192.168.1.1") (ZBT-Link and older D-Link devices)
6. Note: You need to set your PC client to a fixed IP address beforehand, as DHCP is not supported in this rescue mode. So depending on your device, so you need to set the PC client's to a matching IP address, either:
   
   1. an IP of the 192.168.0.x range, e.g. 192.168.0.2 / 255.255.255.0
   2. an IP of the 192.168.1.x range, e.g. 192.168.1.2 / 255.255.255.0

Notes:

- The rescue function provides no Internet access, WiFi or DHCP.
- OpenWrt firmware can be flashed directly using this rescue function when using a OpenWrt ...**factory.bin** firmware file. There is no need to first flash official D-Link firmware.
- Official D-Link documentation of this procedure is rare, a [german D-Link documentation for the DIR-600](ftp://ftp.dlink.de/dir/dir-600/documentation/DIR-600_revb12_howto_de_FirmwareRecovery.pdf "ftp://ftp.dlink.de/dir/dir-600/documentation/DIR-600_revb12_howto_de_FirmwareRecovery.pdf") exists (with the same procedure also applying for other D-Link devices, if the device supports recovery). Inofficial documentation: [OpenWrt Wiki for DIR-505](/toh/d-link/dir-505#web_interface "toh:d-link:dir-505") and [D-Link Forum](http://forums.dlink.com/index.php?topic=44909.msg162511#msg162511 "http://forums.dlink.com/index.php?topic=44909.msg162511#msg162511").
- Inofficial notes of [ZBTLink recovery](https://fccid.io/2AH9TW826/Users-Manual/User-Manual-2994820 "https://fccid.io/2AH9TW826/Users-Manual/User-Manual-2994820"),
- Official [TP-Link rescue partition notes](http://www.tp-link.de/faq-1482.html "http://www.tp-link.de/faq-1482.html")

## Dual firmware partition

Supported by newer Linksys devices

Most newer devices (mostly those with decent amount of flash ROM) have 2 independent firmware partitions. A usage strategy could be, to install OpenWrt only into one of the 2 partitions and leave the vendor firmware in the other partition. No further tools are required to toggle between the two partitions.

Procedure, to manually toggle between the two firmware partitions:

1. Switch device power off.
2. 3x Switch device power on for 2 seconds, then off again.
3. Switch device power on, the device should now boot to the alternative partition.

When successfully booted into any of the two partitions, a triggered firmware update will flash the other, secondary partition. The partition that is currently booted, stays untouched.
