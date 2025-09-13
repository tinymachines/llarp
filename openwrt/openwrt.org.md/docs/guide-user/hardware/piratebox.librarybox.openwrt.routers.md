# PirateBox &amp; LibraryBox

PirateBox &amp; LibraryBox are special configured OpenWrt Routers. The primary target is to share data, located on USB Stick, with people at the location of the device. PirateBox is the origin of those projects and offers, beside the access on the USB Stick, an upload possibility and a shoutbox.

[![Some casing with a funny logo](/_media/media/raspberry_pi_foundation/raspberry.pi.jpg?h=200&tok=a2574a "Some casing with a funny logo")](/_detail/media/raspberry_pi_foundation/raspberry.pi.jpg?id=docs%3Aguide-user%3Ahardware%3Apiratebox.librarybox.openwrt.routers "media:raspberry_pi_foundation:raspberry.pi.jpg") [![](/_media/media/tplink/piratebox.png?h=200&tok=823812)](/_detail/media/tplink/piratebox.png?id=docs%3Aguide-user%3Ahardware%3Apiratebox.librarybox.openwrt.routers "media:tplink:piratebox.png") [![](/_media/media/tplink/librarybox.jpeg?w=500&tok=7116c0)](/_detail/media/tplink/librarybox.jpeg?id=docs%3Aguide-user%3Ahardware%3Apiratebox.librarybox.openwrt.routers "media:tplink:librarybox.jpeg")

#### Requirements

For installing PirateBox you need a device with at least one USB port. The whole list of known devices is [PirateBox gitHub Repository](https://github.com/MaStr/mkPirateBox/wiki/Router-support "https://github.com/MaStr/mkPirateBox/wiki/Router-support").

#### HowTo PirateBox

The following HowTo is for people, who have basic knowledge of OpenWrt configuration. If you need a detailed HowTo, please follow [David Dart's HowTo](http://daviddarts.com/piratebox-diy-openwrt/ "http://daviddarts.com/piratebox-diy-openwrt/").

**Warning:** This will change the routers configuration (i.e. SSID, disable uhttpd and probably other stuff).

- Install OpenWrt on your router depending on its specific needs.
- Enable internet-access for you device
- run (installs the repository to opkg.conf):

```
  opkg install http://stable.openwrt.piratebox.de/all/packages/pbxopkg_0.0.4_all.ipk
```

- run

```
  opkg update
```

- run

```
  opkg install piratebox
```

- reboot your device

If you encounter any problems, please report to [PirateBox Forum](http://forum.daviddarts.com/index.php "http://forum.daviddarts.com/index.php").

#### Suitable Hardware

Any openwrt-supported device will do, in case you want something battery driven: [Ready to go openwrt images](http://stable.openwrt.piratebox.de/trunk/ "http://stable.openwrt.piratebox.de/trunk/")

## Link dump

- [Piratebox forum of TP-Link TL-MR10U](http://forum.daviddarts.com/read.php?8%2C8052 "http://forum.daviddarts.com/read.php?8,8052")
- [Piratebox forum of TP-Link TL-MR13U](http://forum.daviddarts.com/read.php?8%2C8311 "http://forum.daviddarts.com/read.php?8,8311")
- [http://daviddarts.com/piratebox-diy-openwrt/](http://daviddarts.com/piratebox-diy-openwrt/ "http://daviddarts.com/piratebox-diy-openwrt/")
- [http://piratebox.aod-rpg.de/dokuwiki/doku.php](http://piratebox.aod-rpg.de/dokuwiki/doku.php "http://piratebox.aod-rpg.de/dokuwiki/doku.php")
- [http://forum.daviddarts.com/index.php](http://forum.daviddarts.com/index.php "http://forum.daviddarts.com/index.php")
- [https://forum.openwrt.org/viewtopic.php?id=44803](https://forum.openwrt.org/viewtopic.php?id=44803 "https://forum.openwrt.org/viewtopic.php?id=44803")
- [http://www.youtube.com/watch?v=sldcEwQKfb0](http://www.youtube.com/watch?v=sldcEwQKfb0 "http://www.youtube.com/watch?v=sldcEwQKfb0")
- [http://librarybox.us/](http://librarybox.us/ "http://librarybox.us/")
- [http://jasongriffey.net/librarybox/MR3020.html](http://jasongriffey.net/librarybox/MR3020.html "http://jasongriffey.net/librarybox/MR3020.html")
- [https://groups.google.com/forum/#!forum/librarybox](https://groups.google.com/forum/#!forum/librarybox "https://groups.google.com/forum/#!forum/librarybox")
- [https://forum.openwrt.org/viewtopic.php?id=44803](https://forum.openwrt.org/viewtopic.php?id=44803 "https://forum.openwrt.org/viewtopic.php?id=44803")
- [http://www.youtube.com/watch?v=WEGgUw34F1E](http://www.youtube.com/watch?v=WEGgUw34F1E "http://www.youtube.com/watch?v=WEGgUw34F1E")
- [http://vimeo.com/38210825](http://vimeo.com/38210825 "http://vimeo.com/38210825")
