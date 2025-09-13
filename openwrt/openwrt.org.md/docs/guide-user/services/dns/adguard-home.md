# AdGuard Home

[AdGuard Home](https://adguard.com/en/adguard-home/overview.html "https://adguard.com/en/adguard-home/overview.html") (AGH) is a free and open source network-wide advertising and trackers blocking DNS server. It operates as a DNS server that re-routes tracking domains to a “black hole”, thus preventing your devices from connecting to those servers. It is based on software used with public AdGuard DNS servers.

In addition, AdGuard Home also offers DNS encryption features such as DNS over TLS (DoT) and DNS over HTTPS (DoH) built-in without any additional packages needed.

[![](/_media/media/docs/howto/aghome.png)](/_detail/media/docs/howto/aghome.png?id=docs%3Aguide-user%3Aservices%3Adns%3Aadguard-home "media:docs:howto:aghome.png")

## Prerequisites

Routers with low RAM, flash/storage space or slower processors will potentially not be suitable to run AdGuard Home. You may want to run AdGuard Home on another client instead if you have any of the mentioned system resource limitations with your router. The following requirements below are provided as general guidance.

- Minimum of 50MB free RAM.
- Minimum of 100MB free disk/flash space ([see flash/storage requirements](#flashstorage_space_requirements "docs:guide-user:services:dns:adguard-home ↵")).
- Higher performance routers i.e. dual-core with higher processor clock speeds are recommended.

The amount of RAM required will also be relative to the filter lists you use.

Routers with less than 128MB of RAM or only having a single core processor will tend to perform poorly. The [homehub\_v5a](/toh/bt/homehub_v5a "toh:bt:homehub_v5a") was used for testing the 0.107.0 edge and release builds.

An alternative option could be to use a Raspberry Pi Zero plugged into your routers USB port to run AGH. [Using a Pi Zero for AGH](https://forum.openwrt.org/t/raspberry-pi-zero-as-a-router-attached-ethernet-gadget/112329 "https://forum.openwrt.org/t/raspberry-pi-zero-as-a-router-attached-ethernet-gadget/112329").

### DNS latency/performance

For the best performance and lowest latency on DNS requests, AGH should be your primary DNS resolver in your DNS chain. If you currently have dnsmasq or unbound installed, you should move these services to an alternative port and have AGH use DNS port 53 with upstream DNS resolvers of your choice configured. This wiki recommends keeping dnsmasq/unbound as your local/PTR resolver for Reverse DNS.

The rationale for this is due to resolvers like dnsmasq forking each DNS request when AGH is set as an upstream, this will have an impact on DNS latency which is can be viewed in the AGH dashboard. You will also not benefit from being able to see the DNS requests made by each client if AGH is not your primary DNS resolver as all traffic will appear from your router.

The install script in the setup section will move dnsmasq to port 54 and set it for AGH to use as local PTR / reverse DNS lookups.

### Flash/storage space requirements

The compiled `AdGuardHome` binary has grown since the 0.107.0 release. For many routers this will be quite a significant amount of storage taken up in the overlay filesystem. In addition, features like statistics and query logging will also require further storage space when being written to the working directory. For routers with less flash space, it is highly recommended to use USB or an external storage path to avoid filling up your overlay filesystem. If you have low flash space, you may want to use the custom installation method and have all of the AdGuard Home installation stored outside of your flash storage. Alternatively you can also perform an [exroot configuration](/docs/guide-user/additional-software/extroot_configuration "docs:guide-user:additional-software:extroot_configuration").

Currently (May 2022 edge build 108) a full install to the /opt folder you really require about 100mb of space.

- (70mb) 35mb x2 for the AGH binary and again for when it backups and upgrades. (that's in the agh-backup folder)
- 20mb for my filters. (Again you can raise or lower this depending on what lists you use)
- 2mb - 90 days of statistics.
- 53mb - 7 days of query logs.

You can tweak your logging to keep things smaller if required.

### Query/statistics logging

One of the main benefits of AGH is the detailed query and statistics data provided, however for many routers having long retention periods for this data can cause issues (see flash/storage space requirements). If you are using the default tmpfs storage, you should set a relatively short retention period or disable logging altogether. If you want to have longer retention periods for query/statistics data, consider moving the storage directory to outside your routers flash space.

## Installation

Since 21.02, there is a official [AdGuard Home package](/packages/pkgdata/adguardhome "packages:pkgdata:adguardhome") which can be installed through [opkg](/docs/guide-user/additional-software/opkg "docs:guide-user:additional-software:opkg").

The opkg package for 21.02 has also been confirmed to work on 19.07, but will require transferring the correct ipk through SSH or SCP and installing with opkg manually due to not being present in the 19.07 packages repository.

Required dependencies (ca-bundle) are automatically resolved and installed when using the official package.

```
opkg update
opkg install adguardhome
```

The official OpenWrt package uses the following paths and directories by default:

- The `AdGuardHome` application will be installed to `/usr/bin/AdGuardHome`.
- The main `adguardhome.yaml` configuration file is stored at `/etc/adguardhome.yaml`.
- The default working directory is `/var/adguardhome` (By default `/var` is a symlink to `/tmp`).
- The working directory can be configured in `/etc/config/adguardhome`
- An init.d script is provided at `/etc/init.d/adguardhome`.

The default configured working directory will mean query logs and statistics will be lost on a reboot. To avoid this you should configure a persistent storage path such as /opt or /mnt with external storage and update the working directory accordingly.

To have AdGuard Home automatically start on boot and to start the service:

```
service adguardhome enable
service adguardhome start
```

### Setup

After installing the opkg package, run the following commands through SSH to prepare for making AGH the primary DNS resolver. These instructions assume you are using dnsmasq. This will demote dnsmasq to an internal DNS resolver only.

The ports chosen are either well known alternate ports or reasonable compromises. You are free to edit the scripts to use your own ports but you should check with [https://en.wikipedia.org/wiki/List\_of\_TCP\_and\_UDP\_port\_numbers](https://en.wikipedia.org/wiki/List_of_TCP_and_UDP_port_numbers "https://en.wikipedia.org/wiki/List_of_TCP_and_UDP_port_numbers") for reserved ports.

```
# Get the first IPv4 and IPv6 Address of router and store them in following variables for use during the script.
NET_ADDR=$(/sbin/ip -o -4 addr list br-lan | awk 'NR==1{ split($4, ip_addr, "/"); print ip_addr[1]; exit }')
NET_ADDR6=$(/sbin/ip -o -6 addr list br-lan scope global | awk '$4 ~ /^fd|^fc/ { split($4, ip_addr, "/"); print ip_addr[1]; exit }')
echo "Router IPv4 : ""${NET_ADDR}"
echo "Router IPv6 : ""${NET_ADDR6}"
 
# 1. Move dnsmasq to port 54.
# 2. Set local domain to "lan".
# 3. Add local '/lan/' to make sure all queries *.lan are resolved in dnsmasq;
# 4. Add expandhosts '1' to make sure non-expanded hosts are expanded to ".lan";
# 5. Disable dnsmasq cache size as it will only provide PTR/rDNS info, making sure queries are always up to date (even if a device internal IP change after a DHCP lease renew).
# 6. Disable reading /tmp/resolv.conf.d/resolv.conf.auto file (which are your ISP nameservers by default), you don't want to leak any queries to your ISP.
# 7. Delete all forwarding servers from dnsmasq config.
uci set dhcp.@dnsmasq[0].port="54"
uci set dhcp.@dnsmasq[0].domain="lan"
uci set dhcp.@dnsmasq[0].local="/lan/"
uci set dhcp.@dnsmasq[0].expandhosts="1"
uci set dhcp.@dnsmasq[0].cachesize="0"
uci set dhcp.@dnsmasq[0].noresolv="1"
uci -q del dhcp.@dnsmasq[0].server
 
# Delete existing config ready to install new options.
uci -q del dhcp.lan.dhcp_option
uci -q del dhcp.lan.dns
 
# DHCP option 3: Specifies the gateway the DHCP server should send to DHCP clients.
uci add_list dhcp.lan.dhcp_option='3,'"${NET_ADDR}"
 
# DHCP option 6: Specifies the DNS server the DHCP server should send to DHCP clients.
uci add_list dhcp.lan.dhcp_option='6,'"${NET_ADDR}" 
 
# DHCP option 15: Specifies the domain suffix the DHCP server should send to DHCP clients.
uci add_list dhcp.lan.dhcp_option='15,'"lan"
 
# Set IPv6 Announced DNS
uci add_list dhcp.lan.dns="$NET_ADDR6"
 
uci commit dhcp
service dnsmasq restart
service odhcpd restart
exit 0
```

#### Setup AGH through the web interface

On first time setup the default web interface port is TCP 3000.

1. Go to [http://192.168.1.1:3000/](http://192.168.1.1:3000/ "http://192.168.1.1:3000/") (If your router IP is not 192.168.1.1, change this accordingly)
2. Setup the Admin Web Interface to listen on `192.168.1.1` at port `8080`. (Changing the web interface port is optional)
3. Set DNS server to listen on `192.168.1.1` at port `53`.
4. Create an user and choose a strong password.

#### Login AGH

- [http://192.168.1.1:8080/](http://192.168.1.1:8080/ "http://192.168.1.1:8080/") (or whatever listening port you set)

Feel free to change upstream DNS servers to whatever you like (Adguard Home supports DoH, DoT and DoQ out of the box), add the blacklists of your preference and enjoy ad-free browsing on all of your devices.

[![](/_media/media/adguard_home_web_interface.gif?w=600&tok=cd52b1)](/_detail/media/adguard_home_web_interface.gif?id=docs%3Aguide-user%3Aservices%3Adns%3Aadguard-home "media:adguard_home_web_interface.gif")

### Manual installation

For older builds, a custom installation or running the latest edge builds you can follow several well written guides by members of the community:

- [Installing AdGuardHome on OpenWrt](https://forum.openwrt.org/t/how-to-updated-2021-installing-adguardhome-on-openwrt/113904 "https://forum.openwrt.org/t/how-to-updated-2021-installing-adguardhome-on-openwrt/113904")
- [OpenWrt AdGuard Home 101 (dnsmasq)](https://forum.openwrt.org/t/openwrt-adguard-home-101-dnsmasq/110864 "https://forum.openwrt.org/t/openwrt-adguard-home-101-dnsmasq/110864")
- [OpenWrt AdGuard Home 101 (Unbound)](https://forum.openwrt.org/t/openwrt-adguard-home-101-unbound/112007 "https://forum.openwrt.org/t/openwrt-adguard-home-101-unbound/112007")

## Configuration

Recommendations and best configuration practices for using AGH on OpenWrt.

### Web interface

AdGuard Home has it's own web interface for configuration and management and is not managed through LuCI. There is no official LuCI application for managing AdGuard Home. By default the web setup interface will be on port TCP 3000. To access the web interface, use the IP of your router: [http://192.168.1.1:3000](http://192.168.1.1:3000 "http://192.168.1.1:3000"). If this is the first time you have installed AdGuard Home you will go through the setup process.

By default LuCI will be configured to use standard ports TCP 80/443, so AdGuard Home will need to use an alternative port for the web interface. You can use the default setup port TCP 3000 or change it to an alternative (8080 is the usual port 80 replacememt).

Once AGH is active then [follow the official AdGuard Home wiki instructions](https://github.com/AdguardTeam/AdGuardHome/wiki/Configuration "https://github.com/AdguardTeam/AdGuardHome/wiki/Configuration") to configure upstreams and filters. A list of known DNS providers and settings is here : [Known DNS Providers](https://adguard-dns.io/kb/general/dns-providers/ "https://adguard-dns.io/kb/general/dns-providers/")

Note: Some settings may not be editable via the web interface and instead will need to be changed by editing the `adguardhome.yaml` configuration file.

### Nginx Reverse proxy through LuCI

If you already use [Nginx with LuCI](/docs/guide-user/services/webserver/nginx "docs:guide-user:services:webserver:nginx") rather than [uHTTPd](/docs/guide-user/services/webserver/uhttpd "docs:guide-user:services:webserver:uhttpd") you can reverse proxy the AdGuard Home interface. This can simplify accessing the AdGuard Home interface and not having to worry about URLs with non standard HTTP ports. Using a reverse proxy also means you don't have to specifically configure HTTPS access through AdGuard Home and can instead utilise the HTTPS configuration of LuCI instead.

The following example will allow accessing the AdGuard Home interface as a sub directory path /adguard-home. If your router IP or AdGuard Home `http_port` value is different, change it accordingly.

```
location /adguard-home/ {
    proxy_pass http://192.168.1.1:8080/;
    proxy_redirect / /adguard-home/;
    proxy_cookie_path / /adguard-home/;
}
```

Accessing in your browser: [http://\[ROUTER\]/adguard-home](http://%5BROUTER%5D/adguard-home "http://[ROUTER]/adguard-home").

You can read more [reverse proxy configurations](https://docs.nginx.com/nginx/admin-guide/web-server/reverse-proxy/ "https://docs.nginx.com/nginx/admin-guide/web-server/reverse-proxy/") from the Nginx docs.

**Disable DoH encryption on AdGuard Home**

If you have configured TLS on LuCI, there's no need to use TLS on AdGuard Home. Set `allow_unencrypted_doh` to false in `adguardhome.yaml` to allow AdGuard Home respond to DoH requests without TLS encryption.

### Reverse DNS (rDNS)

To enable rDNS so AGH picks up your DHCP assignments from OpenWrt.

1. From the AdGuard Home web interface **Settings** → **DNS settings**
2. Scroll to “Private reverse DNS servers”
3. Add `127.0.0.1:54` or `192.168.1.1:54` (using loopback interface \[127.0.0.1] is recommended whenever applicable to avoid network overhead and increase performance for rDNS queries).
4. Tick both “*Use private reverse DNS resolvers*” and “*Enable reverse resolving of clients' IP addresses*” boxes and click apply.

[![](/_media/media/doc/howtos/rdns_agh.png?w=600&tok=dbe56d)](/_detail/media/doc/howtos/rdns_agh.png?id=docs%3Aguide-user%3Aservices%3Adns%3Aadguard-home "media:doc:howtos:rdns_agh.png")

### LAN domain interception

Adding the following to the Upstream DNS Server configuration will intercept any LAN domain request or requests without a FQDN and pass those requests to the appropriate resolver, which is mostly like your OpenWrt router but it doesn't have to be.

The default LAN domain configured by OpenWrt is “lan”, but if you have configured you own domain, you can use this in the example code below:

(127.0.0.1) local loopback is used here to enable statistics tracking but you may also use your router ip (192.168.1.1) here too.

**Settings** → **DNS Settings** &gt; **Upstream Servers**

```
[/lan/]127.0.0.1:54
[//]127.0.0.1:54
```

### Creating ipset policies

For users using ipset policies for purposes such as VPN split tunnelling, AGH provides ipset functionality similar to dnsmasq. The configuration/syntax is slightly different and you will need to migrate any existing dnsmasq ipset policies to the AGH format and apply these to AGH instead.

An ipset policy is defined in the `adguardhome.yaml` file, there is currently no web interface available to add these policies, therefore you must add these to the yaml config manually.

If ipset is not already installed, install it:

```
opkg update
opkg install ipset
```

**Example dnsmasq syntax**

Using the following example ipset rules in dnsmasq as a reference, the AGH equivalent is demonstrated.

```
ipset=/domain.com/ipset_name
ipset=/domain1.com/domain2.com/ipset_name,ipset_name2
```

**Example AGH syntax**

```
dns:
 ipset:
 - domain.com/ipset_name
 - domain1.com,domain2.com/ipset_name,ipset_name2
...
```

The main syntax differences is each domain is separated using a comma (`,`) not a forward slash (`/`). A forward slash denotes the end of a domain rule with AGH. When specifying the ipset chain, a comma is used in both examples to denote multiple chains if required.

Like dnsmasq, an ipset policy in AGH can have one or more domains as well as be assigned to multiple ipset chains. Further information on ipset functionality can be found on the [official AdGuard Home wiki](https://github.com/AdguardTeam/AdGuardHome/wiki/Configuration#configuration-file "https://github.com/AdguardTeam/AdGuardHome/wiki/Configuration#configuration-file") under “other settings”.

**Note:** The ipset chains must exist before being used or referenced as AGH does not initialise them. It is possible to potentially encounter a race condition on startup if the ipset chains are not created in time when AGH attempts to start. An alternative is creating a [custom init script](/docs/techref/initscripts "docs:techref:initscripts") that runs the ipset create command earlier than the START value of AGH.

### AGH as a NextDNS client

AGH is recommended to be used with filtering disabled as a NextDNS client. [Using AGH as a NextDNS Client](https://forum.openwrt.org/t/how-to-updated-2021-installing-adguardhome-on-openwrt/113904/6 "https://forum.openwrt.org/t/how-to-updated-2021-installing-adguardhome-on-openwrt/113904/6")

## DNS Interception

Some devices will bypass DHCP provided DNS servers e.g. Google Chromecast.

In order to make sure all DNS traffic goes through your primary DNS resolver, you can enforce this through firewall rules.

Please note this **ONLY** enforces **plain** DNS enquiries from your LAN to be redirected through your DNS. To block DOH or other encrypted DNS requires further rules.

### IPTables (firewall3)

Copy and paste these iptables rules in **Network → Firewall → Custom Rules Tab** or directly to `/etc/firewall.user`.

```
iptables -t nat -A PREROUTING -i br-lan -p tcp --dport 53 -j DNAT --to 192.168.1.1:53
iptables -t nat -A PREROUTING -i br-lan -p udp --dport 53 -j DNAT --to 192.168.1.1:53
```

You can also implement this via a fw3 rule within `/etc/config/firewall`:

```
config redirect 'adguardhome_dns_53'
        option src 'lan'
        option proto 'tcp udp'
        option src_dport '53'
        option target 'DNAT'
        option name 'Adguard Home'
        option dest 'lan'
        option dest_port '53'
```

These examples are for IPv4 DNS traffic only as they use DNAT.

[Further information on DNS interception](/docs/guide-user/firewall/fw3_configurations/intercept_dns "docs:guide-user:firewall:fw3_configurations:intercept_dns")

### NFT Tables (firewall4)

Add a new rule to **Network → Firewall → Port Forwards**, setting “Protocol” as “UDP”, “Source zone” as “lan”, “External port” to 53, “Destination zone” as “unspecified” and “Internal IP Address” your router address (usually 192.168.1.1) and “Internal port” still 53. Saving and applying the rule all UDP/53 traffic will redirected to your router.

Alternately a custom rule can be added:

```
nft add rule nat pre udp dport 53 ip saddr 192.168.1.0/24 dnat 192.168.1.1:53
```

This will redirect all DNS traffic from 192.168.1.0/24 to the 192.168.1.1 server.

## Bypassing encrypted DNS for NTP

In order for SSL to work the correct date/time MUST be set on the device. Not all routers have a Real Time Clock and thus must use NTP to update to the correct date/time on boot. As SSL will NOT work without the correct date/time you MUST bypass encrypted DNS to enable NTP updates to work.

Your router does NOT need encrypted DNS. Only your clients behind the router require filtering and encryption. Setting your router to use AGH as its DNS **WILL** result in failed NTP lookups unless you bypass encrypted lookups for NTP. This is **NOT** a recommended setup. Your router should have its own unencrypted upstream for NTP lookups.

When using a upstream DNS setup that utilises DNS encryption e.g. DoT or DoH, you may come across a race condition on startup where communication to such DNS resolvers is not possible because of the NTP service not being able to establish a connection to a network time source and the set the correct time on your router. Given encrypted DNS relies on TLS/certificates, having accurate time is more important. To prevent this, you can allow NTP DNS requests to use plain DNS, regardless of the upstream DNS resolvers set.

From the AdGuard Home web interface: **Settings** → **DNS Settings** → **Upstream DNS Servers**

Add the following to ensure any DNS request for NTP uses plain DNS. In this example, Cloudflare resolvers have been used. You can use any resolvers you like however.

```
[/pool.ntp.org/]1.1.1.1
[/pool.ntp.org/]1.0.0.1
[/pool.ntp.org/]2606:4700:4700::1111
[/pool.ntp.org/]2606:4700:4700::1001
```

Click apply to enable these specific DNS rules.

## Debugging

If AdGuard Home won't start, you will want to view error logs to understand why.

If using the opkg package you can view syslog for errors using `logread`.

```
logread -e AdGuardHome
```

You can also run AdGuardHome from command line and see the output directly.

```
AdGuardHome -v -c /etc/adguardhome.yaml -w /var/adguardhome --no-check-update
```

This example uses the defaults set in the init script with the extra addition of the verbose flag.

- `-v --verbose` - Enables verbose output (useful for debugging).
- `-c --config` - Path to the AdGuard Home YAML config.
- `-w --work-dir` - Path to the set working directory where data such as logs and statistics are stored.
- `--no-check-update` - Disables the built in update checker.

The most common reason for AdGuard Home not starting is due to syntax errors in the `adguardhome.yaml` config.

## Uninstalling

This script uninstalls AGH and resets your router DNS to Google DNS. This is a known good default and should always work.

**Note:** If your router is not at `192.168.1.1` then replace the router IP address used in the commands below accordingly.

`uninstallAGH.sh`

```
#!/bin/sh
opkg update
service adguardhome stop
service adguardhome disable
opkg remove adguardhome
 
# 1. Reverts AdGuard Home configuration and resets settings to default.
# 2. Enable rebind protection.
# 3. Remove DHCP options for IPv4 and IPv6 
uci -q delete dhcp.@dnsmasq[0].noresolv
uci -q delete dhcp.@dnsmasq[0].cachesize
uci set dhcp.@dnsmasq[0].rebind_protection='1'
uci -q delete dhcp.@dnsmasq[0].server
uci -q delete dhcp.@dnsmasq[0].port
uci -q delete dhcp.lan.dhcp_option
uci -q delete dhcp.lan.dns
 
# Network Configuration
# Disable peer/ISP DNS
uci set network.wan.peerdns="0"
uci set network.wan6.peerdns="0"
 
# Configure DNS provider to Google DNS
uci -q delete network.wan.dns
uci add_list network.wan.dns="8.8.8.8"
uci add_list network.wan.dns="8.8.4.4"
 
# Configure IPv6 DNS provider to Google DNS
uci -q delete network.wan6.dns
uci add_list network.wan6.dns="2001:4860:4860::8888"
uci add_list network.wan6.dns="2001:4860:4860::8844"
 
# Save and apply
uci commit dhcp
uci commit network
/etc/init.d/network restart
/etc/init.d/dnsmasq restart
/etc/init.d/odhcpd restart
```

Reconnect your clients to apply the changes.

## Data Files

The `AdGuardHome/data` folder contains the following.

```
root@OpenWrt:/opt/AdGuardHome/data# ll -h
drwxr-xr-x    3 root     root         512 Oct 29 09:42 ./
drwxrwxrwx    4 root     root         736 Oct 30 09:06 ../
drwxr-xr-x    2 root     root         800 Nov  2 09:52 filters/
-rw-r--r--    1 root     root       45.4M Nov  2 20:42 querylog.json
-rw-r--r--    1 root     root        8.9M Oct 29 09:00 querylog.json.1
-rw-r--r--    1 root     root       32.0K Oct 30 05:28 sessions.db
-rw-r--r--    1 root     root        4.0M Nov  2 21:00 stats.db
```

- `querylog.json`: These are your DNS queries. Can be removed.
- `sessions.db`: active logins to AGH currently. This can be deleted but you will need to relog back in.
- `stats.db`: Your statistics database. can purge but you will lose your statistics data.

The filters folder contains all your filter downloads. Purge if it is full but AGH will re-download your filters.

If your filters are too large for your diskspace you will have to disable large filters and restrict their usage.

The `AdGuardHome/agh-backup` folder contains the previous version of AGH. This also can be removed if space is at a premium.

## References

- [AdGuard Home official Wiki](https://github.com/AdguardTeam/AdGuardHome/wiki/Configuration "https://github.com/AdguardTeam/AdGuardHome/wiki/Configuration")
- [AdGuard Home source tree](https://github.com/AdguardTeam/AdGuardHome "https://github.com/AdguardTeam/AdGuardHome")
- [AdGuard Home Supported Platforms and Releases](https://github.com/AdguardTeam/AdGuardHome/wiki/Platforms "https://github.com/AdguardTeam/AdGuardHome/wiki/Platforms")
- [OpenWrt AdGuard Home package source](https://github.com/openwrt/packages/tree/master/net/adguardhome "https://github.com/openwrt/packages/tree/master/net/adguardhome")
