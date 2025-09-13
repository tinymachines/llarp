# DoT with Dnsmasq and Stubby

This article relies on the following:

- Accessing [web interface](/docs/guide-quick-start/walkthrough_login "docs:guide-quick-start:walkthrough_login") / [command-line interface](/docs/guide-quick-start/sshadministration "docs:guide-quick-start:sshadministration")
- Managing [configs](/docs/guide-user/base-system/uci "docs:guide-user:base-system:uci") / [packages](/docs/guide-user/additional-software/managing_packages "docs:guide-user:additional-software:managing_packages") / [services](/docs/guide-user/base-system/managing_services "docs:guide-user:base-system:managing_services") / [logs](/docs/guide-user/base-system/log.essentials "docs:guide-user:base-system:log.essentials")

## Introduction

- This how-to describes the method for setting up [DNS over TLS](https://en.wikipedia.org/wiki/DNS_over_TLS "https://en.wikipedia.org/wiki/DNS_over_TLS") on OpenWrt.
- It relies on [Dnsmasq](/docs/guide-user/base-system/dhcp.dnsmasq "docs:guide-user:base-system:dhcp.dnsmasq") and [Stubby](/docs/guide-user/services/dns/stubby "docs:guide-user:services:dns:stubby") for resource efficiency and performance.
- Follow [DNS hijacking](/docs/guide-user/firewall/fw3_configurations/intercept_dns "docs:guide-user:firewall:fw3_configurations:intercept_dns") to intercept DNS traffic or use [VPN](/docs/guide-user/services/vpn/start "docs:guide-user:services:vpn:start") to protect all traffic.

## Goals

- Encrypt your DNS traffic improving security and privacy.
  
  - Prevent DNS leaks and DNS hijacking.
- Bypass regional restrictions using public DNS providers.
  
  - Escape DNS-based content filters and internet censorship.

## Luci web-interface Instructions

Navigate to System → Software. Tap 'Update Lists', and under 'Filter' enter 'stubby'. Tap the 'Install...' button. There is no Luci plug-in for Stubby. Fortunately, it requires very little effort to simply get it running.

Navigate to Network → Interfaces. Tap 'Edit' next to LAN. 'Advanced Settings', 'Use custom DNS servers': '127.0.0.1', tap '+', and add '0::1' as a second one. 'DNS Weight': '20'. 'Save'.

Tap 'Edit' next to WAN. *If you want the router itself to use alternate DNS, uncheck 'Use DNS servers advertised by peer', and put in e.g. '1.1.1.1'. Otherwise, leave this to resolve to your provider's DNS. Trying to resolve through stubby, before stubby is running properly during boot, can cause problems.* Set the 'DNS Weight' to some high number, low-priority, like '50'. 'Save'.

Tap 'Edit' next to WAN6. Do the same as for WAN, but since this is the IPv6 interface, use a DNS of e.g. '2606:4700:4700::1111', if not using the provider's DNS, and similar low-priority 'DNS Weight' of e.g. 55. 'Save'

Navigate to Network → DHCP and DNS → Forwards. 'DNS Forwards': '0::1#5453' tap '+' and add '127.0.0.1#5453', tap 'Save'. Go to the 'Resolve &amp; Host File' tab. Check 'Ignore resolv file' &amp; 'Strict order', 'Save'.

'Save &amp; Apply'. Stubby should be running now.

There are a few tweaks that can only be done by editing the /etc/config/stubby and /etc/config/dhcp. See below sections.

## Command-line instructions

1.) Install the required packages:

```
opkg update
opkg install stubby
```

2.) Enable DNS encryption:

```
service dnsmasq stop
uci set dhcp.@dnsmasq[0].noresolv="1"
uci -q delete dhcp.@dnsmasq[0].server
uci -q get stubby.global.listen_address \
| sed -e "s/\s/\n/g;s/@/#/g" \
| while read -r STUBBY_SERV
do uci add_list dhcp.@dnsmasq[0].server="${STUBBY_SERV}"
done
```

3.) Disable local use of dnsmasq/stubby: *It is not possible for Stubby to be UP during boot or just right after boot, without additional configuration, because of the race condition with SYSNTPd service. [race\_conditions\_with\_sysntpd](/docs/guide-user/base-system/dhcp_configuration#race_conditions_with_sysntpd "docs:guide-user:base-system:dhcp_configuration")*

```
uci set dhcp.@dnsmasq[0].localuse="0"
```

4.) Commit changes:

```
uci commit dhcp
service dnsmasq start
```

LAN clients should use Dnsmasq as a primary resolver. Dnsmasq forwards DNS queries to Stubby which encrypts DNS traffic.

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

## Alternate Testing sites

- [https://www.cloudflare.com/ssl/encrypted-sni/](https://www.cloudflare.com/ssl/encrypted-sni/ "https://www.cloudflare.com/ssl/encrypted-sni/")
- [https://1.1.1.1/help](https://1.1.1.1/help "https://1.1.1.1/help")

## Troubleshooting

Collect and analyze the following information.

```
# Restart services
service log restart; service dnsmasq restart; service stubby restart
 
# Log and status
logread -e dnsmasq; netstat -l -n -p | grep -e dnsmasq
logread -e stubby; netstat -l -n -p | grep -e stubby
 
# Runtime configuration
pgrep -f -a dnsmasq; pgrep -f -a stubby
head -v -n -0 /etc/resolv.* /tmp/resolv.* /tmp/resolv.*/*
 
# Persistent configuration
uci show dhcp; uci show stubby
```

## Extras

### DoT provider

Stubby is configured with Cloudflare DNS by default. You can change it to Google DNS or any other [DoT provider](https://en.wikipedia.org/wiki/Public_recursive_name_server "https://en.wikipedia.org/wiki/Public_recursive_name_server") including your own [DoT server with Nginx](/docs/guide-user/services/webserver/nginx#dns_over_tls "docs:guide-user:services:webserver:nginx"). Use resolvers supporting DNSSEC validation if necessary. Specify several resolvers to improve fault tolerance.

```
# Configure DoT provider
while uci -q delete stubby.@resolver[0]; do :; done
uci add stubby resolver
uci set stubby.@resolver[-1].address="2001:4860:4860::8888"
uci set stubby.@resolver[-1].tls_auth_name="dns.google"
uci add stubby resolver
uci set stubby.@resolver[-1].address="2001:4860:4860::8844"
uci set stubby.@resolver[-1].tls_auth_name="dns.google"
uci add stubby resolver
uci set stubby.@resolver[-1].address="8.8.8.8"
uci set stubby.@resolver[-1].tls_auth_name="dns.google"
uci add stubby resolver
uci set stubby.@resolver[-1].address="8.8.4.4"
uci set stubby.@resolver[-1].tls_auth_name="dns.google"
uci commit stubby
service stubby restart
```

### DNSSEC validation

Enforce [DNSSEC](https://en.wikipedia.org/wiki/Domain_Name_System_Security_Extensions "https://en.wikipedia.org/wiki/Domain_Name_System_Security_Extensions") validation if your DNS provider does not support it, or you want to perform the validation yourself. Beware of fault tolerance and performance issues.

```
uci set dhcp.@dnsmasq[0].proxydnssec="1"
uci commit dhcp
service dnsmasq restart
uci set stubby.global.appdata_dir="/tmp/stubby"
uci set stubby.global.dnssec_return_status="1"
uci commit stubby
service stubby restart
```
