# MWAN with netifd

This article relies on the following:

- Accessing [web interface](/docs/guide-quick-start/walkthrough_login "docs:guide-quick-start:walkthrough_login") / [command-line interface](/docs/guide-quick-start/sshadministration "docs:guide-quick-start:sshadministration")
- Managing [configs](/docs/guide-user/base-system/uci "docs:guide-user:base-system:uci") / [packages](/docs/guide-user/additional-software/managing_packages "docs:guide-user:additional-software:managing_packages") / [services](/docs/guide-user/base-system/managing_services "docs:guide-user:base-system:managing_services") / [logs](/docs/guide-user/base-system/log.essentials "docs:guide-user:base-system:log.essentials")

## Introduction

- This instruction configures multi-WAN with [netifd](/docs/techref/netifd "docs:techref:netifd") on OpenWrt.
- Enable [IPv6 NAT or NPT](/docs/guide-user/firewall/fw3_configurations/fw3_nat#ipv6_nat "docs:guide-user:firewall:fw3_configurations:fw3_nat") and disable [IPv6 source filter](/docs/guide-user/network/ipv6/ipv6_extras#disabling_ipv6_source_filter "docs:guide-user:network:ipv6:ipv6_extras") if necessary.
- Follow [PBR with netifd](/docs/guide-user/network/routing/pbr_netifd "docs:guide-user:network:routing:pbr_netifd") to customize your routing configuration.

## Features

- Implement multi-WAN based on PBR with netifd.
- Support dual-stack setups using IPv4 and IPv6.
- Perform connectivity check with ICMP and ICMPv6.
- Provide a simple failover method.

## Command-line instructions

Assuming pre-configured upstream interfaces. Set up PBR with netifd using [PBR extras](/docs/guide-user/advanced/pbr_extras "docs:guide-user:advanced:pbr_extras"). Save the failover script. Configure cron to run the failover script. Specify the managed interfaces.

```
# Failover script
cat << "EOF" > /etc/hotplug.d/iface/80-mwan
iface_proc() {
local NET_IF="${1}"
local NET_RT
local NET_OK
for IPV in 4 6
do NET_OK="$(eval echo "\${NET_OK${IPV}}")"
if [ -z "${NET_OK}" ] \
&& iface_check "${NET_IF}"
then eval NET_OK"${IPV}"="1"
NET_RT="$(uci -q get network."${NET_IF}".ip"${IPV}"table)"
uci set network.default"${IPV%4}".lookup="${NET_RT}"
service network reload
fi
done
}
 
iface_check() {
local PING_IF="${1}"
local PING_CNT="2"
local PING_WAIT="3"
local PING_SRC
local PING_DST
eval network_get_ipaddr"${IPV%4}" PING_SRC "${PING_IF}"
eval network_get_gateway"${IPV%4}" PING_DST "${PING_IF}"
case "${PING_DST}" in
(0.0.0.0) PING_DST="${NET_HOST%% *}" ;;
(::) PING_DST="${NET_HOST##* }" ;;
esac
ping -q -c "${PING_CNT}" -W "${PING_WAIT}" \
-I "${PING_SRC}" "${PING_DST}" &> /dev/null
}
 
NET_IF="$(uci -q get network.mwan.iface)"
NET_HOST="$(uci -q get network.mwan.host)"
. /lib/functions/network.sh
network_flush_cache
for NET_IF in ${NET_IF}
do iface_proc "${NET_IF}"
done
EOF
cat << "EOF" >> /etc/sysupgrade.conf
/etc/hotplug.d/iface/80-mwan
EOF
 
# Configure cron
cat << "EOF" >> /etc/crontabs/root
* * * * * . /etc/hotplug.d/iface/80-mwan
EOF
uci set system.@system[0].cronloglevel="9"
uci commit system
service cron restart
```

## Examples

```
# Configure interfaces
NET_IF="wana wana6 wanb wanb6 wanc wanc6"
NET_HOST="8.8.8.8 2001:4860:4860::8888"
uci -q delete network.mwan
uci set network.mwan="mwan"
for NET_IF in ${NET_IF}
do uci add_list network.mwan.iface="${NET_IF}"
done
for NET_HOST in ${NET_HOST}
do uci add_list network.mwan.host="${NET_HOST}"
done
uci commit network
service network restart
```

## Automated

```
wget -U "" -O mwan-netifd.sh "https://openwrt.org/_export/code/docs/guide-user/network/wan/multiwan/mwan_netifd?codeblock=0"
. ./mwan-netifd.sh
```
