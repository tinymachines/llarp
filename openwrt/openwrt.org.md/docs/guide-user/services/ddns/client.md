# DDNS client

See also: [DDNS client configuration](/docs/guide-user/base-system/ddns "docs:guide-user:base-system:ddns")

## Introduction

DDNS stands for [Dynamic DNS](https://en.wikipedia.org/wiki/Dynamic_DNS "https://en.wikipedia.org/wiki/Dynamic_DNS"). Simply put, using this service gives a name to your IP. So if you're hosting something on your line, people would not have to bother typing your IP. They can just type in your domain name! It also helps when your IP changes. Users won't need to discover what your new IP is, they can simply type your domain name.

This guide will help you configure your DDNS service, so that your router auto-updates your IP to your DDNS provider. The simplest method possible would be through [LuCI](/docs/guide-user/luci/luci.essentials "docs:guide-user:luci:luci.essentials").

OpenWrt uses [ddns-scripts](/packages/pkgdata/ddns-scripts "packages:pkgdata:ddns-scripts") which are shell scripts. There are other scripts and programs available in the web, also some DDNS providers offer their own programs. All of them are currently not ported and tested on OpenWrt.

## Features

ddns-scripts support other special communication functions:

- Run once, useful for usage with [cron](/docs/guide-user/base-system/cron "docs:guide-user:base-system:cron").
- Set proxy with/without authentication for HTTP/HTTPS requests.
- Set DNS server to use other than system default.
- Binding to specific network if `wget` or to specific interface if `curl` installed.
- Force the usage of either IPv4 or IPv6 communication only. Require either `wget` or `curl` AND `bind-host`
- DNS requests via TCP, require either `wget` or `curl` AND `bind-host`.

## Requirements

First of all, you'll need to pick and register a DNS name with a compatible DDNS service provider. For a list of DDNS providers, see:

- [https://www.google.com/search?q=dynamic+dns+provider+list](https://www.google.com/search?q=dynamic%20dns%20provider%20list "https://www.google.com/search?q=dynamic+dns+provider+list")
- [http://www.opendirectoryproject.org/Computers/Internet/Protocols/DNS/Service\_Providers/Dynamic\_DNS](http://www.opendirectoryproject.org/Computers/Internet/Protocols/DNS/Service_Providers/Dynamic_DNS "http://www.opendirectoryproject.org/Computers/Internet/Protocols/DNS/Service_Providers/Dynamic_DNS")
- Pick one from the list [https://github.com/openwrt/packages/blob/master/net/ddns-scripts/files/usr/share/ddns/list](https://github.com/openwrt/packages/blob/master/net/ddns-scripts/files/usr/share/ddns/list "https://github.com/openwrt/packages/blob/master/net/ddns-scripts/files/usr/share/ddns/list")

*ddns-scripts* support the following Dynamic DNS service providers out of the box: [3322.org](http://3322.org/ "http://3322.org/") [dnspark.com](http://dnspark.com/ "http://dnspark.com/") [easydns.com](http://easydns.com/ "http://easydns.com/") [mythic-beasts.com](http://mythic-beasts.com/ "http://mythic-beasts.com/") 6) servercow.de [afraid.org](http://afraid.org/ "http://afraid.org/") 6) dnsever.com [editdns.net](http://editdns.net/ "http://editdns.net/") [namecheap.com](http://namecheap.com/ "http://namecheap.com/") simply.com all-inkl.com [do.de](http://do.de/ "http://do.de/") 6) [goip.de](http://goip.de/ "http://goip.de/") 6) [nettica.com](http://nettica.com/ "http://nettica.com/") [sitelutions.com](http://sitelutions.com/ "http://sitelutions.com/") [changeip.com](http://changeip.com/ "http://changeip.com/") domopoli.de [google.com](http://domains.google.com/ "http://domains.google.com/") 5) 6) njal.la [spdyn.de](http://spdyn.de/ "http://spdyn.de/") 6) (spdns.de) [cloudflare.com](http://cloudflare.com/ "http://cloudflare.com/") 2) 5) 6) [dtdns.com](http://dtdns.com/ "http://dtdns.com/") [dns.he.net](http://dns.he.net/ "http://dns.he.net/") 6) now-dns.com [strato.com](http://strato.com/ "http://strato.com/") [core-networks.de](http://core-networks.de/ "http://core-networks.de/") 6) [duckdns.org](http://duckdns.org/ "http://duckdns.org/") 6) [he.net](https://he.net "https://he.net") [no-ip.com](http://no-ip.com/ "http://no-ip.com/") 1) (noip.com) [system-ns.com](http://system-ns.com/ "http://system-ns.com/") [ddnss.de](http://ddnss.de/ "http://ddnss.de/") 6) [duiadns.net](http://duiadns.net/ "http://duiadns.net/") 6) [hosting.de](https://hosting.de "https://hosting.de") [no-ip.pl](http://no-ip.pl/ "http://no-ip.pl/") 6) [thatip.com](http://thatip.com/ "http://thatip.com/") ddo.jp [dy.fi](http://dy.fi/ "http://dy.fi/") infomaniak.com [nsupdate.info](http://nsupdate.info/ "http://nsupdate.info/") 6) transip.nl desec.io dyndns.it ipnodns.ru [nubem.com](http://nubem.com/ "http://nubem.com/") [twodns.de](http://twodns.de/ "http://twodns.de/") [dhis.org](http://dhis.org/ "http://dhis.org/") 6) [dyndns.org](http://dyndns.org/ "http://dyndns.org/") 6) (dyn.com) [inwx.de](https://inwx.de "https://inwx.de") [ovh.com](http://ovh.com/ "http://ovh.com/") udmedia.de [dnsdynamic.org](http://dnsdynamic.org/ "http://dnsdynamic.org/") [dyndnss.net](http://dyndnss.net/ "http://dyndnss.net/") [joker.com](http://joker.com/ "http://joker.com/") opendns.com [variomedia.de](http://variomedia.de/ "http://variomedia.de/") 6) [dnsexit.com](http://dnsexit.com/ "http://dnsexit.com/") dyns.net [loopia.se](http://loopia.se/ "http://loopia.se/") 6) ([loopia.com](http://loopia.com/ "http://loopia.com/")) oray.com xlhost.de [dnshome.de](http://dnshome.de/ "http://dnshome.de/") 6) dynsip.org moniker.com [regfish.de](http://regfish.de/ "http://regfish.de/") 6) [zoneedit.com](http://zoneedit.com/ "http://zoneedit.com/") 5) [dnsmax.com](http://dnsmax.com/ "http://dnsmax.com/") [dynu.com](http://dynu.com/ "http://dynu.com/") [mydns.jp](http://mydns.jp/ "http://mydns.jp/") 6) [schokokeks.org](http://schokokeks.org/ "http://schokokeks.org/") BIND nsupdate 3) 4) 6) [dnsomatic.com](http://dnsomatic.com/ "http://dnsomatic.com/") [dynv6.com](http://dynv6.com/ "http://dynv6.com/") 6) [myonlineportal.net](http://myonlineportal.net/ "http://myonlineportal.net/") 6) [selfhost.de](http://selfhost.de/ "http://selfhost.de/")

1. Requires additional package [ddns-scripts-noip](/packages/pkgdata/ddns-scripts-noip "packages:pkgdata:ddns-scripts-noip") to be installed.
2. Needs additional package [ddns-scripts-cloudflare](/packages/pkgdata/ddns-scripts-cloudflare "packages:pkgdata:ddns-scripts-cloudflare") to be installed.
3. Directly updates a DNS server (Bind, PowerDNS, Knot) via nsupdate (RFC 2136).
4. Needs additional package [ddns-scripts-nsupdate](/packages/pkgdata/ddns-scripts-nsupdate "packages:pkgdata:ddns-scripts-nsupdate") and [bind-client](/packages/pkgdata/bind-client "packages:pkgdata:bind-client") to be installed.
5. Requires SSL support.
6. Supports IPv6.

If you have picked a DDNS service provider and create your host/domain name you need to note additional your username and password. Now you need to decide if you want to use secure communication with your DDNS provider or not. Some provider require secure [HTTPS](https://en.wikipedia.org/wiki/HTTPS "https://en.wikipedia.org/wiki/HTTPS") communication. Read their help pages for details and also read provider specific information below.

## Web interface instructions

Set up DDNS client service using web interface.

1. Navigate to **LuCI → System → Software**
2. Press the button **Update Lists** to update internal lists of available packages.
3. Install the packages [ddns-scripts](/packages/pkgdata/ddns-scripts "packages:pkgdata:ddns-scripts") and [luci-app-ddns](/packages/pkgdata/luci-app-ddns "packages:pkgdata:luci-app-ddns") to provide DDNS client service and web interface.
4. Install the packages [wget-ssl](/packages/pkgdata/wget-ssl "packages:pkgdata:wget-ssl") and [ca-certificates](/packages/pkgdata/ca-certificates "packages:pkgdata:ca-certificates"), or [curl](/packages/pkgdata/curl "packages:pkgdata:curl") and [ca-bundle](/packages/pkgdata/ca-bundle "packages:pkgdata:ca-bundle") for SSL support.
5. Install the provider specific packages `ddns-scripts_*` and LuCI language packages `luci-i18n-ddns-*`.
6. Refresh the page and navigate to **LuCI → Services → Dynamic DNS**.
7. Use the instances `myddns_ipv4` and `myddns_ipv6` or delete them and define your own.
8. Modify the fields you need to change and check the **Enabled** option.
9. Click **Save &amp; Apply** button to save changes.

## Command-line instructions

Install `ddns-scripts` and the provider-specific packages `ddns-scripts_xxxxx`. Also provide SSL support with `wget` and `ca-certificates`, or `curl` and `ca-bundle`.

```
opkg update
opkg install ddns-scripts
opkg install ddns-scripts_xxxxx
opkg install wget ca-certificates
opkg install curl ca-bundle
```

Proceed with setting up the service using the UCI commands.

## Configuration

ddns-scripts are designed to update one host per configuration/section. To update multiple hosts or providers or IPv4 and IPv6 for the same host you need to define separate configurations/sections. Some providers offer to update multiple host within one update request. A possible solution for this option is to use `--custom--` service name settings. Have a look at [provider specifics](#provider_specifics "docs:guide-user:services:ddns:client ↵").

### Web interface instructions

The main settings you need to set:

DDNS Service provider Service provider name as it is known to OpenWrt Lookup Hostname The [FQDNs](https://en.wikipedia.org/wiki/Fully_qualified_domain_name "https://en.wikipedia.org/wiki/Fully_qualified_domain_name") you want to update, script will make DNS queries against it to check if IP address update is needed Domain Usually the same as Lookup Hostname, script will include this name into the update request sent to provider Username Username or other parameter used for authentication in update request (will be sent URL-encoded) Password Password or other parameter (like token) used for authentication in update request (will be sent URL-encoded)  
![:!:](/lib/images/smileys/exclaim.svg) Ensure this password does not have have `$` characters, as this breaks the script. Interface Network name used by OpenWrt hotplug event system to start *ddns-scripts*, e.g. `wan`, `wan6`

- It is not allowed to use `dash`-sign “-” inside configuration/section names.
- A full list of supported settings (some not supported by LuCI) you will find in [UCI documentation](/docs/guide-user/base-system/ddns "docs:guide-user:base-system:ddns").
- Always keep in mind the [Provider specific](#provider_specifics "docs:guide-user:services:ddns:client ↵") settings if there are any.
- Don't forget to enable your configuration/section.
- You need minimum one enabled configuration/section for *ddns* service to start.
- You need to enable *ddns* service to enable updates being sent on reboot and hotplug events.
- Do not change the files `/usr/lib/ddns/services` or `/usr/lib/ddns/services_ipv6` as they can be overwritten by system and package updates.

#### SSL support

Options to configure HTTPS communication are only available if `wget` or `curl` package is installed.

- Check **Use HTTP Secure** option. Additional field **Path to CA-Certificate** is shown with it's default setting.
  
  - If you have installed `ca-certificates` package leave the shown default `/etc/ssl/certs`.
  - If you have installed CA certificates in one file from [above](#ssl_support "docs:guide-user:services:ddns:client ↵") set the value to `/etc/ssl/certs/ca-certificates.crt`.
  - If you like to use other certificate you need to set here the full path to the certificate including file name, e.g. `/path/to/file.crt`.
  - If your certificates are stored in a different path, set here the path where your certificates are located, e.g. `/path/to/files`.
- Click **Save &amp; Apply** button to save changes.

#### Custom service

If you want to use a DDNS provider currently not listed or you want to update multiple hosts within one configuration/section then you should do the following:

- Choose `--custom--` as service. Additional field **Custom update-URL** is shown.
- Fill in the URL you like to use. ![:!:](/lib/images/smileys/exclaim.svg) Please read URL syntax description [below](#custom_service1 "docs:guide-user:services:ddns:client ↵"). Also have a look at [provider specifics](#provider_specifics "docs:guide-user:services:ddns:client ↵").
- Click **Save &amp; Apply** button to save changes.

![:!:](/lib/images/smileys/exclaim.svg) **If you found a DDNS provider not listed or with additional IPv6 support or with changed update URL please open an issue at [Github-OpenWrt-Packages](https://github.com/openwrt/packages "https://github.com/openwrt/packages") so it can be included with the next release.**

### Command-line instructions

The easiest way to configure *ddns-scripts* via console is to edit the file `/etc/config/ddns` directly using build-in [vi editor](https://en.wikipedia.org/wiki/Vi "https://en.wikipedia.org/wiki/Vi") or any other editor you prefer. Other editors as `vi` needs to be installed separately.

A configuration/section looks like:

```
# /etc/config/ddns
config 'service' 'myddns'
	option 'service_name'	'example.org'
	option 'enabled'	'1'
	option 'domain'		'yourhost.example.org'
	option 'username'	'your_username'
	option 'password'	'your_password'
	option 'interface'	'wan'
	option 'ip_source'	'network'
	option 'ip_network'	'wan'
```

Alternatively you can use [UCI command line interface](/docs/guide-user/base-system/uci#command_line_utility "docs:guide-user:base-system:uci"). Example input:

```
uci set ddns.myddns.service_name="ddnsprovider.com"	# only use names listed in /usr/lib/ddns/services
							# or /usr/lib/ddns/services_ipv6 (since CC 15.05)
uci set ddns.myddns.domain="host.yourdomain.net"
uci set ddns.myddns.username="your_user_name"
uci set ddns.myddns.password="p@ssw0rd"
uci set ddns.myddns.interface="wan"	# network interface that should start this configuration/section
uci set ddns.myddns.enabled="1"
uci commit ddns				# don't forget this, otherwise data not written to configuration file
```

`ddns.myddns.enabled=“1”` means:

- `ddns` is the configuration file to change (here `/etc/config/ddns`)
- `myddns` is the configuration/section to change
- `enabled` is the option to set/change
- behind the `equal`-sign is the value to set. ![:!:](/lib/images/smileys/exclaim.svg) Set `single`- or `double`-quotes around the value and no space or whitespace around the `equal`-sign.

Example to create/add a new configuration/section “newddns”:

```
uci set ddns.newddns="service"
uci set ddns.newddns.service_name="ddnsprovider.com"	# only use names listed in /usr/lib/ddns/services
							# or /usr/lib/ddns/services_ipv6 (since CC 15.05)
uci set ddns.newddns.domain="host.yourdomain.net"
uci set ddns.newddns.username="your_user_name"
uci set ddns.newddns.password="p@ssw0rd"
uci set ddns.newddns.interface="wan"	# network interface that should start this configuration/section
uci set ddns.newddns.enabled="1"
uci commit ddns				# don't forget this, otherwise data not written to configuration file
/etc/init.d/ddns restart
```

#### SSL support

You need to add the following entries to the desired section in `/etc/config/ddns` file using `ca-certificates` package:

```
# /etc/config/ddns
config 'service' 'myddns'
	...
	option 'use_https'	'1'
	option 'cacert'		'/etc/ssl/certs'
```

using single file (ie. as descriped [above](#ssl_support "docs:guide-user:services:ddns:client ↵")):

```
# /etc/config/ddns
config 'service' 'myddns'
	...
	option 'use_https'	'1'
	option 'cacert'		'/etc/ssl/certs/ca-certificates.crt'
#	option 'cacert'		'/full/path/to/file.crt'
```

Above options can also be set via LuCI. The options are only shown if `wget` or `curl` package is installed!

#### Custom service

Following changes need to be done if you use a DDNS provider currently not listed or to update multiple hosts within one configuration/section. Edit `/etc/config/ddns`.

```
# /etc/config/ddns
config 'service' 'myddns'
	...
#	option 'service_name'	'example.org'		# comment out "#" or delete
	option 'update_url'	'http://your.update.url...[USERNAME]...[PASSWORD]...[DOMAIN]...[IP]'
```

or use UCI command line interface

```
uci delete ddns.myddns.service_name
uci set ddns.myddns.update_url="http://your.update.url...[USERNAME]...[PASSWORD]...[DOMAIN]...[IP]"
uci commit ddns		# don't forget this, otherwise data not written to configuration file
```

##### URL Syntax

- No need to set `https://`, it is replaced automatically if SSL support is activated.
- The entries \[USERNAME] \[PASSWORD] \[DOMAIN] \[IP] are replaced by *ddns-scripts* just before update.
- \[USERNAME] is replaced by content of `option username` from configuration file.
- \[PASSWORD] is replaced by content of `option password` from configuration file.
- \[DOMAIN] is replaced by content of `option domain` from configuration file.
- \[IP] is replaced by the current IP address of your OpenWrt system.

<!--THE END-->

- Carefully set `option domain` in your configuration, also used to detect if the update was successfully done.
- This entry is the DNS name your OpenWrt system will be reachable from the internet.
- Have a look at [Provider specifics](#provider_specifics "docs:guide-user:services:ddns:client ↵") for samples.

![:!:](/lib/images/smileys/exclaim.svg) **If you found a DDNS provider not listed or with additional IPv6 support or with changed update URL please open an issue at [Github-OpenWrt-Packages](https://github.com/openwrt/packages "https://github.com/openwrt/packages") so it can be included with the next release.**

### Detecting WAN IP

Here a list (without preferences) of URLs to detect your current public ip used by your system:

Dual-Stack IPv4-only IPv6-only Server Location [http://checkip.dns.he.net/](http://checkip.dns.he.net/ "http://checkip.dns.he.net/") - - US [http://checkip.freedyn.org/](http://checkip.freedyn.org/ "http://checkip.freedyn.org/") - - DE [http://bot.whatismyipaddress.com/](http://bot.whatismyipaddress.com/ "http://bot.whatismyipaddress.com/") - - US [http://whatismyip.org/](http://whatismyip.org/ "http://whatismyip.org/") - - US [http://myexternalip.com/raw](http://myexternalip.com/raw "http://myexternalip.com/raw") - - DE [http://wtfismyip.com/text](http://wtfismyip.com/text "http://wtfismyip.com/text") [http://ipv4.wtfismyip.com/text](http://ipv4.wtfismyip.com/text "http://ipv4.wtfismyip.com/text") [http://ipv6.wtfismyip.com/text](http://ipv6.wtfismyip.com/text "http://ipv6.wtfismyip.com/text") US [http://domains.google.com/checkip](http://domains.google.com/checkip "http://domains.google.com/checkip") - - part of Google [http://icanhazip.com/](http://icanhazip.com/ "http://icanhazip.com/") [http://ipv4.icanhazip.com/](http://ipv4.icanhazip.com/ "http://ipv4.icanhazip.com/") [http://ipv6.icanhazip.com/](http://ipv6.icanhazip.com/ "http://ipv6.icanhazip.com/") US [http://checkip.feste-ip.net/](http://checkip.feste-ip.net/ "http://checkip.feste-ip.net/") [http://v4.checkip.feste-ip.net/](http://v4.checkip.feste-ip.net/ "http://v4.checkip.feste-ip.net/") [http://v6.checkip.feste-ip.net/](http://v6.checkip.feste-ip.net/ "http://v6.checkip.feste-ip.net/") DE [http://ident.me/](http://ident.me/ "http://ident.me/") [http://ipv4.ident.me/](http://ipv4.ident.me/ "http://ipv4.ident.me/") [http://ipv6.ident.me/](http://ipv6.ident.me/ "http://ipv6.ident.me/") UK [http://ddnss.de/meineip.php](http://ddnss.de/meineip.php "http://ddnss.de/meineip.php") [http://ip4.ddnss.de/meineip.php](http://ip4.ddnss.de/meineip.php "http://ip4.ddnss.de/meineip.php") [http://ip6.ddnss.de/meineip.php](http://ip6.ddnss.de/meineip.php "http://ip6.ddnss.de/meineip.php") DE [http://checkip.spdyn.de/](http://checkip.spdyn.de/ "http://checkip.spdyn.de/") [http://checkip4.spdyn.de/](http://checkip4.spdyn.de/ "http://checkip4.spdyn.de/") [http://checkip6.spdyn.de/](http://checkip6.spdyn.de/ "http://checkip6.spdyn.de/") DE [http://ifcfg.me/ip](http://ifcfg.me/ip "http://ifcfg.me/ip") [http://4.ifcfg.me/ip](http://4.ifcfg.me/ip "http://4.ifcfg.me/ip") [http://6.ifcfg.me/ip](http://6.ifcfg.me/ip "http://6.ifcfg.me/ip") FR [http://nsupdate.info/myip](http://nsupdate.info/myip "http://nsupdate.info/myip") [http://ipv4.nsupdate.info/myip](http://ipv4.nsupdate.info/myip "http://ipv4.nsupdate.info/myip") [http://ipv6.nsupdate.info/myip](http://ipv6.nsupdate.info/myip "http://ipv6.nsupdate.info/myip") DE [http://checkip.zerigo.com](http://checkip.zerigo.com "http://checkip.zerigo.com") [http://checkip4.zerigo.com/](http://checkip4.zerigo.com/ "http://checkip4.zerigo.com/") [http://checkip6.zerigo.com/](http://checkip6.zerigo.com/ "http://checkip6.zerigo.com/") US - [http://checkip.dyndns.com/](http://checkip.dyndns.com/ "http://checkip.dyndns.com/") 1) [http://checkipv6.dyndns.com/](http://checkipv6.dyndns.com/ "http://checkipv6.dyndns.com/") 1) US + UK - [http://checkip.dyndns.com:8245/](http://checkip.dyndns.com:8245/ "http://checkip.dyndns.com:8245/") [http://checkipv6.dyndns.com:8245/](http://checkipv6.dyndns.com:8245/ "http://checkipv6.dyndns.com:8245/") US + UK - [http://checkip.dyn.com/](http://checkip.dyn.com/ "http://checkip.dyn.com/") 1) 2) [http://checkipv6.dyn.com/](http://checkipv6.dyn.com/ "http://checkipv6.dyn.com/") 1) 2) US + UK - [http://ipv4.myip.dk/api/info/IPv4Address](http://ipv4.myip.dk/api/info/IPv4Address "http://ipv4.myip.dk/api/info/IPv4Address") [http://ipv6.myip.dk/api/info/IPv6Address](http://ipv6.myip.dk/api/info/IPv6Address "http://ipv6.myip.dk/api/info/IPv6Address") US - [http://ipv4.ipogre.com/linux.php](http://ipv4.ipogre.com/linux.php "http://ipv4.ipogre.com/linux.php") [http://ipv6.ipogre.com/linux.php](http://ipv6.ipogre.com/linux.php "http://ipv6.ipogre.com/linux.php") US - [http://v4.ipv6-test.com/api/myip.php](http://v4.ipv6-test.com/api/myip.php "http://v4.ipv6-test.com/api/myip.php") [http://v6.ipv6-test.com/api/myip.php](http://v6.ipv6-test.com/api/myip.php "http://v6.ipv6-test.com/api/myip.php") FR - [http://ipecho.net/plain](http://ipecho.net/plain "http://ipecho.net/plain") - NL - [http://ipinfo.io/ip](http://ipinfo.io/ip "http://ipinfo.io/ip") - part of Amazon AWS - [http://ifconfig.me/ip](http://ifconfig.me/ip "http://ifconfig.me/ip") - JP - [http://checkip.amazonaws.com](http://checkip.amazonaws.com "http://checkip.amazonaws.com") - part of Amazon AWS - [http://myip.dtdns.com](http://myip.dtdns.com "http://myip.dtdns.com") - US - [http://ip.changeip.com](http://ip.changeip.com "http://ip.changeip.com") - US - [http://freedns.afraid.org/dynamic/check.php](http://freedns.afraid.org/dynamic/check.php "http://freedns.afraid.org/dynamic/check.php") - ? - [http://freedns.afraid.org:8080/dynamic/check.php](http://freedns.afraid.org:8080/dynamic/check.php "http://freedns.afraid.org:8080/dynamic/check.php") - ?

\- Users reported timeout problems, use links in the line below (...:8245). - Alias of \*.dyndns.com.

### WAN IP via own PHP script

If you don't like to use one of the above you can write your own. Here is a sample script in PHP which can easily be deployed on any web hosting:

```
<!DOCTYPE html>
<body>
<?php
  echo $_SERVER['REMOTE_ADDR'];
?>
</body>
</html>
```

### Detecting WAN IP with script

If your WAN interface has the IP you want to propagate, this approach has the advantage of not depending on external services or even a working DNS resolution.

Create the script:

```
cat << "EOF" > /etc/ddns/getwanip
#!/bin/sh
. /lib/functions/network.sh
network_flush_cache
for IPV in 4 6
do
eval network_find_wan${IPV%4} NET_IF
eval network_get_ipaddr${IPV%4} NET_ADDR "${NET_IF}"
echo "${NET_ADDR}"
done
EOF
chmod +x /etc/ddns/getwanip
```

Use it in the DDNS configuration by issuing these UCI commands:

```
uci set ddns.NAMEOFYOURSERVICE.ip_source="script"                 #Change NAMEOFYOURSERVICE to yours
uci set ddns.NAMEOFYOURSERVICE.ip_script="/etc/ddns/getwanip"     #Change NAMEOFYOURSERVICE to yours
```

Or by editing these lines in /etc/config/ddns:

```
config service 'NAMEOFYOURSERVICE'                 #Change NAMEOFYOURSERVICE to yours
        option ip_source 'script'
        option ip_script '/etc/ddns/getwanip'
```

## Operation

![:!:](/lib/images/smileys/exclaim.svg) Enable minimum one configuration/section and ddns service!

### Basics

Normally no user actions are required because *ddns-scripts* starts when hotplug `ifup` event happens. This will happen automatically at system startup when the named interface comes up. Event `ifup` also happens when a dialup network comes up. *ddns-scripts* regularly check if there is a difference between your IP address at DNS and your interface. If different an update request is sent to DDNS provider.

- Whenever you **Save &amp; Apply** an `Enabled` configuration/section from LuCI the corresponding script is automatically restarted.
- If you modify `/etc/config/ddns` configuration file from CLI, you need to restart *ddns-scripts* (see below) to apply changes.

To check if *ddns-scripts* are running you could check with **LuCI → Status → Processes** or via console running

```
pgrep -f -a dynamic
```

You should find something like `... /bin/sh /usr/lib/ddns/dynamic_dns_updater.sh myddns 0` for every configuration/section you configured and enabled, where **myddns** shows your configuration/section name.

Inside LuCI also exists a section **Dynamic DNS → Status → Overview** page showing the current status of your DDNS configurations.

### Run manually

#### Web interface instructions

To **check** running *ddns-scripts* processes from the menu go to **Status → Processes**. Look for something like `/bin/sh /usr/lib/ddns/dynamic_dns_updater.sh -v 0 -S myddns -- start`.

To **stop** a desired process press the **Terminate** or **Kill** button. The process should remove from the list.

You can enable/disable and start/stop *ddns-scripts* from **System → Startup** menu. Look for service `ddns` and press the button for the desired action.

You can additionally enable/disable and start/stop individual configuration/section from **Overview → Services → Dynamic DNS**.

#### Command-line instructions

From console command line you could create an `ifup` hotplug event for the desired network interface. This will start all enabled ddns configurations/sections monitoring this interface. ![:!:](/lib/images/smileys/exclaim.svg) Keep in mind that also other service processes (i.e. firewall) might be (re-)started via `ifup` hotplug event! For INTERFACE, type the specified *ddns-scripts* interface name (the interface name from /etc/config/network, usually 'wan')

```
ACTION=ifup INTERFACE=wan /sbin/hotplug-call iface
```

To **start** only one *ddns-scripts* configuration/section (here `myddns`):

```
/usr/lib/ddns/dynamic_dns_updater.sh -S myddns start &
```

Note that verbosity can also be increased, which is very useful for debugging when creating your own ddns client scripts. e.g.

```
/usr/lib/ddns/dynamic_dns_updater.sh -S myddns -v1 start
```

see `/usr/lib/ddns/dynamic_dns_updater.sh -h` for more details

To **stop** one configuration/section you need to find it's PID and kill it manually e.g.

```
pgrep -f -a dynamic
kill <pid of matching dynamic_dns_updater.sh process>
```

To **start** all *ddns-scripts* configurations configured for a given interface e.g. `wan`

```
/usr/lib/ddns/dynamic_dns_updater.sh -n wan start
```

**All** configured ddns services in `/etc/config/ddns` can of can be stopped,started,restarted and reloaded accordingly with the service command e.g.

```
service ddns restart
```

#### Using scheduler

Each configuration/section of *ddns-scripts* can be configured to run once including retry on error so it is guaranteed that the update is sent to the provider.

To configure your configuration/section to run once you need to set `option force_interval 0`. Setting of `option force_unit` is ignored. Inside LuCI set **Force Interval** in **Timer Settings** tab of your desired configuration or edit `/etc/config/ddns` on console.

```
# /etc/config/ddns
config 'service' 'myddns'
	...
	option 'force_interval'	'0'
```

If you set *ddns* service to `enable` then all configurations/sections are started during interface `ifup`. The configuration/section configured to run once will stop after successful update. To guarantee that your configurations only run once not looking for an interface event you need to disable *ddns* service. To start your configuration via [build in crond](/docs/guide-user/base-system/notuci.config#etccrontabsroot_cronjob_aka_crontab "docs:guide-user:base-system:notuci.config") use the following entry as `command` inside crontab configuration (replace `myddns` with the name of your configuration/section):

```
/usr/lib/ddns/dynamic_dns_updater.sh myddns 0 &
```

### Monitoring

#### Syslog

The `option use_syslog` (also in LuCI) allows to define the level of events logged to syslog:

Value Reporting 0 disable 1 info, notice, warning, errors 2 notice, warning, errors 3 warning, errors 4 errors ![:!:](/lib/images/smileys/exclaim.svg) Critical errors forcing *ddns-scripts* to break (stop) are always logged to syslog

#### Logfile

*ddns-scripts* have built-in logfile support. Logfiles are automatically truncated to a settable number of lines (default 250 lines).

Inside LuCI you could enable logfile in **Advanced Settings** tab of desired configuration/section. From console you need to edit the config file:

```
# /etc/config/ddns
config 'service' 'myddns'
	...
	option 'use_logfile'	'1'
```

In case your device has enough built in memory or if you are using Extroot, you might want to store the ddns logs persistently. To achieve this, you need to change the log file location by adding the following line in the `global` section of `/etc/config/ddns`:

```
# /etc/config/ddns
config 'ddns' 'global'
	...
	option 'ddns_logdir'	'<your_custom_log_dir>'
```

This option must be defined in the global section of the `/etc/config/ddns` file. If the option is defined at config service level, it will be ignored by the `/usr/lib/ddns/dynamic_dns_functions.sh` script and the log location will be defaulted to `/var/log/ddns`.

To view logfile content from LuCI select the **Log File Viewer** tab of desired configuration/section and press the **Read / Reread log file** button. From console you should change to the ddns log directory, default `/var/log/ddns`. You will find a logfile for every configuration/section.

```
cat /var/log/ddns/myddns_ipv4.log
cat /var/log/ddns/myddns_ipv6.log
```

### Debugging

To debug what's going on, you can run *ddns-scripts* in verbose mode. Following verbose level are defined:

Level Description 0 Non verbose, no output 1 Output to console (default) 2 Output to console and logfile, run once WITHOUT retry on error 3 Output to console and logfile, run once WITHOUT retry on error, sending NO update to DDNS service

Before starting debugging stop all running *ddns-scripts* processes:

```
/etc/init.d/ddns stop
/etc/init.d/ddns disable
```

validate that no *ddns-scripts* processes running:

```
pgrep -f -a dynamic
```

Now you can start one configuration/section for debugging. To stop/break running script press \[CTRL]+C. Replace `myddns` with your desired configuration/section name and `level` with the desired verbose level.

```
/usr/lib/ddns/dynamic_dns_updater.sh myddns level
```

You will get full description of errors and the output of programs like wget, nslookup etc. used by *ddns-scripts*.

### Common errors

#### Network and name resolution problems

Check your communication settings with the following commands:

```
nslookup google-public-dns-a.google.com
 
ping -c 5 google-public-dns-a.google.com
ping -c 5 -4 google-public-dns-a.google.com	# (-4) force IPv4 communication
ping -c 5 -6 google-public-dns-a.google.com	# (-6) force IPv6 communication if installed
 
wget -O- http://checkip.dyndns.com		# for IPv4
wget -d -O- http://checkipv6.dyndns.com		# for IPv6 needs wget package and IPv6 to be installed
curl -v http://checkipv6.dyndns.com		# for IPv6 needs curl package and IPv6 to be installed
```

#### HTTPS/SSL problems

Check if your DDNS provider ONLY supports secure requests and enable HTTPS `option use_https` in your configuration. Packages `wget` or `curl` not installed to support secure communication. `wget/curl` could not access/validate SSL certificates. Check certificate installation and run `wget` or `curl` in verbose/debug mode:

```
ls -a -R -l /etc/ssl
 
wget -d -O /tmp/wget.out https://www.google.com --ca-certificate=/etc/ssl/certs/ca-certificates.crt	# single certificate file
wget -d -O /tmp/wget.out https://www.google.com --ca-directory=/etc/ssl/certs		# certificate directory
wget -d -O /tmp/wget.out https://www.google.com --no-check-certificate			# ignore certificate !!! INSECURE !!!
 
curl -v -o /tmp/curl.out https://www.google.com --cacert /etc/ssl/certs/ca-certificates.crt	# single certificate file
curl -v -o /tmp/curl.out https://www.google.com --capath /etc/ssl/certs		# certificate directory
curl -v -o /tmp/curl.out https://www.google.com --insecure			# ignore certificate !!! INSECURE !!!
```

## Provider specifics

### Overview

Remember to read how to [configure a custom service](#custom_service1 "docs:guide-user:services:ddns:client ↵"). At provider specific settings, only parameters that needs to be changed are described. The relevant parameters to use together with a custom settings are:

UCI option LuCI description Explanatory note service\_name DDNS Service provider Inside LuCI set to **--custom--** or delete from `/etc/config/ddns` if you need to use custom update URL update\_url Custom update-URL Copy from description below, if necessary domain Hostname/Domain The already registered name at your DDNS provider.  
![:!:](/lib/images/smileys/exclaim.svg) **Must be your public FQDN** because used by nslookup command to check if the send IP update was recognized by your provider and published around World Wide DNS username Username Normally your username but possibly used with different settings password Password Normally your password but possibly used with different settings

If you find a ![FIXME](/lib/images/smileys/fixme.svg) at a provider description below, please support the [ddns-scripts](/packages/pkgdata_lede17_1/ddns-scripts "packages:pkgdata_lede17_1:ddns-scripts") maintainer to test and update this page. Please post a [support](#support "docs:guide-user:services:ddns:client ↵") request if something is not working as described or needs to be updated.

If you find problem **“Failed writing HTTP request: Bad file descriptor”** in some server / wget version (see: [https://bugzilla.redhat.com/show\_bug.cgi?id=912358](https://bugzilla.redhat.com/show_bug.cgi?id=912358 "https://bugzilla.redhat.com/show_bug.cgi?id=912358")), it is worth to try changing:

```
# /etc/config/ddns
- http://[USERNAME]:[PASSWORD]path_to_your_provider_and_other_things
+ --user=[USERNAME] --password:[PASSWORD] http://path_to_your_provider_and_other_things
 
# /usr/lib/ddns/dynamic_dns_updater.sh
- update_output=$( $retrieve_prog "$final_url" )
+ update_output=$( $retrieve_prog $final_url )
```

### cloudflare.com

Last updated: 2022-09-11

[Homepage](https://www.cloudflare.com/ "https://www.cloudflare.com/")

As of OpenWrt version 22.03.0, *ddns-scripts* supports the use of [API tokens](https://blog.cloudflare.com/api-tokens-general-availability/ "https://blog.cloudflare.com/api-tokens-general-availability/"). API Tokens provide a new way to authenticate with the Cloudflare API.

[Create Custom Token](https://dash.cloudflare.com/profile/api-tokens "https://dash.cloudflare.com/profile/api-tokens") by following the [Creating API tokens guide](https://developers.cloudflare.com/api/tokens/create/ "https://developers.cloudflare.com/api/tokens/create/"). make sure to add “Zone DNS Edit” Permission to your custom token. You can also “include Specific zone” under Zone Resources. These allow for scoped and permissioned access to resources and use the RFC compliant [Authorization Bearer Token Header](https://tools.ietf.org/html/rfc6750#section-2.1 "https://tools.ietf.org/html/rfc6750#section-2.1"). For more information on Token vs Key see the [Cloudflare v4 API](https://api.cloudflare.com/#getting-started-requests "https://api.cloudflare.com/#getting-started-requests") documentation.

```
service_name	cloudflare.com-v4
domain		[Your domain, here: example.com]
username	Bearer
password	[Your API token]
```

To use subdomains (CNAME or A records), use the format below when filling your credentials:

```
domain		{subdomain}@[zone]
```

Examples:

- If the hostname is “sample.example.com”, the “domain” field would be “sample@example.com”
- If the hostname is “dev1.sample.example.com”, the “domain” field would be “dev1.sample@example.com”
- If using Cloudflare's “Subdomain Support”, your zone may already be “foo.example.com”, so if the DDNS hostname is “bar.foo.example.com” the domain field would be “bar@foo.example.com”

### dnsomatic.com

Last updated: 2021-05-16

DNS-O-Matic provides you a free, easy and secure way to announce your dynamic IP changes to multiple services with a single update. Using DNS-O-Matic allows you to pick and choose what Dynamic DNS services you want to notify, all from one easy to use interface. [From dns-o-matic homepage](https://www.dnsomatic.com/ "https://www.dnsomatic.com/") -- [Documentation](https://www.dnsomatic.com/wiki/ "https://www.dnsomatic.com/wiki/")

DNS-O-Matic authentication is integrated with OpenDNS, so your DNS-O-Matic credentials are the same as your OpenDNS ones. You need to change your OpenDNS password to one that doesn't contain HTML special characters [On dnsomatic username and password](https://support.opendns.com/hc/en-us/community/posts/360055742852-dns-o-matic-username-password- "https://support.opendns.com/hc/en-us/community/posts/360055742852-dns-o-matic-username-password-")

If you would like to make sure your SSL connection is verified, then [install the CA certificates](/docs/guide-user/services/ddns/client#ssl_support "docs:guide-user:services:ddns:client") and set the path to **/etc/ssl/certs** *(Path to CA-Certificate in the LuCI or **option 'cacert' '/etc/ssl/certs'** when configuring by command line.)*

To update all services registered with DNS-O-Matic in one configuration/section use the following settings in /etc/config/ddns:

```
# /etc/config/ddns
config service 'DNSoMATIC'
        option lookup_host   'anotherddns.com'             # It must be a FQDN that is active on dns-o-matic dashboard to be refreshed by it. if using openDNS, use myip.opendns.com
        option interface     'wan'                         # Set it to the network interface to be monitored on changes
        option ip_source     'web'
        option ip_url        'http://checkip.amazonaws.com/' # does not appear to be used, at least by the LUCI interface
        option use_https     '1'
        option cacert         '/etc/ssl/certs'
        option service_name  'dnsomatic.com'
        option domain        'all.dnsomatic.com'            # It will instruct dns-o-matic to update all services set on its dashboard
        option username      'OPENDNSusername'              # dns-o-matic uses OpenDNS login credentials
        option password      'OPENDNSpassword'              # It must not contain html reserved characters
        option enabled       '1'
```

Alternatively, you can issue uci commands:

```
uci add ddns dnsomatic
uci set ddns.dnsomatic.lookup_host='DDNSchangedBYdnsomatic.com'  ##Change it to yours
uci set ddns.dnsomatic.interface='wan'                           ##Change it to yours
uci set ddns.dnsomatic.ip_source='web'
uci set ddns.dnsomatic.ip_url='http://checkip.amazonaws.com/'    ## not mandatory
uci set ddns.dnsomatic.use_https='1'
uci set ddns.dnsomatic.service_name='dnsomatic.com'
uci set ddns.dnsomatic.domain='all.dnsomatic.com'
uci set ddns.dnsomatic.username='OPENDNSusername'                ##Change it to yours
uci set ddns.dnsomatic.password='OPENDNSpassword'                ##Change it to yours
uci set ddns.dnsomatic.enabled='1'
uci commit
/etc/init.d/ddns reload
```

### duckdns.org

Last updated: 2024-16-12

[Homepage](https://www.duckdns.org/ "https://www.duckdns.org/")

```
service_name	duckdns.org
domain		[Your (sub)domain, without ".duckdns.org"]
username	[dummy, not used, but Luci expects something to be set]
password	[Your authorisation token]
```

If *custom* configuration is required, see [DuckDNS DDNS Client](/docs/guide-user/services/ddns/duckdns "docs:guide-user:services:ddns:duckdns").

Note: this service cannot detect your IPv6 address, it should be included in the DDNS update request; you cannot send updates over IPv6.

### dynu.com

Last updated: 2025-02-13

[Homepage](http://dynu.com/ "http://dynu.com/") -- [IP Update Protocol](https://www.dynu.com/DynamicDNS/IP-Update-Protocol "https://www.dynu.com/DynamicDNS/IP-Update-Protocol")

It works out of the box in the standard most common setup with a single user-defined *hostname* and a domain selected from what is offered by this provider:

```
service_name	dynu.com
domain		[Your FQDN, like "hostname.example.com"]
username	[dummy, not used, but Luci expects something to be set]
password	[your update token]
```

In order to update v4 or v6 IP address for a *subdomain* that they call an [alias](https://www.dynu.com/Resources/Tutorials/DynamicDNS/Advancedfeatures/Aliases "https://www.dynu.com/Resources/Tutorials/DynamicDNS/Advancedfeatures/Aliases") the following custom configuration can be used:

```
service_name	delete / --custom--
update_url	http://api.dynu.com/nic/update?hostname=[DOMAIN]&alias=[PARAMENC]&myipv6=[IP]&password=[PASSWORD]
domain		[your 3rd level domain, like "mydomain.example.com"]
param_enc	[your alias, like "myhost"]
username	[dummy, not used, but Luci expects something to be set]
password	[your update token]
```

This will update IPv6 address for `myhost.mydomain.example.com`

If you are behind a CGNAT with a valid IPv6 address, you might want to add the option `myip=no` to the update URL (forcing Dynu to update `AAAA` entry only). Otherwise Dynu will add your CGNAT IPv4 by default (`A` record) which may be undesirable. In this case, use the following `update_url`:

```
http://api.dynu.com/nic/update?hostname=[DOMAIN]&myip=no&myipv6=[IP]&password=[PASSWORD]
```

The *update token* used as a password in both standard and custom configurations is an MD5/SHA-256 *hash* of “IP Update Password” that is set in [Control Panel / My Account / Username/Password](https://www.dynu.com/en-US/ControlPanel/ManageCredentials "https://www.dynu.com/en-US/ControlPanel/ManageCredentials")

This *password hash* can be generated by the user either [online](https://www.dynu.com/NetworkTools/Hash "https://www.dynu.com/NetworkTools/Hash") or locally: `root@OpenWrt:~# echo -n myupdatepass | sha256sum`

### freedns.afraid.org

Last updated: 2025-04-11

[Homepage](http://freedns.afraid.org/ "http://freedns.afraid.org/") -- [FAQ](http://freedns.afraid.org/faq/ "http://freedns.afraid.org/faq/")

Option 1

```
service_name	afraid.org-v2-token
domain		[Your FQDN]
username	[NOT used. Set to a character of your choice, because LuCI does not accept empty field]
password	[Your authorisation token, NOT your account password]
```

The token - approx. 25 character sequence - can be seen (once logged in) in the sample update URL [here](https://freedns.afraid.org/dynamic/v2/ "https://freedns.afraid.org/dynamic/v2/").

Option 2

```
service_name	delete / --custom--
update_url	[Your direct URL updater from your freedns.afraid.org account]
domain		[Your FQDN]
username	[NOT used. Set to a character of your choice, because LuCI does not accept empty field]
password	[NOT used because already part of direct URL. Set to a character of your choice, because LuCI does not accept empty field]
```

Option 3

```
service_name	afraid.org-v2-basic or afraid.org-basicauth
domain		[Your FQDN]
username	[your username of afraid.org]
password	[Your account password]
```

Option 4 (old method)

```
service_name	afraid.org-keyauth
domain		[Your FQDN]
username	[NOT used. Set to a character of your choice, because LuCI does not accept empty field]
password	[Your authorisation key, NOT your account password]
```

The key - approx. 40 character sequence - can be seen (once logged in) in the sample update URL or script [here](https://freedns.afraid.org/dynamic/ "https://freedns.afraid.org/dynamic/").

### domains.google.com

Last updated: 2016-04-20

Google Domains allows for dynamic names to be set up in the section called Synthetic Records. To access it, log in to [https://domains.google.com](https://domains.google.com "https://domains.google.com") and go to Configure DNS for the domain in question, then scroll down to Synthetic Records and add a new one. It will issue a specific username and password for this hostname. Google requires HTTPS for updates, so be sure to also install package wget or curl in order to allow this. Use the following settings:

```
service_name	--custom--
update_url	http://[USERNAME]:[PASSWORD]@domains.google.com/nic/update?hostname=[DOMAIN]&myip=[IP]
domain		[Your defined hostname]
username	[assigned username for hostname]
password	[assigned password for hostname]
http_secure	Enabled
ca_path		Set to "IGNORE" or download certs and provide path
```

### gratisdns.dk

Last updated: 2015-07-20

[Homepage](http://web.gratisdns.dk/ "http://web.gratisdns.dk/") (Danish only)

Taken from [OpenWrt forum](https://forum.openwrt.org/viewtopic.php?pid=281262 "https://forum.openwrt.org/viewtopic.php?pid=281262")

GratisDNS.dk is only supported by *ddns-scripts* using custom service settings and requires to [install](#ssl_support "docs:guide-user:services:ddns:client ↵") and configure SSL support.

```
service_name	delete / --custom--
update_url	http://ssl.gratisdns.dk/ddns.phtml?u=[USERNAME]&p=[PASSWORD]&d=Mydomain&h=[DOMAIN]&i=[IP]
		!!! replace "Mydomain" in this URL with domain part of your FQDN.
		Sample: your FQDN: host.example.com -> "Mydomain" set to example.com
		Sample: http://ssl.gratisdns.dk/ddns.phtml?u=[USERNAME]&p=[PASSWORD]&d=example.com&h=[DOMAIN]&i=[IP]
domain		[Your FQDN]
username	[Your username]
password	[Your password]
```

### he.net

Last updated: 2023-10-05

[Homepage](https://dns.he.net/ "https://dns.he.net/") [Details about their free dynamic DNS service](https://dns.he.net/docs.html "https://dns.he.net/docs.html")

Background (who they are): Hurricane Electric (referred to as HE.net below) is one of the *original* supporters/pushers of the IPv6 internet (and also provide a [free tunnel broker](https://tunnelbroker.net/ "https://tunnelbroker.net/") if you want IPv6 connectivity but your ISP is in the stone-ages), and HE.net also run major internet backbones.

HE.net is a great option if you *already* have a domain (or sub-domain) you can point at their 5 nameservers (ns\[1-5]/dot/he.net). This will need to be done **before** you can setup the zone (your domain or subdomain) up.

You can then opt for one of an A (for IPv4) record or an AAAA (for IPv6) record *under* that sub-domain, to be updated dynamically by the ddns-service. Security of this ability is provided via a 16-character api-access-key they can generate for you (or you can specify your own).

If you don't have an HE.net account, you will need to [open a free account](https://ipv6.he.net/certification/register.php "https://ipv6.he.net/certification/register.php")

If you don't already have a domain (or subdomain) pointing to HE.net: * Go to the [DNS management page](https://dns.he.net/ "https://dns.he.net/"). * Click on **Add a new domain** (on the left side-bar) * Enter your domain or subdomain (that should *already* have pointed to their 5 nameservers), and click the green **Add domain!** button (the page may take a few seconds to respond, do not click multiple times) * Next to the *new domain*, click the 2nd icon (the one that looks like classic-windows app + pencil icon) to **Edit** the records for that dns-zone. * Click the **New A** button (for IPv4) or **New AAAA** button (for IPv6). * For **Name**, enter only the part part before the first period in the FQDN (the part that goes *before* the domain or subdomain you pointed at HE's nameserver). * ***MAKE SURE*** you click **Enable entry for dynamic dns** checkbox **ON** * Click **Submit** * Click the *icon that looks like a small two-arrows* in a circle (pointing to each other) in the **DDNS** column. * In the popup **Dynamic DNS Record**, here you can either generate a key (up to 16 characters) or specify your own. **You will need this for the password in the example config below**

(src - above steps tested and based on [this blog](https://networkingnotesblog.wordpress.com/2015/10/15/using-dynamic-dns-server-with-he-net/ "https://networkingnotesblog.wordpress.com/2015/10/15/using-dynamic-dns-server-with-he-net/")).

\*Note:* In order for a zone to be accepted for addition to HE.net's DNS-manager, it **must** *already* be configured to point to ns1.he.net / ns2.he.net / ns3.he.net / ns4.he.net / ns5.he.net. Adding the domain or subdomain to HE.net will fail w/ an error otherwise. Note: I don't know if they check for all five nameservers, but may as well just add all 5 NS records to your domain (with the registrar you setup the domain) or if a sub-domain (at your existing host.

Lastly, if you want to (it's optional) protect the update-requests that the ddns-service does, with TLS, you can see the [above section on SSL](/docs/guide-user/services/ddns/client#ssl_support1 "docs:guide-user:services:ddns:client"). The following settings have been tested/worked:

In the below example config, the (sub-)domain pointing to HE.net nameservers is “zone.domain.tld”, and the A record is “addr-a-record” (thus the full dynamic hostname will be addr-a-record.zone.domain.tld).

```
# /etc/config/ddns
config service 'dns_he_net'
        option service_name 'he.net'
        option enabled '1'
        option domain 'addr-a-record.your.domain.tld'       # this is the A or AAAA record you created and set up a DynDNS Key for 
        option lookup_host 'addr-a-record.your.domain.tld'  # same as above - script queries this to see if it's outdated and needs to be updated
        option use_ipv6 '0'                                 # whether to update your AAAA record (by default: A record)
        option username 'your.domain.tld'                   # this is not your HE.net username, but your zone (zone.domain.tld) delegated to HE.net nameservers
        option password 'XXXXXXXXXXXXXXXX'                  # this part is the generated Key for the DynDNS function 
        option ip_source 'network'
        option ip_network 'wan'
        option interface 'wan'
        option use_syslog '2'
        option check_unit 'minutes'
        option force_unit 'minutes'
        option retry_unit 'seconds'
```

More info about how this works underneath the covers: [https://dns.he.net/docs.html](https://dns.he.net/docs.html "https://dns.he.net/docs.html")

Note: There is another (older) doc here: [doc here](/docs/guide-user/services/ddns/hurricaneelectricfreedns "docs:guide-user:services:ddns:hurricaneelectricfreedns").

### mythic-beasts.com

Last updated: 2015-07-20

[Homepage](http://mythic-beasts.com/ "http://mythic-beasts.com/") -- [Support](https://www.mythic-beasts.com/support "https://www.mythic-beasts.com/support")

![FIXME](/lib/images/smileys/fixme.svg) Looking on description at “[Use Mythic Beasts Dynamic DNS with your OpenWRT router](https://www.mythic-beasts.com/support/domains/dynamic/openwrt "https://www.mythic-beasts.com/support/domains/dynamic/openwrt")” and on the existing source code I found out that there must be issues updating Dynamic DNS. I have gone in contact with support of mythic-beasts.com. I will update as soon a solution is available.

### namecheap.com

Last updated: 2015-07-21

[Homepage](https://www.namecheap.com/ "https://www.namecheap.com/") -- [Knowledgebase](https://www.namecheap.com/support/knowledgebase.aspx "https://www.namecheap.com/support/knowledgebase.aspx")

Note that with the namecheap protocol, the username option is translated to the host argument in the update request. Therefore, it should be the host-part on the DNS record, not the username that you use to log into the namecheap.com site. To update multiple hosts you might need to define separate configuration/section for each host. To get your password, log into the namecheap.com site, enter the management console for the domain, and click the Dynamic DNS menu option.

![:!:](/lib/images/smileys/exclaim.svg) Currently *ddns-scripts* only supports the case where your dynamic subdomain has the same IP address as for your unqualified domain. Otherwise you will send updates to namecheap.com every “option check\_interval” 10 minutes (default) because your FQDN is not validated. [Proposed solution here, which you can easily implement yourself](https://github.com/openwrt/packages/issues/2348 "https://github.com/openwrt/packages/issues/2348"). This may only be an issue for ddns-scripts 2.4.

Let assume you define two FQDN at your domain “example.com”: “www.example.com” and “ftp.example.com”. To update only your domain record “example.com”:

```
service_name	namecheap.com
domain		[Your domain, here: example.com]
username	@
password	[Your password]
```

To update for example only your “ftp.example.com” host:

```
service_name	namecheap.com
domain		[Your domain, here: example.com]
username	ftp
password	[Your password]
```

To update all to the same IP address:

NOTE: For namecheap updating multiple subdomains is NOT working nowadays, you have to make one request per subdomain, so configure one section per subdomain. [https://www.namecheap.com/support/knowledgebase/article.aspx/29/11/how-do-i-use-a-browser-to-dynamically-update-the-hosts-ip#comment-936527059](https://www.namecheap.com/support/knowledgebase/article.aspx/29/11/how-do-i-use-a-browser-to-dynamically-update-the-hosts-ip#comment-936527059 "https://www.namecheap.com/support/knowledgebase/article.aspx/29/11/how-do-i-use-a-browser-to-dynamically-update-the-hosts-ip#comment-936527059"):

```
service_name	namecheap.com
domain		[Your domain, here: example.com]
username	@ -a www -a ftp
		!!! @ stands for your domain, www for www.example.com, ftp for ftp.example.com
password	[Your password]
```

### noip.com

Last updated: 2024-10-03

[Homepage](http://www.noip.com/ "http://www.noip.com/") -- [SupportCenter](http://www.noip.com/support/ "http://www.noip.com/support/") -- [Dynamic DNS API](https://www.noip.com/integrate/request/ "https://www.noip.com/integrate/request/")

![:!:](/lib/images/smileys/exclaim.svg) Install the [ddns-scripts-noip](/packages/pkgdata/ddns-scripts-noip "packages:pkgdata:ddns-scripts-noip") package.

The default is to use `username` and `password` as normal inside *ddns-scripts* together with `service_name no-ip.com`.

If you want to update multiple hosts inside one configuration/section you need the following settings:

```
service_name	delete / --custom--
update_url	http://[USERNAME]:[PASSWORD]@dynupdate.no-ip.com/nic/update?myip=[IP]&hostname=

		!!! After the 'hostname=' fill in a comma separated list of hosts to update.
		Sample: host1.example.com,host2.example.com,host3.example.com without any spaces in between.
		Sample: http://[USERNAME]:[PASSWORD]@dynupdate.no-ip.com/nic/update?myip=[IP]&hostname=host1.example.com,host2.example.com,host3.example.com

domain		[Only ONE of your defined hostnames, i.e. host1.example.com]
username	[Your username]
password	[Your password]
```

### spdyn.de (old spdns.de)

Last updated: 2016-08-02

[Homepage](http://spdyn.de/ "http://spdyn.de/") -- [Wiki/FAQ](http://wiki.securepoint.de/index.php/SPDNS_FAQ "http://wiki.securepoint.de/index.php/SPDNS_FAQ") (German only)

The web-pages of *spdns.de* are now reachable at *spdyn.de*. Currently updates send to *update.spdns.de* pages are still handled but produce warnings in DDNS update log at the provder. Created accounts and domains at *spdns.de* are still working without any problems.

The default is to use your `username` and `password` as normal inside *ddns-scripts* together with `service_name spdyn.de`. If you want to use Update-Token, keep in mind that this token can only update the host it is generated for. Use this settings:

```
service_name	spdyn.de
domain		[Your defined hostname at spdyn.de]
username	[Your defined hostname at spdyn.de]
password	[The token generated for this hostname]
```

If you want to update multiple hosts inside one configuration/section you need the following settings (Update-Token doesn't work):

```
service_name	delete / --custom--
update_url	http://[USERNAME]:[PASSWORD]@update.spdyn.de/nic/update?myip=[IP]&hostname=

		!!! After the 'hostname=' fill in a comma separated list of hosts (max. 20) to update.
		Sample: host1.spdyn.de,host2.spdyn.de,host3.spdyn.de without any spaces in between.
		Sample: http://[USERNAME]:[PASSWORD]@update.spdyn.de/nic/update?myip=[IP]&hostname=host1.spdyn.de,host2.spdyn.de,host3.spdyn.de

domain		[Only ONE of your defined hostnames i.e. host3.spdyn.de]
username	[Your username at spdyn.de]
password	[Your password at spdyn.de]
```

### tunnelbroker.net

Hurricane Electric provides a free IPv6inIPv4 tunnel through Tunnel Broker that demands a permanent IP or a real-time updated one. From its [homepage](https://tunnelbroker.net/ "https://tunnelbroker.net/"): “Our free tunnel broker service enables you to reach the IPv6 Internet by tunneling over existing IPv4 connections from your IPv6 enabled host or router to one of our IPv6 routers. To use this service you need to have an IPv6 capable host (IPv6 support is available for most platforms) or router which also has IPv4 (existing Internet) connectivity.”

Apply the following patch to include that service on OpenWRT DDNS

```
grep -q -e "ipv4\.tunnelbroker\.net" /etc/ddns/services \
&& echo -e "\"tunnelbroker.net\"\t\"http://[USERNAME]:[PASSWORD]@ipv4.tunnelbroker.net/nic/update?hostname=[DOMAIN]&myip=[IP]\"\t\"good|nochg\"" >> /etc/ddns/services
```

Now you can configure your tunnelbroker ddns:

```
# /etc/config/ddns
config service 'HE6in4'
        option service_name  'tunnelbroker.net'
        option lookup_host   'hostToCheck.com'             #Change it to yours. It should be a hostname updated by a DDNS with the current IP.
        option ip_source     'web'
        option ip_url        'http://checkip.amazonaws.com/'
        option interface     'wan'                         #Change it to yours
        option username      'tunnelbrokerUSERname'        #Change it to yours. It's the same tunnelbroker login.
        option password      'tunnelbrokerDDNSpassword'    #Change it to yours. It's not the same tunnelbroker login.
        option domain        'tunnelbrokerDDNSnumber'      #Change it to yours. It's only numbers.
        option enabled       '1'
```

Instead of using a web service, that has the risk of being eventually offline, to detect the public IP, you can detect the [WAN public IP by this script](/docs/guide-user/services/ddns/client#detecting_wan_public_ip_by_script "docs:guide-user:services:ddns:client").

## Additional forum threads for configuration

[https://forum.openwrt.org/t/enabling-dynamic-dns-is-too-convoluted-difficult/152939](https://forum.openwrt.org/t/enabling-dynamic-dns-is-too-convoluted-difficult/152939 "https://forum.openwrt.org/t/enabling-dynamic-dns-is-too-convoluted-difficult/152939")
