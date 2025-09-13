# Guest Wi-Fi extras

This article relies on the following:

- Accessing [web interface](/docs/guide-quick-start/walkthrough_login "docs:guide-quick-start:walkthrough_login") / [command-line interface](/docs/guide-quick-start/sshadministration "docs:guide-quick-start:sshadministration")
- Managing [configs](/docs/guide-user/base-system/uci "docs:guide-user:base-system:uci") / [packages](/docs/guide-user/additional-software/managing_packages "docs:guide-user:additional-software:managing_packages") / [services](/docs/guide-user/base-system/managing_services "docs:guide-user:base-system:managing_services") / [logs](/docs/guide-user/base-system/log.essentials "docs:guide-user:base-system:log.essentials")

## Introduction

- This how-to describes the most common guest Wi-Fi tuning scenarios adapted for OpenWrt.
- Follow [Guest Wi-Fi basics](/docs/guide-user/network/wifi/guestwifi/guest-wlan "docs:guide-user:network:wifi:guestwifi:guest-wlan") for setting up guest Wi-Fi.

## Extras

### Dual-band

If you want to utilize dual-band. Change the interface ID if necessary.

```
# Configure wireless
WIFI_DEV="$(uci get wireless.@wifi-iface[1].device)"
uci -q delete wireless.guest2
uci set wireless.guest2="wifi-iface"
uci set wireless.guest2.device="${WIFI_DEV}"
uci set wireless.guest2.mode="ap"
uci set wireless.guest2.network="guest"
uci set wireless.guest2.ssid="guest2"
uci set wireless.guest2.encryption="none"
uci commit wireless
wifi reload
```

The following settings should be applied separately for each SSID/band.

### Providing encryption

Secure your guest network.

```
# Configure wireless
WIFI_PSK="GUEST_WIFI_PASSWORD"
uci set wireless.guest.encryption="psk2"
uci set wireless.guest.key="${WIFI_PSK}"
uci commit wireless
wifi reload
```

### Isolating clients

Isolate guest clients from each other. Some hardware or drivers might not support this option.

```
# Configure wireless
uci set wireless.guest.isolate="1"
uci commit wireless
wifi reload
```

### ICMP / ICMPv6

Allow incoming ICMP and ICMPv6 traffic. Change the rule IDs if necessary. The goal here is to alter the default OpenWRT firewall rules allowing specific ICMP and ICMPv6 types from WAN to instead allow from all source zones. The rules are originally called “Allow-Ping” and “Allow-ICMPv6-Input”.

```
# Configure firewall
uci rename firewall.@rule[1]="icmp"
uci rename firewall.@rule[5]="icmp6"
uci set firewall.icmp.src="*"
uci set firewall.icmp6.src="*"
uci commit firewall
service firewall restart
```

### IPv6

Enable IPv6 on the guest network.

