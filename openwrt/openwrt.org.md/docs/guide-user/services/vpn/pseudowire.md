# Pseudowire

This article may contain network configuration that depends on migration to DSA in OpenWrt 21.02

- Check if your device uses DSA or swconfig as not all devices have been migrated
- ifname@interface has been moved to device sections
- [DSA Networking](/docs/guide-user/network/dsa/start "docs:guide-user:network:dsa:start")
- [Mini tutorial for DSA network config](https://forum.openwrt.org/t/mini-tutorial-for-dsa-network-config/96998 "https://forum.openwrt.org/t/mini-tutorial-for-dsa-network-config/96998") on the forum
- [DSA in the 21.02 release notes](https://openwrt.org/releases/21.02/notes-21.02.0#new_network_configuration_syntax_and_boardjson_change "https://openwrt.org/releases/21.02/notes-21.02.0#new_network_configuration_syntax_and_boardjson_change")

[Pseudo-wire](https://en.wikipedia.org/wiki/Pseudo-wire "https://en.wikipedia.org/wiki/Pseudo-wire") In today's data center an important question is: How to react on server outages? One of the possible answer to this question is a second data center in another location with a symmetric internet connection. This second data center can be run on cheap servers. With this setup, data from the primary data center can continuously be transmitted to the secondary one. If one or more server in the primary data center fail (e.g. because of hardware defect) the second data center can be used as fallback. This would be possible, if both of the data centers could be connected on layer 2 so they both share the same address range simultaneously. With expensive, proprietary hardware (e.g. Cisco) this is easily possible. For exactly this problem pseudowire switching can be used as seen in the following picture.

Proprietary setup: [![](/_media/doc/howto/l2tpv3_1.png)](http://isc.sans.edu/diary.html?storyid=8704 "http://isc.sans.edu/diary.html?storyid=8704")

Linux also supports Layer 2 coupling with VPN1 or unencrypted via the Internet. Examples therefor are:

OpenVPN in bridged to bridged mode. To achieve this the following options are used on the server side:

```
server-bridge ....
up "/etc/openvpn/bridge-start"
dev tap0
```

In the remote data center one client is provided with two VLANs. The first is used to connect to the vpn server. The second one is used later on when routing the layer 2 traffic of the first data center. In this example this is VLAN 111, which is available on the client as bridge.

```
up "/etc/openvpn/bridge-start"
client
#
/etc/openvpn/bridge-start
#!/bin/bash
#################################
# Set up Ethernet bridge on Linux
# Requires: bridge-utils
#################################
# Define Bridge Interface
br="vlan111"
# Define list of TAP interfaces to be bridged,
# for example tap="tap0 tap1 tap2".
tap="$1"
for t in $tap; do
/usr/sbin/openvpn --mktun --dev $t
done
for t in $tap; do
/usr/sbin/brctl addif $br $t
done
for t in $tap; do
/sbin/ifconfig $t 0.0.0.0 promisc up
done
```

The advantage of routing the layer 2 traffic in the unused VLAN 111 has the advantage that local traffic does not mix with the traffic of the remote data center. A disadvantage hereby is the somewhat smaller throughput due to the architecture of openvpn, as to many interrupts are required to copy the data vom kernel space to user space and back. This has a significant role when working with embedded hardware.

[![http://isc.sans.edu/diary.html?storyid=8704](/_media/doc/howto/rbridge.jpg "http://isc.sans.edu/diary.html?storyid=8704")](/_detail/doc/howto/rbridge.jpg?id=docs%3Aguide-user%3Aservices%3Avpn%3Apseudowire "doc:howto:rbridge.jpg") See [rbridge](http://www.inlab.de/rbridge/index.html "http://www.inlab.de/rbridge/index.html") and [etherip](http://lwn.net/Articles/119535/ "http://lwn.net/Articles/119535/").

Here an UDP tunnel in both directions is created to connect two Ethernet segments. An encryption of this tunnel can be implemented by using IPsec on top of this tunnel. This program, however, is not available as source code and therefor its usage is limited.

## L2TPv3 with OpenWrt

L2TPv3 is [available](http://kerneltrap.org/mailarchive/linux-netdev/2010/4/2/6273948 "http://kerneltrap.org/mailarchive/linux-netdev/2010/4/2/6273948") since Kernel 2.6.35.

So what else is to be done to get this working:

- install Linux
- confgiure the firewall
- set up the IPSEC Tunnel
- monitor the IPSEC Tunnel
- start the L2TPv3 Tunnel and bridge it on both ends

No Linux distribution has included L2TPv3 in their network setup - but OpenWrt. With OpenWrt it can be configured in the network configuration in `/etc/config/network`. Have a look at [L2TPv3 Pseudowire bridged to LAN](/docs/guide-user/network/tunneling_interface_protocols#l2tpv3_pseudowire_bridged_to_lan "docs:guide-user:network:tunneling_interface_protocols").

Openwrt can be used on many other hardware besides routers from Linksys. Even para virtual network devices are available to achieve performant network operations in virtualised environments:

- KVM - Kernel Based Virtual Machine
- XEN - [http://de.wikipedia.org/wiki/Xen](http://de.wikipedia.org/wiki/Xen "http://de.wikipedia.org/wiki/Xen")
- ESX/ESXI - VMware
- Virtual Box - Oracle

Openwrt is small, can be easily adopted and has an excellent buildchain. With this buildchain personal modifications are simple to include.

## Implementation

After the theoretical depiction follows a practical implementation using an example network environment. The used network ranges are:

- external IP address in the primary data center (141.64.161.74), gateway (141.64.161.1), netmask (Class C)
- internal IP range 10.1.0.0/24
- external IP address in the secondary data center (192.166.120.139), gateway (192.166.120.1), netmask (Class C)
- unused VLAN 111 in the secondary data center

[![](/_media/doc/howto/pseudowire-practical.jpeg)](/_detail/doc/howto/pseudowire-practical.jpeg?id=docs%3Aguide-user%3Aservices%3Avpn%3Apseudowire "doc:howto:pseudowire-practical.jpeg")

This shows the implementation of the Layer 2 coupling. First, the IPSEC tunnel between 141.64.161.75 to 192.166.120.139 is established. After succeeding, the IPs 192.168.202.5/32 and 192.168.202.9/32 are assigned to the tunnel endpoints. On top of this tunnel the L2TPv3 tunnel can be initialized. The IPSEC tunnel is needed as the connection between the data centers has to be cryptographically secure. This encryption is implemented in the kernel and can be implemented in hardware so latencies should be small and throughput should be huge. L2TPv3 is kernel based, too, which is one of the features that make it appealing in using to achieve the aspired goals.

## Implementation using OpenWrt

To implement this setup with OpenWrt in both data centers an instance (l-01 in the primary, l-02 in the secondary) has to be configured as follows.

### l-01

```
# /etc/config/network
config interface wan
	option ifname eth0
	option type bridge
	option proto static
	option ipaddr 141.64.161.74
	option netmask 255.255.255.0
	option gateway 141.64.161.1
 
config interface lan
	option ifname eth1
	option type bridge
	option proto l2tp
	option ipaddr 10.1.0.1
	option netmask 255.255.255.0
	option encap udp
	option sport 1701
	option dport 1702
	option localaddr 172.30.201.5
	option peeraddr
	172.30.201.9
 
# /etc/config/firewall
config rule
	option src    wan
	option proto    gre
	option target ACCEPT
 
config rule
	option src    wan
	option proto    esp
	option target ACCEPT
 
config rule
	option src    wan
	option proto    ah
	option target ACCEPT
 
config rule
	option src    wan
	option dest_port        500
	option proto    udp
	option target ACCEPT
 
config rule
	option src    wan
	option dest_port        4500
	option proto    udp
	option target ACCEPT
 
# /etc/ipsec.conf
# OpenSwan is being used
conn to-secondary
	type=tunnel
	left=141.64.161.74
	leftnexthop=141.64.161.1
	leftsourceip=192.168.201.5
	leftsubnet=172.30.201.5/32
	leftid="primary@rz"
	right=192.166.120.139
	rightnexthop=192.166.120.1
	rightsourceip=192.168.201.9
	rightsubnet=192.168.201.9/32
	authby=secret
	auto=start
	ike=aes128-sha-modp1024
	esp=aes128-sha1
 
# /etc/monitrc
check process pluto with pidfile /var/run/pluto/pluto.pid
start program = "/etc/init.d/ipsec restart"
stop program = "/etc/init.d/ipsec restart"
#
check host secondary with address 10.1.0.2
if failed icmp type echo count 5 with timeout 30 seconds 
then exec "/sbin/ifup lan"
```

### l-02

```
# /etc/config/network
 config interface wan
	option ifname   eth0
	option type     bridge
	option proto    static
	option ipaddr   192.166.120.139
	option netmask  255.255.255.0
	option gateway  192.166.120.1
 
config interface lan
	option ifname   eth1
	option type     bridge
	option proto    l2tp
	option ipaddr   10.1.0.2
	option netmask  255.255.255.0
	option encap     udp
	option sport     1702
	option dport     1701
	option localaddr 172.30.201.9
	option peeraddr  172.30.201.5
 
# /etc/config/firewall
	# same as l-01
 
# /etc/ipsec.conf
# OpenSwan is being used
conn to-primary
	type=tunnel
	left=141.64.161.74
	leftnexthop=141.64.161.1
	leftsourceip=192.168.201.5
	leftsubnet=172.30.201.5/32
	rightid="secondary@rz"
	right=192.166.120.139
	rightnexthop=192.166.120.1
	rightsourceip=192.168.201.9
	rightsubnet=192.168.201.9/32
	authby=secret
	auto=start
	ike=aes128-sha-modp1024
	esp=aes128-sha1 
 
# /etc/monitrc
check process pluto with pidfile /var/run/pluto/pluto.pid
start program = "/etc/init.d/ipsec restart"
stop program = "/etc/init.d/ipsec restart"
#
check host secondary with address 10.1.0.1
if failed icmp type echo count 5 with timeout 30 seconds 
then exec "/sbin/ifup lan"
```

## Explanations

The functionality of both the IPSEC and the L2TPv3 tunnel are assured by the use of the daemon monit on both ends. If one of the tunnels is destroyed an ifup lan is triggered to restart the connection. In the secondary data center eth1 has to be in VLAN 111. Because of this, the internal network of the primary data center can be used without the interference of layer 2 noise. This means the internal network of the primary data center is bridged in the VLAN 111 in the secondary data center.

## Bridging of devices with varying MTUs

For now the setup works so both sides can ping each other. An ssh connection, however, is either not possible or freezes after a few seconds.

The reason: The bridge for the L2TPv3 contains devices with different MTUs. Furthermore, as the connection is bridged no routing happens, the MTU is not automatically adjusted by the router. All devices in the LAN usually use an MTU of 1500. The MTU of the L2TPv3 devices is about 1400. As the tunnel itself can not fragment packets all packets bigger than the MTU are lost. This happens at longer HTTP request, too.

To solve the problem bridge firewalling and TCP MSS Clamping is used. Bridge firewalling means the iptables rules are used when a packet passes a bridge. Normally this should not work, as a bridge only works in Layer 2. However, if bridge firewalling is enabled in the kernel a bridge can work in Layer 2 as well as Layer 3.

The following sysctl keys are used for this:

- net.bridge.bridge-nf-call-iptables
  
  - 0 - do not send IPv4 traffic through iptables
  - 1 - do send IPv4 traffic through iptables
- net.bridge.bridge-nf-filter-vlan-tagged
  
  - 0 - do not send vlan tagged Ipv4 traffic through iptables
  - 1 - send vlan tagged Ipv4 traffic through iptables

IPv6 have to be configured separately.

For the example setup the rules should be like this:

```
iptables -I FORWARD -s 10.1.0.0/24 -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --set-mss 1400
iptables -I FORWARD -d 10.1.0.0/24 -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --set-mss 1400
iptables -I FORWARD -s 10.1.0.0/24 -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu
iptables -I FORWARD -d 10.1.0.0/24 -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu
```

These rules should be narrowed as good as possible to avoid unpleasant side affects.
