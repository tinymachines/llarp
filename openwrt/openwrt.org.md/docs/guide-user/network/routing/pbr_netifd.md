# PBR with netifd

This article relies on the following:

- Accessing [web interface](/docs/guide-quick-start/walkthrough_login "docs:guide-quick-start:walkthrough_login") / [command-line interface](/docs/guide-quick-start/sshadministration "docs:guide-quick-start:sshadministration")
- Managing [configs](/docs/guide-user/base-system/uci "docs:guide-user:base-system:uci") / [packages](/docs/guide-user/additional-software/managing_packages "docs:guide-user:additional-software:managing_packages") / [services](/docs/guide-user/base-system/managing_services "docs:guide-user:base-system:managing_services") / [logs](/docs/guide-user/base-system/log.essentials "docs:guide-user:base-system:log.essentials")

## Introduction

- This how-to provides most common scenarios for PBR (Policy Based Routing) with netifd.
- It contains both IPv4 and IPv6 routing rules to prevent traffic leaks.
- Enable [IPv6 NAT or NPT](/docs/guide-user/firewall/fw3_configurations/fw3_nat#ipv6_nat "docs:guide-user:firewall:fw3_configurations:fw3_nat") and disable [IPv6 source filter](/docs/guide-user/network/ipv6/ipv6_extras#disabling_ipv6_source_filter "docs:guide-user:network:ipv6:ipv6_extras") if necessary.
- Follow [Routing and PBR basics](/docs/guide-user/network/routing/basics#policy-based_routing "docs:guide-user:network:routing:basics") for common routing principles.

## Guidelines

- Assign each interface to a separate routing table.
  
  - It makes netifd create essential rules automatically to simplify the setup.
  - This isolates each default route resolving possible routing conflicts.
- Keep the default route enabled for each upstream interface.
  
  - Multiple interfaces can be connected and used simultaneously by different clients.
- Do not duplicate static routes in different routing tables.
  
  - Duplicating the same routes in different tables is redundant and pointless.
  - Avoid adding routes on different interfaces to the same table.
- Create custom routing rules for each assigned routing table.
  
  - Elevate routing decision on the level of routing rules.
    
    - Abstract from the contents of routing tables for easier troubleshooting.
  - Use a specific custom priority for each routing rule.
    
    - A priority of about 30000 can override the `main` table.
    - A priority of about 40000-80000 follows after the `main` table.
  - Arrange more specific rules before less specific ones.
    
    - Remember to prioritize tunnel endpoints and local addresses and subnets.
  - Preferably use the `main` table only for tunnel endpoints.
  - Optionally use the `main` table for one of the upstream interfaces.
    
    - This can be useful in a trivial case to minimize configuration.
    - It makes problematic to utilize high numeric priority values.

## Instructions

### Route LAN to VPN and DMZ to WAN

Assuming the following setup:

- VPN and WAN - upstream networks
- LAN and DMZ - downstream networks

Prioritize routing LAN to VPN. Route DMZ to WAN by default.

```
for IPV in 4 6
do
uci set network.lan.ip${IPV}table="1"
uci set network.vpn.ip${IPV}table="2"
uci set network.dmz.ip${IPV}table="3"
uci -q delete network.lan_vpn${IPV%4}
uci set network.lan_vpn${IPV%4}="rule${IPV%4}"
uci set network.lan_vpn${IPV%4}.in="lan"
uci set network.lan_vpn${IPV%4}.lookup="2"
uci set network.lan_vpn${IPV%4}.priority="30000"
done
uci commit network
service network restart
```

### Route VPN server LAN via VPN client

Assuming a working [WireGuard site-to-site](/docs/guide-user/services/vpn/wireguard/extras#site-to-site "docs:guide-user:services:vpn:wireguard:extras") setup.

Allow default routes via VPN client peer on VPN server. Prioritize routing VPN server LAN to VPN tunnel.

```
uci add_list network.wgclient.allowed_ips="0.0.0.0/0"
uci add_list network.wgclient.allowed_ips="::/0"
for IPV in 4 6
do
uci set network.lan.ip${IPV}table="1"
uci set network.vpn.ip${IPV}table="2"
uci -q delete network.lan_vpn${IPV%4}
uci set network.lan_vpn${IPV%4}="rule${IPV%4}"
uci set network.lan_vpn${IPV%4}.in="lan"
uci set network.lan_vpn${IPV%4}.lookup="2"
uci set network.lan_vpn${IPV%4}.priority="30000"
done
uci commit network
service network restart
```

### Route LAN to VPN with failover to WAN

Prioritize routing LAN to VPN. Route LAN to WAN as fallback when VPN is down.

```
for IPV in 4 6
do
uci set network.lan.ip${IPV}table="1"
uci set network.wan${IPV%4}.ip${IPV}table="2"
uci -q delete network.lan_wan${IPV%4}
uci set network.lan_wan${IPV%4}="rule${IPV%4}"
uci set network.lan_wan${IPV%4}.in="lan"
uci set network.lan_wan${IPV%4}.lookup="2"
uci set network.lan_wan${IPV%4}.priority="40000"
done
uci commit network
service network restart
```

### Route LAN to VPN by IP set

Route LAN traffic to VPN except destinations matching IP set. Mark LAN traffic with firewall to apply custom routing.

```
for IPV in 4 6
do
uci -q delete firewall.wan_set${IPV%4}
uci set firewall.wan_set${IPV%4}="ipset"
uci set firewall.wan_set${IPV%4}.name="wan${IPV%4}"
uci set firewall.wan_set${IPV%4}.family="ipv${IPV}"
uci set firewall.wan_set${IPV%4}.match="net"
uci -q delete firewall.lan_mark${IPV%4}
uci set firewall.lan_mark${IPV%4}="rule"
uci set firewall.lan_mark${IPV%4}.name="Mark-LAN-VPN"
uci set firewall.lan_mark${IPV%4}.src="lan"
uci set firewall.lan_mark${IPV%4}.dest="*"
uci set firewall.lan_mark${IPV%4}.ipset="!wan${IPV%4} dest"
uci set firewall.lan_mark${IPV%4}.proto="all"
uci set firewall.lan_mark${IPV%4}.family="ipv${IPV}"
uci set firewall.lan_mark${IPV%4}.set_mark="0x1"
uci set firewall.lan_mark${IPV%4}.target="MARK"
uci set network.lan.ip${IPV}table="1"
uci set network.vpn.ip${IPV}table="2"
uci -q delete network.lan_vpn${IPV%4}
uci set network.lan_vpn${IPV%4}="rule${IPV%4}"
uci set network.lan_vpn${IPV%4}.in="lan"
uci set network.lan_vpn${IPV%4}.mark="1"
uci set network.lan_vpn${IPV%4}.lookup="2"
uci set network.lan_vpn${IPV%4}.priority="30000"
done
uci commit firewall
uci commit network
service firewall restart
service network restart
```

### Route LAN to VPN with WAN port forwarding

Route all traffic to VPN except a webserver running in LAN and serving to WAN. Mark the webserver traffic with firewall to apply custom routing.

```
uci -q delete firewall.lan_web
uci set firewall.lan_web="rule"
uci set firewall.lan_web.name="Mark-HTTPS"
uci set firewall.lan_web.src="lan"
uci set firewall.lan_web.src_mac="00:11:22:33:44:55"
uci set firewall.lan_web.src_port="443"
uci set firewall.lan_web.dest="*"
uci set firewall.lan_web.proto="tcp"
uci set firewall.lan_web.set_mark="0x1"
uci set firewall.lan_web.target="MARK"
for IPV in 4 6
do
uci set network.lan.ip${IPV}table="1"
uci set network.wan${IPV%4}.ip${IPV}table="2"
uci -q delete network.lan_web${IPV%4}
uci set network.lan_web${IPV%4}="rule${IPV%4}"
uci set network.lan_web${IPV%4}.in="lan"
uci set network.lan_web${IPV%4}.mark="1"
uci set network.lan_web${IPV%4}.lookup="2"
uci set network.lan_web${IPV%4}.priority="30000"
done
uci commit firewall
uci commit network
service firewall restart
service network restart
```

### Route LAN to OpenVPN

Prioritize routing LAN to OpenVPN. Be sure to [declare VPN interface](/docs/guide-user/services/vpn/openvpn/extras#network_interface "docs:guide-user:services:vpn:openvpn:extras") and [disable gateway redirection](/docs/guide-user/services/vpn/openvpn/extras#default_gateway "docs:guide-user:services:vpn:openvpn:extras").

```
for IPV in 4 6
do
uci set network.lan.ip${IPV}table="1"
uci set network.vpn.ip${IPV}table="2"
uci -q delete network.vpn_rt${IPV%4}
uci set network.vpn_rt${IPV%4}="route${IPV%4}"
uci set network.vpn_rt${IPV%4}.interface="vpn"
uci -q delete network.lan_vpn${IPV%4}
uci set network.lan_vpn${IPV%4}="rule${IPV%4}"
uci set network.lan_vpn${IPV%4}.in="lan"
uci set network.lan_vpn${IPV%4}.lookup="2"
uci set network.lan_vpn${IPV%4}.priority="30000"
done
uci set network.vpn_rt.target="0.0.0.0/0"
uci set network.vpn_rt6.target="::/0"
uci commit network
service network restart
```

### Route LAN to Tailscale

Prioritize routing LAN to Tailscale. Override the built-in rules generated by Tailscale.

```
for IPV in 4 6
do
uci set network.lan.ip${IPV}table="1"
uci -q delete network.lan_vpn${IPV%4}
uci set network.lan_vpn${IPV%4}="rule"
uci set network.lan_vpn${IPV%4}.in="lan"
uci set network.lan_vpn${IPV%4}.lookup="52"
uci set network.lan_vpn${IPV%4}.priority="30000"
uci -q delete network.pbr${IPV%4}
uci set network.pbr${IPV%4}="rule"
uci set network.pbr${IPV%4}.goto="10000"
uci set network.pbr${IPV%4}.priority="1"
done
uci commit network
service network restart
```

### Prohibitive routes

Create prohibitive routes in the target routing table. Assuming the loopback interface is always up and the default route has a lower metric.

```
for IPV in 4 6
do
uci set network.vpn.ip${IPV}table="2"
uci -q delete network.vpn_ks${IPV%4}
uci set network.vpn_ks${IPV%4}="route${IPV%4}"
uci set network.vpn_ks${IPV%4}.interface="loopback"
uci set network.vpn_ks${IPV%4}.type="prohibit"
uci set network.vpn_ks${IPV%4}.metric="9000"
uci set network.vpn_ks${IPV%4}.table="2"
done
uci set network.vpn_ks.target="0.0.0.0/0"
uci set network.vpn_ks6.target="::/0"
uci commit network
service network restart
```

### Prohibitive rules

Create prohibitive rules overriding the default ones. Prioritize custom rules to override the prohibitive ones.

```
for IPV in 4 6
do
uci -q delete network.lan_ks${IPV%4}
uci set network.lan_ks${IPV%4}="rule${IPV%4}"
uci set network.lan_ks${IPV%4}.in="lan"
uci set network.lan_ks${IPV%4}.action="prohibit"
uci set network.lan_ks${IPV%4}.priority="32000"
done
uci commit network
service network restart
```
