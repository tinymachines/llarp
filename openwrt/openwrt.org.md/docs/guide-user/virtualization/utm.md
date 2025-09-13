# OpenWrt on UTM on Apple Silicon HowTo

This document describes how to run the `armsr/armv8` OpenWrt images in a VM hosted on macOS (Apple Silicon hardware) using [UTM](https://docs.getutm.app/ "https://docs.getutm.app/").

## Prerequisites

- [UTM](https://docs.getutm.app/installation/macos/ "https://docs.getutm.app/installation/macos/") installed
- Familiarity with the command line on macOS (Terminal window)

This article relies on the following:

- Accessing [web interface](/docs/guide-quick-start/walkthrough_login "docs:guide-quick-start:walkthrough_login") / [command-line interface](/docs/guide-quick-start/sshadministration "docs:guide-quick-start:sshadministration")
- Managing [configs](/docs/guide-user/base-system/uci "docs:guide-user:base-system:uci") / [packages](/docs/guide-user/additional-software/managing_packages "docs:guide-user:additional-software:managing_packages") / [services](/docs/guide-user/base-system/managing_services "docs:guide-user:base-system:managing_services") / [logs](/docs/guide-user/base-system/log.essentials "docs:guide-user:base-system:log.essentials")

This article may contain network configuration that depends on migration to DSA in OpenWrt 21.02

- Check if your device uses DSA or swconfig as not all devices have been migrated
- ifname@interface has been moved to device sections
- [DSA Networking](/docs/guide-user/network/dsa/start "docs:guide-user:network:dsa:start")
- [Mini tutorial for DSA network config](https://forum.openwrt.org/t/mini-tutorial-for-dsa-network-config/96998 "https://forum.openwrt.org/t/mini-tutorial-for-dsa-network-config/96998") on the forum
- [DSA in the 21.02 release notes](https://openwrt.org/releases/21.02/notes-21.02.0#new_network_configuration_syntax_and_boardjson_change "https://openwrt.org/releases/21.02/notes-21.02.0#new_network_configuration_syntax_and_boardjson_change")

### Select an OpenWrt image

You need an ARM system-ready 64-bit version of OpenWrt. There are two versions:

- `combined-squashfs.img.gz`: This edition, as of release 23.05.0, does not work correctly with sysupgrade.
- `combined-ext4.img.gz` This disk image uses a single read-write ext4 partition with no read-only squashfs root filesystem. Features like Failsafe Mode or Factory Reset won't be available as they need a read-only squashfs partition to function.

In the guide we'll use *openwrt-armsr-armv8-generic-ext4-combined.img.gz* because it supports sysupgrade.

- Download a stable release of the *generic-ext4-combined.img.gz* image from [targets/armsr/arvm8/ folder](https://downloads.openwrt.org/releases/ "https://downloads.openwrt.org/releases/"), e.g. [23.05.2](https://downloads.openwrt.org/releases/23.05.2/targets/armsr/armv8/openwrt-23.05.2-armsr-armv8-generic-ext4-combined.img.gz "https://downloads.openwrt.org/releases/23.05.2/targets/armsr/armv8/openwrt-23.05.2-armsr-armv8-generic-ext4-combined.img.gz").
- Or you can try a more recent but experimental [snapshot](https://downloads.openwrt.org/snapshots/targets/armsr/armv8/openwrt-armsr-armv8-generic-ext4-combined.img.gz "https://downloads.openwrt.org/snapshots/targets/armsr/armv8/openwrt-armsr-armv8-generic-ext4-combined.img.gz") image.
- Uncompress the gzip'ed img file. On macOS in a Terminal window use the command `gzcat openwrt-*ext4-combined.img.gz > openwrt.img`. As a result you get the raw `openwrt.img` image file.

![:!:](/lib/images/smileys/exclaim.svg) Tip: keep a copy of the original gzip'ed image file, it can be used as an image for sysupgrade.

## VM Setup in UTM

### VM creation

![:!:](/lib/images/smileys/exclaim.svg) Tutorial and screenshots from UTM 4.4.4 on Apple Silicon

[![](/_media/media/virtualization/utm/1-utmstart.png?w=70&tok=be7540)](/_media/media/virtualization/utm/1-utmstart.png "media:virtualization:utm:1-utmstart.png") Start UTM and click *Create a new Virtual Machine*

* * *

[![](/_media/media/virtualization/utm/2-virtualize.png?w=70&tok=87834d)](/_media/media/virtualization/utm/2-virtualize.png "media:virtualization:utm:2-virtualize.png") Select *Virtualize*

* * *

[![](/_media/media/virtualization/utm/3-other.png?w=70&tok=9afe5a)](/_media/media/virtualization/utm/3-other.png "media:virtualization:utm:3-other.png") Select *Other* (because the *Linux* install path assumes an install ISO image, which we are not using for OpenWrt)

* * *

[![](/_media/media/virtualization/utm/4-no-iso-boot.png?w=70&tok=f80f70)](/_media/media/virtualization/utm/4-no-iso-boot.png "media:virtualization:utm:4-no-iso-boot.png") Check the *Skip ISO boot* box

* * *

[![](/_media/media/virtualization/utm/5-cpu-memory.png?w=70&tok=7413cc)](/_media/media/virtualization/utm/5-cpu-memory.png "media:virtualization:utm:5-cpu-memory.png") Configure 512MB and 2 CPUs (enough memory for running sysupgrade later)

* * *

[![](/_media/media/virtualization/utm/6-storage.png?w=70&tok=9301c5)](/_media/media/virtualization/utm/6-storage.png "media:virtualization:utm:6-storage.png") Accept the default storage setting (we will remove this drive later and replace it with the OpenWrt image)

* * *

[![](/_media/media/virtualization/utm/7-shared.png?w=70&tok=c5fb1d)](/_media/media/virtualization/utm/7-shared.png "media:virtualization:utm:7-shared.png") Leave the shared directory configuration blank

* * *

[![](/_media/media/virtualization/utm/8-summary.png?w=70&tok=7659b2)](/_media/media/virtualization/utm/8-summary.png "media:virtualization:utm:8-summary.png") Check the *Open VM Settings* box. Fill in a name for the VM. Click *Save*. This brings you to the VM settings page.

* * *

### VM configuration

The configuration you will set up by following this tutorial is:

- **br-lan** of the VM on **lan** interface, fixed address 10.0.2.2, set in UTM as **Host Only Network**. This interface will *always* be available to the host even if host or VM are disconnected from any network.
- **eth1** of the VM on **wan** interface, dynamic address, set in UTM as **Shared Network** (NAT). This interface will be used to access the Internet through whatever setup the host also uses.

Note that the *order* of the “Host Only” and “Shared Network” networks is important for turn-key operation of OpenWrt in the VM. While it can be configured using the console, configuration in this way simplifies getting to a running configuration.

#### VM settings

##### Remove unused devices

[![](/_media/media/virtualization/utm/10-remove.png?w=70&tok=41321c)](/_media/media/virtualization/utm/10-remove.png "media:virtualization:utm:10-remove.png") Control-click on *Display* and remove it. Control-click on *Sound* and remove it. Control-click on the *VirtIO Drive* and remove it. Confirm deleting the drive with *Delete*. (This is the blank disk that UTM creates during VM creation. We don't need it.)

* * *

##### Network Settings

[![](/_media/media/virtualization/utm/11-host-only.png?w=70&tok=c16a12)](/_media/media/virtualization/utm/11-host-only.png "media:virtualization:utm:11-host-only.png") Select *Network*. Change the Network Mode to *Host Only*. Check the *Show Advanced Settings* box. In the *Guest Network* box, type in the network range for the VM's LAN: *10.0.2.0/24*.

* * *

[![](/_media/media/virtualization/utm/12-wan.png?w=70&tok=492023)](/_media/media/virtualization/utm/12-wan.png "media:virtualization:utm:12-wan.png") Under Devices, click the *+New* entry and add a new *Network*. Click on the network and confirm it is configured as *Shared Network*.

* * *

##### Other Device Settings

[![](/_media/media/virtualization/utm/13-serial.png?w=70&tok=39b0ae)](/_media/media/virtualization/utm/13-serial.png "media:virtualization:utm:13-serial.png") Under Devices, click the *+New* entry and add a new *Serial* device. Click on the Serial device and check the mode. The default is a built-in terminal window that supports copy and paste with native macOS keyboard shortcuts.

* * *

[![](/_media/media/virtualization/utm/14-disk.png?w=70&tok=18a783)](/_media/media/virtualization/utm/14-disk.png "media:virtualization:utm:14-disk.png") Under the *Drives* section, select *New...*. Accept the interface default (VirtIO) and click on *Import...*. Navigate to the `openwrt.img` file you unpacked in previous steps.

* * *

*Save* the configuration.

#### Virtual Machine OpenWrt Settings

* * *

- Start your Virtual Machine (click the Play icon button)
- Wait 4 seconds for GRUB to boot automatically
- Press Enter to activate the console when the boot messages have finished scrolling by.
- Display the current LAN network configuration. Note that the default LAN address of 192.168.1.1 is present on first boot.
  
  ```
  root@openwrt:~# uci show network.lan
  network.lan=interface
  network.lan.device='br-lan'
  network.lan.proto='static'
  network.lan.ipaddr='192.168.1.1'
  network.lan.netmask='255.255.255.0'
  network.lan.ip6assign='60'
  ```
- Edit the network configuration to allow SSH access by pasting these commands into the console:
  
  ```
  uci set network.lan.ipaddr='10.0.2.2'
  uci commit
  service network restart
  ```
- Now your VM is accessible from SSH, user **root** (no password) address **10.0.2.2**
- If you installed a release image such as 23.05.0, the LuCi web interface is available at [http://10.0.2.2/](http://10.0.2.2/ "http://10.0.2.2/") (no password)
- If you installed a snapshot that doesn't include LuCi, install it with
  
  ```
  opkg update && opkg install luci
  ```
- You should have both internet access (try a **opkg update**) AND a LAN interface with a static address you can connect your SSH client program to even if your PC is disconnected from a local network.
- If you have more complex requirements you will have to set that up on your own by reading the documentation, or through LuCi.

## See also

- [Other virtualization options](/docs/guide-user/virtualization/start "docs:guide-user:virtualization:start"): Docker, VMware etc.
- [VMware Fusion](/docs/guide-user/virtualization/fusion "docs:guide-user:virtualization:fusion"): Configuring on a VM hosted on VMware Fusion
