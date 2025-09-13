# IPv6 on L2TP softwire

This page documents how to configure IPv6 over a L2TP softwire, which is a method used by some ISP to provide IPv6 connectivity.

## About softwires

Softwire is the new fancy term for network tunnels, aka encapsulation. Reasonably accurate definitions about softwires are given in [RFC 4925](http://tools.ietf.org/html/rfc4925 "http://tools.ietf.org/html/rfc4925"), and [RFC 5571](http://tools.ietf.org/html/rfc5571 "http://tools.ietf.org/html/rfc5571") describes an implementation using L2TPv2.

Softwires are used as basic blocks to transport newer protocols (typically IPv6) over an older network (typically, the IPv4 core network of an ISP).

## ISP using softwires to provide IPv6

SFR, in France, is known to use softwires to provide IPv6 to its residential customers. See some [documentation (in French)](http://bitsofnetworks.org/utiliser-ipv6-chez-sfr-sans-la-neufbox-fr.html "http://bitsofnetworks.org/utiliser-ipv6-chez-sfr-sans-la-neufbox-fr.html").

## Overview

This howto is derived from an experience with SFR, in France (FTTH residential access). It might applies to other ISPs as well, but you'll need to adapt IP addresses, PPP login and passwords, and so on.

The high-level description of the tunneling is the following:

1. a L2TP tunnel is created, encapsulated in UDP packets over IPv4
2. a PPP session is established inside the tunnel
3. IPv6CP (see [RFC 5072](http://tools.ietf.org/html/rfc5072 "http://tools.ietf.org/html/rfc5072")) is used to negotiate link-local IPv6 addresses
4. an IPv6 prefix is obtained thanks to DHCPv6

In the case of SFR, steps 1 and 2 require an authentication. Fortunately, the L2TP password is hardcoded. The PPP password is not, but it's sent as cleartext, so a simple sniffing is enough to recover it.

### Installation

You need to install [xl2tpd](/packages/pkgdata/xl2tpd "packages:pkgdata:xl2tpd"), which will handle the L2TP tunnel and PPP session.

### Configuration

```
# /etc/config/network
config interface 6pe
        option proto l2tp
        option server <LNS address>
        option username '<PPP username>'
        option password '<PPP password>'
        option keepalive '6'
        option ipv6 '1'
 
config interface 'wan6'
        option ifname '@6pe'
        option proto 'dhcpv6'
```

If you need authentication at the L2TP level (before PPP):

```
# /etc/xl2tpd/xl2tp-secrets
* * my_l2tp_password
```

At this point, rebooting or simply running `ifup wan6` should give you a fully working IPv6 setup. To debug, look at the logs (`logread`) and the interfaces status (`ifstatus 6pe` and `ifstatus wan6`).

Note that SFR's CPE, the Neufbox, is running a modified version of OpenWrt. Since they publish their firmware (I used the [NB6-MAIN-R3.3.4](http://download.nb6thd.neufbox.neuf.fr/nb6thd_Vers%203.3.4_ter/NB6-MAIN-R3.3.4 "http://download.nb6thd.neufbox.neuf.fr/nb6thd_Vers%203.3.4_ter/NB6-MAIN-R3.3.4") firmware), it's possible to look at their config files (and hardcoded passwords), which greatly simplifies the task.

### L2TP tunnel using xl2tpd

```
# /etc/x2ltpd/x2ltpd.conf
[global]
port = 1701
auth file = /etc/xl2tpd/xl2tp-secrets
access control = no
 
[lac 6pe]
lns = 109.6.3.95 ; address of the LNS (L2TP Network Server)
ppp debug = yes
hostname = XX.XX.XX.XX ; your public IP address
hidden bit = no
; ppp debug = yes
pppoptfile = /etc/ppp/options.xl2tpd
require authentication = no
refuse authentication = no
refuse chap = no
flow bit = yes
length bit = yes
 
# /etc/xl2tpd/xl2tp-secrets
*	*	6pe
```

#### Starting the L2TP tunnel

You need to start `xl2tpd`, and connect the profile we defined:

```
/etc/init.d/xl2tpd start
echo "c 6pe" > /var/run/xl2tpd/l2tp-control
```

There doesn't seem to be an easy way to start a profile automatically at startup. Quick &amp; dirty:

```
# /etc/rc.d/S60xl2tpd
...
(sleep 10 && echo "c 6pe" > /var/run/xl2tpd/l2tp-control) &
$BIN $OPTIONS
...
```

#### Troubleshooting

- look at the logs (`logread`)
- try to activate some `xl2tpd` debug options
- use `tcpdump` to see what's going on with the LNS

### PPP configuration

Last, you need to set PPP options for IPv6 negotiation.

```
# /etc/ppp/options.xl2tpd
# From the official firmware
ipv6 ,
+ipv6
ipv6cp-use-persistent
lock
child-timeout 20
lcp-echo-failure 3
lcp-echo-interval 20
name <your PPP login>
```

For SFR, the PPP login seems to be `dhcp/XX.XX.XX.XX@YYYYYYYYYYYY`, where `XX.XX.XX.XX` is your public IP address, and `YYYYYYYYYYYY` is the MAC address of the WAN interface of the official box, without the colons.

You then need to define the PPP password in `/etc/ppp/chap-secrets`:

```
#USERNAME  PROVIDER  PASSWORD  IPADDRESS
dhcp/XX.XX.XX.XX@YYYYYYYYYYYY * <PPP password>
```

For SFR, the password is not obvious. It's sent in cleartext, thus recoverable by sniffing the WAN port of the official box.

### Prefix delegation through DHCPv6

Once the PPP session is established inside the L2TP tunnel, a new interface `ppp0` should appear.

The only remaining step is to request an IPv6 prefix to the ISP, by using for instance the `wide-dhcp6c` client.

#### OpenWrt integration

Note that this is specific to Attitude Adjustment, as IPv6 support is expected to changed a lot in the upcoming Barrier Breaker release.

#### Interface declaration

We need to tell OpenWrt about the new interface:

```
# /etc/config/network
config interface wan6
        option ifname   ppp0
        option proto    none
```

If, at some point, you don't get a default route for IPv6, you could try to add the route yourself, where the gateway is the link-local address of the router at the other end of the softwire:

```
# /etc/config/network
config route6                           
        option interface wan6          
        option target '::/0'            
        option gateway 'fe80::XXXX:XXff:feXX:XXXX'
```
