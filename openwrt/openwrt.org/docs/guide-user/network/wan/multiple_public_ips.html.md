# Using multiple WAN IPs

This article relies on the following:

- Accessing [web interface](/docs/guide-quick-start/walkthrough_login "docs:guide-quick-start:walkthrough_login") / [command-line interface](/docs/guide-quick-start/sshadministration "docs:guide-quick-start:sshadministration")
- Managing [configs](/docs/guide-user/base-system/uci "docs:guide-user:base-system:uci") / [packages](/docs/guide-user/additional-software/managing_packages "docs:guide-user:additional-software:managing_packages") / [services](/docs/guide-user/base-system/managing_services "docs:guide-user:base-system:managing_services") / [logs](/docs/guide-user/base-system/log.essentials "docs:guide-user:base-system:log.essentials")

## Introduction

- Some users get from their ISP more than one routable public IP address.
- Assume that the WAN IPs are `100.64.0.2/29`, `100.64.0.3/29`, etc.

## Goals

- Utilize multiple WAN IPs on the same interface.
- Use a specific WAN IP for a specific LAN host.

## Command-line instructions

### 1. Network

Create an alias for the WAN interface.

```
uci -q delete network.wan3
uci set network.wan3="interface"
uci set network.wan3.proto="static"
uci set network.wan3.device="@wan"
uci set network.wan3.ipaddr="100.64.0.3/29"
uci commit network
service network restart
```

### 2. Firewall

Configure destination and source NAT firewall rules.

```
uci -q delete firewall.dnat3
uci set firewall.dnat3="redirect"
uci set firewall.dnat3.name="DNAT3"
uci set firewall.dnat3.src="wan"
uci set firewall.dnat3.src_dip="100.64.0.3"
uci set firewall.dnat3.dest="lan"
uci set firewall.dnat3.dest_ip="192.168.1.3"
uci set firewall.dnat3.proto="all"
uci set firewall.dnat3.target="DNAT"
uci -q delete firewall.snat3
uci set firewall.snat3="nat"
uci set firewall.snat3.name="SNAT3"
uci set firewall.snat3.src="wan"
uci set firewall.snat3.src_ip="192.168.1.3"
uci set firewall.snat3.snat_ip="100.64.0.3"
uci set firewall.snat3.proto="all"
uci set firewall.snat3.target="SNAT"
uci commit firewall
service firewall restart
```
