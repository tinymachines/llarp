# CUPS Print Server

It is recommended to use [p910nd](/docs/guide-user/services/print_server/p910nd "docs:guide-user:services:print_server:p910nd") non-spooling print server instead of CUPS on a router.

This HowTo provides information on installing and configuring a [Common Unix Printing System](https://en.wikipedia.org/wiki/Common%20Unix%20Printing%20System "https://en.wikipedia.org/wiki/Common Unix Printing System") on OpenWrt.

## Installation on LEDE/OpenWrt 17+ firmware

**There is no pre-built CUPS package for LEDE/OpenWrt 17+**

## Basic instructions to compile CUPS

Obtain and configure a working currently supported buildroot

```
 make menuconfig
 Libraries > [*] libcups
 make V=s
```

Optionally copy ipk's to router and install with opkg.

(see the bottom for further resources)

Opkg methods below are for pre-17 builds and/or after compiling your own packages.

## Preparation

### Prerequisites

1. obtain [usb-installing](/docs/guide-user/storage/usb-installing "docs:guide-user:storage:usb-installing") basic USB support or ([parport](/doc/howto/parport "doc:howto:parport") Parallel Port support)
2. drivers
3. kernel module for USB printers: opkg install kmod-usb-printer
4. Firewall: open ports tcp and udp.

CUPS mandatory uses spooling, which means that the entire print job data gets stored in a buffer (on harddisc or in RAM) before the printing is even started. Dependent of what you want to print, your resources are probably that limited that you should not use CUPS. But of course you can add resources to your hardware, like say connect a harddisc per USB.

1. [usb-drives](/docs/guide-user/storage/usb-drives "docs:guide-user:storage:usb-drives") to mount a filesystem or a SWAP partition. This should massively upgrade your endowment.
2. you cannot mount SWAP over network but you could mount any other filesystem over the network and park the data there, see [filesystem](/doc/howto/server.overview#filesystem "doc:howto:server.overview")

### Required Packages

#### Server (OpenWrt)

Name Version Size in Bytes Description cups 2.2.6 10 315 433 A printer spooling system for devices with USB or LP support.  
[https://www.cups.org/](https://www.cups.org/ "https://www.cups.org/") zlib 1.2.5-1 39 388 Library implementing the deflate compression method libpthread 0.9.32-65 30 717 POSIX thread library libpng 1.2.44-1 128 723 A PNG format files handling library libjpeg 6b-1 61 963 The Independent JPEG Group's JPEG runtime library libstdcpp 4.3.3+cs-65 232 642 GNU Standard C++ Library v3 cups-bjnp 0.5.4-1 11 293 (optional) Description: CUPS backend for the canon printers using the proprietary USB over IP BJNP protocol. This backend allows Cups to print over the network to a Canon printer. It currently supports Cups 1.2 and Cups 1.3 and is designed by reverse engineering.

## Installation

[opkg](/docs/guide-user/additional-software/opkg "docs:guide-user:additional-software:opkg")

```
opkg install cups
vi /etc/cups.conf
If you have external storage, change the CUPS spool directory so that it resides on this storage:  
vi /etc/cups/cupsd.conf and change- RequestRoot /opt/var/spool/cups
. /etc/init.d/cupsd enable
. /etc/init.d/cupsd start
netstat -a
iptables -I INPUT -j ACCEPT -i eth0.1 -p tcp --port ?????
iptables -I INPUT -j ACCEPT -i eth0.1 -p udp --port ?????
```

## Configuration

### CUPSD configuration

Use Cups own configuration Web GUI. If cups is running, you should be able to find it at [http://192.168.1.1:631](http://192.168.1.1:631 "http://192.168.1.1:631") (that is port `631` of your router's own address). The default cups configuration in *Attitude Adjustment* uses the host system authentication mechanism, so in order to log in as Administrator, use the `root` username and its password (the same you use at the Lucy log-in screen).

An alternative to the Web GUI is text file configuration: configure `/etc/cups/cups.conf` according to [man cupsd.conf](http://linux.die.net/man/5/cupsd.conf "http://linux.die.net/man/5/cupsd.conf"). Notice that some configuration files (such as `/etc/cups/printers.conf`) should **not** be edited while cups is running. Many cups text files are meant to be modified by the `lpadmin` command.

#### Permissions Problems

If you have problems with permissions, try to change `/etc/cups/cupsd.conf` to fit your local TCP/IP network:

```
Order Deny,Allow
Deny From All
Allow from 127.0.0.1
Allow from 192.168.1.0/24 #your ip area.
```

##### Toubleshooting: Need drivers uploaded on power up ?

Got an HP Laserjet or similar device that requires the driver to be uploaded to the printer each time it's turned on? See this post [here](https://web.archive.org/web/20230329055348/http://mattie47.com/getting-cups-working-on-openwrt/#comment-12 "https://web.archive.org/web/20230329055348/http://mattie47.com/getting-cups-working-on-openwrt/#comment-12")

### Adding Printers

Notice you can't print a testpage on the local cups, because this would need to have ghostscript installed on your embedded system.

#### USB printers notes and throubleshooting

Backfire: There may be a problem interfacing with USB printers if usb-printers kernel module is also loaded. These conflict with the cups-provided USB support. There are plenty of bugs and one working solution is as follows:

1. Remove usblp support: opkg remove kmod-usb-printer
2. Edit user and group in /etc/cups/cupsd.conf from `User Nobody/Group Nogroup` to `User root/Group root`
3. Change ACL on /usr/lib/cups/backend/usb to 700 (`chmod 700 /usr/lib/cups/backend/usb`). This changes the behaviour of cups, which normally tries to execute the backend through a user account other than root. This forces the backend to run as root from cups.
4. Finally, it should be possible to add printers through the web page [http://host:631/admin](http://host:631/admin "http://host:631/admin") or manually. The USB device name cannot be displayed through lpinfo but can instead be listed by running `/usr/lib/cups/backend/usb` as root.

There is a problem with the permissions on USB printers not being writable by nobody, which is what CUPS expects. An alternative is to make a wrapper backend that executes a sudo script which does `find /proc/bus/usb -type f -exec chmod +rw {} \;`. Point being, there is a permission problem between USB/udev and CUPS preventing USB-printers from working. Also, CUPS is removing support or has a lot of issues currently with usblp support.

In Attitude Adjustment, you just need to change ACL on /usr/lib/cups/backend/usb to 700 (`chmod 700 /usr/lib/cups/backend/usb`). This changes the behaviour of cups, which normally tries to execute the backend through a user account other than root. This forces the backend to run as root from cups, the reason have been said above.

#### Printers must be Shared

In order to use the printers from other clients in your network, the printers must be *shared*. In the Web GUI, when adding a printer you should mark the check box `“Share This Printer”`.

#### Adding drivers / PPDs

If you have a special [PostScript Printer Description (ppd)](https://en.wikipedia.org/wiki/PostScript%20Printer%20Description "https://en.wikipedia.org/wiki/PostScript Printer Description")-file for your printer, copy it to `/usr/share/cups/model/` and restart `cupsd`. Cups will install it in `/etc/cups/ppd` and you can choose it via the web interface. ([http://192.168.1.1:631](http://192.168.1.1:631 "http://192.168.1.1:631")). You can also upload a PPD file through the web interface. **The trick here is that without Ghostscript you are unlikely to get on-router file conversion to work**.

You really get two alternatives:

1. use the printer with a raw queue, and set drivers (i.e. PPD) in your computer/laptop. In this case, the file conversion and preparation will be done on your computer/laptop (as opposed to on the router)
2. add printing drivers to your router. Notice that the usual “Linux printing drivers/filters” stack requires more space than a normal router has. If you've [extended your root space](/docs/guide-user/additional-software/extroot_configuration "docs:guide-user:additional-software:extroot_configuration") and are willing to do some [cross compilation](/docs/guide-developer/toolchain/crosscompile "docs:guide-developer:toolchain:crosscompile"), you can try these unofficial packages [openwrt-printing-packages](https://github.com/FranciscoBorges/openwrt-printing-packages "https://github.com/FranciscoBorges/openwrt-printing-packages")

#### MacOS X tip

Configure your extended printer settings. If you use the standard printer settings and add an IPP printer, MacOS X will add after the server adress /ipp . But this class etc. does not exist on your cupsd.

### Client configuration

This page has good notes about configuring clients for Linux, Windows and Mac OSX:

[configure.the.clients.for.printing](/docs/guide-user/services/print_server/p910nd.server#configuretheclientsforprinting "docs:guide-user:services:print_server:p910nd.server").

The main point is that if you added printers and marked them as shared, all these operating system should be able to find it as a network printer.

## Start on boot

To enable/disable start on boot:

`/etc/init.d/cupsd enable` (it creates a symlink: `/etc/rc.d/S??cupsd → /etc/init.d/cupsd`)

`/etc/init.d/cupsd disable` (this removes the symlink).

## Administration

Use Cups own Web GUI. If cups is running, you should be able to find it at [http://192.168.1.1:631](http://192.168.1.1:631 "http://192.168.1.1:631") (that is port 631 of your router's own address). If you did not change its configuration, to log in to Administration use the `root` username and its password.

Alternatively you can login to OpenWrt and edit `/etc/cups/cups.conf`. Restart cupsd.

### Log Messages

Check [cupsd](/docs/guide-user/perf_and_log/log.messages#cupsd "docs:guide-user:perf_and_log:log.messages") to learn what they mean.

## Notes

- Project Homepage [http://www.cups.org/](http://www.cups.org/ "http://www.cups.org/")
- Legacy Official Repo [https://github.com/Gr4ffy/lede-cups](https://github.com/Gr4ffy/lede-cups "https://github.com/Gr4ffy/lede-cups")
- hplip-common, plip-sane
- [Notes on possibilities of using drivers](https://forum.openwrt.org/viewtopic.php?pid=135838#p135838 "https://forum.openwrt.org/viewtopic.php?pid=135838#p135838") broken-wulfy23-300719
- Package feed for cross-compiling the whole Linux printing stack for your router [https://github.com/FranciscoBorges/openwrt-printing-packages](https://github.com/FranciscoBorges/openwrt-printing-packages "https://github.com/FranciscoBorges/openwrt-printing-packages")

#### OpenWrt User posts about installing CUPS

- [http://mattie47.com/getting-cups-working-on-openwrt/](http://mattie47.com/getting-cups-working-on-openwrt/ "http://mattie47.com/getting-cups-working-on-openwrt/")
- [http://www.newren.com.au/ibbs/forum.php?mod=viewthread&amp;tid=392](http://www.newren.com.au/ibbs/forum.php?mod=viewthread&tid=392 "http://www.newren.com.au/ibbs/forum.php?mod=viewthread&tid=392") broken-wulfy23-040519
- [http://9m2tpt.blogspot.co.nz/2012/01/cups-hl-2140-usb-printer-wzr-hp-g300nh.html](http://9m2tpt.blogspot.co.nz/2012/01/cups-hl-2140-usb-printer-wzr-hp-g300nh.html "http://9m2tpt.blogspot.co.nz/2012/01/cups-hl-2140-usb-printer-wzr-hp-g300nh.html")
