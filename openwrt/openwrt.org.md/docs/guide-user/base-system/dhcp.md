# DHCP and DNS configuration /etc/config/dhcp

See also: [DHCP and DNS examples](/docs/guide-user/base-system/dhcp_configuration "docs:guide-user:base-system:dhcp_configuration"), [dnsmasq](/docs/guide-user/base-system/dhcp.dnsmasq "docs:guide-user:base-system:dhcp.dnsmasq"), [odhcpd](/docs/techref/odhcpd "docs:techref:odhcpd")

OpenWrt uses *dnsmasq* and *odhcpd* to serve DNS/DHCP and DHCPv6 by default.

Roles Ports Packages Configuration DNS server 53/UDP, 53/TCP [dnsmasq](/packages/pkgdata/dnsmasq "packages:pkgdata:dnsmasq") `/etc/config/dhcp` DHCP server 67/UDP DHCP relay 68/UDP DHCPv6 server 547/UDP [odhcpd-ipv6only](/packages/pkgdata/odhcpd-ipv6only "packages:pkgdata:odhcpd-ipv6only") RA (Router Advertisemenents) ICMPv6

Dnsmasq serves as a downstream caching DNS server advertising itself to DHCP clients. This allows better performance and management of DNS functionality on your local network. Every received DNS query not currently in cache is forwarded to the upstream DNS servers.

## Sections

Possible section types of the `dhcp` configuration file are defined below. Not all types may appear in the file and most of them are only needed for special configurations. The common ones are the *Common Options*, the *DHCP Pools* and *Static Leases*.

The default configuration contains one *common section* to specify DNS and daemon related options and one or more *DHCP pools* to define DHCP serving on network interfaces.

### Common options

