# IPsec site-to-site

## Background

In our office environment we use CentOS on many of our internet facing servers. In RedHat Enterprise Linux 5 the IPsec implementation was provided by racoon (KAME), userspace tools, and NETKEY in the kernel. We set up our six office WAN using this and when it's up and running it seems to be stable, however adding a new site to the WAN seems to require resetting all of the IPsec server across the WAN. This can be accomplished by killing off the racoon service and starting it again. This is not particularly helpful. RedHat have decided to move to Libreswan for their Enterprise Linux 6 release as the default IPsec implementation using pluto for the userspace tools but keeping with NETKEY for the kernel stack. We are now in the process of migrating all our IPsec VPN connections to CentOS 6.x.

## Preparation

[IPsec](https://en.wikipedia.org/wiki/IPsec "https://en.wikipedia.org/wiki/IPsec") [Linux Journal IPsec article](http://www.linuxjournal.com/article/9916 "http://www.linuxjournal.com/article/9916") A good explanation IPsec implementations in Linux. A good grounding on Libreswan and openVPN with discussion about the two kernel stacks KLIPS and NETKEY as well as the userspace tools pluto (Libreswan) and racoon (KAME). Note KLIPS is used in openWRT and NETKEY is used in RHEL 6.x / CentOS 6.x the peculiarities of this are discussed later.

### Installation

```
opkg install libreswan
```

## Configuration

```
# vi /etc/ipsec.conf
include /etc/ipsec.d/*.conf
 
# vi /etc/ipsec.secrets
include /etc/ipsec.d/*.secret
```

These two lines allow you to create separate configuration and secret files in the `/etc/ipsec.d/` directory for each connection.

By convention it makes sense to name these files: `<connection_name>.conf` and `<connection_name>.secrets`.

### DNS

Connecting two private networks opens an interesting DNS challenge. The ACME DNS server does not only resolve official server names to IP addresses but also those of ACME internal servers. E.g. hobbit.acme.inc and its IP 10.1.2.42. As we have established a VPN connection we already can reach this host by its address. To get it by its name too we have to offer a name resolution in our home domain. With OpenWrt being very powerful we assume that our router has an active Dnsmasq DNS server. So we have two possibilities to resolve acme.inc addresses.

- **Manually**: Each acme.inc server and its IP address is put into the OpenWrt local hosts file. Dnsmasq will read this list and answer DNS requests for those ACME machines correctly. This should only be an option if we have a very restrictive VPN connection.
- **Automatically**: Dnsmasq forwards requests for acme.inc through the tunnel to the ACME DNS server. This avoids double work.

DNS forwarding through VPN tunnels is almost the same as normal DNS forwarding with one exception. Dnsmasq must use the correct source interface. By default it will use the OpenWrt internet IP for it's requests but this cannot be tunneled. So just expand the Dnsmasq forward settings in LuCI with the OpenWrt internal IP address. In our scenario we wan't to reach ACME DNS at 10.1.2.250 by using our internal IP 192.168.2.82. Don't forget to add this domain on the whitelist otherwise Dnsmasq will detect rebind attacks and discard requests.

[![](/_media/doc/howto/ipsec_dns.png)](/_detail/doc/howto/ipsec_dns.png?id=docs%3Aguide-user%3Aservices%3Avpn%3Alibreswan%3Asite2site "doc:howto:ipsec_dns.png")

## Troubleshooting

If you are having problems getting the IPsec stuff to work, try dropping the firewalls.

#### Usefull commands

```
# Interface & routing
ip a; ip r
ip xfrm policy
ip xfrm state
 
# IPsec related
ipsec look <connection name>
ipsec auto --add <connection name>
ipsec auto --up <connection name>
ipsec auto --down <connection name>
ipsec auto --delete <connection name>
 
# Ping
ping -I <local_internal_interface | local_internal_ip> <remote_internal_ip>
 
# TCP dump
tcpdump -i <external interface>
tcpdump -i <internal interface>
 
# Firewall
nft list ruleset
```
