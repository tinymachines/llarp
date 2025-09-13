# PBR extras

This article relies on the following:

- Accessing [web interface](/docs/guide-quick-start/walkthrough_login "docs:guide-quick-start:walkthrough_login") / [command-line interface](/docs/guide-quick-start/sshadministration "docs:guide-quick-start:sshadministration")
- Managing [configs](/docs/guide-user/base-system/uci "docs:guide-user:base-system:uci") / [packages](/docs/guide-user/additional-software/managing_packages "docs:guide-user:additional-software:managing_packages") / [services](/docs/guide-user/base-system/managing_services "docs:guide-user:base-system:managing_services") / [logs](/docs/guide-user/base-system/log.essentials "docs:guide-user:base-system:log.essentials")

## Introduction

- This instruction configures [PBR](https://en.wikipedia.org/wiki/Policy-based_routing "https://en.wikipedia.org/wiki/Policy-based_routing") with [netifd](/docs/techref/netifd "docs:techref:netifd") on OpenWrt.
- Follow the [automated](/docs/guide-user/advanced/pbr_extras#automated "docs:guide-user:advanced:pbr_extras") section for quick setup.

## Features

- Utilize multiple upstream interfaces with their own gateways.
- Route different subnets/clients to a different gateway.
- Prioritize routing for local subnets and tunnel endpoints.

## Implementation

Automatically set up PBR with netifd:

- Set up named routing tables for each interface.
- Assign each interface to its own routing table.
- Create default routes for unmanaged interfaces.
- Create default routing rules after subnets/endpoints.

Create custom routing rules before the default ones.

## Commands

Sub-command Description `setup` Set up policy-based routing. `unset` Unset policy-based routing.

## Instructions

```
# Configure profile
mkdir -p /etc/profile.d
cat << "EOF" > /etc/profile.d/pbr.sh
pbr() {
local PBR_CMD="${1}"
case "${PBR_CMD}" in
(setup|unset) pbr_proc ;;
(*) command pbr "${@}" ;;
esac
}
 
pbr_proc() {
. /lib/functions.sh
. /lib/functions/network.sh
network_flush_cache
config_load network
config_foreach pbr_iface_proc interface
for IPV in 4 6
do pbr_rule_"${PBR_CMD}"
done
uci commit network
service network restart
}
 
pbr_iface_proc() {
local NET_CONF="${1}"
local NET_PROTO
config_get NET_PROTO "${NET_CONF}" proto
case "${NET_CONF}" in
(loopback) return 0 ;;
esac
case "${NET_PROTO}" in
(gre*|vti*|vxlan|xfrm|relay) return 0 ;;
(none) for IPV in 4 6
do pbr_route_"${PBR_CMD}"
done ;;
esac
for IPV in 4 6
do pbr_table_"${PBR_CMD}"
done
pbr_ipr_"${PBR_CMD}"
}
 
pbr_rule_setup() {
local NET_CONF
eval network_find_wan"${IPV%4}" NET_CONF
uci -q batch << EOI
set network.default'${IPV%4}'='rule${IPV%4}'
set network.default'${IPV%4}'.lookup='${NET_CONF%6}'
set network.default'${IPV%4}'.priority='80000'
EOI
}
 
pbr_rule_unset() {
uci -q batch << EOI
delete network.default'${IPV%4}'
EOI
}
 
pbr_route_setup() {
local NET_TARG
case "${IPV}" in
(4) NET_TARG="0.0.0.0/0" ;;
(6) NET_TARG="::/0" ;;
esac
uci -q batch << EOI
set network.'${NET_CONF}'_rt'${IPV%4}'='route${IPV%4}'
set network.'${NET_CONF}'_rt'${IPV%4}'.interface='${NET_CONF}'
set network.'${NET_CONF}'_rt'${IPV%4}'.target='${NET_TARG}'
EOI
}
 
pbr_route_unset() {
uci -q batch << EOI
delete network.'${NET_CONF}'_rt'${IPV%4}'
EOI
}
 
pbr_table_setup() {
uci -q batch << EOI
set network.'${NET_CONF}'.ip'${IPV}'table='${NET_CONF%6}'
EOI
}
 
pbr_table_unset() {
uci -q batch << EOI
delete network.'${NET_CONF}'.ip'${IPV}'table
EOI
}
 
pbr_ipr_setup() {
if ! grep -q -E -e "^[0-9]+\s+${NET_CONF%6}$" \
/etc/iproute2/rt_tables
then sed -i -e "\$a $(($(sort -r -n \
/etc/iproute2/rt_tables 2> /dev/null \
| grep -o -E -m 1 "^[0-9]+")+1))\t${NET_CONF%6}" \
/etc/iproute2/rt_tables
fi
}
 
pbr_ipr_unset() {
sed -i -r -e "/^[0-9]+\s+${NET_CONF%6}$/d" \
/etc/iproute2/rt_tables
}
EOF
. /etc/profile.d/pbr.sh
```

## Examples

```
# Set up PBR
pbr setup
```

## Automated

```
wget -U "" -O pbr-extras.sh "https://openwrt.org/_export/code/docs/guide-user/advanced/pbr_extras?codeblock=0"
. ./pbr-extras.sh
```
