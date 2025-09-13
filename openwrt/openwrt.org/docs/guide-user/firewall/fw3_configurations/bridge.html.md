# Bridge firewall

This article relies on the following:

- Accessing [web interface](/docs/guide-quick-start/walkthrough_login "docs:guide-quick-start:walkthrough_login") / [command-line interface](/docs/guide-quick-start/sshadministration "docs:guide-quick-start:sshadministration")
- Managing [configs](/docs/guide-user/base-system/uci "docs:guide-user:base-system:uci") / [packages](/docs/guide-user/additional-software/managing_packages "docs:guide-user:additional-software:managing_packages") / [services](/docs/guide-user/base-system/managing_services "docs:guide-user:base-system:managing_services") / [logs](/docs/guide-user/base-system/log.essentials "docs:guide-user:base-system:log.essentials")

## Introduction

- This how-to describes the method for setting up [bridge](https://en.wikipedia.org/wiki/Bridging_%28networking%29 "https://en.wikipedia.org/wiki/Bridging_(networking)") firewall on OpenWrt.
- Follow [Splitting VLANs](/docs/guide-user/network/vlan/creating_virtual_switches "docs:guide-user:network:vlan:creating_virtual_switches") to be able to filter traffic between VLAN ports.
- Follow [Wireless configuration](/docs/guide-user/network/wifi/basic "docs:guide-user:network:wifi:basic") to isolate wireless clients from each other.

## Goals

- Filter and intercept transit traffic on bridged interfaces.

## Command-line instructions

Assuming a setup with bridged LAN and WAN interfaces. Install the required packages. Enable bridge firewall intercepting DNS queries and filtering transit traffic from `eth0` to `eth1`.

```
# Install packages
opkg update
opkg install kmod-nft-bridge
 
# Configure firewall
cat << "EOF" > /etc/nftables.d/bridge.sh
. /lib/functions/network.sh
network_flush_cache
network_find_wan NET_IF
network_get_device NET_DEV "${NET_IF}"
NET_MAC="$(ubus -S call network.device status \
"{'name':'${NET_DEV}'}" | jsonfilter -e "$['macaddr']")"
nft add table bridge filter
nft flush table bridge filter
nft add chain bridge filter prerouting \
{ type filter hook prerouting priority dstnat\; }
nft add rule bridge filter prerouting meta \
l4proto { tcp, udp } th dport 53 pkttype set host \
ether daddr set "${NET_MAC}" comment "Intercept-DNS"
nft add chain bridge filter forward \
{ type filter hook forward priority filter\; }
nft add rule bridge filter forward iifname "eth0" \
oifname "eth1" drop comment "Deny-eth0-eth1"
EOF
uci -q delete firewall.bridge
uci set firewall.bridge="include"
uci set firewall.bridge.path="/etc/nftables.d/bridge.sh"
uci commit firewall
service firewall restart
```

Set up [DNS hijacking](/docs/guide-user/firewall/fw3_configurations/intercept_dns "docs:guide-user:firewall:fw3_configurations:intercept_dns") and [DNS filtering](/docs/guide-user/base-system/dhcp_configuration#dns_filtering "docs:guide-user:base-system:dhcp_configuration").

## Example: DSCP Classification on Dumb AP

If you have your firewall disabled and have kmod-nft-bridge installed, then you can do this easily. This will classify HTTP(S) traffic as AF23. Not practical, but a start.

Save the following to /etc/nftables.conf

```
flush ruleset
 
table bridge dscp {
    chain dscp_set_af23 {
        ip dscp set af23
        ip6 dscp set af23
    }
 
    chain prerouting {
        type filter hook prerouting priority 0; policy accept;
 
        meta l4proto tcp th dport {80, 443} jump dscp_set_af23
    }
}
```

Run the following code. Add it to /etc/rc.local to make it persist.

```
nft -f /etc/nftables.conf
```

## Testing

Use [nslookup](http://man.cx/nslookup%281%29 "http://man.cx/nslookup%281%29"), [ping](http://man.cx/ping%281%29 "http://man.cx/ping%281%29"), [ping6](http://man.cx/ping6%281%29 "http://man.cx/ping6%281%29") on LAN clients to verify the firewall configuration.

## Troubleshooting

Collect and analyze the following information.

```
# Log and status
service firewall restart
 
# Runtime configuration
lsmod | grep -e bridge
nft list ruleset
 
# Persistent configuration
uci show firewall
```

## Extras

### References

- [nftables wiki: Bridge filtering](https://wiki.nftables.org/wiki-nftables/index.php/Bridge_filtering "https://wiki.nftables.org/wiki-nftables/index.php/Bridge_filtering")
- [NetDev: Bridge filtering with nftables](https://netdevconf.info/1.1/proceedings/papers/Bridge-filter-with-nftables.pdf "https://netdevconf.info/1.1/proceedings/papers/Bridge-filter-with-nftables.pdf")
