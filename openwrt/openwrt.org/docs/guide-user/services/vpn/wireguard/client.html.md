# WireGuard client

This article relies on the following:

- Accessing [web interface](/docs/guide-quick-start/walkthrough_login "docs:guide-quick-start:walkthrough_login") / [command-line interface](/docs/guide-quick-start/sshadministration "docs:guide-quick-start:sshadministration")
- Managing [configs](/docs/guide-user/base-system/uci "docs:guide-user:base-system:uci") / [packages](/docs/guide-user/additional-software/managing_packages "docs:guide-user:additional-software:managing_packages") / [services](/docs/guide-user/base-system/managing_services "docs:guide-user:base-system:managing_services") / [logs](/docs/guide-user/base-system/log.essentials "docs:guide-user:base-system:log.essentials")

## Introduction

- This how-to describes the method for setting up [WireGuard](https://en.wikipedia.org/wiki/WireGuard "https://en.wikipedia.org/wiki/WireGuard") client on OpenWrt.
- Follow [WireGuard server](/docs/guide-user/services/vpn/wireguard/server "docs:guide-user:services:vpn:wireguard:server") for server setup and [WireGuard extras](/docs/guide-user/services/vpn/wireguard/extras "docs:guide-user:services:vpn:wireguard:extras") for additional tuning.

## Goals

- Encrypt your internet connection to enforce security and privacy.
  
  - Prevent traffic leaks and spoofing on the client side.
- Bypass regional restrictions using commercial providers.
  
  - Escape client side content filters and internet censorship.
- Access your LAN services remotely without port forwarding.

## Command-line instructions

### 1. Preparation

Install the required packages. Specify configuration parameters for VPN client.

```
# Install packages
opkg update
opkg install wireguard-tools
 
# Configuration parameters
VPN_IF="vpn"
VPN_SERV="SERVER_ADDRESS"
VPN_PORT="51820"
VPN_ADDR="192.168.9.2/24"
VPN_ADDR6="fd00:9::2/64"
```

### 2. Key management

Generate and [exchange keys](/docs/guide-user/services/vpn/wireguard/basics#key_management "docs:guide-user:services:vpn:wireguard:basics") between server and client.

```
# Generate keys
umask go=
wg genkey | tee wgserver.key | wg pubkey > wgserver.pub
wg genkey | tee wgclient.key | wg pubkey > wgclient.pub
wg genpsk > wgclient.psk
 
# Client private key
VPN_KEY="$(cat wgclient.key)"
 
# Pre-shared key
VPN_PSK="$(cat wgclient.psk)"
 
# Server public key
VPN_PUB="$(cat wgserver.pub)"
```

### 3. Firewall

Consider VPN network as public. Assign VPN interface to WAN zone to minimize firewall setup.

```
# Configure firewall
uci rename firewall.@zone[0]="lan"
uci rename firewall.@zone[1]="wan"
uci del_list firewall.wan.network="${VPN_IF}"
uci add_list firewall.wan.network="${VPN_IF}"
uci commit firewall
service firewall restart
```

### 4. Network

Configure VPN interface and peers.

```
# Configure network
uci -q delete network.${VPN_IF}
uci set network.${VPN_IF}="interface"
uci set network.${VPN_IF}.proto="wireguard"
uci set network.${VPN_IF}.private_key="${VPN_KEY}"
uci add_list network.${VPN_IF}.addresses="${VPN_ADDR}"
uci add_list network.${VPN_IF}.addresses="${VPN_ADDR6}"
 
# Add VPN peers
uci -q delete network.wgserver
uci set network.wgserver="wireguard_${VPN_IF}"
uci set network.wgserver.public_key="${VPN_PUB}"
uci set network.wgserver.preshared_key="${VPN_PSK}"
uci set network.wgserver.endpoint_host="${VPN_SERV}"
uci set network.wgserver.endpoint_port="${VPN_PORT}"
uci set network.wgserver.persistent_keepalive="25"
uci set network.wgserver.route_allowed_ips="1"
uci add_list network.wgserver.allowed_ips="0.0.0.0/0"
uci add_list network.wgserver.allowed_ips="::/0"
uci commit network
service network restart
```

Resolve [race conditions](/docs/guide-user/services/vpn/wireguard/extras#race_conditions "docs:guide-user:services:vpn:wireguard:extras") and configure [dynamic connection](/docs/guide-user/services/vpn/wireguard/extras#dynamic_connection "docs:guide-user:services:vpn:wireguard:extras") if necessary.

## Testing

Establish the VPN connection. Verify your routing with [traceroute](http://man.cx/traceroute%288%29 "http://man.cx/traceroute%288%29") and [traceroute6](http://man.cx/traceroute6%288%29 "http://man.cx/traceroute6%288%29").

```
traceroute openwrt.org
traceroute6 openwrt.org
```

Check your IP and DNS provider.

- [ipleak.net](https://ipleak.net/ "https://ipleak.net/")
- [dnsleaktest.com](https://www.dnsleaktest.com/ "https://www.dnsleaktest.com/")

On router:

- Go to **LuCI &gt; Status &gt; Wireguard** and look for peer device connected with an IPv4 or IPv6 address and with a recent handshake time
- Go to **LuCI &gt; Network &gt; Diagnostics** and **ipv4 ping** client device IP eg. 10.0.0.10

On client device depending on wireguard software:

- Check transfer traffic for tx &amp; rx
- Ping router internal lan IP
- Check public IP address in a browser – [https://whatsmyip.com](https://whatsmyip.com "https://whatsmyip.com") – should see public IP address of ISP for the router

## Troubleshooting

Collect and analyze the following information.

```
# Restart services
service log restart; service network restart; sleep 10
 
# Log and status
logread -e vpn; netstat -l -n -p | grep -e "^udp\s.*\s-$"
 
# Runtime configuration
pgrep -f -a wg; wg show; wg showconf wg0
ip address show; ip route show table all
ip rule show; ip -6 rule show; nft list ruleset
 
# Persistent configuration
uci show network; uci show firewall; crontab -l
```
