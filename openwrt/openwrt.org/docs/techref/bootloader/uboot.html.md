# Das U-Boot

[Das U-Boot](https://en.wikipedia.org/wiki/Das%20U-Boot "https://en.wikipedia.org/wiki/Das U-Boot") (the universal bootloader), is arguably the richest, most flexible, and most actively developed FOSS [bootloader](/docs/techref/bootloader "docs:techref:bootloader") available. It's released under the GNU GPL and maintained at [http://www.denx.de/wiki/U-Boot/](http://www.denx.de/wiki/U-Boot/ "http://www.denx.de/wiki/U-Boot/").

Uboot can be build with [OpenWrt Buildroot](/docs/guide-developer/toolchain/start "docs:guide-developer:toolchain:start"), Embedded Linux Development Kit, and others. For documentation see [ELDK-4](http://www.denx.de/wiki/DULG/ELDK "http://www.denx.de/wiki/DULG/ELDK") / [ELDK-5](http://www.denx.de/wiki/ELDK-5/WebHome "http://www.denx.de/wiki/ELDK-5/WebHome").

U-Boot version Purpose u-boot-...\_brn Meant to be loaded from brnboot (stock bootloader) as a 2nd stage bootloader into RAM u-boot-...\_nor Meant to be flashed onto flash memory as main bootloader (at 0xB0000000), overwriting orignal bootloader u-boot-...\_ram Meant to be uploaded via UART by serial if nor\_bootloader got bricked, for rescue purposes

## Compilation

1. retrieve source code, patch support for you hardware if not already contained in that mainline version
2. use a [toolchain](https://en.wikipedia.org/wiki/toolchain "https://en.wikipedia.org/wiki/toolchain") of your choice to build

→[http://www.denx.de/wiki/view/DULG/UBootDoesntRunAfterUpgradingMyCompiler](http://www.denx.de/wiki/view/DULG/UBootDoesntRunAfterUpgradingMyCompiler "http://www.denx.de/wiki/view/DULG/UBootDoesntRunAfterUpgradingMyCompiler")

## Configuration

→ [uboot.config](/docs/techref/bootloader/uboot.config "docs:techref:bootloader:uboot.config")  
→ [flashlog](/toh/tp-link/tl-wr1043nd/flashlog "toh:tp-link:tl-wr1043nd:flashlog")

## Documentation

- [ftp://ftp.denx.de/pub/u-boot/](ftp://ftp.denx.de/pub/u-boot/ "ftp://ftp.denx.de/pub/u-boot/") Obtain latest version
- [http://www.denx.de/wiki/U-Boot/Documentation](http://www.denx.de/wiki/U-Boot/Documentation "http://www.denx.de/wiki/U-Boot/Documentation")
  
  - [Das U-Boot Presentation](http://www.denx.de/wiki/U-Bootdoc/Presentation "http://www.denx.de/wiki/U-Bootdoc/Presentation") A short presentation for a quick overview
  - [Das U-Boot online manual](http://www.denx.de/wiki/view/DULG/UBoot "http://www.denx.de/wiki/view/DULG/UBoot") The Manual
  - [FAQ](http://www.denx.de/wiki/DULG/Faq "http://www.denx.de/wiki/DULG/Faq")
- [Blackfin](http://docs.blackfin.uclinux.org/doku.php?id=bootloaders%3Au-boot "http://docs.blackfin.uclinux.org/doku.php?id=bootloaders:u-boot")
- [Porting U-Boot for a new Blackfin device](http://docs.blackfin.uclinux.org/doku.php?id=bootloaders%3Au-boot%3Aporting "http://docs.blackfin.uclinux.org/doku.php?id=bootloaders:u-boot:porting") Blackfin specific, but you can milk this for information
- [U-Boot as coreboot payload](http://blogs.coreboot.org/blog/2011/04/30/u-boot-as-coreboot-payload/ "http://blogs.coreboot.org/blog/2011/04/30/u-boot-as-coreboot-payload/") just for fun

## Das U-Boot Modifications

If somebody writes a patch for the bootloader implementation of a particular device, you will find links to this on the wiki-page for that device. Additionally, we accumulate all the patches written for a particular bootloader on its own page. Hopefully, you can get a better comprehension of the functionality of the bootloader by having a look at them:

- For the Marvell Kirkwood (e.g. [Seagate Dockstar](/toh/seagate/dockstar "toh:seagate:dockstar")) [https://github.com/doozan/uBoot](https://github.com/doozan/uBoot "https://github.com/doozan/uBoot") by Jeff Doozan
- For [Qualcomm Atheros AR9331](/docs/techref/hardware/soc/soc.qualcomm.ar71xx#ar9331 "docs:techref:hardware:soc:soc.qualcomm.ar71xx") [based devices](/docs/techref/hardware/soc/soc.qualcomm.ar71xx#ar9331_based_devices "docs:techref:hardware:soc:soc.qualcomm.ar71xx") (and now also AR9341 and AR9344)
  
  - **U-Boot 1.1.4 modification** by [Piotr Dymacz (pepe2k)](https://forum.openwrt.org/profile.php?id=72549 "https://forum.openwrt.org/profile.php?id=72549")
    
    - started with [http://code.google.com/p/wr703n-uboot-with-web-failsafe/](http://code.google.com/p/wr703n-uboot-with-web-failsafe/ "http://code.google.com/p/wr703n-uboot-with-web-failsafe/")
    - Official repository now on [GitHub](https://github.com/pepe2k/u-boot_mod "https://github.com/pepe2k/u-boot_mod")
    - How to Build ( Github read-me and additional build info ) [pepe2k](/docs/techref/bootloader/pepe2k "docs:techref:bootloader:pepe2k")
    - [OpenWrt forum discussion](https://forum.openwrt.org/viewtopic.php?id=43237 "https://forum.openwrt.org/viewtopic.php?id=43237")
    - An article (in Polish) about one of the first versions of this project on [www.tech-blog.pl](http://www.tech-blog.pl/2013/03/29/zmodyfikowany-u-boot-dla-routerow-tp-link-z-atheros-ar9331-z-trybem-aktualizacji-oprogramowania-przez-www-i-konsola-sieciowa-netconsole/ "http://www.tech-blog.pl/2013/03/29/zmodyfikowany-u-boot-dla-routerow-tp-link-z-atheros-ar9331-z-trybem-aktualizacji-oprogramowania-przez-www-i-konsola-sieciowa-netconsole/")
