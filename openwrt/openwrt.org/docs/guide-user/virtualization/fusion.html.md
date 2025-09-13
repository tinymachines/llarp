# OpenWrt on VMware Fusion on Apple Silicon HowTo

This document describes how to run the `armsr/armv8` OpenWrt images in a VM hosted on macOS (Apple Silicon hardware) using [VMware Fusion](https://www.vmware.com/products/fusion.html "https://www.vmware.com/products/fusion.html").

## Prerequisites

- [VMware Fusion](https://www.vmware.com/products/fusion.html "https://www.vmware.com/products/fusion.html") installed
- qemu installed (via [Homebrew](http://brew.sh "http://brew.sh"))
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

- Download a stable release of the *generic-ext4-combined.img.gz* image from [targets/armsr/arvm8/ folder](https://downloads.openwrt.org/releases/ "https://downloads.openwrt.org/releases/"), e.g. [23.05.0](https://downloads.openwrt.org/releases/23.05.0/targets/armsr/armv8/openwrt-23.05.0-armsr-armv8-generic-ext4-combined.img.gz "https://downloads.openwrt.org/releases/23.05.0/targets/armsr/armv8/openwrt-23.05.0-armsr-armv8-generic-ext4-combined.img.gz").
- Or you can try the fresher but unstable [snapshot](https://downloads.openwrt.org/snapshots/targets/armsr/armv8/openwrt-armsr-armv8-generic-ext4-combined.img.gz "https://downloads.openwrt.org/snapshots/targets/armsr/armv8/openwrt-armsr-armv8-generic-ext4-combined.img.gz") image.
- Uncompress the gzip'ed img file. On macOS in a Terminal window use the command `gzcat openwrt-*ext4-combined.img.gz > openwrt.img`. As a result you get the raw `openwrt.img` image file.
- Convert the raw image to a VMDK-formatted disk image: `qemu-img convert -O vmdk openwrt.img openwrt.vmdk`
- Check your VMware Fusion networking configuration. You need to know the subnet used by the host-only networking:
  
  ```
  user@host demo % grep VNET_1_HOSTONLY_SUBNET '/Library/Preferences/VMware Fusion/networking'
  answer VNET_1_HOSTONLY_SUBNET 172.16.132.0
  ```

![:!:](/lib/images/smileys/exclaim.svg) Tip: keep a copy of the original gzip'ed image file, it can be used as an image for sysupgrade.

## VM Setup in VMware Fusion

### VM creation

![:!:](/lib/images/smileys/exclaim.svg) Tutorial and screenshots from VMware Fusion 13.5.0 on Apple Silicon

[![](/_media/media/virtualization/fusion/1-custom.png?w=70&tok=70b82c)](/_media/media/virtualization/fusion/1-custom.png "media:virtualization:fusion:1-custom.png") Start VMware fusion and use the *File→New* menu. Select *Create a custom virtual machine*

* * *

[![](/_media/media/virtualization/fusion/2-linux-5.png?w=70&tok=039123)](/_media/media/virtualization/fusion/2-linux-5.png "media:virtualization:fusion:2-linux-5.png") Select the appropriate Linux kernel version (OpenWrt 23.05.0 for armsr/armv8 uses Linux kernel 5.x).

* * *

[![](/_media/media/virtualization/fusion/3-existing.png?w=70&tok=2475e8)](/_media/media/virtualization/fusion/3-existing.png "media:virtualization:fusion:3-existing.png") Select *Use an existing virtual disk* and *Choose virtual disk...*

* * *

[![](/_media/media/virtualization/fusion/4-select-vmdk.png?w=70&tok=bc1ca7)](/_media/media/virtualization/fusion/4-select-vmdk.png "media:virtualization:fusion:4-select-vmdk.png") Select the `openwrt.vmdk` you created earlier, and *Make a separate copy of the virtual disk*.

* * *

[![](/_media/media/virtualization/fusion/5-finish.png?w=70&tok=457b79)](/_media/media/virtualization/fusion/5-finish.png "media:virtualization:fusion:5-finish.png") On the *Finish* page, click Customize Settings.

* * *

[![](/_media/media/virtualization/fusion/6-saveit.png?w=70&tok=01c521)](/_media/media/virtualization/fusion/6-saveit.png "media:virtualization:fusion:6-saveit.png") Select a location to save the VM. After saving, edit the configuration.

* * *

### VM configuration

The configuration you will set up by following this tutorial is:

- **br-lan** of the VM on **lan** interface, fixed address 172.16.132.2 (or whatever subnet VMware Fusion is using for VNET\_1), set in VMware Fusion as **Private to my Mac**. This interface will *always* be available to the host even if host or VM are disconnected from any network.
- **eth1** of the VM on **wan** interface, dynamic address, set in VMware Fusion as **Share with my Mac** (NAT). This interface will be used to access the Internet through whatever setup the host also uses.

Note that the *order* of the “Private to my Mac” and “Share with my Mac” networks is important for turn-key operation of OpenWrt in the VM.

#### VM settings

[![](/_media/media/virtualization/fusion/7-settings.png?w=70&tok=b42c7d)](/_media/media/virtualization/fusion/7-settings.png "media:virtualization:fusion:7-settings.png") Reconfigure some of the devices shown on the configuration page.

* * *

##### Remove unused devices

[![](/_media/media/virtualization/fusion/8-remove-sound.png?w=70&tok=942e4e)](/_media/media/virtualization/fusion/8-remove-sound.png "media:virtualization:fusion:8-remove-sound.png") Click on the sound card. Remove the sound card.

* * *

[![](/_media/media/virtualization/fusion/9-remove-camera.png?w=70&tok=20f85f)](/_media/media/virtualization/fusion/9-remove-camera.png "media:virtualization:fusion:9-remove-camera.png") Click on the camera. Remove the camera.

* * *

[![](/_media/media/virtualization/fusion/10-remove-dvd.png?w=70&tok=89ba7f)](/_media/media/virtualization/fusion/10-remove-dvd.png "media:virtualization:fusion:10-remove-dvd.png") Click on the CD/DVD. Open the advanced options section. Remove the CD/DVD drive.

* * *

##### Network Settings

[![](/_media/media/virtualization/fusion/11-network-private.png?w=70&tok=e85b5f)](/_media/media/virtualization/fusion/11-network-private.png "media:virtualization:fusion:11-network-private.png") Click on the existing Network. Change it to *Private to my Mac*.

* * *

[![](/_media/media/virtualization/fusion/12-add-network.png?w=70&tok=934bab)](/_media/media/virtualization/fusion/12-add-network.png "media:virtualization:fusion:12-add-network.png") Click on the *Add Device...* button on the main settings panel. Click on *Network Adapter*. (This will add the network for the WAN.)

* * *

[![](/_media/media/virtualization/fusion/13-shared-network.png?w=70&tok=325db5)](/_media/media/virtualization/fusion/13-shared-network.png "media:virtualization:fusion:13-shared-network.png") Configure it to *Share with my Mac*.

* * *

##### Other Device Settings

Optional: check the *USB &amp; Bluetooth* settings and choose your desired options.

* * *

[![](/_media/media/virtualization/fusion/14-memory.png?w=70&tok=fa5879)](/_media/media/virtualization/fusion/14-memory.png "media:virtualization:fusion:14-memory.png") Click on the *Processors and Memory* icon. Configure the system for 512MB and 2 processor cores.

* * *

Close the settings panel.

* * *

Optional: make a snapshot to capture the original unconfigured state, using the application menu Virtual Machine→Snapshots→Take Snapshot

#### Virtual Machine OpenWrt Settings

- Start your Virtual Machine (click the Play icon button)
- Wait 4 seconds for GRUB to boot automatically
- Press Enter to activate the console when the boot messages have finished scrolling by.

![:!:](/lib/images/smileys/exclaim.svg) [![](/_media/media/virtualization/fusion/15-allow-network.png?w=70&tok=4f2bf7)](/_media/media/virtualization/fusion/15-allow-network.png "media:virtualization:fusion:15-allow-network.png") OpenWrt by default configures the LAN into a bridge. This sets the virtual network adapter into promiscuous mode, which requires approval from VMware for the host-only network it uses. Promiscuous access is not required, so you can either approve or cancel the request.

- Display the current LAN network configuration. Note that the default LAN address of 192.168.1.1 is present on first boot. Type the `uci show network.lan` command into the virtual console window to see:
  
  ```
  root@openwrt:~# uci show network.lan
  network.lan=interface
  network.lan.device='br-lan'
  network.lan.proto='static'
  network.lan.ipaddr='192.168.1.1'
  network.lan.netmask='255.255.255.0'
  network.lan.ip6assign='60'
  ```
- Edit the network configuration to allow SSH access. Use the VNET\_1\_HOSTONLY\_SUBNET value from above, replacing the last octet with `2`, and restart the network. An example to type into the console:
  
  ```
  uci set network.lan.ipaddr=172.16.132.2
  uci commit
  service network restart
  ```
- Now your VM is accessible from SSH, user **root** (no password) address **10.0.2.2**
- If you installed a release image such as 23.05.0, the LuCi web interface is available at your chosen IP address (such as [http://172.16.132.2/](http://172.16.132.2/ "http://172.16.132.2/")).
- If you installed a snapshot that doesn't include LuCi, install it with
  
  ```
  opkg update && opkg install luci
  ```
- You should have both internet access (try a **opkg update**) **and** a LAN interface with a static address you can connect your SSH client program to even if your PC is disconnected from a local network.
- If you have more complex requirements you will have to set that up on your own by reading the documentation, or through LuCi.

## See also

- [Other virtualization options](/docs/guide-user/virtualization/start "docs:guide-user:virtualization:start"): Docker, VMware etc.
- [UTM on Apple Silicon](/docs/guide-user/virtualization/utm "docs:guide-user:virtualization:utm"): Configuring using the open-source UTM virtual machine GUI
