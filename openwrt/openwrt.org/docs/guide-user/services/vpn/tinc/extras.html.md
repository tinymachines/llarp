# Tinc extras

This article relies on the following:

- Accessing [web interface](/docs/guide-quick-start/walkthrough_login "docs:guide-quick-start:walkthrough_login") / [command-line interface](/docs/guide-quick-start/sshadministration "docs:guide-quick-start:sshadministration")
- Managing [configs](/docs/guide-user/base-system/uci "docs:guide-user:base-system:uci") / [packages](/docs/guide-user/additional-software/managing_packages "docs:guide-user:additional-software:managing_packages") / [services](/docs/guide-user/base-system/managing_services "docs:guide-user:base-system:managing_services") / [logs](/docs/guide-user/base-system/log.essentials "docs:guide-user:base-system:log.essentials")

## Introduction

- This how-to describes the most common [Tinc](https://en.wikipedia.org/wiki/Tinc_%28protocol%29 "https://en.wikipedia.org/wiki/Tinc_(protocol)") tuning scenarios adapted for OpenWrt.
- Follow [Tinc server](/docs/guide-user/services/vpn/tinc/server "docs:guide-user:services:vpn:tinc:server") for server setup and [Tinc client](/docs/guide-user/services/vpn/tinc/client "docs:guide-user:services:vpn:tinc:client") for client setup.
- Follow [DDNS client](/docs/guide-user/services/ddns/client "docs:guide-user:services:ddns:client") to use own server with dynamic IP address.
- Follow [Random generator](/docs/guide-user/services/rng "docs:guide-user:services:rng") to overcome low entropy issues.

## Extras

### References

- [Tinc documentation](https://www.tinc-vpn.org/docs/ "https://www.tinc-vpn.org/docs/")

### Site-to-site

Implement plain routing between server side LAN and client side LAN assuming that:

- `192.168.1.0/24` - server side LAN
- `192.168.2.0/24` - client side LAN

Configure subnets on VPN server and client.

```
uci add_list tinc.server.Subnet="192.168.1.0/24"
uci add_list tinc.client.Subnet="192.168.2.0/24"
uci commit tinc
service tinc restart
```

Consider VPN network as private and assign VPN interface to LAN zone on VPN client.

```
uci del_list firewall.wan.network="vpn"
uci add_list firewall.lan.network="vpn"
uci commit firewall
service firewall restart
```

### Default gateway

If you do not need to route all traffic to VPN. Disable gateway redirection on VPN client.

```
for IPV in 4 6
do
uci -q delete network.lan.ip${IPV}table
uci -q delete network.vpn.ip${IPV}table
uci -q delete network.vpn_rt${IPV%4}
uci -q delete network.lan_vpn${IPV%4}
done
uci del_list tinc.server.Subnet="0.0.0.0/0"
uci del_list tinc.server.Subnet="::/0"
uci commit network
service network restart
```

### Split gateway

If VPN gateway is separate from your LAN gateway. Implement plain routing between LAN and VPN networks assuming that:

- `192.168.1.0/24` - LAN network
- `192.168.1.2/24` - VPN gateway
- `192.168.9.0/24` - VPN network

Add port forwarding for VPN server on LAN gateway.

```
uci -q delete firewall.tinc
uci set firewall.tinc="redirect"
uci set firewall.tinc.name="Redirect-Tinc"
uci set firewall.tinc.src="wan"
uci set firewall.tinc.src_dport="655"
uci set firewall.tinc.dest="lan"
uci set firewall.tinc.dest_ip="192.168.1.2"
uci set firewall.tinc.family="ipv4"
uci set firewall.tinc.proto="tcp"
uci set firewall.tinc.target="DNAT"
uci commit firewall
service firewall restart
```

Add route to VPN network via VPN gateway on LAN gateway.

```
uci -q delete network.vpn
uci set network.vpn="route"
uci set network.vpn.interface="lan"
uci set network.vpn.target="192.168.9.0/24"
uci set network.vpn.gateway="192.168.1.2"
uci commit network
service network restart
```

### DNS over VPN

[Serve DNS](/docs/guide-user/base-system/dhcp_configuration#providing_dns_for_non-local_networks "docs:guide-user:base-system:dhcp_configuration") for VPN clients on OpenWrt server when using point-to-point topology.

Route DNS over VPN to prevent DNS leaks on VPN client.

[Replace peer DNS](/docs/guide-user/base-system/dhcp_configuration#upstream_dns_provider "docs:guide-user:base-system:dhcp_configuration") with public or VPN-specific DNS provider on OpenWrt client.

Modify the VPN connection using NetworkManager on Linux desktop client.

```
nmcli connection modify id VPN_CON \
ipv4.dns-search ~. ipv4.dns-priority -50 \
ipv6.dns-search ~. ipv6.dns-priority -50
```

### Kill switch

Prevent traffic leaks on OpenWrt client isolating VPN interface in a separate firewall zone.

```
uci -q delete firewall.vpn
uci set firewall.vpn="zone"
uci set firewall.vpn.name="vpn"
uci set firewall.vpn.input="REJECT"
uci set firewall.vpn.output="ACCEPT"
uci set firewall.vpn.forward="REJECT"
uci set firewall.vpn.masq="1"
uci set firewall.vpn.mtu_fix="1"
uci add_list firewall.vpn.network="vpn"
uci del_list firewall.wan.network="vpn"
uci -q delete firewall.@forwarding[0]
uci set firewall.lan_vpn="forwarding"
uci set firewall.lan_vpn.src="lan"
uci set firewall.lan_vpn.dest="vpn"
uci commit firewall
service firewall restart
```

### Automated

Automated VPN server installation.

```
URL="https://openwrt.org/_export/code/docs/guide-user/services/vpn/tinc/server"
cat << EOF > tinc-server.sh
$(wget -U "" -O - "${URL}?codeblock=0")
$(wget -U "" -O - "${URL}?codeblock=1")
$(wget -U "" -O - "${URL}?codeblock=2")
$(wget -U "" -O - "${URL}?codeblock=3")
$(wget -U "" -O - "${URL}?codeblock=4")
EOF
sh tinc-server.sh
```
