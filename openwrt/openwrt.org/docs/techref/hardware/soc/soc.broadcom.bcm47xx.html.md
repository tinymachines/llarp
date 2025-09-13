# Broadcom BCM47xx

This page covers the BCM47xx and BCM53xx Wireless Router/AP SoC running MIPS CPUs.

## Subtargets in Barrier Breaker

Beginning with [r41024](https://dev.openwrt.org/changeset/41024 "https://dev.openwrt.org/changeset/41024") this arch was split into 3 subtargets:

- legacy: old devices based on SSB bus
- generic: devices based on BCM4705 and two Linksys exceptions: WRT610N V2 and E3000 V1
- mips74k: newer devices with BCMA SoC and bgmac ethernet

See [list of Broadcom SoCs](https://wireless.docs.kernel.org/en/latest/en/users/drivers/b43/soc.html "https://wireless.docs.kernel.org/en/latest/en/users/drivers/b43/soc.html") to see if your BCM* chipset is SSB or BCMA.

## Images

The current goal is to boot one image on all the different devices using SoC of the bcm47xx family. The main image is openwrt-brcm47xx-squashfs.trx which is in the generic image format used by the Broadcom SDK for these devices. Many vendors like Netgear and Linksys currently are using their own image formats to prevent an incorrect image from being flashed to their devices, these images contain the same code as the generic image, but with some special header data just for this device, mostly containing the internal device name and the version of this firmware.

If you want to flash OpenWrt from the default firmware, use the image for your device if there is one, otherwise use the openwrt-brcm47xx-squashfs.trx image. For sysupgrade always use the generic image openwrt-brcm47xx-squashfs.trx independently from what image you initially flashed to your device.

If that does not work you could download the image builder or check out OpenWrt from the svn and edit target/linux/brcm47xx/image/Makefile to fit your needs. If you have to do some modifications to generate a valid image and it boots on your device please send a patch to the mailing list for inclusion into OpenWrt.

### Attitude Adjustment

Version 12.09-rc1: [http://downloads.openwrt.org/attitude\_adjustment/12.09-rc1/brcm47xx/](http://downloads.openwrt.org/attitude_adjustment/12.09-rc1/brcm47xx/ "http://downloads.openwrt.org/attitude_adjustment/12.09-rc1/brcm47xx/")

This image has support for all BCM47xx SoCs using SSB. These are all devices with a ieee802.11b or ieee802.11g WiFi support and the BCM4785/BCM4705 with an additional ieee80211n PCI devices connected to the SoC. This also includes some devices without any WiFi functionality using this SOC.

#### BCM4785/BCM4705

This SoC has a different Ethernet core and does not use b44 as the Ethernet driver. It needs tg3 instead. The default images for Attitude Adjustment do not include the tg3 Ethernet driver. Use the image builder (OpenWrt-ImageBuilder-brcm47xx-for-linux-i486.tar.bz2) to generate a image with Ethernet support. The profile with b43 as the WiFi driver is named Bcm4705-b43.

```
make image PROFILE="Bcm4705-b43"
```

### Barrier Breaker

Snapshot images download: [http://downloads.openwrt.org/snapshots/trunk/brcm47xx/](http://downloads.openwrt.org/snapshots/trunk/brcm47xx/ "http://downloads.openwrt.org/snapshots/trunk/brcm47xx/")

This is the current version where development takes place. It contains support for all the SoC supported by Attitude Adjustment and also most of the recent bcm47xx SoCs. It should at least be able to boot all the known MIPS based BCM47xx and BCM53xx based SoCs.

The default Barrier Breaker images contain the b44, tg3 and bgmac Ethernet driver so Ethernet should work on all supported services without using the image builder. If you want to save some space you could use the image builder to generate an image with only the drivers for your device.

## Ethernet

New Broadcom devices with gigabit Ethernet are supported by the bgmac kernel driver. Unfortunately CPUs on most of these SoCs are too slow to provide 1000 Mb/s routing or NAT. It results in NAT being limited to something around 130Mb/s on BCM4706 and even less on slower units (like ~50Mb/s on BCM4718A1).

To solve this problem, Broadcom developed the proprietary ctf.ko module that watches in-system routing rules and implements NAT on its own. It results in much better performance (even up to 850Mb/s on BCM4706) while breaking things like QoS and advanced firewall rules.

Unfortunately ctf.ko is closed source and there is no open source alternative. For more details see:

- [Ethernet performance for transfers between VLANs (bcm47xx)](https://lists.openwrt.org/pipermail/openwrt-devel/2013-August/020962.html "https://lists.openwrt.org/pipermail/openwrt-devel/2013-August/020962.html")
- [Understanding/reimplementing forwarding acceleration used by Broadcom (ctf)](https://lists.openwrt.org/pipermail/openwrt-devel/2013-August/021112.html "https://lists.openwrt.org/pipermail/openwrt-devel/2013-August/021112.html")

## WiFi drivers

There are different WiFi drivers for the Broadcom WiFi cores found in the BCM47xx SoCs or the PCI(e) or USB connected WiFi chips on the boards. There is no single driver that supports all chips and all drivers have their own pros and cons. Some chips are supported by three of these drivers and others are supported by none of these drivers.

![:!:](/lib/images/smileys/exclaim.svg) Do not activate multiple drivers at once. The first driver loaded takes precedence and it's not easy to control which one that is. With other Linux distributions, you could blacklist the unneeded drivers. In OpenWrt you should make sure they are not installed using opkg, which automatically removes them from the `/etc/modules.d/` directory.

See also:

- [http://en.wikipedia.org/wiki/Comparison\_of\_open\_source\_wireless\_drivers](http://en.wikipedia.org/wiki/Comparison_of_open_source_wireless_drivers "http://en.wikipedia.org/wiki/Comparison_of_open_source_wireless_drivers")
- [https://wiki.archlinux.org/index.php/Broadcom\_wireless](https://wiki.archlinux.org/index.php/Broadcom_wireless "https://wiki.archlinux.org/index.php/Broadcom_wireless")

### b43

This is the open source driver built by the community based on reverse engineered specifications of the proprietary Broadcom driver. This is the driver that is included in the current OpenWrt builds. It is also in the mainline Linux kernel. This driver supports most of the current available Broadcom WiFi cores. It has support for station (STA), AP, AdHoc, Mesh and other modes and it supports 5 GHz band on N-PHY devices. It supports 802.11g rates only and can't handle multiple SSIDs.

Website: [http://wireless.wiki.kernel.org/en/users/Drivers/b43](http://wireless.wiki.kernel.org/en/users/Drivers/b43 "http://wireless.wiki.kernel.org/en/users/Drivers/b43")

The OpenWrt package is named: **kmod-b43**

### b43legacy

This is for some very old ieee802.11b and first generation Broadcom ieee802.11g compatible devices. This driver has a similar feature set to b43 and is only supported by the community based on reverse engineered specifications.

Website: [http://wireless.wiki.kernel.org/en/users/Drivers/b43](http://wireless.wiki.kernel.org/en/users/Drivers/b43 "http://wireless.wiki.kernel.org/en/users/Drivers/b43")

The OpenWrt package is named: **kmod-b43legacy**

### brcm80211

This is the open source driver supported and released by Broadcom in 2010. It is in the mainline Linux kernel, but only since version 3.2. It is still missing some functionality, as of 2013: dual width 40MHz channels, advanced power saving features, LED support, HW-based encryption, among others. The driver has been renamed to its two constituents, the soft MAC driver (brcmsmac) and the full MAC driver (brcmfmac).

Website: [http://wireless.wiki.kernel.org/en/users/Drivers/brcm80211](http://wireless.wiki.kernel.org/en/users/Drivers/brcm80211 "http://wireless.wiki.kernel.org/en/users/Drivers/brcm80211")

#### brcmsmac

brcmsmac supports some recent soft mac ieee802.11n Broadcom WiFi cores found on PCIe cards and in SoCs, for details see the website. This driver is developed and supported by Broadcom. The current version only supports station mode, but there are patches in current OpenWrt trunk which add support for AP and Ad Hoc mode. brcmsmac is capable of operating devices with ieee80211n rates and running in the 5GHz band, but AP mode currently does not work in the 5GHz band.

The OpenWrt package is named: **kmod-brcmsmac**

#### brcmfmac

brcmfmac supports some recent full mac ieee802.11n Broadcom WiFi cores found on USB, SDIO and SPI interfaces, for details see the website.

The OpenWrt package is named: **kmod-brcmfmac**

### broadcom-wl

broadcom-wl contains the proprietary closed source Broadcom driver. It contains closed source MIPS binaries with a few trivial open source files that allow it to be compiled against any kernel version. It's based on old Broadcom's sources (version 5.10.56.27.3) and supports many old 802.11g devices but very few 802.11n devices (BCM4716, BCM4717, BCM4718). It does not support new chipsets (BCM5356, BCM5357, BCM5358, BCM47186, BCM4331) or 802.11ac devices (BCM4352, BCM4360). For old devices it often has more functionality than the brcm80211 drivers. For example, it supports 40 MHz channels and power saving features, which have been removed before releasing brcm80211. It is capable of operating in AP mode and also supports the 5 GHz band.

In 2008 Broadcom released Linux STA driver and continued updating it. Just like in case of OpenWrt driver, it contains some open source files, however binaries were pre-compiled for x86 and x86\_64 only. So despite providing support for more hardware, it can't be integrated into OpenWrt because of lack of support for MIPS/ARM and important features like AP mode.

Note that broadcom-wl doesn't use a standard cfg80211 API, so it can't be configured using standard nl80211 tools. This is why OpenWrt has an extra package providing `wlc` (user space tool that uses Broadcom's proprietary API) and `broadcom.sh` (that translates UCI config into `wlc` calls). You can also install `wl` binary that is closed source version of `wlc` written by Broadcom that may be helpful for some debugging. Remember that `broadcom.sh` may not handle all UCI options, please see [the UCI wireless configuration page](/docs/guide-user/network/wifi/basic "docs:guide-user:network:wifi:basic") for the details. Some advanced functionality can by configured with the `wl` utility only. Beware that running `wifi` (to activate your UCI WiFi configuration file) will however restart the driver and you will lose your settings made by the utility.

The OpenWrt package for the driver is named: **kmod-brcm-wl**  
The OpenWrt package for the configuration utility is named: **wl**  
The OpenWrt package for the open source variant of the configuration utility is named: **wlc**

##### Setting up the broadcom-wl driver

After installing any wireless driver made for opkg and OpenWrt, new [WiFi configuration entries](/docs/guide-user/network/wifi/basic "docs:guide-user:network:wifi:basic") in the `/etc/config/wireless` UCI file are available upon reboot. These are set by the OPKG driver maintainer. If they are not available, you can run `wifi detect` to acquire a sample configuration. For broadcom-wl (the kmod-brcm-wl package) the wireless interface is named `wl0`. By far not everything can be set using UCI. Use the `wl` utility to set advanced settings. For example, to set the channel to 4, on the 2.4Ghz band, and with a bandwidth of 40Mhz using the lower band, use:

```
root@OpenWrt:~# wl -i wl0 chanspec -c 4 -b 2 -w 40 -s -1
Chanspec set to 0x2b04
```

Now reload the wifi configuration by:

```
root@OpenWrt:~# wl -i wl0 down
root@OpenWrt:~# wl -i wl0 up
```

You configure to run these settings at boot to make them stick. Please note that this method of WiFi configuration is rather low level and---going partly past the normal OpenWrt WiFi interface---there isn't any mechanism available to automatically choose the right channel for example. So you have to manually select the channel specification. If the above channel is too crowded in your area, set it for example to channel 9 using the upper sideband:

```
root@OpenWrt:~# wl -i wl0 chanspec -c 9 -b 2 -w 40 -s 1
Chanspec set to 0x2e09
```

In the future maybe the community will further integrate the proprietary Broadcom driver into the OpenWrt framework. What is more likely though is that the open source drivers (brcm80211) will obtain more functionality.

If you want to use [LuCI](/docs/guide-user/luci/luci.essentials "docs:guide-user:luci:luci.essentials") to configure UCI configuration, note that not all functionality and features are currently well supported and do not correspond well to the driver functionality in the graphical interface. It may therefore sometimes call the driver configuration utility with unsupported arguments.

For providing authentication and encryption with Wi-Fi and the broadcom-wl driver, you need the proprietary application from Broadcom, **nas** (Network Authentication Service). The tool is automatically started by the wireless infrastructure to accomodate the broadcom-wl driver. There is no configuration necessary, just install the package **nas**. See also [encryption](/docs/guide-user/network/wifi/encryption "docs:guide-user:network:wifi:encryption").

An exmaple UCI configuration is as follows. Note that the hwmode option does not have to be given in which case the driver's default is used.

```
config wifi-device 'wl0'
	option type 'broadcom'
	option disabled '0'
	option channel '4'
	option txpower '16'

config wifi-iface
	option device 'wl0'
	option network 'lan'
	option ssid 'OpenWrt'
	option key 'passphrase'
	option mode 'ap'
	option encryption 'psk2'
```

![](/_media/meta/icons/tango/48px-dialog-warning.svg.png?w=24&tok=aae903) Broadcom devices may use two different buses for its wireless drivers:  
\- SSB (Sonic Silicon Backplane), bus used by older devices  
\- BCMA ([AMBA](https://en.wikipedia.org/wiki/Advanced%20Micro-controller%20Bus%20Architecture "https://en.wikipedia.org/wiki/Advanced Micro-controller Bus Architecture")), bus developed by Broadcom; shall replace SSB (see also [here](https://github.com/hanshuebner/linux-xlnx/tree/master/drivers/bcma "https://github.com/hanshuebner/linux-xlnx/tree/master/drivers/bcma"))  
The **b43** driver supports both SSB and BCMA-chips. However, **brcm80211** (brcmSmac &amp; brcmFmac) does not and will not support any chips which contain the SSB. Therefore, older devices may be unsupported by the newer open source drivers. See also this patch [Patch for 3.11](http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=314878d246955e0c6fff95d8ae64285fe828c785 "http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=314878d246955e0c6fff95d8ae64285fe828c785")

## Sysupgrade

When using sysupgrade always use openwrt-brcm47xx-squashfs.trx and not any device specific file.

See also ['.bin' to '.trx' image conversion](/docs/techref/hardware/soc/soc.broadcom.bcm47xx/image.conversion "docs:techref:hardware:soc:soc.broadcom.bcm47xx:image.conversion").

## CFE

### Network boot

Most of the recent devices have a [cfe](/docs/techref/bootloader/cfe "docs:techref:bootloader:cfe") bootloader able to boot images over the network.

To build an image bootable over the network select the following: “Target Images” --→ \[x] “ramdisk” --→ Compression --→ \[xz] This will generate a file in bin/brcm47xx/openwrt-brcm47xx-vmlinux.elf

The following example boots an elf image from the tftp server at 192.168.1.2 under the path /brcm47xx/openwrt-brcm47xx-vmlinux.elf:

```
boot -tftp -elf 192.168.1.2:/brcm47xx/openwrt-brcm47xx-vmlinux.elf
```

## BCM4704 JTAG pinout

[![](/_media/media/doc/hardware/bcm4704_jtag_pinout.png?w=400&tok=bf8e4b)](/_detail/media/doc/hardware/bcm4704_jtag_pinout.png?id=docs%3Atechref%3Ahardware%3Asoc%3Asoc.broadcom.bcm47xx "media:doc:hardware:bcm4704_jtag_pinout.png")

## Links

List with some detailed informations about bcm47xx SoCs: [http://wireless.kernel.org/en/users/Drivers/b43/soc](http://wireless.kernel.org/en/users/Drivers/b43/soc "http://wireless.kernel.org/en/users/Drivers/b43/soc") [headers](/docs/techref/headers "docs:techref:headers")

## Devices

The list of related devices: [bcm4702](/tag/bcm4702?do=showtag&tag=bcm4702 "tag:bcm4702"), [bcm4704](/tag/bcm4704?do=showtag&tag=bcm4704 "tag:bcm4704"), [bcm4705](/tag/bcm4705?do=showtag&tag=bcm4705 "tag:bcm4705"), [bcm4706](/tag/bcm4706?do=showtag&tag=bcm4706 "tag:bcm4706"), [bcm4708](/tag/bcm4708?do=showtag&tag=bcm4708 "tag:bcm4708"), [bcm4716](/tag/bcm4716?do=showtag&tag=bcm4716 "tag:bcm4716"), [bcm47162](/tag/bcm47162?do=showtag&tag=bcm47162 "tag:bcm47162"), [bcm4717](/tag/bcm4717?do=showtag&tag=bcm4717 "tag:bcm4717"), [bcm4718](/tag/bcm4718?do=showtag&tag=bcm4718 "tag:bcm4718"), [bcm47186](/tag/bcm47186?do=showtag&tag=bcm47186 "tag:bcm47186"), [bcm47xx](/tag/bcm47xx?do=showtag&tag=bcm47xx "tag:bcm47xx"), [bcm5352](/tag/bcm5352?do=showtag&tag=bcm5352 "tag:bcm5352"), [bcm5354](/tag/bcm5354?do=showtag&tag=bcm5354 "tag:bcm5354"), [bcm5357](/tag/bcm5357?do=showtag&tag=bcm5357 "tag:bcm5357"), [bcm5358](/tag/bcm5358?do=showtag&tag=bcm5358 "tag:bcm5358"), [bcm53xx](/tag/bcm53xx?do=showtag&tag=bcm53xx "tag:bcm53xx"), [bcm5836](/tag/bcm5836?do=showtag&tag=bcm5836 "tag:bcm5836")
