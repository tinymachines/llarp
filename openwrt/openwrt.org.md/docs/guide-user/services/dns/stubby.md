# Stubby

Stubby is an application that acts as a local DNS stub resolver using [DNS over TLS](https://en.wikipedia.org/wiki/DNS_over_TLS "https://en.wikipedia.org/wiki/DNS_over_TLS"). Stubby encrypts DNS queries sent from a client machine to a DoT-provider increasing end user privacy. Follow [DNS encryption](/docs/guide-user/services/dns/start#encryption "docs:guide-user:services:dns:start") to utilize DoT via Stubby.

## Overview

An unprotected setup without Stubby might look like this:

**local**→**internet** dnsmasq on 53→unencrypted dns on 53

A setup protected with Stubby will then look like this:

**local**→**local**→**internet** dnsmasq on 53→stubby on 5453→encrypted dns on 853

We'll basically be putting Stubby in between dnsmasq and the internet, leaving most things untouched so that dnsmasq will continue to work in OpenWrt.

## Installation

```
opkg update
opkg install stubby
```

## Configuration

Stubby can be configured directly via `/etc/stubby/stubby.yml` or via `/etc/config/stubby` when using uci. The [README](https://github.com/openwrt/packages/blob/master/net/stubby/files/README.md "https://github.com/openwrt/packages/blob/master/net/stubby/files/README.md") within the packages repository contains further information.

The default listening port for stubby is 5453 (IPv4 and IPv6 on localhost).

You can add `127.0.0.1#5453` to the list of DNS servers to forward requests to, so that requests will be forwarded to stubby.

Make sure your router advertises itself as DNS server through DHCP so that clients will benefit from Stubby.

![:!:](/lib/images/smileys/exclaim.svg) Note that this does not prevent clients in LAN to access unencrypted DNS directly (for example if they ignore the advertised router DNS through DHCP, because of a static DNS setting).

To prevent local leaks or delays, make sure stubby is the only server that is being forwarded to, and block TCP and UDP output to port 53 in wan.

![:!:](/lib/images/smileys/exclaim.svg) You might want to add `/etc/stubby/` to the list of config files that should be preserved on upgrade / backup!

## Troubleshooting

Make sure the trigger option matches the name of your WAN interface.

```
. /lib/functions/network.sh
network_flush_cache
network_find_wan NET_IF
uci set stubby.global.trigger="${NET_IF}"
uci commit stubby
```

Verify the user/group and owner/permissions are set up properly.

```
chown -R stubby:stubby /var/etc/stubby
 
# grep stubby /etc/passwd /etc/group
/etc/passwd:stubby:x:410:410:stubby:/var/run/stubby:/bin/false
/etc/group:stubby:x:410:stubby
 
# ls -l /var/etc/stubby
-r--------    1 stubby   stubby         721 Jun 15 11:31 stubby.yml
```

## External Links

- [Stubby's Website](https://dnsprivacy.org/wiki/display/DP/DNS+Privacy+Daemon+-+Stubby "https://dnsprivacy.org/wiki/display/DP/DNS+Privacy+Daemon+-+Stubby")
- [Stubby's GitHub repo](https://github.com/getdnsapi/stubby "https://github.com/getdnsapi/stubby")
