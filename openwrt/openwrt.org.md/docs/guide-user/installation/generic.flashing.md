# Installing OpenWrt

The installation of OpenWrt is device specific. These device specific procedures should be found in the wiki. See [Table of Hardware](/toh/start "toh:start") for available procedures. If your device is not listed, information in this Howto may be helpful.

**Warning!**  
This section describes actions that might damage your device or firmware. Proceed with care!

![:!:](/lib/images/smileys/exclaim.svg) If your attempt to install OpenWrt fails, please view [generic.debrick](/docs/guide-user/troubleshooting/generic.debrick "docs:guide-user:troubleshooting:generic.debrick") for fixes.

![:!:](/lib/images/smileys/exclaim.svg) This HOWTO is VERY generic. You cannot use it in most situations, as you have to adapt values and other parts for specific hardware. Please look at the [supported hardware page](/toh/start "toh:start") for device-specific documentation.

In most circumstances; you have three options:

- **`Option 1:`** install OpenWrt onto the router's non-volatile memory
- **`Option 2:`** install OpenWrt onto the RAM
- **`Option 3:`** boot OpenWrt over the network ([netbooting](/inbox/howto/netboot "inbox:howto:netboot") is not supported by all [bootloaders](/docs/techref/bootloader "docs:techref:bootloader")).

## Four Installation Methods

There are four ways to install OpenWrt on a device:

### Method 1: via OEM firmware

Open the WebUI of the **OEM firmware** with your web browser and install the OpenWrt **factory** firmware image file using the *“Firmware Upgrade”* option. Your device should reboot with OpenWrt installed.

**`NOTE:`** Sometimes the OEM firmware will only allow you to flash your device with a specific firmware file. If that is the case, you will not be able to install OpenWrt using this method. However, for some devices the build bots prepare tagged builds such that they are compliant with the firmwares from the manufacturer. This should be documented on the device specific page for your model.

### Method 2: via Bootloader and an Ethernet port

Most, if not all [bootloaders](/docs/techref/bootloader "docs:techref:bootloader") provide built-in functionality for this purpose. Some use a [TFTP](https://en.wikipedia.org/wiki/Trivial%20File%20Transfer%20Protocol "https://en.wikipedia.org/wiki/Trivial File Transfer Protocol")-client, others a TFTP-server, others a [FTP](https://en.wikipedia.org/wiki/File%20Transfer%20Protocol "https://en.wikipedia.org/wiki/File Transfer Protocol")-client, some an FTP-server, some a web server and some use the [XMODEM](https://en.wikipedia.org/wiki/XMODEM "https://en.wikipedia.org/wiki/XMODEM")-protocol.

Before proceeding you need to determine the following:

- a) the preset IP address of the bootloader (not necessarily identical to the IP address the device has after it has booted the original firmware!)
- b) the protocol and whether the bootloader acts as client or as server
- c) the correct port number (if not [default](https://en.wikipedia.org/wiki/List%20of%20TCP%20and%20UDP%20port%20numbers "https://en.wikipedia.org/wiki/List of TCP and UDP port numbers"))
- d) the interface you need to connect to
- e) a user name and login password (if necessary)
- f) the time window you have after starting the device to obtain a connection

Once you know all of the above parameters, you may proceed.

1. Install the appropriate software on your PC (i.e. if the bootloader uses an FTP-server, you need a FTP-client).
2. Read the appropriate manual page ie: `tftp`, `tftpd`, `ftp`, `ncftp`, `ftpd`, `pure-ftpd`, etc ...
3. Configure a static IP address for your PC interface in the same IP address block as pre-configured in the bootloader.
4. Connect your PC to the device.
5. Power cycle the device.
6. Connect to the bootloader using the software you chose
7. Install the OpenWrt firmware file.
8. **Do not overwrite or alter the bootloader** until explicitly instructed to do so!

