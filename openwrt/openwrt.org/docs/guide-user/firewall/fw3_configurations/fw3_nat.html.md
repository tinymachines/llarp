# NAT examples

The [fw4 application](/docs/guide-user/firewall/overview "docs:guide-user:firewall:overview") has extensive support for [NAT](https://en.wikipedia.org/wiki/Network_address_translation "https://en.wikipedia.org/wiki/Network_address_translation") filtering. NAT is a powerful feature for network redirection and is credited with extending the life of the IPv4 protocol.

This section contains typical uses of the fw4 NAT features. As with other firewall sections, this section will not delve into NAT background and theory. Some useful links for going deeper are:

- [https://www.netfilter.org/documentation/HOWTO/NAT-HOWTO.html](https://www.netfilter.org/documentation/HOWTO/NAT-HOWTO.html "https://www.netfilter.org/documentation/HOWTO/NAT-HOWTO.html")
- [https://www.karlrupp.net/en/computer/nat\_tutorial](https://www.karlrupp.net/en/computer/nat_tutorial "https://www.karlrupp.net/en/computer/nat_tutorial")
- [https://www.systutorials.com/816/port-forwarding-using-iptables/](https://www.systutorials.com/816/port-forwarding-using-iptables/ "https://www.systutorials.com/816/port-forwarding-using-iptables/")

For NAT diagnostics please see [Netfilter Management](/docs/guide-user/firewall/netfilter_iptables/netfilter_management "docs:guide-user:firewall:netfilter_iptables:netfilter_management") to analyze the netfilter rules and investigate conntrack sessions.

## NAT example configurations

OpenWrt's fw4 application supports DNAT, SNAT, and MASQUERADING. The following examples could be used in fw4's config file [/etc/config/firewall](https://git.openwrt.org/?p=project%2Ffirewall4.git%3Ba%3Dblob%3Bf%3Droot%2Fetc%2Fconfig%2Ffirewall "https://git.openwrt.org/?p=project/firewall4.git;a=blob;f=root/etc/config/firewall").

### Destination NAT (DNAT)

For public servers behind a firewall the DNAT target is used to translate the public IP address on the WAN-side to the server's private LAN address.

![:!:](/lib/images/smileys/exclaim.svg) A server publicly accessible from the Internet is highly visible. Consider putting your public servers in a [DMZ](/docs/guide-user/firewall/fw3_configurations/fw3_dmz "docs:guide-user:firewall:fw3_configurations:fw3_dmz") for security.

#### DNAT: Port forwarding for IPv4

The goal of this rule is to redirect all WAN-side SSH access on port 2222 to a the SSH port (22) of a single LAN-side station.

```
config redirect
       option name            'Example of SSH DNAT'
       option target          DNAT
       option src             wan
       option dest            lan
       option proto           tcp
       option src_dport       2222
       option dest_ip         192.168.10.20
       option dest_port       22
       option enabled         1
```

To test from a WAN-side station (STA1), SSH to the externally visible IP address on port 2222:

```
ssh -p 2222 203.0.113.8 "hostname; cat /proc/version"
```

When the rule is enabled STA2 will reply with its hostname and kernel version. When the rule is disabled, the connection is refused.

While this is all that one needs to know to use OpenWRT's fw4, the passionate reader may well ask “So what netfilter rules does this generate?”

```
# fw4 print | awk '/\{/ { p=$0 }; /Example/ { print p, $0, "}"; }' | tr -d '\t'
chain dstnat_wan { meta nfproto ipv4 tcp dport 2222 counter dnat 192.168.10.20:22                     comment "!fw4: Example of SSH DNAT" }
chain dstnat_lan { ip saddr 192.168.10.0/24 ip daddr 203.0.113.8 tcp dport 2222 dnat 192.168.10.20:22 comment "!fw4: Example of SSH DNAT (reflection)" }
chain srcnat_lan { ip saddr 192.168.10.0/24 ip daddr 192.168.10.20 tcp dport 22 snat 192.168.10.1     comment "!fw4: Example of SSH DNAT (reflection)" }
```

Netfilter uses these rules by matching entries in the [conntrack](/docs/guide-user/firewall/netfilter_iptables/netfilter_management#conntrack_diagnostics "docs:guide-user:firewall:netfilter_iptables:netfilter_management") table and taking the specified action.

The first rule matches connections coming in the WAN-side sent to TCP port 2222 and translates the destination to the server's LAN IP address, `192.168.10.20:22`. The second rule is like the first but for LAN-side machines, STA3, that SSH to the WAN IP address and port; this rule causes the connection to be reflected directly to the server, STA2, instead of going out onto the WAN. Connections modified by the second rule will additionally match the third rule which rewrites the source address to be that of the OpenWRT device, 192.168.10.1; a necessity if the server is isolated from the rest of the LAN.

The next thought of the passionate reader is “So what is in the conntrack table?”

```
# grep 2222 /proc/net/nf_conntrack
ipv4     2 tcp      6 7424 ESTABLISHED src=198.51.100.171 dst=203.0.113.8 sport=51390 dport=2222 packets=21 bytes=4837 src=192.168.10.20 dst=198.51.100.171 sport=22 dport=51390 packets=23 bytes=4063 [ASSURED] mark=0 zone=0 use=2
```

This record shows the WAN-side src=STA1 and dst=STA2:2222 and the reverse direction LAN-side src=STA2:22, dst=STA1.

#### DNAT: Ping a LAN-side server from a specific WAN IP

This redirect rule will cause the router to translate the WAN-side source of 1.2.3.4 to the LAN-side STA2 and route the ICMP echo to it. The rule is reflexive in that STA2 will be translated to 1.2.3.4 on the WAN-side.

```
config redirect
        option src      wan
        option src_dip  1.2.3.4
        option proto    icmp
        option dest     lan
        option dest_ip  192.168.10.20
        option target   DNAT
	option name     DNAT-ICMP-WAN-LAN
	option enabled  1
```

#### DNAT: LAN-side public server

[![ Diagram of DNAT ](/lib/exe/fetch.php?w=400&tok=771caf&media=https%3A%2F%2Fupload.wikimedia.org%2Fwikipedia%2Fcommons%2Fc%2Fc3%2FDNAT-nofonts.svg " Diagram of DNAT ")](/lib/exe/fetch.php?tok=b2e7c0&media=https%3A%2F%2Fupload.wikimedia.org%2Fwikipedia%2Fcommons%2Fc%2Fc3%2FDNAT-nofonts.svg "https://upload.wikimedia.org/wikipedia/commons/c/c3/DNAT-nofonts.svg")

In this example, STA2 is inside the LAN running an email server (e.g. postfix) listening on port 2525 for incoming email.

```
config redirect
        option target DNAT
        option src wan
        option src_dport 25
        option proto tcp
        option family ipv4
        option dest lan
        option dest_ip 192.168.10.20
        option dest_port 2525
        option name DNAT-MAIL-SERVER
        option enabled 1
```

This redirect rule states: any incoming traffic from the WAN on port 25, redirect to STA2 port 2525.

To verify what is going on dump `/proc/net/nf_conntrack` to observe the dynamic connection for incoming traffic. There can be quite a few conntrack records in it so we will search on just the ones using port 2525:

```
# grep port=2525 /proc/net/nf_conntrack
...
ipv4     2 tcp      6 7436 ESTABLISHED src=198.51.100.171 dst=203.0.113.8 sport=41370 dport=25 packets=4 bytes=229 src=192.168.10.20 dst=198.51.100.171 sport=2525 dport=41370 packets=3 bytes=164 [ASSURED] mark=0 use=2
...
```

The connection is coming from STA1 port 25 to the DUT and is translated to STA2 on port 2525 with a response destination to STA1.

The relevant traffic matches the DNAT conntrack state which is allowed to traverse zones by OpenWrt firewall, so no extra permissive rules are required.

### Source NAT (SNAT)

The goal of this rule is to translate the source IP address from a real station to a fictitious one on port 8080.

```
config redirect
        option target           SNAT
        option src              lan
        option dest             wan
	option proto            tcp
        option src_ip           192.168.10.20
        option src_dip          192.168.10.13
        option dest_port        8080
	option enabled          1
```

To test:

1. use netcat to listen on the STA1, the WAN-side station: `nc -l 8080`
2. use netcat to connect on the STA2, the LAN-side station: `nc -v 192.168.3.171 8080`

Type something on the LAN-side station and see it echoed on the WAN-side station. Check the connection on the WAN-side station using `netstat -ntap` and see the line:

```
tcp        0      0 192.168.3.171:8080      192.168.10.13:47970 ESTABLISHED 16746/nc
```

The WAN-side station shows the SNAT address connecting to it on port 8080!

When used alone, Source NAT is used to restrict a computer's access to the internet while allowing it to access a few services by forwarding what appears to be a few local services, e.g. [NTP](http://en.wikipedia.org/wiki/Network_time_protocol "http://en.wikipedia.org/wiki/Network_time_protocol"), to the internet. While DNAT hides the local network from the internet, SNAT hides the internet from the local network.

### MASQUERADE

This is the most used and useful NAT function. It translates a local private network on the LAN-side to a single public address/port num on the WAN-side and then the reverse. It is the default firewall configuration for **every** IPv4 router. As a result it is a very simple fw4 configuration

The LAN-side uses a [private network](https://en.wikipedia.org/wiki/Private_network "https://en.wikipedia.org/wiki/Private_network"). The router translates the private addresses to the router address:port and the netfilter conntrack module manages the connection.

The masquerade is set on the WAN-side

```
config zone
	option name 'wan'
	list network 'wan'
	....
	option masq '1'
```

Simple, no?

The router will generally get its WAN ip address from the upstream DHCP server and be the DHCP server (and usually DNS server) for LAN stations. The `network` configuration file defines the private network and the `dhcp` configuration file defines how the OpenWrt router assigns LAN-side IPv4 addresses.

When MASQUERADE is enabled, **all** forwarded traffic between WAN and LAN is translated. Essentially, there is very little that can go wrong with the MASQUERADE firewall rules.

Dump `/proc/net/nf_conntrack` to inspect the current MASQUERADE connections. The following connection tracks SSH (22) access from STA1 to STA2.

```
ipv4     2 tcp      6 4615 ESTABLISHED src=192.168.3.171 dst=192.168.10.20 sport=60446 dport=22 packets=27 bytes=1812 src=192.168.10.20 dst=192.168.3.171 sport=22 dport=60446 packets=21 bytes=2544 [ASSURED] mark=0 use=2
```

![:!:](/lib/images/smileys/exclaim.svg) MASQUERADE supports two or more private LAN zones

### Transparent proxy rule (external)

![:!:](/lib/images/smileys/exclaim.svg) not tested

The following rule redirects all LAN-side HTTP traffic through an external proxy at 192.168.1.100 listening on port 3128. It assumes the *lan* address to be 192.168.1.1 - this is needed to masquerade redirected traffic towards the proxy.

```
config redirect
        option src              lan
        option proto            tcp
        option src_ip           !192.168.1.100
        option src_dport        80
        option dest_ip          192.168.1.100
        option dest_port        3128
        option target           DNAT
 
config redirect
        option dest             lan
        option proto            tcp
        option src_dip          192.168.1.1
        option dest_ip          192.168.1.100
        option dest_port        3128
        option target           SNAT
```

## Extras

### NAT

Enable masquerading aka NAT on the WAN zone.

```
uci set firewall.@zone[1].masq="1"
uci commit firewall
service firewall restart
```

### IPv6 NAT

Enable IPv6 masquerading aka NAT66 on the WAN zone.

```
uci set firewall.@zone[1].masq6="1"
uci commit firewall
service firewall restart
```

Announce IPv6 default route for the ULA prefix.

```
uci set dhcp.lan.ra_default="1"
uci commit dhcp
service odhcpd restart
```

Disable IPv6 source filter on the upstream interface.

```
uci set network.wan6.sourcefilter="0"
uci commit network
service network restart
```

### Selective NAT

Enable masquerading selectively for a specific source subnet.

```
uci -q delete firewall.nat
uci set firewall.nat="nat"
uci set firewall.nat.family="ipv4"
uci set firewall.nat.proto="all"
uci set firewall.nat.src="wan"
uci set firewall.nat.src_ip="192.168.2.0/24"
uci set firewall.nat.target="MASQUERADE"
uci commit firewall
service firewall restart
```

### IPv6 selective NAT

Enable IPv6 masquerading selectively for a specific source subnet.

```
uci -q delete firewall.nat6
uci set firewall.nat6="nat"
uci set firewall.nat6.family="ipv6"
uci set firewall.nat6.proto="all"
uci set firewall.nat6.src="wan"
uci set firewall.nat6.src_ip="fd00:2::/64"
uci set firewall.nat6.target="MASQUERADE"
uci commit firewall
service firewall restart
```

### NPT

Enable IPv4 to IPv4 network prefix translation.

```
cat << "EOF" > /etc/nftables.d/npt.sh
LAN_PFX="192.168.1.0/24"
WAN_PFX="192.168.2.0/24"
. /lib/functions/network.sh
network_flush_cache
network_find_wan WAN_IF
network_get_device WAN_DEV "${WAN_IF}"
nft add rule inet fw4 srcnat \
oifname "${WAN_DEV}" snat ip prefix to ip \
saddr map { "${LAN_PFX}" : "${WAN_PFX}" }
EOF
uci -q delete firewall.npt
uci set firewall.npt="include"
uci set firewall.npt.path="/etc/nftables.d/npt.sh"
uci commit firewall
service firewall restart
```

### IPv6 NPT

Enable IPv6 to IPv6 network prefix translation.

```
cat << "EOF" > /etc/nftables.d/npt6.sh
LAN_PFX="$(uci -q get network.globals.ula_prefix)"
. /lib/functions/network.sh
network_flush_cache
network_find_wan6 WAN_IF
network_get_device WAN_DEV "${WAN_IF}"
network_get_prefix6 WAN_PFX "${WAN_IF}"
nft add rule inet fw4 srcnat \
oifname "${WAN_DEV}" snat ip6 prefix to ip6 \
saddr map { "${LAN_PFX}" : "${WAN_PFX}" }
EOF
uci -q delete firewall.npt6
uci set firewall.npt6="include"
uci set firewall.npt6.path="/etc/nftables.d/npt6.sh"
uci commit firewall
service firewall restart
```

### Multi-WAN IPv6 NPT

Enable IPv6 network prefix translation with multiple WAN interfaces (e.g. for [mwan3](/docs/guide-user/network/wan/multiwan/mwan3 "docs:guide-user:network:wan:multiwan:mwan3")).

```
cat << "EOF" > /etc/nftables.d/npt6.sh
LAN_IF="lan"
WAN_IF="wana6 wanb6"
. /lib/functions/network.sh
network_flush_cache
network_get_prefix_assignment6 LAN_PFX "${LAN_IF}"
for WAN_IF in ${WAN_IF}
do
network_get_device WAN_DEV "${WAN_IF}"
network_get_prefix6 WAN_PFX "${WAN_IF}"
nft add rule inet fw4 srcnat \
oif "${WAN_DEV}" snat ip6 prefix to ip6 \
saddr map { "${LAN_PFX}" : "${WAN_PFX}" }
done
EOF
uci -q delete firewall.npt6
uci set firewall.npt6="include"
uci set firewall.npt6.path="/etc/nftables.d/npt6.sh"
uci commit firewall
service firewall restart
```

### Symmetric dynamic IPv6 NPT

Enable symmetric dynamic IPv6 to IPv6 network prefix translation.

```
cat << "EOF" > /etc/nftables.d/npt6.sh
LAN_IF="lan"
sleep 5
. /lib/functions/network.sh
network_flush_cache
network_get_device LAN_DEV "${LAN_IF}"
network_get_prefix_assignment6 LAN_PFX "${LAN_IF}"
network_find_wan6 WAN_IF
network_get_device WAN_DEV "${WAN_IF}"
network_get_prefix6 WAN_PFX "${WAN_IF}"
nft add rule inet fw4 srcnat \
oifname "${WAN_DEV}" snat ip6 prefix to ip6 \
saddr map { "${LAN_PFX}" : "${WAN_PFX}" }
nft add rule inet fw4 srcnat \
oifname "${LAN_DEV}" snat ip6 prefix to ip6 \
saddr map { "${WAN_PFX}" : "${LAN_PFX}" }
EOF
uci -q delete firewall.npt6
uci set firewall.npt6="include"
uci set firewall.npt6.path="/etc/nftables.d/npt6.sh"
uci commit firewall
service firewall restart
```

### IPv6 to IPv4 NAT with Jool

Enable IPv6 to IPv4 NAT aka NAT64 for IPv6-only networks with Jool. Use DNS64 to resolve domain names.

```
opkg update
opkg install jool-tools-netfilter
. /usr/share/libubox/jshn.sh
json_init
json_add_string "instance" "default"
json_add_string "framework" "netfilter"
json_add_object "global"
json_add_string "pool6" "64:ff9b::/96"
json_close_object
json_dump > /etc/jool/jool-nat64.conf.json
uci set jool.general.enabled="1"
uci set jool.nat64.enabled="1"
uci commit jool
service jool restart
```

### IPv6 to IPv4 NAT with Tayga

Enable IPv6 to IPv4 NAT aka NAT64 for IPv6-only networks with Tayga. Use DNS64 to resolve domain names.

```
opkg update
opkg install tayga
uci del_list firewall.lan.network="nat64"
uci add_list firewall.lan.network="nat64"
uci commit firewall
service firewall restart
uci -q delete network.nat64
uci set network.nat64="interface"
uci set network.nat64.proto="tayga"
uci set network.nat64.prefix="64:ff9b::/96"
uci set network.nat64.ipv6_addr="fd00:ffff::1"
uci set network.nat64.dynamic_pool="192.168.255.0/24"
uci set network.nat64.ipv4_addr="192.168.255.1"
uci commit network
service network restart
```

### TTL

Modify TTL for egress traffic.

```
cat << "EOF" > /etc/nftables.d/ttl.sh
WAN_TTL="65"
. /lib/functions/network.sh
network_flush_cache
network_find_wan WAN_IF
network_get_device WAN_DEV "${WAN_IF}"
nft add rule inet fw4 mangle_postrouting \
oifname "${WAN_DEV}" ip ttl set "${WAN_TTL}"
EOF
uci -q delete firewall.ttl
uci set firewall.ttl="include"
uci set firewall.ttl.path="/etc/nftables.d/ttl.sh"
uci commit firewall
service firewall restart
```

### IPv6 hop limit

Modify IPv6 hop limit for egress traffic.

```
cat << "EOF" > /etc/nftables.d/hlim.sh
WAN_HLIM="65"
. /lib/functions/network.sh
network_flush_cache
network_find_wan6 WAN_IF
network_get_device WAN_DEV "${WAN_IF}"
nft add rule inet fw4 mangle_postrouting \
oifname "${WAN_DEV}" ip6 hoplimit set "${WAN_HLIM}"
EOF
uci -q delete firewall.hlim
uci set firewall.hlim="include"
uci set firewall.hlim.path="/etc/nftables.d/hlim.sh"
uci commit firewall
service firewall restart
```

### FTP passthrough

Enable NAT passthrough for FTP using [kmod-nf-nathelper](/packages/pkgdata/kmod-nf-nathelper "packages:pkgdata:kmod-nf-nathelper").

```
opkg update
opkg install kmod-nf-nathelper
service firewall restart
```

### SIP passthrough

Enable NAT passthrough for SIP, PPTP, GRE, etc. using [kmod-nf-nathelper-extra](/packages/pkgdata/kmod-nf-nathelper-extra "packages:pkgdata:kmod-nf-nathelper-extra").

```
opkg update
opkg install kmod-nf-nathelper-extra
service firewall restart
```

### RTSP passthrough

Enable NAT passthrough for RTSP using [kmod-ipt-nathelper-rtsp](/packages/pkgdata/kmod-ipt-nathelper-rtsp "packages:pkgdata:kmod-ipt-nathelper-rtsp").

```
opkg update
opkg install kmod-ipt-nathelper-rtsp
service firewall restart
```
