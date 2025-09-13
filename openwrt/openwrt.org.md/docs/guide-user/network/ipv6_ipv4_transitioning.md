# IPv4/IPv6 transition technologies

See also: [NAT64 for IPv6-only networks](/docs/guide-user/network/ipv6/nat64 "docs:guide-user:network:ipv6:nat64"), [NAT66 and IPv6 masquerading](/docs/guide-user/network/ipv6/ipv6.nat6 "docs:guide-user:network:ipv6:ipv6.nat6"), [IPv6 NAT and NPT](/docs/guide-user/firewall/fw3_configurations/fw3_nat#ipv6_nat "docs:guide-user:firewall:fw3_configurations:fw3_nat")

Transition technologies can be installed using the following packages:

- IPv6-in-IPv4 tunnels: [6rd](/packages/pkgdata/6rd "packages:pkgdata:6rd"), [6to4](/packages/pkgdata/6to4 "packages:pkgdata:6to4"), [6in4](/packages/pkgdata/6in4 "packages:pkgdata:6in4").
- IPv4-in-IPv6 tunnels: [ds-lite](/packages/pkgdata/ds-lite "packages:pkgdata:ds-lite").

## 6in4 Tunnel / HE.net Tunnel Broker

See also: [Setting up an IPv6 Tunnel with LuCI](/docs/guide-user/network/ipv6/ipv6tunnel-luci "docs:guide-user:network:ipv6:ipv6tunnel-luci"), [IPv6 with Hurricane Electric](/docs/guide-user/network/ipv6/ipv6_henet "docs:guide-user:network:ipv6:ipv6_henet")

6in4 tunnels are usually provided by external tunnel providers like HE.net.

![:!:](/lib/images/smileys/exclaim.svg) The package [6in4](/packages/pkgdata/6in4 "packages:pkgdata:6in4") must be installed to use this protocol.

![:!:](/lib/images/smileys/exclaim.svg) 6in4 requires you to have a public IPv4 address, clients behind CGNAT are [not supported](https://forums.he.net/index.php?topic=488.0 "https://forums.he.net/index.php?topic=488.0").

### Static IPv6-in-IPv4 Tunnel

The example below illustrates a static tunnel configuration for the Hurricane Electric (he.net) broker. option `ipaddr` specifies the local IPv4 address, `peeraddr` is the broker IPv4 address and `ip6addr` the local IPv6 address routed via the tunnel.

```
# /etc/config/network
config interface 'wan6'
        option proto        '6in4'
        option ipaddr       '178.24.115.19'
        option peeraddr     '216.66.80.30'
        option ip6addr      '2001:0DB8:1f0a:1359::2/64'
```

### Dynamic IPv6-in-IPv4 Tunnel (HE.net only)

The example below illustrates a dynamic tunnel configuration for the Hurricane Electric (he.net) broker with enabled IP update. The local IPv4 address is determined automatically. The options `tunnelid`, `username` and `updatekey` are provided for IP update.

```
# /etc/config/network
config interface 'wan6'
        option proto     '6in4'
        option mtu       '1424'                      # the IPv6 tunnel MTU (optional)
        option peeraddr  '216.66.80.30'              # the IPv4 tunnel endpoint at the tunnel provider
        option ip6addr   '2001:0db8:1f0a:1359::2/64' # the IPv6 tunnel address
        option ip6prefix '2001:db8:1234::/48'        # Your routed prefix (required)
        # configuration options below are only valid for HE.net tunnels, ignore them for other tunnel providers.
        option tunnelid  '12345'                     # HE.net tunnel id
        option username  'username'                  # HE.net username used to login into tunnelbroker, not the User ID shown after login in.
        option updatekey 'updatekey'                 # HE.net updatekey instead of password, default for new tunnels
```

See below for advanced configuration options.

In a typical tunnel configuration (e.g. HE.net) you get two different ipv6 addresses/prefixes from the tunnel provider:

- **ip6addr**: The tunnel endpoint address is like '2001:DB8:2222:EFGH::2/64'. This ...::2 address is only used for the tunnel interface endpoint. It is not a routable address and it can't be used for anything else than connecting to the other end of the tunnel, typically ...::1 .
- **ip6prefix**: The tunnel provider gives you also a routable prefix, typically either /48 or /64, for example '2001:DB8:1112::/48' or '2001:DB8:1234:ABCD::/64'. Your LAN clients will get addresses from that prefix. Using a wider prefix helps delegate IPv6 to several downstream networks.

#### Firewall

Some users may require to add extra firewall rules to allow 6in4 traffic to always reach their tunnel endpoint. The package [iptables-mod-ipopt](/packages/pkgdata/iptables-mod-ipopt "packages:pkgdata:iptables-mod-ipopt") must be installed for length matching.

```
# /etc/config/firewall
config rule
        option name      'Allow-protocol-41'
        option src       'wan'
        option proto     '41'
        option target    'ACCEPT'
 
config rule
        option name      'Allow-protocol-59'
        option src       'wan'
        option proto     '59'
        option target    'ACCEPT'
        option extra     '-m length --length 40'
```

#### Default route

Provide default route to override `sourcefilter`.

```
# /etc/config/network
config route6
        option interface 'wan6'
        option target    '::/0'
```

## Protocol 6in4 (IPv6-in-IPv4 Tunnel)

Name Type Required Default Description `ipaddr` IPv4 address no Current WAN IPv4 address Local IPv4 endpoint address `peeraddr` IPv4 address yes *(none)* Remote IPv4 endpoint address `ip6addr` IPv6 address (CIDR) yes *(none)* Local IPv6 address delegated to the tunnel endpoint `ip6prefix` IPv6 prefix no *(none)* Routed IPv6 prefix for downstream interfaces (Barrier Breaker and later only) `tunlink` Logical Interface no *(none)* Tunnel base interface. Define which Interface, for example WAN, should be used for outgoing IPv4 traffic to the Remote IPv4 Address `defaultroute` boolean no `1` Whether to create an IPv6 default route over the tunnel `ttl` integer no `64` TTL used for the tunnel interface `tos` string no *(none)* Type Of Service : either “inherit” (the outer header inherits the value of the inner header) or an hexadecimal value. Also known as DSCP. `mtu` integer no `1280` MTU used for the tunnel interface `tunnelid` integer no *(none)* HE.net global tunnel ID, used for endpoint update `username` string no *(none)* HE.net username which you use to login into tunnelbroker, not the User ID shown after you have login in, plaintext, used for endpoint update `password` string no *(none)* HE.net password, plaintext, obsolete, used for endpoint update `updatekey` string no *(none)* HE.net updatekey, plaintext, overrides password since 2014-02, used for endpoint update `metric` integer no `0` Specifies the default route metric to use

![:!:](/lib/images/smileys/exclaim.svg) This protocol type does not need the `device` option set in the interface section. The interface name is derived from the section name, e.g. `config interface sixbone` would result in an interface named `6in4-sixbone`.

![:!:](/lib/images/smileys/exclaim.svg) Although `ip6prefix` isn't required, `sourcefilter` is enabled by default and prevents forwarding of packets unless `ip6prefix` is specified.

## 6rd Tunnel (ISP-Provided IPv6 Transition)

6rd is a tunnel mechanism based on 6to4. Unlike other tunneling mechanisms, 6rd is usually provided by the ISP itself.

![:!:](/lib/images/smileys/exclaim.svg) The package [6rd](/packages/pkgdata/6rd "packages:pkgdata:6rd") must be installed to use this protocol.

![:!:](/lib/images/smileys/exclaim.svg) The configuration of 6rd is usually auto-detected and manual configuration is not needed, simply installing the 6rd package (and rebooting) is usually enough.

![:!:](/lib/images/smileys/exclaim.svg) To automatically configure 6rd from dhcp you need to create an interface with `option auto 0` and put its name as the 'iface6rd' parameter. In addition you also need to add its name to a suitable firewall zone in `/etc/config/firewall`.

```
# /etc/config/network
config interface 'wan6'
        option proto '6rd'
        option peeraddr '77.174.0.2'
        option ip6prefix '2001:838:ad00::'
        option ip6prefixlen '40'
        option ip4prefixlen '16'
```

To debug 6rd via DHCP, enable [DHCP client logging](/docs/guide-user/network/protocol.dhcp#dhcp_client_scripts "docs:guide-user:network:protocol.dhcp"), reboot the router, and check the logs:

```
# logread -e ip6rd
ip6rd=16 40 2001:0838:ad00:0000:0000:0000:0000:0000 77.174.0.2
```

If this line isn't present, you need to obtain the correct values for peeraddr, ip6prefix, ip6prefixlen and ip4prefixlen from your ISP. The above ip6rd or the obtained values can be used to hardcode the 6rd tunnel. Remove or comment out the iface6rd line in the wan section.

![:!:](/lib/images/smileys/exclaim.svg) If you choose a name for your tunnel-interface different from `wan6`, be sure to add that network to the `wan` firewall-zone.

Below configuration options are only needed for hardcoding the 6rd tunnel.

## Protocol 6rd

Name Type Required Default Description `peeraddr` IPv4 address yes no 6rd - Gateway `ipaddr` IPv4 address no Current WAN IPv4 address Local IPv4 endpoint address `ip6prefix` IPv6 prefix (without length) yes no 6rd-IPv6 Prefix `ip6prefixlen` IPv6 prefix length yes no 6rd-IPv6 Prefix length `ip4prefixlen` IPv6 prefix length no 0 IPv4 common prefix `defaultroute` boolean no `1` Whether to create an IPv6 default route over the tunnel `ttl` integer no `64` TTL used for the tunnel interface `tos` string no *(none)* Type Of Service: either “inherit” (the outer header inherits the value of the inner header) or an hexadecimal value `mtu` integer no `1280` MTU used for the tunnel interface `iface6rd` logical interface no *(none)* Logical interface template for auto-configuration of 6rd `mtu6rd` integer no *system default* MTU of the 6rd interface `zone6rd` firewall zone no *system default* Firewall zone to which the 6rd interface should be added

![:!:](/lib/images/smileys/exclaim.svg) This protocol type does not need the `device` option set in the interface section. The interface name is derived from the section name, e.g. `config interface wan6` would result in an interface named `6rd-wan6`.

![:!:](/lib/images/smileys/exclaim.svg) Some ISP's give you the number of bytes you should use from your WAN IP to calculate your IPv6 address. `ip4prefixlen` expects the *prefix* bytes of your WAN IP to calculate the IPv6 address. So if your ISP gives you 14 bytes to calculate, enter 18 (32 - 14).

## 6pe, L2TP Tunnel (ISP-provided IPv6 Transition)

This is another transitional mechanism for IPv6 used by some ISPs, it relies on a L2TPv2 tunnel.

![:!:](/lib/images/smileys/exclaim.svg) The package [xl2tpd](/packages/pkgdata/xl2tpd "packages:pkgdata:xl2tpd") must be installed to use this protocol. It will handle the L2TP tunnel and PPP session.

The high-level description of the tunneling is the following:

1. An L2TP tunnel is created, encapsulated in UDP packets over IPv4.
2. A PPP session is established inside the tunnel.
3. IPv6CP (see [RFC 5072](http://tools.ietf.org/html/rfc5072 "http://tools.ietf.org/html/rfc5072")) is used to negotiate link-local IPv6 addresses.
4. An IPv6 prefix is obtained thanks to DHCPv6.

This howto is derived from an experience with SFR, in France (FTTH residential access). It might apply to other ISPs as well. In the case of SFR, steps 1 and 2 require an authentication. Fortunately, the L2TP password is hardcoded. The PPP password is not, but it's sent as cleartext, so a simple sniffing is enough to recover it.

```
# /etc/config/network
config interface 6pe
        option proto l2tpv2
        option server <LNS address>
        option username '<PPP username>'
        option password '<PPP password>'
        option keepalive '6'
        option ipv6 '1'
 
config interface 'wan6'
        option device '@6pe'
        option proto 'dhcpv6'
```

If you need authentication at the L2TP level (before PPP):

```
# /etc/xl2tpd/xl2tp-secrets
* * my_l2tp_password
```

At this point, running `service network reload` or simply running `ifup wan6` should give you a fully working IPv6 setup. To debug, look at the logs (`logread`) and the interfaces status (`ifstatus 6pe` and `ifstatus wan6`).

Advanced options for this protocol are below.

## Protocol l2tp (PPP over L2TP Tunnel)

Most options are similar to protocol “ppp”.

Name Type Required Default Description `server` string yes *(none)* L2TP server to connect to. Acceptable datatypes are hostname or IP address, with optional port separated by colon `:`. Note that specifying port is only supported recently and should appear in DD release `username` string no *(none)* Username for PAP/CHAP authentication `password` string yes if `username` is provided *(none)* Password for PAP/CHAP authentication `ipv6` bool no 0 Enable IPv6 on the PPP link (IPv6CP) `mtu` int no `pppd` default Maximum Transmit/Receive Unit, in bytes `keepalive` string no *(none)* Number of unanswered echo requests before considering the peer dead. The interval between echo requests is 5 seconds. `checkup_interval` int no *(none)* Number of seconds to pass before checking if the interface is not up since the last setup attempt and retry the connection otherwise. Set it to a value sufficient for a successful L2TP connection for you. It's mainly for the case that netifd sent the connect request yet xl2tpd failed to complete it without the notice of netifd `pppd_options` string no *(none)* Additional options to pass to `pppd`

The name of the physical interface will be “l2tp-&lt;logical interface name&gt;”.

## 6to4 Tunnel

6to4 is the simplest IPv6 tunneling mechanism and relies on publicly available gateways.

![:!:](/lib/images/smileys/exclaim.svg) The package [6to4](/packages/pkgdata/6to4 "packages:pkgdata:6to4") must be installed to use this protocol.

```
# /etc/config/network
config interface 'wan6'
        option proto '6to4'
 
# /etc/config/firewall
config rule
        option target 'ACCEPT' 
        option name '6to4' 
        option src 'wan' 
        option proto '41'
```

![:!:](/lib/images/smileys/exclaim.svg) If you choose a name for your tunnel-interface different from `wan6`, be sure to add that network to the `wan` firewall-zone.

See below for advanced configuration options.

## Protocol 6to4 (IPv6-in-IPv4 Tunnel)

Name Type Required Default Description `ipaddr` IPv4 address no Current WAN IPv4 address Local IPv4 endpoint address `defaultroute` boolean no `1` Whether to create an IPv6 default route over the tunnel `ttl` integer no `64` TTL used for the tunnel interface `tos` string no *(none)* Type Of Service : either “inherit” (the outer header inherits the value of the inner header) or an hexadecimal value `mtu` integer no `1280` MTU used for the tunnel interface `metric` integer no `0` Specifies the default route metric to use

![:!:](/lib/images/smileys/exclaim.svg) This protocol type does not need the `device` option set in the interface section. The interface name is derived from the section name, e.g. `config interface wan6` would result in an interface named `6to4-wan6`.

## Dual-Stack Lite tunnel (ds-lite IPv4 in IPv6)

ds-lite is a transitioning-mechanism which is used by ISPs to support legacy IPv4-connectivity over a native IPv6 connection.

![:!:](/lib/images/smileys/exclaim.svg) The package [ds-lite](/packages/pkgdata/ds-lite "packages:pkgdata:ds-lite") must be installed to use this protocol.

![:!:](/lib/images/smileys/exclaim.svg) The configuration is usually auto-detected and manual configuration is not needed, simply installing the ds-lite package (and restarting the network interfaces like when changing the configuration) is usually enough.

```
# /etc/config/network
config interface 'wan6'
        option device 'eth1'
        option proto 'dhcpv6'
 
config interface 'wan'
        option proto 'dslite'
        option peeraddr '2001:db80::1' # Your ISP's DS-Lite AFTR
```

![:!:](/lib/images/smileys/exclaim.svg) If you choose a name for your tunnel-interface different from `wan`, be sure to add that network to the `wan` firewall-zone.

See below for advanced configuration options.

## Protocol dslite (Dual-Stack Lite)

Name Type Required Default Description `peeraddr` IPv6 address yes no DS-Lite AFTR address `ip6addr` IPv6 address no Current WAN IPv6 address Local IPv6 endpoint address `tunlink` Logical Interface no Current WAN interface Tunnel base interface `defaultroute` boolean no `1` Whether to create an IPv6 default route over the tunnel `ttl` integer no `64` TTL used for the tunnel interface `mtu` integer no `1280` MTU used for the tunnel interface

![:!:](/lib/images/smileys/exclaim.svg) ds-lite operation requires that IPv4 NAT is disabled. You should adjust your settings in /etc/config/firewall accordingly.

![:!:](/lib/images/smileys/exclaim.svg) This protocol type does not need the `device` option set in the interface section. The interface name is derived from the section name, e.g. `config interface wan` would result in an interface named `dslite-wan`.
