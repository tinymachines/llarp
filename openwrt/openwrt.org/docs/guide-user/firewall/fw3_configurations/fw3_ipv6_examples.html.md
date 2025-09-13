# IPv6 firewall examples

## Port accept for IPv6

To open port 80 so that a local webserver at `2001:db8:42::1337` can be reached from the Internet:

```
config rule
	option src 'wan'
	option proto 'tcp'
	option dest 'lan'
	option dest_ip '2001:db8:42::1337'
	option dest_port '80'
	option family 'ipv6'
	option target 'ACCEPT'
```

To open SSH access to all IPv6 hosts in the local network:

```
config rule
	option src 'wan'
	option proto 'tcp'
	option dest 'lan'
	option dest_port '22'
	option family 'ipv6'
	option target 'ACCEPT'
```

To open all TCP/UDP port between 1024 and 65535 towards the local IPv6 network:

```
config rule
	option src 'wan'
	option proto 'tcp udp'
	option dest 'lan'
	option dest_port '1024:65535'
	option family 'ipv6'
	option target 'ACCEPT'
```

## Forwarding IPv6 tunnel traffic

![:!:](/lib/images/smileys/exclaim.svg) This example is for IPv6 tunnels only, and does not apply to native dual-stack interfaces.

The example below assumes your tunnel interface is configured on it's own zone. An alternative setup that may also be used is having your IPv6 tunnel on an interface like `henet` and attached to the `wan` zone. This is also correct, but if you plan on passing a prefix down to your LAN and want to firewall appropriately it is better to create a separate firewall zone as described below.

IPv6 packets may not be forwarded from lan to your wan6 interface and vice versa by default. Make sure that `net.ipv6.conf.all.forwarding=1` is enabled, you can run `sysctl net.ipv6.conf.all.forwarding` to confirm the value set. (This is likely already enabled by default on newer OpenWrt builds).

Assuming your tunnel interface is called `wan6`, add the following sections to `/etc/config/firewall` to create a new zone `wan6`.

```
config zone
	option name 'wan6'
	option network 'wan6'
	option family 'ipv6'
	option input 'ACCEPT'
	option output 'ACCEPT'
	option forward 'REJECT'
 
config forwarding
        option dest 'wan6'
        option src 'lan'
```

Forwarding lan → wan6 will allow your IPv6 prefix to work on the lan side, you can confirm this by going to [https://test-ipv6.com](https://test-ipv6.com "https://test-ipv6.com").

The `family` option ensures that the zone and all associated entries (`rule`, `forwarding` and `redirect` sections) are only added to *ip6tables* but not *iptables*.

### Opening IPv6 ports to LAN clients

![:!:](/lib/images/smileys/exclaim.svg) Adding the following forwarding rule below will expose **ALL IPv6 ports** behind a v6 host on the LAN, which is potentially very dangerous. Instead, you should selectively define allow IPv6 firewall rules to avoid this. The documentation was previously worded in a way that stated this forwarding rule was needed to allow IPv6 traffic to flow properly. This is not true. You do not need to allow wan6 → lan to everything.

```
# Only enable this if you know what you're doing and have additional firewall rules blocking access to IPv6 TCP/UDP ports.
config forwarding
        option dest 'lan'
        option src 'wan6'
```

Any firewall rules required to open one or more ports would follow the same syntax as the examples above, with the exception of the `src` value being `wan6`, rather than `wan`.

## Dynamic prefix forwarding

Forward IPv6 traffic from WAN to a specific LAN host using its GUA address. Configure a [static IPv6 suffix](/docs/guide-user/base-system/dhcp_configuration#static_leases "docs:guide-user:base-system:dhcp_configuration") and add a forwarding rule.

```
uci add firewall rule
uci set firewall.@rule[-1].name="Forward-IPv6"
uci set firewall.@rule[-1].src="wan"
uci set firewall.@rule[-1].dest="lan"
uci set firewall.@rule[-1].dest_ip="::23/-64"
uci set firewall.@rule[-1].family="ipv6"
uci set firewall.@rule[-1].proto="tcp udp"
uci set firewall.@rule[-1].target="ACCEPT"
uci commit firewall
service firewall restart
```

The negative netmask notation works only with OpenWrt firewall:

- `/-64` equivalent for `/::0000:ffff:ffff:ffff:ffff`
- `/-60` equivalent for `/::000f:ffff:ffff:ffff:ffff`
- `/-56` equivalent for `/::00ff:ffff:ffff:ffff:ffff`
- `/-48` equivalent for `/::ffff:ffff:ffff:ffff:ffff`

## IPv6 port forwarding

Forward a specific IPv6 port from WAN to a LAN host behind NAT66. Configure a [static DHCPv6 lease](/docs/guide-user/base-system/dhcp_configuration#static_leases "docs:guide-user:base-system:dhcp_configuration") and add a redirect using the ULA address.

```
uci add firewall redirect
uci set firewall.@redirect[-1].name="Forward-SSH-IPv6"
uci set firewall.@redirect[-1].src="wan"
uci set firewall.@redirect[-1].src_dport="22"
uci set firewall.@redirect[-1].dest="lan"
uci set firewall.@redirect[-1].dest_ip="fd00:db8:42::1337"
uci set firewall.@redirect[-1].dest_port="22"
uci set firewall.@redirect[-1].family="ipv6"
uci set firewall.@redirect[-1].proto="tcp"
uci set firewall.@redirect[-1].target="DNAT"
uci commit firewall
service firewall restart
```

## IPv6 firewall testing

You can confirm the state of your IPv6 firewall using a couple of tools:

- [https://ipv6.chappell-family.com/ipv6tcptest/](https://ipv6.chappell-family.com/ipv6tcptest/ "https://ipv6.chappell-family.com/ipv6tcptest/")
- [http://www.ipv6scanner.com/cgi-bin/main.py](http://www.ipv6scanner.com/cgi-bin/main.py "http://www.ipv6scanner.com/cgi-bin/main.py")
- [https://ifconfig.co](https://ifconfig.co "https://ifconfig.co")
- [https://ipv6.icanhazip.com](https://ipv6.icanhazip.com "https://ipv6.icanhazip.com")

These tools will allow you to query one or more ports against an IPv6 address to determine the response. In most cases you should not have open ports, unless these have been explicitly opened via a firewall rule.
