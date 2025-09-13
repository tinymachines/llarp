# NAT64 for a IPv6-only network (Jool)

This article relies on the following:

- Accessing [web interface](/docs/guide-quick-start/walkthrough_login "docs:guide-quick-start:walkthrough_login") / [command-line interface](/docs/guide-quick-start/sshadministration "docs:guide-quick-start:sshadministration")
- Managing [configs](/docs/guide-user/base-system/uci "docs:guide-user:base-system:uci") / [packages](/docs/guide-user/additional-software/managing_packages "docs:guide-user:additional-software:managing_packages") / [services](/docs/guide-user/base-system/managing_services "docs:guide-user:base-system:managing_services") / [logs](/docs/guide-user/base-system/log.essentials "docs:guide-user:base-system:log.essentials")

See also: [NAT66 and IPv6 masquerading](/docs/guide-user/network/ipv6/ipv6.nat6 "docs:guide-user:network:ipv6:ipv6.nat6"), [IPv6 NAT and NPT](/docs/guide-user/firewall/fw3_configurations/fw3_nat#ipv6_nat "docs:guide-user:firewall:fw3_configurations:fw3_nat")

NAT64 (Network address translation from IPv6 to IPv4) is a technology for allowing an IPv6-only network to connect and interoperate with the IPv4 Internet.

It's very similar to the NAT44 used by most home networks that forwards packets between IPv4 private address space and IPv4 public address space, except it forwards between IPv6 (public) addresses and IPv4 public addresses.

It works in conjunction with several technologies:

- DNS64, where the DNS returns a specially formatted IPv6 address that encodes the target IPv4 address, which is then handled by NAT64 to forward packets.
- [PREF64](https://git.openwrt.org/?p=project%2Fodhcpd.git%3Ba%3Dcommitdiff%3Bh%3Dc6bff6f1c0fbb37a21a7f54e393615bad22a72d9 "https://git.openwrt.org/?p=project/odhcpd.git;a=commitdiff;h=c6bff6f1c0fbb37a21a7f54e393615bad22a72d9"), where the router advertises in an ICMPv6 Router Advertisement the NAT64 prefix which devices can use to create a CLAT interface (Android, iOS and macOS uses this).

In OpenWrt, NAT64 can be easily activated using [Jool](https://github.com/NICMx/Jool#jool "https://github.com/NICMx/Jool#jool").

## Two options are possible

#### Option 1 - Running in the main network namespace

Pros

- easy to activate
- basic integration with the uci configuration system

Cons

- hard to enforce firewall rules
- translation not available for locally (on the router) generated traffic
- fights over dynamic port numbers
- needs to be reconfigured every time the public IPv4 changes

#### Option 2 - Running jool in a separate network namespace

Pros

- easy to enforce firewall rules
- translation available for all traffic

Cons

- no integration with the configuration system

### Option 1 - Running in the main network namespace

The following packages need to be installed first:

```
# opkg update
# opkg install kmod-jool-netfilter jool-tools-netfilter
```

### Jool Configuration Syntax

Jool's configuration is split into three configuration files:

- /etc/config/jool
- /etc/jool/jool-nat64.conf.json
- /etc/jool/jool-siit.conf.json

#### /etc/config/jool

This file controls which of the services is enabled (NAT64, SIIT, or both).

```
config jool 'general'
	option enabled '0'

config jool 'nat64'
        option enabled '0'

config jool 'siit'
        option enabled '0'
```

#### /etc/jool

In this folder are the files that actually configures Jool's NAT64 and SIIT modules.

The reference for configuring these is in the jools official documentation:

- [Jool's configuration examples](https://nicmx.github.io/Jool/en/config-atomic.html "https://nicmx.github.io/Jool/en/config-atomic.html")
- [Jool's documentation](https://nicmx.github.io/Jool/en/documentation.html "https://nicmx.github.io/Jool/en/documentation.html")

#### Using Jool

##### Basic setup

After having Jool installed you need to configure it. This is a basic sample configuration that can be used as a template:

/etc/jool/jool-nat64.conf.json:

```
{
	"comment": "NAT64 instance configuration.",
	"instance": "nat64",
	"framework": "netfilter",
	"global": {
		"pool6": "64:ff9b::/96",
		"maximum-simultaneous-opens": 16,
		"source-icmpv6-errors-better": true
	}
}
```

After saving the configuration you need to enable it:

```
uci set jool.general.enabled="1"
uci set jool.nat64.enabled="1"
uci commit jool
service jool restart
```

After this configuration, jool should be running. You can test this by pinging an IPv4 address.

```
# Confirm working NAT64 from a device inside your LAN
ping 64:ff9b::1.1.1.1
```

### Option 2 - Running jool in a separate network namespace

Inspired and supported by the tutorial IPv6-only/mostly on OpenWrt by Ondřej Caletka [1)](#fn__1).

The following packages need to be installed first:

```
# opkg update
# opkg install kmod-veth ip-full kmod-jool-netfilter jool-tools-netfilter
```

#### Setup jool network namespace

Create or copy the following shell script to `/etc/jool/setupjool.sh`

```
#!/bin/sh
ip link add jool type veth peer openwrt
ip netns add jool
ip link set dev openwrt netns jool
ip netns exec jool sh <<EOF
    sysctl -w net.ipv4.conf.all.forwarding=1
    sysctl -w net.ipv6.conf.all.forwarding=1
    sysctl -w net.ipv6.conf.openwrt.accept_ra=2
    sysctl -w net.ipv4.ip_local_port_range="32768 32999"
    ip link set dev lo up
    ip link set dev openwrt up
    ip addr add dev openwrt 192.168.164.2/24
    ip addr add dev openwrt fe80::64
    ip route add default via 192.168.164.1
    modprobe jool
    jool instance add --netfilter --pool6 64:ff9b::/96
    jool global update lowest-ipv6-mtu 1500
    jool pool4 add 192.168.164.2 33000-65535 --tcp
    jool pool4 add 192.168.164.2 33000-65535 --udp
    jool pool4 add 192.168.164.2 33000-65535 --icmp
EOF
```

Make it executable and execute it once.

```
chmod +x setupjool.sh
```

Add the following line to `/etc/rc.local` through the CLI or Luci UI (`System - Startup - Local Startup`), before the `exit 0`.

```
/etc/jool/setupjool.sh
```

Persist it across `sysupgrades`, add file to `/etc/sysupgrade.conf` through the CLI or Luci UI (`System - Backup / Flash Firmware- Configuration`)

```
cat << EOF >> /etc/sysupgrade.conf
/etc/jool/setupjool.sh
EOF
```

#### Setup jool interface

- use IPv4 subnet 192.168.164.1/24
- allocate one IPv6 /64 with SLAAC
- route NAT64 prefix to fe80::64
- configure `jool` firewall zone and forward from `lan` zone

Setup new interface

file `/etc/config/network`

```
config interface 'jool'
	option proto 'static'
	option device 'jool'
	option ipaddr '192.168.164.1'
	option netmask '255.255.255.0'
	option ip6assign '64'
	option ip6hint '64'
```

Configure DHCPv4 and SLAAC/DHCPv6

file `/etc/config/dhcp`

```
config dhcp 'jool'
	option interface 'jool'
	option start '100'
	option limit '150'
	option leasetime '12h'
	option ignore '1'
	option ra 'server'
	option ra_default '2'
```

Add a static IPv6 route

file `/etc/config/network`

```
config route6
	option interface 'jool'
	option target '64:ff9b::/96'
	option gateway 'fe80::64'
```

Add `jool` firewall zone

file `/etc/config/firewall`

```
config zone
	option name 'jool'
	option input 'ACCEPT'
	option output 'ACCEPT'
	option forward 'REJECT'
	list network 'jool'

config forwarding
        option src 'jool'
        option dest 'wan'
```

Forward `lan` zone to `jool`

file `/etc/config/firewall`

```
config forwarding
	option src 'lan'
	option dest 'jool'
```

#### Testing

After this configuration, jool should be running and the firewall is correctly configured. You can test this by pinging a synthesized IPv4 address.

```
# Confirm working NAT64 from your router
ping 64:ff9b::1.1.1.1
```

Make sure it works also from the connected devices

- otherwise it might be a routing/firewall issue
- try a complete reboot before you start tweaking and debugging

#### Add forwardings from existing firewall zone to ''jool''

e.g., `lan`

file `/etc/config/firewall`

```
config forwarding
	option src 'lan'
	option dest 'jool'
```

### Add PREF64 option to the existing networks

Option in the Router Advertisement messages carring the NAT64 prefix the network is using. New feature introduced with `v23.05.0`

file `/etc/config/dhcp`

```
config dhcp 'lan'
	option interface 'lan'
        ...
	option ra_pref64 '64:ff9b::/96'
```

## Configure DNS64

In a standard dual-stack network, with regular DNS, an IPv6-only device cannot connect to IPv4-only servers, as it has no access to NAT44.

DNS64 comes to fix this, by synthesizing AAAA records from A records. These IPv6 addresses are ranslated by NAT64 (`jool`) to IPv4 addresses.

To use DNS64 you can [change your DNS](/docs/guide-user/base-system/dhcp_configuration#upstream_dns_provider "docs:guide-user:base-system:dhcp_configuration") to [Cloudflare's DNS64](https://developers.cloudflare.com/1.1.1.1/infrastructure/ipv6-networks/ "https://developers.cloudflare.com/1.1.1.1/infrastructure/ipv6-networks/") [Google DNS64](https://developers.google.com/speed/public-dns/docs/dns64 "https://developers.google.com/speed/public-dns/docs/dns64") or set up [unbound for DNS64](https://github.com/openwrt/packages/blob/master/net/unbound/files/README.md#complete-uci "https://github.com/openwrt/packages/blob/master/net/unbound/files/README.md#complete-uci") to correctly resolve domain names into translated addresses. Cloudflare and Google DNS64 can only be use if you use the well-known NAT64 prefix `64:ff9b::/96`.

## Become IPv6-mostly

Android and iOS as well as macOS are working fine in IPv6-only networks. To signal to clients which are able and willing to run IPv6-only, the DHCP option 108 was introduced with RFC8925.

Add this option to the DHCPv4 configuration of the desired zone e.g., `lan`

file `/etc/config/dhcp`

```
# 30 minutes = 1800 seconds = 0x708 seconds
dhcp_option '108,0:0:7:8'
```

After this all your mobile and macOS devices will drop the IPv4 lease and run in IPv6-only mode.

### See also:

- [Jool source code and documentation](https://github.com/openwrt/packages/blob/master/net/jool/files/readme.md "https://github.com/openwrt/packages/blob/master/net/jool/files/readme.md")
- [RFC6052](http://tools.ietf.org/html/rfc6052 "http://tools.ietf.org/html/rfc6052"), [RFC6146](http://tools.ietf.org/html/rfc6146 "http://tools.ietf.org/html/rfc6146"), [RFC7050](http://tools.ietf.org/html/rfc7050 "http://tools.ietf.org/html/rfc7050") and [RFC8925](http://tools.ietf.org/html/rfc8925 "http://tools.ietf.org/html/rfc8925") for reference.

[1)](#fnt__1)

[RIPE87 Tutorial IPv6-mostly on OpenWrt](https://ripe87.ripe.net/wp-content/uploads/presentations/8-IPv6-mostly_on_OpenWRT.pdf "https://ripe87.ripe.net/wp-content/uploads/presentations/8-IPv6-mostly_on_OpenWRT.pdf")
