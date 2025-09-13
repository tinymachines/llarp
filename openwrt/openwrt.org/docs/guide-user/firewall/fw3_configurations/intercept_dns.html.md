# DNS hijacking

This article relies on the following:

- Accessing [web interface](/docs/guide-quick-start/walkthrough_login "docs:guide-quick-start:walkthrough_login") / [command-line interface](/docs/guide-quick-start/sshadministration "docs:guide-quick-start:sshadministration")
- Managing [configs](/docs/guide-user/base-system/uci "docs:guide-user:base-system:uci") / [packages](/docs/guide-user/additional-software/managing_packages "docs:guide-user:additional-software:managing_packages") / [services](/docs/guide-user/base-system/managing_services "docs:guide-user:base-system:managing_services") / [logs](/docs/guide-user/base-system/log.essentials "docs:guide-user:base-system:log.essentials")

## Introduction

- This how-to describes the method for intercepting DNS traffic on OpenWrt.
- You can combine it with [VPN](/docs/guide-user/services/vpn/start "docs:guide-user:services:vpn:start") or [DNS encryption](/docs/guide-user/services/dns/start#encryption "docs:guide-user:services:dns:start") to protect DNS traffic.

## Goals

- Override preconfigured DNS provider for LAN clients.
  
  - Prevent DNS leaks for LAN clients when using VPN or DNS encryption.

## Web interface instructions

Configure firewall to intercept DNS traffic.

1. Navigate to **LuCI → Network → Firewall → Port Forwards**.
2. Click **Add** and specify:
   
   - Name: `Intercept-DNS`
   - Restrict to address family: IPv4 and IPv6
   - Protocol: TCP, UDP
   - Source zone: `lan`
   - External port: `53`
   - Destination zone: unspecified
   - Internal IP address: any
   - Internal port: any
3. Click **Save**, then **Save &amp; Apply**.

## Command-line instructions

Configure firewall to intercept DNS traffic.

```
# Intercept DNS traffic
uci -q del firewall.dns_int
uci set firewall.dns_int="redirect"
uci set firewall.dns_int.name="Intercept-DNS"
uci set firewall.dns_int.family="any"
uci set firewall.dns_int.proto="tcp udp"
uci set firewall.dns_int.src="lan"
uci set firewall.dns_int.src_dport="53"
uci set firewall.dns_int.dest_port="53"
uci set firewall.dns_int.target="DNAT"
uci commit firewall
service firewall restart
```

## Testing

Configure different [DNS providers](https://en.wikipedia.org/wiki/Public_recursive_name_server "https://en.wikipedia.org/wiki/Public_recursive_name_server") on the client and router. Verify the identified DNS provider only matches the router.

- [dnsleaktest.com](https://www.dnsleaktest.com/ "https://www.dnsleaktest.com/")

## Troubleshooting

Collect and analyze the following information.

```
# Log and status
service firewall restart
 
# Runtime configuration
nft list ruleset
 
# Persistent configuration
uci show firewall
```

## Extras

### DNS over HTTPS

Utilize banIP to [filter DoH](/docs/guide-user/services/banip#blocking_doh "docs:guide-user:services:banip") traffic forcing LAN clients to switch to plain DNS.

### DNS over TLS

Configure firewall to filter DoT traffic forcing LAN clients to switch to plain DNS.

```
# Filter DoT traffic
uci -q delete firewall.dot_fwd
uci set firewall.dot_fwd="rule"
uci set firewall.dot_fwd.name="Deny-DoT"
uci set firewall.dot_fwd.src="lan"
uci set firewall.dot_fwd.dest="wan"
uci set firewall.dot_fwd.dest_port="853"
uci set firewall.dot_fwd.proto="tcp udp"
uci set firewall.dot_fwd.target="REJECT"
uci commit firewall
service firewall restart
```

### DNS forwarding

Set up [DNS forwarding](/docs/guide-user/base-system/dhcp_configuration#dns_forwarding "docs:guide-user:base-system:dhcp_configuration") to your local DNS server with Dnsmasq. Assuming the local DNS server is in the same subnet. Configure firewall to avoid looping.

```
# Configure firewall
uci set firewall.dns_int.src_mac="!11:22:33:44:55:66"
uci commit firewall
service firewall restart
```

### DNS redirection

Avoid using Dnsmasq. Configure firewall to redirect DNS traffic to your local DNS server. Move the local DNS server to a separate subnet to avoid masquerading.

```
# Configure firewall
uci set firewall.dns_int.name="Redirect-DNS"
uci set firewall.dns_int.family='ipv4'
uci set firewall.dns_int.dest_ip="192.168.2.2"
uci set firewall.dns_int.src_ip='!192.168.2.2'
uci commit firewall
service firewall restart
 
# Configure network
uci add_list network.lan.ipaddr="192.168.2.1/24"
uci commit network
service network restart
```
