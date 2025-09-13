# WireGuard road-warrior automated

This article relies on the following:

- Accessing [web interface](/docs/guide-quick-start/walkthrough_login "docs:guide-quick-start:walkthrough_login") / [command-line interface](/docs/guide-quick-start/sshadministration "docs:guide-quick-start:sshadministration")
- Managing [configs](/docs/guide-user/base-system/uci "docs:guide-user:base-system:uci") / [packages](/docs/guide-user/additional-software/managing_packages "docs:guide-user:additional-software:managing_packages") / [services](/docs/guide-user/base-system/managing_services "docs:guide-user:base-system:managing_services") / [logs](/docs/guide-user/base-system/log.essentials "docs:guide-user:base-system:log.essentials")

## Introduction

The road-warrior scenario is described in [Strongswan's Road-warrior guide](/docs/guide-user/services/vpn/strongswan/roadwarrior "docs:guide-user:services:vpn:strongswan:roadwarrior"). This guide sets up a road-warrior-style service using WireGuard, with support for IPv4-only or IPv4/IPv6 dual tunnels, with two IPv6 configuration options.

#### IPv6 Configuration A: routable global addresses delegated to the peers

This configuration is good if:

- You have a stable IPv6 prefix delegation (prefix ⇐ /60) from your ISP, *or*
- You are willing to regenerate client configurations when your IPv6 delegation changes

*and*

- You want to use routable IPv6 addresses for your VPN clients

#### IPv6 Configuration B: only ULA addresses delegated to the peers, with NAT6

This configuration uses only [ULA addresses](https://en.wikipedia.org/wiki/Unique%20local%20address "https://en.wikipedia.org/wiki/Unique local address") for the VPN peers. This configuration is good if:

- Your IPv6 delegation is too small (prefix &gt; 60) or you don't have one (i.e. not enough subnets), *or*
- You have an IPv6 delegation (prefix &lt; = /60), but:
  
  - you are not sure your ISP will give you the same delegation long-term, *or*
  - You don't want to regenerate client configurations when your IPv6 delegation changes

It's also good if:

- Your prefix is fine but you want to use NAT6 addresses for VPN clients (and not assigning them any global IPv6 addresses)

## End Goals

When finished with this setup, you will have:

- Set up a WireGuard VPN server on OpenWrt
  
  - Typically accessed via a [DDNS](/docs/guide-user/base-system/ddns "docs:guide-user:base-system:ddns") hostname(s) managed for the peers' use
  - [NAT6](/docs/guide-user/network/ipv6/ipv6.nat6 "docs:guide-user:network:ipv6:ipv6.nat6") through your upstream IPv6 interface when routing IPv6 peer traffic from a ULA (configuration B, or configuration A if the peer only uses a ULA)
  - Routed public delegated IPv6 traffic when the peer is using a delegated address (configuration A)
  - IPv4 and IPv6 traffic is subject to normal firewall rules based on the zone assigned to the WireGuard interface

<!--THE END-->

- Created WireGuard peer configurations, and corresponding configuration files and QR codes for each peer

## Prerequisites

Before you start, you need:

- A hostname (or IP address) and port that can be used to connect to an IPv4 UDP service on your OpenWrt system, for transporting VPN traffic via the public IPv4 internet. If you don't have a public IP address, you will need to arrange a port forward from your upstream router (not tested).
- For IPv4, an available RFC1918 /24 subnet to dedicate to the WireGuard tunnel and its peers
- If configuring IPv6 tunnel support:
  
  - IPv6 configured &gt;&gt; [IPv6](/docs/guide-user/network/ipv6/configuration "docs:guide-user:network:ipv6:configuration")
  - A unique IPv6 assignment hint for the WireGuard interface. It must be no larger than 2 ^ (64 - prefix-length); this is used to compose the /64 subnet's prefix
  - *Required for configuration A*: A delegated routable prefix (no more than /60 bits as the prefix) from which you can dedicate a /64 subnet
  - Optionally, a hostname (or IPv6 address) and port that can be used to connect to an IPv6 UDP service on your OpenWrt system (for transporting VPN traffic via the public IPv6 internet)

### Install the prerequisite packages

```
opkg update
opkg install wireguard-tools qrencode
```

For OpenWrt 21.02 series, also add in:

```
opkg install kmod-ipt-nat6
```

Optional packages for post-configuration management through LuCI:

```
opkg install luci-proto-wireguard luci-app-wireguard
```

## Create WireGuard interface and its keys

- Download the script
- Edit the configuration values at the top (or write a wrapper script to set environment variables and call this script)
- Copy the script(s) to your OpenWrt system (such as with `scp`)

[wg\_roadwarrior.sh](/_export/code/docs/guide-user/services/vpn/wireguard/road-warrior?codeblock=3 "Download Snippet")

```
#!/bin/ash
#
# See more details at https://openwrt.org/docs/guide-user/services/vpn/wireguard/road-warrior
 
# The following configuration variables are required: set them before
# running this script, or edit this script to set them:
 
## The base name for the wireguard interface.
## this will have "wg_" prepended to it.
#export WG_INTERFACE="vpn"
 
## The WireGuard server port (UDP), this must be unused by other
## WireGuard interfaces or programs
#export WG_SERVER_PORT="51820"
 
## The (existing) firewall zone for the interface that will receive
## IPv4-ingress tunnel traffic
#export WG_WAN4_FWZONE="wan"
 
## The (existing) firewall zone name for the new WG interface
#export WG_FWZONE="lan"
 
##An IPv4 /24 subnet (without last octet) for the IPv4 tunnel
#export WG_IPV4_SUBNET="192.168.x"
 
## To use only IPv4 in the tunnel, leave the rest of these
## variables below commented out.
 
########## Optional IPv6 config below ##############
 
## The (existing) firewall zone for the interface that will receive
## IPv6-ingress tunnel traffic (May be identical to WG_WAN4_FWZONE)
#export WG_WAN6_FWZONE="wan"
 
## The prefix hint is used to compose a subnet from the /48 ULA prefix
## (obtained from the system config).  It will be composed like
## ${ULA_PREFIX}:${WG_IPV6_PREFIX_HINT}::/64
## Choose a prefix hint that is not used for any interfaces's ip6hint
## value.
#export WG_IPV6_PREFIX_HINT=4
 
## To use only ULA IPv6 addresses in the tunnel (no delegated
## addresses), omit WG_DELEGATED_PREFIX6.
 
## The prefix hint is also used to compose a subnet from the
## WG_DELEGATED_PREFIX6, but without a separating colon, so that if
## you have a prefix larger than 48, you can use hex digits to select
## the subnet.
 
## for a /48 prefix delegation, use a prefix up to 16 bits, so you get
## WG_delegated_interface6="nnnn:nnnn:nnnn:${WG_IPV6_PREFIX_HINT}"
#export WG_DELEGATED_PREFIX6="nnnn:nnnn:nnnn:"
 
## for a /56 prefix delegation, use a two-digit hex WG_IPV6_PREFIX_HINT,
## so you get WG_delegated_interface6="nnnn:nnnn:nn${WG_IPV6_PREFIX_HINT}"
#export WG_DELEGATED_PREFIX6="nnnn:nnnn:nn"
 
## for a /60 prefix delegation, use a one-digit hex WG_IPV6_PREFIX_HINT,
## so you get WG_delegated_interface6="nnnn:nnnn:nnn${WG_IPV6_PREFIX_HINT}"
#export WG_DELEGATED_PREFIX6="nnnn:nnnn:nnn"
 
clear
echo "======================================"
echo "|     Automated WireGuard Script     |"
echo "|     road-warrior server setup      |"
echo "======================================"
# Define Variables
echo -n "Defining variables... "
 
check_ev()
{
    evname=$1
    eval value="\$${evname}"
    if [ -z "$value" ]
    then
	echo $evname not set 1>&2
	exit 1
    fi
}
 
check_ev WG_INTERFACE
check_ev WG_IPV4_SUBNET
check_ev WG_SERVER_PORT
check_ev WG_FWZONE
check_ev WG_WAN4_FWZONE
 
find_fwzone()
{
    zone=$1
    varname=$2
 
    n=0
    while zname=$(uci -q get firewall.@zone[$n].name); do
	if [ "$zname" = "$zone" ]; then
	    eval $varname="@zone[$n]"
	    return
	fi
	n=$((n+1))
    done
 
    echo Unable to find firewall zone ${zone}. 1>&2
    exit 1
}
 
find_fwzone ${WG_FWZONE} WG_firewall_zone
find_fwzone ${WG_WAN4_FWZONE} scratch
 
if [ \
	-z "$WG_IPV6_PREFIX_HINT" -o \
	-z "$WG_WAN6_FWZONE" ]
then
    echo "IPv4 only mode"
    DUAL_TUNNEL=""
else
    find_fwzone ${WG_WAN6_FWZONE} scratch
 
    if [ -n "$WG_DELEGATED_PREFIX6" ]
    then
	export WG_delegated_interface6="${WG_DELEGATED_PREFIX6}${WG_IPV6_PREFIX_HINT}"
	echo "IPv6 ULA and delegated prefix mode"
	export WG_server_IP6_delegated="${WG_delegated_interface6}::1"
    else
	echo "IPv6 ULA only mode"
    fi
    echo "IPv4/IPv6 dual tunnel mode"
    DUAL_TUNNEL=yes
    ## TODO: future: determine upstream settings/prefixes/etc
    ## Look at https://openwrt.org/docs/guide-developer/jshn
    # case $(uci get network.wan6.proto) in
    # 	6in4)
    # 	# Use ifstatus wan with jshn
    # 	;;
    # 	dhcpv6)
    # 	# TODO: get this from ifstatus?
    # 	;;
    # esac
    if ! uci -q get network.globals.ula_prefix >/dev/null
    then
	echo "No ULA defined, unable to proceed." 1>&2
	exit 1
    fi
    ula=$(uci get network.globals.ula_prefix)
    ula=${ula%%::/*}
    export interface6_ula="${ula}:${WG_IPV6_PREFIX_HINT}"
    export WG_server_IP6_ula="${interface6_ula}::1"
fi
 
export WG_server_IP="${WG_IPV4_SUBNET}.1"
export WG_INTERFACE_NAME=wg_${WG_INTERFACE}
export WG_NAT6_name=nat6_${WG_INTERFACE_NAME}
echo "Done"
 
# Create directories
echo -n "Creating directories and pre-defining permissions on those directories... "
wg_directory=/etc/wireguard
mkdir -p ${wg_directory}/networks/${WG_INTERFACE}/peers
chmod 700 ${wg_directory}/networks/${WG_INTERFACE}
if ! fgrep -w -q ${wg_directory} /etc/sysupgrade.conf && \
   ! fgrep -w -q ${wg_directory}/ /etc/sysupgrade.conf
then
    echo ${wg_directory} >>/etc/sysupgrade.conf
fi
echo "Done"
 
# Remove pre-existing WireGuard interface
echo -n "Removing pre-existing WireGuard interface... "
uci -q del network.${WG_INTERFACE_NAME}
uci -q del_list firewall.${WG_firewall_zone}.network="${WG_INTERFACE_NAME}"
echo -n "Disabling pre-existing firewall script... "
uci -q delete firewall.${WG_NAT6_name}
echo "Done"
 
# Generate WireGuard server keys
echo -n "Generating WireGuard server keys for '${WG_INTERFACE}' network... "
wg genkey | tee "${wg_directory}/networks/${WG_INTERFACE}/${WG_INTERFACE}_server_private.key" | wg pubkey | tee "${wg_directory}/networks/${WG_INTERFACE}/${WG_INTERFACE}_server_public.key" >/dev/null 2>&1
echo "Done"
 
# Create WireGuard interface for 'LAN' network
echo -n "Creating WireGuard interface for '${WG_INTERFACE}' network... "
uci set network.${WG_INTERFACE_NAME}=interface
uci set network.${WG_INTERFACE_NAME}.proto='wireguard'
uci set network.${WG_INTERFACE_NAME}.private_key="$(cat ${wg_directory}/networks/${WG_INTERFACE}/${WG_INTERFACE}_server_private.key)"
uci set network.${WG_INTERFACE_NAME}.listen_port="${WG_SERVER_PORT}"
uci add_list network.${WG_INTERFACE_NAME}.addresses="${WG_server_IP}/24"
if [ -n "$DUAL_TUNNEL" ]
then
    uci add_list network.${WG_INTERFACE_NAME}.addresses="${WG_server_IP6_ula}/64"
    if [ -n "${WG_server_IP6_delegated}" ]
    then
	uci add_list network.${WG_INTERFACE_NAME}.addresses="${WG_server_IP6_delegated}/64"
    fi
fi
uci add_list firewall.${WG_firewall_zone}.network="${WG_INTERFACE_NAME}"
uci set network.${WG_INTERFACE_NAME}.mtu='1280'
echo "Done"
 
# Add firewall rule
echo -n "Adding firewall rules for '${WG_INTERFACE}' network... "
uci set firewall.wg_rule_${WG_INTERFACE}="rule"
uci set firewall.wg_rule_${WG_INTERFACE}.name="Allow-WireGuard-${WG_INTERFACE}-${WG_WAN4_FWZONE}"
uci set firewall.wg_rule_${WG_INTERFACE}.src="${WG_WAN4_FWZONE}"
uci set firewall.wg_rule_${WG_INTERFACE}.dest_port="${WG_SERVER_PORT}"
uci set firewall.wg_rule_${WG_INTERFACE}.proto="udp"
uci set firewall.wg_rule_${WG_INTERFACE}.target="ACCEPT"
 
if [ -n "$DUAL_TUNNEL" ]
then
    if [ "${WG_WAN6_FWZONE}" != "${WG_WAN4_FWZONE}" ]
    then
	uci set firewall.wg_rule6_${WG_INTERFACE}="rule"
	uci set firewall.wg_rule6_${WG_INTERFACE}.name="Allow-WireGuard-${WG_INTERFACE}-${WG_WAN6_FWZONE}"
	uci set firewall.wg_rule6_${WG_INTERFACE}.src="${WG_WAN6_FWZONE}"
	uci set firewall.wg_rule6_${WG_INTERFACE}.dest_port="${WG_SERVER_PORT}"
	uci set firewall.wg_rule6_${WG_INTERFACE}.proto="udp"
	uci set firewall.wg_rule6_${WG_INTERFACE}.target="ACCEPT"
    fi
 
    if [ -d /etc/nftables.d ]; then
	# Create NAT6 firewall chain for ULA egress
	fwscript=/etc/nftables.d/${WG_NAT6_name}.nft
	cat >${fwscript} <<EOF
# Created by ${0##*/}
chain srcnat_ula6_${WG_INTERFACE} {
  type nat hook postrouting priority srcnat; policy accept;
  oifname "\$${WG_WAN6_FWZONE}_devices" ip6 saddr ${interface6_ula}::/64 counter masquerade comment "!fw4: ULA masquerade6"
}
EOF
    else
	# Create NAT6 firewall addition script for ULA
	fwscript=/etc/firewall.${WG_NAT6_name}.sh
	cat >$fwscript <<EOF
#!/bin/sh
# Created by ${0##*/}
MY_NETWORK=${WG_INTERFACE_NAME}
NET_PFX6="${interface6_ula}::/64"
. /lib/functions/network.sh
network_flush_cache
network_find_wan6 NET_IF6
network_get_device NET_DEV6 "\${NET_IF6}"
if [ -n "\${NET_DEV6}" ];
then
  logger -t firewall.${WG_NAT6_name} -p info -- adding NAT/MASQUERADE for source net "\${NET_PFX6}" through "\${NET_DEV6}"
  ip6tables -t nat -A POSTROUTING -s "\${NET_PFX6}" -o "\${NET_DEV6}" -j MASQUERADE
fi
 
exit 0
EOF
	chmod 555 $fwscript
 
	uci set firewall.${WG_NAT6_name}="include"
	uci set firewall.${WG_NAT6_name}.path="${fwscript}"
	uci set firewall.${WG_NAT6_name}.reload='1'
    fi
    if ! fgrep -w -q ${fwscript} /etc/sysupgrade.conf; then
	echo ${fwscript} >>/etc/sysupgrade.conf
    fi
 
fi
echo "Done"
 
# Remove existing peers
echo -n "Removing pre-existing peers... "
while uci -q delete network.@wireguard_${WG_INTERFACE_NAME}[0]; do :; done
rm -R ${wg_directory}/networks/${WG_INTERFACE}/peers/* >/dev/null 2>&1
echo "Done"
 
# Commit UCI changes
echo -en "\nCommiting changes... "
uci commit
echo "Done"
 
# Restart WireGuard interface
echo -en "\nRestarting WireGuard interface... "
ifup ${WG_INTERFACE_NAME}
echo "Done"
 
# Restart firewall
echo -en "\nRestarting firewall... "
service firewall restart >/dev/null 2>&1
echo "Done"
```

- Run the script

```
sh ./wg_roadwarrior.sh
```

This creates the WireGuard interface and its server keys. It also sets up a firewall rule to NAT6 outbound traffic from the VPN's /64 subnet of the IPv6 ULA prefix. If it detects fw4 installation (presence of `/etc/nftables.d`) it creates a new nftable chain with a NAT6 rule, otherwise it creates a fw3 include rule and puts the NAT6 rule into that file.

## Create WireGuard peer configurations

- Download the script
- Edit the configuration values at the top (or write a wrapper script to set environment variables and call this script)
- Copy the script(s) to your OpenWrt system (such as with `scp`)

[add\_roadwarrior\_peer.sh](/_export/code/docs/guide-user/services/vpn/wireguard/road-warrior?codeblock=5 "Download Snippet")

```
#!/bin/ash
 
# See more details at https://openwrt.org/docs/guide-user/services/vpn/wireguard/road-warrior
 
# These variables are required: set them before running this script,
# or edit this script to set them:
 
## Match this to the value used for WG_INTERFACE in wg_roadwarrior.sh
#export WG_INTERFACE="vpn"
 
## Set the hostname or address for the WG server for IPv4 tunnel
## ingress
#WG_DDNS="yourserver.dyndns.org"
 
## Set this to "0" to use a delegated non-ULA subnet from the WG
## interface.  Set this to "1" to skip using a delegated prefix.  If
## you created the WG server with a delegated prefix, this can be the
## client's choice to use either ONLY_ULA=0 or ONLY_ULA=1, but if you
## created the WG server with only a ULA subnet, then this must be
## ONLY_ULA=1.
#ONLY_ULA="0"
 
## Optional: set the hostname or address for the WG server for IPv6
## tunnel ingress
#WG_DDNS6="yourserver-ipv6.dyndns.org"
 
## for debugging, change these to start with 'echo '
UCI=uci
TRIAL=
 
if [ -z "$1" ]; then
    echo too few arguments: usage $0 peer_name 1>&2
    exit 1
fi
export username="$1"
 
clear
echo "========================================================="
echo "|               Automated WireGuard Script              |"
echo "|                 Add road-warrior peer                 |"
echo "========================================================="
# Define Variables
if [ -z "${WG_INTERFACE}" ]
then
    echo WG_INTERFACE not set 1>&2
    exit 1
fi
if [ -z "${WG_DDNS}" ]
then
    echo WG_DDNS not set 1>&2
    exit 1
fi
export WG_INTERFACE_NAME=wg_${WG_INTERFACE}
export WG_server_port="$(uci get network.${WG_INTERFACE_NAME}.listen_port)"
ula=$(uci get network.globals.ula_prefix |sed -e 's,::/.*,,')
ticker=1
DUAL_TUNNEL=""
for network in $(uci -q get network.${WG_INTERFACE_NAME}.addresses)
do
    case $network in
	*.*.*.*/*)
	    ipv4addr=${network%%/*}
	    export interface=$(echo ${ipv4addr} | cut -d . -f 1,2,3)
	    export WG_server_IP="${interface}.1"
	    ;;
 
	*:*/*)
	    if [ -z "${ONLY_ULA}" ]
	    then
		echo ONLY_ULA not set 1>&2
		exit 1
	    fi
	    ipv6prefix=${network%%::1/*}
	    ipv6addr=${network%%/*}
	    ulamatch1=${network##fd*}
	    ulamatch2=${network##fc*}
	    if [ "${ONLY_ULA}" = 0 -o -z "${ulamatch1}" -o -z "${ulamatch2}" ]; then
		export WG_server_IP6_${ticker}=${ipv6addr}
		export interface6_${ticker}="${ipv6prefix}"
		ticker=$((ticker+1))
	    fi
	    if [ -z "${ulamatch1}" -o -z "${ulamatch2}" ]; then
		export dns6_ula=${ipv6addr}
		export interface6_ula=${ipv6prefix}
	    fi
	    DUAL_TUNNEL="yes"
	    ;;
    esac
    shift
done
 
if [ -n "$DUAL_TUNNEL" ]
then
    echo IPv4/IPv6 dual tunnel
else
    echo IPv4 only tunnel
fi
if [ -z "$WG_DDNS6" ]
then
    echo only providing tunnel ingress via IPv4
else
    echo including tunnel ingress via IPv6
fi
 
echo -n "Checking variables... "
if [ -z "${WG_INTERFACE}" -o \
	-z "${interface}" -o \
	-z "${WG_DDNS}" -o \
	-z "${WG_server_port}" -o \
	-z "${WG_server_IP}" ]
then
    echo Insufficient configurations found in existing network "${WG_INTERFACE}" 1>&2
    exit 1
fi
 
function last_peer_ID () {
	cd "/etc/wireguard/networks/${WG_INTERFACE}/peers"
	ls | sort -V | tail -1 | cut -d '_' -f 1
}
 
peer_ID=$(last_peer_ID)
if [ -z "$peer_ID" ]; then
    export peer_ID=1
else
    export peer_ID=$((peer_ID+1))
fi
echo using new peer ID ${peer_ID} for ${username}
export peer_IP=$((peer_ID+1))
echo "Done"
 
if [ -n "$DUAL_TUNNEL" ]
then
    if [ -z "${interface6_1}" -o \
	-z "${dns6_ula}" -o \
	-z "${interface6_ula}" -o \
	-z "${WG_server_IP6_1}" ]
    then
	echo Insufficient EVs or configurations found for IPv6 dual tunnel 1>&2
	exit 1
    fi
    allowed_ips6="${interface6_1}::${interface}.${peer_IP}/128"
    allowed_ips6_ula="${interface6_ula}::${interface}.${peer_IP}/128"
else
    allowed_ips6=""
fi
 
create_peer_config()
{
    CONFNAME="$1"
    ENDPOINT="$2"
    DNS="$3"
    PEERIPS="$4"
    SERVERIPS="$5"
    # Create peer configuration
    echo -n "Creating config for '${peer_ID}_${WG_INTERFACE}_${username} (${ENDPOINT})'... "
    confdir="/etc/wireguard/networks/${WG_INTERFACE}/peers/${peer_ID}_${WG_INTERFACE}_${username}"
    conffile="${peer_ID}_${WG_INTERFACE}_${username}.${CONFNAME}"
    cat <<-EOF > "${confdir}/${conffile}.conf"
[Interface]
# Name = ${username}-${CONFNAME}
Address = ${PEERIPS}
PrivateKey = $(cat /etc/wireguard/networks/${WG_INTERFACE}/peers/${peer_ID}_${WG_INTERFACE}_${username}/${peer_ID}_${WG_INTERFACE}_${username}_private.key) # Peer's private key
DNS = ${DNS}
 
[Peer]
PublicKey = $(cat /etc/wireguard/networks/${WG_INTERFACE}/${WG_INTERFACE}_server_public.key) # Server's public key
PresharedKey = $(cat /etc/wireguard/networks/${WG_INTERFACE}/peers/${peer_ID}_${WG_INTERFACE}_${username}/${peer_ID}_${WG_INTERFACE}_${username}.psk) # Peer's pre-shared key
PersistentKeepalive = 25
AllowedIPs = ${SERVERIPS}
Endpoint = ${ENDPOINT}:${WG_server_port}
EOF
    qrencode -t svg -o "${confdir}/${conffile}.svg" -r "${confdir}/${conffile}.conf"
    echo "Done"
}
 
# Configure Variables
echo ""
echo -n "Defining variables for '${peer_ID}_${WG_INTERFACE}_${username}'... "
 
# Gather allowed IP addresses: one for provided IPv4 tunnel endpoint
# plus one for each allowed IPv6 address
allowed_ips4="${interface}.${peer_IP}/32"
allowed_ips6_list="${allowed_ips6}"
n=2;
eval "nextinterface=\${interface6_${n}}"
while [ -n "${nextinterface}" ]; do
    echo adding "${nextinterface}"
    ip6="${nextinterface}::${interface}.${peer_IP}/128"
    allowed_ips6="${allowed_ips6},${ip6}"
    allowed_ips6_list="${allowed_ips6_list} ${ip6}"
    n=$((n+1))
    eval "nextinterface=\${interface6_${n}}"
done
allowed_ips="${allowed_ips4},${allowed_ips6}"
allowed_ips_ula="${allowed_ips4},${allowed_ips6_ula}"
 
# Create directory for storing peers
echo -n "Creating directory for peer '${peer_ID}_${WG_INTERFACE}_${username}'... "
mkdir -p "/etc/wireguard/networks/${WG_INTERFACE}/peers/${peer_ID}_${WG_INTERFACE}_${username}"
echo "Done"
 
# Generate peer keys
echo -n "Generating peer keys for '${peer_ID}_${WG_INTERFACE}_${username}'... "
wg genkey | tee "/etc/wireguard/networks/${WG_INTERFACE}/peers/${peer_ID}_${WG_INTERFACE}_${username}/${peer_ID}_${WG_INTERFACE}_${username}_private.key" | wg pubkey | tee "/etc/wireguard/networks/${WG_INTERFACE}/peers/${peer_ID}_${WG_INTERFACE}_${username}/${peer_ID}_${WG_INTERFACE}_${username}_public.key" >/dev/null 2>&1
echo "Done"
 
# Generate Pre-shared key
echo -n "Generating peer PSK for '${peer_ID}_${WG_INTERFACE}_${username}'... "
wg genpsk | tee "/etc/wireguard/networks/${WG_INTERFACE}/peers/${peer_ID}_${WG_INTERFACE}_${username}/${peer_ID}_${WG_INTERFACE}_${username}.psk" >/dev/null 2>&1
echo "Done"
 
# Add peer to server
echo -n "Adding '${peer_ID}_${WG_INTERFACE}_${username}' to WireGuard server... "
${UCI} add network wireguard_${WG_INTERFACE_NAME} >/dev/null 2>&1
${UCI} set network.@wireguard_${WG_INTERFACE_NAME}[-1].public_key="$(cat /etc/wireguard/networks/${WG_INTERFACE}/peers/${peer_ID}_${WG_INTERFACE}_${username}/${peer_ID}_${WG_INTERFACE}_${username}_public.key)"
${UCI} set network.@wireguard_${WG_INTERFACE_NAME}[-1].preshared_key="$(cat /etc/wireguard/networks/${WG_INTERFACE}/peers/${peer_ID}_${WG_INTERFACE}_${username}/${peer_ID}_${WG_INTERFACE}_${username}.psk)"
${UCI} set network.@wireguard_${WG_INTERFACE_NAME}[-1].description="${username}"
${UCI} add_list network.@wireguard_${WG_INTERFACE_NAME}[-1].allowed_ips="${allowed_ips4}"
for ip6 in ${allowed_ips6_list}
do
    ${UCI} add_list network.@wireguard_${WG_INTERFACE_NAME}[-1].allowed_ips="${ip6}"
done
${UCI} set network.@wireguard_${WG_INTERFACE_NAME}[-1].route_allowed_ips='1'
${UCI} set network.@wireguard_${WG_INTERFACE_NAME}[-1].persistent_keepalive='25'
echo "Done"
 
if [ -n "$DUAL_TUNNEL" ]
then
   # IPv4 tunnel endpoint, dual stack tunnel
   create_peer_config "${WG_DDNS}-dual" "${WG_DDNS}" "${WG_server_IP},${dns6_ula}" "${allowed_ips}" "0.0.0.0/0,::/0"
 
   # IPv4 tunnel endpoint, dual stack (ULA only) tunnel
   create_peer_config "${WG_DDNS}-dual-ula" "${WG_DDNS}" "${WG_server_IP},${dns6_ula}" "${allowed_ips_ula}" "0.0.0.0/0,::/0"
 
   # IPv4 tunnel endpoint, IPv6 tunnel
   create_peer_config "${WG_DDNS}-ipv6" "${WG_DDNS}" "${dns6_ula}" "${allowed_ips6}" "::/0"
 
   # IPv4 tunnel endpoint, IPv6 ULA tunnel
   create_peer_config "${WG_DDNS}-ipv6-ula" "${WG_DDNS}" "${dns6_ula}" "${allowed_ips6_ula}" "::/0"
fi
 
# IPv4 tunnel endpoint, IPv4 only tunnel
create_peer_config "${WG_DDNS}-ipv4" "${WG_DDNS}" "${WG_server_IP}" "${allowed_ips4}" "0.0.0.0/0"
 
if [ -n "$DUAL_TUNNEL" -a -n "$WG_DDNS6" ]
then
    # IPv6 tunnel endpoint, dual stack tunnel
    create_peer_config "${WG_DDNS6}-dual-via6" "${WG_DDNS6}" "${WG_server_IP},${dns6_ula}" "${allowed_ips}" "0.0.0.0/0,::/0"
 
    # IPv6 tunnel endpoint, dual stack (ULA only) tunnel
    create_peer_config "${WG_DDNS6}-dual-ula-via6" "${WG_DDNS6}" "${WG_server_IP},${dns6_ula}" "${allowed_ips_ula}" "0.0.0.0/0,::/0"
fi
 
# Commit UCI changes
echo -en "\nCommiting changes... "
${UCI} commit
echo "Done"
 
# Restart WireGuard interface
echo -en "\nRestarting WireGuard interface... "
${TRIAL} ifup ${WG_INTERFACE_NAME}
echo "Done"
 
# Restart firewall
echo -en "\nRestarting firewall... "
${TRIAL} service firewall restart 2>/dev/null
echo "Done"
```

- Run it once for each peer:

```
sh ./add_roadwarrior_peer.sh <peername>
```

This configures the peers on the interface previously created, and generates configuration files and QR codes for those peers.

After you have run this for all your expected peers, copy `/etc/wireguard/networks/${WG_INTERFACE}/peers` off of the OpenWrt system (such as with `scp`) to a place where you can distribute the configuration files or display the QR codes for your WireGuard peers to use.

*Note:* the wireguard server keys and each client's keys are stored in `/etc/wireguard/networks/${WG_INTERFACE}`. To keep your VPN secure, these keys must be protected from disclosure.

You can add more peers later with the same script.

The script generates several variants of configuration files for each client. They are merely client-side variations on the peer configuration. Since they share the same server-side peer definition, only one of these configurations (per client) can be actively connected to the server at a time.

- `nnn-ipv4.conf` and `nnn-ipv4.svg`: tunnel running via IPv4 ingress to WireGuard service; tunnels only IPv4 traffic

<!--THE END-->

- `nnn-dual.conf` and `nnn-dual.svg`: tunnel running via IPv4 ingress to WireGuard service; tunnels IPv4 and IPv6 traffic, with client using IPv6 addresses from ULA and global prefixes
  
  - only created if you configured IPv6 when creating the WireGuard interface with `wg_roadwarrior.sh`

<!--THE END-->

- `nnn-dual-ula.conf` and `nnn-dual-ula.svg`: tunnel running via IPv4 ingress to WireGuard service; tunnels IPv4 and IPv6 traffic, with client using IPv6 address from ULA prefix only
  
  - only created if you configured IPv6 when creating the WireGuard interface with `wg_roadwarrior.sh`

<!--THE END-->

- `nnn-ipv6.conf` and `nnn-ipv6.svg`: tunnel running via IPv4 ingress to WireGuard service; tunnels only IPv6 traffic, with client using IPv6 addresses from ULA and global prefixes
  
  - only created if you configured IPv6 when creating the WireGuard interface with `wg_roadwarrior.sh`

<!--THE END-->

- `nnn-ipv6-ula.conf` and `nnn-ipv6-ula.svg`: tunnel running via IPv4 ingress to WireGuard service; tunnels only IPv6 traffic, with client using IPv6 address from ULA prefix only
  
  - only created if you configured IPv6 when creating the WireGuard interface with `wg_roadwarrior.sh`

<!--THE END-->

- `nnn-dual-via6.conf` and `nnn-dual-via6.svg`: tunnel running via IPv6 ingress to WireGuard service; tunnels IPv4 and IPv6 traffic, with client using IPv6 addresses from ULA and global prefixes
  
  - only created if you set WG\_DDNS6 when running `add_roadwarrior_peer.sh` and you configured IPv6 when creating the WireGuard interface with `wg_roadwarrior.sh`

<!--THE END-->

- `nnn-dual-ula-via6.conf` and `nnn-dual-ula-via6.svg`: tunnel running via IPv6 ingress to WireGuard service; tunnels IPv4 and IPv6 traffic, with client using IPv6 address from ULA prefix only
  
  - only created if you set WG\_DDNS6 when running `add_roadwarrior_peer.sh` and you configured IPv6 when creating the WireGuard interface with `wg_roadwarrior.sh`

The WireGuard IPv6 peer configurations assign both a ULA-prefixed and a delegated routable IPv6 address unless you set `ONLY_ULA=1` when running `add_roadwarrior_peer.sh`, in which case they have only a ULA-prefixed IPv6 address.

## Enable ULA routing

ULA prefixes normally won't have packets sent out to the IPv6 internet. Because the NAT is applied after the routing is determined, you need to enable the routing of ULA to the IPv6 internet. Since the firewall has been configured with NAT6 for ULA source addresses, it's safe to enable routing for ULA sources.

- Download the following ULA routing script.

[enable-ula.sh](/_export/code/docs/guide-user/services/vpn/wireguard/road-warrior?codeblock=7 "Download Snippet")

```
#!/bin/sh
wan6proto=$(uci get network.wan6.proto)
if [ "${wan6proto}" = '6in4' ]; then
   uci add_list network.wan6.ip6prefix=$(uci get network.globals.ula_prefix)
elif [ "${wan6proto}" = 'dhcpv6' ]; then
   uci set network.wan6.sourcefilter="0"
fi
uci commit
ifup wan6
```

- Run the script

```
sh enable-ula.sh
```

## Testing

Configure the WireGuard client on a peer using one of the QR codes or configuration files. Connect the VPN tunnel. Visit [https://ipquail.com](https://ipquail.com "https://ipquail.com") in a browser on the client to confirm the IP addresses used are those from the VPN tunnel configuration.

## Credit

The scripts here are modeled on those from [Automated WireGuard Server and Multi-client](/docs/guide-user/services/vpn/wireguard/automated "docs:guide-user:services:vpn:wireguard:automated").