**Prerequisite:** Allow [ICMPv6](/docs/guide-user/network/wifi/guestwifi/extras#icmpicmpv6 "docs:guide-user:network:wifi:guestwifi:extras"), at least from the guest network to the router. Note that in IPv6, unlike IPv4, ICMP is a requirement.

The following will assign an IPv6 prefix, configure a DHCPv6 pool, and allow DHCPv6 requests.

```
# Configure network
uci set network.guest.ip6assign="60"
uci commit network
service network restart
 
# Configure DHCP
uci set dhcp.guest.dhcpv6="server"
uci set dhcp.guest.ra="server"
uci -q delete dhcp.guest.ra_flags
uci add_list dhcp.guest.ra_flags="managed-config"
uci add_list dhcp.guest.ra_flags="other-config"
uci commit dhcp
service odhcpd restart
 
# Configure firewall
uci -q delete firewall.guest_dhcp6
uci set firewall.guest_dhcp6="rule"
uci set firewall.guest_dhcp6.name="Allow-DHCPv6-Guest"
uci set firewall.guest_dhcp6.src="guest"
uci set firewall.guest_dhcp6.dest_port="547"
uci set firewall.guest_dhcp6.proto="udp"
uci set firewall.guest_dhcp6.family="ipv6"
uci set firewall.guest_dhcp6.target="ACCEPT"
uci commit firewall
service firewall restart
```

You may need to request a shorter prefix length from your ISP (i.e. more available addresses) and configure your networks to use a smaller chunk of that delegated prefix:

```
uci set network.wan6.reqprefix="60"
uci set network.lan.ip6assign="64"
uci set network.guest.ip6assign="64"
```

You can see what prefix your ISP gave you under Network → Interfaces → wan6 → IPv6-PD. [Subnets in IPv6 should be at least of size /64](https://serverfault.com/a/426207 "https://serverfault.com/a/426207"), so requesting a /60 prefix allows up to 24 = 16 subnets.

### IPv6-only guest network

While your primary LAN may have legacy devices that only support IPv4, most modern phones, tablets, and laptops fully support IPv6 and so you may be able to run an IPv6 only guest network, by simply not allocating an IPv4 address to the network or providing and DHCPv4 addresses.

To enable IPv6 guests to access legacy IPv4 only websites you need to set up DNS64 + NAT64.

- Set the advertised DNS servers for your guest network to Google DNS64, or your own DNS64 service
- Configure [NAT64](/docs/guide-user/network/ipv6/nat64 "docs:guide-user:network:ipv6:nat64") on your OpenWrt router to provide network translation (similar how you would otherwise be providing NAT44 from a private IPv4 range).

### Restricting internet access

Allow guest clients to only browse websites.

```
# Configure firewall
uci -q delete firewall.guest_wan
uci -q delete firewall.guest_fwd
uci set firewall.guest_fwd="rule"
uci set firewall.guest_fwd.name="Allow-HTTP/HTTPS-Guest-Forward"
uci set firewall.guest_fwd.src="guest"
uci set firewall.guest_fwd.dest="wan"
uci add_list firewall.guest_fwd.dest_port="80"
uci add_list firewall.guest_fwd.dest_port="443"
uci set firewall.guest_fwd.proto="tcp"
uci set firewall.guest_fwd.target="ACCEPT"
uci commit firewall
service firewall restart
```

### Restricting upstream access / Wireless AP

Allow guest clients to access the internet but restrict upstream access.

```
# Fetch upstream subnet and zone
. /lib/functions/network.sh
network_flush_cache
network_find_wan NET_IF
network_get_subnet NET_SUB "${NET_IF}"
FW_WAN="$(fw3 -q network "${NET_IF}")"
 
# Configure firewall
uci -q delete firewall.guest_wan
uci -q delete firewall.guest_fwd
uci set firewall.guest_fwd="rule"
uci set firewall.guest_fwd.name="Allow-Guest-Forward"
uci set firewall.guest_fwd.src="guest"
uci set firewall.guest_fwd.dest="${FW_WAN}"
uci set firewall.guest_fwd.dest_ip="!${NET_SUB}"
uci set firewall.guest_fwd.proto="all"
uci set firewall.guest_fwd.target="ACCEPT"
uci commit firewall
service firewall restart
```

Enable masquerading for the LAN zone when using a wireless AP.

```
# Configure firewall
uci rename firewall.@zone[0]="lan"
uci set firewall.lan.masq="1"
uci set firewall.lan.masq_src="!${NET_SUB}"
uci commit firewall
service firewall restart
```

### Resolving race conditions

Resolve the [race condition](https://forum.openwrt.org/t/workaround-gl-ar150-no-dhcp-if-lan-cable-is-not-plugged-during-boot/32349 "https://forum.openwrt.org/t/workaround-gl-ar150-no-dhcp-if-lan-cable-is-not-plugged-during-boot/32349") with netifd service.

```
# Configure DHCP
uci set dhcp.guest.force="1"
uci commit dhcp
service dnsmasq restart
```

### Limiting bandwidth

Limit the bandwidth of the guest network using kb/s.

```
opkg update
opkg install qos-scripts
uci -q delete qos.guest
uci set qos.guest="interface"
uci set qos.guest.enabled="1"
uci set qos.guest.upload="5000"
uci set qos.guest.download="80000"
uci commit qos
service qos restart
```

Or, alternatively via interface by installing [luci-app-sqm](/packages/pkgdata/luci-app-sqm "packages:pkgdata:luci-app-sqm") and configuring via web interface. SQM (Smart Queue Management) wiki here: [sqm](/docs/guide-user/network/traffic-shaping/sqm "docs:guide-user:network:traffic-shaping:sqm")

### Multiple network devices

For a network setup that involves two or more network devices (e.g. a router, one or more switches, one or more access points) you need to provide a [separate VLAN](/docs/guide-user/network/vlan/creating_virtual_switches "docs:guide-user:network:vlan:creating_virtual_switches"). On every router, switch or AP we add an interface type `bridge` which will put the wired and wireless guest interfaces in one network.

### HotSpot / Captive portal

If you want to setup a simple Hotspot for your guest network, take a look at [Nodogsplash](/docs/guide-user/services/captive-portal/wireless.hotspot.nodogsplash "docs:guide-user:services:captive-portal:wireless.hotspot.nodogsplash") or [WiFiDog](/docs/guide-user/services/captive-portal/wireless.hotspot.wifidog "docs:guide-user:services:captive-portal:wireless.hotspot.wifidog").

For a captive portal to a commercial [ChilliSpot](http://www.chillispot.org/ "http://www.chillispot.org/") compatible Hotspot service provider, look at [CoovaChilli](/docs/guide-user/services/captive-portal/wireless.hotspot.coova-chilli "docs:guide-user:services:captive-portal:wireless.hotspot.coova-chilli").

### Automated

Automated guest network setup.

```
URL="https://openwrt.org/_export/code/docs/guide-user/network/wifi/guestwifi/guest-wlan"
cat << EOF > guest-wlan.sh
$(wget -U "" -O - "${URL}?codeblock=0")
$(wget -U "" -O - "${URL}?codeblock=1")
$(wget -U "" -O - "${URL}?codeblock=2")
$(wget -U "" -O - "${URL}?codeblock=3")
EOF
sh guest-wlan.sh
```
