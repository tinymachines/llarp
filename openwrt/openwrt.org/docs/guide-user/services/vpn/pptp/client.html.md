# PPTP client

This article relies on the following:

- Accessing [web interface](/docs/guide-quick-start/walkthrough_login "docs:guide-quick-start:walkthrough_login") / [command-line interface](/docs/guide-quick-start/sshadministration "docs:guide-quick-start:sshadministration")
- Managing [configs](/docs/guide-user/base-system/uci "docs:guide-user:base-system:uci") / [packages](/docs/guide-user/additional-software/managing_packages "docs:guide-user:additional-software:managing_packages") / [services](/docs/guide-user/base-system/managing_services "docs:guide-user:base-system:managing_services") / [logs](/docs/guide-user/base-system/log.essentials "docs:guide-user:base-system:log.essentials")

## Introduction

- This how-to describes the method for setting up [PPTP](https://en.wikipedia.org/wiki/Point-to-Point_Tunneling_Protocol "https://en.wikipedia.org/wiki/Point-to-Point_Tunneling_Protocol") client on OpenWrt.
- Follow [PPTP server](/docs/guide-user/services/vpn/pptp/server "docs:guide-user:services:vpn:pptp:server") for server setup and [PPTP extras](/docs/guide-user/services/vpn/pptp/extras "docs:guide-user:services:vpn:pptp:extras") for additional tuning.

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
opkg install ppp-mod-pptp kmod-nf-nathelper-extra
 
# Configuration parameters
VPN_IF="vpn"
VPN_SERV="SERVER_ADDRESS"
VPN_USER="USERNAME"
VPN_PASS="PASSWORD"
```

### 2. Firewall

Enable conntrack helper to allow related GRE traffic. Consider VPN network as public. Assign VPN interface to WAN zone to minimize firewall setup.

```
# Configure kernel parameters
cat << EOF >> /etc/sysctl.conf
net.netfilter.nf_conntrack_helper=1
EOF
service sysctl restart
 
# Configure firewall
uci rename firewall.@zone[0]="lan"
uci rename firewall.@zone[1]="wan"
uci del_list firewall.wan.network="${VPN_IF}"
uci add_list firewall.wan.network="${VPN_IF}"
uci commit firewall
service firewall restart
```

### 3. Network

Set up VPN interface.

```
# Configure network
uci -q delete network.${VPN_IF}
uci set network.${VPN_IF}="interface"
uci set network.${VPN_IF}.proto="pptp"
uci set network.${VPN_IF}.server="${VPN_SERV}"
uci set network.${VPN_IF}.username="${VPN_USER}"
uci set network.${VPN_IF}.password="${VPN_PASS}"
uci set network.${VPN_IF}.ipv6="1"
uci commit network
service network restart
```

Configure [dynamic connection](/docs/guide-user/services/vpn/pptp/extras#dynamic_connection "docs:guide-user:services:vpn:pptp:extras") if necessary.

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
logread -e pppd
 
# Runtime configuration
pgrep -f -a pppd
ip address show; ip route show table all
ip rule show; ip -6 rule show; nft list ruleset
sysctl net.netfilter.nf_conntrack_helper
 
# Persistent configuration
uci show network; uci show firewall
grep -v -e "^#" -e "^$" /etc/sysctl.conf
```
