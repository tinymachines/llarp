# Libreswan L2TP/IPsec

This how-to explains how to configure an openwrt router to act as an L2TP/IPsec gateway (vpn server) using xl2tpd (for L2TP) and Libreswan (for IPsec).

The new [strongSwan documentation](/docs/guide-user/services/vpn/strongswan/start "docs:guide-user:services:vpn:strongswan:start") is currently missing an L2TP/IPsec page. Use this one as a reference for the **xl2tpd** part.

## Deprecation Note

As of OpenWrt version 20.x.x, ipsec-tools was removed for security reasons (project abandoned [http://ipsec-tools.sourceforge.net/](http://ipsec-tools.sourceforge.net/ "http://ipsec-tools.sourceforge.net/")) and will not be coming back.

See the discussion of OpenWrt developers here [https://github.com/openwrt/packages/issues/7832](https://github.com/openwrt/packages/issues/7832 "https://github.com/openwrt/packages/issues/7832").

Please use [strongswan](/docs/guide-user/services/vpn/strongswan/start "docs:guide-user:services:vpn:strongswan:start") for ipsec in OpenWrt.

If you try to install Libreswan using this manual on OpenWRT &gt; 19.07.9, you'll get an error:

```
opkg_install_cmd: Cannot install package ipsec-tools.
```

## Installation

#### Server

Install the required packages.

```
opkg update
opkg install ipsec-tools iptables-mod-ipsec kmod-crc-ccitt \
kmod-crc16 kmod-crypto-aes kmod-crypto-arc4 kmod-crypto-authenc \
kmod-crypto-core kmod-crypto-des kmod-crypto-hmac kmod-crypto-md5 \
kmod-crypto-sha1 kmod-ipsec kmod-ipsec4 kmod-ppp libreswan ppp xl2tpd
```

The libreswan package might try to drag with it the kmod-libreswan package, if it does manually uninstall it as we are not going to use it and it might interfere with the default in kernel mod-ipsec module.

#### Client

IPsec/L2TP support is installed per default on android and windows devices. For Linux clients please consult your distributions documentation in order to find what packages they recommend.

## Configuration

### xl2tpd configuration

The L2TP protocol is related to ppp and xl2tpd makes use of pppd. So the configuration of xl2tpd includes both configuring xl2tpd as well as pppd.

```
# /etc/xl2tpd/xl2tpd.conf
 
[global]
port = 1701
auth file = /etc/xl2tpd/xl2tp-secrets
access control = no
 
[lns default]
exclusive = yes
ip range = 10.1.20.31-10.1.20.50
hidden bit = no
local ip = 10.1.20.30
length bit = yes
require chap = yes
refuse pap = yes
name = vpn
ppp debug = yes
pppoptfile = /etc/ppp/options.xl2tpd
```

Here follows some explanations of some of the options.

- `port` tells xl2tpd what port to listen on, the default port for l2tp is 1701.
- `access control` allows us to enable or disable l2tp authentication. We disable that as the l2tp authentication is pretty weak and its redundant because we use chap auth via pppd and ipsec.
- `ip range` tells xl2tpd what ip numbers to hand out to connecting clients.
- `local ip` the ip the openwrt server will use.
- `require chap` and `refuse pap` is used to disable pap and require chap authentication.
- `name` is the name of the vpn connection, this is used later on XXXXXX.
- `ppp debug` is used to toggle debug output, leave it on until it all works.
- `pppoptfile` tells xl2tpd what ppp options file it should use.

The file `/etc/ppp/options.xl2tpd` should contain this.

```
lock
noauth
#debug
dump
logfd 2
#logfile /var/log/xl2tpd.log
mtu 1400
mru 1400
ms-dns 192.168.1.1
lcp-echo-failure 12
lcp-echo-interval 5
require-mschap-v2
nomppe
```

- `ms-dns` tells xl2tpd what dns-server it should configure clients to use, so alter this to suit your setup.
- `mtu` + `mru` might need som tweaking to suit your setup, so you avoid ip fragmentation.
- `lcp-echo-failure` + `lcp-echo-interval` tells xl2tpd how many echo request failures it should accept before terminating the client, and how often it should send echo requests.
- `require-mschap-v2` tells xl2tpd to require mschap-v2 authentication.
- `nomppe` instructs xl2tpd to reject mppe encryption as its of no use as we encapsulate the L2TP traffic in IPsec packets.

Add usernames and passwords and ipadresses to `/etc/ppp/chap.secrets`

```
#USERNAME  PROVIDER  PASSWORD  IPADDRESS
username	vpn	secret	10.1.20.32
```

Here each client needs a line, with the login username, the provider columns is the same as the name option se in `/etc/xl2tpd/xl2tpd.conf`. A separate password for each client and then the ip address the client should have, it should be in the range configured in `/etc/xl2tpd/xl2tpd.conf` with the `ip range` option.

### Libreswan configuration

The Libreswan configuration is pretty straightforward. The exact default config file entries have changed a bit in recent releases, but the syntax has remained the same. Libreswan is picky about whitespaces so be careful and follow the conventions as described in the ipsec.conf manpage. The config setup section contains generic settings and should only contain the following options.

```
# /etc/ipsec.conf
 
config setup
        dumpdir=/var/run/pluto
        nat_traversal=yes
        oe=off
        protostack=netkey
```

- `oe=off`, as android clients dont seem to support this option.
- `protostack=netkey` that instructs Libreswan to use the default kernel IPsec implementation.

Then there should be a section that defines the actual ipsec connection, such as this.

```
# /etc/ipsec.conf
 
conn myvpn
	auto=add
	authby=secret
	pfs=no
	type=transport
	left=xxx.xxx.xxx.xxx
	leftprotoport=17/1701
	right=%any
	rightprotoport=17/%any
	rekey=no
	keyingtries=5
```

- `auto=add` tells Libreswan we want this connection to be active at start.
- `authby=secret` specifies that we want to use PSK.
- `pfs=no` disables perfect forward security, android seems not to support this so i disable it.
- `type=transport` the type of IPsec connection we want, as L2TP does the tunneling all we need is transport mode to provide encryption.
- `left=xxx.xxx.xxx.xx` should be altered to reflect the public ip address of the openwrt router.
- `leftprotoport=17/1701` defines the connection to handle IP type 17, UDP and port 1701, the port used by L2TP traffic.
- `right=%any` allows the client to use any IP address.
- `rightprotoport=17/%any` allows the client to use UDP but any port, some L2TP implementations seem to use different source ports so the %any covers that.
- `rekey=no` tells Libreswan NOT to initiate a rekeying, as some mobile clients seem unable to handle rekeying well. Libreswan will still reply to rekeying if the client initiates it.
- `keyingtries=5` tells Libreswan to only try to reconnect/rekey to a client five times. This stops Libreswan from forever trying to bring back a failed connection.

### Network configuration

Each client L2TP connection get its own PPP interface, so we start by defining a bunch of interfaces. In this case four are defined but you can define as many as you need. You do this by adding the following lines.

```
# /etc/config/network
 
config 'interface' 'vpn0'
	option 'ifname' 'ppp0'
	option 'proto' 'none'
	option 'auto' '1'
 
config 'interface' 'vpn1'
	option 'ifname' 'ppp1'
	option 'proto' 'none'
	option 'auto' '1'
 
config 'interface' 'vpn2'
	option 'ifname' 'ppp2'
	option 'proto' 'none'
	option 'auto' '1'
 
config 'interface' 'vpn3'
	option 'ifname' 'ppp3'
	option 'proto' 'none'
	option 'auto' '1'
```

The next step is to group these interfaces together and allow traffic to and from the VPN. This is done by creating a zone that is made up by the VPN interfaces, and then allow traffic to flow to and form this zone. Add the following lines.

```
# /etc/config/firewall
 
config 'zone'
	option 'name' 'vpn'
	option 'network' 'vpn0 vpn1 vpn2 vpn3'
	option 'conntrack' '1'
	option 'input' 'ACCEPT'
	option 'output' 'ACCEPT'
	option 'forward' 'REJECT'
 
config 'forwarding'
	option 'src' 'vpn'
	option 'dest' 'lan'
 
config 'forwarding'
	option 'src' 'lan'
	option 'dest' 'vpn'
 
config 'forwarding'
	option 'src' 'vpn'
	option 'dest' 'wan'
```

For a deeper understanding of what these lines do please consult the OpenWrt documentation.

In order to allow IPsec traffic trough the firewall add the following rules.

```
# /etc/config/firewall
 
config 'rule'
	option 'target' 'ACCEPT'
	option 'src' 'wan'
	option '_name' 'ip_50_ESP'
	option 'proto' '50'
 
config 'rule'
	option 'target' 'ACCEPT'
	option '_name' 'IP_51_AH'
	option 'src' 'wan'
	option 'proto' '51'
 
config 'rule'
	option 'target' 'ACCEPT'
	option '_name' 'IKE'
	option 'src' 'wan'
	option 'proto' 'udp'
	option 'dest_port' '500'
 
config 'rule'
	option 'target' 'ACCEPT'
	option '_name' 'ipsec_NAT-T'
	option 'src' 'wan'
	option 'proto' 'udp'
	option 'dest_port' '4500'
```

This basically lets IP type 50 and 51 packets trough, this is IPsec ah and esp packets. It also opens up port 500/udp traffic, this is used for the IKE protocol that is used by IPsec to manage encryption keys. Lastly port 4500/udp is opened, this is used when ipsec operates in NAT traversal mode, e.g. when the client is behind a NAT.

The last thing we need to do is allow L2TP traffic through the firewall. We can not just open up udp port 1702 like we have done for the ipsec traffic. This would allow pure l2tp traffic trough and that is not acceptable as l2tp is unencrypted and uses somewhat weak mschapv2 authentication.

The solution is to add a custom firewall rule that only allows udp traffic on port 1702 that have been delivered with ipsec encryption.

```
# /etc/firewall.user
iptables -I INPUT 1 -p udp -m policy --dir in --pol ipsec -m udp --dport 1701 -j ACCEPT
```

Backfire have had some issues with automatically bringing up the VPN zone in the firewall, but it seems to work in trunk. In order to fix this i have just used a simple line in `rc.local` that brings up the VPN zone. After it has been brought up once it seems to work just fine.

```
# /etc/rc.local
# Apply for each VPN interface to make firewall work properly with VPN connections
ifup vpn0
```

### Client configuration

Mount manually:

```
sudo mount 192.168.1.254:/mnt/share1 /home/sandra/nfs_share
```

Or mount permanently with entries on each client PC:

```
# /etc/fstab
# Intranet
192.168.1.254:/mnt/sda2 /media/openwrt    nfs     ro,async,auto    0       0
192.168.1.254:/mnt/sda4 /media/remote_stuff    nfs     rw,async,auto    0       0
#
```

Check the [mount](http://man.cx/mount "http://man.cx/mount").

## Troubleshooting

```
nft list ruleset
```

## Notes

- The Project Homepage: [https://libreswan.org/](https://libreswan.org/ "https://libreswan.org/")
- Configuration examples: [https://libreswan.org/wiki/Configuration\_examples](https://libreswan.org/wiki/Configuration_examples "https://libreswan.org/wiki/Configuration_examples")
- A very good tutorial: [http://www.frozentux.net/iptables-tutorial/iptables-tutorial.html](http://www.frozentux.net/iptables-tutorial/iptables-tutorial.html "http://www.frozentux.net/iptables-tutorial/iptables-tutorial.html")
