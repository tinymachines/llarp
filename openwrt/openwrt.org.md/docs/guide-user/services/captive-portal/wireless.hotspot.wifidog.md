# WiFiDog captive portal (defunct)

WiFiDog is no longer an active project. There has been little or no activity in the project since 2015. The OpenWrt package has not worked correctly since 2015 after an iptables update at that time. No attempt has been made to correct this.

Most of the following links no longer function:

Please read [WiFiDog Captive Portal](https://en.wikipedia.org/wiki/WiFiDog%20Captive%20Portal "https://en.wikipedia.org/wiki/WiFiDog Captive Portal") for a definition of WiFiDog. It is FOSS software used to create wireless hot-spots. It is a next-generation alternative to [NoCat](http://nocat.net/ "http://nocat.net/"). For more information look at the [wifidog FAQ](http://dev.wifidog.org/wiki/FAQ "http://dev.wifidog.org/wiki/FAQ"). [Captive portal](https://en.wikipedia.org/wiki/Captive%20portal "https://en.wikipedia.org/wiki/Captive portal").

- [http://dev.wifidog.org/](http://dev.wifidog.org/ "http://dev.wifidog.org/")
- [http://www.authpuppy.org/](http://www.authpuppy.org/ "http://www.authpuppy.org/")

## Preparation

### Prerequisites

### Required Packages

- iptables-mod-extra
- iptables-mod-ipopt
- kmod-ipt-nat
- iptables-mod-nat-extra
- libpthread

## Installation

[opkg](/docs/guide-user/additional-software/opkg "docs:guide-user:additional-software:opkg")

```
opkg update
opkg install wifidog
vi /etc/wifidog.conf
/etc/init.d/wifidog enable
/etc/init.d/wifidog start
netstat -a
```

You can also run wifidog in foreground/debug mode:

```
wifidog -f -d 7
  -f means to run in foreground (do not become a background daemon)
  -d 7 increases debug output level to the maximum
```

## Configuration

## Start on boot

To enable/disable start on boot:  
`/etc/init.d/wifidog enable` this simply creates a symlink: `/etc/rc.d/S?0??? → /etc/init.d/???`  
`/etc/init.d/wifidog disable` this removes the symlink again

## Administration

Follow instructions on [http://dev.wifidog.org/wiki/doc/install/auth-server](http://dev.wifidog.org/wiki/doc/install/auth-server "http://dev.wifidog.org/wiki/doc/install/auth-server")

## Troubleshooting

## Notes

- The Project Homepage: [http://dev.wifidog.org/](http://dev.wifidog.org/ "http://dev.wifidog.org/")
- [How to offer 2 hotspots with WiFiDog with Kernel 2.4](https://forum.openwrt.org/viewtopic.php?id=24926 "https://forum.openwrt.org/viewtopic.php?id=24926")
