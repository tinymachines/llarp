# DoT with Unbound

This article relies on the following:

- Accessing [web interface](/docs/guide-quick-start/walkthrough_login "docs:guide-quick-start:walkthrough_login") / [command-line interface](/docs/guide-quick-start/sshadministration "docs:guide-quick-start:sshadministration")
- Managing [configs](/docs/guide-user/base-system/uci "docs:guide-user:base-system:uci") / [packages](/docs/guide-user/additional-software/managing_packages "docs:guide-user:additional-software:managing_packages") / [services](/docs/guide-user/base-system/managing_services "docs:guide-user:base-system:managing_services") / [logs](/docs/guide-user/base-system/log.essentials "docs:guide-user:base-system:log.essentials")

## Introduction

- This how-to describes the method for setting up [DNS over TLS](https://en.wikipedia.org/wiki/DNS_over_TLS "https://en.wikipedia.org/wiki/DNS_over_TLS") on OpenWrt.
- It relies on [Unbound](/docs/guide-user/services/dns/unbound "docs:guide-user:services:dns:unbound") for performance and fault tolerance.
- Follow [DNS hijacking](/docs/guide-user/firewall/fw3_configurations/intercept_dns "docs:guide-user:firewall:fw3_configurations:intercept_dns") to intercept DNS traffic or use [VPN](/docs/guide-user/services/vpn/start "docs:guide-user:services:vpn:start") to protect all traffic.

## Goals

- Encrypt your DNS traffic improving security and privacy.
  
  - Prevent DNS leaks and DNS hijacking.
- Bypass regional restrictions using public DNS providers.
  
  - Escape DNS-based content filters and internet censorship.

## Command-line instructions

[Disable](/docs/guide-user/base-system/dhcp_configuration#disabling_dns_role "docs:guide-user:base-system:dhcp_configuration") Dnsmasq DNS role or remove it completely optionally [replacing](/docs/guide-user/base-system/dhcp_configuration#replacing_dnsmasq_with_odhcpd_and_unbound "docs:guide-user:base-system:dhcp_configuration") its DHCP role with odhcpd.

Install the required packages. Enable DNS encryption.

```
# Install packages
opkg update
opkg install unbound-daemon
 
# Enable DNS encryption
uci set unbound.fwd_google.enabled="1"
uci set unbound.fwd_google.fallback="0"
uci commit unbound
service unbound restart
```

LAN clients and local system should use Unbound as a primary resolver assuming that Dnsmasq is disabled.

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
service log restart; service unbound restart
 
# Log and status
logread -e unbound; netstat -l -n -p | grep -e unbound
 
# Runtime configuration
pgrep -f -a unbound
head -v -n -0 /etc/resolv.* /tmp/resolv.* /tmp/resolv.*/*
 
# Persistent configuration
uci show unbound
```

## Extras

### Web interface

If you want to manage the settings using web interface. Install the necessary packages.

```
# Install packages
opkg update
opkg install luci-app-unbound
service rpcd restart
```

Navigate to **LuCI → Services → Recursive DNS** to configure Unbound.

### DoT provider

Unbound is configured with Google DNS. You can change it to Cloudflare DNS or any other [DoT provider](https://en.wikipedia.org/wiki/Public_recursive_name_server "https://en.wikipedia.org/wiki/Public_recursive_name_server") including your own [DoT server with Nginx](/docs/guide-user/services/webserver/nginx#dns_over_tls "docs:guide-user:services:webserver:nginx"). Use resolvers supporting DNSSEC validation if necessary. Specify several resolvers to improve fault tolerance.

Change to Cloudflare DNS

```
# Configure DoT provider
uci set unbound.fwd_google.enabled="0"
uci set unbound.fwd_cloudflare.enabled="1"
uci set unbound.fwd_cloudflare.fallback="0"
uci commit unbound
service unbound restart
```

Change to other [DoT provider](https://en.wikipedia.org/wiki/Public_recursive_name_server "https://en.wikipedia.org/wiki/Public_recursive_name_server")

```
# Configure DoT provider (example: "Cloudflare Family Protection")
uci set unbound.fwd_google.enabled="0"
uci set unbound.fwd_cloudflare.enabled="0"
while uci -q del unbound.@zone[4]; do :; done
uci add unbound zone
uci set unbound.@zone[-1].enabled="1"
uci set unbound.@zone[-1].fallback="0"
uci set unbound.@zone[-1].zone_type="forward_zone"
uci add_list unbound.@zone[-1].zone_name="."
uci add_list unbound.@zone[-1].server="1.1.1.3"
uci add_list unbound.@zone[-1].server="1.0.0.3"
uci add_list unbound.@zone[-1].server="2606:4700:4700::1113"
uci add_list unbound.@zone[-1].server="2606:4700:4700::1003"
uci set unbound.@zone[-1].tls_upstream="1"
uci set unbound.@zone[-1].tls_index="family.cloudflare-dns.com"
uci commit unbound
service unbound restart
```

### DNSSEC validation

Enforce [DNSSEC](https://en.wikipedia.org/wiki/Domain_Name_System_Security_Extensions "https://en.wikipedia.org/wiki/Domain_Name_System_Security_Extensions") validation if your DNS provider does not support it, or you want to perform the validation yourself. Beware of fault tolerance and performance issues.

```
# Enforce DNSSEC validation
uci set unbound.@unbound[0].validator="1"
uci commit unbound
service unbound restart
```

## Configure unbound with dnsmasq

Unbound can also act as a resolver for dnsmasq. How to install and how to change the [DoT provider](https://en.wikipedia.org/wiki/Public_recursive_name_server "https://en.wikipedia.org/wiki/Public_recursive_name_server") were described earlier. Here would be just described how to configure unbound with dnsmasq. NOTE: more details related to the dnsmasq configuration with unbound you can find in package [documentation](https://github.com/openwrt/packages/blob/master/net/unbound/files/README.md "https://github.com/openwrt/packages/blob/master/net/unbound/files/README.md").

#### Command-line instructions

```
# Change unbound port to 5353, because dnsmasq is running already on port 53
sed -i "s/option listen_port '53'/option listen_port '5353'/g" /etc/config/unbound
sed -i "s/option add_local_fqdn '2'/option add_local_fqdn '0'/g" /etc/config/unbound
 
# configure dnsmasq to forward to localhost 5353
service dnsmasq stop
uci set dhcp.@dnsmasq[0].noresolv="1"
uci set dhcp.@dnsmasq[0].cachesize='0'
uci -q delete dhcp.@dnsmasq[0].server
uci add_list dhcp.@dnsmasq[0].server="127.0.0.1#5353"
uci add_list dhcp.@dnsmasq[0].server="::1#5353"
uci commit dhcp
service dnsmasq start
service unbound restart
 
# Optional - ensure, that the NTP server can work without DNS
uci del system.ntp.server
uci add_list system.ntp.server='194.177.4.1'    # 0.openwrt.pool.ntp.org
uci add_list system.ntp.server='213.222.217.11' # 1.openwrt.pool.ntp.org
uci add_list system.ntp.server='80.50.102.114'  # 2.openwrt.pool.ntp.org
uci add_list system.ntp.server='193.219.28.60'  # 3.openwrt.pool.ntp.org
uci commit system
```

\# Optional steps

```
# Optional: Disable ISP's DNS server
uci set network.wan.peerdns='0'
uci set network.wan6.peerdns='0'
uci commit network


# Optional: Force LAN clients to send DNS queries to dnsmasq (that later will be going to unbound):
uci add firewall rule
uci set firewall.@rule[-1].name='Block-Public-DNS'
uci set firewall.@rule[-1].src='lan'
uci set firewall.@rule[-1].dest='wan'
uci set firewall.@rule[-1].dest_port='53 853 5353'
uci set firewall.@rule[-1].target='REJECT'
uci commit firewall


## 2. Optional: Redirect queries for DNS servers running on non-standard ports. For example: 5353
## Warning: don't use this one if you run an mDNS server
uci add firewall redirect
uci set firewall.@redirect[-1].dest='lan'
uci set firewall.@redirect[-1].target='DNAT'
uci set firewall.@redirect[-1].name='Divert-DNS, port 5353'
uci set firewall.@redirect[-1].src='lan'
uci set firewall.@redirect[-1].src_dport='5353'
uci set firewall.@redirect[-1].dest_port='53'
uci commit firewall

# On the end
/etc/init.d/firewall reload
```
