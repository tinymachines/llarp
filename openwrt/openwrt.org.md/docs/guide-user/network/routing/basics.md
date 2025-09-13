# Routing basics

See also: [IP Layer Network Administration](http://linux-ip.net/pages/the-guide.html "http://linux-ip.net/pages/the-guide.html"), [IP routing tutorial](https://www.inetdaemon.com/tutorials/internet/ip/routing/ "https://www.inetdaemon.com/tutorials/internet/ip/routing/")

[Routing](https://en.wikipedia.org/wiki/Routing "https://en.wikipedia.org/wiki/Routing") is the process of selecting a path to send network traffic. There are several [routing protocols](https://en.wikipedia.org/wiki/Routing_protocol "https://en.wikipedia.org/wiki/Routing_protocol") for *dynamic routing*, specifically [B.A.T.M.A.N.](/docs/guide-user/network/wifi/mesh/batman "docs:guide-user:network:wifi:mesh:batman") and [OLSR](/docs/guide-user/network/wifi/mesh/olsr "docs:guide-user:network:wifi:mesh:olsr") for mesh networking, however *static routing* is typically enough for most use cases. Routing is handled by a kernel component and can be configured by the user space tool [ip](http://man.cx/ip%288%29 "http://man.cx/ip%288%29") from the package [iproute2](https://en.wikipedia.org/wiki/iproute2 "https://en.wikipedia.org/wiki/iproute2"). Note that by default OpenWrt announces IPv6 default route only for GUA and applies source filter for IPv6 that allows routing only for prefixes delegated from the upstream router.

## How it works

### Basic routing

In a trivial case, the route is selected by the traffic destination, highest netmask and lowest metric. Routing rules are expected to be in their default state and can be basically ignored, the same applies to routing tables other than the `main` table.

### Policy-based routing

See also: [Policy-based routing](/docs/guide-user/network/routing/pbr "docs:guide-user:network:routing:pbr")

In general case, the kernel iterates over the routing rules from lower to higher numeric priority values. By default, only the `main` routing table contains the default route and the corresponding rule is automatically created with a priority of `32766`. If we utilize custom routing tables with `ip4table` and/or `ip6table` options, netifd creates the rules for each local address as source and each local subnet as destination with respective priorities of `10000` and `20000`. To override the default route in the `main` table, we can add a rule with a priority of about `30000`, or assign each upstream interface to a separate routing table and lookup it after the `main` table.

## Configuration

See also: [Static routes](/docs/guide-user/network/routing/routes_configuration "docs:guide-user:network:routing:routes_configuration"), [Routing rules](/docs/guide-user/network/routing/ip_rules "docs:guide-user:network:routing:ip_rules")

`/etc/config/network` is the UCI configuration file where all routing related adjustments are made in OpenWrt.

### Default routing tables

See also: [ip-route](http://man.cx/ip-route%288%29 "http://man.cx/ip-route%288%29")

ID Name Description `0` `unspec` Special table matching all table names/IDs. `253` `default` Reserved table, empty by default. `254` `main` Routing table with all non-policy routes. `255` `local` Special table with local and broadcast addresses.

Edit `/etc/iproute2/rt_tables` to customize routing tables.

### Default routing rules

See also: [ip-rule](http://man.cx/ip-rule%288%29 "http://man.cx/ip-rule%288%29")

Priority Match Lookup table Description `0` anything `local` High priority routing for local and broadcast addresses. `10000` local addresses as source `<custom>` A list of rules for each local address created by netifd when using `ip4table` or `ip6table`. `20000` local subnets as destination `<custom>` A list of rules for each local subnet created by netifd when using `ip4table` or `ip6table`. `32766` anything `main` Non-policy routing, can be overridden with other rules by the administrator, also offers routes for tunnel endpoints. `32767` IPv4 traffic `default` Post-processing for IPv4 traffic missed by previous rules. `90000+` traffic from local system `<custom>` A list of rules for each interface created by netifd when using `ip4table` or `ip6table`, works as failover for traffic from the local system. `4200000000+` IPv6 traffic to interfaces `-` A list of terminating rules automatically created for each IPv6 interface.

## Testing

Verify your routing [traceroute](http://man.cx/traceroute%288%29 "http://man.cx/traceroute%288%29") and [traceroute6](http://man.cx/traceroute6%288%29 "http://man.cx/traceroute6%288%29").

```
traceroute openwrt.org
traceroute6 openwrt.org
```

Check your IP and DNS provider.

- [ipleak.net](https://ipleak.net/ "https://ipleak.net/")
- [dnsleaktest.com](https://www.dnsleaktest.com/ "https://www.dnsleaktest.com/")

Test routing for a specific destination.

```
ip route get 198.51.100.1
ip route get 198.51.100.1 from 192.168.1.1
ip route get 2001:db8::1
ip route get 2001:db8::1 from fd00:1::1
```

## Troubleshooting

Collect and analyze the following information.

```
# Restart services
service log restart; service network restart; sleep 10
 
# Log and status
logread; ifstatus wan; ifstatus wan6
 
# Runtime configuration
ip address show; ip route show table all
ip rule show; ip -6 rule show; nft list ruleset
 
# Persistent configuration
uci show network; uci show dhcp; uci show firewall
grep -v -e "^#" -e "^$" /etc/iproute2/rt_tables
```
