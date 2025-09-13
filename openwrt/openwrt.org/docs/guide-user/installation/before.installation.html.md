# FAQ before installing OpenWrt

## Hardware

### Which router should I buy?

1. Please see the [buyerguide](/toh/buyerguide "toh:buyerguide") for features you could be looking for.
2. Please decide yourself which ones are important to *you*.
3. Then ask in the OpenWrt Forum (or anywhere else) for personal recommendations.

### Will OpenWrt run on ...?

Please check [current TableOfHardware](/toh/start "toh:start") for the list of supported devices.

## Software

### How do I get started?

The [beginner's guide](/doc/howto/user.beginner "doc:howto:user.beginner") should hook you up.

### How can I obtain OpenWrt firmware images?

→ [downloads](/downloads "downloads")

### What is the difference between the different image formats?

- a **factory image** is one built for the bootloader flasher or stock software flasher
- a **sysupgrade image** (previously named trx image) is designed to be flashed from within openwrt itself

The two have the same content, but a factory image would have extra header information or whatever the platform needs. Generally speaking, the factory image is to be used with the OEM GUI or OEM flashing utilities to convert the device to OpenWrt. After that, use the sysupgrade images.

- a **uImage** is a [tagged](http://docs.blackfin.uclinux.org/doku.php?id=bootloaders%3Au-boot%3Auimage "http://docs.blackfin.uclinux.org/doku.php?id=bootloaders:u-boot:uimage") linux image expected by the u-boot loader
- a **tftp image** is XXX
- a **vmlinux.bin image** is XXX
- a **vmlinux.elf “image”** is XXX

### Which OpenWrt version should I choose?

→ [Choosing an Openwrt version](/downloads "downloads")

### How do I install OpenWrt?

→ [generic.flashing](/docs/guide-user/installation/generic.flashing "docs:guide-user:installation:generic.flashing")

### How often can I write on the flash chip?

Flash devices can be written to, at minimum, anywhere between 100,000 and 1,000,000 times (according to the manufacturers). Keep in mind we have a [normal distribution](https://en.wikipedia.org/wiki/normal%20distribution "https://en.wikipedia.org/wiki/normal distribution") and also, that Flash never ever just stops working, but merely distinct blocks do. I.e. you won't be able to write to them any longer, but you should be able to still read them.

### How do I compile OpenWrt?

Start here → [toolchain](/docs/guide-developer/toolchain/start "docs:guide-developer:toolchain:start")

### How do I compile all OpenWrt packages?

```
CONFIG_ALL=y + make V=99 IGNORE_ERRORS=m
```

* * *

## Other questions

### Why is everything so modular?

Because everything light-weight tends to be highly modular. Compare: [lightweight tube](http://upload.wikimedia.org/wikipedia/commons/3/3d/Boeing_747_Le_Bourget_FRA_002.jpg "http://upload.wikimedia.org/wikipedia/commons/3/3d/Boeing_747_Le_Bourget_FRA_002.jpg") vs. [heavy weight tube](http://upload.wikimedia.org/wikipedia/commons/2/2b/Tank_car2090.jpg "http://upload.wikimedia.org/wikipedia/commons/2/2b/Tank_car2090.jpg")

### I do not like CLI (command-line interface)

There are claims all over the web, that OpenWrt can only be handled by command-line. There is a beginners guide available:[CLI](/docs/guide-user/base-system/user.beginner.cli "docs:guide-user:base-system:user.beginner.cli").

There is one WebUIs available LuCI, LuCI2 is in development.

Older versions of OpenWrt could support [X-Wrt and Gargoyle](/docs/guide-user/luci/webinterface.overview "docs:guide-user:luci:webinterface.overview") The [X Window System](https://en.wikipedia.org/wiki/X%20Window%20System "https://en.wikipedia.org/wiki/X Window System") feed is probably broken/untested and outdated for a long time (status: BB, 2014)

### What is the difference between brcm-2.4 and brcm47xx?

- *brcm-2.4*: heavily modified Linux kernel version 2.4, `wl` (or wl-mimo) proprietary driver, `nas` authentificator, `wlc` control utility
- *brcm47xx*: vanilla Linux kernel version 2.6/3, `b43` reverse engineered FOSS driver, `wpad` (hostapd + wpa\_supplicant), standard linux utilites (`iw`, `iwconfig`, etc.)

It is reported as still debatable which wireless driver is better for stability and performance. brcm-2.4 is still available in the latest OpenWrt stable, but has been abandoned in trunk as of Rxxxxx.

**Note:** At least as of 10.3.1 stable, it is possible to build 2.6 kernel with proprietary Broadcom drivers. No precompiled images have been posted yet though. If your target is brcm47xx, it will build 2.6 kernel, no matter what the wireless drivers are. --- *sup 2012/05/07 11:53*

**brcm47xx stability issue** It has been [reported](https://dev.openwrt.org/ticket/7552 "https://dev.openwrt.org/ticket/7552") that brcm47xx has issues when router is under heavy load.

### How to enable athdebug and debug madwifi?

From `package/madwifi/Makefile`:

```
ifdef CONFIG_MADWIFI_DEBUG
  MADWIFI_APPLETS += athdebug 80211debug
endif
```

So first enable the “Advanced configuration options (for developers)” item, then navigate to the kmod-madwifi submenu and tick “Enable compilation of debugging features” on or add/replace “CONFIG\_DEVEL=y” plus “CONFIG\_MADWIFI\_DEBUG=y” manually in .config
