# Tor client

This article relies on the following:

- Accessing [web interface](/docs/guide-quick-start/walkthrough_login "docs:guide-quick-start:walkthrough_login") / [command-line interface](/docs/guide-quick-start/sshadministration "docs:guide-quick-start:sshadministration")
- Managing [configs](/docs/guide-user/base-system/uci "docs:guide-user:base-system:uci") / [packages](/docs/guide-user/additional-software/managing_packages "docs:guide-user:additional-software:managing_packages") / [services](/docs/guide-user/base-system/managing_services "docs:guide-user:base-system:managing_services") / [logs](/docs/guide-user/base-system/log.essentials "docs:guide-user:base-system:log.essentials")

## Introduction

- This how-to describes the method for setting up [Tor](https://en.wikipedia.org/wiki/Tor_%28anonymity_network%29 "https://en.wikipedia.org/wiki/Tor_(anonymity_network)") client on OpenWrt.
- Tor is limited to DNS and TCP traffic, use [VPN](/docs/guide-user/services/vpn/start "docs:guide-user:services:vpn:start") to protect all traffic.
- Follow [Tor extras](/docs/guide-user/services/tor/extras "docs:guide-user:services:tor:extras") for automated setup and additional tuning.

## Goals

- Provide anonymous communication with onion routing.
  
  - Access the dark net and Tor hidden services.
- Encrypt your internet connection to enforce security and privacy.
  
  - Prevent traffic leaks and spoofing on the client side.
- Bypass regional restrictions using public relay providers.
  
  - Escape client side content filters and internet censorship.

## Command-line instructions

### 1. Tor client

Install the required packages. Configure Tor client.

```
# Install packages
opkg update
opkg install tor
 
# Configure Tor client
cat << EOF > /etc/tor/custom
AutomapHostsOnResolve 1
AutomapHostsSuffixes .
VirtualAddrNetworkIPv4 172.16.0.0/12
VirtualAddrNetworkIPv6 [fc00::]/8
DNSPort 0.0.0.0:9053
DNSPort [::]:9053
TransPort 0.0.0.0:9040
TransPort [::]:9040
EOF
cat << EOF >> /etc/sysupgrade.conf
/etc/tor
EOF
uci del_list tor.conf.tail_include="/etc/tor/custom"
uci add_list tor.conf.tail_include="/etc/tor/custom"
uci commit tor
service tor restart
```

Disable [IPv6 GUA prefix](/docs/guide-user/network/ipv6/ipv6_extras#disabling_gua_prefix "docs:guide-user:network:ipv6:ipv6_extras") and announce [IPv6 default route](/docs/guide-user/network/ipv6/ipv6_extras#announcing_ipv6_default_route "docs:guide-user:network:ipv6:ipv6_extras").

### 2. DNS over Tor

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

Redirect DNS traffic to Tor and prevent DNS leaks.

```
# Enable DNS over Tor
service dnsmasq stop
uci set dhcp.@dnsmasq[0].localuse="0"
uci set dhcp.@dnsmasq[0].noresolv="1"
uci set dhcp.@dnsmasq[0].rebind_protection="0"
uci -q delete dhcp.@dnsmasq[0].server
uci add_list dhcp.@dnsmasq[0].server="127.0.0.1#9053"
uci add_list dhcp.@dnsmasq[0].server="::1#9053"
uci commit dhcp
service dnsmasq start
```

### 3. Firewall

Configure firewall to intercept LAN traffic. Disable LAN to WAN forwarding to prevent traffic leaks.

```
# Intercept TCP traffic
cat << "EOF" > /etc/nftables.d/tor.sh
TOR_CHAIN="dstnat_$(uci -q get firewall.tcp_int.src)"
TOR_RULE="$(nft -a list chain inet fw4 ${TOR_CHAIN} \
| sed -n -e "/Intercept-TCP/p")"
nft replace rule inet fw4 ${TOR_CHAIN} \
handle ${TOR_RULE##* } \
fib daddr type != { local, broadcast } ${TOR_RULE}
EOF
uci -q delete firewall.tor_nft
uci set firewall.tor_nft="include"
uci set firewall.tor_nft.path="/etc/nftables.d/tor.sh"
uci -q delete firewall.tcp_int
uci set firewall.tcp_int="redirect"
uci set firewall.tcp_int.name="Intercept-TCP"
uci set firewall.tcp_int.src="lan"
uci set firewall.tcp_int.src_dport="0-65535"
uci set firewall.tcp_int.dest_port="9040"
uci set firewall.tcp_int.proto="tcp"
uci set firewall.tcp_int.family="any"
uci set firewall.tcp_int.target="DNAT"
 
# Disable LAN to WAN forwarding
uci -q delete firewall.@forwarding[0]
uci commit firewall
service firewall restart
```

## Testing

Verify that you are using Tor.

- [check.torproject.org](https://check.torproject.org/ "https://check.torproject.org/")

Check your IP and DNS provider.

- [ipleak.net](https://ipleak.net/ "https://ipleak.net/")
- [dnsleaktest.com](https://www.dnsleaktest.com/ "https://www.dnsleaktest.com/")

## Troubleshooting

Collect and analyze the following information.

```
# Restart services
service log restart; service firewall restart; service tor restart
 
# Log and status
logread -e Tor; netstat -l -n -p | grep -e tor
 
# Runtime configuration
pgrep -f -a tor
nft list ruleset
 
# Persistent configuration
uci show firewall; uci show tor; grep -v -r -e "^#" -e "^$" /etc/tor
```
