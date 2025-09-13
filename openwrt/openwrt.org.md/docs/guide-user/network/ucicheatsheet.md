# UCI networking options cheatsheet

This is a cheatsheet for quick lookup of networking UCI options, useful for experienced users.

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

```
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
```

Common options options valid for all protocol types.

Name Type Required Default Description `device` string yes(\*) *(none)* L3 device name, such as `eth0.1`, `eth2`, `tun0`, `br-lan`, etc.  
Needs to match the `name` option of the respective `device` section.  
![:!:](/lib/images/smileys/exclaim.svg) Do not specify wireless interfaces as their names and behavior can be dynamic and unpredictable, instead assign wireless interfaces to bridges using the `network` option in [wireless configuration](/docs/guide-user/network/wifi/basic#wi-fi_interfaces "docs:guide-user:network:wifi:basic").  
This option may be empty or missing if only a wireless interface references this network or if the protocol is `pptp`, `pppoa`, `6in4`, etc. `mtu` number no *(none)* Override the default MTU on this interface `auto` boolean no `0` for proto `none`, else `1` Specifies whether to bring up interface on boot `ipv6` boolean no `1` Specifies whether to enable (1) or disable (0) IPv6 on this interface (Barrier Breaker and later only) `force_link` boolean no `1` for protocol `static`, else `0` Specifies whether ip address, route, and optionally gateway are assigned to the interface regardless of the link being active ('1') or only after the link has become active ('0'); when set to '1', carrier sense events do not invoke hotplug handlers `disabled` boolean no `0` enable or disable the interface section `ip4table` string no *(none)* IPv4 routing table for routes of this interface, see: `ip rule show; ip route show table <ip4table>` `ip6table` string no *(none)* IPv6 routing table for routes of this interface, see: `ip -6 rule show; ip -6 route show table <ip6table>`

## Alias

Name Type Required Default Description `interface` string yes *(none)* Specifies the *logical interface name* of the parent (or master) interface this alias belongs to; must refer to one of the defined `interface` sections `proto` string yes *(none)* Specifies the *alias interface protocol* `ipaddr` ip address yes, if no `ip6addr` is set *(none)* alias IP address `netmask` netmask yes, if no `ip6addr` is set *(none)* alias Netmask `gateway` ip address no *(none)* Default gateway `broadcast` ip address no *(none)* Broadcast address (autogenerated if not set) `ip6addr` ipv6 address yes, if no `ipaddr` is set *(none)* IPv6 address (CIDR notation) `ip6gw` ipv6 address no *(none)* IPv6 default gateway `dns` list of ip addresses no *(none)* DNS server(s) `layer` integer no `3` Selects the interface to attach to for stacked protocols (tun over bridge over eth, ppp over eth or similar).  
3: attach to layer 3 interface (*tun\**, *ppp\** if parent is layer 3 else fallback to 2)  
2: attach to layer 2 interface (*br-\** if parent is bridge else fallback to layer 1)  
1: attach to layer 1 interface (*eth\**, *wlan\**)

![FIXME](/lib/images/smileys/fixme.svg) please check if this is still true or not: At the time of writing, only the `static` protocol type is allowed for aliases.

## Section "rule" and "rule6"

```
config rule
        option mark   '0xFF'
        option in     'lan'
        option dest   '172.16.0.0/16'
        option lookup '100'
 
config rule6
        option in     'vpn'
        option dest   'fdca:1234::/64'
        option action 'prohibit'
```

Both `rule` and `rule6` sections share the same set of defined options.

Name Type Required Default Description `in` string no *(none)* Specifies the incoming *logical interface name* `out` string no *(none)* Specifies the outgoing *logical interface name* `src` ip subnet no *(none)* Specifies the source subnet to match (CIDR notation) `dest` ip subnet no *(none)* Specifies the destination subnet to match (CIDR notation) `tos` integer no *(none)* Specifies the TOS value to match in IP headers `mark` mark/mask no *(none)* Specifies the *fwmark* and optionally its mask to match, e.g. `0xFF` to match mark 255 or `0x0/0x1` to match any even mark value `uidrange` integer/integer range no *(none)* Specifies an individual UID or range of UIDs to match, e.g. `1000` to match corresponding UID or `1000-1005` to inclusively match all UIDs within the corresponding range `suppress_prefixlength` integer no *(none)* Reject routing decisions that have a prefix length less than or equal to the specified value `ipproto` integer 0-255 no `0` The **ipproto** element allows you to specify a protocol number in IP rule configuration, enabling rules to target traffic based on the protocol. This aligns with the [IANA Protocol Numbers](https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml "https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml"). The **ipproto** value is an unsigned integer and must be in the range of **0–255**. `invert` boolean no `0` If set to `1`, the meaning of the match options is inverted `priority` integer no *(incrementing)* Controls the order of the IP rules, by default the priority is auto-assigned so that they are processed in the same order they're declared in the config file `lookup` routing table at least one of *(none)* The rule target is a table lookup, the ID can be either a numeric table index ranging from `0` to `65535` or a symbolic alias declared in `/etc/iproute2/rt_tables`. The special aliases `local` (`255`), `main` (`254`) and `default` (`253`) are recognized as well `goto` rule index The rule target is a jump to another rule specified by its `priority` value `action` string The rule target is one of the routing actions outlined in the table below `disabled` boolean no `0` Specifies if the rule should be set or not.

## Section "route"

```
config route 'net172'
        option interface 'lan'
        option target '172.16.1.0'
        option netmask '255.255.255.0'
        option gateway '10.1.1.1'
```

Name Type Required Default Description `interface` string yes *(none)* Specifies the *logical interface name* of the parent (or master) interface this route belongs to; must refer to one of the defined `interface` sections `target` ip address yes *(none)* Network address `netmask` netmask no *(none)* Route netmask. If omitted, `255.255.255.255` is assumed which makes `target` a *host address* `gateway` ip address no *(none)* Network gateway. If omitted, the `gateway` from the parent interface is taken if any, otherwise creates a `link` scope route; if set to `0.0.0.0` no gateway will be specified for the route `metric` number no `0` Specifies the *route metric* to use `mtu` number no *interface MTU* Defines a specific MTU for this route `table` routing table no `main` Defines the table ID to use for the route. The ID can be either a numeric table index ranging from 0 to 65535 or a symbolic alias declared in `/etc/iproute2/rt_tables`. The special aliases local (255), main (254) and default (253) are recognized as well `source` ip address no *(none)* The preferred source address when sending to destinations covered by the target `onlink` boolean no `0` When enabled gateway is on link even if the gateway does not match any interface prefix `type` string no `unicast` One of the types outlined in the routing types table below `proto` routing protocol no `static` Defines the protocol ID for the route. The ID can be either a numeric value ranging from 0 to 255 or a symbolic alias declared in `/etc/iproute2/rt_protos`. i.e. `kernel`, `boot`, `ra`, `redirect`, `static` `disabled` boolean no `0` Specifies if the static route should be set or not, available since OpenWrt &gt;= 21.02.

## Section "route6"

```
config route6 'default'
        option interface 'lan'
        option target '2008:a:a:c::/64'
        option gateway '2008:a:a:b::2'
```

Name Type Required Default Description `interface` string yes *(none)* Specifies the *logical interface name* of the parent (or master) interface this route belongs to; must refer to one of the defined `interface` sections `target` ipv6 address yes *(none)* IPv6 network address `gateway` ipv6 address no *(none)* IPv6 gateway. If omitted, the `gateway` from the parent interface is taken `metric` number no `0` Specifies the *route metric* to use `mtu` number no *interface MTU* Defines a specific MTU for this route `table` routing table no `main` Defines the table ID to use for the route. The ID can be either a numeric table index ranging from 0 to 65535 or a symbolic alias declared in /etc/iproute2/rt\_tables. The special aliases local (255), main (254) and default (253) are recognized as well `source` ip address no *(none)* The route source address in source-address dependent routes. It's called “from” in the ip command. `onlink` boolean no `0` When enabled gateway is on link even if the gateway does not match any interface prefix `type` string no `unicast` One of the types outlined in the Routing Types table below `proto` routing protocol no `static` Defines the protocol ID for the route. The ID can be either a numeric value ranging from 0 to 255 or a symbolic alias declared in `/etc/iproute2/rt_protos`. i.e. `kernel`, `boot`, `ra`, `redirect`, `static` `disabled` boolean no `0` Specifies if the static route should be set or not, available since OpenWrt &gt;= 21.02.

### Routing types

Type Description `unicast` the route entry describes real paths to the destinations covered by the route prefix. `local` the destinations are assigned to this host. The packets are looped back and delivered locally. `broadcast` the destinations are broadcast addresses. The packets are sent as link broadcasts. `multicast` a special type used for multicast routing. It is not present in normal routing tables. `unreachable` these destinations are unreachable. Packets are discarded and the ICMP message host unreachable is generated. The local senders get an EHOSTUNREACH error. `prohibit` these destinations are unreachable. Packets are discarded and the ICMP message communication administratively prohibited is generated. The local senders get an EACCES error. `blackhole` these destinations are unreachable. Packets are discarded silently. The local senders get an EINVAL error. `anycast` the destinations are anycast addresses assigned to this host. They are mainly equivalent to local with one difference: such addresses are invalid when used as the source address of any packet.

## Routing types

Type Description `unicast` the route entry describes real paths to the destinations covered by the route prefix. `local` the destinations are assigned to this host. The packets are looped back and delivered locally. `broadcast` the destinations are broadcast addresses. The packets are sent as link broadcasts. `multicast` a special type used for multicast routing. It is not present in normal routing tables. `unreachable` these destinations are unreachable. Packets are discarded and the ICMP message host unreachable is generated. The local senders get an EHOSTUNREACH error. `prohibit` these destinations are unreachable. Packets are discarded and the ICMP message communication administratively prohibited is generated. The local senders get an EACCES error. `blackhole` these destinations are unreachable. Packets are discarded silently. The local senders get an EINVAL error. `anycast` the destinations are anycast addresses assigned to this host. They are mainly equivalent to local with one difference: such addresses are invalid when used as the source address of any packet.

## Protocol "6in4" (IPv6-in-IPv4 Tunnel)

```
config interface 'wan6'
        option proto '6in4'
        option mtu '1424'                          # the IPv6 tunnel MTU (optional)
        option peeraddr '62.12.34.56'              # the IPv4 tunnel endpoint at the tunnel provider
        option ip6addr '2001:DB8:2222:EFGH::2/64'  # the IPv6 tunnel
        option ip6prefix '2001:DB8:1234::/48'      # Your routed prefix (required!)
        # configuration options below are only valid for HE.net tunnels. ignore them for other tunnel providers.
        option tunnelid '123456'     # HE.net tunnel id
        option username 'username'   # HE.net username used to login into tunnelbroker, not the User ID shown after login in.
        option password 'password'   # HE.net password if there is no updatekey for tunnel
        option updatekey 'updatekey' # HE.net updatekey instead of password, default for new tunnels
 
config interface 'lan'
        option proto 'static'
        option ip6assign '60'
```

Name Type Required Default Description `ipaddr` IPv4 address no Current WAN IPv4 address Local IPv4 endpoint address `peeraddr` IPv4 address yes *(none)* Remote IPv4 endpoint address `ip6addr` IPv6 address (CIDR) yes *(none)* Local IPv6 address delegated to the tunnel endpoint `ip6prefix` IPv6 prefix no *(none)* Routed IPv6 prefix for downstream interfaces (Barrier Breaker and later only) `tunlink` Logical Interface no *(none)* Tunnel base interface. Define which Interface, for example WAN, should be used for outgoing IPv4 traffic to the Remote IPv4 Address `defaultroute` boolean no `1` Whether to create an IPv6 default route over the tunnel `ttl` integer no `64` TTL used for the tunnel interface `tos` string no *(none)* Type Of Service : either “inherit” (the outer header inherits the value of the inner header) or an hexadecimal value. Also known as DSCP. `mtu` integer no `1280` MTU used for the tunnel interface `tunnelid` integer no *(none)* HE.net global tunnel ID, used for endpoint update `username` string no *(none)* HE.net username which you use to login into tunnelbroker, not the User ID shown after you have login in, plaintext, used for endpoint update `password` string no *(none)* HE.net password, plaintext, obsolete, used for endpoint update `updatekey` string no *(none)* HE.net updatekey, plaintext, overrides password since 2014-02, used for endpoint update `metric` integer no `0` Specifies the default route metric to use

![:!:](/lib/images/smileys/exclaim.svg) This protocol type does not need the `device` option set in the interface section. The interface name is derived from the section name, e.g. `config interface sixbone` would result in an interface named `6in4-sixbone`.

![:!:](/lib/images/smileys/exclaim.svg) Although `ip6prefix` isn't required, `sourcefilter` is enabled by default and prevents forwarding of packets unless `ip6prefix` is specified.

## Protocol "6rd" (ISP-provided IPv6 transition, 6rd)

```
config interface 'wan6'
        option proto '6rd'
        option peeraddr '77.174.0.2'
        option ip6prefix '2001:838:ad00::'
        option ip6prefixlen '40'
        option ip4prefixlen '16'
```

Name Type Required Default Description `peeraddr` IPv4 address yes no 6rd - Gateway `ipaddr` IPv4 address no Current WAN IPv4 address Local IPv4 endpoint address `ip6prefix` IPv6 prefix (without length) yes no 6rd-IPv6 Prefix `ip6prefixlen` IPv6 prefix length yes no 6rd-IPv6 Prefix length `ip4prefixlen` IPv6 prefix length no 0 IPv4 common prefix `defaultroute` boolean no `1` Whether to create an IPv6 default route over the tunnel `ttl` integer no `64` TTL used for the tunnel interface `tos` string no *(none)* Type Of Service: either “inherit” (the outer header inherits the value of the inner header) or an hexadecimal value `mtu` integer no `1280` MTU used for the tunnel interface `iface6rd` logical interface no *(none)* Logical interface template for auto-configuration of 6rd `mtu6rd` integer no *system default* MTU of the 6rd interface `zone6rd` firewall zone no *system default* Firewall zone to which the 6rd interface should be added

![:!:](/lib/images/smileys/exclaim.svg) This protocol type does not need the `device` option set in the interface section. The interface name is derived from the section name, e.g. `config interface wan6` would result in an interface named `6rd-wan6`.

![:!:](/lib/images/smileys/exclaim.svg) Some ISP's give you the number of bytes you should use from your WAN IP to calculate your IPv6 address. `ip4prefixlen` expects the *prefix* bytes of your WAN IP to calculate the IPv6 address. So if your ISP gives you 14 bytes to calculate, enter 18 (32 - 14).

## Protocol "l2tp" (ISP-provided IPv6 transition, 6pe)

```
config interface '6pe'
        option proto 'l2tp'
        option server '<LNS address>'
        option username '<PPP username>'
        option password '<PPP password>'
        option keepalive '6'
        option ipv6 '1'
 
config interface 'wan6'
        option device '@6pe'
        option proto 'dhcpv6'
```

Most options are similar to protocol “ppp”.

Name Type Required Default Description `server` string yes *(none)* L2TP server to connect to. Acceptable datatypes are hostname or IP address, with optional port separated by colon `:`. Note that specifying port is only supported recently and should appear in DD release `username` string no *(none)* Username for PAP/CHAP authentication `password` string yes if `username` is provided *(none)* Password for PAP/CHAP authentication `ipv6` bool no 0 Enable IPv6 on the PPP link (IPv6CP) `mtu` int no `pppd` default Maximum Transmit/Receive Unit, in bytes `keepalive` string no *(none)* Number of unanswered echo requests before considering the peer dead. The interval between echo requests is 5 seconds. `checkup_interval` int no *(none)* Number of seconds to pass before checking if the interface is not up since the last setup attempt and retry the connection otherwise. Set it to a value sufficient for a successful L2TP connection for you. It's mainly for the case that netifd sent the connect request yet xl2tpd failed to complete it without the notice of netifd `pppd_options` string no *(none)* Additional options to pass to `pppd`

The name of the physical interface will be “l2tp-&lt;logical interface name&gt;”.

## Protocol "6to4" (IPv6-in-IPv4 tunnel)

```
config interface 'wan6'
        option proto '6to4'
 
config interface 'lan'
        option proto 'static'
        option ip6assign '60'
```

Name Type Required Default Description `ipaddr` IPv4 address no Current WAN IPv4 address Local IPv4 endpoint address `defaultroute` boolean no `1` Whether to create an IPv6 default route over the tunnel `ttl` integer no `64` TTL used for the tunnel interface `tos` string no *(none)* Type Of Service : either “inherit” (the outer header inherits the value of the inner header) or an hexadecimal value `mtu` integer no `1280` MTU used for the tunnel interface `metric` integer no `0` Specifies the default route metric to use

![:!:](/lib/images/smileys/exclaim.svg) This protocol type does not need the `device` option set in the interface section. The interface name is derived from the section name, e.g. `config interface wan6` would result in an interface named `6to4-wan6`.

## Protocol "dslite" (Dual-Stack Lite)

```
config interface 'wan6'
        option device 'eth1'
        option proto 'dhcpv6'
 
config interface 'wan'
        option proto 'dslite'
        option peeraddr '2001:db80::1' # Your ISP's DS-Lite AFTR
```

Name Type Required Default Description `peeraddr` IPv6 address yes no DS-Lite AFTR address `ip6addr` IPv6 address no Current WAN IPv6 address Local IPv6 endpoint address `tunlink` Logical Interface no Current WAN interface Tunnel base interface `defaultroute` boolean no `1` Whether to create an IPv6 default route over the tunnel `ttl` integer no `64` TTL used for the tunnel interface `mtu` integer no `1280` MTU used for the tunnel interface

![:!:](/lib/images/smileys/exclaim.svg) ds-lite operation requires that IPv4 NAT is disabled. You should adjust your settings in /etc/config/firewall accordingly.

![:!:](/lib/images/smileys/exclaim.svg) This protocol type does not need the `device` option set in the interface section. The interface name is derived from the section name, e.g. `config interface wan` would result in an interface named `dslite-wan`.

## Section "switch"

```
config switch
        option name 'switch0'
        option reset '1'
        option enable_vlan '1'
```

Option Name Type Required Default Impact Notes `name` string yes (none) defines which switch to configure `reset` boolean 1 `enable_vlan` boolean 1 Default may differ by hardware `enable_mirror_rx` boolean no 0 Mirror received packets from the `mirror_source_port` to the `mirror_monitor_port` `enable_mirror_tx` boolean no 0 Mirror transmitted packets from the `mirror_source_port` to the `mirror_monitor_port` `mirror_monitor_port` integer no 0 Switch port to which packets are mirrored `mirror_source_port` integer no 0 Switch port from which packets are mirrored `arl_age_time` integer no 300 Adjust the address-resolution (MAC) table's aging time (seconds) Default may differ by hardware `igmp_snooping` boolean no 0 Enable IGMP snooping Unconfirmed if can be set. Unknown how it interacts with interface- or port-level IGMP snooping. `igmp_v3` boolean no 0 Unconfirmed if can be set. Unknown how it interacts with interface- or port-level IGMP snooping.

## Section "switch\_vlan"

```
config switch_vlan
        option device 'switch0'
        option vlan '1'
        option ports '1 2 3 4 5t'
 
config switch_vlan
        option device 'switch0'
        option vlan '2'
        option ports '0 5t'
```

Option Name Type Required Default Impact Notes `description` string no (none) A human-readable description of the VLAN configuration `device` string yes (none) defines which switch to configure `vlan` integer yes (none) The vlan “table index” to configure May be limited to 127 or another number. See the output of `swconfig dev <dev> help` for limit. Sets defaults for VLAN tag and PVID. `vid` integer no `vlan` The VLAN tag number to use See the output of `swconfig dev <dev> help` for limit. VLANs 0 and 4095 are often considered “special use”. `ports` string yes (none) A string of space-separated port indicies that should be associated with the VLAN. Adding the suffix `t` to a port indicates that egress packets should be tagged, for example `'0 1 3t 5t`' The suffixes `*` and `u` are referred to in [docs:guide-user:network:switch](/docs/guide-user/network/vlan/switch "docs:guide-user:network:vlan:switch") with reference to certain Broadcom switches in the context of older releases.

## Section "switch\_port"

```
config switch_port
        option device 'eth0'
        option port '3'
        option pvid '3'
```

Option Name Type Required Default Impact Notes `device` string yes (none) defines which switch to configure `port` integer yes (none) The port index to configure `pvid` integer no † Port PVID; the VLAN tag†† to assign to untagged ingress packets †Typically defaults one of the VLAN tags associated with the port. Logic not clear when there are multiple VLANs on the port. '0' can occur. Certain values have been rejected; logic not clear on limitations. ††*May* refer to the VLAN “index” rather than the VLAN tag itself (unconfirmed). `enable_eee` boolean no 0 Enable “energy saving” features `igmp_snooping` boolean no 0 Enable IGMP snooping Unconfirmed if can be set. Unknown how it interacts with interface- or switch-level IGMP snooping. `igmp_v3` boolean no 0 Unconfirmed if can be set. Unknown how it interacts with interface- or switch-level IGMP snooping.
