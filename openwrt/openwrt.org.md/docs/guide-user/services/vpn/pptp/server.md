# PPTP server

This article relies on the following:

- Accessing [web interface](/docs/guide-quick-start/walkthrough_login "docs:guide-quick-start:walkthrough_login") / [command-line interface](/docs/guide-quick-start/sshadministration "docs:guide-quick-start:sshadministration")
- Managing [configs](/docs/guide-user/base-system/uci "docs:guide-user:base-system:uci") / [packages](/docs/guide-user/additional-software/managing_packages "docs:guide-user:additional-software:managing_packages") / [services](/docs/guide-user/base-system/managing_services "docs:guide-user:base-system:managing_services") / [logs](/docs/guide-user/base-system/log.essentials "docs:guide-user:base-system:log.essentials")

## Introduction

- This how-to describes the method for setting up [PPTP](https://en.wikipedia.org/wiki/Point-to-Point_Tunneling_Protocol "https://en.wikipedia.org/wiki/Point-to-Point_Tunneling_Protocol") server on OpenWrt.
- Follow [PPTP client](/docs/guide-user/services/vpn/pptp/client "docs:guide-user:services:vpn:pptp:client") for client setup and [PPTP extras](/docs/guide-user/services/vpn/pptp/extras "docs:guide-user:services:vpn:pptp:extras") for additional tuning.

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
opkg install pptpd kmod-nf-nathelper-extra
 
# Configuration parameters
VPN_POOL="192.168.9.128-254"
VPN_USER="USERNAME"
VPN_PASS="PASSWORD"
```

### 2. Firewall

Enable conntrack helper to allow related GRE traffic. Consider VPN network as private. Assign VPN interface to LAN zone to minimize firewall setup. Allow access to VPN server from WAN zone.

```
# Configure kernel parameters
cat << EOF >> /etc/sysctl.conf
net.netfilter.nf_conntrack_helper=1
EOF
service sysctl restart
 
# Configure firewall
uci rename firewall.@zone[0]="lan"
uci rename firewall.@zone[1]="wan"
uci del_list firewall.lan.device="ppp+"
uci add_list firewall.lan.device="ppp+"
uci -q delete firewall.pptp
uci set firewall.pptp="rule"
uci set firewall.pptp.name="Allow-PPTP"
uci set firewall.pptp.src="wan"
uci set firewall.pptp.dest_port="1723"
uci set firewall.pptp.proto="tcp"
uci set firewall.pptp.target="ACCEPT"
uci commit firewall
service firewall restart
```

### 3. VPN service

Configure VPN service.

```
# Configure VPN service
uci set pptpd.pptpd.enabled="1"
uci set pptpd.pptpd.logwtmp="0"
uci set pptpd.pptpd.localip="${VPN_POOL%.*}.1"
uci set pptpd.pptpd.remoteip="${VPN_POOL}"
uci -q delete pptpd.@login[0]
uci set pptpd.client="login"
uci set pptpd.client.username="${VPN_USER}"
uci set pptpd.client.password="${VPN_PASS}"
uci commit pptpd
service pptpd restart
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
service log restart; service pptpd restart; sleep 10
 
# Log and status
logread -e pptpd; netstat -l -n -p | grep -e pptpd
 
# Runtime configuration
pgrep -f -a pptpd
ip address show; ip route show table all
ip rule show; ip -6 rule show; nft list ruleset
sysctl net.netfilter.nf_conntrack_helper
 
# Persistent configuration
uci show network; uci show firewall; uci show pptpd
grep -v -e "^#" -e "^$" /etc/sysctl.conf
```
