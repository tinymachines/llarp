# EasyCwmp (CPE WAN Management Protocol daemon)

EasyCwmp project is a client implementation of [TR-069](http://en.wikipedia.org/wiki/TR-069 "http://en.wikipedia.org/wiki/TR-069") for OpenWrt. Code is licensed under GPL 2 and can be accessed at [www.easycwmp.org](http://www.easycwmp.org "http://www.easycwmp.org")

EasyCwmp is developed by PIVA Software.The aim of this project is to be fully compliant with the TR069 CWMP standard.

## EasyCwmp Presentation in Broadband World Forum

## Compliant Standards

- TR-069: CPE WAN Management Protocol v1.1
- TR-098: Internet Gateway Device version 1 (Data Model for TR-069)
- TR-181: Device version 2.
- TR-104: Provisioning Parameters for VoIP CPE version 2
- TR-106: Data Model Template for TR-069-Enabled Devices
- TR-111: Applying TR-069 to Remote Management of Home Networking Devices

## EasyCwmp design

The EasyCwmp design includes 2 parts:

- EasyCwmp core: it includes the TR069 CWMP engine and it is in charge of communication with ACS server. It is developed with C.
- EasyCwmp DataModel: it includes the DATAModel of TR-06 and it is compliant to some DataModel standards such as TR-098, TR-181, TR-104, ...

The key design goal is to separate the CWMP method execution from the CWMP engine. That makes easy to add and test new features.

DataModel is developped with shell as free solution and with C as commercial solution.

## Benefits

- Easy to update the DataModel parameters thanks to the DataModel solution design.
- Easy to install on Linux systems and to port on POSIX systems thanks to the design flexibility.
- Easy to use thanks to the availability of a good documentation.
- Supports all required TR-069 methods.
- Supports integrated file transfer (HTTP, HTTPS, FTP).
- Supports SSL.
- Supports IPv6.

## Interoperability

- ACSLite (Commercial ACS from Netmania)
- tGem (Commercial ACS from Tilgin)
- Open ACS/LibreACS (open source ACS)
- GenieACS (open source ACS)
- FreeACS (open source ACS)

## Install

#### EasyCwmp

EasyCwmp is mainly developed and tested with OpenWRT Linux platform.

Download:

Download the easycwmp-openwrt-{x}.{y}.{z}.tar.gz and then copy it to your /path/to/openwrt/package/

```
  cd /path/to/openwrt/package/
  tar -xzvf easycwmp-openwrt.tar.gz
  cd ..
```

Build as built-in

```
  make menuconfig   #(And then select the package as <*>)
  make
```

Build as package:

```
  make menuconfig   #(And then select the package as <M>)
  make package/easycwmp/compile
```

Install:

Build as built-in: install your OpenWRT system in your device according to the OpenWRT manuals and then start your system and you will get easycwmp running automatically

Build as package: copy the package to the OpenWRT system and then install it with:

```
  opkg install
```

And then run it with:

```
  /etc/init.d/easycwmpd start
```

or run it with:

```
  /etc/init.d/easycwmpd boot
```

Note: If you run easycwmpd with start command then it will send inform to the ACS containing “2 PERIODIC” event and send GetRPCMethods to the ACS. And if you run easycwmpd with boot command then it will send inform to the ACS containing “1 BOOT” event.

Note: A third party application could trigger EasyCwmp daemon to send notify (inform with value change event) by calling the command:

```
  ubus call tr069 notify
```

If the EasyCwmp daemon receive the ubus call notify then it will check if there is a value changed of parameters with notification not equal to 0

#### microxml

If you got any problem related to libmicroxml when building EasyCwmp in OpenWRT, then you can use the following libmicroxml package:

```
  cd /path/to/openwrt/package/
  wget http://easycwmp.org/download/libmicroxml.tar.gz
```
