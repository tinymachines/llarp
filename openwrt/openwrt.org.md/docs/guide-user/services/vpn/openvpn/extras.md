# OpenVPN extras

This article relies on the following:

- Accessing [web interface](/docs/guide-quick-start/walkthrough_login "docs:guide-quick-start:walkthrough_login") / [command-line interface](/docs/guide-quick-start/sshadministration "docs:guide-quick-start:sshadministration")
- Managing [configs](/docs/guide-user/base-system/uci "docs:guide-user:base-system:uci") / [packages](/docs/guide-user/additional-software/managing_packages "docs:guide-user:additional-software:managing_packages") / [services](/docs/guide-user/base-system/managing_services "docs:guide-user:base-system:managing_services") / [logs](/docs/guide-user/base-system/log.essentials "docs:guide-user:base-system:log.essentials")

## Introduction

- This how-to describes the most common [OpenVPN](https://en.wikipedia.org/wiki/OpenVPN "https://en.wikipedia.org/wiki/OpenVPN") tuning scenarios adapted for OpenWrt.
- Follow [OpenVPN server](/docs/guide-user/services/vpn/openvpn/server "docs:guide-user:services:vpn:openvpn:server") for server setup and [OpenVPN client](/docs/guide-user/services/vpn/openvpn/client "docs:guide-user:services:vpn:openvpn:client") for client setup.
- Follow [DDNS client](/docs/guide-user/services/ddns/client "docs:guide-user:services:ddns:client") to use own server with dynamic IP address.
- Follow [Random generator](/docs/guide-user/services/rng "docs:guide-user:services:rng") to overcome low entropy issues.

## Extras

### References

- [OpenVPN for BSD/Linux/Windows](https://openvpn.net/community-downloads/ "https://openvpn.net/community-downloads/")
- [OpenVPN for Android](https://github.com/schwabe/ics-openvpn#openvpn-for-android "https://github.com/schwabe/ics-openvpn#openvpn-for-android")
- [OpenVPN documentation](https://community.openvpn.net/ "https://community.openvpn.net/")

### Web interface

If you want to manage VPN instances using web interface. Install the necessary packages and provide [instance management](/docs/guide-user/services/vpn/openvpn/extras#instance_management "docs:guide-user:services:vpn:openvpn:extras").

```
# Install packages
opkg update
opkg install luci-app-openvpn
service rpcd restart
```

Navigate to **LuCI → VPN → OpenVPN** to manage OpenVPN instances.

### Instance management

If you need to manage multiple VPN instances or use web interface. Configure VPN instances.

```
# Provide VPN instance management
ls /etc/openvpn/*.conf \
| while read -r VPN_CONF
do VPN_ID="$(basename ${VPN_CONF%.*} | sed -e "s/\W/_/g")"
uci -q delete openvpn.${VPN_ID}
uci set openvpn.${VPN_ID}="openvpn"
uci set openvpn.${VPN_ID}.enabled="1"
uci set openvpn.${VPN_ID}.config="${VPN_CONF}"
done
uci commit openvpn
service openvpn restart
```

Be sure to specify a different VPN interface name for each instance.

### Commercial provider

If you use a commercial VPN provider. Set up credentials for username/password authentication.

```
# Save username/password credentials
umask go=
cat << EOF > /etc/openvpn/client.auth
USERNAME
PASSWORD
EOF
 
# Configure VPN service
cat << EOF >> /etc/openvpn/client.conf
auth-user-pass client.auth
EOF
service openvpn restart
```

### Dynamic connection

Set up [Hotplug extras](/docs/guide-user/advanced/hotplug_extras "docs:guide-user:advanced:hotplug_extras") to restart VPN client upon reconnecting WAN interface.

```
# Configure hotplug
mkdir -p /etc/hotplug.d/online
cat << "EOF" > /etc/hotplug.d/online/10-openvpn
case ${DEVICE} in
(tun*) exit 0 ;;
esac
service openvpn restart
EOF
cat << "EOF" >> /etc/sysupgrade.conf
/etc/hotplug.d/online/10-openvpn
EOF
```

### Dynamic address

Allow the peer to change its address/port.

```
# Configure VPN service
cat << EOF >> /etc/openvpn/client.conf
float
EOF
service openvpn restart
```

### Network interface

If you want to set up PBR. Declare the VPN interface.

```
uci del_list firewall.wan.device="tun+"
uci add_list firewall.wan.network="vpn"
uci commit firewall
service firewall restart
uci -q delete network.vpn
uci set network.vpn="interface"
uci set network.vpn.proto="none"
uci set network.vpn.device="tun0"
uci commit network
service network restart
```

Be sure to resolve [race condition](/docs/guide-user/services/vpn/openvpn/extras#dynamic_connection "docs:guide-user:services:vpn:openvpn:extras") with netifd service.

### Static addresses

Provide static IP address allocation on VPN server assuming that:

- `192.168.9.0/24` - VPN network
- `fd00:9::/64` - IPv6 VPN network

```
umask go=rx
mkdir -p /etc/openvpn/ccd
cat << EOF >> /etc/openvpn/ccd/client
ifconfig-push 192.168.9.2 255.255.255.0
ifconfig-ipv6-push fd00:9::2/64
EOF
cat << EOF >> /etc/openvpn/server.conf
client-config-dir ccd
EOF
service openvpn restart
```

### Site-to-site

Implement plain routing between server side LAN and [client side LAN](https://community.openvpn.net/openvpn/wiki/RoutedLans "https://community.openvpn.net/openvpn/wiki/RoutedLans") assuming that:

- `192.168.1.0/24` - server side LAN
- `192.168.2.0/24` - client side LAN

Add route to client side LAN, push route to server side LAN, selectively disable gateway redirection.

```
umask go=rx
mkdir -p /etc/openvpn/ccd
cat << EOF >> /etc/openvpn/ccd/client
iroute 192.168.2.0 255.255.255.0
push-remove redirect-gateway
EOF
cat << EOF >> /etc/openvpn/server.conf
client_config_dir ccd
route 192.168.2.0 255.255.255.0
push "route 192.168.1.0 255.255.255.0"
EOF
service openvpn restart
```

Consider VPN network as private and assign VPN interface to LAN zone on VPN client.

```
uci del_list firewall.wan.device="tun+"
uci add_list firewall.lan.device="tun+"
uci commit firewall
service firewall restart
```

### Default gateway

If you do not need to route all traffic to VPN. Disable gateway redirection on VPN client.

```
cat << EOF >> /etc/openvpn/client.conf
pull-filter ignore redirect-gateway
EOF
```

If you use a commercial VPN provider. Ignore routes pushed by VPN server.

```
cat << EOF >> /etc/openvpn/client.conf
route-nopull
EOF
```

### Split gateway

If VPN gateway is separate from your LAN gateway. Implement plain routing between LAN and VPN networks assuming that:

- `192.168.1.0/24` - LAN network
- `192.168.1.2/24` - VPN gateway
- `192.168.9.0/24` - VPN network

Add port forwarding for VPN server on LAN gateway.

```
uci -q delete firewall.ovpn
uci set firewall.ovpn="redirect"
uci set firewall.ovpn.name="Redirect-OpenVPN"
uci set firewall.ovpn.src="wan"
uci set firewall.ovpn.src_dport="1194"
uci set firewall.ovpn.dest="lan"
uci set firewall.ovpn.dest_ip="192.168.1.2"
uci set firewall.ovpn.family="ipv4"
uci set firewall.ovpn.proto="udp"
uci set firewall.ovpn.target="DNAT"
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

Set up [IPv6 tunnel broker](/docs/guide-user/network/ipv6/ipv6_henet "docs:guide-user:network:ipv6:ipv6_henet") or use [IPv6 NAT or NPT](/docs/guide-user/firewall/fw3_configurations/fw3_nat#ipv6_nat "docs:guide-user:firewall:fw3_configurations:fw3_nat") if necessary. Enable IPv6 tunnel on VPN server, offer IPv6 DNS, redirect IPv6 gateway.

```
VPN_POOL6="fd00:9::/64"
VPN_DNS6="${VPN_POOL6%:*}:1"
cat << EOF >> /etc/openvpn/server.conf
proto udp6
server-ipv6 ${VPN_POOL6}
push "dhcp-option DNS ${VPN_DNS6}"
push "redirect-gateway ipv6"
EOF
service openvpn restart
```

Disable [ISP prefix delegation](/docs/guide-user/network/ipv6/ipv6_extras#disabling_gua_prefix "docs:guide-user:network:ipv6:ipv6_extras") to prevent IPv6 leaks on VPN client.

### TCP

Use [TCP](https://openvpn.net/faq/why-does-openvpn-use-udp-and-tcp/ "https://openvpn.net/faq/why-does-openvpn-use-udp-and-tcp/") if necessary. Beware of performance issues.

```
VPN_PROTO="tcp"
cat << EOF >> /etc/openvpn/server.conf
proto ${VPN_PROTO}
proto ${VPN_PROTO}6
EOF
service openvpn restart
uci set firewall.ovpn.proto="${VPN_PROTO}"
uci commit firewall
service firewall restart
```

### Bridging

If you need to utilize [bridging](https://openvpn.net/community-resources/ethernet-bridging/ "https://openvpn.net/community-resources/ethernet-bridging/"). Beware of compatibility issues.

```
VPN_ADDR="$(uci -q get network.lan.ipaddr)"
VPN_MASK="$(uci -q get network.lan.netmask)"
VPN_POOL="${VPN_ADDR%.*}.128 ${VPN_ADDR%.*}.254"
VPN_DNS="${VPN_ADDR}"
cat << EOF >> /etc/openvpn/server.conf
dev tap
server-bridge ${VPN_ADDR} ${VPN_MASK} ${VPN_POOL}
push "dhcp-option DNS ${VPN_DNS}"
EOF
service openvpn restart
uci -q delete firewall.lan.device
uci commit firewall
service firewall restart
uci add_list network.@device[0].ports="tap0"
uci commit network
service network restart
```

### IPv6 Windows client

Fix IPv6 routing for Windows desktop client.

```
NETSH_IPV6="C:\\\\Windows\\\\System32\\\\cmd.exe /c netsh interface ipv6"
cat << EOF >> /etc/openvpn/client.ovpn
script-security 2
up '${NETSH_IPV6} set privacy state=disabled store=active & echo'
ipchange '${NETSH_IPV6} set global randomizeidentifiers=disabled store=active & echo'
route-up '${NETSH_IPV6} delete route prefix=%ifconfig_ipv6_local%/%ifconfig_ipv6_netbits% interface=%dev_idx% store=active'
EOF
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

Modify the VPN client profile for Windows desktop client.

```
cat << EOF >> /etc/openvpn/client.ovpn
block-outside-dns
EOF
```

### DNS and domain

Use DNS and domain provided by VPN server on OpenWrt client.

```
cat << "EOF" > /etc/hotplug.d/net/10-openvpn-resolv
case ${INTERFACE} in
(tun*) ;;
(*) exit 0 ;;
esac
RES_FILE="$(uci -q get dhcp.@dnsmasq[0].resolvfile)"
case ${ACTION} in
(add) RES_FILE="${RES_FILE%.*}.vpn" ;;
(remove) RES_FILE="${RES_FILE%.*}.auto" ;;
esac
uci set dhcp.@dnsmasq[0].resolvfile="${RES_FILE}"
service dnsmasq restart
EOF
cat << "EOF" > /etc/hotplug.d/openvpn/10-resolv
RES_FILE="$(uci -q get dhcp.@dnsmasq[0].resolvfile)"
env | sed -n -e "
/^foreign_option_.*=dhcp-option.*DNS/s//nameserver/p
/^foreign_option_.*=dhcp-option.*DOMAIN/s//search/p
" | sort -u > "${RES_FILE%.*}.vpn"
EOF
cat << "EOF" >> /etc/sysupgrade.conf
/etc/hotplug.d/net/10-openvpn-resolv
/etc/hotplug.d/openvpn/10-resolv
EOF
service openvpn restart
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
uci add_list firewall.vpn.device="tun+"
uci del_list firewall.wan.device="tun+"
uci -q delete firewall.@forwarding[0]
uci set firewall.lan_vpn="forwarding"
uci set firewall.lan_vpn.src="lan"
uci set firewall.lan_vpn.dest="vpn"
uci commit firewall
service firewall restart
```

### Multi-client

Set up multi-client VPN server. Use [EasyRSA](https://github.com/OpenVPN/easy-rsa#overview "https://github.com/OpenVPN/easy-rsa#overview") to add clients or revoke their certificates via CRL.

```
# Add one more client
easyrsa build-client-full client1 nopass
openvpn --tls-crypt-v2 ${EASYRSA_PKI}/private/server.pem \
--genkey tls-crypt-v2-client ${EASYRSA_PKI}/private/client1.pem
 
# Revoke client certificate
easyrsa revoke client
 
# Generate a CRL
easyrsa gen-crl
 
# Enable CRL verification
VPN_PKI="/etc/easy-rsa/pki"
VPN_CRL="$(cat ${VPN_PKI}/crl.pem)"
cat << EOF >> /etc/openvpn/server.conf
<crl-verify>
${VPN_CRL}
</crl-verify>
EOF
service openvpn restart
```

### Automated

Automated VPN server installation and client profiles generation.

```
URL="https://openwrt.org/_export/code/docs/guide-user/services/vpn/openvpn/server"
cat << EOF > openvpn-server.sh
$(wget -U "" -O - "${URL}?codeblock=0")
$(wget -U "" -O - "${URL}?codeblock=1")
$(wget -U "" -O - "${URL}?codeblock=2")
$(wget -U "" -O - "${URL}?codeblock=3")
EOF
sh openvpn-server.sh
```
