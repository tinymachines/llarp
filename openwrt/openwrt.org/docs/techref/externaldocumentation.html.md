# External Documentation

OpenWrt is a Linux distribution and comes with own documentation, but much documentation is provided upstream, by the creators of the components.

## Bootloader

### Das U-Boot (GPLv2)

[http://www.denx.de/wiki/U-Boot/](http://www.denx.de/wiki/U-Boot/ "http://www.denx.de/wiki/U-Boot/")

### RedBoot (modified GPL)

RedBoot (Red Hat Embedded Debug and Bootstrap firmware) [http://ecos.sourceware.org/redboot/](http://ecos.sourceware.org/redboot/ "http://ecos.sourceware.org/redboot/")

### CFE (BSD like)

CFE (Common Firmware Environment) is a firmware developed by Broadcom. [http://www.broadcom.com/support/communications\_processors/downloads.php#cfe](http://www.broadcom.com/support/communications_processors/downloads.php#cfe "http://www.broadcom.com/support/communications_processors/downloads.php#cfe")

## Linux Kernel (GPLv2)

This is the Homepage of the Linux Kernel: [http://www.kernel.org/](http://www.kernel.org/ "http://www.kernel.org/").

## GNU/Linux Drivers (diverse)

While all drivers belong into the kernel, official Wikis additionally exist for wireless and sound:

- [http://wireless.kernel.org/](http://wireless.kernel.org/ "http://wireless.kernel.org/")
- [http://alsa-project.org/main/index.php/Main\_Page](http://alsa-project.org/main/index.php/Main_Page "http://alsa-project.org/main/index.php/Main_Page")

## C standard library

### µClibc (LGPL)

At the moment OpenWrt uses µClibc as C standard library. [http://www.uclibc.org/](http://www.uclibc.org/ "http://www.uclibc.org/")

### EGLIBC (LGPL)

### newlib (LGPL)

### diet libc (GPLv2)

The project homepage [http://www.fefe.de/dietlibc/](http://www.fefe.de/dietlibc/ "http://www.fefe.de/dietlibc/") and some [FAQ](http://www.fefe.de/dietlibc/FAQ.txt "http://www.fefe.de/dietlibc/FAQ.txt").

## Opkg (GPLv2)

OpenWrt can be seen as a Linux Distribution for embeded devices. It does bring a Package Manager: [http://code.google.com/p/opkg/](http://code.google.com/p/opkg/ "http://code.google.com/p/opkg/")

## BusyBox (GPLv2)

OpenWRT uses [BusyBox](http://www.busybox.net/ "http://www.busybox.net/") to implement the shell environment and most of the usual Unix commands. Instead of having a collection of separate binaries, BusyBox condenses them into one. Executables like vi, ls and grep are merely symbolic links to the BusyBox binary. [BusyBox Command Help](http://busybox.net/downloads/BusyBox.html "http://busybox.net/downloads/BusyBox.html")

## Netfilter (GPLv2+)

iptables, ip6tables, ebtables: [http://www.netfilter.org/](http://www.netfilter.org/ "http://www.netfilter.org/")

## Dropbear (MIT-style license)

OpenWrt prefers [http://matt.ucc.asn.au/dropbear/dropbear.html](http://matt.ucc.asn.au/dropbear/dropbear.html "http://matt.ucc.asn.au/dropbear/dropbear.html") over openssl-daemon because of its smaller footprint.

## Dnsmasq (GPL)

In order to handle various OpenWrt configurations, the dnsmasq init script is quite complex. Documentation on all the options passed to dnsmasq is available. [Dnsmasq manual](http://www.thekelleys.org.uk/dnsmasq/docs/dnsmasq-man.html "http://www.thekelleys.org.uk/dnsmasq/docs/dnsmasq-man.html")

## Samba (GPLv3)

Official documentation: [http://www.samba.org/samba/docs/](http://www.samba.org/samba/docs/ "http://www.samba.org/samba/docs/")

## Web servers

### µHTTPd (New BSD License)

Since 10.03 'Backfire' OpenWrt utilizes µHTTPd instead of httpd included in Busybox. [https://dev.openwrt.org/browser/trunk/package/uhttpd/](https://dev.openwrt.org/browser/trunk/package/uhttpd/ "https://dev.openwrt.org/browser/trunk/package/uhttpd/") (install `uhttpd`)

### httpd (Busybox) (GPLv2)

[httpd](http://www.busybox.net/downloads/BusyBox.html "http://www.busybox.net/downloads/BusyBox.html") (recompile busybox with this included)

### lighttpd (revised BSD)

Currently used by the X-Wrt project. [lighttpd](http://www.lighttpd.net/ "http://www.lighttpd.net/") (install `lighttpd` and mods)

### mini-httpd (GPLv3+)

[mini-httpd](http://www.nongnu.org/mini-httpd/ "http://www.nongnu.org/mini-httpd/") (install `mini-httpd` and mods)

### Audio Servers

- [http://pulseaudio.org/](http://pulseaudio.org/ "http://pulseaudio.org/")
