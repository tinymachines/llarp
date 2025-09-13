# Babel routing protocol (babeld)

`babeld` is the reference implementation of the [Babel routing protocol](http://www.pps.univ-paris-diderot.fr/~jch/software/babel/ "http://www.pps.univ-paris-diderot.fr/~jch/software/babel/")

This documentation applies to `babeld` after version 1.5.1. Older versions used a slightly different syntax and different option names.

## Introduction

The UCI configuration aims at being as transparent as possible: option names are the same as the native babeld config (using “\_” instead of “-”). Refer to the commented [default configuration file](https://github.com/openwrt-routing/packages/blob/master/babeld/files/babeld.config "https://github.com/openwrt-routing/packages/blob/master/babeld/files/babeld.config") and to the [man page for babeld](https://www.irif.fr/~jch/software/babel/babeld.html "https://www.irif.fr/~jch/software/babel/babeld.html") for more details.

You can configure `babeld` in three different places:

- `/etc/babeld.conf`, the native babeld configuration
- native configuration fragments in `/tmp/babeld.d/` (starting from `babeld` 1.6.0-3). The fragments must end with a `.conf` extension.
- `/etc/config/babeld`, the UCI-style configuration. This is the preferred way of configuring `babeld`.

If the same option is defined in several places, the last one takes precedence. So, for instance, you can mix native and UCI-style configuration, but the UCI-generated configuration will take precedence over the native configuration for conflicting options.

This article may contain network configuration that depends on migration to DSA in OpenWrt 21.02

- Check if your device uses DSA or swconfig as not all devices have been migrated
- ifname@interface has been moved to device sections
- [DSA Networking](/docs/guide-user/network/dsa/start "docs:guide-user:network:dsa:start")
- [Mini tutorial for DSA network config](https://forum.openwrt.org/t/mini-tutorial-for-dsa-network-config/96998 "https://forum.openwrt.org/t/mini-tutorial-for-dsa-network-config/96998") on the forum
- [DSA in the 21.02 release notes](https://openwrt.org/releases/21.02/notes-21.02.0#new_network_configuration_syntax_and_boardjson_change "https://openwrt.org/releases/21.02/notes-21.02.0#new_network_configuration_syntax_and_boardjson_change")

## General configuration

General configuration for `babeld` is done inside a `config general` section, for instance:

```
# /etc/config/babeld
config general
	option 'random_id'     'true'
	option 'local_port'    '33123'
	option 'ubus_bindings' 'true'
	list   'import_table'  '42'
	list   'import_table'  '100'
```

You can use any global option accepted by `babeld`, see “Global options” in the [man page](https://www.irif.fr/~jch/software/babel/babeld.html "https://www.irif.fr/~jch/software/babel/babeld.html").

![:!:](/lib/images/smileys/exclaim.svg) Remember, you must replace “`-`” by “`_`” in option names on OpenWrt.

## Interface configuration

To start using `babeld` on a network interface, a `config interface` section must be used. In its simplest form, this section just needs the name of the interface:

```
# /etc/config/babeld
config interface
	option 'ifname' 'br-lan'
```

You can also specify options:

```
# /etc/config/babeld
config interface
	option 'ifname'         'tun-fastd'
	option 'type'           'tunnel'
	option 'hello_interval' '2'
	option 'rxcost'         '60'
```

You can use any interface option accepted by `babeld`, see “Interface configuration” in the [man page](https://www.irif.fr/~jch/software/babel/babeld.html "https://www.irif.fr/~jch/software/babel/babeld.html").

![:!:](/lib/images/smileys/exclaim.svg) Remember, you must replace “`-`” by “`_`” in option names on OpenWrt.

You can also use logical interface name, see the examples below.

## Default interface configuration

You can also configure options for all interfaces. To do this, simply omit the `ifname` option:

```
# /etc/config/babeld
# Disable split horizon on all interfaces
config interface
	option 'split_horizon' 'false'
```

Note that interface-specific configuration always overrides default interface configuration.

## Filtering rules and redistribution

`babeld` has a small language to describe “filters” that acts on routes.

A filter consists of:

- a type (`in`, `out`, `redistribute` or `install`) that specifies when the filter should apply;
- a set of selectors (`ip`, `eq`, `le` ...) that allow to match routes;
- a set of actions to perform on the matched routes: `allow`, `deny`, `metric xxx`, `src-prefix xxx`, `table xxx`, `pref-src xxx`.

### Reference documentation for filters

The reference documentation is the man page: [https://www.irif.fr/~jch/software/babel/babeld.html](https://www.irif.fr/~jch/software/babel/babeld.html "https://www.irif.fr/~jch/software/babel/babeld.html") (section “Filtering rules”).

### Default filtering rules

By default, `babeld` accepts any route from its neighbours, relays them to other neighbours, and install them in the kernel routing table. It also redistributes local IP addresses (configured on any network interface) as host routes: /32 for IPv4, /128 for IPv6.

This default configuration is sufficient for basic needs. Read below for more complex examples.

## Troubleshooting

When starting `babeld`, `/etc/config/babeld` is used to generate a configuration in `/var/etc/babeld.conf`. If babeld does not start, look for something unusual in this file. Also look at the logs (using `logread`).

Note that, by default, no interface is configured, so babeld will refuse to start.

## Example interface configuration

It is recommended to use logical interface names, so that you can also define firewall zones with these interfaces, and use all UCI goodness (automatic interface reloading, `ifstatus`, persistent interface name, etc). But you can also use physical interface names if you want to.

![:!:](/lib/images/smileys/exclaim.svg) Using logical interface names does not seem to work reliably in all cases, see [this ticket](https://github.com/openwrt-routing/packages/pull/52#issuecomment-55004440 "https://github.com/openwrt-routing/packages/pull/52#issuecomment-55004440").

### Wireless setup with logical interface names

Here is an example with two radios, one 2.4 GHz (`wlan_24`) and one 5 GHz (`wlan_5`). Note that we don't bridge anything, as Babel will route between the interfaces.

```
# /etc/config/network
config interface wlan_24
        option 'proto'    'static'
        option 'ipaddr'   '10.0.0.42'
        option 'netmask'  '255.255.255.255'
 
config interface wlan_5
        option 'proto'    'static'
        option 'ipaddr'   '10.0.0.42'
        option 'netmask'  '255.255.255.255'
```

```
# /etc/config/wireless
config wifi-iface
	option 'device'     'radio0'
	option 'network'    'wlan_24'
	option 'mode'       'adhoc'
	option 'ssid'       'mymesh'
	option 'encryption' 'none'
 
config wifi-iface
	option 'device'     'radio1'
	option 'network'    'wlan_5'
	option 'mode'       'adhoc'
	option 'ssid'       'mymesh'
	option 'encryption' 'none'
```

```
# /etc/config/babeld
# Default options
config interface
    option 'hello_interval'  '1'
    option 'update_interval' '16'
 
config interface
    option 'ifname' 'wlan_24'
    option 'type'   'wireless'
 
config interface
    option 'ifname' 'wlan_5'
    option 'type'   'wireless'
```

### Wireless setup with physical interface names

If you don't want to bother, or don't use the firewall, you can just use physical interface names instead:

```
# Default options
config interface
    option hello_interval 1
    option update_interval 16
 
config interface
    option ifname wlan0
 
config interface
    option ifname wlan1
```

### UCI-managed tunnel

This example uses a GRE tunnel, defined in UCI, and enables the RTT-based metric on it.

```
# /etc/config/network
config interface mytunnel 
    option proto    gre
    # Firewall zone
    option zone     myzone
    option peeraddr 198.51.100.42
 
config interface mytunnel_static                               
    option proto    static                              
    option ifname   @mytunnel                              
    option ipaddr   10.0.0.42                       
    option netmask  255.255.255.254                     
    # Fixes IPv6 multicast (long-standing bug in kernel)
    option ip6addr  'fe80::42:42:42/64'
```

```
# /etc/config/babeld
config interface
    option ifname mytunnel
    option type tunnel
    option max_rtt_penalty 100
```

### Manually managed tunnel

In some cases, tunnels are managed outside of UCI. It's still a good idea to declare them this way:

```
# /etc/config/network
config interface mytunnel
    option ifname   tun-openvpn
    option proto    none
```

You may actually want to assign addresses on your tunnel interfaces:

```
# /etc/config/network
config interface mytunnel
    option ifname   tun-openvpn       
    option proto    static
    option ipaddr   10.0.0.42
    option netmask  255.255.255.255
    # OpenVPN does not assign a link-local address on tunnels
    option ip6addr  'fe80::42:42:42/64'
    # Firewall zone
    option zone     dn42                              
```

In both cases, you can then use the logical interface name:

```
# /etc/config/babeld
config interface
    option ifname mytunnel
    option type tunnel
    option max_rtt_penalty 100
```

## Example filtering configuration

### Illustration: default filtering rules

For illustration, the default filtering rules would be equivalent to the following OpenWrt configuration:

```
# /etc/config/babeld
 
# Accept all routes from neighbours.
config filter
	option 'type'	'in'
	option 'action'	'allow'
 
# Send all known routes to neighbours.
config filter
	option 'type'	'out'
	option 'action'	'allow'
 
# Install all routes to the kernel.
config filter
	option 'type'	'install'
	option 'action'	'allow'
 
# Redistribute all local IP addresses as host routes.
config filter
	option 'type'	'redistribute'
	option 'local'	'true'
	option 'action'	'allow'
 
# Don't redistribute any other route from the kernel routing table.
config filter
	option 'type'	'redistribute'
	option 'local'	'false'
	option 'action'	'deny'
```

### Redistribute a default route

For a border router, it is common to obtain a default route from an external source (DHCP client or static route). This default route then needs to be redistributed inside the Babel network, as shown in the following configuration:

```
# /etc/config/babeld
config filter
	option 'type'	'redistribute'
	# Redistribute any kernel route within 0/0 (that is, any IPv4 route)
	option 'ip'	'0.0.0.0/0'
	# ... but only routes with a prefix length of 0. That is, the default route.
	option 'eq'	'0'
	# ... and only if its "rt proto" is 3 (as shown by "ip route show"), see /etc/iproute2/rt_protos.
	# This is only needed because babeld special-cases this rt proto and refuses to
	# redistribute it by default. Remove this line if your default route uses another rt proto
	# (dhcpcd seems to use 16, "proto static" is 4).
	option 'proto'	'3'
	# Advertise the route in Babel with a metric. If there are several border routers,
	# it is possible to choose a different metric on each one to reflect the quality
	# of each uplink (capacity, latency, stability...)
	option 'action'	'metric 128'
```

And similarly for IPv6:

```
# /etc/config/babeld
config filter
	option 'type'	'redistribute'
	option 'ip'	'::/0'
	option 'eq'	'0'
	option 'proto'	'3'
	option 'action'	'metric 128'
```

### Redistribute a dynamic default route

Imagine that a border router has two uplinks on which it receives a default route, for instance through BGP. The main uplink has a large capacity, while the second uplink is a backup link with much less capacity. We would like to redistribute this default route in Babel, but if BGP switches to the backup uplink, we want other Babel routers to know about it. This way, Babel routers can possibly decide to switch to another border router with a better uplink.

This is possible through the `if` selector that allows to change the redistribution metric:

```
# /etc/config/babeld
config filter
	option 'type'	'redistribute'
	option 'ip'	'::/0'
	option 'eq'	'0'
	option 'proto'	'3'
	# Only apply this filter when the default route points to the eth-main network interface.
	option 'if'     'eth-main'
	# Redistribute with a smallish metric in this case.
	option 'action'	'metric 128'
 
config filter
	option 'type'	'redistribute'
	option 'ip'	'::/0'
	option 'eq'	'0'
	option 'proto'	'3'
	# Redistribute with a larger metric when the default route points
	# to the "eth-backup" network interface.
	option 'if'     'eth-backup'
	option 'action'	'metric 512'
```

### Redistribute only a subset of local IP addresses

A router has several interfaces, and some of them may be unrelated to Babel. It is possible to specify which addresses should redistributed and which addresses should not.

For instance, to redistribute all local IP addresses except for a given prefix:

```
# /etc/config/babeld
 
# Don't redistribute local IP addresses within 198.51.100.0/24
config filter
	option 'type'	'redistribute'
	option 'ip'	'198.51.100.0/24'
	option 'local'	'true'
	# Don't redistribute.
	option 'action'	'deny'
```

The opposite approach is to whitelist local addresses from a given IP prefix:

```
# /etc/config/babeld
 
# Only redistribute local IP addresses within 203.0.113.0/24
config filter
	option 'type'	'redistribute'
	option 'ip'	'203.0.113.0/24'
	option 'local'	'true'
	option 'action'	'allow'
 
# Deny all other addresses from redistribution.
config filter
	option 'type'	'redistribute'
	option 'local'	'true'
	option 'action'	'deny'
```

### Installing routes in the kernel

By default, `babeld` installs routes in the regular kernel routing table. It is possible to install routes in another routing table with the general configuration item `export-table`, but it may not be fine-grained enough.

Here is a filter that install routes within `2001:db8:cafe::/48` in a different routing table:

```
# /etc/config/babeld
 
config filter
	option 'type'	'install'
	# Only apply to routes within 2001:db8:cafe::/48
	option 'ip'	'2001:db8:cafe::/48'
	# "Allow" is implicit.
	option 'action'	'table 200'
```

### Specifying a source address for kernel routes

Since `babeld` 1.9.0, it is possible to specify a source address to the kernel when installing routes. This is only used for packets generated by the router itself (possibly including useful ICMP messages!), but not for forwarded packets.

Here, we showcase taking several actions for the same filter:

```
# /etc/config/babeld
 
config filter
	option 'type'	'install'
	option 'ip'	'2001:db8:cafe::/48'
	# We specify both the kernel routing table and the preferred source address to use for these routes.
	option 'action'	'table 200  pref-src 2001:db8:ba:be1::42'
```

## Ubus Bindings

A better integration of babeld with OpenWrt is to connect the daemon to the IPC. So far, we can only communicate via a websocket. With ubus we can send and receive commands in json format.

Following functions exists:

- get\_info
- get\_neighbours
- get\_xroutes
- get\_routes

All output is divided into IPv4 and IPv6.

Ubus has to be enabled by setting “config general”

```
  option 'ubus_bindings' 'true'
```

```
root@OpenWrt:~# ubus call babeld get_info
{
	"babeld_version": "babeld-1.9.2",
	"my_id": "32:xx:xx:xx:xx:xx:xx:xx",
	"host": "OpenWrt"
}
```

```
root@OpenWrt:~# ubus call babeld get_neighbours
{
	"IPv4": [
 
	],
	"IPv6": [
		{
			"address": "fe80::26a4:3cff:fee3:7ddb",
			"dev": "br-lan",
			"hello_reach": 65535,
			"uhello_reach": 0,
			"rxcost": 96,
			"txcost": 96,
			"rtt": "0.000",
			"if_up": true
		},
		{
			"address": "fe80::26a4:3cff:fee4:d6f",
			"dev": "phy0-mesh0",
			"hello_reach": 65535,
			"uhello_reach": 0,
			"rxcost": 256,
			"txcost": 256,
			"rtt": "0.000",
			"if_up": true
		}
	]
}
```

```
root@OpenWrt:~# ubus call babeld get_xroutes
{
	"IPv4": [
		{
			"address": "10.31.27.12/32",
			"src_prefix": "0.0.0.0/0",
			"metric": 0
		},
		{
			"address": "10.31.27.11/32",
			"src_prefix": "0.0.0.0/0",
			"metric": 0
		}
	],
	"IPv6": [
		{
			"address": "2001:920:1959:778f::1/128",
			"src_prefix": "::/0",
			"metric": 0
		},
		{
			"address": "2001:920:1959:778f::/64",
			"src_prefix": "::/0",
			"metric": 0
		}
	]
}
```

```
root@OpenWrt:~# ubus call babeld get_routes
{
	"IPv4": [
		{
			"address": "10.36.31.0/25",
			"src_prefix": "0.0.0.0/0",
			"route_metric": 2015,
			"route_smoothed_metric": 2020,
			"refmetric": 1631,
			"id": "da:58:d7:ff:fe:00:77:47",
			"seqno": 40314,
			"age": 7,
			"via": "fe80::618:d6ff:fe24:fe5d",
			"nexthop": "10.31.27.14",
			"installed": false,
			"feasible": false
		},
		{
			"address": "10.36.31.0/25",
			"src_prefix": "0.0.0.0/0",
			"route_metric": 2239,
			"route_smoothed_metric": 2244,
			"refmetric": 1855,
			"id": "da:58:d7:ff:fe:00:77:47",
			"seqno": 40314,
			"age": 10,
			"via": "fe80::618:d6ff:fe0c:3680",
			"nexthop": "10.31.16.86",
			"installed": false,
			"feasible": false
		}
	],
	"IPv6": [
		{
			"address": "2003:a:36d:2410::/60",
			"src_prefix": "::/0",
			"route_metric": 3210,
			"route_smoothed_metric": 3189,
			"refmetric": 2826,
			"id": "02:1b:21:ff:fe:26:57:05",
			"seqno": 22769,
			"age": 10,
			"via": "fe80::618:d6ff:fe0c:3680",
			"installed": false,
			"feasible": false
		},
		{
			"address": "2003:a:36d:2410::/60",
			"src_prefix": "::/0",
			"route_metric": 3210,
			"route_smoothed_metric": 3193,
			"refmetric": 2826,
			"id": "02:1b:21:ff:fe:26:57:05",
			"seqno": 22769,
			"age": 11,
			"via": "fe80::26a4:3cff:fee4:d72",
			"installed": false,
			"feasible": false
		}
	]
}
```

Further babeld can sends a notification via the ubus bus if we experience any changes in neighbours, routes or xroutes. The format looks like this:

- {route,xroute,neighbour}.add: Object was added
- {route,xroute,neighbour}.change: Object was changed
- {route,xroute,neighbour}.flush: Object was flushed

## History: backward compatibility

This section is kept for historical interest, since babeld 1.5.1 was released a long time ago (August 2014).

![:!:](/lib/images/smileys/exclaim.svg) Starting from babeld 1.8.0-3, the compatibility code has been removed: [https://github.com/openwrt-routing/packages/commit/1aacfea7b3ad97fb8c549a66fa7e7526a6419bd2](https://github.com/openwrt-routing/packages/commit/1aacfea7b3ad97fb8c549a66fa7e7526a6419bd2 "https://github.com/openwrt-routing/packages/commit/1aacfea7b3ad97fb8c549a66fa7e7526a6419bd2")

### Global options

Compared to pre-1.5.1 versions of `babeld`, the name of options in the “general” section have changed. We now use the same names as babeld (which have been introduced only recently, in babeld 1.4.2).

Most old options are accepted and translated, with a few exceptions:

- `hello_interval` and `wired_hello_interval` are ignored. You must set `hello_interval` on interfaces instead.
- `conf_file` is ignored
- `diversity` does no longer accept the old “3,42” syntax. You must use `diversity 3` and `diversity_factor 42` instead

So, except if you were using `diversity`, your old configuration file should still work.

### Interfaces

Pre-1.5.1 versions of `babeld` used a slightly different syntax for specifying interface options:

```
config interface wlan
    option foo bar
```

instead of the new syntax:

```
config interface
    option ifname wlan
    option foo bar
```

However, the old syntax is still accepted, so you can keep using your old configuration files.
