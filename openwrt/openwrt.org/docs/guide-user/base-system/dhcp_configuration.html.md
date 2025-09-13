# DHCP and DNS examples

This article relies on the following:

- Accessing [web interface](/docs/guide-quick-start/walkthrough_login "docs:guide-quick-start:walkthrough_login") / [command-line interface](/docs/guide-quick-start/sshadministration "docs:guide-quick-start:sshadministration")
- Managing [configs](/docs/guide-user/base-system/uci "docs:guide-user:base-system:uci") / [packages](/docs/guide-user/additional-software/managing_packages "docs:guide-user:additional-software:managing_packages") / [services](/docs/guide-user/base-system/managing_services "docs:guide-user:base-system:managing_services") / [logs](/docs/guide-user/base-system/log.essentials "docs:guide-user:base-system:log.essentials")

See also: [DHCP and DNS configuration](/docs/guide-user/base-system/dhcp "docs:guide-user:base-system:dhcp"), [DNS encryption](/docs/guide-user/services/dns/start#encryption "docs:guide-user:services:dns:start"), [DNS hijacking](/docs/guide-user/firewall/fw3_configurations/intercept_dns "docs:guide-user:firewall:fw3_configurations:intercept_dns")

## Introduction

This how-to provides most common dnsmasq and odhcpd tuning scenarios adapted for OpenWrt.

## Instructions

### Static leases

**LuCI → DHCP and DNS → Static Leases**

Add a fixed IPv4 address `192.168.1.22` and name `mylaptop` for a machine with the MAC address `11:22:33:44:55:66`.

```
uci add dhcp host
uci set dhcp.@host[-1].name="mylaptop"
uci set dhcp.@host[-1].mac="11:22:33:44:55:66"
uci set dhcp.@host[-1].ip="192.168.1.22"
uci set dhcp.@host[-1].dns="1"
uci commit dhcp
service dnsmasq restart
```

Reconnect your clients to apply the changes.

Add a fixed IPv6 interface identifier aka address suffix `23` and name `mylaptop` for a machine with the DUID `000100004fd454041c6f65d26f43`.

```
uci add dhcp host
uci set dhcp.@host[-1].name="mylaptop"
uci set dhcp.@host[-1].duid="000100004fd454041c6f65d26f43"
uci set dhcp.@host[-1].hostid="23"
uci set dhcp.@host[-1].dns="1"
uci commit dhcp
service odhcpd restart
```

Reconnect your clients to apply the changes.

This is an implementation of the `--dhcp-host` option. You can combine IPv4 and IPv6 reservations to a single host entry. Using multiple MACs per host entry is possible but unreliable. Add a separate host entry for each MAC if the host has more than one interface connected simultaneously.

See also: [odhcpd leases](/docs/techref/odhcpd#ubus_api "docs:techref:odhcpd")

### MAC filtering

Ignore DHCP requests from specific clients.

```
uci add dhcp host
uci set dhcp.@host[-1].name="mydesktop"
uci set dhcp.@host[-1].mac="00:11:22:33:44:55"
uci set dhcp.@host[-1].ip="ignore"
uci commit dhcp
service dnsmasq restart
```

Ignore all DHCP requests except the ones from known clients configured with [static leases](/docs/guide-user/base-system/dhcp_configuration#static_leases "docs:guide-user:base-system:dhcp_configuration") or `/etc/ethers`.

```
uci set dhcp.lan.dynamicdhcp="0"
uci commit dhcp
service dnsmasq restart
```

Avoid using this as a security measure since the client can still access the network with a static IP.

### Race conditions with netifd

Resolve the [race condition](https://forum.openwrt.org/t/workaround-gl-ar150-no-dhcp-if-lan-cable-is-not-plugged-during-boot/32349 "https://forum.openwrt.org/t/workaround-gl-ar150-no-dhcp-if-lan-cable-is-not-plugged-during-boot/32349") with netifd service and skip check for competing DHCP servers.

```
uci set dhcp.lan.force="1"
uci commit dhcp
service dnsmasq restart
```

### Missing public prefix

Suppress warnings about missing GUA prefix.

```
uci set dhcp.odhcpd.loglevel="3"
uci commit dhcp
service odhcpd restart
```

### Providing IPv6 default route with DHCP

Announce IPv6 default route for clients using the ULA prefix.

```
uci set dhcp.lan.ra_default="1"
uci commit dhcp
service odhcpd restart
```

### DHCP options

[DHCP options](http://www.networksorcery.com/enp/protocol/bootp/options.htm "http://www.networksorcery.com/enp/protocol/bootp/options.htm") can be configured under the DHCP pool section via `dhcp_option`. Use an alternative default gateway, DNS server and NTP server, disable WINS.

```
uci add_list dhcp.lan.dhcp_option="3,192.168.1.2"
uci add_list dhcp.lan.dhcp_option="6,172.16.60.64"
uci add_list dhcp.lan.dhcp_option="42,172.16.60.64"
uci add_list dhcp.lan.dhcp_option="44"
uci commit dhcp
service dnsmasq restart
```

### Client classifying and individual options

Use the `tag` classifier to create a tagged group. Assign individual DHCP options to hosts tagged with `tag1`. Specify custom DNS and possibly other DHCP options.

```
uci set dhcp.tag1="tag"
uci set dhcp.tag1.dhcp_option="6,8.8.8.8,8.8.4.4"
uci add dhcp host
uci set dhcp.@host[-1].name="j400"
uci set dhcp.@host[-1].mac="00:21:63:75:aa:17"
uci set dhcp.@host[-1].ip="10.11.12.14"
uci set dhcp.@host[-1].tag="tag1"
uci add dhcp host
uci set dhcp.@host[-1].name="j500"
uci set dhcp.@host[-1].mac="01:22:64:76:bb:18"
uci set dhcp.@host[-1].ip="10.11.12.15"
uci set dhcp.@host[-1].tag="tag1"
uci commit dhcp
service dnsmasq restart
```

Use the `mac` classifier to create a tagged group. Assign different DHCP options to hosts with matching MACs. Disable default gateway and specify custom DNS.

```
uci set dhcp.mac1="mac"
uci set dhcp.mac1.mac="00:FF:*:*:*:*"
uci set dhcp.mac1.networkid="vpn"
uci add_list dhcp.mac1.dhcp_option="3"
uci add_list dhcp.mac1.dhcp_option="6,192.168.1.3"
uci commit dhcp
service dnsmasq restart
```

### Use vendor-specific DHCP option to disable NetBios over TCP for Windows Clients

See also: [Vendor-Specific Option Code 0x01 - Microsoft Disable NetBIOS Option](https://docs.microsoft.com/en-us/openspecs/windows_protocols/ms-dhcpe/ef7676b1-5568-4afc-836a-7eca63a10a3a "https://docs.microsoft.com/en-us/openspecs/windows_protocols/ms-dhcpe/ef7676b1-5568-4afc-836a-7eca63a10a3a")

If you want to disable NetBIOS over TCP on Windows clients, it's possible with the following vendor-specific DHCP option:

- DHCP Option 43 (Vendor Specific Information)
  
  - Vendor-specific Option Code (1 byte): 0x01 (Microsoft Disable NetBios Option)
  - Vendor-specific Option Length (1 byte): 0x04
  - Vendor-specific Option Data (4 bytes): See table below

Value Effect 0x00000000 Enable NetBIOS over TCP/IP 0x00000001 Ignore setting 0x00000002 Disable NetBIOS over TCP/IP

It needs to be pushed to clients who have the “MSFT 5.0” Vendor class identifier in their DHCP requests.

This can be achieved with the following configuration snippet:

```
uci set dhcp.msft="vendorclass"
uci set dhcp.msft.networkid="msft"
uci set dhcp.msft.vendorclass="MSFT"
uci add_list dhcp.msft.dhcp_option="vendor:MSFT,1,2i"
uci commit dhcp
service dnsmasq restart
```

### DHCP pool for a large network

- `10.0.0.0` - network address
- `255.0.0.0` - network mask
- `10.22.0.1` - pool start
- `10.22.0.254` - pool end
- `22*2**16+1` - pool offset
- `253` - pool limit

```
# ipcalc.sh 10.0.0.0 255.0.0.0 $((22*2**16+1)) 253
IP=10.0.0.0
NETMASK=255.0.0.0
BROADCAST=10.255.255.255
NETWORK=10.0.0.0
PREFIX=8
START=10.22.0.1
END=10.22.0.254
 
uci set dhcp.lan.start="$((22*2**16+1))"
uci set dhcp.lan.limit="253"
uci commit dhcp
service dnsmasq restart
```

### Hostnames

**LuCI → Network → Hostnames**

Define a custom domain name and the corresponding PTR record - assigns the IPv4 address `192.168.1.23` and IPv6 address `fdce::23` to the domain name `mylaptop` and construct an appropriate reverse records. You can also use this to rebind domain names. The init service merges all entries to an additional hosts file used with the `--addn-hosts` option.

```
uci add dhcp domain
uci set dhcp.@domain[-1].name="mylaptop"
uci set dhcp.@domain[-1].ip="192.168.1.23"
uci add dhcp domain
uci set dhcp.@domain[-1].name="mylaptop"
uci set dhcp.@domain[-1].ip="fdce::23"
uci commit dhcp
service dnsmasq restart
```

Be sure to set up [static leases](/docs/guide-user/base-system/dhcp_configuration#static_leases "docs:guide-user:base-system:dhcp_configuration") to avoid possible collisions due to race conditions.

### A and AAAA RR

This is an implementation of the `--address` option. Return `10.10.10.1` for the domain `home` and all its subdomains.

```
uci add_list dhcp.@dnsmasq[0].address="/home/10.10.10.1"
uci commit dhcp
service dnsmasq restart
```

### SRV RR

This is an implementation of the `--srv-host` option. Define an SRV record for SIP over UDP, with the default port of `5060` on the host `pbx.mydomain.com`, with a class of `0` and a weight of `10`.

```
uci add dhcp srvhost
uci set	dhcp.@srvhost[-1].srv="_sip._udp.mydomain.com"
uci set	dhcp.@srvhost[-1].target="pbx.mydomain.com"
uci set	dhcp.@srvhost[-1].port="5060"
uci set	dhcp.@srvhost[-1].class="0"
uci set	dhcp.@srvhost[-1].weight="10"
uci commit dhcp
service dnsmasq restart
```

### CNAME RR

This is an implementation of the `--cname` option. A Canonical Name record specifies that a domain name is an alias for another domain, the “canonical” domain. Specify that the FTP server is on the same host as the web server.

```
uci add dhcp cname
uci set dhcp.@cname[-1].cname="ftp.example.com"
uci set dhcp.@cname[-1].target="www.example.com"
uci commit dhcp
service dnsmasq restart
```

Be sure to set up [hostnames](/docs/guide-user/base-system/dhcp_configuration#hostnames "docs:guide-user:base-system:dhcp_configuration") since CNAME depends on it.

### MX RR

This is an implementation of the `--mx-host` option. Mitigate the issues caused by split DNS for your own domain if you're running the mail server for your domain behind a firewall. Convince that mailer that it's actually authoritative for your domain, otherwise sendmail may not find an MX record to confirm that the domain is an MX relay and complain about non-existent domain of sender address.

```
uci add dhcp mxhost
uci set	dhcp.@mxhost[-1].domain="yyy.zzz"
uci set	dhcp.@mxhost[-1].relay="my.host.com"
uci set	dhcp.@mxhost[-1].pref="10"
uci commit dhcp
service dnsmasq restart
```

### TFTP boot

Direct BOOTP requests to the TFTP server. Tell the client to load `pxelinux.0` from the server at `192.168.1.2`, and mount root from `/data/netboot/root` on the same server.

```
uci set dhcp.linux="boot"
uci set dhcp.linux.filename="/tftpboot/pxelinux.0"
uci set dhcp.linux.serveraddress="192.168.1.2"
uci set dhcp.linux.servername="fileserver"
uci add_list dhcp.linux.dhcp_option="option:root-path,192.168.1.2:/data/netboot/root"
uci commit dhcp
service dnsmasq restart
```

### Multi-Arch TFTP boot

For PXE boot, each client needs a specific binary for its architecture e.g. PC BIOS, UEFI x86 32bit, UEFI x86 64bit, ARM, etc. You can match on the DHCP “Vendor Class Identifier” option (60) specified by the client to send back the right filename.

```
uci set dhcp.@dnsmasq[0].logdhcp='1'
uci set dhcp.@dnsmasq[0].enable_tftp='1'
uci set dhcp.@dnsmasq[0].tftp_root='/srv/tftp'
uci add dhcp match
uci set dhcp.@match[-1].networkid='bios'
uci set dhcp.@match[-1].match='60,PXEClient:Arch:00000'
uci add dhcp match
uci set dhcp.@match[-1].networkid='efi32'
uci set dhcp.@match[-1].match='60,PXEClient:Arch:00006'
uci add dhcp match
uci set dhcp.@match[-1].networkid='efi64'
uci set dhcp.@match[-1].match='60,PXEClient:Arch:00007'
uci add dhcp match
uci set dhcp.@match[-1].networkid='efi64'
uci set dhcp.@match[-1].match='60,PXEClient:Arch:00009'
uci add dhcp boot
uci set dhcp.@boot[-1].filename='tag:bios,bios/lpxelinux.0'
uci set dhcp.@boot[-1].serveraddress="$(uci get network.lan.ipaddr)"
uci set dhcp.@boot[-1].servername="$(uci get system.@system[0].hostname)"
uci add dhcp boot
uci set dhcp.@boot[-1].filename='tag:efi32,efi32/syslinux.efi'
uci set dhcp.@boot[-1].serveraddress="$(uci get network.lan.ipaddr)"
uci set dhcp.@boot[-1].servername="$(uci get system.@system[0].hostname)"
uci add dhcp boot
uci set dhcp.@boot[-1].filename='tag:efi64,efi64/syslinux.efi'
uci set dhcp.@boot[-1].serveraddress="$(uci get network.lan.ipaddr)"
uci set dhcp.@boot[-1].servername="$(uci get system.@system[0].hostname)"
uci commit dhcp
service dnsmasq reload
```

### Chainloading iPXE

If you are configuring [chainloading](https://ipxe.org/howto/chainloading "https://ipxe.org/howto/chainloading") for [iPXE](https://ipxe.org/ "https://ipxe.org/"), you can match on the DHCP “User Class” option (77) to send an iPXE script to the client, and on the client-arch option to choose the iPXE binary (for other values of client-arch, see [RFC](https://www.rfc-editor.org/rfc/rfc4578.html#section-2.1 "https://www.rfc-editor.org/rfc/rfc4578.html#section-2.1") or [this forum thread](https://forum.openwrt.org/t/feature-request-make-setting-up-ipxe-netbooting-easier-suggest-sane-defaults-suggest-boot-firmwares/153591 "https://forum.openwrt.org/t/feature-request-make-setting-up-ipxe-netbooting-easier-suggest-sane-defaults-suggest-boot-firmwares/153591")).

```
uci set dhcp.@dnsmasq[0].logdhcp='1'
uci set dhcp.@dnsmasq[0].enable_tftp='1'
uci set dhcp.@dnsmasq[0].tftp_root='/srv/tftp'
uci add dhcp match
uci set dhcp.@match[-1].networkid='bios'
uci set dhcp.@match[-1].match='option:client-arch,0'
uci add dhcp match
uci set dhcp.@match[-1].networkid='efi64'
uci set dhcp.@match[-1].match='option:client-arch,7'
uci add dhcp match
uci set dhcp.@match[-1].networkid='efi64'
uci set dhcp.@match[-1].match='option:client-arch,9'
uci add dhcp match
uci set dhcp.@match[-1].networkid='ipxe'
uci set dhcp.@match[-1].match='77,"iPXE"'
uci add dhcp boot
uci set dhcp.@boot[-1].filename='tag:bios,undionly.kpxe'
uci set dhcp.@boot[-1].serveraddress="$(uci get network.lan.ipaddr)"
uci set dhcp.@boot[-1].servername="$(uci get system.@system[0].hostname)"
uci add dhcp boot
uci set dhcp.@boot[-1].filename='tag:efi64,ipxe.efi'
uci set dhcp.@boot[-1].serveraddress="$(uci get network.lan.ipaddr)"
uci set dhcp.@boot[-1].servername="$(uci get system.@system[0].hostname)"
uci add dhcp boot
uci set dhcp.@boot[-1].filename='tag:ipxe,boot_script.ipxe'
uci set dhcp.@boot[-1].serveraddress="$(uci get network.lan.ipaddr)"
uci set dhcp.@boot[-1].servername="$(uci get system.@system[0].hostname)"
uci commit dhcp
service dnsmasq reload
```

### Multiple DHCP/DNS server/forwarder instances

If you need multiple DNS forwarders with different configurations or DHCP server with different sets of lease files.

Running multiple dnsmasq instances as DNS forwarder and/or DHCPv4 server, each having their own configuration and lease list can be configured by creating multiple dnsmasq sections. Typically in such configs each dnsmasq section will be bound to a specific interface by using the interface list; assigning sections like `dhcp`, `host`, etc. to a specific dnsmasq instance is done by the `instance` option. By default dnsmasq adds the loopback interface to the interface list to listen when the `--interface` option is used; therefore the loopback interface needs to be excluded in one of the dnsmasq instances by using the notinterface list.

These are example settings for multiple dnsmasq instances each having their own dhcp section. dnsmasq instance `lan_dns` is bound to the `lan` interface while the dnsmasq instance `guest_dns` is bound to the `guest` interface.

```
# Remove default instances
while uci -q delete dhcp.@dnsmasq[0]; do :; done
while uci -q delete dhcp.@dhcp[0]; do :; done
 
# Use network interface names for DHCP/DNS instance names
INST="lan guest"
for INST in ${INST}
do
uci set dhcp.${INST}_dns="dnsmasq"
uci set dhcp.${INST}_dns.domainneeded="1"
uci set dhcp.${INST}_dns.boguspriv="1"
uci set dhcp.${INST}_dns.filterwin2k="0"
uci set dhcp.${INST}_dns.localise_queries="1"
uci set dhcp.${INST}_dns.rebind_protection="1"
uci set dhcp.${INST}_dns.rebind_localhost="1"
uci set dhcp.${INST}_dns.local="/${INST}/"
uci set dhcp.${INST}_dns.domain="${INST}"
uci set dhcp.${INST}_dns.expandhosts="1"
uci set dhcp.${INST}_dns.nonegcache="0"
uci set dhcp.${INST}_dns.authoritative="1"
uci set dhcp.${INST}_dns.readethers="1"
uci set dhcp.${INST}_dns.leasefile="/tmp/dhcp.leases.${INST}"
uci set dhcp.${INST}_dns.resolvfile="/tmp/resolv.conf.d/resolv.conf.auto"
uci set dhcp.${INST}_dns.nonwildcard="1"
uci add_list dhcp.${INST}_dns.interface="${INST}"
uci add_list dhcp.${INST}_dns.notinterface="loopback"
uci set dhcp.${INST}="dhcp"
uci set dhcp.${INST}.instance="${INST}_dns"
uci set dhcp.${INST}.interface="${INST}"
uci set dhcp.${INST}.start="100"
uci set dhcp.${INST}.limit="150"
uci set dhcp.${INST}.leasetime="12h"
done
uci -q delete dhcp.@dnsmasq[0].notinterface
uci commit dhcp
service dnsmasq restart
```

The LuCI web interface has not been updated to support multiple dnsmasq instances.

### Logging DNS queries

**LuCI → Network → DHCP and DNS → General Settings → Log queries**

Log DNS queries for troubleshooting.

```
uci set dhcp.@dnsmasq[0].logqueries="1"
uci commit dhcp
service dnsmasq restart
```

See also: [Reading logs](/docs/guide-user/base-system/log.essentials "docs:guide-user:base-system:log.essentials")

### Disabling DHCP role

This change turns off DHCP on the specified interface but leaves DNS services available.

```
uci set dhcp.lan.ignore="1"
uci commit dhcp
service dnsmasq restart
service odhcpd restart
```

### Disabling IPv6 DNS for odhcpd

Stop advertising IPv6 DNS with DHCPv6/RA.

```
uci set dhcp.lan.dns_service="0"
uci set dhcp.lan.ra_dns="0"
uci commit dhcp
service odhcpd restart
```

### Disabling DNS role

This is useful when you just want to hand out addresses to clients, without doing any DNS by dnsmasq.

```
service dnsmasq stop
uci set dhcp.@dnsmasq[0].localuse="0"
uci set dhcp.@dnsmasq[0].port="0"
uci commit dhcp
service dnsmasq start
```

### Replacing dnsmasq with odhcpd and Unbound

Remove dnsmasq and use odhcpd for both DHCP and DHCPv6.

```
opkg update
opkg remove dnsmasq odhcpd-ipv6only
opkg install odhcpd
uci -q delete dhcp.@dnsmasq[0]
uci set dhcp.lan.dhcpv4="server"
uci set dhcp.odhcpd.maindhcp="1"
uci commit dhcp
service odhcpd restart
```

Use Unbound for DNS.

```
opkg update
opkg install unbound-control unbound-daemon
uci set unbound.@unbound[0].add_local_fqdn="3"
uci set unbound.@unbound[0].add_wan_fqdn="1"
uci set unbound.@unbound[0].dhcp_link="odhcpd"
uci set unbound.@unbound[0].dhcp4_slaac6="1"
uci set unbound.@unbound[0].unbound_control="1"
uci commit unbound
service unbound restart
uci set dhcp.odhcpd.leasefile="/var/lib/odhcpd/dhcp.leases"
uci set dhcp.odhcpd.leasetrigger="/usr/lib/unbound/odhcpd.sh"
uci commit dhcp
service odhcpd restart
```

See also: [Unbound official documentation](https://github.com/openwrt/packages/blob/master/net/unbound/files/README.md#unbound-and-odhcpd "https://github.com/openwrt/packages/blob/master/net/unbound/files/README.md#unbound-and-odhcpd")

### Providing custom DNS with DHCP

**LuCI → Network → Interfaces → LAN → Edit → DHCP Server**

- **Advanced Settings → DHCP-Options**
- **IPv6 Settings → Announced IPv6 DNS servers**

Announce custom DNS servers with DHCP.

```
# Configure dnsmasq
uci -q delete dhcp.lan.dhcp_option
uci add_list dhcp.lan.dhcp_option="6,8.8.8.8,8.8.4.4"
uci commit dhcp
service dnsmasq restart
 
# Configure odhcpd
uci -q delete dhcp.lan.dns
uci add_list dhcp.lan.dns="2001:4860:4860::8888"
uci add_list dhcp.lan.dns="2001:4860:4860::8844"
uci commit dhcp
service odhcpd restart
```

Reconnect your clients to apply the changes.

See also: [ISP DNS with DHCP](/docs/guide-user/network/protocol.dhcp#providing_isp_dns_with_dhcp "docs:guide-user:network:protocol.dhcp"), [IPv6 ISP DNS with DHCPv6](/docs/guide-user/network/protocol.dhcp#providing_ipv6_isp_dns_with_dhcpv6 "docs:guide-user:network:protocol.dhcp")

### Providing DNS for non-local networks

Answer DNS queries arriving from non-local networks. Reply to VPN clients using point-to-point topology.

```
uci set dhcp.@dnsmasq[0].localservice="0"
uci commit dhcp
service dnsmasq restart
```

### Disabling DNS cache

Disable DNS cache.

```
uci set dhcp.@dnsmasq[0].cachesize="0"
uci commit dhcp
service dnsmasq restart
```

### Split DNS

Enable split DNS for OpenWrt and LAN clients:

- OpenWrt will bypass dnsmasq and only use resolvers advertised by the upstream DHCP server.
- LAN clients will use dnsmasq, ignoring `resolvfile` and relying on the `server` option.

```
service dnsmasq stop
uci set dhcp.@dnsmasq[0].localuse="0"
uci set dhcp.@dnsmasq[0].noresolv="1"
uci commit dhcp
service dnsmasq start
```

This helps avoid race conditions related to DNS encryption.

### DNS forwarding

**LuCI → Network → DHCP and DNS → General Settings → DNS forwardings**

Forward DNS queries to specific servers.

```
uci -q delete dhcp.@dnsmasq[0].server
uci add_list dhcp.@dnsmasq[0].server="8.8.8.8"
uci add_list dhcp.@dnsmasq[0].server="8.8.4.4"
uci commit dhcp
service dnsmasq restart
```

This can be combined with [selective DNS forwarding](/docs/guide-user/base-system/dhcp_configuration#selective_dns_forwarding "docs:guide-user:base-system:dhcp_configuration") or [split DNS](/docs/guide-user/base-system/dhcp_configuration#split_dns "docs:guide-user:base-system:dhcp_configuration").

### Selective DNS forwarding

**LuCI → Network → DHCP and DNS → General Settings → DNS forwardings**

Forward DNS queries for a specific domain and all its subdomains to a different server. More specific domains take precedence over less specific domains.

```
uci add_list dhcp.@dnsmasq[0].server="/example.com/192.168.2.1"
uci commit dhcp
service dnsmasq restart
```

This can be combined with unconditional [DNS forwarding](/docs/guide-user/base-system/dhcp_configuration#dns_forwarding "docs:guide-user:base-system:dhcp_configuration").

### DNS filtering

**LuCI → Network → DHCP and DNS → General Settings → DNS forwardings**

Simple DNS-based content filtering.

```
# Blacklist
uci add_list dhcp.@dnsmasq[0].server="/example.com/"
uci add_list dhcp.@dnsmasq[0].server="/example.net/"
uci commit dhcp
service dnsmasq restart
 
# Whitelist
uci add_list dhcp.@dnsmasq[0].server="/example.com/#"
uci add_list dhcp.@dnsmasq[0].server="/example.net/#"
uci add_list dhcp.@dnsmasq[0].server="/#/"
uci commit dhcp
service dnsmasq restart
```

See also: [Ad blocking](/docs/guide-user/services/ad-blocking "docs:guide-user:services:ad-blocking"), [DNS-based firewall with IP sets](/docs/guide-user/firewall/fw3_configurations/dns_ipset "docs:guide-user:firewall:fw3_configurations:dns_ipset")

### Race conditions with sysntpd

Resolve the race condition with sysntpd service. When running dnsmasq with `noresolv` and `localuse` options and using DNS encryption for local system. Fetch peer DNS or use a fallback DNS provider. Bypass DNS forwarding for NTP provider.

```
. /lib/functions/network.sh
network_flush_cache
for IPV in 4 6
do eval network_find_wan${IPV%4} NET_IF
network_get_dnsserver NET_DNS "${NET_IF}"
case ${IPV} in
(4) NET_DNS="${NET_DNS:-8.8.8.8 8.8.4.4}" ;;
(6) NET_DNS="${NET_DNS:-2001:4860:4860::8888 2001:4860:4860::8844}" ;;
esac
for NET_DNS in ${NET_DNS}
do uci get system.ntp.server \
| sed -e "s/\s/\n/g" \
| sed -r -e "/\.pool\.ntp\.org$/s|^[0-9]*\.||;s|.*|\
del_list dhcp.@dnsmasq[0].server='/\0/${NET_DNS}'\n\
add_list dhcp.@dnsmasq[0].server='/\0/${NET_DNS}'|" \
| uci -q batch
done
done
uci commit dhcp
service dnsmasq restart
```

### Upstream DNS provider

**LuCI → Network → Interfaces → WAN &amp; WAN6 → Edit**

- **Use DNS servers advertised by peer**
- **Use custom DNS servers**

OpenWrt uses peer DNS as the upstream resolvers for dnsmasq by default. These are typically provided by the ISP upstream DHCP server. You can change it to any other [DNS provider](https://en.wikipedia.org/wiki/Public_recursive_name_server "https://en.wikipedia.org/wiki/Public_recursive_name_server") or a local DNS server running on another host. Use resolvers supporting DNSSEC validation if necessary. Specify several resolvers to improve fault tolerance.

```
# Configure DNS provider
uci -q delete network.wan.dns
uci add_list network.wan.dns="8.8.8.8"
uci add_list network.wan.dns="8.8.4.4"
 
# Configure IPv6 DNS provider
uci -q delete network.wan6.dns
uci add_list network.wan6.dns="2001:4860:4860::8888"
uci add_list network.wan6.dns="2001:4860:4860::8844"
 
# Disable peer DNS
uci set network.wan.peerdns="0"
uci set network.wan6.peerdns="0"
 
# Save and apply
uci commit network
service network restart
```

#### General notes

- Resolvers from all active interfaces are combined in a single runtime configuration indiscriminately.
- If the interface is down, its resolvers are not used, so it's reasonable to specify resolvers only on interfaces they are reachable from.
- Dnsmasq periodically queries all the listed resolvers and then uses the fastest one for a period of time.

#### Multiple DNS providers

- The more DNS providers, the higher the fault tolerance of your DNS relative to DoS.
- Different DNS providers may return different answers to a DNS query due to differences in caching, synchronization, load balancing, content filtering, etc.
- To distinguish between correct and incorrect answers such as false-negatives, you need to utilize DNSSEC which may negatively impact fault tolerance and performance.

#### Peer DNS options

- Keep peer DNS enabled to improve your DNS fault tolerance.
- Disable peer DNS to prevent DNS leaks if you have configured a VPN connection on OpenWrt.
- Disable peer DNS to actually change your DNS provider and receive more predictable DNS replies.
