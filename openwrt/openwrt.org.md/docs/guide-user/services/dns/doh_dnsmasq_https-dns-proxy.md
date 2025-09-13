# DoH with Dnsmasq and https-dns-proxy

This article relies on the following:

- Accessing [web interface](/docs/guide-quick-start/walkthrough_login "docs:guide-quick-start:walkthrough_login") / [command-line interface](/docs/guide-quick-start/sshadministration "docs:guide-quick-start:sshadministration")
- Managing [configs](/docs/guide-user/base-system/uci "docs:guide-user:base-system:uci") / [packages](/docs/guide-user/additional-software/managing_packages "docs:guide-user:additional-software:managing_packages") / [services](/docs/guide-user/base-system/managing_services "docs:guide-user:base-system:managing_services") / [logs](/docs/guide-user/base-system/log.essentials "docs:guide-user:base-system:log.essentials")

## Introduction

- This how-to describes the method for setting up [DNS over HTTPS](https://en.wikipedia.org/wiki/DNS_over_HTTPS "https://en.wikipedia.org/wiki/DNS_over_HTTPS") on OpenWrt.
- It relies on [Dnsmasq](/docs/guide-user/base-system/dhcp.dnsmasq "docs:guide-user:base-system:dhcp.dnsmasq") and [https-dns-proxy](/packages/pkgdata/https-dns-proxy "packages:pkgdata:https-dns-proxy") for masking DNS traffic as HTTPS traffic.
- Follow [DNS hijacking](/docs/guide-user/firewall/fw3_configurations/intercept_dns "docs:guide-user:firewall:fw3_configurations:intercept_dns") to intercept DNS traffic or use [VPN](/docs/guide-user/services/vpn/start "docs:guide-user:services:vpn:start") to protect all traffic.

## Goals

- Encrypt your DNS traffic improving security and privacy.
  
  - Prevent DNS leaks and DNS hijacking.
- Bypass regional restrictions using public DNS providers.
  
  - Escape DNS-based content filters and internet censorship.

## Command-line instructions

Install the required packages. DNS encryption should be enabled automatically.

```
# Install packages
opkg update
opkg install https-dns-proxy
```

LAN clients should use Dnsmasq as a primary resolver. Dnsmasq forwards DNS queries to https-dns-proxy which encrypts DNS traffic.

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
service log restart; service dnsmasq restart; service https-dns-proxy restart
 
# Log and status
logread -e dnsmasq; netstat -l -n -p | grep -e dnsmasq
logread -e https-dns; netstat -l -n -p | grep -e https-dns
 
# Runtime configuration
pgrep -f -a dnsmasq; pgrep -f -a https-dns
head -v -n -0 /etc/resolv.* /tmp/resolv.* /tmp/resolv.*/*
 
# Persistent configuration
uci show dhcp; uci show https-dns-proxy
```

### "Private DNS server cannot be accessed" on Android

When using a custom DNS server on your Android device in combination with https-dns-proxy on your router, you may be unable to connect to the Internet, resulting in an error message that reads: “Private DNS server cannot be accessed”. This is due to DNS forcing being enabled by default.

In order to fix this, run the following commands in an SSH session:

```
uci delete https-dns-proxy.config.force_dns
uci set https-dns-proxy.config.force_dns='0'
uci commit https-dns-proxy
service https-dns-proxy restart
```

Or, if you have the web interface installed, you can go to **LuCI → Services → HTTPS DNS Proxy** and change the “Force Router DNS” value to “Let local devices use their own DNS servers if set”. Then press “Save &amp; Apply”.

## Extras

### Web interface

If you want to manage the settings using web interface. Install the necessary packages.

```
# Install packages
opkg update
opkg install luci-app-https-dns-proxy
service rpcd restart
```

- Navigate to **LuCI → Network → DHCP and DNS** to configure Dnsmasq.
- Navigate to **LuCI → Services → HTTPS DNS Proxy** to configure https-dns-proxy.

### DoH provider

https-dns-proxy is configured with Google DNS and Cloudflare DNS by default. You can change it to Google DNS or any other [DoH provider](https://en.wikipedia.org/wiki/Public_recursive_name_server "https://en.wikipedia.org/wiki/Public_recursive_name_server"). Use resolvers supporting DNSSEC validation if necessary. Specify several resolvers to improve fault tolerance.

```
# Configure DoH provider
while uci -q delete https-dns-proxy.@https-dns-proxy[0]; do :; done
uci set https-dns-proxy.dns="https-dns-proxy"
uci set https-dns-proxy.dns.bootstrap_dns="8.8.8.8,8.8.4.4"
uci set https-dns-proxy.dns.resolver_url="https://dns.google/dns-query"
uci set https-dns-proxy.dns.listen_addr="127.0.0.1"
uci set https-dns-proxy.dns.listen_port="5053"
uci commit https-dns-proxy
service https-dns-proxy restart
```
