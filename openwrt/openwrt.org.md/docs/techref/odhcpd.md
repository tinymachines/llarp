# odhcpd

See also: [odhcpd upstream documentation](https://github.com/openwrt/odhcpd/blob/master/README "https://github.com/openwrt/odhcpd/blob/master/README")

odhcpd is an embedded DHCP/DHCPv6/RA server &amp; NDP relay.

## Abstract

odhcpd is a daemon for serving and relaying IP management protocols to configure clients and downstream routers. It tries to follow the [RFC 6204](https://datatracker.ietf.org/doc/html/rfc6204 "https://datatracker.ietf.org/doc/html/rfc6204") requirements for IPv6 home routers.

odhcpd provides server services for DHCP, RA, stateless SLAAC and stateful DHCPv6, prefix delegation and can be used to relay RA, DHCPv6 and NDP between routed (non-bridged) interfaces in case no delegated prefixes are available.

## Features

### Router Discovery (RD)

Router Discovery (RD) support (solicitations and advertisements) with 2 modes of operation:

1. RD Server mode: Router Discovery (RD) server for slave interfaces:
   
   1. Automatic detection of prefixes, delegated prefix, default routes and MTU.
   2. Automatic re-announcement of any changes in either prefixes or routes.
2. RD Relay mode: Router Discovery (RD) relay between master and slave interfaces.
   
   1. Supports rewriting of the announced DNS server addresses.

### DHCPv6

DHCPv6 support with 2 modes of operation:

1. DHCPv6 Server mode: stateless, stateful and Prefix Delegation (PD) server mode:
   
   1. Stateless and stateful address assignment.
   2. Prefix delegation support.
   3. Dynamic reconfiguration of any changes in Prefix Delegation.
   4. Hostname detection and hosts-file creation.
2. DHCPv6 Relay mode: A mostly standards-compliant DHCPv6-relay:
   
   1. Supports rewriting of the announced DNS server addresses.

### DHCPv4

1. Stateless and stateful DHCPv4 server mode.

### Neighbor Discovery Proxy (NDP)

Proxy for Neighbor Discovery solicitation and advertisement messages (NDP):

1. Supports auto-learning of routes to the local routing table.
2. Supports marking interfaces as “external”.

Interfaces marked as “external” will not receive any proxyied NDP content and are only served with NDP for Duplicate Address Detection (DAD) and traffic to the router itself.

![:!:](/lib/images/smileys/exclaim.svg) Interfaces marked as external need additional firewall rules for security!

## Configuration

odhcpd uses a UCI configuration file in `/etc/config/dhcp` for configuration and may also receive information from ubus.

### odhcpd section

Configuration for the odhcp daemon.

Name Type Default Description `legacy` boolean `0` Enable DHCPv4 if the 'dhcp' section contains a `start` option, but no `dhcpv4` option set. `maindhcp` boolean `0` Use odhcpd as the main DHCPv4 service. `leasefile` string Location of the lease/hostfile for DHCPv4 and DHCPv6. `leasetrigger` string Location of the lease trigger script. `loglevel` integer `6` Syslog level priority (0-7). 0=emer, 1=alert, 2=crit, 3=err, 4=warn, 5=notice, 6=info, 7=debug

### dhcp section

Configuration for DHCPv4, DHCPv6, RA and NDP services.

Name Type Required Default Description `interface` string `<name of UCI section>` Logical OpenWrt interface. `ifname` string `<resolved from logical>` Physical network interface. `networkid` string `<same as ifname>` Alias of `ifname` for compatibility. `ignore` boolean `0` Do not serve this interface unless overridden by `ra`, `ndp`, `dhcpv4` or `dhcpv6` options. `master` boolean `0` Is a master interface for relaying. `ra` string `disabled` Router Advert service. Set to `disabled`, `server`, `relay` or `hybrid`. `dhcpv6` string `disabled` DHCPv6 service. Set to `disabled`, `server`, `relay` or `hybrid`. `dhcpv4` string `disabled` DHCPv4 service. Set to `disabled` or `server`. `ndp` string `disabled` Neighbor Discovery Proxy. Set to `disabled`, `relay` or `hybrid`. `dynamicdhcp` boolean `1` Leases for DHCPv4 and DHCPv6 are created dynamically. `dhcpv4_forcereconf` boolean `0` Force reconfiguration by sending force renew message even if the client did not include the force renew nonce capability option ([RFC 6704](https://datatracker.ietf.org/doc/html/rfc6704 "https://datatracker.ietf.org/doc/html/rfc6704")). `dhcpv6_assignall` boolean `1` Assign all viable DHCPv6 addresses in statefull mode. If disabled only the DHCPv6 address having the longest preferred lifetime is assigned. `dhcpv6_hostidlength` integer `12` Host ID length of dynamically created leases, allowed values: 12 - 64 (bits). `dhcpv6_na` boolean `1` DHCPv6 stateful addressing hands out IA\_NA - Internet Address - Network Address. `dhcpv6_pd` boolean `1` DHCPv6 stateful addressing hands out IA\_PD - Internet Address - Prefix Delegation. `router` list `<local address>` Routers to announce accepts IPv4 only. `dns` list `<local address>` DNS servers to announce on the network. IPv4 and IPv6 addresses are accepted. `dns_service` boolean `1` Announce the address of interface as DNS service if the list of DNS is empty. `domain` list `<local search domain>` Search domains to announce on the network. `leasetime` string `12h` DHCPv4 address leasetime `start` integer `100` Starting address of the DHCPv4 pool. `limit` integer `150` Number of addresses in the DHCPv4 pool. `preferred_lifetime` string `12h` Value for the preferred lifetime for a prefix. `ra_default` integer `0` Override default route. Set to `0` (default), `1` (ignore, no public address) or `2` (ignore all). `ra_flags` list `other-config` List of RA flags to be advertised in RA messages:  
`managed-config` - get address information from DHCPv6 server. If this flag is set, `other-config` flag is redundant.  
`other-config` - get other configuration from DHCPv6 server (such as DNS servers). See [here](https://datatracker.ietf.org/doc/html/rfc4861#section-4.2 "https://datatracker.ietf.org/doc/html/rfc4861#section-4.2") for details.  
`home-agent` - see [here](https://datatracker.ietf.org/doc/html/rfc3775#section-7.1 "https://datatracker.ietf.org/doc/html/rfc3775#section-7.1") for details.  
`none`.  
OpenWrt since version 21.02 configures `managed-config` and `other-config` [by default](https://github.com/openwrt/openwrt/blob/openwrt-21.02/package/network/services/odhcpd/files/odhcpd.defaults#L49-L50 "https://github.com/openwrt/openwrt/blob/openwrt-21.02/package/network/services/odhcpd/files/odhcpd.defaults#L49-L50"). `ra_slaac` boolean `1` Announce SLAAC for a prefix (that is, set the A flag in RA messages). `ra_management` integer no `1` ![:!:](/lib/images/smileys/exclaim.svg) This option is [deprecated](https://git.openwrt.org/?p=project%2Fodhcpd.git%3Ba%3Dcommit%3Bh%3De73bf11dee1073aaaddc0dc67ca8c7d75ae3c6ad "https://git.openwrt.org/?p=project/odhcpd.git;a=commit;h=e73bf11dee1073aaaddc0dc67ca8c7d75ae3c6ad"). Use `ra_flags` and `ra_slaac` options instead.  
RA management mode: no M-Flag but A-Flag and ra\_slaac is ture (`0`) , both M and A flags and ra\_slaac is ture(`1`), both M and A flags and ra\_slaac is false (`2`) `ra_offlink` boolean `0` Announce prefixes off-link. `ra_preference` string `medium` Route preference `medium`, `high` or `low`. `ra_maxinterval` integer `600` Maximum time allowed between sending unsolicited Router Advertisements (RA). `ra_mininterval` integer `200` Minimum time allowed between sending unsolicited Router Advertisements (RA). `ra_lifetime` integer `1800` Router Lifetime published in Router Advertisement (RA) messages. `ra_useleasetime` boolean `0` If set, the configured DHCPv4 `leasetime` is used both as limit for the preferred and valid lifetime of an IPv6 prefix. `ra_reachabletime` integer `0` Reachable Time in milliseconds to be published in Router Advertisement (RA) messages'. `ra_retranstime` integer `0` Retransmit Time in milliseconds to be published in Router Advertisment (RA) messages. `ra_hoplimit` integer `0` The maximum hops to be published in Router Advertisement (RA) messages. `ra_mtu` integer `0` The MTU to be published in Router Advertisement (RA) messages. `ra_dns` boolean `1` Announce DNS configuration in RA messages ([RFC 8106](https://datatracker.ietf.org/doc/html/rfc8106 "https://datatracker.ietf.org/doc/html/rfc8106")). `ndproxy_routing` boolean `1` Learn routes from NDP. `ndproxy_slave` boolean `0` NDProxy external slave. `ndproxy_static` list Static NDProxy prefixes. `prefix_filter` string `::/0` Only advertise on-link prefixes within the provided IPv6 prefix. Others are filtered out. `ntp` list DHCPv6 stateful option 56 to Announce NTP servers

### host section

The `host` section is where static leases are defined.

Name Type Required Default Description `ip` string yes *(none)* IP address to lease `mac` string no *(none)* MAC address `duid` string no *(none)* DUID in base16 `hostid` string no *(none)* IPv6 host identifier `name` string no *(none)* Hostname `leasetime` string no *(none)* DHCPv4/v6 leasetime

Example `hostid='105ee0badc0de`' ⇒ IPv6 '::1:5ee:bad:c0de'

## ubus API

Replace dnsmasq with odhcpd to access IPv4 leases.

```
ubus -v list dhcp
ubus call dhcp ipv4leases
ubus call dhcp ipv6leases
```

## Compiling

odhcpd uses cmake.

```
# Prepare
cmake .
 
# Build/install
make
make install
 
# Build DEB/RPM packages
make package
```
