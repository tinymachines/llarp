# IP set extras

This article relies on the following:

- Accessing [web interface](/docs/guide-quick-start/walkthrough_login "docs:guide-quick-start:walkthrough_login") / [command-line interface](/docs/guide-quick-start/sshadministration "docs:guide-quick-start:sshadministration")
- Managing [configs](/docs/guide-user/base-system/uci "docs:guide-user:base-system:uci") / [packages](/docs/guide-user/additional-software/managing_packages "docs:guide-user:additional-software:managing_packages") / [services](/docs/guide-user/base-system/managing_services "docs:guide-user:base-system:managing_services") / [logs](/docs/guide-user/base-system/log.essentials "docs:guide-user:base-system:log.essentials")

## Introduction

- This instruction extends the functionality of [Firewall](/docs/guide-user/firewall/start "docs:guide-user:firewall:start").
- Follow the [automated](/docs/guide-user/advanced/ipset_extras#automated "docs:guide-user:advanced:ipset_extras") section for quick setup.

## Features

- Create and populate IP sets with domains, CIDRs, ASNs and GeoIP.
- Populate IP sets automatically at startup.

## Implementation

- Rely on [DNS](/docs/guide-user/base-system/dhcp#ip_sets "docs:guide-user:base-system:dhcp")/[Firewall](/docs/guide-user/firewall/firewall_configuration#ip_sets "docs:guide-user:firewall:firewall_configuration") IP set UCI configurations.
- Process settings with [OpenWrt functions](https://github.com/openwrt/openwrt/blob/master/package/base-files/files/lib/functions.sh "https://github.com/openwrt/openwrt/blob/master/package/base-files/files/lib/functions.sh").
- Utilize [resolveip](/packages/pkgdata/resolveip "packages:pkgdata:resolveip") to resolve domains.
- Fetch ASN prefixes using [RIPEstat Data API](https://stat.ripe.net/docs/data_api "https://stat.ripe.net/docs/data_api").
- Fetch GeoIP data using [IPdeny GeoIP Data](https://www.ipdeny.com/ipblocks/ "https://www.ipdeny.com/ipblocks/").
- Use [Hotplug extras](/docs/guide-user/advanced/hotplug_extras "docs:guide-user:advanced:hotplug_extras") to trigger setup automatically.

## Commands

Sub-command Description `setup` Set up IP sets. `unset` Unset IP sets.

## Instructions

```
# Configure profile
mkdir -p /etc/profile.d
cat << "EOF" > /etc/profile.d/ipset.sh
ipset() {
local IPSET_CMD="${1}"
case "${IPSET_CMD}" in
(setup|unset) ipset_proc ;;
(*) command ipset "${@}" ;;
esac
}
 
ipset_proc() {
. /lib/functions.sh
config_load dhcp
config_foreach ipset_proc_"${IPSET_CMD}" ipset
uci_commit firewall
service firewall reload
fw4 reload-sets
}
 
ipset_proc_setup() {
local IPSET_CONF="${1}"
local IPSET_TEMP="$(mktemp -t ipset.XXXXXX)"
{
config_list_foreach "${IPSET_CONF}" domain ipset_domain
config_list_foreach "${IPSET_CONF}" cidr ipset_cidr
config_list_foreach "${IPSET_CONF}" asn ipset_asn
config_list_foreach "${IPSET_CONF}" geoip ipset_geoip
} | sort -u > "${IPSET_TEMP}"
config_list_foreach "${IPSET_CONF}" name ipset_"${IPSET_CMD}"
rm -f "${IPSET_TEMP}"
}
 
ipset_proc_unset() {
local IPSET_CONF="${1}"
config_list_foreach "${IPSET_CONF}" name ipset_"${IPSET_CMD}"
}
 
ipset_setup() {
local IPSET_NAME="${1}"
local IPSET_FILE="/var/ipset-${IPSET_NAME}"
local IPSET_FAMILY
case "${IPSET_NAME}" in
(*6) IPSET_FAMILY="ipv6"
sed -e "/\./d" ;;
(*) IPSET_FAMILY="ipv4"
sed -e "/:/d" ;;
esac < "${IPSET_TEMP}" > "${IPSET_FILE}"
uci -q batch << EOI
set firewall.'${IPSET_NAME//-/_}'='ipset'
set firewall.'${IPSET_NAME//-/_}'.name='${IPSET_NAME}'
set firewall.'${IPSET_NAME//-/_}'.family='${IPSET_FAMILY}'
set firewall.'${IPSET_NAME//-/_}'.match='net'
set firewall.'${IPSET_NAME//-/_}'.loadfile='${IPSET_FILE}'
EOI
}
 
ipset_unset() {
local IPSET_NAME="${1}"
local IPSET_FILE="/var/ipset-${IPSET_NAME}"
rm -f "${IPSET_FILE}"
uci -q batch << EOI
delete firewall.'${IPSET_NAME//-/_}'.loadfile
EOI
}
 
ipset_domain() {
local IPSET_ENTRY="${1}"
resolveip "${IPSET_ENTRY}"
}
 
ipset_cidr() {
local IPSET_ENTRY="${1}"
echo "${IPSET_ENTRY}"
}
 
ipset_asn() {
local IPSET_ENTRY="${1}"
wget -O - "https://stat.ripe.net/data/\
announced-prefixes/data.json?resource=${IPSET_ENTRY}" \
| jsonfilter -e "@['data']['prefixes'][*]['prefix']"
}
 
ipset_geoip() {
local IPSET_ENTRY="${1}"
wget -O - "https://www.ipdeny.com/ipblocks/data/\
aggregated/${IPSET_ENTRY}-aggregated.zone" \
"https://www.ipdeny.com/ipv6/ipaddresses/\
aggregated/${IPSET_ENTRY}-aggregated.zone"
}
EOF
. /etc/profile.d/ipset.sh
 
# Configure hotplug
mkdir -p /etc/hotplug.d/online
cat << "EOF" > /etc/hotplug.d/online/70-ipset-setup
if [ -z "${TERM}" ] \
&& [ ! -e /var/lock/ipset-setup ] \
|| [ -n "${TERM}" ] \
&& lock -n /var/lock/ipset-setup \
&& sleep 10
then . /etc/profile.d/ipset.sh
ipset setup
lock -u /var/lock/ipset-setup
fi
EOF
cat << "EOF" >> /etc/sysupgrade.conf
/etc/hotplug.d/online/70-ipset-setup
EOF
 
# Configure cron
cat << "EOF" >> /etc/crontabs/root
0 */3 * * * . /etc/hotplug.d/online/70-ipset-setup
EOF
service cron restart
```

## Examples

```
# Install packages
opkg update
opkg install resolveip
 
# Configure IP sets, domains, CIDRs and ASNs
uci set dhcp.example="ipset"
uci add_list dhcp.example.name="example"
uci add_list dhcp.example.name="example6"
uci add_list dhcp.example.domain="example.com"
uci add_list dhcp.example.domain="example.net"
uci add_list dhcp.example.cidr="9.9.9.9/32"
uci add_list dhcp.example.cidr="2620:fe::fe/128"
uci add_list dhcp.example.asn="2906"
uci add_list dhcp.example.asn="40027"
uci add_list dhcp.example.geoip="cn"
uci add_list dhcp.example.geoip="ru"
uci commit dhcp
 
# Populate IP sets
ipset setup
```

## Automated

```
wget -U "" -O ipset-extras.sh "https://openwrt.org/_export/code/docs/guide-user/advanced/ipset_extras?codeblock=0"
. ./ipset-extras.sh
```