**`NOTES:`** Sometimes even the bootloader prevents you from flashing a non-OEM firmware. If you have a short time window, the connection between your computer and device needs to be established quickly. To make this as quick possible, you can disable auto-negotiation on your [NIC](https://en.wikipedia.org/wiki/Network%20interface%20controller "https://en.wikipedia.org/wiki/Network interface controller") and/or [disable media sensing](http://support.microsoft.com/kb/239924 "http://support.microsoft.com/kb/239924").

#### Specific Howtos

- [generic.flashing.tftp](/docs/guide-user/installation/generic.flashing.tftp "docs:guide-user:installation:generic.flashing.tftp")
- [generic.flashing.ftp](/docs/guide-user/installation/generic.flashing.ftp "docs:guide-user:installation:generic.flashing.ftp")
- [generic.flashing.xmodem](/docs/guide-user/installation/generic.flashing.xmodem "docs:guide-user:installation:generic.flashing.xmodem")

### Method 3: via Bootloader and Serial port

- data info of mentioned items (b) to (f) inside above Method-2.
- [generic.flashing.serial](/docs/guide-user/installation/generic.flashing.serial "docs:guide-user:installation:generic.flashing.serial")

### Method 4: via JTAG

- [port.jtag](/docs/techref/hardware/port.jtag "docs:techref:hardware:port.jtag")

### Install a ramdisk-image into main memory

This step shows you howto upload a new ramdisk image to the device. The existing firmware on the flash remains unchanged! You require a working serial cable to do the ramdisk upload.

1. specifically select the RAMDISK option to make OpenWrt Buildroot create a ramdisk-image for you to upload
2. connect an ethernet cable between your computer and one of the LAN ports (doesn't matter which, just so long as it's not the WAN port) of the WNDR3700.
3. connect your serial cable to the header on the WNDR3700 and set your local terminal program (eg. minicom) to
   
   - 115200 bps 8N1
   - no software flow control
   - no hardware flow control.
4. set your computer's ethernet port to use the IP address `192.168.0.10/24`
5. set up a TFTP server on your local computer to respond to requests on the 192.168.0.10 interface. Make sure that the ramdisk image (openwrt-ar71xx-uImage-lzma.bin) is in the directory used by the TFTP server.
6. Fix the header for the ramdisk image so that it's recognized by the u-Boot firmware. Use the wndr3700.c program that was posted by \*aorlinsk* on the forums here [http://aorlinsk2.free.fr/openwrt/wndr3700/](http://aorlinsk2.free.fr/openwrt/wndr3700/ "http://aorlinsk2.free.fr/openwrt/wndr3700/") and run it from the TFTP server's data directory. I've also reproduced the code here just in case:
   
   - ```
     ./wndr3700 openwrt-ar71xx-uImage-lzma.bin openwrt-fixed.out
     ```
7. power up the board. When it gets to the message asking you to press any key to interrupt the normal bootup sequence, press a key on the serial console (or just hold down the enter key from first bootup until you get to a prompt):
8. enter the following into the serial console:
   
   ```
   setenv ipaddr 192.168.0.1
   setenv serverip 192.168.0.10
   setenv bootargs 'board=WNDR3700'
   tftpboot 80800000 openwrt-fixed.out
   bootm
   ```
   
   (if you forget the bootargs piece below, the board will boot and look normal, but it won't be able to bring up any of the network interfaces!)
9. The system should boot!

Concrete examples: [wnr2000](/toh/netgear/wnr2000 "toh:netgear:wnr2000"), ...

Don't forget to consult the other [Generic Basic Howtos for OpenWrt](/docs/start "docs:start")

## Installation Checklist

*This checklist cannot and does not completely cover all the ways you can install OpenWrt.*

**Pre-Installation**

- Say hello in [#openwrt](https://webchat.oftc.net/?channels=#openwrt "https://webchat.oftc.net/?channels=#openwrt") channel at OFTC.
- Make sure that the router has currently stock/original firmware installed.
- Configure your computer to use static IP address.
- Connect to the router with wire, not WiFi.
- Do your own research and read all the resources about installing OpenWrt on your router:
- [FAQ before installation](/docs/guide-user/installation/before.installation "docs:guide-user:installation:before.installation")
- [Table of Hardware](/toh/start "toh:start")
- [OpenWrt forum](https://forum.openwrt.org/ "https://forum.openwrt.org/")
- Print or save those pages for offline reading:
  
  - [First login](http://wiki.openwrt.org/doc/howto/firstlogin "http://wiki.openwrt.org/doc/howto/firstlogin")
  - [Failsafe](/docs/guide-user/troubleshooting/failsafe_and_factory_reset "docs:guide-user:troubleshooting:failsafe_and_factory_reset")
- (optional) [Backup flash of your router.](/docs/guide-user/installation/generic.backup "docs:guide-user:installation:generic.backup")

**Installation**

- Reboot router.
- Download OpenWrt image in proper location.
  
  - In case of [upgrading](/docs/guide-user/installation/generic.sysupgrade "docs:guide-user:installation:generic.sysupgrade") existing OpenWrt system, the proper location is RAM (usually /tmp).
- Verify MD5 checksum of the OpenWrt image you downloaded.
- Make sure that there is at least as much free RAM as the size of OpenWrt image you have downloaded.

**Post-Installation**

- Do [First login](http://wiki.openwrt.org/doc/howto/firstlogin "http://wiki.openwrt.org/doc/howto/firstlogin") and set root password.
- [Backup flash of your router.](/docs/guide-user/installation/generic.backup "docs:guide-user:installation:generic.backup")
- Make yourself comfortable with the [Failsafe](/docs/guide-user/troubleshooting/failsafe_and_factory_reset "docs:guide-user:troubleshooting:failsafe_and_factory_reset") mode.
- [Configure your device](/docs/guide-user/base-system/basic "docs:guide-user:base-system:basic")
