# Guest Wi-Fi basics

This article relies on the following:

- Accessing [web interface](/docs/guide-quick-start/walkthrough_login "docs:guide-quick-start:walkthrough_login") / [command-line interface](/docs/guide-quick-start/sshadministration "docs:guide-quick-start:sshadministration")
- Managing [configs](/docs/guide-user/base-system/uci "docs:guide-user:base-system:uci") / [packages](/docs/guide-user/additional-software/managing_packages "docs:guide-user:additional-software:managing_packages") / [services](/docs/guide-user/base-system/managing_services "docs:guide-user:base-system:managing_services") / [logs](/docs/guide-user/base-system/log.essentials "docs:guide-user:base-system:log.essentials")

## Introduction

- Guest Wi-Fi provides an isolated wireless network which is independent from your main WLAN.
- Guest clients have internet connectivity and restricted LAN connectivity.
- Follow [Guest Wi-Fi extras](/docs/guide-user/network/wifi/guestwifi/extras "docs:guide-user:network:wifi:guestwifi:extras") for additional tuning.

## Goals

- Create an open wireless network independent from the main WLAN.
- Provide internet connectivity to guest clients and restrict LAN connectivity.

## Command-line instructions

### 1. Network

Set up a guest network interface.

```
# Configure network
uci -q delete network.guest_dev
uci set network.guest_dev="device"
uci set network.guest_dev.type="bridge"
uci set network.guest_dev.name="br-guest"
uci -q delete network.guest
uci set network.guest="interface"
uci set network.guest.proto="static"
uci set network.guest.device="br-guest"
uci set network.guest.ipaddr="192.168.3.1/24"
uci commit network
service network restart
```

### 2. Wireless

Set up a wireless interface bound to the guest network interface.

```
# Configure wireless
WIFI_DEV="$(uci get wireless.@wifi-iface[0].device)"
uci -q delete wireless.guest
uci set wireless.guest="wifi-iface"
uci set wireless.guest.device="${WIFI_DEV}"
uci set wireless.guest.mode="ap"
uci set wireless.guest.network="guest"
uci set wireless.guest.ssid="guest"
uci set wireless.guest.encryption="none"
uci commit wireless
wifi reload
```

[Secure](/docs/guide-user/network/wifi/guestwifi/extras#providing_encryption "docs:guide-user:network:wifi:guestwifi:extras") the guest network and [isolate](/docs/guide-user/network/wifi/guestwifi/extras#isolating_clients "docs:guide-user:network:wifi:guestwifi:extras") its clients if necessary.

### 3. DHCP

Configure a DHCP pool for the guest network.

```
# Configure DHCP
uci -q delete dhcp.guest
uci set dhcp.guest="dhcp"
uci set dhcp.guest.interface="guest"
uci set dhcp.guest.start="100"
uci set dhcp.guest.limit="150"
uci set dhcp.guest.leasetime="1h"
uci commit dhcp
service dnsmasq restart
```

### 4. Firewall

Configure firewall for the guest network. Allow to forward traffic from the guest network to WAN. Allow DHCP requests and DNS queries.

```
# Configure firewall
uci -q delete firewall.guest
uci set firewall.guest="zone"
uci set firewall.guest.name="guest"
uci set firewall.guest.network="guest"
uci set firewall.guest.input="REJECT"
uci set firewall.guest.output="ACCEPT"
uci set firewall.guest.forward="REJECT"
uci -q delete firewall.guest_wan
uci set firewall.guest_wan="forwarding"
uci set firewall.guest_wan.src="guest"
uci set firewall.guest_wan.dest="wan"
uci -q delete firewall.guest_dns
uci set firewall.guest_dns="rule"
uci set firewall.guest_dns.name="Allow-DNS-Guest"
uci set firewall.guest_dns.src="guest"
uci set firewall.guest_dns.dest_port="53"
uci set firewall.guest_dns.proto="tcp udp"
uci set firewall.guest_dns.target="ACCEPT"
uci -q delete firewall.guest_dhcp
uci set firewall.guest_dhcp="rule"
uci set firewall.guest_dhcp.name="Allow-DHCP-Guest"
uci set firewall.guest_dhcp.src="guest"
uci set firewall.guest_dhcp.dest_port="67"
uci set firewall.guest_dhcp.proto="udp"
uci set firewall.guest_dhcp.family="ipv4"
uci set firewall.guest_dhcp.target="ACCEPT"
uci commit firewall
service firewall restart
```

## Testing

Connect to the guest network. Check your internet connectivity.

- [ipleak.net](https://ipleak.net/ "https://ipleak.net/")

Use [ping](http://man.cx/ping%288%29 "http://man.cx/ping%288%29"), [ping6](http://man.cx/ping6%288%29 "http://man.cx/ping6%288%29") or [nmap](http://man.cx/nmap%281%29 "http://man.cx/nmap%281%29") to verify your firewall configuration.

## Troubleshooting

Collect and analyze the following information.

```
# Restart services
service log restart; service network restart
service dnsmasq restart; service firewall restart
 
# Log and status
logread; netstat -l -n -p | grep -e dnsmasq
 
# Runtime configuration
pgrep -f -a dnsmasq
ip address show; ip route show table all
ip rule show; ip -6 rule show; nft list ruleset
head -v -n -0 /etc/resolv.* /tmp/resolv.* /tmp/resolv.*/*
 
# Persistent configuration
uci show network; uci show wireless; uci show dhcp; uci show firewall
```
