# saned Scanner Server

This page attempts to document how to get a simple USB scanner working and accessible via network by using [The SANE project](http://www.sane-project.org/ "http://www.sane-project.org/").

## Requirements

1. [usb-installing](/docs/guide-user/storage/usb-installing "docs:guide-user:storage:usb-installing") (or support for the parallel port, if you have a parallel port scanners)
2. install the right backend supporting your scanner
3. xinetd installed or alternatively manually starting up saned

### USB port

Note: I'm having a printer-scanner, which is why the “scanner” is recognized as a printer. I'm not actually sure, if this is needed for scanning functionality!

```
opkg update
opkg install kmod-usb-printer
```

Now plug in scanner, run `dmesg` and look for lines similar to the following ones:

```
hub.c: new USB ice 01:02.0-1, assigned address 2
printer.c: usblp0: USB Bidirectional printer  2 if 0 alt 0 proto 2 vid 0x04A9 pid 0x1094
usb.c: USB disconnect on ice 01:02.0-1 address 2
hub.c: new USB ice 01:02.0-1, assigned address 3
printer.c: usblp1: USB Bidirectional printer  3 if 0 alt 0 proto 2 vid 0x04A9 pid 0x1094
```

### Parallel port

In case you have a parallel port scanner, you will need this:

```
opkg update
opkg install kmod-lp
```

Check the output of the `dmesg`. If there is a device node `/dev/printers/0` then the installation succeeded.

**`TIP:`** p910nd is reported as working with some noname USB-to-Parport adapter/converter as well; maybe the same is true for some scanners?

### Install xinetd

Xinet makes possible to run saned only when the port is accessed via network. Because we're lazy, let's go trough this route. Install xinetd (if not already installed):

```
opkg install xinetd
```

## Installation

### Command line

At minimum, we need saned and a working backend. [The SANE project has a partial list of supported scanners](http://www.sane-project.org/sane-backends.html#SCANNERS "http://www.sane-project.org/sane-backends.html#SCANNERS"). If you are not sure, what backend you need, xerox\_mfp is a good starting point.

Installing sane-all will presumably pull in all backends, but usually this is not needed and takes up unnecessary space. Sane-frontends is not strictly needed, but recommended for testing/troubleshooting as it includes scanimage. Scanimage will also tell you, what frontend it uses when/if it finds your scanner, so if unsure, one could install -all and remove the unneeded backends afterwards.

[opkg](/docs/guide-user/additional-software/opkg "docs:guide-user:additional-software:opkg")

Basis-system

```
opkg update
opkg install sane-daemon 
```

Scanner

```
opkg install sane-xerox_mfp
#if you have a xerox scanner
opkg install sane-plustek
#example for Canon lide 20 (canon use sometimes plustek hardware) 
```

all availble scanner can be install with

```
opkg install sane-backends-all
```

[package: sane-backends-all](/packages/pkgdata/sane-backends-all "packages:pkgdata:sane-backends-all") there are also list of all avaible single scanner package

Optional

```
opkg install sane-frontend
```

## (Optional): testing the scanner

Run this on the router to see if the scanner is found and working :

```
scanimage -L
```

If you get this:

```
No scanners were identified. If you were expecting something different,
check that the scanner is plugged in, turned on and detected by the
sane-find-scanner tool (if appropriate). Please read the documentation
which came with this software (README, FAQ, manpages).
```

You most probably do not have the right backend installed. Please try again after installing the right backend. You should get something similar to this:

```
device `xerox_mfp:libusb:002:003' is a SAMSUNG ORION multi-function peripheral
```

Presumably you could try to brute-force, install all backends and then remove them as scanimage will tell you which backend it is using if/when it finds your scanner.

## Configuration

### Use xinetd to start saned

sane-daemon should have come with a configuration file, enable it in /etc/xinetd.d/sane-port :

```
# default: off
# description: The saned provides scanner service via the network.  \
#	Applications like kooka, xsane or xscanimage can use the remote \
#	scanner. 
service sane-port
{
	socket_type = stream
	port        = 6566
	wait        = no
	user        = saned
	group       = scanner
	server      = /usr/sbin/saned
	disable     = no
}
```

(i.e. change disable = yes to no)

### Start saned without xinetd

saned is already a deamon by default

you can start saned with rc.local

```
saned -a
```

The -a flag requests that saned run in standalone daemon mode. In this mode, saned will detach from the console and run in the background, listening for incoming client connections; inetd is not required for saned operations in this mode. If the optional username is given after -a , saned will drop root privileges and run as this user (and group).

[saned manpage](https://manpages.ubuntu.com/manpages/xenial/man8/saned.8.html "https://manpages.ubuntu.com/manpages/xenial/man8/saned.8.html")

### Enable saned to be accessible from the LAN

Put your subnet in `/etc/sane.d/saned.conf` :

```
192.168.1.1/24
```

**TODO:** IPv6 LAN addressing for those who need it?

### Firewall rules

**TODO:** Placeholder. Add examples here to open port 6566 if closed.

### Zeroconf

AirSane exposes a sane scanner over AirScan/eSCL, which is available by default on Windows and macOS. See [https://github.com/cmangla/AirSane-openwrt](https://github.com/cmangla/AirSane-openwrt "https://github.com/cmangla/AirSane-openwrt").

## Access from your computer (client) on the network

You probably want to access the scanner from some client software.

### Linux

If you are using Linux, enable saned on all your computers you want to access the scanner from, and add your router IP in `/etc/sane.d/net.conf` on **the client machine** (if you have name resolving working on your LAN, presumably you can also use your router name here).

After adding the IP address, running `scanimage -L` on the client should produce something like this:

```
device 'net:192.168.1.1:xerox_mfp:libusb:002:003' is a SAMSUNG ORION multi-function peripheral
```

Your scanner is now ready to use!

### OS X, Windows and other OSes

The SANE project has [a list of frontends (applications)](http://www.sane-project.org/sane-frontends.html "http://www.sane-project.org/sane-frontends.html"), which includes a few choices for Windows and a choice for OS X. How to use these might be out of scope on this Wiki, but feel free to add links here to tips and right documentation. One thing worth mentioning is that at least on Linux, LibreOffice can use sane backend.

**TODO:** find out if LibreOffice requires a local running saned, or is it usable without one, and us such usable OOTB for a saned running somewhere on the network?

## Troubleshooting

- Run `scanimage -L` on the router, if it does not find your scanner, you need to solve this first
- If scanimage does not find your scanner, install `sane-all` and try again?
- Run `scanimage -L` on your client (Linux), it should find the scanner. If it doesn't, but your router does, the saned on the client is not configured correctly
