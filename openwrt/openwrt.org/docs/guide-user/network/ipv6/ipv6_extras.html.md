# IPv6 extras

This article relies on the following:

- Accessing [web interface](/docs/guide-quick-start/walkthrough_login "docs:guide-quick-start:walkthrough_login") / [command-line interface](/docs/guide-quick-start/sshadministration "docs:guide-quick-start:sshadministration")
- Managing [configs](/docs/guide-user/base-system/uci "docs:guide-user:base-system:uci") / [packages](/docs/guide-user/additional-software/managing_packages "docs:guide-user:additional-software:managing_packages") / [services](/docs/guide-user/base-system/managing_services "docs:guide-user:base-system:managing_services") / [logs](/docs/guide-user/base-system/log.essentials "docs:guide-user:base-system:log.essentials")

## Introduction

- This how-to describes the most common [IPv6](https://en.wikipedia.org/wiki/IPv6 "https://en.wikipedia.org/wiki/IPv6") tuning scenarios adapted for OpenWrt.
- Follow [IPv6 NAT or NPT](/docs/guide-user/firewall/fw3_configurations/fw3_nat#ipv6_nat "docs:guide-user:firewall:fw3_configurations:fw3_nat") for NAT setup and [IPv6 multicast](/docs/guide-user/network/ipv6/multicast "docs:guide-user:network:ipv6:multicast") for multicast setup.

## Extras

### Disabling GUA prefix

Assign only the ULA prefix on the LAN interface.

```
uci set network.lan.ip6class="local"
uci commit network
service network restart
```

### Announcing IPv6 default route

Announce IPv6 default route for clients using the ULA prefix.

```
uci set dhcp.lan.ra_default="1"
uci commit dhcp
service odhcpd restart
```

### Using IPv6 by default

Prefer IPv6 over IPv4 behind NAT66 for the ULA prefix. Specify an [unassigned](https://www.iana.org/assignments/ipv6-address-space/ipv6-address-space.xhtml "https://www.iana.org/assignments/ipv6-address-space/ipv6-address-space.xhtml") prefix for ULA.

```
NET_ULA="$(uci get network.globals.ula_prefix)"
uci set network.globals.ula_prefix="d${NET_ULA:1}"
uci commit network
service network restart
```

### Missing GUA prefix

Suppress warnings about missing GUA prefix.

```
uci set dhcp.odhcpd.loglevel="3"
uci commit dhcp
service odhcpd restart
```

### Disabling IPv6 source filter

Disable IPv6 source filter for setups using PBR, NAT or NPT.

```
uci set network.wan6.sourcefilter="0"
uci commit network
service network restart
```
