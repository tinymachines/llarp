# OpenVPN client

This article relies on the following:

- Accessing [web interface](/docs/guide-quick-start/walkthrough_login "docs:guide-quick-start:walkthrough_login") / [command-line interface](/docs/guide-quick-start/sshadministration "docs:guide-quick-start:sshadministration")
- Managing [configs](/docs/guide-user/base-system/uci "docs:guide-user:base-system:uci") / [packages](/docs/guide-user/additional-software/managing_packages "docs:guide-user:additional-software:managing_packages") / [services](/docs/guide-user/base-system/managing_services "docs:guide-user:base-system:managing_services") / [logs](/docs/guide-user/base-system/log.essentials "docs:guide-user:base-system:log.essentials")

## Introduction

- This how-to describes the method for setting up [OpenVPN](https://en.wikipedia.org/wiki/OpenVPN "https://en.wikipedia.org/wiki/OpenVPN") client on OpenWrt.
- Follow [OpenVPN server](/docs/guide-user/services/vpn/openvpn/server "docs:guide-user:services:vpn:openvpn:server") for server setup and [OpenVPN extras](/docs/guide-user/services/vpn/openvpn/extras "docs:guide-user:services:vpn:openvpn:extras") for additional tuning.

## Goals

- Encrypt your internet connection to enforce security and privacy.
  
  - Prevent traffic leaks and spoofing on the client side.
- Bypass regional restrictions using commercial providers.
  
  - Escape client side content filters and internet censorship.
- Access your LAN services remotely without port forwarding.

## Command-line instructions

### 1. Preparation

Install the required packages.

```
# Install packages
opkg update
opkg install openvpn-openssl
```

### 2. Firewall

Consider VPN network as public. Assign VPN interface to WAN zone to minimize firewall setup.

```
# Configure firewall
uci rename firewall.@zone[0]="lan"
uci rename firewall.@zone[1]="wan"
uci del_list firewall.wan.device="tun+"
uci add_list firewall.wan.device="tun+"
uci commit firewall
service firewall restart
```

### 3. VPN service

Save your client profile to configure VPN service.

```
# Save VPN client profile
umask go=
cat << EOF > /etc/openvpn/client.conf
COPY_PASTE_CLIENT_PROFILE_HERE
EOF
service openvpn restart
```

Specify credentials for [commercial provider](/docs/guide-user/services/vpn/openvpn/extras#commercial_provider "docs:guide-user:services:vpn:openvpn:extras") and configure [dynamic connection](/docs/guide-user/services/vpn/openvpn/extras#dynamic_connection "docs:guide-user:services:vpn:openvpn:extras") if necessary.

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
service log restart; service openvpn restart; sleep 10
 
# Log and status
logread -e openvpn; netstat -l -n -p | grep -e openvpn
 
# Runtime configuration
pgrep -f -a openvpn
ip address show; ip route show table all
ip rule show; ip -6 rule show; nft list ruleset
 
# Persistent configuration
uci show network; uci show firewall; uci show openvpn
head -v -n -0 /etc/openvpn/*.conf
```
