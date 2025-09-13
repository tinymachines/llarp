# IPv6 configuration

See also: [Static IPv6 routes](/docs/guide-user/network/routing/routes_configuration#ipv6_routes "docs:guide-user:network:routing:routes_configuration"), [IPv6 routing example](/docs/guide-user/network/routing/examples/routing_with_ipv6 "docs:guide-user:network:routing:examples:routing_with_ipv6"), [IPv4/IPv6 transitioning](/docs/guide-user/network/ipv6_ipv4_transitioning "docs:guide-user:network:ipv6_ipv4_transitioning"), [IPv6 extras](/docs/guide-user/network/ipv6/ipv6_extras "docs:guide-user:network:ipv6:ipv6_extras"), [IPv6 Troubleshooting](/docs/guide-user/network/ipv6/troubleshooting "docs:guide-user:network:ipv6:troubleshooting")

The default firmware provides full IPv6 support with a DHCPv6 client (`odhcp6c`), an RA &amp; DHCPv6 Server (`odhcpd`) and a IPv6 firewall (`ip6tables`).  
Also, the default installation of the web interface includes the package `luci-proto-ipv6`, required to configure IPv6 from the `luci` web interface.

![:!:](/lib/images/smileys/exclaim.svg) If you are making a custom build please note that the packages stated above must be installed to provide the corresponding IPv6 functionality.

### Compliance

Our aim is to follow [RFC 7084](https://datatracker.ietf.org/doc/html/rfc7084 "https://datatracker.ietf.org/doc/html/rfc7084") where possible.  
Please notify us if you find any standard violations.

The following requirements of [RFC 7084](https://datatracker.ietf.org/doc/html/rfc7084 "https://datatracker.ietf.org/doc/html/rfc7084") are currently known not to be met:

- [RFC 7084](https://datatracker.ietf.org/doc/html/rfc7084 "https://datatracker.ietf.org/doc/html/rfc7084") WAA-5 (SHOULD-requirement): The NTP-Server is requested and received but currently not processed or used.

### General features

- Prefix handling:
  
  - Management of prefixes, addresses and routes from upstream connections and local ULA-prefixes
  - Management of prefix unreachable-routes, prefix deprecation ([RFC 7084](https://datatracker.ietf.org/doc/html/rfc7084 "https://datatracker.ietf.org/doc/html/rfc7084")) and prefix classes
  - Distribution of prefixes onto downstream interfaces (including size, ID and class hints)
  - Source-based policy routing to correctly handle multiple uplink interfaces, ingress policy filtering ([RFC 7084](https://datatracker.ietf.org/doc/html/rfc7084 "https://datatracker.ietf.org/doc/html/rfc7084"))

## Upstream configuration for WAN interfaces

The following sections describe the configuration of IPv6 connections to your ISP or an upstream router. Please note that most tunneling mechanisms like 6in4, 6rd and 6to4 may not work behind a NAT-router. Multiple IPv6 addresses can be assigned with [aliases](/docs/guide-user/network/network_interface_alias "docs:guide-user:network:network_interface_alias").

### Native IPv6 connection

- Automatic bootstrap from SLAAC, stateless DHCPv6, stateful DHCPv6, DHCPv6-PD and any combination
- Handling of preferred and valid address and prefix lifetimes
- Duplicate address (DAD) and Link-MTU detection
- DHCPv6 Extensions: Reconfigure, Information-Refresh, SOL\_MAX\_RT=3600
- DHCPv6 Extensions: RDNSS, DNS Search Domain, NTP, SIP, ds-lite, prefix exclusion (experimental)

For an uplink with native IPv6-connectivity you can use the following example configuration. It will work both for uplinks supporting DHCPv6 with Prefix Delegation and those that don't support DHCPv6-PD or DHCPv6 at all (SLAAC-only).

```
# cat /etc/config/network
config interface wan
        option ipv6 1 # only required for PPP-based protocols
        ...
 
config interface wan6
        option device   eth1 # use same device as in wan-section or "@wan"
        option proto    dhcpv6
 
config interface lan
        option proto    static
        option ip6assign 60
        ...
```

See below for advanced configuration options of protocol **dhcpv6**.

#### PPP-based protocols and option ipv6

PPP-based protocols - for example pppoe and pppoa - require that `option ipv6` is specified in the parent `config interface wan` section. See [WAN interface protocols](/docs/guide-user/network/wan/wan_interface_protocols "docs:guide-user:network:wan:wan_interface_protocols"). **option ipv6** can take the value:

- **0**: disable IPv6 on the interface
- **1**: enable IPCP6 negotiation on the interface, but nothing else. If successful, the parent interface will be assigned a [link-local address](https://en.wikipedia.org/wiki/Link-local_address "https://en.wikipedia.org/wiki/Link-local_address") (prefix fe80::/10). All other IPv6 configuration is made in the `wan6` interface which must be configured manually, as described below.
- **auto**: (default) enable IPv6 on the interface. Spawn a virtual interface wan\_6 (note the underscore) and start DHCPv6 client odhcp6c to manage prefix assignment. Ensure the lan interface has `option ip6assign 64` (or a larger prefix size) set to redistribute the received prefix downstream.

Further configuration options, if required, can be given in the `config interface wan6` section.

Note: In order to successfully receive DHCPv6 advertisement unicast messages from the dhcp6s to OpenWrt dhcp6c, you will need to have firewall rule for the WAN zone (already allowed in default):

```
# cat /etc/config/firewall
....
config rule
        option target 'ACCEPT'
        option src 'wan'
        option proto 'udp'
        option dest_port '546'
        option name 'Allow DHCPv6 replies'
        option family 'ipv6'
        option src_port '547'
```

### Protocol "dhcpv6"

These are available options in uci configuration of client ipv6 interface (using the “dhcpv6” protocol).

Name Type Required Default Description `reqaddress` \[try,force,none] no try Behaviour for requesting addresses `reqprefix` \[auto, no, 0-64, &lt;prefix/length&gt;] no auto Specifies the behavior for requesting IPv6 prefixes. Numbers denote hinted prefix length (e.g., 0-64). If set to no, only a single IPv6 address is requested for the AP itself, without a subnet for routing. Alternatively, a specific IPv6 prefix and length can be specified in the &lt;prefix/length&gt; format (e.g., 2001:db8::/56), which allows requesting a specific IPv6 prefix when dynamically issued by the upstream. `clientid` hexstring no *DUID-LL (type 3)* Override client identifier in DHCP requests (Option 1). The odhcp6c default is `00030001` concatenated with the `device` MAC address - see [RFC 8415](https://datatracker.ietf.org/doc/html/rfc8415#section-11.4 "https://datatracker.ietf.org/doc/html/rfc8415#section-11.4") `ifaceid` ipv6 addr no *link-local identifier* Override the interface identifier for adresses received via RA (Router Advertisement) `dns` list of ip addresses no *(none)* Supplement DHCP-assigned DNS server(s), or use only these if peerdns is 0 `peerdns` boolean no `1` Use DHCP-provided DNS server(s) `keep_ra_dnslifetime` boolean no `0` Ignore default lifetime for RDNSS records [More info](https://github.com/openwrt/odhcp6c/commit/d420f49396c627ce1072b83170889baf0720bc8b "https://github.com/openwrt/odhcp6c/commit/d420f49396c627ce1072b83170889baf0720bc8b") `defaultroute` boolean no `1` Whether to create an IPv6 default route via the received gateway `reqopts` list of numbers no *(none)* Specifies a list of additional DHCP options to request `defaultreqopts` boolean no `1` If set to `0`, do not request any options except those specified in `reqopts` `sendopts` string no *(none)* Space-separated list of additional DHCP options to send to the server. Syntax: `option:value` where `option` is either an integer code or a symbolic name such as `hostname`. `noslaaconly` boolean no `0` Don't allow configuration via SLAAC (RAs) only (implied by reqprefix != no) `forceprefix` boolean no `0` Require presence of IPv6 Prefix in received DHCP message `norelease` boolean no `0` Don't send a RELEASE when the interface is brought down `ip6prefix` ipv6 prefix no *(none)* Use an (additional) user-provided IPv6 prefix for distribution to clients `extendprefix` boolean no `0` On a 3GPP Mobile WAN link, accept a /64 prefix via SLAAC and extend it on one downstream interface - see [RFC 7278](https://datatracker.ietf.org/doc/html/rfc7278 "https://datatracker.ietf.org/doc/html/rfc7278") `iface_dslite` logical interface no *(none)* Logical interface template for auto-configuration of DS-Lite (0 means disable DS-Lite autoconfiguration; every other value will autoconfigure DS-Lite when the AFTR-Name option is received) `zone_dslite` string no *(none)* Firewall zone of the logical DS-Lite interface `iface_map` string no *(none)* Logical interface template for auto-configuration of either map-e/map-t/lw6o4 autoconfiguration (0 means disable map-e/map-t/lw406 autoconfiguration; every other value will autoconfigure map-e/map-t/lw4o6 when the corresponding Softwire46 options are received) `zone_map` string no *(none)* Firewall zone of the logical map-e/map-t/lw6o4 interface `iface_464xlat` string no *(none)* Logical interface template for the 464xlat interface (0 means disable 464xlat autoconfiguration; every other value will try to autoconfigure 464xlat) `zone_464xlat` string no *(none)* Firewall zone of the logical 464xlat interface `zone` string no *(none)* Firewall zone to which the interface will be added `sourcefilter` boolean no `1` Whether to enable source based IPv6 routing `vendorclass` string no *(none)* Vendor class to be included in the DHCP messages (Option 16) `userclass` string no *(none)* User class to be be included in the DHCP messages (Option 15) `delegate` boolean no `1` Whether to enable prefix delegation in case of DS-Lite/map/464xlat `soltimeout` integer no `120` The maximum solicit timeout `fakeroute` boolean no `1` Fake default route when no route info via RA is received `ra_holdoff` integer no `3` Minimum time in seconds between accepting RA updates `noclientfqdn` boolean no `0` Don't send Client FQDN option (Option 39). The unset default uses the system hostname e.g. `OpenWrt` `noacceptreconfig` boolean no `0` Don't send Accept Reconfigure option [More info](https://github.com/openwrt/odhcp6c/commit/dc30922e418be6271ad177f3f9d4ecf0c1eb3f01 "https://github.com/openwrt/odhcp6c/commit/dc30922e418be6271ad177f3f9d4ecf0c1eb3f01") `noserverunicast` boolean no `0` Ignore Server Unicast option [More info](https://github.com/openwrt/odhcp6c/commit/67ae6a71b5762292e114b281d0e329cc24209ae6 "https://github.com/openwrt/odhcp6c/commit/67ae6a71b5762292e114b281d0e329cc24209ae6") `skpriority` integer no `0` Set packet kernel priority [More info](https://github.com/openwrt/odhcp6c/commit/bcd283632ac13391aac3ebdd074d1fd832d76fa3 "https://github.com/openwrt/odhcp6c/commit/bcd283632ac13391aac3ebdd074d1fd832d76fa3") `verbose` boolean no `0` Increase logging verbosity

**Note:** To automatically configure ds-lite from dhcpv6, you need to create an interface with `option auto 0` and put its name as the 'iface\_dslite' parameter. In addition, you also need to add its name to a suitable firewall zone in /etc/config/firewall.

### Static IPv6 connection

Static configuration of the IPv6 uplink is supported as well. The following example demonstrates this.

```
# cat /etc/config/network
config interface wan
        option device   eth1
        option proto    static
        option ip6addr  2001:db80::2/64   # Own address
        option ip6gw    2001:db80::1      # Gateway address
        option ip6prefix 2001:db80:1::/48 # Prefix addresses for distribution to downstream interfaces
        option dns      2001:db80::1      # DNS server
 
config interface lan
        option proto    static
        option ip6assign 60
        ...
```

For advanced configuration options see below for the usable options in a IPv6 “static” protocol:

### Protocol "static", IPv6

Name Type Required Default Description `ip6addr` ipv6 address yes, if no `ipaddr` is set *(none)* Assign given IPv6 address to this interface (CIDR notation) `ip6ifaceid` ipv6 suffix no ::1 Allowed values: 'eui64', 'random', fixed value like '::1:2'. It is advised to **NOT** use just '::' as this is a [reserved anycast address](https://www.rfc-editor.org/rfc/rfc4291#section-2.6.1 "https://www.rfc-editor.org/rfc/rfc4291#section-2.6.1")'  
When IPv6 prefix (like 'a:b:c:d::') is received from a delegating server, use the suffix (like '::1') to form the IPv6 address ('a:b:c:d::1') for this interface. Useful with several routers in LAN. The option was introduced by [this commit](http://git.openwrt.org/?p=project%2Fnetifd.git%3Ba%3Dcommitdiff%3Bh%3D0b0e5e2fc5b065092644a5c4717c0a03a9098dcf%3Bhp%3De9d2014a478807c7fac0581bb4a145901a3f23b4 "http://git.openwrt.org/?p=project/netifd.git;a=commitdiff;h=0b0e5e2fc5b065092644a5c4717c0a03a9098dcf;hp=e9d2014a478807c7fac0581bb4a145901a3f23b4") to netifd in Jan 2015. `ip6gw` ipv6 address no *(none)* Assign given IPv6 default gateway to this interface `ip6assign` prefix length no *(none)* Delegate a prefix of given length to this interface (see Downstream configuration below) `ip6hint` prefix hint (hex) no *(none)* Hint the subprefix-ID that should be delegated as hexadecimal number (see Downstream configuration below) `ip6prefix` ipv6 prefix no *(none)* IPv6 prefix routed here for use on other interfaces (Barrier Breaker and later only) `ip6class` list of strings no *(none)* Define the IPv6 prefix-classes this interface will accept `ip6deprecated` boolean no `0` Set preferred lifetime of IPv6 addresses to zero `dns` list of ip addresses no *(none)* DNS server(s) `dns_metric` integer no `0` [DNS metric](https://git.openwrt.org/?p=project%2Fnetifd.git%3Ba%3Dcommitdiff%3Bh%3D7f6be657e2dabc185417520de4d0d0de2580c27d "https://git.openwrt.org/?p=project/netifd.git;a=commitdiff;h=7f6be657e2dabc185417520de4d0d0de2580c27d") `dns_search` list of domain names no *(none)* Search list for host-name lookup, relevant only for the router `metric` integer no `0` Specifies the default route metric to use

## Downstream configuration for LAN interfaces

- Server support for Router Advertisement, DHCPv6 (stateless and stateful) and DHCPv6-PD
- Automatic detection of announced prefixes, delegated prefixes, default routes and MTU
- Change detection for prefixes and routes triggering resending of RAs and DHCPv6-Reconfigure
- Detection of client hostnames and export as augmented hosts-file
- Support for RA &amp; DHCPv6-relaying and NDP-proxying to e.g. support uplinks without prefix delegation

OpenWrt provides a flexible local prefix delegation mechanism.

It can be tuned for each downstream-interface individually with 3 parameters which are all optional:

- `ip6assign`: Prefix size used for assigned prefix to the interface (e.g. 64 will assign /64-prefixes)
- `ip6hint`: Subprefix ID to be used if available (e.g. 1234 with an ip6assign of 64 will assign prefixes of the form ...:1234::/64 or given LAN ports, LAN &amp; LAN2, and a prefix delegation of /56, use ip6hint of 00 and 80 which would give prefixes of LAN ...:xx00::/64 and LAN2 ...:xx80::/64)
- `ip6class`: Filter for prefix classes to accept on this interface (e.g. `wan6` - only assign prefix from the respective interface, `local` - only assign the ULA-prefix)

`ip6assign` and / or `ip6hint` settings might be ignored if the desired subprefix cannot be assigned. In this case, the system will first try to assign a prefix with the same length but different subprefix-ID. If this fails as well, the prefix length is reduced until the assignment can be satisfied. If `ip6hint` is not set, an arbitrary ID will be chosen. Setting the `ip6assign` parameter to a value &lt; 64 will allow the DHCPv6-server to hand out all but the first /64 via DHCPv6-Prefix Delegation to downstream routers on the interface. If `ip6hint` is not suitable for the given `ip6assign`, it will be rounded down to the nearest possible value.

If `ip6class` is not set, then all prefix classes are accepted on this interface. Specify one or multiple interface names such as `wan6` to accept only prefix from the respective interface, or specify `local` accept only the ULA-prefix when using IPv6 NAT or NPT. This can be used to select upstream interfaces from which subprefixes are assigned. For prefixes received from dynamic-configuration methods like DHCPv6, it is possible that the prefix-class is not equal to the source-interface but e.g. augmented with an ISP-provided numeric prefix class-value.

```
# cat /etc/config/network
config globals globals
        option ula_prefix fd00:db80::/48
 
config interface wan6
        option proto static
        option ip6prefix 2001:db80::/56
        ...
 
config interface lan
        option proto static
        option ip6assign 60
        option ip6hint 10
        ...
 
config interface guest
        option proto static
        option ip6assign 64
        option ip6hint abcd
        list ip6class wan6
        ...
```

The results of that configuration would be:

- The `lan` interface will be assigned the prefixes 2001:db80:0:10::/60 and fd00:db80:0:10::/60.
- The DHCPv6-server can offer both prefixes except 2001:db80:0:abcd::/64 and fd00:db80:0:abcd::/64 to downstream routers on `lan` via DHCPv6-PD.
- The `guest` interface will only get assinged the prefix 2001:db80:0:abcd::/64 due to the class filter.

For multiple interfaces, the prefixes are assigned based on firstly the assignment length (smallest first) then on weight and finally alphabetical order of interface names. e.g. if wlan0 and eth1 have ip6assign 61 and eth2 has ip6assign 62, the prefixes are assigned to eth1 then wlan0 (alphabetic) and then eth2 (longest prefix). Note that if there are not enough prefixes, the last interfaces get no prefix - which would happen to eth2 if the overall prefix length was 60 in this example.

![:!:](/lib/images/smileys/exclaim.svg) If the router can `ping6` the internet, but lan machines get “Destination unreachable: Unknown code 5” or “Source address failed ingress/egress policy” then the **ip6assign** option is missing on your lan interface.

## Router Advertisement &amp; DHCPv6

OpenWrt features a versatile RA &amp; DHCPv6 server and relay. Per default, SLAAC and both stateless and stateful DHCPv6 are enabled on an interface. If there are any prefixes of size /64 or shorter present then addresses will be handed out from each prefix. If all addresses on an interface have prefixes shorter than /64, then DHCPv6 Prefix Delegation is enabled for downstream routers. If a default route is present, the router advertises itself as default router on the interface.

The system is also able to detect when there is no prefix available from an upstream interface and can switch into relaying mode automatically to extend the upstream interface configuration onto its downstream interfaces. This is useful for putting the target router behind another IPv6 router which doesn't offer prefixes via DHCPv6-PD.

### SLAAC and DHCPv6

Example configuration section for SLAAC + DHCPv6 server mode. This is suitable also for a typical 6in4 tunnel configuration, where you specify the fixed LAN prefix in the tunnel interface config. Make sure to disable NDP-Proxy by removing the `ndp` option if any.

```
# cat /etc/config/dhcp
config dhcp lan
    option dhcpv6 server
    option ra server
    option ra_flags 'managed-config other-config'
    ...
```

### SLAAC only

Example configuration section for SLAAC alone. Make sure to deactivate RA flags, otherwise clients expect the presence of a DHCPv6 and consequently may fail to activate the network connection. Note that disabling DHCPv6 makes some clients (e.g. Android devices) prefer IPv4 over IPv6.

```
# cat /etc/config/dhcp
config dhcp lan
    option dhcpv6 disabled
    option ra server
    list ra_flags 'none'
    ...
```

### IPv6 relay

Example configuration section for relaying

```
# cat /etc/config/dhcp
config dhcp lan
    option dhcpv6 relay
    option ra relay
    option ndp relay
    ...
 
config dhcp wan6
    option dhcpv6 relay
    option ra relay
    option ndp relay
    option master 1
    option interface wan6
```

## Routing Management

OpenWrt uses a source-address and source-interface based policy-routing system. This is required to correctly handle different uplink interfaces. Each delegated prefix is added with an unreachable route to avoid IPv6-routing loops.

To determine the current status of routes you can consult the information provided by `ifstatus`.

Example (ifstatus wan6):

```
...
        "ipv6-address": [
                {
                        "address": "2001:db80::a00:27ff:fe67:cd9c",
                        "mask": 64,
                        "preferred": 1681,
                        "valid": 7081
                }
        ],
        "ipv6-prefix": [
                {
                        "address": "2001:db80:0:100::",
                        "mask": 56,
                        "preferred": 86282,
                        "valid": 86282,
                        "class": "wan6",
                        "assigned": {
                                "lan": {
                                        "address": "2001:db80:0:110::",
                                        "mask": 60
                                }
                        }
                }
        ],
        "route": [
                {
                        "target": "2001:db80::",
                        "mask": 48,
                        "nexthop": "fe80::800:27ff:fe00:0",
                        "metric": 1024,
                        "valid": 7081
                },
                {
                        "target": "::",
                        "mask": 0,
                        "nexthop": "fe80::800:27ff:fe00:0",
                        "metric": 1024,
                        "valid": 7081
                }
        ],
...
```

Interpretation:

- On the interface 2 routes are provided: 2001:db80::/48 and a default-route via the router fe80::800:27ff:fe00:0.
- These routes can only be used by locally generated traffic and traffic with a suitable source-address, that is either one of the local addresses or an address out of the delegated prefix.

## ULA prefix

IPv6 [ULA prefix](/docs/guide-user/network/network_configuration?s=ula_prefix#section_globals "docs:guide-user:network:network_configuration") can serve the following purposes:

- Predictable [static IPv6](/docs/guide-user/base-system/dhcp_configuration#static_leases "docs:guide-user:base-system:dhcp_configuration") suffix allocation with DHCPv6.
- Predictable site-to-site connectivity with dynamic or missing GUA prefix.
- IPv6 routing for LAN clients behind [NAT66](/docs/guide-user/network/ipv6/ipv6.nat6 "docs:guide-user:network:ipv6:ipv6.nat6") with missing GUA prefix.

If IPv6 GUA is not available, a [workaround](/docs/guide-user/network/ipv6/ipv6_extras#using_ipv6_by_default "docs:guide-user:network:ipv6:ipv6_extras") is generally required to make applications prefer IPv6 over IPv4.

## Troubleshooting

Assistance diagnosing issues available at [IPv6 Troubleshooting](/docs/guide-user/network/ipv6/troubleshooting "docs:guide-user:network:ipv6:troubleshooting")
