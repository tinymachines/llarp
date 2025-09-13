# DoH/DoH3, DoT, DoQ and DNSCrypt with Dnsmasq and dnsproxy

This article relies on the following:

- Accessing [web interface](/docs/guide-quick-start/walkthrough_login "docs:guide-quick-start:walkthrough_login") / [command-line interface](/docs/guide-quick-start/sshadministration "docs:guide-quick-start:sshadministration")
- Managing [configs](/docs/guide-user/base-system/uci "docs:guide-user:base-system:uci") / [packages](/docs/guide-user/additional-software/managing_packages "docs:guide-user:additional-software:managing_packages") / [services](/docs/guide-user/base-system/managing_services "docs:guide-user:base-system:managing_services") / [logs](/docs/guide-user/base-system/log.essentials "docs:guide-user:base-system:log.essentials")

## Introduction

- This how-to describes the method for setting up [DNS over HTTPS](https://en.wikipedia.org/wiki/DNS_over_HTTPS "https://en.wikipedia.org/wiki/DNS_over_HTTPS"), [DNS over HTTP/3](https://en.wikipedia.org/wiki/HTTP/3 "https://en.wikipedia.org/wiki/HTTP/3"), [DNS over TLS](https://en.wikipedia.org/wiki/DNS_over_TLS "https://en.wikipedia.org/wiki/DNS_over_TLS"), [DNS over QUIC](https://en.wikipedia.org/wiki/QUIC "https://en.wikipedia.org/wiki/QUIC") and [DNSCrypt](https://en.wikipedia.org/wiki/DNSCrypt "https://en.wikipedia.org/wiki/DNSCrypt") on OpenWrt.
- It relies on [Dnsmasq](/docs/guide-user/base-system/dhcp.dnsmasq "docs:guide-user:base-system:dhcp.dnsmasq") and [dnsproxy](/packages/pkgdata/dnsproxy "packages:pkgdata:dnsproxy") for resource efficiency and performance.
- Follow [DNS hijacking](/docs/guide-user/firewall/fw3_configurations/intercept_dns "docs:guide-user:firewall:fw3_configurations:intercept_dns") to intercept DNS traffic or use [VPN](/docs/guide-user/services/vpn/start "docs:guide-user:services:vpn:start") to protect all traffic.

## Goals

- Encrypt your DNS traffic improving security and privacy.
  
  - Prevent DNS leaks and DNS hijacking.
- Bypass regional restrictions using public DNS providers.
  
  - Escape DNS-based content filters and internet censorship.

## Command-line instructions

1\. Install the required packages:

```
opkg update
opkg install dnsproxy
```

2\. Enable DNS encryption:

```
# Configure dnsmasq
service dnsmasq stop
uci set dhcp.@dnsmasq[0].noresolv="1"
uci set dhcp.@dnsmasq[0].cachesize="10000"
uci set dhcp.@dnsmasq[0].min_cache_ttl="3600"
uci set dhcp.@dnsmasq[0].max_cache_ttl="86400"
uci -q del dhcp.@dnsmasq[0].server
uci add_list dhcp.@dnsmasq[0].server="127.0.0.1#5354"
uci add_list dhcp.@dnsmasq[0].server="::1#5354"
uci commit dhcp
service dnsmasq start
 
# Configure dnsproxy
uci set dnsproxy.global.enabled="1"
uci del dnsproxy.global.listen_port
uci add_list dnsproxy.global.listen_port="5354"
uci set dnsproxy.cache.enabled="0"  # "1" to enable (Enable this ONLY if you want to test "cache_optimistic" option)
uci set dnsproxy.cache.cache_optimistic="1"
uci set dnsproxy.cache.size="2097152"  # Equal to 2 MB (in binary)
uci del dnsproxy.servers.bootstrap
uci add_list dnsproxy.servers.bootstrap="8.8.8.8"
uci add_list dnsproxy.servers.bootstrap="tcp://8.8.8.8"
uci commit dnsproxy
service dnsproxy restart
```

3\. It is recommended to increase the maximum buffer size: [UDP Buffer Sizes](https://github.com/quic-go/quic-go/wiki/UDP-Buffer-Sizes "https://github.com/quic-go/quic-go/wiki/UDP-Buffer-Sizes")

```
cat << "EOF" > /etc/sysctl.d/12-buffer-size.conf
net.core.rmem_max=7500000
net.core.wmem_max=7500000
EOF
sysctl -p /etc/sysctl.d/12-buffer-size.conf
```

4\. Ensure NTP (Network Time Protocol) can work without DNS:

```
uci del system.ntp.server
uci add_list system.ntp.server="216.239.35.0"     # time.google.com
uci add_list system.ntp.server="216.239.35.4"     # time.google.com
uci add_list system.ntp.server="216.239.35.8"     # time.google.com
uci add_list system.ntp.server="216.239.35.12"    # time.google.com
uci add_list system.ntp.server="162.159.200.123"  # time.cloudflare.com
uci add_list system.ntp.server="162.159.200.1"    # time.cloudflare.com
uci commit system
service system restart
```

5\. Optional: [DNS hijacking](/docs/guide-user/firewall/fw3_configurations/intercept_dns#command-line_instructions "docs:guide-user:firewall:fw3_configurations:intercept_dns"): Configure firewall to intercept DNS traffic:

```
# Intercept DNS traffic
uci -q del firewall.dns_int
uci set firewall.dns_int="redirect"
uci set firewall.dns_int.name="Intercept-DNS"
uci set firewall.dns_int.family="any"
uci set firewall.dns_int.proto="tcp udp"
uci set firewall.dns_int.src="lan"
uci set firewall.dns_int.src_dport="53"
uci set firewall.dns_int.target="DNAT"
uci commit firewall
service firewall restart
```

LAN clients should use Dnsmasq as a primary resolver. Dnsmasq forwards DNS queries to dnsproxy which encrypts DNS traffic.

For documents, please see:

- [**Default "dnsproxy.config" file in OpenWrt**](https://github.com/openwrt/packages/blob/master/net/dnsproxy/files/dnsproxy.config "https://github.com/openwrt/packages/blob/master/net/dnsproxy/files/dnsproxy.config")
- [AdguardTeam/dnsproxy: Simple DNS proxy with DoH, DoT, DoQ and DNSCrypt support](https://github.com/AdguardTeam/dnsproxy#usage "https://github.com/AdguardTeam/dnsproxy#usage")
- [AdguardTeam/AdGuardHome: Configuring upstreams](https://github.com/AdguardTeam/AdGuardHome/wiki/Configuration#upstreams "https://github.com/AdguardTeam/AdGuardHome/wiki/Configuration#upstreams")
- [What is DNS over TLS (DoT), DNS over Quic (DoQ) and DNS over HTTPS (DoH &amp; DoH3)? - NextDNS Help Center](https://help.nextdns.io/t/x2hmvas/what-is-dns-over-tls-dot-dns-over-quic-doq-and-dns-over-https-doh-doh3 "https://help.nextdns.io/t/x2hmvas/what-is-dns-over-tls-dot-dns-over-quic-doq-and-dns-over-https-doh-doh3")

## Testing

Verify domain name resolution with [nslookup](http://man.cx/nslookup%281%29 "http://man.cx/nslookup%281%29"):

```
nslookup openwrt.org localhost
```

To check your DNS provider, you can use:

- [Cloudflare Test](https://one.one.one.one/help/ "https://one.one.one.one/help/")
- [AdGuard Test](https://adguard.com/en/test.html "https://adguard.com/en/test.html")
- [NextDNS Test](https://test.nextdns.io/ "https://test.nextdns.io/")
- [Mullvad Test](https://mullvad.net/en/check "https://mullvad.net/en/check")
- [Quad9 Test](https://on.quad9.net/ "https://on.quad9.net/")
- [OpenDNS Test](https://welcome.opendns.com/ "https://welcome.opendns.com/")
- [Cloudflare Browser Check](https://www.cloudflare.com/ssl/encrypted-sni/ "https://www.cloudflare.com/ssl/encrypted-sni/")

DNS Leak Test and DNSSEC Test:

- [DNS Leak Test #1](https://dnsleaktest.com/ "https://dnsleaktest.com/")
- [DNS Leak Test #2](https://dnscheck.tools/ "https://dnscheck.tools/")
- [DNSSEC Test #1](http://dnssec-or-not.com/ "http://dnssec-or-not.com/")
- [DNSSEC Test #2](https://wander.science/projects/dns/dnssec-resolver-test/ "https://wander.science/projects/dns/dnssec-resolver-test/")

Alternative test via CLI: * check connection to Quad9 DNS (it require to use Quad9 DNS servers):

```
dig +short txt proto.on.quad9.net.
# should print: doh. or dot.
```

\* check connection to NextDNS (it require to use NextDNS DNS servers):

```
curl -SL https://test.nextdns.io/
{
        "status": "ok",
        "protocol": "DOT",
        "profile": "SOMEPROFILE",
        "client": "80.XXX.XXX.XXX",
        "srcIP": "80.XXX.XXX.XXX",
        "destIP": "XX.XX.28.0",
        "anycast": true,
        "server": "zepto-ber-1",
        "clientName": "unknown-dot"
}
```

## Troubleshooting

Collect and analyze the following information.

```
# Set verbose mode
uci set dnsproxy.global.verbose="1"; uci commit dnsproxy
 
# Restart services
service log restart; service dnsmasq restart; service dnsproxy restart
 
# Log and status
logread -e dnsmasq; netstat -l -n -p | grep -e dnsmasq
logread -e dnsproxy; netstat -l -n -p | grep -e dnsproxy
 
# Runtime configuration
pgrep -f -a dnsmasq; pgrep -f -a dnsproxy
head -v -n -0 /etc/resolv.* /tmp/resolv.* /tmp/resolv.*/*
 
# Persistent configuration
uci show dhcp; uci show dnsproxy
```

## Extras

### Configure DNS provider

**dnsproxy** is configured with Cloudflare DNS by default. You can change it to Google DNS or any other [**Known DNS Providers**](https://adguard-dns.io/kb/general/dns-providers/ "https://adguard-dns.io/kb/general/dns-providers/") or [**DNS Stamp**](https://dnscrypt.info/public-servers "https://dnscrypt.info/public-servers") used for DNSCrypt. Use resolvers supporting DNSSEC validation if necessary. Specify several resolvers to improve fault tolerance.

```
Example with "AdGuard DNS (Default)"
 
# DNS over HTTPS (DoH)
uci del dnsproxy.servers.upstream
uci add_list dnsproxy.servers.upstream="https://dns.adguard-dns.com/dns-query"
uci commit dnsproxy
service dnsproxy restart
 
# DNS over HTTP/3 (DoH3)
uci del dnsproxy.servers.upstream
uci add_list dnsproxy.servers.upstream="h3://dns.adguard-dns.com/dns-query"
uci commit dnsproxy
service dnsproxy restart
 
# DNS over TLS (DoT)
uci del dnsproxy.servers.upstream
uci add_list dnsproxy.servers.upstream="tls://dns.adguard-dns.com"
uci commit dnsproxy
service dnsproxy restart
 
# DNS over QUIC (DoQ)
uci del dnsproxy.servers.upstream
uci add_list dnsproxy.servers.upstream="quic://dns.adguard-dns.com"
uci commit dnsproxy
service dnsproxy restart
 
# DNSCrypt ("DNS Stamp" of AdGuard DNS)
uci del dnsproxy.servers.upstream
uci add_list dnsproxy.servers.upstream="sdns://AQMAAAAAAAAAETk0LjE0MC4xNC4xNDo1NDQzINErR_JS3PLCu_iZEIbq95zkSV2LFsigxDIuUso_OQhzIjIuZG5zY3J5cHQuZGVmYXVsdC5uczEuYWRndWFyZC5jb20"
uci commit dnsproxy
service dnsproxy restart
 
# DNS over HTTPS ("DNS Stamp" of AdGuard DNS)
uci del dnsproxy.servers.upstream
uci add_list dnsproxy.servers.upstream="sdns://AgMAAAAAAAAADDk0LjE0MC4xNS4xNSCaOjT3J965vKUQA9nOnDn48n3ZxSQpAcK6saROY1oCGQw5NC4xNDAuMTUuMTUKL2Rucy1xdWVyeQ"
uci commit dnsproxy
service dnsproxy restart
```

### Web interface

If you want to manage the settings using web interface. Install the necessary packages. The package is not officially in OpenWrt, you need to download the package, upload and install it through the Luci interface (**System → Software → Upload Package...**):

- [https://github.com/muink/luci-app-dnsproxy](https://github.com/muink/luci-app-dnsproxy "https://github.com/muink/luci-app-dnsproxy")

Navigate to **LuCI → Services → DNS Proxy** to configure.

**Note:** I hope someone wants to become the maintainer of “[**luci-app-dnsproxy**](https://github.com/muink/luci-app-dnsproxy "https://github.com/muink/luci-app-dnsproxy")” package and make it an official OpenWrt package.
