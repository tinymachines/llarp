# Firewall and network interfaces

The goal of a router is to forward packet streams from incoming network interfaces to outgoing network interfaces. Firewall rules add another layer of granularity to what is allowed to be forwarded across interfaces - and additionally which packets are allowed to be inputted to, and outputted from, the router itself. This section discusses the relationships between the firewall code and the network interfaces.

At the heart of all routers is a hardware switch with a number of interface ports. When a packet enters one of the switch ports, the hardware switch matches a fixed field in the packet and forwards the packet to an output port which transmits it.

The switch generally uses the layer-2 destination MAC address in the packet to switch on. Each port has a cache of MAC addresses for stations reachable by (attached to) that port. Entries in the MAC cache gradually out, so must be re-discovered if used again. Layer-2 frames with a known destination MAC are switched to the desired LAN port. If the MAC is not present anywhere in the switch cache, a broadcast packet (e.g. ARP) is flooded to all LAN ports to discover which has access to the destination MAC.

OpenWrt routers have two types of LAN interface: wired Ethernet (IEEE802.3 or RFC894 Ethernet II, Ethernet II being the most common) and wireless Ethernet (IEEE802.11).

The wired LAN ports each map directly to a single switch port. Generally there is one 802.11 Wi-Fi port attached to a Wi-Fi radio chip (2.4Ghz, 5Ghz). Each handles one or more [IEEE802.11 standard](https://en.wikipedia.org/wiki/IEEE_802.11 "https://en.wikipedia.org/wiki/IEEE_802.11") protocols (e.g. 802.11a, 802.11n) and ancillary support for wireless networks (e.g. 802.11s mesh networking). The Wi-Fi chips convert the 802.11 signal into a canonical ethernet frame injected into the switch port for routing. All Wi-Fi stations connected to the 802.11 Access Point use the same radio(s) and the same switch port.

The LAN bridge interface `br-lan` combines wireless interface(s) with the wired ports to create a single logical network.

![:!:](/lib/images/smileys/exclaim.svg) Use bridging when combining WLAN and wired Ethernet ports. Otherwise partition the ports into VLANs.

## Firewall zones

The firewall of an OpenWrt router is able to collect interfaces into `zones` to more logically filter traffic. A zone can be configured to any set of interfaces but generally there are at least two zones: `lan` for the collection of LAN interfaces and `wan` for the WAN interfaces.

This simplifies the firewall rule logic somewhat by conceptually grouping the interfaces:

- A rule for a packet originating in a zone must be entering the router on one of the zone's interfaces,
- A rule for a packet being forwarded to a zone must be exiting the router on one of the zone's interfaces.

![:!:](/lib/images/smileys/exclaim.svg) recognize the **zone** concept does not significantly simplify a simple SOHO router with a single `br-lan` interface and a single `wan` interface. Each interface has a one-to-one mapping with a zone.

## Firewall and VLANs

VLAN provisioning and use is documented in:

- [VLAN Overview](/docs/guide-user/network/vlan/switch "docs:guide-user:network:vlan:switch")
- [HW switch configuration](/docs/guide-user/network/vlan/switch_configuration "docs:guide-user:network:vlan:switch_configuration")
- [Adding VLANs](/docs/guide-user/network/vlan/creating_virtual_switches "docs:guide-user:network:vlan:creating_virtual_switches")
- [Use VLANs to partition a DMZ](/docs/guide-user/firewall/fw3_configurations/fw3_dmz "docs:guide-user:firewall:fw3_configurations:fw3_dmz")

A switch partitioned into multiple VLANs futher helps to organize the switch ports. It is recommended that each VLAN map one-to-one with a zone. The advantage to using a VLAN architecture is the packets are tagged with the VLAN ID to disambiguate routing/firewall decisions.
