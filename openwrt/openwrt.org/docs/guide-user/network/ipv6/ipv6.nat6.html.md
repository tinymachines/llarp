# NAT66 and IPv6 masquerading

This article relies on the following:

- Accessing [web interface](/docs/guide-quick-start/walkthrough_login "docs:guide-quick-start:walkthrough_login") / [command-line interface](/docs/guide-quick-start/sshadministration "docs:guide-quick-start:sshadministration")
- Managing [configs](/docs/guide-user/base-system/uci "docs:guide-user:base-system:uci") / [packages](/docs/guide-user/additional-software/managing_packages "docs:guide-user:additional-software:managing_packages") / [services](/docs/guide-user/base-system/managing_services "docs:guide-user:base-system:managing_services") / [logs](/docs/guide-user/base-system/log.essentials "docs:guide-user:base-system:log.essentials")

## Introduction

- This how-to describes the method for setting up NAT66 aka NAT6 with IPv6 masquerading on your OpenWrt router.
- Assuming a [ULA prefix](/docs/guide-user/network/ipv6/configuration#ula_prefix "docs:guide-user:network:ipv6:configuration"), [SLAAC and DHCPv6](/docs/guide-user/network/ipv6/configuration#slaac_and_dhcpv6 "docs:guide-user:network:ipv6:configuration") and a working IPv6 connection on the router.
- Avoid using NAT66 and better [use relay mode](/docs/guide-user/network/ipv6/configuration#ipv6_relay "docs:guide-user:network:ipv6:configuration") if you are provided with a /64 prefix.
- It is also best to avoid using NAT66 unless you are facing the following problems:
  
  - IPv6 multihoming without BGP.
  - Performing stateless 1:1 NAT for migration purposes.
  - Your ISP uses a dynamic prefix and you need stable addressing.
  - Creating a subnet for when the network doesn't support subnetting.
  - Being provided a smaller prefix than a /64 or worse, none at all or a ULA address.
- See also: [NAT64 for a IPv6-only networks](/docs/guide-user/network/ipv6/nat64 "docs:guide-user:network:ipv6:nat64"), [IPv6 NAT and NPT](/docs/guide-user/firewall/fw3_configurations/fw3_nat#ipv6_nat "docs:guide-user:firewall:fw3_configurations:fw3_nat")

## Command-line instructions

### 1. Firewall

Enable IPv6 masquerading on the upstream zone.

```
# Configure firewall
uci set firewall.@zone[1].masq6="1"
uci commit firewall
service firewall restart
```

### 2. Network

Disable IPv6 source filter on the upstream interface.

```
# Configure network
uci set network.wan6.sourcefilter="0"
uci commit network
service network restart
```

Prefer [IPv6 by default](/docs/guide-user/network/ipv6/ipv6_extras#using_ipv6_by_default "docs:guide-user:network:ipv6:ipv6_extras") or announce [IPv6 default route](/docs/guide-user/network/ipv6/ipv6_extras#announcing_ipv6_default_route "docs:guide-user:network:ipv6:ipv6_extras") if necessary.

## Troubleshooting

Collect and analyze the following information.

```
# Log and status
service firewall restart
 
# Runtime configuration
ip -6 address show; ip -6 route show table all
ip -6 rule show; nft list ruleset
 
# Persistent configuration
uci show network; uci show firewall
```
