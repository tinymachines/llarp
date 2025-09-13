# Network configuration /etc/config/network

See also: [IPv4 configuration](/docs/guide-user/network/ipv4/configuration "docs:guide-user:network:ipv4:configuration"), [IPv6 configuration](/docs/guide-user/network/ipv6/configuration "docs:guide-user:network:ipv6:configuration"), [Static routes](/docs/guide-user/network/routing/routes_configuration "docs:guide-user:network:routing:routes_configuration"), [WAN interface protocols](/docs/guide-user/network/wan/wan_interface_protocols "docs:guide-user:network:wan:wan_interface_protocols"), [Network scripting](/docs/guide-developer/network-scripting#examples "docs:guide-developer:network-scripting"), [DHCP client scripting](/docs/guide-user/network/protocol.dhcp "docs:guide-user:network:protocol.dhcp")

## Overview

The default OpenWrt network stack of a typical home router looks like this:

LuCI → Network Comment Example Firewall Rules for traffic between zones Forwarding Rules, Traffic Rules, Custom Rules Firewall / Interfaces Network zone configuration WAN (Zone) LAN (Zone) Interfaces → Interfaces IP configuration WAN WAN6 LAN Interfaces → Devices Devices and bridge configuration eth0 br-lan (bridge config) Switch / Wireless VLANs and wireless SSIDs VLAN 2 (eth0.2) VLAN 1 (eth0.1) OpenWrt OpenWrt Switch / Wireless Internal jack labels and radio labels WAN (Interface) LAN 1 LAN 2 LAN 3 LAN 4 radio0 radio1 - Common vendor labels on backside of a device “Internet” “1” “2” “3” “4” “n/ac” “b/g/n”

Your device may vary slightly in features or numbering scheme. A minimal network configuration for a router usually consists of at least two *interfaces* (`lan` and `wan`) and their associated *devices* (`br-lan` and `eth0`), as well as a *switch* section if applicable.

Note that the labels WAN and LAN can mean different things depending on the context.

## Managing configuration

The central network configuration is handled by the UCI **network** subsystem, and stored in the file `/etc/config/network`. This UCI subsystem is responsible for defining *switch VLANs*, *interface configurations* and *network routes*. After network configuration customization you need to reload or restart the `network` service to apply the changes.

The `network` service manages both wired and wireless networking with [netifid](/docs/guide-developer/netifid "docs:guide-developer:netifid") and [wifi](https://github.com/openwrt/openwrt/blob/main/package/base-files/files/sbin/wifi "https://github.com/openwrt/openwrt/blob/main/package/base-files/files/sbin/wifi") respectively.

Individual interfaces can be brought up with `ifup name` or down with `ifdown name` where *name* corresponds to the *logical interface name* of the corresponding `config interface` section. Keep in mind that `ifup` is normally enough to reload an interface since it includes `ifdown`.

Note that wireless interfaces are managed externally and `ifup` may break the relation to existing bridges. In such a case it is required to run `wifi up` after `ifup` in order to re-establish the bridge connection.

```
# Soft network reload
service network reload
 
# Hard network restart
service network restart
 
# Reconnect interface
ifdown wan6
ifup wan6
 
# Wireless reload
wifi down
wifi up
 
# List interfaces
ubus list network.interface.*
 
# Status information
ifstatus wan6
```

## Example configuration

Here an example network UCI subsystem with default settings for a TL-WR1043ND:

```
config interface 'loopback'
	option device 'lo'
	option proto 'static'
	option ipaddr '127.0.0.1'
	option netmask '255.0.0.0'
 
config globals 'globals'
	option ula_prefix 'fd27:70fa:5c1d::/48'
 
config device 'lan_br'
	option name 'br-lan'
	option type 'bridge'
	list ports 'eth0.1'
 
config interface 'lan'
	option device 'br-lan'
	option proto 'static'
	option netmask '255.255.255.0'
	option ip6assign '60'
	option ipaddr '192.168.1.1'
 
config interface 'wan'
	option device 'eth0.2'
	option proto 'dhcp'
 
config interface 'wan6'
	option device 'eth0.2'
	option proto 'dhcpv6'
 
config switch
	option name 'switch0'
	option reset '1'
	option enable_vlan '1'
 
config switch_vlan
	option device 'switch0'
	option vlan '1'
	option ports '1 2 3 4 5t'
 
config switch_vlan
	option device 'switch0'
	option vlan '2'
	option ports '0 5t'
```

## Section "globals"

The `globals` section contains interface-independent options affecting the network configuration in general.

```
config globals 'globals'
	option ula_prefix 'fd27:70fa:5c1d::/48'
```

Name Type Required Default Description `ula_prefix` IPv6-prefix or `auto` no *(none)* IPv6 [ULA](https://en.wikipedia.org/wiki/Unique_local_address "https://en.wikipedia.org/wiki/Unique_local_address") prefix for this device: `auto` - auto-generate a new ULA prefix `packet_steering` number no 0 Use every CPU to handle packet traffic. `0` - disabled, `1` - enabled, `2` - enabled for all CPUs `tcp_l3mdev` boolean no 0 Toggles net.ipv4.tcp\_l3mdev\_accept flag (For VRF) `udp_l3mdev` boolean no 0 Toggles net.ipv4.udp\_l3mdev\_accept flag (For VRF)

## Section "device"

The `device` section is optional when L2 and L3 is the same device, i.e. MAC and IP on the same physical interface.

```
config device 'lan_br'
	option name 'br-lan'
	option type 'bridge'
	list ports 'eth0.1'
```

Other example: **enable flow control** for interface eth2:

```
config device                          
        option name 'eth2'                        
        option rxpause '1'             
        option txpause '1'
```

Name Type Required Default Description `name` string yes *(none)* L3 device name.  
Needs to match the `device` option of the respective `interface` section `macaddr` string no *(none)* MAC address overriding the default one for this device, e.g. `62:11:22:aa:bb:cc` `type` string no *(none)* If set to `bridge`, creates a bridge of the given `name` using L2 devices listed in `ports` and wireless interfaces assigned using the `network` option in the [wireless configuration](/docs/guide-user/network/wifi/basic#wi-fi_interfaces "docs:guide-user:network:wifi:basic") `ifname` string no(\*) *(none)* The base L2 device required when using the `macvlan` device type. Install the [kmod-macvlan](/packages/pkgdata/kmod-macvlan "packages:pkgdata:kmod-macvlan") package if necessary. `ports` list no *(none)* List of L2 device names. `rxpause` string no *(none)* controls the receive (RX) flow control. Setting it to `1` enables RX pause frames, which allows the interface to signal the sender to pause transmission when overwhelmed by incoming data. `txpause` string no *(none)* controls the transmission flow control (TX). Setting the value to `1` enables TX pause frames, allowing the interface to temporarily stop sending data when the receiver indicates that it is overloaded. `autoneg` string no *(none)* by setting to `1` enables auto-negotiation that determines whether the interface will automatically negotiate the best link parameters (such as speed, duplex mode) with the connected device. `table` string no 10 When `type` is set to `vrf`, set routing table name or number here

TODO: move everything related to bridges and layer 2 here.

## Section "interface"

Sections of the type `interface` declare logical networks serving as containers for IP address settings, [aliases](/docs/guide-user/network/network_interface_alias "docs:guide-user:network:network_interface_alias"), [routes](/docs/guide-user/network/routing/routes_configuration "docs:guide-user:network:routing:routes_configuration"), physical interface names and [firewall rules](/docs/guide-user/firewall/start "docs:guide-user:firewall:start") - they play a central role within the OpenWrt configuration concept.

A minimal interface declaration consists of the following lines:

```
config 'interface' 'wan'
	option 'proto' 'dhcp'
	option 'device' 'eth0.2'
```

- `wan` is a unique *logical interface name*
- `dhcp` specifies the *interface protocol*, DHCP in this example
- `eth0.2` is the *physical interface* associated with this section

The Linux kernel limits the *physical interface name* length to max 14 usable characters including the automatically added prefix that is added for some protocols (e.g.`6in4`, `pppoa-`, `pppoe-`, `gre4t-`) or with bridges (`br-`).

Depending on the protocol type, the *logical interface name* may thus be limited to only 8 characters. E.g. `abcde6789` is a valid interface name for a normal interface using dhcp, but not for a pppoe interface where the final name would be `pppoe-abcde6789`, which is more than 14 chars.

If using .VLAN notation, an additional 5 characters may be needed, limiting the “parent” interface name to 3 characters for protocols such as GRE. `abcd.NNNN` ⇒ `gre4t-abc.NNNN` for 14 characters.

Using a too long name will lead to silent errors, with interface creation or modification not being successful. Example of this silent error when using br- and different length .VLAN notation can be seen in the forum at [https://forum.openwrt.org/t/network-interface-warning-has-a-issue/182420/14](https://forum.openwrt.org/t/network-interface-warning-has-a-issue/182420/14 "https://forum.openwrt.org/t/network-interface-warning-has-a-issue/182420/14")

The *interface protocol* may be one of the following:

Protocol Description Program `static` Static configuration with fixed address and netmask `ip`/`ifconfig` `dhcp` Address and netmask are assigned by DHCP `udhcpc` (Busybox) `dhcpv6` Address and netmask are assigned by DHCPv6 `odhcpc6c` `ppp` PPP protocol - dialup modem connections `pppd` `pppoe` PPP over Ethernet - DSL broadband connection `pppd` + `plugin rp-pppoe.so` `pppoa` PPP over ATM - DSL connection using a builtin modem `pppd` + plugin ... `3g` CDMA, UMTS or GPRS connection using an AT-style 3G modem `comgt` `qmi` USB modems using QMI protocol `uqmi` `ncm` USB modems using NCM protocol `comgt-ncm` + ? `wwan` USB modems with protocol autodetection `wwan` `hnet` Self-managing home network (HNCP) `hnet-full` `pptp` Connection via PPtP VPN ? `6in4` IPv6-in-IPv4 tunnel for use with Tunnel Brokers like HE.net ? `aiccu` Anything-in-anything tunnel `aiccu` `6to4` Stateless IPv6 over IPv4 transport ? `6rd` IPv6 rapid deployment `6rd` `dslite` Dual-Stack Lite `ds-lite` `l2tp` PPP over L2TP Pseudowire Tunnel `xl2tpd` `relay` relayd pseudo-bridge `relayd` `gre`, `gretap` GRE over IPv4 `gre` + `kmod-gre` `grev6`, `grev6tap` GRE over IPv6 `gre` + `kmod-gre6` `vti` VTI over IPv4 `vti` + `kmod-ip_vti` `vtiv6` VTI over IPv6 `vti` + `kmod-ip6_vti` `vxlan` VXLAN protocol for layer 2 virtualization, see [here](/docs/guide-user/network/tunneling_interface_protocols "docs:guide-user:network:tunneling_interface_protocols") for further information and a configuration example `vxlan` + `kmod-vxlan` + `ip-full` `none` Unspecified protocol, therefore all the other interface settings will be ignored (like disabling the configuration) -

Depending on the used *interface protocol* several other options may be required for a complete interface declaration. The corresponding options for each protocol are listed below. Options marked as “yes” in the “Required” column *must* be defined in the interface section if the corresponding protocol is used, options marked as “no” *may* be defined but can be omitted as well.

![:!:](/lib/images/smileys/exclaim.svg) If an interface section has no protocol defined (not even `none` ), the other settings are completely ignored. The result is that, if the interface section is mentioning a physical network interface (i.e. eth0), this will be down even if a cable is connected (with proto 'none' the interface is up).

### Common options

Common options options valid for all protocol types.

Name Type Required Default Description `device` string yes(\*) *(none)* L3 device name, such as `eth0.1`, `eth2`, `tun0`, `br-lan`, etc.  
Needs to match the `name` option of the respective `device` section.  
![:!:](/lib/images/smileys/exclaim.svg) Do not specify wireless interfaces as their names and behavior can be dynamic and unpredictable, instead assign wireless interfaces to bridges using the `network` option in [wireless configuration](/docs/guide-user/network/wifi/basic#wi-fi_interfaces "docs:guide-user:network:wifi:basic").  
This option may be empty or missing if only a wireless interface references this network or if the protocol is `pptp`, `pppoa`, `6in4`, etc. `mtu` number no *(none)* Override the default MTU on this interface `auto` boolean no `0` for proto `none`, else `1` Specifies whether to bring up interface on boot `ipv6` boolean no `1` Specifies whether to enable (1) or disable (0) IPv6 on this interface (Barrier Breaker and later only) `force_link` boolean no `1` for protocol `static`, else `0` Specifies whether ip address, route, and optionally gateway are assigned to the interface regardless of the link being active ('1') or only after the link has become active ('0'); when set to '1', carrier sense events do not invoke hotplug handlers `disabled` boolean no `0` enable or disable the interface section `ip4table` string no *(none)* IPv4 routing table for routes of this interface, see: `ip rule show; ip route show table <ip4table>` `ip6table` string no *(none)* IPv6 routing table for routes of this interface, see: `ip -6 rule show; ip -6 route show table <ip6table>`

### Bridge options

![:!:](/lib/images/smileys/exclaim.svg) All bridge settings are optional.

Name Type Default Range Description `bridge_empty` boolean `0` `0`, `1` Enables creating empty bridges `vlan_filtering` boolean `0` `0`, `1` Enables **VLAN** aware bridge mode `igmp_snooping` boolean `0` `0`, `1` Enables **IGMP** snooping on the bridge, an optimization that only sends multicast traffic to ports with multicast clients or routers `multicast_querier` boolean (`igmp_snooping` setting) `0`, `1` **IGMP** Enables the bridge as a multicast querier, which keeps the multicast group to port mappings current. Only one querier is elected per subnet `query_interval` number `12500` - **IGMP** Interval in 1/100 seconds between querier general queries (so default is 125 seconds) `query_response_interval` number `1000` (less than `query_interval`) **IGMP** Max time in 1/100 seconds responses to queries should be sent (increase to make IGMP less bursty) `last_member_interval` number `100` - **IGMP** Max time in 1/100s responses to queries after “leave group” messages (the leave latency) `hash_max` number `512` - **IGMP** Size of kernel multicast hash table (larger to avoid collisions that disable snooping) `robustness` number `2` - **IGMP** Sets Startup Query Count and Last Member Count. Also combined with `query_interval` and `query_response_interval` to calculate Group Membership Interval and “other querier” timeout (both other values must be set) `stp` boolean `0` `0`, `1` Enables the Spanning Tree Protocol (**STP**) which prevents network loops (and resulting packet storms) `forward_delay` number `2`![:!:](/lib/images/smileys/exclaim.svg) `2` - `30` **STP** Delay in seconds between port state transitions from Listening → Learning → Forwarding (i.e. bridge ports will be blocked for 2x this value when brought up) ![:!:](/lib/images/smileys/exclaim.svg) **NOTE** The default `2` is below the minimum 802.1D standard of `4`, and STP will be ignored by conforming switches. Set to at least `4` to work with non-OpenWrt switches! `hello_time` number `2` `1` - `10` **STP** Seconds between STP packets `priority` number `32767` `0` - `65535` **STP** Bridge Priority. Lowest priority bridge becomes the Root of the Spanning Tree; most switches default to `32768` `ageing_time` number `300` `10` - `1000000` **STP** Expire in seconds for dynamic MAC entries in the Filtering DB `max_age` number `20` `6` - `40` **STP** After current Root Bridge absent this many seconds, attempt to become the Root Bridge (effects the speed a dead bridge is identified)

## Switch configuration (DSA / bridge-vlan)

This only applies to **OpenWrt 21.02 and later**, and only for targets that have switched to a DSA driver.

![FIXME](/lib/images/smileys/fixme.svg), see: [DSA networking](/docs/guide-user/network/dsa/start "docs:guide-user:network:dsa:start")

## Switch configuration (legacy swconfig)

As of OpenWrt 21.02, swconfig is being phased out and is being replaced with DSA.

This guide applies to all versions of OpenWrt before 21.02. It also applies to non-DSA targets in OpenWrt 21.02.

For many users, the default switch configuration is sufficient. Should the user need to configure the switch differently, LuCI, UCI, or direct editing of `/etc/config/network` may be used to achieve different configurations. Prior to any reconfiguration of the switch, an understanding of the default configuration is important. As an example, some devices have a single switch-connected interface, and other have two or more.

See also:

- [swconfig](/docs/techref/swconfig "docs:techref:swconfig")
- [VLAN](/docs/guide-user/network/vlan/switch_configuration "docs:guide-user:network:vlan:switch_configuration")
- [Switch Documentation](/docs/guide-user/network/vlan/switch "docs:guide-user:network:vlan:switch") (Older content, but does give discuss single-interface configuration)

The identifier for the switch(es) may be obtained using:

```
# swconfig list
Found: switch0 - ag71xx-mdio.0
```

With the identifier known, the configuration can be viewed:

```
# swconfig dev switch0 show
Global attributes:
	enable_vlan: 1
	enable_mirror_rx: 0
	enable_mirror_tx: 0
	mirror_monitor_port: 0
	mirror_source_port: 0
	arl_age_time: 300
	arl_table: address resolution table
[...]
```

There are three types of switch-related configuration stanzas, `switch`, `switch_vlan`, and `switch_port`.

Not all options are available on all hardware. Some limitations may be found with `swconfig dev <dev> help`. After making changes, check the output of `swconfig` to determine if the configuration was accepted by the switch hardware.

![FIXME](/lib/images/smileys/fixme.svg): The list of options may be incomplete. The details of each option need additional discovery and documentation, including checking of the underlying code. The source of restrictions on value ranges has yet to be identified. Valid values should be confirmed in the code.

### Section "switch"

Option Name Type Required Default Impact Notes `name` string yes (none) defines which switch to configure `reset` boolean 1 `enable_vlan` boolean 1 Default may differ by hardware `enable_mirror_rx` boolean no 0 Mirror received packets from the `mirror_source_port` to the `mirror_monitor_port` `enable_mirror_tx` boolean no 0 Mirror transmitted packets from the `mirror_source_port` to the `mirror_monitor_port` `mirror_monitor_port` integer no 0 Switch port to which packets are mirrored `mirror_source_port` integer no 0 Switch port from which packets are mirrored `arl_age_time` integer no 300 Adjust the address-resolution (MAC) table's aging time (seconds) Default may differ by hardware `igmp_snooping` boolean no 0 Enable IGMP snooping Unconfirmed if can be set. Unknown how it interacts with interface- or port-level IGMP snooping. `igmp_v3` boolean no 0 Unconfirmed if can be set. Unknown how it interacts with interface- or port-level IGMP snooping.

### Section "switch\_vlan"

Option Name Type Required Default Impact Notes `description` string no (none) A human-readable description of the VLAN configuration `device` string yes (none) defines which switch to configure `vlan` integer yes (none) The vlan “table index” to configure May be limited to 127 or another number. See the output of `swconfig dev <dev> help` for limit. Sets defaults for VLAN tag and PVID. `vid` integer no `vlan` The VLAN tag number to use See the output of `swconfig dev <dev> help` for limit. VLANs 0 and 4095 are often considered “special use”. `ports` string yes (none) A string of space-separated port indicies that should be associated with the VLAN. Adding the suffix `t` to a port indicates that egress packets should be tagged, for example `'0 1 3t 5t`' The suffixes `*` and `u` are referred to in [docs:guide-user:network:switch](/docs/guide-user/network/vlan/switch "docs:guide-user:network:vlan:switch") with reference to certain Broadcom switches in the context of older releases.

### Section "switch\_port"

Option Name Type Required Default Impact Notes `device` string yes (none) defines which switch to configure `port` integer yes (none) The port index to configure `pvid` integer no † Port PVID; the VLAN tag†† to assign to untagged ingress packets †Typically defaults one of the VLAN tags associated with the port. Logic not clear when there are multiple VLANs on the port. '0' can occur. Certain values have been rejected; logic not clear on limitations. ††*May* refer to the VLAN “index” rather than the VLAN tag itself (unconfirmed). `enable_eee` boolean no 0 Enable “energy saving” features `igmp_snooping` boolean no 0 Enable IGMP snooping Unconfirmed if can be set. Unknown how it interacts with interface- or switch-level IGMP snooping. `igmp_v3` boolean no 0 Unconfirmed if can be set. Unknown how it interacts with interface- or switch-level IGMP snooping.
