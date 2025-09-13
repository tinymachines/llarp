# Tinc server

This article relies on the following:

- Accessing [web interface](/docs/guide-quick-start/walkthrough_login "docs:guide-quick-start:walkthrough_login") / [command-line interface](/docs/guide-quick-start/sshadministration "docs:guide-quick-start:sshadministration")
- Managing [configs](/docs/guide-user/base-system/uci "docs:guide-user:base-system:uci") / [packages](/docs/guide-user/additional-software/managing_packages "docs:guide-user:additional-software:managing_packages") / [services](/docs/guide-user/base-system/managing_services "docs:guide-user:base-system:managing_services") / [logs](/docs/guide-user/base-system/log.essentials "docs:guide-user:base-system:log.essentials")

## Introduction

- This how-to describes the method for setting up [Tinc](https://en.wikipedia.org/wiki/Tinc_%28protocol%29 "https://en.wikipedia.org/wiki/Tinc_(protocol)") server on OpenWrt.
- Follow [Tinc client](/docs/guide-user/services/vpn/tinc/client "docs:guide-user:services:vpn:tinc:client") for client setup and [Tinc extras](/docs/guide-user/services/vpn/tinc/extras "docs:guide-user:services:vpn:tinc:extras") for additional tuning.

## Goals

- Encrypt your internet connection to enforce security and privacy.
  
  - Prevent traffic leaks and spoofing on the client side.
- Bypass regional restrictions using commercial providers.
  
  - Escape client side content filters and internet censorship.
- Access your LAN services remotely without port forwarding.

## Command-line instructions

### 1. Preparation

Install the required packages. Specify configuration parameters for VPN server.

```
# Install packages
opkg update
opkg install tinc
 
# Configuration parameters
VPN_IF="vpn"
VPN_PORT="655"
VPN_ADDR="192.168.9.1/24"
VPN_ADDR6="fd00:9::1/64"
```

### 2. Key management

Generate and [exchange keys](/docs/guide-user/services/vpn/tinc/start#key_management "docs:guide-user:services:vpn:tinc:start") between server and client.

```
# Generate keys
mkdir -p /etc/tinc/${VPN_IF}
tinc -n ${VPN_IF} generate-rsa-keys < /dev/null
tinc -n ${VPN_IF} generate-ed25519-keys < /dev/null
VPN_SPUB="$(sed -e "s/^.*\s//" /etc/tinc/${VPN_IF}/ed25519_key.pub)"
VPN_CPUB="$(sed -e "s/^.*\s//" client.pub)"
```

### 3. Firewall

Consider VPN network as private. Assign VPN interface to LAN zone to minimize firewall setup. Allow access to VPN server from WAN zone.

```
# Configure firewall
uci rename firewall.@zone[0]="lan"
uci rename firewall.@zone[1]="wan"
uci del_list firewall.lan.network="${VPN_IF}"
uci add_list firewall.lan.network="${VPN_IF}"
uci -q delete firewall.tinc
uci set firewall.tinc="rule"
uci set firewall.tinc.name="Allow-Tinc"
uci set firewall.tinc.src="wan"
uci set firewall.tinc.dest_port="${VPN_PORT}"
uci set firewall.tinc.proto="tcp udp"
uci set firewall.tinc.target="ACCEPT"
uci commit firewall
service firewall restart
```

### 4. VPN service

Configure VPN service.

```
# Configure VPN service
uci -q delete tinc.${VPN_IF}
uci set tinc.${VPN_IF}="tinc-net"
uci set tinc.${VPN_IF}.enabled="1"
uci set tinc.${VPN_IF}.Interface="${VPN_IF}"
uci set tinc.${VPN_IF}.Name="server"
uci -q delete tinc.server
uci set tinc.server="tinc-host"
uci set tinc.server.enabled="1"
uci set tinc.server.net="${VPN_IF}"
uci set tinc.server.Name="server"
uci set tinc.server.PublicKey="1"
uci set tinc.server.Ed25519PublicKey="${VPN_SPUB}"
uci add_list tinc.server.Subnet="0.0.0.0/0"
uci add_list tinc.server.Subnet="::/0"
uci -q delete tinc.client
uci set tinc.client="tinc-host"
uci set tinc.client.enabled="1"
uci set tinc.client.net="${VPN_IF}"
uci set tinc.client.Name="client"
uci set tinc.client.PublicKey="1"
uci set tinc.client.Ed25519PublicKey="${VPN_CPUB}"
uci add_list tinc.client.Subnet="${VPN_ADDR%.*}.2/32"
uci add_list tinc.client.Subnet="${VPN_ADDR6%:*}:2/128"
uci commit tinc
service tinc restart
```

### 5. Network

Set up VPN interface.

```
# Configure network
uci -q delete network.${VPN_IF}
uci set network.${VPN_IF}="interface"
uci set network.${VPN_IF}.proto="static"
uci set network.${VPN_IF}.ipaddr="${VPN_ADDR}"
uci set network.${VPN_IF}.ip6addr="${VPN_ADDR6}"
uci set network.${VPN_IF}.device="${VPN_IF}"
uci commit network
service network restart
```

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
service log restart; service tinc restart; sleep 10
 
# Log and status
logread -e tinc; netstat -l -n -p | grep -e tinc
 
# Runtime configuration
pgrep -f -a tinc
ip address show; ip route show table all
ip rule show; ip -6 rule show; nft list ruleset
 
# Persistent configuration
uci show network; uci show firewall; uci show tinc
head -v -n -0 /etc/tinc/*/*/*
```
