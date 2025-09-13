# Domoticz on OpenWrt

## Introduction

*“Domoticz is a very light weight home automation system that lets you monitor and configure miscellaneous devices, including lights, switches, various sensors/meters like temperature, rainfall, wind, ultraviolet (UV) radiation, electricity usage/production, gas consumption, water consumption and many more. Notifications/alerts can be sent to any mobile device.”*

## Installation

Package was added by this commit: [https://github.com/openwrt/packages/commit/042933714af6440eb38728b5ade18d5d70855ee4](https://github.com/openwrt/packages/commit/042933714af6440eb38728b5ade18d5d70855ee4 "https://github.com/openwrt/packages/commit/042933714af6440eb38728b5ade18d5d70855ee4")

And big update was made by this commit: [https://github.com/openwrt/packages/pull/6091](https://github.com/openwrt/packages/pull/6091 "https://github.com/openwrt/packages/pull/6091")

### Basic Packages

#### Update Packages List

First update your Sources.

```
opkg update
```

#### Required Packages and Installation

Domoticz has define all needed requirements. The size of package is about 9 MB. So just simply install it

```
opkg install domoticz
```

#### Configuration

Configuration file for domoticz is in `/etc/init.d/domoticz` The default domoticz configuration is:

```
domoticz.@domoticz[0]=domoticz
domoticz.@domoticz[0].disabled='1'
domoticz.@domoticz[0].loglevel='1'
domoticz.@domoticz[0].syslog='daemon'
domoticz.@domoticz[0].sslwww='0'
domoticz.@domoticz[0].userdata='/var/lib/domoticz/'
```

### Webinterface

The configuration of Domoticz is done by webinterface on port 8080 e.g `http://192.168.1.1:8080`

To check how it works you can monitor your device. To do this add “Hardware” - Motherboard sensors

[https://www.domoticz.com/wiki/Hardware\_Setup](https://www.domoticz.com/wiki/Hardware_Setup "https://www.domoticz.com/wiki/Hardware_Setup")

### Troubleshooting

The notifications via email are not working because, by default the libcurl library is not compiled with snmp support. The System Alive Checker requires root rights [https://www.domoticz.com/wiki/System\_Alive\_Checker\_(Ping)](https://www.domoticz.com/wiki/System_Alive_Checker_%28Ping%29 "https://www.domoticz.com/wiki/System_Alive_Checker_(Ping)")

## Resources

- \[0] [https://www.domoticz.com/wiki/](https://www.domoticz.com/wiki/ "https://www.domoticz.com/wiki/")
- \[1] [https://www.domoticz.com/forum/](https://www.domoticz.com/forum/ "https://www.domoticz.com/forum/")
