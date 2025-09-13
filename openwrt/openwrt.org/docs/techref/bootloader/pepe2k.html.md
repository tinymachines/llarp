# pepe2k-u-boot\_mod

U-Boot 1.1.4 modification for routers. Github : [https://github.com/pepe2k/u-boot\_mod](https://github.com/pepe2k/u-boot_mod "https://github.com/pepe2k/u-boot_mod")

### Introduction

In short, this project is a deep modification of U-Boot 1.1.4 sources, mostly from TP-Link, but some code fragments were taken also from D-Link, Netgear, ZyXEL and Belkin. All these companies are using SDK from Qualcomm/Atheros which includes modified version of U-Boot 1.1.4.

The concept for this project came from another U-Boot modification, dedicated to a small and very popular TP-Link router - model TL-WR703N, which includes web fail safe mode: wr703n-uboot-with-web-failsafe. I was using it and decided to make my own version, which could have some improvements, additional capabilities, support for different models and work with all modern web browsers.

First version of this modification was introduced on OpenWrt forum in this thread, at the end of March 2013 and was dedicated only for TP-Link routers with Atheros AR9331 SoC. Now, it supports also models from different manufacturers, devices with Atheros AR934x, Qualcomm Atheros QCA953x, Qualcomm Atheros QCA955x and other (in the near future Qualcomm Atheros QCA956x and MediaTek MT762x) are under development.

You can find some information about previous versions of this project also on my blog, in [this article (web archive)](https://web.archive.org/web/20210731175218/http://www.tech-blog.pl/2013/03/29/zmodyfikowany-u-boot-dla-routerow-tp-link-z-atheros-ar9331-z-trybem-aktualizacji-oprogramowania-przez-www-i-konsola-sieciowa-netconsole/ "https://web.archive.org/web/20210731175218/http://www.tech-blog.pl/2013/03/29/zmodyfikowany-u-boot-dla-routerow-tp-link-z-atheros-ar9331-z-trybem-aktualizacji-oprogramowania-przez-www-i-konsola-sieciowa-netconsole/"). It is in Polish, but Google Translator will help you to understand it.

### Bootloader Access

**Web server**

The most important change is an inclusion of a web server, based on uIP 0.9 TCP/IP stack. It allows to upgrade firmware, U-Boot and ART (Atheros Radio Test) images, directly from your web browser, without need to access serial console and running a TFTP server. You can find similar firmware recovery mode, also based on uIP 0.9 TCP/IP stack, in D-Link routers.

Web server contains 7 pages: index.html (allows to upgrade firmware image, screenshot below) uboot.html (allows to upgrade U-Boot image) art.html (allows to upgrade ART image) flashing.html 404.html fail.html style.css

**Network Console** Second, very useful modification is a network console (it is a part of original U-Boot sources, but none of the manufacturers included it). It allows you to communicate with U-Boot console over the Ethernet, using UDP protocol (default UDP port: 6666, router IP: 192.168.1.1).

### How to build/compile

- Build toolchain for your device, while building your firmware
- Find the toolchain at /home/openwrt/bin/target/&lt;arch&gt;/OpenWrt-Toolchain-*
- Download repo git clone [https://github.com/pepe2k/u-boot\_mod](https://github.com/pepe2k/u-boot_mod "https://github.com/pepe2k/u-boot_mod") in the same build dir /home/openwrt/
- Extract u-boo-mod and make directory “toolchain” inside u-boot\_mod
- Extract /home/openwrt/bin/target/&lt;arch&gt;/OpenWrt-Toolchain-* to above u-boot\_mod/toolchain/ directory
- cd to u-boot-mod
- “Makefile” here contains all names of the supported board
  
  - Edit the path of your u-boot-mod at
    
    - export BUILD\_TOPDIR = “/home/openwrt/u-boot-mod”
  - Edit the Toolchain path
    
    - export TOOLCHAIN\_DIR:=$(BUILD\_TOPDIR)/toolchain
    - export PATH:=$(TOOLCHAIN\_DIR)/bin:$(PATH)
  - Make sure your board is present in this file; e.g. tp-link\_tl-mr10u\_v1
- cd u-boot, is another directory inside u-boot-mod; contains another Makefile
- vi Makefile
- This Makefile is important contains commands for final board build; e.g. #@$(call config\_init,board-name,hostname,flash size,reset gpio,1 if reset button is active low,SOC)
- You can edit flashsize and gpio
- cd out from u-boot
- make &lt;target board&gt;; e.g. make tp-link\_tl-mr10u\_v1
- get your compiled bootloader in bin/

### Credits And Contributors

Thanks to M-K O'Connell for donating a router with QCA9563

Thanks to Krzysztof M. for donating a TL-WDR3600 router

Thanks to pupie from OpenWrt forum for his great help

Thanks for all donators and for users who contributed in code development

Github : [https://github.com/pepe2k/u-boot\_mod/graphs/contributors](https://github.com/pepe2k/u-boot_mod/graphs/contributors "https://github.com/pepe2k/u-boot_mod/graphs/contributors")