Sections of the type `dnsmasq` specify per dnsmasq instance the values and options relevant to the overall operation of the dnsmasq instance and the DHCP options on all interfaces served. The following table lists all available options, their default value, as well as the corresponding *dnsmasq* command line option. See [the dnsmasq man page](http://www.thekelleys.org.uk/dnsmasq/docs/dnsmasq-man.html "http://www.thekelleys.org.uk/dnsmasq/docs/dnsmasq-man.html") for further details.

These are the default settings for the common options:

```
config dnsmasq
	option domainneeded '1'
	option boguspriv '1'
	option filterwin2k '0'
	option localise_queries '1'
	option rebind_protection '1'
	option rebind_localhost '1'
	option local '/lan/'
	option domain 'lan'
	option expandhosts '1'
	option nonegcache '0'
	option cachesize '1000'
	option authoritative '1'
	option readethers '1'
	option leasefile '/tmp/dhcp.leases'
	option resolvfile '/tmp/resolv.conf.d/resolv.conf.auto'
	option nonwildcard '1'
	option localservice '1'
	option ednspacket_max '1232'
	option filter_aaaa '0'
	option filter_a '0'
```

Options:

- `local` and `domain` enable *dnsmasq* to serve entries in `/etc/hosts`, as well as DHCP client's names if configured under *lan* domain.
- `domainneeded`, `boguspriv`, `localise_queries`, and `expandhosts` ensure requests for local host names are not forwarded to upstream DNS servers.
- `authoritative` makes router the only DHCP server on this network; clients get their IP lease a lot faster this way.
- `leasefile` stores leases in a file so they can be picked up again if *dnsmasq* is restarted.
- `resolvfile` tells *dnsmasq* to use this file to find upstream name servers; it gets created by the WAN DHCP or PPP client.
- `enable_tftp` and `tftp_root` turn on the TFTP server and serve files from tftp\_root.
  
  - May need to set server's IP on client, changing it by setting `serverip` (e.g. `setenv serverip 192.168.1.10`).

### All options

Name Type Default Option Description `add_local_domain` boolean `1` Add the local domain as search directive in resolv.conf. `add_local_hostname` boolean `1` Add A, AAAA, and PTR records for this router only on DHCP served LAN.  
![:!:](/lib/images/smileys/exclaim.svg) enhanced function available since 18.06 with option `add_local_fqdn` `add_local_fqdn` integer `1` Add A, AAAA, and PTR records for this router only on DHCP served LAN.  
`0`**:** Disable.  
`1`**:** Hostname on Primary Address.  
`2`**:** Hostname on All Addresses.  
`3`**:** FDQN on All Addresses.  
`4`**:** `iface.host.domain` on All Addresses.  
![:!:](/lib/images/smileys/exclaim.svg) `add_local_fqdn` available since 18.06 `add_wan_fqdn` integer `0` Labels WAN interfaces like `add_local_fqdn` instead of your ISP assigned default which may be obscure. WAN is inferred from `config dhcp` sections with `option ignore 1` set, so they do not need to be named *WAN*  
![:!:](/lib/images/smileys/exclaim.svg) `add_wan_fqdn` available since 18.06 `addnhosts` list of file paths *(none)* `--addn-hosts` Additional host files to read for serving DNS responses. Syntax in each file is the same as `/etc/hosts` `addnmount` list of directory or file paths *(none)* Expose additional filesystem paths to the jailed *dnsmasq* process. This is useful in the case of manually configured includes in the configuration file or symlinks pointing outside of the exposed paths as used, for example, by an ad blocker or other name-banning package. `authoritative` boolean `1` `--dhcp-authoritative` Force *dnsmasq* into authoritative mode. This speeds up DHCP leasing. Used if this is the only server on the network `bogusnxdomain` list of IP addresses *(none)* `--bogus-nxdomain=<ipaddr>[/prefix]` IP addresses to convert into NXDOMAIN responses (to counteract “helpful” upstream DNS servers that never return NXDOMAIN). `boguspriv` boolean `1` `--bogus-priv` Reject reverse lookups to private IP ranges where no corresponding entry exists in `/etc/hosts` `cachelocal` boolean `1` When set to `0`, use each network interface's `dns` address in the local `/etc/resolv.conf`. Normally, only the loopback address is used, and all queries go through *dnsmasq*. `cachesize` integer `150` `-c` Size of *dnsmasq* query cache. `dbus` boolean `0` `-1` Enable DBus messaging for *dnsmasq*.  
![:!:](/lib/images/smileys/exclaim.svg) Standard builds of *dnsmasq* on OpenWrt do not include DBus support. `dhcp_boot` string *(none)* `--dhcp-boot` Specifies BOOTP options, in most cases just the file name. You can also use: “`file name`, `tftp server name`, `tftp ip address`” `dhcphostsfile` file path *(none)* `--dhcp-hostsfile` Specify an external file with per host DHCP options `dhcpleasemax` integer `150` `-X` Maximum number of DHCP leases `dnsforwardmax` integer `150` `--dns-forward-max=<queries>` Maximum number of concurrent connections `domain` domain name *(none)* `-s` DNS domain handed out to DHCP clients `domainneeded` boolean `1` `-D` Tells *dnsmasq* never to forward queries for plain names, without dots or domain parts, to upstream nameservers. If the name is not known from /etc/hosts or DHCP then a “not found” answer is returned `dnssec` boolean `0` `--dnssec` Validate DNS replies and cache DNSSEC data.  
![:!:](/lib/images/smileys/exclaim.svg) Requires the [dnsmasq-full](/packages/pkgdata/dnsmasq-full "packages:pkgdata:dnsmasq-full") package. Please note that many applications now require DNSSEC to work properly, e.g. Google apps on iOS like Gmail and Google Maps, and Windows Update and Windows Account activation on windows PCs. `dnsseccheckunsigned` boolean `0` `--dnssec-check-unsigned` Check the zones of unsigned replies to ensure that unsigned replies are allowed in those zones. This protects against an attacker forging unsigned replies for signed DNS zones, but is slower and requires that the nameservers upstream of *dnsmasq* are DNSSEC-capable.  
![:!:](/lib/images/smileys/exclaim.svg) Requires the [dnsmasq-full](/packages/pkgdata/dnsmasq-full "packages:pkgdata:dnsmasq-full") package.  
![:!:](/lib/images/smileys/exclaim.svg) Caution: If you use this option on a device that doesn't have a hardware clock, dns resolution may break after a reboot of the device due to an incorrect system time. `ednspacket_max` integer `1232` `-P` Specify the largest EDNS.0 UDP packet which is supported by the DNS forwarder `enable_tftp` boolean `0` `--enable-tftp` Enable the builtin TFTP server `expandhosts` boolean `1` `-E` Add the local domain part to names found in `/etc/hosts` `filterwin2k` boolean `0` `-f` Do not forward requests that cannot be answered by public name servers.  
Make sure it is disabled if you need to resolve SRV records or use SIP phones. `fqdn` boolean `0` `--dhcp-fqdn` Do not resolve unqualifed local hostnames. Needs `domain` to be set. `listen_address` list of IP addresses *(none)* `--listen-address=<ipaddr>` Listen only on the specified IP addresses. If unspecified, listen on IP addresses from each interface `interface` list of interface names *(all interfaces)* `--interface=<interface name>` List of interfaces to listen on. If unspecified, *dnsmasq* will listen to all interfaces except those listed in `notinterface`. Note that *dnsmasq* listens on loopback by default. `notinterface` list of interface names *(none)* `--except-interface=<interface name>` Interfaces *dnsmasq* should not listen on. `ipset` list of strings *(none)* `--ipset` The syntax is: `list ipset '/example.com/example.org/example_ipv4,example_ipv6'`  
![:!:](/lib/images/smileys/exclaim.svg) Requires the [dnsmasq-full](/packages/pkgdata/dnsmasq-full "packages:pkgdata:dnsmasq-full") package. `leasefile` file path *(none)* `--dhcp-leasefile=<path>` Store DHCP leases in this file `local` string *(none)* `-S` Look up DNS entries for this domain from `/etc/hosts`. This follows the same syntax as `server` entries, see the man page. `localise_queries` boolean `1` `--localise-queries` Choose IP address to match the incoming interface if multiple addresses are assigned to a host name in `/etc/hosts`. Initially [disabled](https://github.com/openwrt/openwrt/blob/master/package/network/services/dnsmasq/files/dnsmasq.init#L879 "https://github.com/openwrt/openwrt/blob/master/package/network/services/dnsmasq/files/dnsmasq.init#L879"), but still [enabled](https://github.com/openwrt/openwrt/blob/master/package/network/services/dnsmasq/files/dhcp.conf#L5 "https://github.com/openwrt/openwrt/blob/master/package/network/services/dnsmasq/files/dhcp.conf#L5") in the config by default. ![:!:](/lib/images/smileys/exclaim.svg) Note well the spelling of this option. `localservice` boolean `1` `--local-service` Accept DNS queries only from hosts whose address is on a local subnet, ie a subnet for which an interface exists on the server. `local_ttl` integer `0` `--local-ttl` Default TTL for locally authoritative answers. `localuse` boolean `1` Use *dnsmasq* as a local system resolver. [Depends](https://github.com/openwrt/openwrt/blob/master/package/network/services/dnsmasq/files/dnsmasq.init#L1058-L1062 "https://github.com/openwrt/openwrt/blob/master/package/network/services/dnsmasq/files/dnsmasq.init#L1058-L1062") on the `noresolv` and `resolvfile` options. `logfacility` string `DAEMON` `--log-facility=<facility>` Set the facility to which dnsmasq will send syslog entries. See the [dnsmasq man page](https://thekelleys.org.uk/dnsmasq/docs/dnsmasq-man.html "https://thekelleys.org.uk/dnsmasq/docs/dnsmasq-man.html") for available facilities. `logqueries` boolean `0` `--log-queries=extra` Log the results of DNS queries, dump cache on SIGUSR1, include requesting IP `nodaemon` boolean `0` `-d` Don't daemonize the *dnsmasq* process `nohosts` boolean `0` `-h` Don't read DNS names from `/etc/hosts` `nonegcache` boolean `0` `-N` Disable caching of negative “no such domain” responses `noresolv` boolean `0` `--no-resolv` Don't read upstream servers from `/etc/resolv.conf` which is linked to `resolvfile` by default `nonwildcard` boolean `1` `--bind-dynamic` Bind only configured interface addresses, instead of the wildcard address. `port` port number `53` `-p` Listening port for DNS queries, disables DNS server functionality if set to `0` `queryport` integer *(none)* `-Q` Use a fixed port for outbound DNS queries `readethers` boolean `1` `--read-ethers` Read static lease entries from `/etc/ethers`, re-read on SIGHUP `rebind_protection` boolean `1` `--stop-dns-rebind` Enables DNS rebind attack protection by discarding upstream RFC1918 responses `rebind_localhost` boolean `1` `--rebind-localhost-ok` Allows upstream 127.0.0.0/8 responses, required for DNS based blacklist services, only takes effect if rebind protection is enabled `rebind_domain` list of domain names *(none)* `--rebind-domain-ok` List of domains to allow RFC1918 responses for, only takes effect if rebind protection is enabled. The correct syntax is: `list rebind_domain '/example.com/'` `resolvfile` file path `/tmp/resolv.conf.d/resolv.conf.auto` `-r` Specifies an alternative resolv file `server` list of strings *(none)* `-S` List of DNS servers to forward requests to. See the *dnsmasq* man page for syntax details. `serverlist` file path `/etc/dnsmasq.servers` `-S` Specify upstream servers directly. If one or more optional domains are given, that server is used only for those domains and they are queried only using the specified server. Syntax is `server=/*.mydomain.tld/192.168.100.1` or see the *dnsmasq* man page for details. `rev_server` list of strings *(none)* `--rev-server` List of network range with a DNS server to forward reverse DNS requests to. See the *dnsmasq* man page for syntax details. `address` list of strings *(none)* `-A` List of IP addresses for queried domains. See the *dnsmasq* man page for syntax details. `strictorder` boolean `0` `-o` Obey order of DNS servers in `/etc/resolv.conf` `tftp_root` directory path *(none)* `--tftp-root` Specifies the TFTP root directory `minport` integer `0` `--min-port` Dnsmasq picks random ports as source for outbound queries. When this option is given, the ports used will always be larger than or equal to the specified minport value (min valid value 1024). Useful for systems behind firewalls. `maxport` integer `0` `--max-port` Dnsmasq picks random ports as source for outbound queries. When this option is given, the ports used will always be smaller than or equal to the specified maxport value (max valid value 65535). Useful for systems behind firewalls. `noping` boolean `0` `--no-ping` By default dnsmasq checks if an IPv4 address is in use before allocating it to a host by sending ICMP echo request (aka ping) to the address in question. This parameter allows to disable this check. `allservers` boolean `0` `--all-servers` By default, when dnsmasq has more than one upstream server available, it will send queries to just one server. Setting this parameter forces dnsmasq to send all queries to all available servers. The reply from the server which answers first will be returned to the original requeser. `quietdhcp` boolean `0` `--quiet-dhcp` Suppress logging of the routine operation of DHCP. Errors and problems will still be logged `sequential_ip` boolean `0` `--dhcp-sequential-ip` Dnsmasq is designed to choose IP addresses for DHCP clients using a hash of the client's MAC address. This normally allows a client's address to remain stable long-term, even if the client sometimes allows its DHCP lease to expire. In this default mode IP addresses are distributed pseudo-randomly over the entire available address range. There are sometimes circumstances (typically server deployment) where it is more convenient to have IP addresses allocated sequentially, starting from the lowest available address, and setting this parameter enables this mode. Note that in the sequential mode, clients which allow a lease to expire are much more likely to move IP address; for this reason it should not be generally used. `addmac` \[0,1,base64,text] `0` `--add-mac` Add the MAC address of the requester to DNS queries which are forwarded upstream; this may be used to do DNS filtering by the upstream server.  
The MAC address can only be added if the requester is on the same subnet as the dnsmasq server. Note that the mechanism used to achieve this (an EDNS0 option) is not yet standardised, so this should be considered experimental. Also note that exposing MAC addresses in this way may have security and privacy implications. `logdhcp` boolean `0` `--log-dhcp` Enables extra DHCP logging; logs all the options sent to the DHCP clients and the tags used to determine them `dhcpscript` string *(none)* `--dhcp-script` Run a custom script upon DHCP lease add / renew / remove actions `confdir` directory path `/tmp/dnsmasq<instance>.d` `--conf-dir` Directory with additional configuration files (instance specific) `max_ttl` integer *(none)* `--max-ttl` limit the ttl in the DNS answer to this value `min_cache_ttl` integer *(none)* `--min-cache-ttl` set the minimum time-to-live of DNS answers, even when the ttl in the answer is lower `max_cache_ttl` integer *(none)* `--max-cache-ttl` the maximum time-to-live for any DNS answer, even if higher `rapidcommit` boolean `0` `--dhcp-rapid-commit` Enable DHCPv4 Rapid Commit (fast address assignment) See [RFC 4039](https://www.rfc-editor.org/rfc/rfc4039 "https://www.rfc-editor.org/rfc/rfc4039").

### DHCP pools

Sections of the type `dhcp` specify per interface lease pools and settings for serving DHCP requests. Typically there is at least one section of this type present in the `/etc/config/dhcp` file to cover the lan interface.

You can disable a lease pool for a specific interface by specifying the `ignore` option in the corresponding section.

A minimal example of a `dhcp` section is listed below:

```
config dhcp 'lan'
	option interface 'lan'
	option start '100'
	option limit '150'
	option leasetime '12h'
```

- `lan` specifies the OpenWrt interface that is served by this DHCP pool
- `100` is the offset from the network address, in the default configuration this would mean start leasing addresses from `192.168.1.100`
- `150` is the maximum number of addresses that may be leased, in the default configuration this would mean leasing addresses up to `192.168.1.249`
- `12h` specifies the time to live for handed out leases, twelve hours in this example
- `server` defines the mode for IPv6 configuration (RA &amp; DHCPv6)

Below is a listing of legal options for `dhcp` sections.

Name Type Required Default Description `dhcp_option` list of strings no *(none)* The ID dhcp\_option here must be with written with an underscore. OpenWrt will translate this to `--dhcp-option`, with a hyphen, as ultimately used by dnsmasq. Multiple option values can be given for this *network-id*, with a a space between them and the total string between “”. E.g. '26,1470' or 'option:mtu, 1470' that can assign an MTU per DHCP. Your client must accept MTU by DHCP for this to work. Or “3,192.168.1.1 6,192.168.1.1” to give out gateway and DNS server addresses. A list of options can be found [here](https://en.wikipedia.org/wiki/Dynamic_Host_Configuration_Protocol#Options "https://en.wikipedia.org/wiki/Dynamic_Host_Configuration_Protocol#Options") (note that dnsmasq does not support all options listed there). A list of the symbolic option names that dnsmasq recognises can be found by running `dnsmasq --help dhcp`. `dhcp_option_force` list of strings no *(none)* Exactly the same as `dhcp_option` (note the underscores), but it will be translated to `--dhcp-option-force`, meaning that the DHCP option will be sent regardless on whether the client requested it.  
![:!:](/lib/images/smileys/exclaim.svg) `dhcp_option_force` available since 18.06 `dynamicdhcp` boolean no `1` Dynamically allocate client addresses, if set to `0` only clients present in the `ethers` files are served `force` boolean no `0` Forces DHCP serving on the specified interface even if another DHCP server is detected on the same network segment `ignore` boolean no `0` Specifies whether *dnsmasq* should ignore this pool if set to `1` `dhcpv4` string no *(none)* Specifies whether DHCPv4 server should be enabled (`server`) or disabled (`disabled`) `dhcpv6` string no *(none)* Specifies whether DHCPv6 server should be enabled (`server`), relayed (`relay`) or disabled (`disabled`) `dns` list no `<local address>` DNS servers to announce on the network. Only IPv6 addresses are accepted. To configure IPv4 DNS servers, use `dhcp_option`. `dns_service` boolean no `1` Announce the IPv6 address of interface as DNS service if the list of `dns` option is empty.  
![:!:](/lib/images/smileys/exclaim.svg) `dns_service` available since 21.02 `ra` string no *(none)* Specifies whether Router Advertisements should be enabled (`server`), relayed (`relay`) or disabled (`disabled`) `ra_default` integer no `0` Default router lifetime in the RA message will be set if default route is present and a global IPv6 address (`0`) or if default route is present but no global IPv6 address (`1`) or neither of both conditions (`2`) `ra_flags` list of strings no `other-config` List of RA flags to be advertised in RA messages:  
`managed-config` - get address and other information from DHCPv6 server. If this flag is set, `other-config` flag is redundant.  
`other-config` - get other configuration from DHCPv6 server (such as DNS servers). See [here](https://datatracker.ietf.org/doc/html/rfc4861#section-4.2 "https://datatracker.ietf.org/doc/html/rfc4861#section-4.2") for details.  
`home-agent` - see [here](https://datatracker.ietf.org/doc/html/rfc3775#section-7.1 "https://datatracker.ietf.org/doc/html/rfc3775#section-7.1") for details.  
`none`.  
OpenWrt since version 21.02 configures `managed-config` and `other-config` [by default](https://github.com/openwrt/openwrt/blob/openwrt-21.02/package/network/services/odhcpd/files/odhcpd.defaults#L49-L50 "https://github.com/openwrt/openwrt/blob/openwrt-21.02/package/network/services/odhcpd/files/odhcpd.defaults#L49-L50"). `ra_slaac` boolean no `1` Announce SLAAC for a prefix (that is, set the A flag in RA messages). `ra_management` integer no `1` ![:!:](/lib/images/smileys/exclaim.svg) This option is [deprecated](https://git.openwrt.org/?p=project%2Fodhcpd.git%3Ba%3Dcommit%3Bh%3De73bf11dee1073aaaddc0dc67ca8c7d75ae3c6ad "https://git.openwrt.org/?p=project/odhcpd.git;a=commit;h=e73bf11dee1073aaaddc0dc67ca8c7d75ae3c6ad"). Use `ra_flags` and `ra_slaac` options instead.  
RA management mode : no M-Flag but A-Flag (`0`), both M and A flags (`1`), M flag but not A flag (`2`) `ra_offlink` bool no `0` Announce prefixes as offlink (`1`) in RAs `ra_preference` string no `medium` Announce routes with either high (`high`), medium (`medium`) or low (`low`) priority in RAs `ra_mininterval` integer no `200` Minimum time interval between RAs (in seconds) `ra_maxinterval` integer no `600` Maximum time interval between RAs (in seconds) `ra_lifetime` integer no `1800` Advertised router lifetime (in seconds) `ra_useleasetime` bool no `0` Limit the preferred and valid lifetimes of the prefixes in the RA messages to the configured DHCP leasetime `ra_hoplimit` integer no `0` Advertised current hop limit `(0-255)` `ra_reachabletime` integer no `0` Advertised reachable time (in milliseconds) `(0-3600000)` `ra_retranstime` integer no `0` Advertised NS retransmission time (in milliseconds) `(0-60000)` `ra_mtu` integer no *(none)* Maximum advertised MTU `ra_dns` boolean no `1` Announce DNS configuration in RA messages (RFC8106) `ndp` string no *(none)* Specifies whether NDP should be relayed (`relay`) or disabled (`disabled`) `ndproxy_routing` bool no `1` Learn routes from NDP `ndproxy_slave` bool no `0` Ignore neighbor messages on slave enabled (`1`) interfaces `master` boolean no `0` Specifies whether DHCPv6, RA and NDP in relay mode is a master interface or not. `interface` logical interface name yes *(none)* Specifies the interface associated with this DHCP address pool; must be one of the interfaces defined in `/etc/config/network`. `leasetime` string yes `12h` Specifies the lease time of addresses handed out to clients, for example `12h` or `30m` `limit` integer yes `150` Specifies the size of the address pool (e.g. with start=100, limit=150, maximum address will be .249) `networkid` string no *(value of `interface`)* The dhcp functionality defined in the dhcp section is limited to the interface indicated here through its *network-id*. In case omitted the system tries to know the network-id via the `interface` setting in this dhcp section, through consultation of /etc/config/network. Some IDs get assigned dynamically, are not provided by network, but still can be set here. `start` integer yes `100` Specifies the offset from the network address of the underlying interface to calculate the minimum address that may be leased to clients. It may be greater than 255 to span subnets. `instance` dnsmasq instance no *(none)* Dnsmasq instance to which the dhcp section is bound; if not specified the section is valid for all dnsmasq instances. `tag` list of tag names no *(none)* List of tags that dnsmasq needs to match to use with `--dhcp-range`.

Notes:

- `interface` is a logical interface / network name, i.e. `lan`, `wan`, `wifi` etc. (section names in `/etc/config/network`), NOT a layer 3 device name like `eth0`, `eth1`, `wlan0` etc. (the `ifname` IDs in `/etc/config/network`).
- `networkid` is a layer 3 device name, i.e. `eth0`, `eth1`, `wlan0` etc., not a network name (`lan`, `wan`, `wifi` etc.).

This departs from `ifname` and `network` as used in `/etc/config/network` and in `/etc/config/wireless`, so double check!

### Static leases

You can assign fixed IP addresses to hosts on your network, based on their MAC (hardware) address(es) (for IPv4) or [DUID](https://en.wikipedia.org/wiki/DHCPv6#DHCP_unique_identifier "https://en.wikipedia.org/wiki/DHCPv6#DHCP_unique_identifier") (for IPv6) using several `host` sections (one per host [1)](#fn__1)). This allows a machine with a particular MAC/DUID to always get the same address(es), hostname, etc.

Name Type Required Default Description *Host Matching* `mac` list of strings no *(none)* Hexadecimal MAC (hardware) address(es) of this host. dnsmasq (re)assigns the same DHCP lease to any request coming from a matching address. This only works reliably if only one of the addresses is active at any given time. `duid` string no *(none)* A hexadecimal [DUID](https://en.wikipedia.org/wiki/DHCPv6#DHCP_unique_identifier "https://en.wikipedia.org/wiki/DHCPv6#DHCP_unique_identifier") (DHCPv6 client identifier, max. 256 chars = 128 bytes). `match_tag` list of strings no *(none)* If specified the section will apply only to requests having all the tags; incoming interface name is always auto-assigned, other tags can be added by vendorclass/userclass/etc. sections. `instance` dnsmasq instance no *(none)* Dnsmasq instance to which the host section is bound; if not specified the section is valid for all dnsmasq instances. *Host Configuration* `ip` string no *(none)* The IP address for this host, or `ignore` to ignore any DHCP request from this host. `hostid` string no *(none)* A hexadecimal [IPv6 token](https://datatracker.ietf.org/doc/html/draft-chown-6man-tokenised-ipv6-identifiers-02 "https://datatracker.ietf.org/doc/html/draft-chown-6man-tokenised-ipv6-identifiers-02") (address suffix, max. 16 chars = 64 bits). `name` string no *(none)* The hostname for this host. `tag` list of strings no *(none)* Assigns the given tag to this host. `dns` boolean no `0` Add static forward and reverse DNS entries for this host. `broadcast` boolean no `0` Force broadcast DHCP response. `leasetime` string no *(none)* Host-specific lease time, e.g. 2m, 3h, 5d.

Example for assigning a static IP address in /etc/config/dhcp:

```
config host
        option name 'nas'
        list mac '11:22:33:44:55:66'
        option ip '192.168.1.123'
        option leasetime 'infinite'
```

Note: at least one of `mac` (can use wildcards), `duid`, or `name` *must* be specified. You can also enable the `readethers` option in the `dnsmasq` section and add entries to the `/etc/ethers` file.

### Booting options

Some hosts support booting over the network (PXE booting). Sections of the type `boot` specify how DHCP/BOOTP is used to tell the host which file to boot and the server to load it from. Each client can only receive one set of filename and server address options. If different hosts should boot different files, or boot from different servers, you can use *tags* aka *network-ids* to map options to each client.

Usually, you need to set additional DHCP options (through `dhcp_option`) for further stages of the boot process. See the *dnsmasq* man page for details on the syntax of the `O` option.

The configuration options in this section are used to construct an `-M` option for *dnsmasq*.

\*Note\*: odhcp currently lacks support root-path specification. If you need this functionality, disable odhcpd and use dnsmasq instead.

Name Type Required Default Description `dhcp_option` list of strings no *(none)* Additional options to be added for this network-id. ![:!:](/lib/images/smileys/exclaim.svg) If you specify this, you also need to specify the network-id. `filename` string yes *(none)* The filename the host should request from the boot server. `networkid` string no *(none)* The tag (aka network-id) these boot options should apply to. Applies to all clients if left unspecified. `serveraddress` string yes *(none)* The IP address of the boot server. `servername` string yes *(none)* The hostname of the boot server. `force` bool no *(none)* `dhcp_option` will always be sent even if the client does not ask for it in the parameter request list. This is sometimes needed, for example when sending options to PXELinux. `instance` dnsmasq instance no *(none)* Dnsmasq instance to which the boot section is bound. If not specified the section is valid for all dnsmasq instances.

### Classifying clients and assigning individual options

DHCP can provide the client with numerous options, such as the domain name, NTP servers, network booting options, etc. While some settings are applicable to all hosts in a network segment, others are more specific and are relevant only to a group of hosts, or even only a single one. *dnsmasq* offers to group DHCP options and their values by a `tag`, internally named `networkid`, which is an alphanumeric identifier, and sending options only to hosts which have been tagged with that `networkid`.

In OpenWrt, you can tag hosts by the DHCP range they're in (section `dhcp`), or a number of options the client might send with their DHCP request. In each of these sections, you can use the `dhcp_option` list to add DHCP options to be sent to hosts with this tag (or networkid).

You can use the following classifying sections:

Name Description `mac` Hardware address of the client. `tag` An alphanumeric label which marks the network. `vendorclass` String sent by the client representing the vendor of the client. *dnsmasq* performs a substring match on the vendor class string using this value. `userclass` String sent by the client representing the user of the client. *dnsmasq* performs a substring match on the user class string using this value. `circuitid` Matches the circuit ID as sent by the relay agent, as defined in RFC3046. `remoteid` Matches the remote ID as sent by the relay agent, as defined in RFC3046. `subscrid` Matches the subscriber ID as sent by the relay agent, as defined in RFC3993.

Each classifying section (except `tag`) has one configuration option: which tag it will be assigned.

E.g. a `mac` section with an `mac` entry that exactly matches your ethernet MAC, and a tag (aka `networkid`) of `green` will be tagged `green`.

Name Type Required Default Description *`<classifier>`* string yes *(none)* Use section type as option name and classifying filter as option value. `networkid` string yes *(none)* The tag that matching clients will be assigned. `force` bool no *false* Whether to send the additional options from `dhcp_option` list to the clients that didn't request them.

`tag` classifying sections have one configuration option: values of DHCP options to assign to this tag.

E.g. continuing the previous example, `green` tagged DHCP clients can be selectively forced to receive a `dhcp_option` if there is a `tag` entry with `tag` value of `green`, where a list of `dhcp_option` is also supplied, and `force` is set.

Name Type Required Default Description *`<classifier>`* string yes *(none)* Use section type as option name and classifying filter as option value. `dhcp_option` list of strings no *(none)* Additional options to be added for this tag aka networkid. `force` bool no *false* Whether to send the additional options from `dhcp_option` list to the clients that didn't request them.

### IP sets

![:!:](/lib/images/smileys/exclaim.svg) Requires the [dnsmasq-full](/packages/pkgdata/dnsmasq-full "packages:pkgdata:dnsmasq-full") package.

dnsmasq can automatically populate Netfilter IP sets with resolved addresses of the specified domains. This feature can be enabled using `ipset` option in the `dnsmasq` section, or, with a more convenient syntax, using a dedicated `ipset` section. Every `ipset` section contains names of the IP sets to populate (`name`, multiple IP set names can be specified in one section), and domains whose resolved addresses should be added to the specified IP sets (`domain`). Example:

```
dhcp ipset
	list name 'ss_rules_dst_forward'
	list name 'ss_rules6_dst_forward'
	list domain 'linkedin.com'
	list domain 'telegram.org'
```

### DHCP relay

If you are routing between two interfaces (i.e. they are not bridged) then you will find that clients on the far end of the network sending DHCP requests get no response, as the DHCP broadcast cannot be routed between interfaces.

This can be solved without setting up an independent DHCP server for the far subnet by configuring dnsmasq to act as a DHCP relay. In this configuration it listens for DHCP requests as normal, forwards them to a remote DHCP server, then any response it receives it broadcasts back in the original subnet.

This configuration allows a single DHCP server to handle address assignments across a large network broken up into multiple subnets.

As of October 2021 LuCI does not have an interface for this so the configuration file must be manually edited.

Example DHCP relay configuration:

```
config relay 'id'
	option interface 'lan'
	option local_addr '1.1.1.1'
	option server_addr '2.2.2.2'
```

Name Type Required Default Description `id` string yes *(none)* A unique name for the section, which must be different to every other section's name. `interface` string yes *(none)* Logical network interface where the destination DHCP server is located. `local_addr` string yes *(none)* IP address to listen for DHCP requests. `server_addr` string yes *(none)* IP address of the upstream DHCP server accessible through the network given by the *interface* option. DHCP responses picked up on the far subnet will be relayed to this server. This address must be routed correctly (i.e. you can ping it successfully from the OpenWrt command line).

### Host records

If you want a specific domain (or subdomain) to resolve to a specific IP, one possibility is to add a `hostrecord` for it in dnsmasq's configuration. This can be done using a 'hostrecord' entry in `/etc/config/dhcp`.

Example:

```
config hostrecord
	option name 'example.com'
	option ip '192.168.1.2'
```

With this example configuration, `example.com` resolves to `192.168.1.2`, but `subdomain.example.com` is still resolved in the usual way.

Note that this is different from using dnsmasq's 'address' options, which instruct dnsmasq to resolve an entire domain (including any subdomain) to a specific IP address.

[1)](#fnt__1)

The configuration options in each `host` section are used to construct a `-G` option for *dnsmasq*
