# OpenVPN server

This article relies on the following:

- Accessing [web interface](/docs/guide-quick-start/walkthrough_login "docs:guide-quick-start:walkthrough_login") / [command-line interface](/docs/guide-quick-start/sshadministration "docs:guide-quick-start:sshadministration")
- Managing [configs](/docs/guide-user/base-system/uci "docs:guide-user:base-system:uci") / [packages](/docs/guide-user/additional-software/managing_packages "docs:guide-user:additional-software:managing_packages") / [services](/docs/guide-user/base-system/managing_services "docs:guide-user:base-system:managing_services") / [logs](/docs/guide-user/base-system/log.essentials "docs:guide-user:base-system:log.essentials")

## Introduction

- This how-to describes the method for setting up [OpenVPN](https://en.wikipedia.org/wiki/OpenVPN "https://en.wikipedia.org/wiki/OpenVPN") server on OpenWrt.
- Follow [OpenVPN client](/docs/guide-user/services/vpn/openvpn/client "docs:guide-user:services:vpn:openvpn:client") for client setup and [OpenVPN extras](/docs/guide-user/services/vpn/openvpn/extras "docs:guide-user:services:vpn:openvpn:extras") for additional tuning.
- It requires OpenWrt 21.02+ with OpenVPN 2.5+ supporting `tls-crypt-v2`.
  
  - OpenWrt 19.07 users with OpenVPN 2.4 should refer to an [older revision](/docs/guide-user/services/vpn/openvpn/server?rev=1632708683 "docs:guide-user:services:vpn:openvpn:server").

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
opkg install openvpn-openssl openvpn-easy-rsa
 
# Configuration parameters
VPN_DIR="/etc/openvpn"
VPN_PKI="/etc/easy-rsa/pki"
VPN_PORT="1194"
VPN_PROTO="udp"
VPN_POOL="192.168.9.0 255.255.255.0"
VPN_DNS="${VPN_POOL%.* *}.1"
VPN_DN="$(uci -q get dhcp.@dnsmasq[0].domain)"
 
# Fetch server address
NET_FQDN="$(uci -q get ddns.@service[0].lookup_host)"
. /lib/functions/network.sh
network_flush_cache
network_find_wan NET_IF
network_get_ipaddr NET_ADDR "${NET_IF}"
if [ -n "${NET_FQDN}" ]
then VPN_SERV="${NET_FQDN}"
else VPN_SERV="${NET_ADDR}"
fi
```

### 2. Key management

Use [EasyRSA](https://github.com/OpenVPN/easy-rsa#overview "https://github.com/OpenVPN/easy-rsa#overview") to manage the PKI. Utilize private key password protection if necessary.

```
# Configuration parameters
export EASYRSA_PKI="${VPN_PKI}"
export EASYRSA_TEMP_DIR="/tmp"
export EASYRSA_CERT_EXPIRE="3650"
export EASYRSA_BATCH="1"
 
# Remove and re-initialize PKI directory
easyrsa init-pki
 
# Generate DH parameters
easyrsa gen-dh
 
# Create a new CA
easyrsa build-ca nopass
 
# Generate server keys and certificate
easyrsa build-server-full server nopass
openvpn --genkey tls-crypt-v2-server ${EASYRSA_PKI}/private/server.pem
 
# Generate client keys and certificate
easyrsa build-client-full client nopass
openvpn --tls-crypt-v2 ${EASYRSA_PKI}/private/server.pem \
--genkey tls-crypt-v2-client ${EASYRSA_PKI}/private/client.pem
```

### 3. Firewall

Consider VPN network as private. Assign VPN interface to LAN zone to minimize firewall setup. Allow access to VPN server from WAN zone.

```
# Configure firewall
uci rename firewall.@zone[0]="lan"
uci rename firewall.@zone[1]="wan"
uci del_list firewall.lan.device="tun+"
uci add_list firewall.lan.device="tun+"
uci -q delete firewall.ovpn
uci set firewall.ovpn="rule"
uci set firewall.ovpn.name="Allow-OpenVPN"
uci set firewall.ovpn.src="wan"
uci set firewall.ovpn.dest_port="${VPN_PORT}"
uci set firewall.ovpn.proto="${VPN_PROTO}"
uci set firewall.ovpn.target="ACCEPT"
uci commit firewall
service firewall restart
```

### 4. VPN service

Configure VPN service and generate client profiles.

```
# Configure VPN service and generate client profiles
umask go=
VPN_DH="$(cat ${VPN_PKI}/dh.pem)"
VPN_CA="$(openssl x509 -in ${VPN_PKI}/ca.crt)"
ls ${VPN_PKI}/issued \
| sed -e "s/\.\w*$//" \
| while read -r VPN_ID
do
VPN_TC="$(cat ${VPN_PKI}/private/${VPN_ID}.pem)"
VPN_KEY="$(cat ${VPN_PKI}/private/${VPN_ID}.key)"
VPN_CERT="$(openssl x509 -in ${VPN_PKI}/issued/${VPN_ID}.crt)"
VPN_EKU="$(echo "${VPN_CERT}" | openssl x509 -noout -purpose)"
case ${VPN_EKU} in
(*"SSL server : Yes"*)
VPN_CONF="${VPN_DIR}/${VPN_ID}.conf"
cat << EOF > ${VPN_CONF} ;;
user nobody
group nogroup
dev tun
port ${VPN_PORT}
proto ${VPN_PROTO}
server ${VPN_POOL}
topology subnet
client-to-client
keepalive 10 60
persist-tun
persist-key
push "dhcp-option DNS ${VPN_DNS}"
push "dhcp-option DOMAIN ${VPN_DN}"
push "redirect-gateway def1"
push "persist-tun"
push "persist-key"
<dh>
${VPN_DH}
</dh>
EOF
(*"SSL client : Yes"*)
VPN_CONF="${VPN_DIR}/${VPN_ID}.ovpn"
cat << EOF > ${VPN_CONF} ;;
user nobody
group nogroup
dev tun
nobind
client
remote ${VPN_SERV} ${VPN_PORT} ${VPN_PROTO}
auth-nocache
remote-cert-tls server
EOF
esac
cat << EOF >> ${VPN_CONF}
<tls-crypt-v2>
${VPN_TC}
</tls-crypt-v2>
<key>
${VPN_KEY}
</key>
<cert>
${VPN_CERT}
</cert>
<ca>
${VPN_CA}
</ca>
EOF
done
service openvpn restart
ls ${VPN_DIR}/*.ovpn
```

Basic openvpn server configuration is now complete.

1. Perform OpenWrt [backup](/docs/guide-user/troubleshooting/backup_restore "docs:guide-user:troubleshooting:backup_restore").
2. Either extract client profile from the archive file, or use SCP to retrieve the /etc/openvpn/client.ovpn file from the router.
3. Review/edit the IP address for the 'remote' line contained within the client.ovpn file.
4. Import the client.ovpn profile into your clients.

For an additional .ovpn after completing the above:

1. Run this [multi-client](/docs/guide-user/services/vpn/openvpn/extras#multi-client "docs:guide-user:services:vpn:openvpn:extras") script.
2. Now make a script consisting of the “Configuration parameters” of Part 1 above and all of Part 4 above and run it. Note that the “remote” line may be missing in the new ovpn (use the original as a reference for that).

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

## Notes

For beginners to OpenVPN server, this PDF guide may be helpful. It is based on above cli instructions with additional note and tips. [OpenVPN server setup guide for BT Home Hub 5A](https://www.dropbox.com/s/idjzqs3cyyb1zai/7-OpenVPN%20Server%20for%20HH5A.pdf?dl=0 "https://www.dropbox.com/s/idjzqs3cyyb1zai/7-OpenVPN%20Server%20for%20HH5A.pdf?dl=0")
