# OpenConnect server

This article relies on the following:

- Accessing [web interface](/docs/guide-quick-start/walkthrough_login "docs:guide-quick-start:walkthrough_login") / [command-line interface](/docs/guide-quick-start/sshadministration "docs:guide-quick-start:sshadministration")
- Managing [configs](/docs/guide-user/base-system/uci "docs:guide-user:base-system:uci") / [packages](/docs/guide-user/additional-software/managing_packages "docs:guide-user:additional-software:managing_packages") / [services](/docs/guide-user/base-system/managing_services "docs:guide-user:base-system:managing_services") / [logs](/docs/guide-user/base-system/log.essentials "docs:guide-user:base-system:log.essentials")

## Introduction

- This how-to describes the method for setting up [OpenConnect](https://en.wikipedia.org/wiki/OpenConnect "https://en.wikipedia.org/wiki/OpenConnect") server on OpenWrt.
- Follow [OpenConnect client](/docs/guide-user/services/vpn/openconnect/client "docs:guide-user:services:vpn:openconnect:client") for client setup and [OpenConnect extras](/docs/guide-user/services/vpn/openconnect/extras "docs:guide-user:services:vpn:openconnect:extras") for additional tuning.

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
opkg install ocserv
 
# Configuration parameters
VPN_PORT="4443"
VPN_POOL="192.168.9.0 255.255.255.0"
VPN_DNS="${VPN_POOL%.* *}.1"
VPN_USER="USERNAME"
VPN_PASS="PASSWORD"
```

### 2. Key management

Generate password hash for VPN client.

```
# Generate password hash
ocpasswd ${VPN_USER} << EOI
${VPN_PASS}
${VPN_PASS}
EOI
VPN_HASH="$(sed -n -e "/^${VPN_USER}:.*:/s///p" /etc/ocserv/ocpasswd)"
```

### 3. Firewall

Consider VPN network as private. Assign VPN interface to LAN zone to minimize firewall setup. Allow access to VPN server from WAN zone.

```
# Configure firewall
uci rename firewall.@zone[0]="lan"
uci rename firewall.@zone[1]="wan"
uci del_list firewall.lan.device="vpns+"
uci add_list firewall.lan.device="vpns+"
uci -q delete firewall.oc
uci set firewall.oc="rule"
uci set firewall.oc.name="Allow-OpenConnect"
uci set firewall.oc.src="wan"
uci set firewall.oc.dest_port="4443"
uci set firewall.oc.proto="tcp udp"
uci set firewall.oc.target="ACCEPT"
uci commit firewall
service firewall restart
```

### 4. VPN service

Configure VPN service.

```
# Configure VPN service
uci -q delete ocserv.config.enable
uci -q delete ocserv.config.zone
uci set ocserv.config.port="${VPN_PORT}"
uci set ocserv.config.ipaddr="${VPN_POOL% *}"
uci set ocserv.config.netmask="${VPN_POOL#* }"
uci -q delete ocserv.@routes[0]
uci -q delete ocserv.@dns[0]
uci set ocserv.dns="dns"
uci set ocserv.dns.ip="${VPN_DNS}"
uci -q delete ocserv.@ocservusers[0]
uci set ocserv.client="ocservusers"
uci set ocserv.client.name="${VPN_USER}"
uci set ocserv.client.password="${VPN_HASH}"
uci commit ocserv
service ocserv restart
```

## Web-based configuration

If you want to manage VPN server settings using web interface:

```
# Install packages
opkg update
opkg install luci-app-ocserv
service rpcd restart
```

Navigate to **LuCI → VPN → OpenConnect VPN** to configure OpenConnect server.

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
service log restart; service ocserv restart; sleep 10
 
# Log and status
logread -e ocserv; netstat -l -n -p | grep -e ocserv
 
# Runtime configuration
pgrep -f -a ocserv
ip address show; ip route show table all
ip rule show; ip -6 rule show; nft list ruleset
 
# Persistent configuration
uci show network; uci show firewall; uci show ocserv
```
