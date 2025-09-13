# PPTP extras

This article relies on the following:

- Accessing [web interface](/docs/guide-quick-start/walkthrough_login "docs:guide-quick-start:walkthrough_login") / [command-line interface](/docs/guide-quick-start/sshadministration "docs:guide-quick-start:sshadministration")
- Managing [configs](/docs/guide-user/base-system/uci "docs:guide-user:base-system:uci") / [packages](/docs/guide-user/additional-software/managing_packages "docs:guide-user:additional-software:managing_packages") / [services](/docs/guide-user/base-system/managing_services "docs:guide-user:base-system:managing_services") / [logs](/docs/guide-user/base-system/log.essentials "docs:guide-user:base-system:log.essentials")

## Introduction

- This how-to describes the most common [PPTP](https://en.wikipedia.org/wiki/Point-to-Point_Tunneling_Protocol "https://en.wikipedia.org/wiki/Point-to-Point_Tunneling_Protocol") tuning scenarios adapted for OpenWrt.
- Follow [PPTP server](/docs/guide-user/services/vpn/pptp/server "docs:guide-user:services:vpn:pptp:server") for server setup and [PPTP client](/docs/guide-user/services/vpn/pptp/client "docs:guide-user:services:vpn:pptp:client") for client setup.
- Follow [PPTP protocol](/docs/guide-user/network/tunneling_interface_protocols#protocol_pptp_point-to-point_tunneling_protocol "docs:guide-user:network:tunneling_interface_protocols") for client configuration.
- Follow [DDNS client](/docs/guide-user/services/ddns/client "docs:guide-user:services:ddns:client") to use own server with dynamic IP address.
- Follow [Random generator](/docs/guide-user/services/rng "docs:guide-user:services:rng") to overcome low entropy issues.

## Extras

### References

- [Poptop server documentation](http://poptop.sourceforge.net/dox/ "http://poptop.sourceforge.net/dox/")

### Web interface

If you want to manage VPN settings using web interface. Install the necessary packages.

```
# Install packages
opkg update
opkg install luci-proto-ppp
service rpcd restart
```

Navigate to **LuCI → Network → Interfaces** to configure PPTP.

### Dynamic connection

Preserve default route to restore WAN connectivity when VPN is disconnected.

```
# Preserve default route
uci set network.wan.metric="1024"
uci commit network
service network restart
```

### NAT traversal

Provide PPTP passthrough for LAN clients over your router.

```
# Install packages
opkg update
opkg install kmod-nf-nathelper-extra
service firewall restart
```

### Static addresses

Provide static IP address allocation on VPN server.

```
# Configure VPN service
rm -f /tmp/etc/chap-secrets
uci set pptpd.client.remoteip="192.168.9.2"
uci commit pptpd
service pptpd restart
```

### Site-to-site

Implement plain routing between server side LAN and client side LAN assuming that:

- `192.168.1.0/24` - server side LAN
- `192.168.2.0/24` - client side LAN

Set up [static address](/docs/guide-user/services/vpn/pptp/extras#static_addresses "docs:guide-user:services:vpn:pptp:extras") allocation on VPN server, add route to client side LAN.

```
cat << "EOF" > /etc/ppp/ip-up
#!/bin/sh
case ${IPREMOTE} in
(192.168.9.2) ip route add 192.168.2.0/24 via ${IPREMOTE} dev ${IFNAME} ;;
esac
EOF
chmod +x /etc/ppp/ip-up
```

Consider VPN network as private and assign VPN interface to LAN zone on VPN client, add route to server side LAN.

```
uci del_list firewall.wan.network="vpn"
uci add_list firewall.lan.network="vpn"
uci commit firewall
service firewall restart
uci -q delete network.vpn_rt
uci set network.vpn_rt="route"
uci set network.vpn_rt.interface="vpn"
uci set network.vpn_rt.target="192.168.1.0/24"
uci set network.vpn_rt.gateway="192.168.9.1"
uci commit network
service network restart
```

### Default gateway

This article relies on the following:

- Accessing [web interface](/docs/guide-quick-start/walkthrough_login "docs:guide-quick-start:walkthrough_login") / [command-line interface](/docs/guide-quick-start/sshadministration "docs:guide-quick-start:sshadministration")
- Managing [configs](/docs/guide-user/base-system/uci "docs:guide-user:base-system:uci") / [packages](/docs/guide-user/additional-software/managing_packages "docs:guide-user:additional-software:managing_packages") / [services](/docs/guide-user/base-system/managing_services "docs:guide-user:base-system:managing_services") / [logs](/docs/guide-user/base-system/log.essentials "docs:guide-user:base-system:log.essentials")

#### Introduction

- This how-to describes the most common [OpenConnect](https://en.wikipedia.org/wiki/OpenConnect "https://en.wikipedia.org/wiki/OpenConnect") tuning scenarios adapted for OpenWrt.
- Follow [OpenConnect server](/docs/guide-user/services/vpn/openconnect/server "docs:guide-user:services:vpn:openconnect:server") for server setup and [OpenConnect client](/docs/guide-user/services/vpn/openconnect/client "docs:guide-user:services:vpn:openconnect:client") for client setup.
- Follow [OpenConnect protocol](/docs/guide-user/network/tunneling_interface_protocols#protocol_openconnect_openconnect_vpn "docs:guide-user:network:tunneling_interface_protocols") for client configuration.
- Follow [DDNS client](/docs/guide-user/services/ddns/client "docs:guide-user:services:ddns:client") to use own server with dynamic IP address.
- Follow [Random generator](/docs/guide-user/services/rng "docs:guide-user:services:rng") to overcome low entropy issues.

#### Extras

##### References

- [OpenConnect official site](https://www.infradead.org/openconnect/ "https://www.infradead.org/openconnect/")
- [ocserv server documentation](https://ocserv.gitlab.io/www/manual.html "https://ocserv.gitlab.io/www/manual.html")
- [OpenConnect configuration examples](https://github.com/openwrt/packages/tree/master/net/ocserv "https://github.com/openwrt/packages/tree/master/net/ocserv")

##### Server certificate

Fetch server certificate from remote VPN server. Beware of possible MITM.

```
openssl s_client -showcerts -connect ${VPN_SERV}:${VPN_PORT} \
< /dev/null > server-cert.pem
```

##### Keep existing gateway

Preserve default route to restore WAN connectivity when VPN is disconnected.

```
# Preserve default route
uci set network.wan.metric="1024"
uci commit network
service network restart
```

##### Gateway redirection

Disable gateway redirection in the client if you don't need to route all traffic through VPN.

```
uci set network.vpn.defaultroute="0"
uci commit network
service network restart
```

##### Split gateway

If VPN gateway is separate from your LAN gateway. Implement plain routing between LAN and VPN networks assuming that:

- `192.168.1.0/24` - LAN network
- `192.168.1.2/24` - VPN gateway
- `192.168.9.0/24` - VPN network

Add port forwarding for VPN server on LAN gateway.

```
uci -q delete firewall.oc
uci set firewall.oc="redirect"
uci set firewall.oc.name="Redirect-OpenConnect"
uci set firewall.oc.src="wan"
uci set firewall.oc.src_dport="4443"
uci set firewall.oc.dest="lan"
uci set firewall.oc.dest_ip="192.168.1.2"
uci set firewall.oc.family="ipv4"
uci set firewall.oc.proto="tcp udp"
uci set firewall.oc.target="DNAT"
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

##### IPv6 gateway

Set up [IPv6 tunnel broker](/docs/guide-user/network/ipv6/ipv6_henet "docs:guide-user:network:ipv6:ipv6_henet") or use [IPv6 NAT or NPT](/docs/guide-user/firewall/fw3_configurations/fw3_nat#ipv6_nat "docs:guide-user:firewall:fw3_configurations:fw3_nat") if necessary. Enable IPv6 tunnel on VPN server, offer IPv6 DNS, redirect IPv6 gateway.

```
VPN_POOL6="fd00:9::/64"
VPN_DNS6="${VPN_POOL6%:*}:1"
uci set ocserv.config.ip6addr="${VPN_POOL6}"
uci -q delete ocserv.dns6
uci set ocserv.dns6="dns"
uci set ocserv.dns6.ip="${VPN_DNS6}"
uci commit ocserv
service ocserv restart
```

Disable [ISP prefix delegation](/docs/guide-user/network/ipv6/ipv6_extras#disabling_gua_prefix "docs:guide-user:network:ipv6:ipv6_extras") to prevent IPv6 leaks on VPN client.

##### DNS over VPN

[Serve DNS](/docs/guide-user/base-system/dhcp_configuration#providing_dns_for_non-local_networks "docs:guide-user:base-system:dhcp_configuration") for VPN clients on OpenWrt server when using point-to-point topology.

Route DNS over VPN to prevent DNS leaks on VPN client.

[Replace peer DNS](/docs/guide-user/base-system/dhcp_configuration#upstream_dns_provider "docs:guide-user:base-system:dhcp_configuration") with public or VPN-specific DNS provider on OpenWrt client.

Modify the VPN connection using NetworkManager on Linux desktop client.

```
nmcli connection modify id VPN_CON \
ipv4.dns-search ~. ipv4.dns-priority -50 \
ipv6.dns-search ~. ipv6.dns-priority -50
```

##### Kill switch

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

##### Multi-client

Generate [password hash](/docs/guide-user/services/vpn/openconnect/server#key_management "docs:guide-user:services:vpn:openconnect:server") for a new VPN client. Set up multi-client VPN server. Use unique credentials for each client.

```
# Configure VPN service
VPN_USER="USERNAME1"
VPN_PASS="PASSWORD1"
uci -q delete ocserv.client1
uci set ocserv.client1="ocservusers"
uci set ocserv.client1.name="${VPN_USER}"
uci set ocserv.client1.password="${VPN_HASH}"
uci commit ocserv
service ocserv restart
```

##### Automated

Automated VPN server installation.

```
URL="https://openwrt.org/_export/code/docs/guide-user/services/vpn/openconnect/server"
cat << EOF > openconnect-server.sh
$(wget -U "" -O - "${URL}?codeblock=0")
$(wget -U "" -O - "${URL}?codeblock=1")
$(wget -U "" -O - "${URL}?codeblock=2")
$(wget -U "" -O - "${URL}?codeblock=3")
EOF
sh openconnect-server.sh
```

### Split gateway

If VPN gateway is separate from your LAN gateway. Implement plain routing between LAN and VPN networks assuming that:

- `192.168.1.0/24` - LAN network
- `192.168.1.2/24` - VPN gateway
- `192.168.9.0/24` - VPN network

Add port forwarding for VPN server on LAN gateway.

```
uci -q delete firewall.pptp
uci set firewall.pptp="redirect"
uci set firewall.pptp.name="Redirect-PPTP"
uci set firewall.pptp.src="wan"
uci set firewall.pptp.src_dport="1723"
uci set firewall.pptp.dest="lan"
uci set firewall.pptp.dest_ip="192.168.1.2"
uci set firewall.pptp.family="ipv4"
uci set firewall.pptp.proto="tcp"
uci set firewall.pptp.target="DNAT"
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

### IPv6 gateway

Set up [IPv6 tunnel broker](/docs/guide-user/network/ipv6/ipv6_henet "docs:guide-user:network:ipv6:ipv6_henet") or use [IPv6 NAT or NPT](/docs/guide-user/firewall/fw3_configurations/fw3_nat#ipv6_nat "docs:guide-user:firewall:fw3_configurations:fw3_nat") if necessary. Configure IPv6 on VPN server.

```
cat << "EOF" > /etc/ppp/ip-up
#!/bin/sh
ip address add fd00:9::1/64 dev ${IFNAME}
EOF
chmod +x /etc/ppp/ip-up
```

Configure IPv6 on VPN client, redirect IPv6 gateway.

```
uci add_list firewall.wan.network="vpn6"
uci commit firewall
service firewall restart
uci -q delete network.vpn6
uci set network.vpn6="interface"
uci set network.vpn6.proto="static"
uci set network.vpn6.device="@vpn"
uci set network.vpn6.ip6addr="fd00:9::2/64"
uci -q delete network.vpn6_rt
uci set network.vpn6_rt="route6"
uci set network.vpn6_rt.interface="vpn6"
uci set network.vpn6_rt.target="::/0"
uci commit network
service network restart
```

Disable [ISP prefix delegation](/docs/guide-user/network/ipv6/ipv6_extras#disabling_gua_prefix "docs:guide-user:network:ipv6:ipv6_extras") to prevent IPv6 leaks on VPN client.

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

### Multi-client

Set up multi-client VPN server. Use unique credentials for each client.

```
# Configure VPN service
VPN_USER="USERNAME1"
VPN_PASS="PASSWORD1"
uci -q delete pptpd.client1
uci set pptpd.client1="login"
uci set pptpd.client1.username="${VPN_USER}"
uci set pptpd.client1.password="${VPN_PASS}"
uci commit pptpd
service pptpd restart
```

### Automated

Automated VPN server installation.

```
URL="https://openwrt.org/_export/code/docs/guide-user/services/vpn/pptp/server"
cat << EOF > pptp-server.sh
$(wget -U "" -O - "${URL}?codeblock=0")
$(wget -U "" -O - "${URL}?codeblock=1")
$(wget -U "" -O - "${URL}?codeblock=2")
EOF
sh pptp-server.sh
```
