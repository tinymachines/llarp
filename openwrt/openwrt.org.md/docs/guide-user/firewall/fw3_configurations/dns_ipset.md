# Filtering traffic with IP sets by DNS

This article relies on the following:

- Accessing [web interface](/docs/guide-quick-start/walkthrough_login "docs:guide-quick-start:walkthrough_login") / [command-line interface](/docs/guide-quick-start/sshadministration "docs:guide-quick-start:sshadministration")
- Managing [configs](/docs/guide-user/base-system/uci "docs:guide-user:base-system:uci") / [packages](/docs/guide-user/additional-software/managing_packages "docs:guide-user:additional-software:managing_packages") / [services](/docs/guide-user/base-system/managing_services "docs:guide-user:base-system:managing_services") / [logs](/docs/guide-user/base-system/log.essentials "docs:guide-user:base-system:log.essentials")

## Introduction

- This how-to configures traffic filtering with [IP sets](https://wiki.nftables.org/wiki-nftables/index.php/Sets "https://wiki.nftables.org/wiki-nftables/index.php/Sets") by DNS on OpenWrt.
- It relies on [resolveip](/packages/pkgdata/resolveip "packages:pkgdata:resolveip") and [firewall](/docs/guide-user/firewall/overview "docs:guide-user:firewall:overview") with [IP sets](/docs/guide-user/firewall/firewall_configuration#ip_sets "docs:guide-user:firewall:firewall_configuration") to resolve and filter domains.

## Goals

- Filter LAN client traffic with IP sets by DNS.

## Command-line instructions

Install the required packages. Filter LAN client traffic with firewall and IP sets. Set up [IP set extras](/docs/guide-user/advanced/ipset_extras "docs:guide-user:advanced:ipset_extras") and [Hotplug extras](/docs/guide-user/advanced/hotplug_extras "docs:guide-user:advanced:hotplug_extras") to automatically populate IP sets.

```
# Install packages
opkg update
opkg install resolveip
 
# Configure IP sets
uci -q delete dhcp.filter
uci set dhcp.filter="ipset"
uci add_list dhcp.filter.name="filter"
uci add_list dhcp.filter.name="filter6"
uci add_list dhcp.filter.domain="example.com"
uci add_list dhcp.filter.domain="example.net"
uci commit dhcp
 
# Filter LAN client traffic with IP sets
for IPV in 4 6
do
uci -q delete firewall.fwd_filter${IPV%4}
uci set firewall.fwd_filter${IPV%4}="rule"
uci set firewall.fwd_filter${IPV%4}.name="Filter-IPset-DNS-Forward"
uci set firewall.fwd_filter${IPV%4}.src="lan"
uci set firewall.fwd_filter${IPV%4}.dest="wan"
uci set firewall.fwd_filter${IPV%4}.proto="all"
uci set firewall.fwd_filter${IPV%4}.family="ipv${IPV}"
uci set firewall.fwd_filter${IPV%4}.ipset="filter${IPV%4} dest"
uci set firewall.fwd_filter${IPV%4}.target="REJECT"
done
uci commit firewall
 
# Populate IP sets
ipset setup
```

## Testing

Flush DNS cache on the clients and restart the client browser. Verify your client traffic is properly filtered on the router.

## Troubleshooting

Collect and analyze the following information.

```
# Restart services
service firewall restart
 
# Runtime configuration
nft list ruleset
 
# Persistent configuration
uci show firewall; crontab -l
```

## Extras

### Web interface

If you want to manage the settings using web interface.

- Navigate to **LuCI → Network → Firewall → Traffic Rules → Filter-IPset-DNS-Forward** to manage firewall rules.
- Navigate to **LuCI → Network → DHCP and DNS → IP sets** to manage domains.

Reboot the router to apply the changes.

### Manage domains

Add/remove domains to/from the filtering list.

```
# Add domains
uci add_list dhcp.filter.domain="example.com"
uci add_list dhcp.filter.domain="example.net"
 
# Remove domains
uci del_list dhcp.filter.domain="example.com"
uci del_list dhcp.filter.domain="example.net"
 
# Save and apply
uci commit dhcp
ipset setup
```

### Source restriction

Limit the restriction scope to a specific source MAC address.

```
# Apply source restriction
for IPV in 4 6
do
uci add_list firewall.fwd_filter${IPV%4}.src_mac="11:22:33:44:55:66"
uci add_list firewall.fwd_filter${IPV%4}.src_mac="aa:bb:cc:dd:ee:ff"
done
uci commit firewall
service firewall restart
```

### Time restriction

[Reorder firewall rules](/docs/guide-user/firewall/fw3_configurations/dns_ipset#established_connections "docs:guide-user:firewall:fw3_configurations:dns_ipset") and enable time restriction to keep the rules active. [Reload kernel timezone](/docs/guide-user/base-system/system_configuration#daylight_saving_time "docs:guide-user:base-system:system_configuration") to properly apply DST.

```
# Apply time restriction
for IPV in 4 6
do
uci set firewall.fwd_filter${IPV%4}.start_time="21:00:00"
uci set firewall.fwd_filter${IPV%4}.stop_time="09:00:00"
uci set firewall.fwd_filter${IPV%4}.weekdays="Mon Tue Wed Thu Fri"
done
uci commit firewall
service firewall restart
```

### Established connections

Reorder firewall rules to properly apply time restrictions.

```
# Reorder firewall rules
cat << "EOF" > /etc/nftables.d/estab.sh
ER_RULE="$(nft -a list chain inet fw4 forward \
| sed -n -e "/\sestablished.*related.*accept\s/p")"
RJ_RULE="$(nft -a list chain inet fw4 forward \
| sed -n -e "/\shandle_reject\s/p")"
nft delete rule inet fw4 forward handle ${ER_RULE##* }
if [ -n "${RJ_RULE}" ]
then nft insert rule inet fw4 forward position ${RJ_RULE##* } ${ER_RULE}
else nft add rule inet fw4 forward ${ER_RULE}
fi
EOF
uci -q delete firewall.estab
uci set firewall.estab="include"
uci set firewall.estab.path="/etc/nftables.d/estab.sh"
uci commit firewall
service firewall restart
```
