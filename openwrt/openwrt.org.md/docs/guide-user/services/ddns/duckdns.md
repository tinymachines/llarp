# DDNS Client DuckDNS

This article describes a *custom* configuration that uses a user-defined update URL.

![:!:](/lib/images/smileys/exclaim.svg) In most cases you can follow a much simpler setup process by selecting “duckdns.org” as your Service provider in [DDNS client](/docs/guide-user/services/ddns/client#duckdnsorg "docs:guide-user:services:ddns:client").

Use of the instructions below assumes you have [ddns-scripts](/packages/pkgdata/ddns-scripts "packages:pkgdata:ddns-scripts") installed.

- Following the link under the “Hints” header can show you if there are any changes that might be helpful, including features that aren't always present in busybox.
- Installing the `ca-certificates` package will automatically add a general collection of certificates to the directory `/etc/ssl/certs/` and enables verification of SSL certificates by any program that uses this as a default, including ddns-scripts.

## IPv4

In `/etc/config/ddns`, replace `<subdomain>` and `<duckdns-token>` with the proper values.

```
config service 'DuckDNS_ipv4'
	option enabled		'1'
	option interface	'wan'
	option username		'<subdomain>'
	option domain		'<subdomain>.duckdns.org'
	option password		'<duckdns-token>'
	option ip_source	'network'
	option ip_network	'wan'
	option check_interval	'1'
	option check_unit	'hours'
	option update_url	'https://www.duckdns.org/update?domains=[USERNAME]&token=[PASSWORD]&ip=[IP]'
	option use_https	'1'
```

Notes

- This will update anytime the `wan` network goes up, or the check (every hour) notices an inconsistency, and will force the ip to the value detected on the `wan` network (remove the `&ip=[IP]` and duckdns will auto-detect).
- The `interface` option tells ddns to update when this network changes status, namely when it goes up.
- The `domain` option is the domain held by the client, and `'nslookup $DOMAIN'` should succeed and point to the client (or router it's behind) when everything is up to date; this is used as the check to see if `$DOMAIN` points to the clients public IP.
- The `username` option is used where the `domain` option was used before, this is also reflected in the change to `update_url`
- Turning on https for improved security, using `/etc/ssl/certs/` (populated by “ca-certificates”), or “option cacert”
- The `force_interval` and `force_unit` options are unnecessary as duckdns does not expire listings if they aren't refreshed periodically.

If you want to view or edit the service in LuCI (via [luci-app-ddns](/packages/pkgdata/luci-app-ddns "packages:pkgdata:luci-app-ddns")), it is also necessary to add these options to the config:

```
    option lookup_host	'<subdomain>.duckdns.org'
    option use_ipv6		'0'
    option cacert		'/etc/ssl/certs'
```

## IPv6

ddns-scripts supports updating your duckdns.org subdomain with your IPv6 address, which is still needed for home users with dynamic IPv6 address. Even though your IPv6 address is globally addressable, as of 2024, some residential ISP still assign dynamic IPv6 address that may periodically change.

In `/etc/config/ddns`, replace `<subdomain>` and `<duckdns-token>` below with the proper values.

```
config service 'DuckDNS_ipv6'
	option enabled		'1'
	option lookup_host	'<subdomain>.duckdns.org'
	option username		'<subdomain>'
	option domain		'<subdomain>.duckdns.org'
	option password		'<duckdns-token>'
	option use_ipv6		'1'
	option ip_source	'network'
	option ip_network	'wan6'
	option interface	'wan6'
	option check_interval	'1'
	option check_unit	'hours'
	option update_url	'https://www.duckdns.org/update?domains=[USERNAME]&token=[PASSWORD]&ipv6=[IP]'
	option use_https	'1'	
```

- Enable “Use cURL” in DDNS Global Settings to avoid `GNU Wget Error: 4` [error](https://forum.openwrt.org/t/gnu-wget-error-4-failed-address-family-not-supported-by-protocol-when-using-ddns-scripts-for-ipv6/175640 "https://forum.openwrt.org/t/gnu-wget-error-4-failed-address-family-not-supported-by-protocol-when-using-ddns-scripts-for-ipv6/175640")

```
config ddns 'global'
    option use_curl '1'
```

## Further Reading

- [Dynamic DNS Client Configuration](/docs/guide-user/base-system/ddns "docs:guide-user:base-system:ddns") - All the settable options for ddns-scripts. Includes information on IPv6 (not supported by duckdns), proxies, and more.
- [Duck DNS](https://www.duckdns.org/ "https://www.duckdns.org/") - Duck DNS itself, this page also lists your domains and your token.
- [Duck DNS - Install](https://www.duckdns.org/install.jsp "https://www.duckdns.org/install.jsp") - the install page of Duck DNS for various devices.
- [ddns-scripts package](https://github.com/openwrt/packages/tree/master/net/ddns-scripts "https://github.com/openwrt/packages/tree/master/net/ddns-scripts") - package listing on Github.
- [Reddit thread](http://www.reddit.com/r/raspberry_pi/comments/1mqb9f/duckdns_a_free_ddns_just_got_better_bring_on_the/ "http://www.reddit.com/r/raspberry_pi/comments/1mqb9f/duckdns_a_free_ddns_just_got_better_bring_on_the/") - the reddit launch thread (archived, but viewable), with plenty of interesting information.
