# WireGuard site-to-site automated

### Introduction

This guide provides an automated script that creates scripts to configure a site-to-site WireGuard VPN between two OpenWrt systems. The script generates two scripts, one for each site. Once the scripts are generated, you copy them to the two OpenWrt systems and run them to configure the WireGuard VPN.

Once you have run the setup scripts, you must delete them to protect the private keys they contain. The scripts write the private keys into the standard network configuration files, which are already protected.

The top of the script contains a section of settings that you need to customize for your system hostnames and IP address ranges. It supports a single IPv4 range and a single IPv6 range. The IPv4 uses an example RFC1918 address range for each site, which you should customize. The IPv6 range is set to the ULA for each site (which you will provide), but you can use a different IPv6 range if desired.

The scripts have been tested with OpenWrt 23.05.

## 1. Prerequisites

1. Set up a Dynamic DNS client &gt;&gt; [DDNS client](/docs/guide-user/services/ddns/client "docs:guide-user:services:ddns:client")
2. Install Wireguard &gt;&gt; [Installing packages](/docs/guide-user/services/vpn/wireguard/basics#installing_packages "docs:guide-user:services:vpn:wireguard:basics")
3. IPv6 configured &gt;&gt; [IPv6](/docs/guide-user/network/ipv6/configuration "docs:guide-user:network:ipv6:configuration")

## 2. Script

Copy the script below to one of the OpenWrt systems, customize the script settings in `/root/s2s_combined.sh` in the top section to match your desired configuration, and then run the script with

```
sh /root/s2s_combined.sh
```

If you set the `WG_TRIAL` variable to a non-empty value, the generated scripts will echo the commands they *would* use instead of actually configuring the VPN.

After running the script, copy the generated scripts to the indicated hosts and run them. Delete them afterwards to protect your keys.

[s2s\_combined.sh](/_export/code/docs/guide-user/services/vpn/wireguard/site-to-site?codeblock=1 "Download Snippet")

```
#!/bin/sh
#
# s2s_combined.sh: create configuration scripts that set up a
# site-to-site VPN between two OpenWrt hosts using wireguard.
# The site configurations are symmetric, each is a server with the
# other as a peer.
#
# This script generates two script files, one for each site.  The
# generated files contain matched pre-shared keys and private/public key
# values for the two sites.
#
# Run this script on one of the routers (site A for example), then
# copy the generated script for the other site to the other router.
# Run the appropriate script on each router: '/tmp/site-<hostname>.sh'
#
# After running the generated scripts, DELETE the scripts, so that
# nobody copies them and steals the keys.  The keys are stored in the
# network configuration files, which you are already protecting since
# they have other confidential information such as wifi passwords, TLS
# server keys, etc.
#
# The generated scripts configure a wireguard tunnel that carries IPv4
# and IPv6 through the tunnel.  It routes the other site's IPv6 ULA
# range through the tunnel, plus one IPv4 range.  You can add more
# routed networks later through LuCI or uci.
#
 
clear
echo "======================================"
echo "|     Automated WireGuard Script     |"
echo "|          Site-to-Site VPN          |"
echo "|          Script generator          |"
echo "======================================"
echo -n "Defining variables... "
# Set the following values as needed to configure the generated scripts:
#
# Make this non-empty if you want to create scripts that only show
# the configuration and don't actually set it.
WG_TRIAL=""
# The hostnames of the two OpenWrt routers.  Use a dynamic DNS service
# if needed so that your routers can find each other.
WG_SITE_A_HOSTNAME="siteA.dynamic-dns.net"
WG_SITE_B_HOSTNAME="siteB.dynamic-dns.net"
# The description
WG_SITE_A_DESCRIPTION="Site A, ${WG_SITE_A_HOSTNAME}"
WG_SITE_B_DESCRIPTION="Site B, ${WG_SITE_B_HOSTNAME}"
# The interface names at each site
WG_SITE_A_IF="wg_s2s_a"
WG_SITE_B_IF="wg_s2s_b"
WG_PORT="51820"
# The IPv4 range at each site.
# Site A will route traffic to WG_SITE_B_LAN_RANGE through the tunnel
# and vice-versa for site B
WG_SITE_A_LAN_RANGE="192.168.0.0/24"
WG_SITE_B_LAN_RANGE="192.168.1.0/24"
# The IPv6 ULA prefixes for each host.  The tunnel will be configured
# to route to the peer's ULA addresses. Get this with
# "uci get network.globals.ula_prefix |sed -e 's,::/.*,,'"
WG_SITE_A_ULA_PREFIX="fdff:ffff:ffff"
WG_SITE_B_ULA_PREFIX="fdee:eeee:eeee"
# Route the IPv6 ULA prefix for the remote site through the tunnel
WG_SITE_A_LAN_RANGE6="${WG_SITE_A_ULA_PREFIX}::/48"
WG_SITE_B_LAN_RANGE6="${WG_SITE_B_ULA_PREFIX}::/48"
# The firewall zone names at each site (the VPN tunnel endpoints are placed
# in these zones).  The zones must already exist before you run
# the generated scripts.
WG_SITE_A_VPN_ZONE=vpn
WG_SITE_B_VPN_ZONE=vpn
# The firewall WAN zone names at each site, used to configure WAN
# firewall ingress rules to accept wireguard traffic on the chosen port
WG_SITE_A_WAN_ZONE=wan
WG_SITE_B_WAN_ZONE=wan
# You probably don't need to change these unless you don't like these
# internal names
WG_SITE_A_CONFIG_NAME=s2s_vpn_site_a
WG_SITE_B_CONFIG_NAME=s2s_vpn_site_b
WG_FW_RULE_ID="wg_s2s_${WG_PORT}"
echo "Done"
 
if [ ! -z "${WG_TRIAL}" ]; then
    ECHO="echo echo"
else
    ECHO="echo"
fi
 
cleanup() {
    echo -n "Removing temporary key files... "
    rm -f /tmp/wg_site_a.key /tmp/wg_site_a.pub
    rm -f /tmp/wg_site_b.key /tmp/wg_site_b.pub
    rm -f /tmp/wg_site_a_and_b.psk
    echo "Done"
}
 
trap cleanup EXIT
 
cd /tmp
# Generate keys
umask go=
echo -n "Generating WireGuard keys for sites A and B... "
wg genkey | tee wg_site_a.key | wg pubkey > wg_site_a.pub
wg genkey | tee wg_site_b.key | wg pubkey > wg_site_b.pub
wg genpsk > wg_site_a_and_b.psk
 
# Site_A keys
WG_SITE_A_KEY="$(cat wg_site_a.key)"
WG_SITE_A_PUB="$(cat wg_site_a.pub)"
 
# Site_B keys
WG_SITE_B_KEY="$(cat wg_site_b.key)"
WG_SITE_B_PUB="$(cat wg_site_b.pub)"
 
# Pre-shared key known by both
WG_PSK="$(cat wg_site_a_and_b.psk)"
 
echo "Done"
 
create_site_config()
{
    LOCAL_DESCRIPTION="${1}"
    LOCAL_VPN_ZONE="${2}"
    LOCAL_IF="${3}"
    LOCAL_WAN_ZONE="${4}"
    LOCAL_KEY="${5}"
    LOCAL_HOSTNAME="${6}"
    REMOTE_CONF="${7}"
    REMOTE_PUB="${8}"
    REMOTE_PSK="${9}"
    REMOTE_LAN_RANGE="${10}"
    REMOTE_LAN_RANGE6="${11}"
    REMOTE_HOSTNAME="${12}"
    REMOTE_DESCRIPTION="${13}"
 
    if [ -z "$REMOTE_DESCRIPTION" ]; then
        echo not enough args to subroutine 1>&2
        exit 1
    fi
    echo "#!/bin/sh"
    echo "clear"
    echo "echo ======================================"
    echo "echo \"|     Automated WireGuard Script     |\""
    echo "echo \"|          Site-to-Site VPN          |\""
    echo "echo \"|           Configuration            |\""
    echo "echo ======================================"
    echo "echo Generated to configure \"${LOCAL_HOSTNAME}\" to tunnel with \"${REMOTE_HOSTNAME}\""
 
    echo "echo -n Creating firewall rule for WAN ingress..."
    # find the zone in the firewall.  There doesn't seem to be a way
    # to ask uci to show the zone with name=X, so we have
    # to search for it
    echo "i=0"
    echo "zone="
    echo 'while uci -q get firewall.@zone[$i].name >/dev/null; do'
    echo '    if [ "$(uci -q get firewall.@zone[$i].name)" = "'${LOCAL_VPN_ZONE}'" ]; then'
    echo '        zone=$i'
    echo '        break'
    echo '    fi'
    echo '    i=$((i + 1))'
    echo 'done'
    echo 'if [ -z "$zone" ]; then'
    echo '    echo firewall zone '${LOCAL_VPN_ZONE}' not found'
    echo '    exit 1'
    echo 'fi'
 
    ${ECHO} uci del_list firewall.@zone['$zone'].network=\"${LOCAL_IF}\"
    ${ECHO} uci add_list firewall.@zone['$zone'].network=\"${LOCAL_IF}\"
    ${ECHO} uci -q delete firewall.${WG_FW_RULE_ID}
    ${ECHO} uci set firewall.${WG_FW_RULE_ID}=\"rule\"
    ${ECHO} uci set firewall.${WG_FW_RULE_ID}.name=\"Allow-WireGuard-${WG_PORT}\"
    ${ECHO} uci set firewall.${WG_FW_RULE_ID}.src=\"${LOCAL_WAN_ZONE}\"
    ${ECHO} uci set firewall.${WG_FW_RULE_ID}.dest_port=\"${WG_PORT}\"
    ${ECHO} uci set firewall.${WG_FW_RULE_ID}.proto=\"udp\"
    ${ECHO} uci set firewall.${WG_FW_RULE_ID}.target=\"ACCEPT\"
    ${ECHO} uci commit firewall
    ${ECHO} service firewall restart
    echo "echo Done"
 
    # Configure network, $LOCAL_DESCRIPTION tunnel endpoint
    echo "echo -n Configure wireguard interface \"${LOCAL_IF}\"..."
    ${ECHO} uci -q delete network.${LOCAL_IF}
    ${ECHO} uci set network.${LOCAL_IF}=\"interface\"
    ${ECHO} uci set network.${LOCAL_IF}.proto=\"wireguard\"
    ${ECHO} uci set network.${LOCAL_IF}.private_key=\"${LOCAL_KEY}\"
    ${ECHO} uci set network.${LOCAL_IF}.listen_port=\"${WG_PORT}\"
    echo "echo Done"
 
    # Add local site's ideas about remote site
    echo "echo -n Configure peer \"${REMOTE_DESCRIPTION}\"..."
    ${ECHO} uci -q delete network.${REMOTE_CONF}
    ${ECHO} uci set network.${REMOTE_CONF}=\"wireguard_${LOCAL_IF}\"
    ${ECHO} uci set network.${REMOTE_CONF}.public_key=\"${REMOTE_PUB}\"
    ${ECHO} uci set network.${REMOTE_CONF}.preshared_key=\"${REMOTE_PSK}\"
    ${ECHO} uci set network.${REMOTE_CONF}.description=\""${REMOTE_DESCRIPTION}"\"
    ${ECHO} uci add_list network.${REMOTE_CONF}.allowed_ips=\"${REMOTE_LAN_RANGE}\"
    ${ECHO} uci add_list network.${REMOTE_CONF}.allowed_ips=\"${REMOTE_LAN_RANGE6}\"
    ${ECHO} uci set network.${REMOTE_CONF}.route_allowed_ips=\'1\'
    ${ECHO} uci set network.${REMOTE_CONF}.persistent_keepalive=\'25\'
    ${ECHO} uci set network.${REMOTE_CONF}.endpoint_host=\"${REMOTE_HOSTNAME}\"
    ${ECHO} uci set network.${REMOTE_CONF}.endpoint_port=\"${WG_PORT}\"
    ${ECHO} uci commit network
    ${ECHO} service network restart
    echo "echo Done"
    echo "echo ======================================"
    echo "echo \"|             Next steps             |\""
    echo "echo ======================================"
    echo "echo Remove this script: \"\$0\""
    echo "echo It contains copies of your secret keys that"
    echo "echo you do not need anymore, because they are now in the network"
    echo "echo configuration files.  Delete the script to avoid key theft."
}
 
echo -n "Creating configuration script for \"${WG_SITE_A_DESCRIPTION}\" ... "
create_site_config \
    "${WG_SITE_A_DESCRIPTION}" \
    "${WG_SITE_A_VPN_ZONE}" \
    "${WG_SITE_A_IF}" \
    "${WG_SITE_A_WAN_ZONE}" \
    "${WG_SITE_A_KEY}"\
    "${WG_SITE_A_HOSTNAME}"\
    "${WG_SITE_B_CONFIG_NAME}" \
    "${WG_SITE_B_PUB}" \
    "${WG_PSK}" \
    "${WG_SITE_B_LAN_RANGE}" \
    "${WG_SITE_B_LAN_RANGE6}" \
    "${WG_SITE_B_HOSTNAME}" \
    "${WG_SITE_B_DESCRIPTION}" >site-${WG_SITE_A_HOSTNAME}.sh
chmod u+x site-${WG_SITE_A_HOSTNAME}.sh
echo "Done"
 
echo -n "Creating configuration script for \"${WG_SITE_B_DESCRIPTION}\" ... "
create_site_config \
    "${WG_SITE_B_DESCRIPTION}" \
    "${WG_SITE_B_VPN_ZONE}" \
    "${WG_SITE_B_IF}" \
    "${WG_SITE_B_WAN_ZONE}" \
    "${WG_SITE_B_KEY}"\
    "${WG_SITE_B_HOSTNAME}"\
    "${WG_SITE_A_CONFIG_NAME}" \
    "${WG_SITE_A_PUB}" \
    "${WG_PSK}" \
    "${WG_SITE_A_LAN_RANGE}" \
    "${WG_SITE_A_LAN_RANGE6}" \
    "${WG_SITE_A_HOSTNAME}" \
    "${WG_SITE_A_DESCRIPTION}" >site-${WG_SITE_B_HOSTNAME}.sh
chmod u+x site-${WG_SITE_B_HOSTNAME}.sh
echo "Done"
 
echo "======================================"
echo "|             Next steps             |"
echo "======================================"
echo "1. Copy /tmp/site-${WG_SITE_A_HOSTNAME}.sh to ${WG_SITE_A_HOSTNAME} and run it there,"
echo "  then delete all copies of it to protect your keys."
echo "2. Copy /tmp/site-${WG_SITE_B_HOSTNAME}.sh to ${WG_SITE_B_HOSTNAME} and run it there,"
echo "  then delete all copies of it to protect your keys."
echo "======================================"
if [ ! -z "${WG_TRIAL}" ]; then
    echo "========================================="
    echo "| Trial mode, scripts are nonfunctional |"
    echo "========================================="
fi
exit 0
```

## 3. Testing

The VPN connection auto-establishes when the network is started on each system.  
In LuCI, you can check in STATUS \\ WIREGUARD if site-a and site-b are connected, you see the time between the last successfull handshake (or errors).

**Please be aware, that the scripts do not set firewall zone settings to enable traffic forwarding from “lan” firewall zone to “vpn” firewall zone and vice versa.**  
**You need to configure this firewall zone stuff (or for testing purpose, just put the wiregourd interfaces on both sides in the “lan” firwall zone instead of “vpn”) before you can do the tracerout test (see below).**

Verify the traffic is routed from each site through the VPN to the tunneled addresses at the other site.

On site a:

```
traceroute <some-site-b-LAN-IPv4-address>
traceroute <some-site-b-LAN-IPv6-address>
```

On site b:

```
traceroute <some-site-a-LAN-IPv4-address>
traceroute <some-site-a-LAN-IPv6-address>
```

## 4. Troubleshooting

\* Error Line 100 .. : Did you install Software Package luci-proto-wireguard before running the script?  
\* Editing Firewall before running scripts: Have you defined a empty “vpn” Firewall Zone before running the script?  
\* Downloading the code/script/file to a Computer with Windows OS leads to a non functional script file. You need to open the downloaded file with an editor like PSPad or Notepad++ and save it as text file in UNIX format before uploading.  
\* Transfer/Upload of the downloaded script/code snippet/file s2s\_combined.sh from your computer to the openWRT device can be tricky if you are working with a Windows based system / WinSCP. Make sure you use “text” mode for the upload of the file to the “root” folder of your openWrt device. For details see this forum post: [https://forum.openwrt.org/t/wireguard-guide-site2site-script-upload-problem-binary-text-winscp/182597](https://forum.openwrt.org/t/wireguard-guide-site2site-script-upload-problem-binary-text-winscp/182597 "https://forum.openwrt.org/t/wireguard-guide-site2site-script-upload-problem-binary-text-winscp/182597")  
\* More info about configuring the firwall zones “vpn” and “lan” working together can be found here:  
→ [https://forum.openwrt.org/t/solved-routing-riddle-driving-me-crazy/182754/4](https://forum.openwrt.org/t/solved-routing-riddle-driving-me-crazy/182754/4 "https://forum.openwrt.org/t/solved-routing-riddle-driving-me-crazy/182754/4") and in this thread [https://forum.openwrt.org/t/solved-wireguarde-site2site-script-firewall-zone-problem/182709](https://forum.openwrt.org/t/solved-wireguarde-site2site-script-firewall-zone-problem/182709 "https://forum.openwrt.org/t/solved-wireguarde-site2site-script-firewall-zone-problem/182709")  
\* optimzing, tuning, extra stuff to make things easier to understand / documented:  
→ Try to give your Wireguard Network Interface a IP (Range) and allow the Peer that IP Range as suggested here: [https://forum.openwrt.org/t/solved-routing-riddle-driving-me-crazy/182754/15](https://forum.openwrt.org/t/solved-routing-riddle-driving-me-crazy/182754/15 "https://forum.openwrt.org/t/solved-routing-riddle-driving-me-crazy/182754/15")
