# IPv6 with Hurricane Electric

This article relies on the following:

- Accessing [web interface](/docs/guide-quick-start/walkthrough_login "docs:guide-quick-start:walkthrough_login") / [command-line interface](/docs/guide-quick-start/sshadministration "docs:guide-quick-start:sshadministration")
- Managing [configs](/docs/guide-user/base-system/uci "docs:guide-user:base-system:uci") / [packages](/docs/guide-user/additional-software/managing_packages "docs:guide-user:additional-software:managing_packages") / [services](/docs/guide-user/base-system/managing_services "docs:guide-user:base-system:managing_services") / [logs](/docs/guide-user/base-system/log.essentials "docs:guide-user:base-system:log.essentials")

## Introduction

- This how-to describes the method for setting up [6in4](https://en.wikipedia.org/wiki/6in4 "https://en.wikipedia.org/wiki/6in4") tunnel on OpenWrt.
- It relies on Hurricane Electric IPv6 tunnel broker and supports static/dynamic setup.
- Follow [DDNS client](/docs/guide-user/services/ddns/client "docs:guide-user:services:ddns:client") to use IPv6 tunnel broker with dynamic address.
- Follow [IPv6 with Hurricane Electric using LuCI](/docs/guide-user/network/ipv6/ipv6tunnel-luci "docs:guide-user:network:ipv6:ipv6tunnel-luci") for web interface instructions.

## Goals

- Provide IPv6 connectivity for LAN clients.
- Access your LAN services remotely without port forwarding.

## Command-line instructions

Register a free account with [Hurricane Electric IPv6 tunnel broker](https://tunnelbroker.net/ "https://tunnelbroker.net/") and create a regular tunnel.

Install the required packages. Specify configuration parameters for the tunnel. Set up a static IPv6 tunnel.

```
# Install packages
opkg update
opkg install 6in4
 
# Configuration parameters
HENET_PEER="203.0.113.45"
HENET_IPV6="2001:db8:1f0a:1a2::2/64"
HENET_PFX64="2001:db8:1f0a:2b3::/64"
HENET_PFX48="2001:db8:1f0a::/48"
 
# Fetch WAN IP address
. /lib/functions/network.sh
network_flush_cache
network_find_wan NET_IF
network_get_ipaddr NET_ADDR "${NET_IF}"
 
# Configure tunnel
uci -q delete network.wan6
uci set network.wan6="interface"
uci set network.wan6.proto="6in4"
uci set network.wan6.ipaddr="${NET_ADDR}"
uci set network.wan6.peeraddr="${HENET_PEER}"
uci set network.wan6.ip6addr="${HENET_IPV6}"
uci add_list network.wan6.ip6prefix="${HENET_PFX64}"
uci add_list network.wan6.ip6prefix="${HENET_PFX48}"
uci commit network
service network restart
```

## Testing

Use [ping6](http://man.cx/ping6%288%29 "http://man.cx/ping6%288%29") and [traceroute6](http://man.cx/traceroute6%288%29 "http://man.cx/traceroute6%288%29") to verify you can reach IPv6 services.

```
ping6 openwrt.org
traceroute6 openwrt.org
```

Check your internet connectivity.

- [ipleak.net](https://ipleak.net/ "https://ipleak.net/")

## Troubleshooting

Collect and analyze the following information.

```
# Restart services
service log restart; ifup wan6; sleep 10
 
# Log and status
logread; ifstatus wan6
 
# Runtime configuration
ip address show; ip route show table all
ip rule show; ip -6 rule show; nft list ruleset
 
# Persistent configuration
uci show network; uci show dhcp; uci show firewall
```

## Extras

### Dynamic address

Reconfigure IPv6 tunnel for dynamic IP address.

```
# Configuration parameters
HENET_TUNID="123456"
HENET_USER="USERNAME"
HENET_UPKEY="UPDATEKEY"
 
# Configure tunnel
uci -q delete network.wan6.ipaddr
uci set network.wan6.tunnelid="${HENET_TUNID}"
uci set network.wan6.username="${HENET_USER}"
uci set network.wan6.updatekey="${HENET_UPKEY}"
uci commit network
service network restart
```

### Default route

Provide IPv6 default route with source filter disabled.

```
# Configure network
uci -q delete network.wan6_rt
uci set network.wan6_rt="route6"
uci set network.wan6_rt.interface="wan6"
uci set network.wan6_rt.target="::/0"
uci commit network
service network restart
```

### Cake SQM

Process IPv6 traffic as separate flows when using [cake SQM](/docs/guide-user/network/traffic-shaping/sqm-details "docs:guide-user:network:traffic-shaping:sqm-details").

```
# Configure network
uci set network.wan6.tos="inherit"
uci commit network
service network restart
```
