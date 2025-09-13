# Devices with OpenWrt as a stock firmware

Some routers like GL.inet or Turris already have preinstalled native firmware based on OpenWrt. The firmwares may contain tweaks, proprietary software/drivers, packages aren't compatible with OpenWrt, kernel modules missing, configurations not comparable and almost always uses their own Web GUI alongside LUCI to improve user experience. The customization of their firmware may be so big so that even though they are OpenWrt-based, a lot of OpenWrt wiki articles/packages/recommendations do not apply.

Since they need to make their own adaptation they usually based on older stable versions of OpenWrt. Routers with Qualcomm Atheros or MediaTek SoC usually use [QCA Software Development Kit (QSDK)](https://wiki.codelinaro.org/en/clo/qsdk/overview/ "https://wiki.codelinaro.org/en/clo/qsdk/overview/") which is very heavily modified old OpenWrt 15.

The proprietary parts can't be publicly audited so they may contain security vulnerabilities. That's why some users may prefer to install on this devices a truly open source “vanilla OpenWrt” downloaded from OpenWrt.org.

## GL.iNet

[GL.iNet](/toh/gl.inet/start "toh:gl.inet:start") is a Hong Kong based company that produces popular travel routers for 3G modems and powerful VPN “edge computing” routers.

Their firmware is based on OpenWrt with a few differences:

- Nice and user friendly Web GUI based on Vue.js
- LUCI is also available for power users.
- They offer a [cloud solution](https://docs.gl-inet.com/en/3/app/cloud/ "https://docs.gl-inet.com/en/3/app/cloud/") with [DynDNS](/docs/guide-user/services/ddns/client "docs:guide-user:services:ddns:client") and remote control.
- Lighttpd is used instead of uhttpd.
- 3G modem drivers are included.
- Drivers are mostly proprietary.

These devices are usually fully supported by vanilla OpenWrt.

## Turris

[Turris](/toh/turris/turris "toh:turris:turris") are advanced routers which are fully open source and with focus on security. Their [Omnia](/toh/turris/turris_omnia "toh:turris:turris_omnia") router has 8Gb of storage and 1600 MHz dual-core ARMv7 CPU so it can be used as a NAS or a small server. Their firmware called [TurrisOS](https://project.turris.cz/en/software "https://project.turris.cz/en/software") and based on latest stable OpenWrt with a few differences:

- User friendly Web GUI Foris and reForis which is written in Python and open source
- LUCI is also available for power users
- Rolling auto updates and distributed firewall
- Lighttpd is used instead of uhttpd.
- Instead of DropBear is used OpenSSH server
- No [SquashFS](/docs/techref/file_system "docs:techref:file_system") which simplifies software install and updates
- Easy install of NextCloud, OpenVPN, WireGuard and LXC containers
- Dynamic Firewall and secure DNS
- MQTT support useful for IoT

This device is supported by vanilla OpenWrt with some small limitations.

## Cudy

[Cudy](/toh/cudy/start "toh:cudy:start") is a Shenzhen based company that produces routers, travel routers, and access points. Some of these use a vendor forked build of OpenWRT with a user-friendly GUI and are supported by “vanilla OpenWRT.” Cudy routers have firmware image validation and supported models require flashing Cudy provided intermediary firmware prior to being able to flash images from OpenWRT.org.

## WallFi

[WallFi WAP 1.0](https://www.tindie.com/products/tech/smallest-access-point-repeater/ "https://www.tindie.com/products/tech/smallest-access-point-repeater/") is a WiFi repeater that is so small so can be built into wall. It uses uses almost vanilla OpenWrt with LUCI Web GUI. But this is not a popular device.

## Vilfo

fixme: [Vilfo](https://www.vilfo.com/en "https://www.vilfo.com/en") produce an x64 based device aimed at VPN usage. It has basic wifi.

## ISP Devices

These devices you can't buy in a shop because they are given to customers by ISPs. This vendors uses Broadcom wireless [which has a limited support of OpenWrt](/meta/infobox/broadcom_wifi "meta:infobox:broadcom_wifi"). That doesn't help you that much though, as packages aren't compatible, kernel modules missing, configurations not comparable and often with a different web interface (and configuration backend) on top, as with most vendors (GPL-) source availability is often 'incomplete' as well. Such devices not supported by the vanilla OpenWrt but they do use it internally:

- [Technicolor](https://www.youtube.com/watch?v=eGdpJjR-jDw "https://www.youtube.com/watch?v=eGdpJjR-jDw") are very popular devices but only few of their devices are [partially supported by the vanilla OpenWrt](/toh/hwdata/technicolor/start "toh:hwdata:technicolor:start")
- [IOPSYS](https://iopsys.eu/ "https://iopsys.eu/") develops their own firmware IOPSYSWRT based on OpenWrt with [JUCI Web GUI](https://github.com/mkschreder/juci "https://github.com/mkschreder/juci").
- [Sentinel SPS](https://sentinel-sps.com/ "https://sentinel-sps.com/") is a CPE Gateway and proxy that protects network from viruses and security attacks.
