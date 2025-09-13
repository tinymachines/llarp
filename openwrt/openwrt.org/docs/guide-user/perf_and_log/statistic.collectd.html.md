# Collectd

This article relies on the following:

- Accessing [web interface](/docs/guide-quick-start/walkthrough_login "docs:guide-quick-start:walkthrough_login") / [command-line interface](/docs/guide-quick-start/sshadministration "docs:guide-quick-start:sshadministration")
- Managing [configs](/docs/guide-user/base-system/uci "docs:guide-user:base-system:uci") / [packages](/docs/guide-user/additional-software/managing_packages "docs:guide-user:additional-software:managing_packages") / [services](/docs/guide-user/base-system/managing_services "docs:guide-user:base-system:managing_services") / [logs](/docs/guide-user/base-system/log.essentials "docs:guide-user:base-system:log.essentials")

## Introduction

[collectd](/packages/pkgdata/collectd "packages:pkgdata:collectd") is a small daemon which collects system information periodically and provides mechanisms to store the values in a variety of ways.

## Installation

### Web interface instructions

1. Install the packagee [luci-app-statistics](/packages/pkgdata/luci-app-statistics "packages:pkgdata:luci-app-statistics").
2. Configure collectd using the tools in **Statistics → Setup** section of the LuCI web interface.

By default, collectd saves its RRD data in `/tmp/rrd` which is a RAM-based directory, so its contents will be lost when the device reboots. To save the data across power failure/restarts, consider [adding an external USB Drive](/docs/guide-user/storage/usb-drives-quickstart "docs:guide-user:storage:usb-drives-quickstart") and then configuring collectd to save the data to that new storage. Do this using the **Output plugins → RRDTool** tab in LuCI, configure the *Storage directory*, or the *DataDir* command of the `<Plugin rrdtool>` section of the collectd configuration file at `/etc/collectd.conf`.

### Command-line instructions

```
opkg update
opkg install collectd
vi /etc/collectd.conf
/etc/init.d/collectd restart
```

## Examples

### Minimal

```
# /etc/collectd.conf
BaseDir "/var/lib/collectd"
PIDFile "/var/run/collectd.pid"
Interval 30
ReadThreads 2
```

### Simple

```
opkg update
opkg install collectd-mod-rrdtool collectd-mod-processes collectd-mod-interface
 
# /etc/collectd.conf
BaseDir "/var/run/collectd"
Include "/etc/collectd/conf.d"
PIDFile "/var/run/collectd.pid"
PluginDir "/usr/lib/collectd"
TypesDB "/usr/share/collectd/types.db"
Interval 30
ReadThreads 2
 
LoadPlugin cpu
LoadPlugin interface
LoadPlugin load
LoadPlugin memory
LoadPlugin processes
LoadPlugin rrdtool
LoadPlugin uptime
 
<Plugin interface>
	IgnoreSelected false
	Interface eth0
	Interface eth1
	Interface eth2
</Plugin>
 
<Plugin processes>
	Process uhttpd
	Process dnsmasq
	Process dropbear
</Plugin>
 
<Plugin rrdtool>
	DataDir "/tmp/rrd"
	RRARows 100
	RRASingle true
	RRATimespan 3600
	RRATimespan 86400
	RRATimespan 604800
	RRATimespan 2678400
	RRATimespan 31622400
</Plugin>
```

### Advanced

