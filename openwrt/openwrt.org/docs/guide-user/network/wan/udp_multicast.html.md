# IPTV / UDP multicast

Lots of ISPs provide their users with an IPTV service, usually done via IPv4 UDP multicasting. This document aims to explain how to make it work for most common scenarios.

## Basic concepts

When a host wants to start receiving UDP multicast traffic, it needs to subscribe itself to a “UDP multicast group”. In IPv4 Control of multicast groups is achieved with IGMP protocol. In IPv6 its accomplished with special Multicast Listener Discovery (MLD) packets in the ICMPv6 protocol. Once a host is subscribed, all the traffic for this group is sent to it using [broadcast L2 frames](http://en.wikipedia.org/wiki/IP_multicast#Layer_2_delivery "http://en.wikipedia.org/wiki/IP_multicast#Layer_2_delivery"). This detail is important because common bridges just pass all the broadcast traffic to all the ports. So if you use Linux to bridge wireless and wired networks (usual scenario for home LANs) and you subscribe to a multicast group from one of the wired clients, the wireless will be flooded too. The Linux kernel and most managed switches are able to use IGMP snooping to decide which ports need to be flooded. This feature is disabled by default in OpenWrt software bridges but can be enabled with a single line in the configuration for the bridge. When enabled, it should prevent unnecessary traffic on ports that were not actually subscribing such as WiFi ports when only a wired client has requested multicast.

Another important consideration is that multicasting over wireless doesn't usually work as one might expect since it uses the lowest possible bitrate (to enable all clients to “hear” it) and also employs special tricks for power-saving. Basically, this makes multicasting useless for IPTV over WiFi as it limits the total bandwidth to a few megabits. The solution is to convert the multicast stream into a unicast stream sent just to the one WiFi client that wants to hear it. The udpxy program is capable of making this conversion.

### Using igmpproxy for IPv4 multicast streams

In the usual scenario, LAN clients such as smart TVs wish to receive multicast streams from an ISP IPTV service operating on IPv4. Since the LAN clients are behind the OpenWrt router they can not simply send an IGMP request and start receiving the relevant TV data as only other machines on the LAN will hear the IGMP request. Instead the OpenWrt router must act as a router for multicast packets and igmpproxy does this by listening for and proxying the IGMP requests to the ISP as well, and then enabling forwarding of the UDP packets from WAN to LAN.

OpenWrt has the package [igmpproxy utility](https://github.com/pali/igmpproxy "https://github.com/pali/igmpproxy") to do that. It listens on a “downstream” (LAN) interface for IGMP requests, when it hears them, it makes a similar request on the upstream (WAN) side. This request is heard by ISP equipment (or even just a smart switch on WAN) and when upstream routers are configured correctly the flow of multicast data will begin to arrive on WAN shortly after the request is sent. The igmpproxy adds routes and rules to the kernel which cause the kernel to forward these multicast UDP packets received on the WAN to the LAN where they are received by the original requester.

First you need to install the package

`opkg install igmpproxy`

You need to edit `/etc/config/igmpproxy` according to your setup. For a usual situation with a simple WAN and LAN network:

```
config igmpproxy
        option quickleave 1

config phyint
        option network wan
        option zone wan # the upstream firewall zone for forward rules
        option direction upstream
        list altnet 0.0.0.0/0 # a description of allowed source addresses for multicast packets

config phyint
        option network lan
        option zone lan #the downstream firewall zone for forward rules
        option direction downstream
```

#### Network interface settings

To avoid flooding all ports of your LAN bridge, including WiFi, you can enable IGMP snooping on your LAN interface:

`/etc/config/network`

```
config interface lan
        option type bridge
        option igmp_snooping 1
        ...
```

#### Firewall settings

In older versions of igmpproxy it used to require firewall rules. However current versions insert the rules automatically during start-up of the igmpproxy daemon.

You will see two rules inserted into the appropriate forward chain, in iptables-save format they would look like:

```
-A zone_wan_forward -d 239.255.255.250/32 -p udp -m comment --comment "!fw3: ubus:igmpproxy[instance1] rule 1" -j zone_lan_dest_DROP
-A zone_wan_forward -d 224.0.0.0/4 -p udp -m comment --comment "!fw3: ubus:igmpproxy[instance1] rule 2" -j zone_lan_dest_ACCEPT
```

The first rule drops SSDP packets that would cause WAN side services to be advertised on your LAN. The second rule allows forwarding of any other multicast packets. However forwarding will only occur for those packets where igmpproxy will insert routing rules.

In some circumstances it \*may* be useful to set multicast packets to have a time to live that allows them to transit the OpenWrt router without dying. Adding a line such as this to the /etc/firewall.user may be required:

```
iptables -t mangle -A PREROUTING -i eth0 -d 224.0.0.0/4 -p udp -j TTL --ttl-set 2
```

This will cause multicast UDP packets to have a TTL of 2 prior to being routed by OpenWrt allowing them to be sent out the LAN interface with TTL=1. You can increase the value further if you need to route the packets further across sub-networks in your personal network. This rule may especially be required if you use VLC to provide a testing multicast stream on the WAN side, as by default it outputs a TTL=1 preventing routing.

#### Force IGMP version

In some situations the upstream traffic requires IGMPv2. To force the OpenWrt kernel to use IGMPv2 on all interfaces if necessary, you can add the following line to /etc/sysctl.conf. Try it without first and only add if you experience a problem.

```
net.ipv4.conf.all.force_igmp_version=2
```

### Custom multicast application running in the router

If you got a custom software running in the router, which want to listen or send data to the multicast, then add the below route so that all the wireless clients and the router can listen/send to the multicast group.

```
route add -net 224.0.0.0 netmask 224.0.0.0 wlan0
```

### Multicast Streams Over WiFi with Unicast conversion (udpxy)

If you wish to access multicast streams over WiFi, the bandwidth efficient way is to convert it to unicast so that high speed modulation can be used. The udpxy package enables this functionality.

Install the luci-app-udpxy package:

```
opkg update; opkg install luci-app-udpxy
```

Go to Luci &gt; Services &gt; udpxy

Click Enabled, enter the IP address of the LAN interface into “Bind IP/Interface” (default 192.168.1.1) enter a port number not in use already on the router (default is 4022)

Most other fields can be left blank, click save and apply.

Now if you have a multicast stream you wish to listen to, and your router has default 192.168.1.1 address and you want to hear an example multicast rtp stream sent to 224.0.1.2 on port 345 you can enter into the browser on your LAN machine:

`http://192.168.1.1:4022/rtp/224.0.1.2:345/`

and udpxy running on the router will listen for the rtp stream and convert it into an MPEG-TS stream and send it to your device.

For more information about udpxy see: [udpxy README](http://www.udpxy.com/download/udpxy/README.txt "http://www.udpxy.com/download/udpxy/README.txt")

#### Using igmpproxy and udpxy together

When using igmpproxy together with udpxy, the igmpproxy will already create the required firewall rules and nothing is required.

#### Firewall configuration for udpxy

ALERT: this may be out of date information?

When using udpxy you need to accept IGMP traffic and also you need to allow it for INPUT:

```
config rule
        option src      wan
        option proto    igmp
        option target   ACCEPT
config rule
        option src      wan
        option proto    udp
        option dest_ip  224.0.0.0/4
        option target   ACCEPT
```

## IPv6

IPv6 uses MLD see [Multicast\_Listener\_Discovery](https://en.wikipedia.org/wiki/Multicast_Listener_Discovery "https://en.wikipedia.org/wiki/Multicast_Listener_Discovery")
