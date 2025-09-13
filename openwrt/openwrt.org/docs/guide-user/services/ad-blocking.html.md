# Ad blocking

Network-wide ad blocking may be desired for content filtering to reduce ads, reduce bandwidth usage, reduce tracking and increase privacy. This can be accomplished with OpenWrt by installing one of the options below.

## Solutions

### Adblock

- Packages: [adblock](/packages/pkgdata/adblock "packages:pkgdata:adblock"), [luci-app-adblock](/packages/pkgdata/luci-app-adblock "packages:pkgdata:luci-app-adblock")
- Configuration: **LuCI → Services → Adblock**
- Follow: [documentation](https://github.com/openwrt/packages/blob/master/net/adblock/files/README.md "https://github.com/openwrt/packages/blob/master/net/adblock/files/README.md"), [forum](https://forum.openwrt.org/t/adblock-support-thread/507 "https://forum.openwrt.org/t/adblock-support-thread/507")

### Adblock-Fast

the high-performance ad-blocking service work with Dnsmasq, SmartDNS, and Unbound. with easy manage block list by LuCI Web UI ( more easy than **Adblock** ).

- Configuration: **LuCI → Services → Adblock-Fast**
- Follow: [documentation](https://docs.openwrt.melmac.net/adblock-fast/ "https://docs.openwrt.melmac.net/adblock-fast/"), [forum](https://forum.openwrt.org/t/adblock-fast-ad-blocking-service-for-dnsmasq-and-unbound/170530 "https://forum.openwrt.org/t/adblock-fast-ad-blocking-service-for-dnsmasq-and-unbound/170530")

### AdGuard Home

- Packages: [adguardhome](/packages/pkgdata/adguardhome "packages:pkgdata:adguardhome")
- Follow: [documentation](/docs/guide-user/services/dns/adguard-home "docs:guide-user:services:dns:adguard-home"), [forum](https://forum.openwrt.org/t/how-to-updated-2021-installing-adguardhome-on-openwrt-manual-and-opkg-method/113904 "https://forum.openwrt.org/t/how-to-updated-2021-installing-adguardhome-on-openwrt-manual-and-opkg-method/113904")

### Adblock-lean

adblock-lean is a powerful and ultra-efficient adblocker for OpenWrt

- Follow: [documentation](https://github.com/lynxthecat/adblock-lean/tree/master "https://github.com/lynxthecat/adblock-lean/tree/master"), [forum](https://forum.openwrt.org/t/adblock-lean-set-up-adblock-using-dnsmasq-blocklist/157076 "https://forum.openwrt.org/t/adblock-lean-set-up-adblock-using-dnsmasq-blocklist/157076")
