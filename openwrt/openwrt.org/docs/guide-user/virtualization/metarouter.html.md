# Metarouter Virtualization on Mikrotik RouterBoard

Metarouter are virtual routers running on top of Mikrotik's RouterOS. This can be interesting when you want to use both RouterOS features and OpenWrt features in the same box. It also is a way to avoid having to worry about recovery of the RouterOS installation and the attached license. Depending on model.

If you flash OpenWrt from NetBoot facility, you will lose your RouterOS licence (not clear if this is true).

It is possible to run up to 7 virtual instances of OpenWrt on top of the router OS using a virtualization called metarouter ( [vendor manual](http://wiki.mikrotik.com/wiki/Manual:Metarouter "http://wiki.mikrotik.com/wiki/Manual:Metarouter")).

Network connectivity of the virtual instances is handled by virtual interfaces that could be connected to a

- bridge running on the host system or
- physical port of the router.

## Experiences with RB2011-UiAS-2HnD

### Wireless

There is currently no way to directly access the WLAN interface from within a virtual instance.

Therefore WLAN management is currently only possible using the routerOS CLI ( [vendor manual](http://wiki.mikrotik.com/wiki/Manual:Interface/Wireless "http://wiki.mikrotik.com/wiki/Manual:Interface/Wireless")).

### USB

There is currently no way to directly access the USB port from within a virtual instance.

Attached USB storage devices could be exported to the network using SMB and FTP. You may mount them within a virtual instance using smbmount or curlftpfs.

![:!:](/lib/images/smileys/exclaim.svg) Before a USB storage device can be used by routerOS it must be formatted using MikroTik's proprietary format - so all data is lost!

## Resources

- [metarouter patches provided by MikroTik (up to Backfire)](http://www.mikrotik.com/download/metarouter/openwrt-metarouter-1.2.patch "http://www.mikrotik.com/download/metarouter/openwrt-metarouter-1.2.patch")
- [metarouter patches to build Attitude Adjustment](http://forum.mikrotik.com/viewtopic.php?p=309608#p309608 "http://forum.mikrotik.com/viewtopic.php?p=309608#p309608")
- [metarouter patches to build Barrier Breaker (not well tested)](http://openwrt.naberius.de/barrier_breaker/mr-mips/ "http://openwrt.naberius.de/barrier_breaker/mr-mips/")
- [metarouter-app - create virtual applications using metarouter](https://code.google.com/p/metarouter-apps/ "https://code.google.com/p/metarouter-apps/")
- [mikrotik\_metarouter\_openwrt](/docs/guide-user/virtualization/mikrotik_metarouter_openwrt "docs:guide-user:virtualization:mikrotik_metarouter_openwrt")