```
opkg update
opkg install collectd-mod-rrdtool collectd-mod-iptables collectd-mod-netlink
 
# /etc/collectd.conf
BaseDir "/var/lib/collectd"
PIDFile "/var/run/collectd.pid"
Interval 30
ReadThreads 2
 
LoadPlugin iptables
LoadPlugin netlink
LoadPlugin rrdtool
 
# Use only iptables filter
<Plugin iptables>
	chain mangle TC_USER1
	chain mangle TC_USER2
	chain mangle TC_USER3
</Plugin>
 
<Plugin netlink>
	VerboseInterface pppoe-dsl
	QDisc "pppoe-dsl" "hfsc-1:0"
	Class "pppoe-dsl" "hfsc-1:1"
	Class "pppoe-dsl" "hfsc-1:10"
	Class "pppoe-dsl" "hfsc-1:101"
	Class "pppoe-dsl" "hfsc-1:102"
	Class "pppoe-dsl" "hfsc-1:103"
	Class "pppoe-dsl" "hfsc-1:20"
	Class "pppoe-dsl" "hfsc-1:201"
	Class "pppoe-dsl" "hfsc-1:202"
	Class "pppoe-dsl" "hfsc-1:203"
	Class "pppoe-dsl" "hfsc-1:30"
	Class "pppoe-dsl" "hfsc-1:301"
	Class "pppoe-dsl" "hfsc-1:302"
	Class "pppoe-dsl" "hfsc-1:303"
	Class "pppoe-dsl" "hfsc-1:40"
	Class "pppoe-dsl" "hfsc-1:50"
</Plugin>
 
<Plugin rrdtool>
	DataDir "/mnt/storage/rrd"
	CacheTimeout 120
	CacheFlush 900
</Plugin>
```

### Ping check

A simple ping check by IP address.

```
opkg update
opkg install luci-app-statistics collectd-mod-ping
uci set luci_statistics.collectd_network.enable="1"
uci set luci_statistics.collectd_ping.enable="1"
uci set luci_statistics.collectd_ping.Hosts="8.8.8.8 8.8.4.4"
uci commit luci_statistics
/etc/init.d/luci_statistics restart
/etc/init.d/collectd restart
/etc/init.d/rpcd restart
```

Ping check by domain name. Note that collectd [always prefers IPv6](https://forum.openwrt.org/t/collectd-network-plugin-getaddrinfo-failed-system-error/90546 "https://forum.openwrt.org/t/collectd-network-plugin-getaddrinfo-failed-system-error/90546") if not specified otherwise.

```
uci set luci_statistics.collectd_ping.Hosts="openwrt.org"
uci set luci_statistics.collectd_ping.AddressFamily="ipv4"
uci commit luci_statistics
/etc/init.d/luci_statistics restart
```

Navigate to **LuCI → Statistics → Graphs → Ping** to see visualization results.

## Graphs and visualization

collectd is strictly a statistics collection service and does not provide any way to visualize the gathered data. To enable visualization of the gathered data, install and configure the packages [luci-app-statistics](/packages/pkgdata/luci-app-statistics "packages:pkgdata:luci-app-statistics") and [collectd-mod-rrdtool](/packages/pkgdata/collectd-mod-rrdtool "packages:pkgdata:collectd-mod-rrdtool"). The statistics gathered by collectd should then be viewable in the LuCI web interface.

## Persistent data storage

- [Script for periodic data backup](https://forum.openwrt.org/t/save-luci-statistics-collectd-across-reboot/75785/16?u=tmomas "https://forum.openwrt.org/t/save-luci-statistics-collectd-across-reboot/75785/16?u=tmomas")
- [Where data can be stored and where not](https://forum.openwrt.org/t/collectd-a-good-place-to-save-rrd-file/105113/2?u=tmomas "https://forum.openwrt.org/t/collectd-a-good-place-to-save-rrd-file/105113/2?u=tmomas")

## References

- [https://www.collectd.org/](https://www.collectd.org/ "https://www.collectd.org/")
- [collectd(1)](http://collectd.org/documentation/manpages/collectd.1.shtml "http://collectd.org/documentation/manpages/collectd.1.shtml"), [collectd.conf(5)](http://collectd.org/documentation/manpages/collectd.conf.5.shtml "http://collectd.org/documentation/manpages/collectd.conf.5.shtml")
- [https://oss.oetiker.ch/rrdtool/](https://oss.oetiker.ch/rrdtool/ "https://oss.oetiker.ch/rrdtool/")
- [statistic.rrdtool](/docs/guide-user/perf_and_log/statistic.rrdtool "docs:guide-user:perf_and_log:statistic.rrdtool")
