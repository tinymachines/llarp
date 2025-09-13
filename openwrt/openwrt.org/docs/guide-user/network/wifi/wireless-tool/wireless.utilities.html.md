# Wireless Utilities

As explained at [wireless.overview](/docs/guide-user/network/wifi/wireless.overview "docs:guide-user:network:wifi:wireless.overview") the Linux IEEE 802.11 subsystem is fragmented. The available tools depend entirely on the [driver](https://wireless.wiki.kernel.org/en/users/drivers "https://wireless.wiki.kernel.org/en/users/drivers") associated with your wireless device. These have an API different from that of Ethernet devices because the specifications of IEEE 802.11 regulate quite precisely the communications process. Therefore it makes sense to *not* implement these requirements in each driver but only once for all drivers, and also because there is the problem of diverging frequency regulations worldwide.

## mac80211 based drivers

Common drivers based on this kernel subsystem include most of [driver.wlan](/docs/techref/driver.wlan/start "docs:techref:driver.wlan:start"): ath11k, mt76, rtl819x, mwlwifi, brcmfmac, etc.

### iwinfo

`iwinfo` is a CLI frontend to the custom library, which assembles information from various places. It is also used by [LuCI](/doc/howto/luci "doc:howto:luci")

- When in AP-mode, obtain a list of connected clients in STA-mode:
  
  ```
  iwinfo wlan0/wl0/ath0 assoclist
  ```

### iw

`iw` is the configuration utility for the [nl80211](https://wireless.wiki.kernel.org/en/developers/documentation/nl80211 "https://wireless.wiki.kernel.org/en/developers/documentation/nl80211") API.

- Add a new virtual interface with the given configuration:
  
  ```
  iw dev <devname> interface add <name> type <type> [mesh_id <meshid>] [4addr on|off] [flags <flag>*]
  ```
  
  Valid interface types are: managed, ibss, monitor, mesh, wds. See →[wireless modes](https://wireless.wiki.kernel.org/en/users/documentation/modes "https://wireless.wiki.kernel.org/en/users/documentation/modes")  
  The flags are only used for monitor interfaces, valid flags are: none, fcsfail, control, otherbss, cook
- Add a new virtual interface with the given configuration:
  
  ```
  iw phy <phyname> interface add <name> type <type> [flags <flag>*]
  ```
- Getting the currently set regulatory domain:
  
  ```
  iw reg get
  ```
- When in AP-mode, obtain a list of connected clients in STA-mode:
  
  ```
  iw dev wlan0 station dump
  ```
  
  The above also lists retry and fail packet counts, which are helpful in determining if wireless congestion (e.g. from many nearby 2.4GHz networks on the same channel in an apartment complex) is the source of throughput issues.
- Setting regulatory domain. Set your country [ISO 3166-1 alpha-2](https://en.wikipedia.org/wiki/ISO%203166-1%20alpha-2 "https://en.wikipedia.org/wiki/ISO 3166-1 alpha-2") in capital letters:
  
  ```
  iw reg set XX
  ```

**`Note:`** The `ath9k` driver (and all other softmac drivers?) sets its own regulatory restrictions based on its EEPROM, i.e. the [ART (Atheros Radio Test) partition](/docs/techref/flash.layout "docs:techref:flash.layout") on flash. Setting the domain from userland can only further restrict the regulatory settings. So if EEPROM says Japan, you can use all 14 channels, if you then set it to US, you can use merely the 12. It does not work the other way around, i.e. if EEPROM says US, you only can use the allowed 12 channels, no matter what you set in userspace! The value `98` represents a synthesized regulatory domain, based on the intersection of the available source of regulatory information (which can include the EEPROM, the userland setting, and a country IE from your AP).

- Question: Is there any way to get/set these raw settings (like, whatever it has in EEPROM)?
- Answer: Your “expectation” of having the freedom to modify the EEPROM is valid as I agree with it too but current (US) legislation does not allow for it. So to support upstream drivers we just cannot allow for those type of changes. You won't get any support if you try to mess with that stuff unless we get a change in legislation that says otherwise. Please refer to:
  
  - [https://wireless.wiki.kernel.org/en/vendors/VendorSupport](https://wireless.wiki.kernel.org/en/vendors/VendorSupport "https://wireless.wiki.kernel.org/en/vendors/VendorSupport")
  - [https://wireless.wiki.kernel.org/en/developers/Regulatory/statement](https://wireless.wiki.kernel.org/en/developers/Regulatory/statement "https://wireless.wiki.kernel.org/en/developers/Regulatory/statement")
  - [https://wireless.wiki.kernel.org/en/developers/Regulatory](https://wireless.wiki.kernel.org/en/developers/Regulatory "https://wireless.wiki.kernel.org/en/developers/Regulatory")
  - [Regulations per country](https://git.kernel.org/pub/scm/linux/kernel/git/sforshee/wireless-regdb.git/tree/db.txt "https://git.kernel.org/pub/scm/linux/kernel/git/sforshee/wireless-regdb.git/tree/db.txt")

### iwconfig

`iwconfig` (and `/proc/net/wireless`) is the configuration utility for the now obsolete [Wext](https://wireless.wiki.kernel.org/en/developers/documentation/wireless-extensions "https://wireless.wiki.kernel.org/en/developers/documentation/wireless-extensions") API scheduled for removal. Use `iw` or `iwinfo`.

### Hostapd

The mac80211 subsystem moves all aspects of *master mode* (a.k.a. AP mode) into user space, thus it depends on `hostapd` (also read [Hostapd](http://www.linuxwireless.org/en/users/Documentation/hostapd "http://www.linuxwireless.org/en/users/Documentation/hostapd")) to

- handle authenticating clients,
- set encryption keys,
- establishing key rotation policy,
- handle other aspects of the wireless infrastructure.

Due to this, the old method of issuing `iwconfig <wireless interface> mode master` no longer works. Userspace programs like hostapd now use [netlink](https://en.wikipedia.org/wiki/netlink "https://en.wikipedia.org/wiki/netlink") (the nl80211 driver) to create a master mode interface for your traffic and a monitor mode interface for receiving and transmitting management frames.

### wpad

Is a hostapd + [wpa\_supplicant](/doc/howto/wireless.utilities_wpa-supplicant "doc:howto:wireless.utilities_wpa-supplicant") multicall binary.

### hostapd-mini and wpad-mini

Are stripped down versions without OpenSSL dependency.

Available Packages hostapd 232.885 This package contains a full featured IEEE 802.1x/WPA/EAP/RADIUS Authenticator.  
`/etc/hostapd.conf` is generated by `hostapd.sh` hostapd-utils 10.198 This package contains a command line utility to control the IEEE 802.1x/WPA/EAP/RADIUS Authenticator. hostapd-mini 134.598 This package contains a minimal IEEE 802.1x/WPA Authenticator (Alles Version: 20110527-2) wpad 355.463 This package contains a full featured IEEE 802.1x/WPA/EAP/RADIUS Authenticator and Supplicant [wpa-supplicant](/doc/howto/wireless.utilities_wpa-supplicant "doc:howto:wireless.utilities_wpa-supplicant") 220.602 WPA Supplicant wpa-cli 19.887 WPA Supplicant command line interface wpad-mini 203.085 This package contains a minimal IEEE 802.1x/WPA Authenticator and Supplicant (WPA-PSK only). wpa-supplicant-mini 111.984 WPA Supplicant (minimal version) libnl-tiny 13.529 This package contains a stripped down version of libnl; all packages in hostapd depend on it libnl 107.504 This package contains a library for applications dealing with [netlink](https://en.wikipedia.org/wiki/netlink "https://en.wikipedia.org/wiki/netlink") sockets xsupplicant 122.996 This software allows a host to authenticate with a RADIUS server using 802.1x and various EAP protocols.

![](/_media/meta/icons/tango/dialog-information.png) **`wpad`** package is a full featured IEEE 802.1x authenticator/supplicant ([WPA](https://en.wikipedia.org/wiki/Wi-Fi%20Protected%20Access "https://en.wikipedia.org/wiki/Wi-Fi Protected Access")/[EAP](https://en.wikipedia.org/wiki/Extensible%20Authentication%20Protocol "https://en.wikipedia.org/wiki/Extensible Authentication Protocol")/[RADIUS](https://en.wikipedia.org/wiki/Remote%20Authentication%20Dial%20In%20User%20Service "https://en.wikipedia.org/wiki/Remote Authentication Dial In User Service")), while **`wpad-mini`** only supports WPA-PSK (Pre-shared key). **`wpad`** obsoletes **`hostapd`** and `wpa_supplicant` as it offers both authentication service for the access point mode and supplicant services for the wireless client mode in one package.

Also see [atheros.and.generic.mac80211.wifi](/docs/guide-user/network/wifi/encryption#atherosandgenericmac80211wifi "docs:guide-user:network:wifi:encryption")

![FIXME](/lib/images/smileys/fixme.svg):

- As far as I understand, wpad is a wrapper around hostapd with multicall support and [wpa\_supplicant](/doc/howto/wireless.utilities_wpa-supplicant "doc:howto:wireless.utilities_wpa-supplicant") built.
- Both wpad and wpad-mini are just wrappers around 'hostapd' with support packages, see [https://dev.openwrt.org/browser/trunk/package/hostapd/Makefile](https://dev.openwrt.org/browser/trunk/package/hostapd/Makefile "https://dev.openwrt.org/browser/trunk/package/hostapd/Makefile")
  
  - `wpad-mini` is the base system with only WPA(2)-PSK authentication.
  - `wpad` supports IEEE 802.1x/WPA/EAP/RADIUS (adds the 'WPA supplicant' package with OpenSSL library)
- The `hostapd-utils` just adds a small hostapd\_cli command line tool for messaging with the daemon.

<!--THE END-->

- [atheros.and.generic.mac80211.wifi](/docs/guide-user/network/wifi/encryption#atherosandgenericmac80211wifi "docs:guide-user:network:wifi:encryption")

<!--THE END-->

- Actually, it's the other way around: hostapd is symlink to wpad, cf. `/usr/sbin/hostapd → wpad`.
- Turning off debugging for `wpa_supplicant` decreased size of `wpad`-package from ~365 KiB to ~286 KiB. Turning off debugging for hostapd did nothing. Because it's a different binary, not included in `wpad`.

## drivers without cfg80211-support

### Atheros proprietary (madwifi)

- When in AP-mode, obtain a list of connected clients in STA-mode
  
  ```
  wlanconfig ath0 list sta
  ```

### Broadcom proprietary (wl)

- When in AP-mode, obtain a list of connected clients in STA-mode:
  
  ```
  wl assoclist
  wl sta_info macaddr
  ```
