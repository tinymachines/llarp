# DNSCrypt with Dnsmasq and dnscrypt-proxy

This article relies on the following:

- Accessing [web interface](/docs/guide-quick-start/walkthrough_login "docs:guide-quick-start:walkthrough_login") / [command-line interface](/docs/guide-quick-start/sshadministration "docs:guide-quick-start:sshadministration")
- Managing [configs](/docs/guide-user/base-system/uci "docs:guide-user:base-system:uci") / [packages](/docs/guide-user/additional-software/managing_packages "docs:guide-user:additional-software:managing_packages") / [services](/docs/guide-user/base-system/managing_services "docs:guide-user:base-system:managing_services") / [logs](/docs/guide-user/base-system/log.essentials "docs:guide-user:base-system:log.essentials")

## Introduction

- This how-to describes the method for setting up [DNSCrypt](https://en.wikipedia.org/wiki/DNSCrypt "https://en.wikipedia.org/wiki/DNSCrypt") on OpenWrt.
- It relies on [Dnsmasq](/docs/guide-user/base-system/dhcp.dnsmasq "docs:guide-user:base-system:dhcp.dnsmasq") and [dnscrypt-proxy](/docs/guide-user/services/dns/dnscrypt-proxy "docs:guide-user:services:dns:dnscrypt-proxy") for resource efficiency.
- Follow [DNS hijacking](/docs/guide-user/firewall/fw3_configurations/intercept_dns "docs:guide-user:firewall:fw3_configurations:intercept_dns") to intercept DNS traffic or use [VPN](/docs/guide-user/services/vpn/start "docs:guide-user:services:vpn:start") to protect all traffic.

## Goals

- Encrypt your DNS traffic improving security and privacy.
  
  - Prevent DNS leaks and DNS hijacking.
- Bypass regional restrictions using public DNS providers.
  
  - Escape DNS-based content filters and internet censorship.

## Command-line instructions

Install the required packages. Enable DNS encryption.

```
# Install packages
opkg update
opkg install dnscrypt-proxy
 
# Configure DNSCrypt provider
uci set dnscrypt-proxy.@dnscrypt-proxy[0].resolver="adguard-dns"
uci set dnscrypt-proxy.@dnscrypt-proxy[0].address="127.0.0.1"
uci set dnscrypt-proxy.@dnscrypt-proxy[0].port="5253"
uci commit dnscrypt-proxy
service dnscrypt-proxy restart
 
# Enable DNS encryption
service dnsmasq stop
uci set dhcp.@dnsmasq[0].noresolv="1"
uci -q delete dhcp.@dnsmasq[0].server
DNSCRYPT_ADDR="$(uci -q get dnscrypt-proxy.@dnscrypt-proxy[0].address)"
DNSCRYPT_PORT="$(uci -q get dnscrypt-proxy.@dnscrypt-proxy[0].port)"
DNSCRYPT_SERV="${DNSCRYPT_ADDR//[][]/}#${DNSCRYPT_PORT}"
uci add_list dhcp.@dnsmasq[0].server="${DNSCRYPT_SERV}"
uci commit dhcp
service dnsmasq start
```

LAN clients should use Dnsmasq as a primary resolver. Dnsmasq forwards DNS queries to dnscrypt-proxy which encrypts DNS traffic.

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
# Restart services
service log restart; service dnsmasq restart; service dnscrypt-proxy restart
 
# Log and status
logread -e dnsmasq; netstat -l -n -p | grep -e dnsmasq
logread -e dnscrypt-proxy; netstat -l -n -p | grep -e dnscrypt-proxy
 
# Runtime configuration
pgrep -f -a dnsmasq; pgrep -f -a dnscrypt-proxy
head -v -n -0 /etc/resolv.* /tmp/resolv.* /tmp/resolv.*/*
 
# Persistent configuration
uci show dhcp; uci show dnscrypt-proxy
```

## Extras

### Web interface

If you want to manage the settings using web interface. Install the necessary packages.

```
# Install packages
opkg update
opkg install luci-app-dnscrypt-proxy
service rpcd restart
```

- Navigate to **LuCI → Network → DHCP and DNS** to configure Dnsmasq.
- Navigate to **LuCI → Services → DNSCrypt-Proxy** to configure dnscrypt-proxy.

### DNSCrypt provider

dnscrypt-proxy is configured with AdGuard DNS. You can change it to DNSCrypt.eu or any other [DNSCrypt provider](https://github.com/openwrt/packages/blob/master/net/dnscrypt-proxy/files/dnscrypt-resolvers.csv "https://github.com/openwrt/packages/blob/master/net/dnscrypt-proxy/files/dnscrypt-resolvers.csv"). Use resolvers supporting DNSSEC validation if necessary. Specify several resolvers to improve fault tolerance.

```
# Configure DNSCrypt provider
while uci -q delete dnscrypt-proxy.@dnscrypt-proxy[0]; do :; done
uci set dnscrypt-proxy.dns6a="dnscrypt-proxy"
uci set dnscrypt-proxy.dns6a.resolver="dnscrypt.eu-dk-ipv6"
uci set dnscrypt-proxy.dns6a.address="[::1]"
uci set dnscrypt-proxy.dns6a.port="5253"
uci set dnscrypt-proxy.dns6b="dnscrypt-proxy"
uci set dnscrypt-proxy.dns6b.resolver="dnscrypt.eu-nl-ipv6"
uci set dnscrypt-proxy.dns6b.address="[::1]"
uci set dnscrypt-proxy.dns6b.port="5254"
uci set dnscrypt-proxy.dnsa="dnscrypt-proxy"
uci set dnscrypt-proxy.dnsa.resolver="dnscrypt.eu-dk"
uci set dnscrypt-proxy.dnsa.address="127.0.0.1"
uci set dnscrypt-proxy.dnsa.port="5255"
uci set dnscrypt-proxy.dnsb="dnscrypt-proxy"
uci set dnscrypt-proxy.dnsb.resolver="dnscrypt.eu-nl"
uci set dnscrypt-proxy.dnsb.address="127.0.0.1"
uci set dnscrypt-proxy.dnsb.port="5256"
uci commit dnscrypt-proxy
service dnscrypt-proxy restart
 
uci -q delete dhcp.@dnsmasq[0].server
while
DNSCRYPT_ADDR="$(uci -q get dnscrypt-proxy.@dnscrypt-proxy[0].address)"
DNSCRYPT_PORT="$(uci -q get dnscrypt-proxy.@dnscrypt-proxy[0].port)"
DNSCRYPT_SERV="${DNSCRYPT_ADDR//[][]/}#${DNSCRYPT_PORT}"
uci -q delete dnscrypt-proxy.@dnscrypt-proxy[0]
do uci add_list dhcp.@dnsmasq[0].server="${DNSCRYPT_SERV}"
done
uci revert dnscrypt-proxy
uci commit dhcp
service dnsmasq restart
```
