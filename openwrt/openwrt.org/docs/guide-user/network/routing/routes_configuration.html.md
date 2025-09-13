# Static routes

Netifd supports static *IP route* declarations which are required to implement basic routing.

## IPv4 routes

Static *IPv4 routes* can be defined on specific interfaces using `route` sections. As for *aliases*, multiple sections can be attached to an interface. The `route` sections are stored in the uci file `/etc/config/network`.

A minimal example looks like this:

```
config route 'route_example_1'
        option interface 'lan'
        option target '172.16.123.0'
        option netmask '255.255.255.0'
        option gateway '172.16.123.100'
```

- `lan` is the *logical interface name* of the parent interface
- `172.16.123.0` is the *network address* of the route
- `255.255.255.0` specifies the *route netmask*

Another example, creating a default route for table 100 with the gateway `10.72.197.110`:

```
config route 'route_example_2'
        option interface 'vpn'
        option target '0.0.0.0/0'
        option table '100'
        option gateway '10.72.197.110'
```

- `vpn` is the *logical interface name* of the parent interface
- `0.0.0.0/0` is the *subnet address* all includes all IPs, because we use a subnet we don't need to use netmask
- `100` is the specific *table number*, if you want it to be shown as a name, add it to `/etc/iproute2/rt_tables`

This is a persistent equivalent to the runtime command:

```
ip route add default via 10.72.197.110 table 100
```

### Options for IPv4 routes

Name Type Required Default Description `interface` string yes *(none)* Specifies the *logical interface name* of the parent (or master) interface this route belongs to; must refer to one of the defined `interface` sections `target` ip address yes *(none)* Network address `netmask` netmask no *(none)* Route netmask. If omitted, `255.255.255.255` is assumed which makes `target` a *host address* `gateway` ip address no *(none)* Network gateway. If omitted, the `gateway` from the parent interface is taken if any, otherwise creates a `link` scope route; if set to `0.0.0.0` no gateway will be specified for the route `metric` number no `0` Specifies the *route metric* to use `mtu` number no *interface MTU* Defines a specific MTU for this route `table` routing table no `main` Defines the table ID to use for the route. The ID can be either a numeric table index ranging from 0 to 65535 or a symbolic alias declared in `/etc/iproute2/rt_tables`. The special aliases local (255), main (254) and default (253) are recognized as well `source` ip address no *(none)* The preferred source address when sending to destinations covered by the target `onlink` boolean no `0` When enabled gateway is on link even if the gateway does not match any interface prefix `type` string no `unicast` One of the types outlined in the routing types table below `proto` routing protocol no `static` Defines the protocol ID for the route. The ID can be either a numeric value ranging from 0 to 255 or a symbolic alias declared in `/etc/iproute2/rt_protos`. i.e. `kernel`, `boot`, `ra`, `redirect`, `static` `disabled` boolean no `0` Specifies if the static route should be set or not, available since OpenWrt &gt;= 21.02.

## IPv6 routes

*IPv6 routes* can be specified as well by defining one or more `route6` sections.

A minimal example looks like this:

```
config route6
        option interface 'lan'
        option target '2001:0DB8:100:F00:BA3::1/64'
        option gateway '2001:0DB8:99::1'
```

- `lan` is the *logical interface name* of the parent interface
- `2001:0DB8:100:F00:BA3::1/64` is the routed *IPv6 subnet* in CIDR notation
- `2001:0DB8:99::1` specifies the *IPv6 gateway* for this route

### Options for IPv6 routes

Name Type Required Default Description `interface` string yes *(none)* Specifies the *logical interface name* of the parent (or master) interface this route belongs to; must refer to one of the defined `interface` sections `target` ipv6 address yes *(none)* IPv6 network address `gateway` ipv6 address no *(none)* IPv6 gateway. If omitted, the `gateway` from the parent interface is taken `metric` number no `0` Specifies the *route metric* to use `mtu` number no *interface MTU* Defines a specific MTU for this route `table` routing table no `main` Defines the table ID to use for the route. The ID can be either a numeric table index ranging from 0 to 65535 or a symbolic alias declared in /etc/iproute2/rt\_tables. The special aliases local (255), main (254) and default (253) are recognized as well `source` ip address no *(none)* The route source address in source-address dependent routes. It's called “from” in the ip command. `onlink` boolean no `0` When enabled gateway is on link even if the gateway does not match any interface prefix `type` string no `unicast` One of the types outlined in the Routing Types table below `proto` routing protocol no `static` Defines the protocol ID for the route. The ID can be either a numeric value ranging from 0 to 255 or a symbolic alias declared in `/etc/iproute2/rt_protos`. i.e. `kernel`, `boot`, `ra`, `redirect`, `static` `disabled` boolean no `0` Specifies if the static route should be set or not, available since OpenWrt &gt;= 21.02.

#### Routing types

Type Description `unicast` the route entry describes real paths to the destinations covered by the route prefix. `local` the destinations are assigned to this host. The packets are looped back and delivered locally. `broadcast` the destinations are broadcast addresses. The packets are sent as link broadcasts. `multicast` a special type used for multicast routing. It is not present in normal routing tables. `unreachable` these destinations are unreachable. Packets are discarded and the ICMP message host unreachable is generated. The local senders get an EHOSTUNREACH error. `prohibit` these destinations are unreachable. Packets are discarded and the ICMP message communication administratively prohibited is generated. The local senders get an EACCES error. `blackhole` these destinations are unreachable. Packets are discarded silently. The local senders get an EINVAL error. `anycast` the destinations are anycast addresses assigned to this host. They are mainly equivalent to local with one difference: such addresses are invalid when used as the source address of any packet.
