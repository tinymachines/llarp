# DNSCrypt with Dnsmasq and dnscrypt-proxy2

This article relies on the following:

- Accessing [web interface](/docs/guide-quick-start/walkthrough_login "docs:guide-quick-start:walkthrough_login") / [command-line interface](/docs/guide-quick-start/sshadministration "docs:guide-quick-start:sshadministration")
- Managing [configs](/docs/guide-user/base-system/uci "docs:guide-user:base-system:uci") / [packages](/docs/guide-user/additional-software/managing_packages "docs:guide-user:additional-software:managing_packages") / [services](/docs/guide-user/base-system/managing_services "docs:guide-user:base-system:managing_services") / [logs](/docs/guide-user/base-system/log.essentials "docs:guide-user:base-system:log.essentials")

## Introduction

- This how-to describes the method for setting up [DNSCrypt](https://en.wikipedia.org/wiki/DNSCrypt "https://en.wikipedia.org/wiki/DNSCrypt") on OpenWrt.
- It relies on [Dnsmasq](/docs/guide-user/base-system/dhcp.dnsmasq "docs:guide-user:base-system:dhcp.dnsmasq") and [dnscrypt-proxy2](/packages/pkgdata/dnscrypt-proxy2 "packages:pkgdata:dnscrypt-proxy2") that supports DNSCrypt v2, DNS over HTTPS and Anonymized DNSCrypt.
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
opkg install dnscrypt-proxy2
 
# Enable DNS encryption
service dnsmasq stop
uci set dhcp.@dnsmasq[0].noresolv="1"
uci set dhcp.@dnsmasq[0].cachesize='0'
uci -q delete dhcp.@dnsmasq[0].server
uci add_list dhcp.@dnsmasq[0].server="127.0.0.53"
sed -i "32 s/.*/server_names = ['google', 'cloudflare']/" /etc/dnscrypt-proxy2/*.toml
uci commit dhcp
service dnsmasq start
service dnscrypt-proxy restart
 
# Ensure, that the NTP server can work without DNS
uci del system.ntp.server
uci add_list system.ntp.server='194.177.4.1'    # 0.openwrt.pool.ntp.org
uci add_list system.ntp.server='213.222.217.11' # 1.openwrt.pool.ntp.org
uci add_list system.ntp.server='80.50.102.114'  # 2.openwrt.pool.ntp.org
uci add_list system.ntp.server='193.219.28.60'  # 3.openwrt.pool.ntp.org
uci commit system
```

LAN clients should use Dnsmasq as a primary resolver. Dnsmasq forwards DNS queries to dnscrypt-proxy2 which encrypts DNS traffic.

Note: These are the recommended options from the [official DNSCrypt guide for OpenWrt on GitHub](https://github.com/DNSCrypt/dnscrypt-proxy/wiki/Installation-on-OpenWrt#recommended-tweaks "https://github.com/DNSCrypt/dnscrypt-proxy/wiki/Installation-on-OpenWrt#recommended-tweaks").

Note: Beware that the distributed configuration includes an activated `block-names.txt`. If you experience problems with some names, match them against this file first.

Optional steps suggested by the [official DNSCrypt guide for OpenWrt on GitHub](https://github.com/DNSCrypt/dnscrypt-proxy/wiki/Installation-on-OpenWrt#recommended-tweaks "https://github.com/DNSCrypt/dnscrypt-proxy/wiki/Installation-on-OpenWrt#recommended-tweaks"):

```
# Optional: Enable printing logs in syslog
sed -i "183 s/.*/use_syslog = true/" /etc/dnscrypt-proxy2/*.toml
service dnscrypt-proxy restart

# Optional: Disable ISP's DNS server
uci set network.wan.peerdns='0'
uci set network.wan6.peerdns='0'
uci commit network

# Optional: Force LAN clients to send DNS queries to dnscrypt-proxy:
## 1. Divert-DNS, port 53
uci add firewall redirect
uci set firewall.@redirect[-1].dest='lan'
uci set firewall.@redirect[-1].target='DNAT'
uci set firewall.@redirect[-1].name='Divert-DNS, port 53'
uci set firewall.@redirect[-1].src='wan'
uci set firewall.@redirect[-1].src_dport='53'
uci set firewall.@redirect[-1].dest_port='53'
uci commit firewall

## 2. Block DNS-over-TLS over port 853
uci add firewall rule
uci set firewall.@rule[-1].name='Reject-DoT,port 853'
uci add_list firewall.@rule[-1].proto='tcp'
uci set firewall.@rule[-1].src='lan'
uci set firewall.@rule[-1].dest='wan'
uci set firewall.@rule[-1].dest_port='853'
uci set firewall.@rule[-1].target='REJECT'
uci commit firewall

## 3. Optional: Redirect queries for DNS servers running on non-standard ports. For example: 5353
## Warning: don't use this one if you run an mDNS server
uci add firewall redirect
uci set firewall.@redirect[-1].dest='lan'
uci set firewall.@redirect[-1].target='DNAT'
uci set firewall.@redirect[-1].name='Divert-DNS, port 5353'
uci set firewall.@redirect[-1].src='lan'
uci set firewall.@redirect[-1].src_dport='5353'
uci set firewall.@redirect[-1].dest_port='53'
uci commit firewall

# Remember to reload firewall
/etc/init.d/firewall reload
```

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
uci show dhcp; grep -v -e "^\s*#" -e "^\s*$" /etc/dnscrypt-proxy2/dnscrypt-proxy.toml
```

## Extras

### DoH and DNSCrypt provider

**dnscrypt-proxy2** is configured with Google DNS and Cloudflare DNS by default. You can change it to Google DNS or any other [DoH or DNSCrypt provider](https://dnscrypt.info/public-servers "https://dnscrypt.info/public-servers"). Use resolvers supporting DNSSEC validation if necessary. Specify several resolvers to improve fault tolerance.

```
# Configure DoH or DNSCrypt provider
# First, we need to set up a list of servers to use, example: (you have to change "exampledns" for the name of the DNS provider)
sed -i "32 s/.*/server_names = ['exampledns', 'exampledns2']/" /etc/dnscrypt-proxy2/*.toml
service dnscrypt-proxy restart
 
# Or you can also use only one server, example:
sed -i "32 s/.*/server_names = ['cloudflare']/" /etc/dnscrypt-proxy2/*.toml
service dnscrypt-proxy restart
```

### ODoH protocol

[**ODoH (Oblivious DNS-over-HTTPS)**](https://github.com/DNSCrypt/dnscrypt-proxy/wiki/Oblivious-DoH "https://github.com/DNSCrypt/dnscrypt-proxy/wiki/Oblivious-DoH") prevents servers from learning anything about client IP addresses, by using intermediate **relays** dedicated to forwarding encrypted DNS data. Instead of directly sending a query to a target DoH server, the client encrypts it for that server, but sends it to a **relay**. An **ODoH relay** can only communicate with an **ODoH server** and an **ODoH client**. **Relays** can't get responses from a **generic DoH server** that doesn't support **ODoH**. You can change the [ODoH servers](https://github.com/DNSCrypt/dnscrypt-resolvers/blob/master/v3/odoh-servers.md "https://github.com/DNSCrypt/dnscrypt-resolvers/blob/master/v3/odoh-servers.md") and [ODoH relays](https://github.com/DNSCrypt/dnscrypt-resolvers/blob/master/v3/odoh-relays.md "https://github.com/DNSCrypt/dnscrypt-resolvers/blob/master/v3/odoh-relays.md") to any other.

```
# Enable ODoH on dnscrypt-proxy2
sed -i -e "s/.*odoh_servers.*/odoh_servers = true/; 689,700 s/#//" /etc/dnscrypt-proxy2/*.toml
 
# Configure "ODoH servers" and "ODoH relays"
odoh_servers="['odoh-cloudflare', 'odoh-crypto-sx']"
odoh_relays="['odohrelay-crypto-sx', 'odohrelay-koki-bcn']"
sed -i -e "32 s/.*/server_names = $odoh_servers/; 795 s/.*/routes = [/; 797 s/.*/    { server_name='*', via=$odoh_relays }/; 798 s/.*/]/" /etc/dnscrypt-proxy2/*.toml
service dnscrypt-proxy restart
```

More information about **ODoH protocol**: [Improving DNS Privacy with Oblivious DoH in 1.1.1.1](https://blog.cloudflare.com/oblivious-dns/ "https://blog.cloudflare.com/oblivious-dns/")

Caveats: The **Oblivious DNS-over-HTTPS** protocol is still a work in progress. Servers and relays may not be very stable.
