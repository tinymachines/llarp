# Wireless overview

This article deals with 802.11 wireless. OpenWrt supports other wireless devices too, see [Bluetooth](/docs/guide-user/hardware/bluetooth/start "docs:guide-user:hardware:bluetooth:start"), 802.15.4 ([r45348](https://dev.openwrt.org/changeset/45348 "https://dev.openwrt.org/changeset/45348")) or RTL-SDR ([RTL-SDR on TL-WR703n](https://yuv.al/blog/feeding-data-to-flightradar24-dot-com/ "https://yuv.al/blog/feeding-data-to-flightradar24-dot-com/"))

## Introduction

[Linux Wireless](https://wireless.wiki.kernel.org/welcome "https://wireless.wiki.kernel.org/welcome") is *the* source for documentation regarding the entire **Linux Kernel IEEE 802.11 (“wireless”) subsystem**. It is a wiki like this one, so feel free to contribute there as well! Everything not OpenWrt specific belongs there. This page is an exception, as I believe I can provide a better introduction. ![;-)](/lib/images/smileys/wink.svg)

- IEEE 802.**3** is a family of communication protocols comprising [Layer 1](https://en.wikipedia.org/wiki/Physical%20Layer "https://en.wikipedia.org/wiki/Physical Layer") and [Layer 2 Sublayer MAC](https://en.wikipedia.org/wiki/Media%20Access%20Control "https://en.wikipedia.org/wiki/Media Access Control")
- IEEE 802.3 has an official name: *Ethernet*
- IEEE 802.**11** is a family of communication protocols also comprising Layer 1 and Layer 2 Sublayer MAC
- IEEE 802.11 has no official name, so most people simply call it “wireless” or “wavelan” or `wifi` (note that [Wi-Fi](https://en.wikipedia.org/wiki/Wi-Fi "https://en.wikipedia.org/wiki/Wi-Fi") is a brand name)
- The support for IEEE 802.11 in the Linux kernel is fragmented. This means there are two frames (WEXT=deprecated, cfg80211 + nl80211=current) and multiple drivers, e.g.
  
  - For some Broadcom WNICs, there are also three drivers available: Broadcom proprietary drivers (`broadcom-wl`), broadcom mac80211-based drivers (the `b43`) and the brcmSmac- and brcmFmac drivers
    
    - To set up and configure, [**wireless utilities**](https://wireless.wiki.kernel.org/en/users/documentation/iw "https://wireless.wiki.kernel.org/en/users/documentation/iw") are available, however on OpenWrt, UCI is preferred: `/etc/config/wireless` and `/etc/config/network`.
  - There are two different types of WNICs to distinguish: [SoftMAC](https://wireless.wiki.kernel.org/en/developers/documentation/glossary#:~:text=%28Access%20Point%29-,SoftMAC,-SoftMAC%20is%20a "https://wireless.wiki.kernel.org/en/developers/documentation/glossary#:~:text=(Access%20Point)-,SoftMAC,-SoftMAC%20is%20a") and [FullMAC](https://wireless.wiki.kernel.org/en/developers/documentation/glossary#:~:text=or%20terminal%20emulator.-,FullMAC,-FullMAC%20is%20a "https://wireless.wiki.kernel.org/en/developers/documentation/glossary#:~:text=or%20terminal%20emulator.-,FullMAC,-FullMAC%20is%20a") devices; also see [*About mac80211*](https://wireless.wiki.kernel.org/en/developers/documentation/mac80211 "https://wireless.wiki.kernel.org/en/developers/documentation/mac80211").
- Many drivers might require firmware blobs. Most firmware code is closed source. (Exception carl9170, [ath9k\_htc](https://wireless.wiki.kernel.org/en/developers/gsoc/2012/ath9k_htc_open_firmware "https://wireless.wiki.kernel.org/en/developers/gsoc/2012/ath9k_htc_open_firmware"))
- Atheros ath9k does not require firmware.
- In contrast to Ethernet drivers, wireless drivers work in a **Wireless Mode of Operation**.

### Wireless Modes of Operation

→[Wireless Modes of Operation](/docs/techref/wireless.modes "docs:techref:wireless.modes") →Kernel: [Wireless Modes of Operation](http://wireless.kernel.org/en/users/Documentation/modes "http://wireless.kernel.org/en/users/Documentation/modes")

### Driver support for wireless modes of operation

See what the Linux 802.11 driver for *your* hardware can and cannot do. Some drivers support only one mode: STA (also called station, client or managed mode) other drivers support multiple modes, some even simultaneously (interface combination):

- →[wireless.kernel.org: Driver capabilities: support for Wireless Modes of Operation](http://wireless.kernel.org/en/users/Drivers "http://wireless.kernel.org/en/users/Drivers")
- →[Wikipedia: Driver capabilities: support for Wireless Modes of Operation](https://en.wikipedia.org/wiki/Comparison_of_open_source_wireless_drivers#Driver_capabilities "https://en.wikipedia.org/wiki/Comparison_of_open_source_wireless_drivers#Driver_capabilities")

Limitations when combining multiple wireless modes of operation at the same time do exist.

- →[Driver limitations when combining multiple wireless modes of operation](https://forum.openwrt.org/viewtopic.php?pid=204746#p204746 "https://forum.openwrt.org/viewtopic.php?pid=204746#p204746")

Firmware Limitations do exist

- →[No 5GHz AP with Intel 7260](http://www.spinics.net/lists/linux-wireless/msg124328.html "http://www.spinics.net/lists/linux-wireless/msg124328.html")

### Regulation in law

Available frequencies, bands and channels are subject to regulation in each state. Please see: [https://git.kernel.org/pub/scm/linux/kernel/git/sforshee/wireless-regdb.git/tree/db.txt](https://git.kernel.org/pub/scm/linux/kernel/git/sforshee/wireless-regdb.git/tree/db.txt "https://git.kernel.org/pub/scm/linux/kernel/git/sforshee/wireless-regdb.git/tree/db.txt")

## Wireless Drivers in OpenWrt

Wireless drivers are pulled on a more or less regular basis from [wireless-testing](http://git.kernel.org/cgit/linux/kernel/git/wireless/wireless-testing.git/ "http://git.kernel.org/cgit/linux/kernel/git/wireless/wireless-testing.git/") and the OpenWrt patches which are not mainlined yet are adjusted, see e.g. [r36939](https://dev.openwrt.org/changeset/36939/trunk "https://dev.openwrt.org/changeset/36939/trunk"). OpenWrt does not use kernel drivers. The package is called mac80211.

- [history of commits to OpenWrt trunk regarding mac80211](https://dev.openwrt.org/log/trunk/package/kernel/mac80211 "https://dev.openwrt.org/log/trunk/package/kernel/mac80211")
- [tickets on mac80211](https://dev.openwrt.org/search?ticket=on&q=mac80211 "https://dev.openwrt.org/search?ticket=on&q=mac80211"), better is a custom query in [Trac](https://en.wikipedia.org/wiki/Trac "https://en.wikipedia.org/wiki/Trac"): e.g. [custom query](https://dev.openwrt.org/query?status=accepted&status=assigned&status=new&status=reopened&description=~mac80211&max=20&order=priority "https://dev.openwrt.org/query?status=accepted&status=assigned&status=new&status=reopened&description=~mac80211&max=20&order=priority")

Similar work (brand new drivers for older kernel) is done by the [backports](https://backports.wiki.kernel.org/index.php/Main_Page "https://backports.wiki.kernel.org/index.php/Main_Page") project [April 2013 announcement](http://marc.info/?l=linux-backports&m=136490878702448 "http://marc.info/?l=linux-backports&m=136490878702448"), previously called compat-wireless or compat-driver. OpenWrt does not use this, despite referencing it by name.

## Wireless Utilities in OpenWrt

- [Wireless Utilities](/docs/guide-user/network/wifi/wireless-tool/wireless.utilities "docs:guide-user:network:wifi:wireless-tool:wireless.utilities")

## Wireless Tools and Applications available in the OpenWrt repository

- [kismet](/docs/guide-user/network/wifi/wireless-tool/kismet "docs:guide-user:network:wifi:wireless-tool:kismet") – An IEEE 802.11 network detector, sniffer and intrusion detection system.
- [aircrack-ng](/docs/guide-user/network/wifi/wireless-tool/aircrack-ng "docs:guide-user:network:wifi:wireless-tool:aircrack-ng") – Aircrack-ng is the next generation of aircrack with new features
- [horst](/docs/guide-user/network/wifi/wireless-tool/horst "docs:guide-user:network:wifi:wireless-tool:horst") – A scanning and analysis tool for IEEE 802.11 networks and especially IBSS (ad-hoc) mode and mesh networks (OLSR).

### Captive portal software available in the OpenWrt repository

`nodogsplash` Layer 3 [https://github.com/nodogsplash/nodogsplash](https://github.com/nodogsplash/nodogsplash "https://github.com/nodogsplash/nodogsplash") NoDogSplash offers a simple way to open a free hotspot providing restricted access to an internet connection.  
It is another alternative from NoCat which aims to offer captive portal solutions local to the router/gateway and a simplistic setup, user bandwidth control and basic auth/splash page. Nodogsplash is small, well tested, tailored for OpenWrt by its author and can be set up with only one or two config file changes. By contrast, Chilli is more complete but complex to set up. `coova-chilli` Layer 2 / Layer 3 [http://www.coova.org/](http://www.coova.org/ "http://www.coova.org/") CoovaChilli is an open source access controller for wireless LAN access points and is based on ChilliSpot. It is used for authenticating users of a wireless (or wired) LAN. It supports web based login (UAM) which is today's standard for public HotSpots and it supports Wireless Protected Access (WPA) encryption. Authentication, authorization and accounting (AAA) is handled by your favorite RADIUS server.  
Built on top of Chillispot with several improvements and additions. Includes [WISPr](https://en.wikipedia.org/wiki/WISPr "https://en.wikipedia.org/wiki/WISPr") support, and much more. Main captive portal solution used in CoovaAP.

### Wireless packages available in the OpenWrt repository

This shall be, but is not, an exhaustive list of all packages in the OpenWrt repository regarding wireless stuff to play with. The installation is always the same `opkg install <package>`. For documentation regarding the configuration and utilization, search for Howtos in this wiki or in the Internet.

Name Size Description airpwn 23618 Airpwn is a framework for 802.11 (wireless) packet injection. Airpwn listens to incoming wireless packets, and if the data matches a pattern specified in the config files, custom content is injected “spoofed” from the wireless access point. From the perspective of the wireless client, airpwn becomes the server. collectd-mod-wireless 7321 wireless status input plugin freifunk-watchdog 9546 A watchdog daemon that monitors wireless interfaces to ensure the correct BSSID and channel. The process will initiate a wireless restart as soon as it detects a BSSID or channel mismatch. karma 8605 KARMA is a set of tools for assessing the security of wireless clients at multiple layers. Wireless sniffing tools discover clients and their preferred/trusted networks by passively listening for 802.11 Probe Request frames. kmod-wprobe 9408 A module that exports measurement data from wireless driver to user space mdk3 49495 Tool to exploit wireless vulnerabilities wavemon 32209 wavemon is an ncurses-based monitoring application for wireless network devices. Based on WEXT-API wireless-tools 30236 This package contains a collection of tools for configuring wireless adapters implementing WEXT-API

### Wireless drivers available in the OpenWrt repository

E.g.:

Package Dependencies kmod-ath9k kmod-ath9k-common kmod-ath kmod-mac80211 kmod-crypto-core kmod-crypto-arc 4 kmod-crypto-core kmod-crypto-aes kmod-cfg80211 wireless-tools iw libnl-tiny crda Overall size = 486.450 Bytes kmod-ath5k kmod-ath kmod-mac80211 kmod-crypto-core kmod-crypto-arc 4 kmod-crypto-core kmod-crypto-aes kmod-cfg80211 wireless-tools iw libnl-tiny crda Overall size = 308.902 Bytes kmod-b43 kmod-ssb kmod-bcma kmod-mac80211 kmod-crypto-core kmod-crypto-arc 4 kmod-crypto-core kmod-crypto-aes kmod-cfg80211 wireless-tools iw libnl-tiny crda Overall size = 561.201 Bytes

Name Size Description kmod-ath9k 155.684 This module adds support for wireless adapters based on Atheros IEEE 802.11n AR5008 and AR9001 family of chipsets. kmod-ath9k-htc 113.441 This module adds support for wireless adapters based on Atheros USB AR9271 and AR7010 family of chipsets. kmod-ath9k-common 104.136 Atheros 802.11n wireless devices (common code for ath9k and ath9k\_htc) kmod-ath5k 82.272 This module adds support for wireless adapters based on Atheros 5xxx chipset. kmod-ath 10.059 This module contains some common parts needed by Atheros Wireless drivers. kmod-b43 210.860 Kernel module for Broadcom 43xx wireless support (mac80211 stack) kmod-brcm-wl 1847.448 Proprietary kernel module for Broadcom SSB/B43xx, it replaces kmod-b43. It requires also the packages nas and wlc kmod-brcmsmac 550.416 Kernel module for Broadcom BCMA/IEEE802.11n PCIe Wireless cards kmod-mac80211 139.372 Generic IEEE 802.11 Networking Stack (mac80211) kmod-cfg80211 93.696 cfg80211 is the Linux wireless LAN (802.11) configuration API. iw 32.100 cfg80211 interface configuration utility wireless-tools 23.153 Contains `iwconfig`, `iwlist` and `iwpriv`; tools for configuring wireless adapters implementing the WExt. crda 9.627 The [Central Regulatory Domain Agent](https://wireless.wiki.kernel.org/en/developers/regulatory/crda "https://wireless.wiki.kernel.org/en/developers/regulatory/crda") serves one purpose: tell Linux kernel what to enforce. In essence it is a udev helper for communication between the kernel and userspace. You only need to run this manually for debugging purposes. For manual changing of regulatory domains use iw (`iw reg set`) or wpa-supplicant (feature yet to be added). libnl-tiny 13.529 This package contains a stripped down version of libnl

![](/_media/meta/icons/tango/48px-outdated.svg.png) Due to [r31954](https://dev.openwrt.org/changeset/31954/ "https://dev.openwrt.org/changeset/31954/") tweaking the `regulatory.bin` to enable channel 13 and 14 is no longer an option.

## Wireless Configuration HowTo and Recipes

You can find a couple of probed scenarios under → [wifi section](/docs/guide-user/network/wifi/start "docs:guide-user:network:wifi:start").

## Troubleshooting

- [problem with any kinds of multicast traffic on 802.11 networks](https://forum.openwrt.org/viewtopic.php?id=33875 "https://forum.openwrt.org/viewtopic.php?id=33875")

## Notes

- [on AP modes](https://forum.openwrt.org/viewtopic.php?pid=133243#p133243 "https://forum.openwrt.org/viewtopic.php?pid=133243#p133243")
- [r37553 add authsae open80211s authentication daemon](https://dev.openwrt.org/changeset/37553 "https://dev.openwrt.org/changeset/37553") [IEEE 802.11s](https://en.wikipedia.org/wiki/IEEE%20802.11s "https://en.wikipedia.org/wiki/IEEE 802.11s")
- [r37483 ath9k: add initial tx queueing rework patches](https://dev.openwrt.org/changeset/37483 "https://dev.openwrt.org/changeset/37483") This forces all packets (even for un-aggregated traffic) through software queues to improve fairness and stability

## OpenWrt Wireless FAQ

- → [OpenWrt Wireless FAQ](/tag/wireless "tag:wireless")
