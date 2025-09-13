This article may contain network configuration that depends on migration to DSA in OpenWrt 21.02

- Check if your device uses DSA or swconfig as not all devices have been migrated
- ifname@interface has been moved to device sections
- [DSA Networking](/docs/guide-user/network/dsa/start "docs:guide-user:network:dsa:start")
- [Mini tutorial for DSA network config](https://forum.openwrt.org/t/mini-tutorial-for-dsa-network-config/96998 "https://forum.openwrt.org/t/mini-tutorial-for-dsa-network-config/96998") on the forum
- [DSA in the 21.02 release notes](https://openwrt.org/releases/21.02/notes-21.02.0#new_network_configuration_syntax_and_boardjson_change "https://openwrt.org/releases/21.02/notes-21.02.0#new_network_configuration_syntax_and_boardjson_change")

# VLAN

VLAN is the acronym for **V**irtual **L**ocal **A**rea **N**etwork, it is a virtual partitioning of physical network switches on OSI layer 2.

It is a way to keep network clients separated from each other even if they use the same shared physical network, without setting up a whole subnet and a router. It works by adding a label (VLAN ID) on networking traffic, and using this label to route the traffic to keep isolated clients in different VLANs. To use a VLAN you need at least 2 devices supporting VLAN features (as any route requires at least 2 points), which is usually advanced routers, any OpenWrt device, and any self-respecting PC or single-board computer (Windows, MacOS, Linux and BSDs support VLANs).

OpenWrt supports [IEEE 802.1Q](https://en.wikipedia.org/wiki/IEEE_802.1Q "https://en.wikipedia.org/wiki/IEEE_802.1Q") and [IEEE 802.1ad](https://en.wikipedia.org/wiki/IEEE_802.1ad "https://en.wikipedia.org/wiki/IEEE_802.1ad") VLAN standards.

Many embedded devices with more than 1 port contain a VLAN-capable switch (all routers with a WAN port have a VLAN-capable switch for example). Single-port devices and devices where there is an ethernet controller for each port (like for example PCEngines boards or most PC hardware in general) will have VLAN managed by OS drivers.

A VLAN-capable switch is an integrated version of an independent device called “managed switch”. It is connected to an internal “ethernet” interface of your device, and it is more or less independent from the main CPU. It can place ports under the same VLAN (and they will communicate with each other) by just setting the right VLAN ID(s) on the ports (with the right configuration, below), and this will work irrespective of the fact that the network communication reaches or not the router CPU itself (do note that to configure the router itself you still need at least one VLAN to reach the CPU).

A device where there is software VLAN support is just a device with many different ethernet controllers, so if you want to place 2 interfaces in the same VLAN, AND you want these two interfaces to also route traffic to-from each other (to act as if they were a VLAN-capable switch as the one I talked about above), you need to bridge them too (i.e. both must be in the same Interface, be it **lan**, **wan** or whatever).

If you have any question, feel free to discuss this guide on the OpenWrt forum: [https://forum.openwrt.org/t/vlan-assigning](https://forum.openwrt.org/t/vlan-assigning "https://forum.openwrt.org/t/vlan-assigning")

## VLAN explained with default scenario of most OpenWrt routers

A very common default VLAN configuration on many off-the-shelf routers is the LAN↔WAN separation. OpenWrt default configuration on such devices does usually mirror the stock configuration. Most of such routers only contain a single network interface (eth0), leading to a 5-port VLAN-enabled switch that is virtually partitioned into a LAN and WAN network by using VLANs:

VLAN ID

Upstream:  
HW switch  
↑↓  
eth0 driver

Downstream:  
HW switch  
↑↓  
physical ports

CPU (eth0) LAN 1 LAN 2 LAN 3 LAN 4 WAN 1 tagged untagged untagged untagged untagged off 2 tagged off off off off untagged

In this example, VLAN ID of the LAN ports is 1 while the VLAN ID of the WAN port is 2.

Note that the terms “incoming” and “outgoing” and similar refer to network traffic reaching the switch physical ports (or internal CPU port), NOT to traffic that has already entered in the switch.

- **Tagged** on “CPU (eth0)” means that the two VLAN ID tags used in this example (1, 2) are sent to the router CPU “as tagged data”. Remember: you can only send Tagged data to VLAN-aware devices configured to deal with it properly.
- **Untagged** means that on these ports the switch will accept only the incoming traffic without any VLAN IDs (i.e. normal ethernet traffic). The switch will remove VLAN IDs on outgoing data in such ports. Each port can only be assigned as “untagged” to exactly one VLAN ID.
- **Off** no traffic to or from the tagged ports of this VLAN ID will reach these ports.

The purpose of a tagged port is to pass traffic for multiple VLANs, whereas an untagged port accepts traffic for only a single VLAN. Generally speaking, tagged ports will link switches, and untagged ports will link to end devices.

The router CPU then uses the tag information configured above to know if the data came from VLAN 1 (LAN) or VLAN 2 (WAN) and will then act accordingly. In the default configuration, the CPU will only receive and generate “Tagged” data (as there is no other way for it to tell what is what). The CPU uses driver level VLAN-management for this, as it acts as a single-port device.

Note how the WAN and LAN VLAN IDs in this example do not share any external ports. For any data to cross the WAN and LAN border, it has to pass the CPU on eth0 (where the router and firewall will be filtering the data). As said above, nothing prevents to make VLANs that bypass the CPU entirely.

## Is there a VLAN-capable hardware switch integrated in your device?

To find out if the ports of an OpenWrt device consist of several distinct network interfaces, or if it is a single network interface leading to a switch

- You can check the OpenWrt tech page for your router.
- You can run the following SSH command on your device to find out `ls -l /sys/class/net`.

Newer devices with embedded switches (like Netgear R7800) use the DSA switch driver, that creates a distinct network interface for each switch port as if they didn't have a switch at all.

Most OpenWrt-supported devices can use the DSA driver, but they aren't ported over yet because the switch configuration would change significantly and likely break any custom setup in devices in the field.

Example: The following ALIX.2D13 has 3 **real** network interfaces: eth0, eth1 and eth2. Each leads to a single non-switched physical network jack. If needed, you have to use OS-software based VLAN configuration:

```
# ls -l /sys/class/net
...
lrwxrwxrwx    1 root     root             0 Jul 25 14:10 eth0 -> ../../devices/pci0000:00/0000:00:09.0/net/eth0
lrwxrwxrwx    1 root     root             0 Jul 25 14:10 eth1 -> ../../devices/pci0000:00/0000:00:0a.0/net/eth1
lrwxrwxrwx    1 root     root             0 Jul 25 14:10 eth2 -> ../../devices/pci0000:00/0000:00:0b.0/net/eth2
```

Example: The following TP-Link TL-WDR3600 has only 1 real network interface: eth0. Its 5 physical network jacks belong to a single VLAN-capable switch, that in this example is segmented into 2 VLANs, managed by the switch-hardware : eth0.1 and eth0.2:

```
# ls -l /sys/class/net
...
lrwxrwxrwx    1 root     root             0 Jan  1  1970 eth0 -> ../../devices/platform/ag71xx.0/net/eth0
lrwxrwxrwx    1 root     root             0 Jul 21 22:13 eth0.1 -> ../../devices/virtual/net/eth0.1
lrwxrwxrwx    1 root     root             0 Jul 21 22:13 eth0.2 -> ../../devices/virtual/net/eth0.2
```

## Assigning VLAN IDs on VLAN-enabled switch hardware

The `switch` section of `/etc/config/network` is responsible for partitioning the embedded switch into several *VLANs* which appear as independent interfaces in the system although they share the same hardware.

This section might not be present on some platforms (depends on specific hardware support). Also, some switches only support 4-bit VLANs.

**The example below shows a typical configuration for systems not using** [DSA](/docs/guide-user/network/dsa/converting-to-dsa "docs:guide-user:network:dsa:converting-to-dsa"):

```
config 'switch' 'eth0'
        option 'reset' '1'
        option 'enable_vlan' '1'
 
config 'switch_vlan' 'eth0_1'
        option 'device' 'eth0'
        option 'vlan' '1'
        option 'ports' '0 1 3t 5t'
 
config 'switch_vlan' 'eth0_2'
        option 'device' 'eth0'
        option 'vlan' '2'
        option 'ports' '2 4t 5t'
 
config 'switch_vlan' 'eth0_3'
        option 'device' 'eth0'
        option 'vlan' '3'
        option 'ports' '3t 4t'
 
config 'switch_port'
        option 'device' 'eth0'
        option 'port' '3'
        option 'pvid' '3'
```

Common properties are defined within the `switch` section; vlan specific properties are located in additional `switch_vlan` sections linked to the `switch` section through the `device` option; pvid specific properties are found in `switch_port` sections linked to the `switch` section through the `device` option.

Ports can be *tagged* or *untagged*:

- The *tagged* port (`t` is appended to the port number) is the one that forces usage of VLAN tags, i.e. when the packet is outgoing, the VLAN ID tag with `vlan` value is added to the packet, and when the packet is incoming, the VLAN ID tag has to be present and match the configured `vlan` value(s).
- The *untagged* port is removing the VLAN ID tag when leaving the port -- this is used for communication with ordinary devices that does not have any clue about VLANs. When the untagged packet arrives to the port, the default port VLAN ID (called `pvid`) is assigned to the packet automatically. The `pvid` value can be selected by the `switch_port` section.

The CPU port (number `5` in our example) may be configured as tagged or untagged, it may even be omitted in the port configuration. The CPU port works like any other ordinary port and can be configured to be tagged or untagged -- when the switch routes packet to the CPU port, it appears on the corresponding switch interface (with VLAN ID tag number appended to the interface name in case of a tagged port) as incoming packet to allow software routing (to WiFi for example).

In our example, untagged packet coming to port 0 would be marked as VLAN ID 1 first, then sent to port 1 (untagged, VLAN ID tag removed), port 3 (tagged) and the CPU port (tagged), so the packet appears on `eth0.1` interface. Another packet arriving to port 2 tagged with VLAN ID 2 would be sent to port 4 (tagged) and the CPU port (tagged), the packet appears on `eth0.2` interface. Each tagged switch CPU port has a corresponding interface, in our example you see `eth0.1` and `eth0.2` in the system (as well as `eth0`). When the packet is sent by the software to the tagged CPU port, it has the corresponding VLAN ID assigned automatically. So when the software sends packet to `eth0.2`, is is marked with VLAN ID 2 tag automatically first, and then sent to port 2 (untagged, VLAN ID tag removed) and port 4 (tagged).

![:!:](/lib/images/smileys/exclaim.svg) An untagged port can have only 1 VLAN ID ![:!:](/lib/images/smileys/exclaim.svg)

## Creating driver-level VLANs

A driver-level VLAN could be created in the `interface` section by adding a dot (`.`) and the respective VLAN ID after the interface name (in the `ifname` option), like `eth1.2` for VLAN ID 2 on `eth1`. When any internal software routing decision sends the packet to the software VLAN, it leaves the respective interface (`eth1` in our example) with the VLAN tag present and VLAN ID set to the number corresponding to the interface name (`2` in our example on `eth1.2`).

If the incoming packet arrives to the interface with software VLANs (incoming packet to `eth1`) and has a VLAN ID tag set, it appears on the respective software-VLAN-interface instead (VLAN ID 2 tag arrives on `eth1.2`) -- if it exists in the configuration! Otherwise the packet is dropped. Non-tagged packets are delivered to non-VLAN interface (`eth1`) as usual.

When you bridge non-VLAN and VLAN interfaces together, the system takes care about adding VLAN ID when sending packet from non-VLAN to VLAN interface, and it automatically removes the VLAN ID when sending packet from VLAN interface to non-VLAN one.

Driver-level VLAN Interfaces may be configured manually. If not, they are created on the fly by netifd. Defining VLANs manually gives more options. The following options are supported:

Name Type Required Default Description `type` VLAN Type no 802.1q VLAN type, possible values: 8021q or 8021ad `name` Name yes *(none)* Name of device, i.e. eth0.5 or vlan5 `ifname` Parent interface yes *(none)* Name of parent/base interface, i.e. eth0 `vid` VLAN Id yes *(none)* VLAN Id `macaddr` MAC no *(none)* MAC of new interface

Let's take the example of TP-Link outdoor CPE210 wireless adapter. It has only one NIC, like most outdoor devices, but it can be extended to support several virtual NICs very easily.

In the following example, eth0 is segmented into 2 VLAN-interfaces, with VLAN ID 106 and 204 using explicit manual configuration:

```
config device
	option type '8021q'
	option ifname 'eth0'
	option vid '106'
	option name 'vlan1'
 
config device
	option type '8021q'
	option ifname 'eth0'
	option vid '204'
	option name 'vlan2'
 
config interface 'lan'
	option type 'bridge'
	option ifname 'vlan1'
	option proto 'static'
	option ipaddr '192.168.1.1'
	option netmask '255.255.255.0'
 
config interface 'wan'
	option ifname 'vlan2'
	option proto 'dhcp'
```

An equivalent configuration in implicit notation is shown below. Note that the `device` sections are missing and the VLAN ID and parent interface is derived from the `ifname` option value in dot-notation.

```
config interface 'lan'
	option type 'bridge'
	option ifname 'eth0.106'
	option proto 'static'
	option ipaddr '192.168.1.1'
	option netmask '255.255.255.0'
 
config interface 'wan'
	option ifname 'eth0.204'
	option proto 'dhcp'
```

## Assigning VLAN IDs using DSA on devices with one physical port

An equivalent VLAN configuration using **Distributed Switch Architecture** (DSA) on a simple device with one physical port (not a switch).

To get WLANs to work, bridge the wireless networks to the interfaces (e.g. 'iot' network on VLAN 2 and wlan0-1, 'guest' network on VLAN and wlan1-1).

Full known working /etc/config/network

```
config interface 'loopback'
        option ifname 'lo'
        option proto 'static'
        option ipaddr '127.0.0.1'
        option netmask '255.0.0.0'
 
config globals 'globals'
        option packet_steering '1'
        option ula_prefix 'fdfe:bdca:64ed::/48'
 
config device
        option name 'br-lan'
        option type 'bridge'
        list ports 'lan'
 
config bridge-vlan 'lan_vlan'
	option device 'br-lan'
	option vlan '1'
	list ports 'lan:u*'
 
 
config interface 'lan'
	option device 'br-lan.1'
	option proto 'dhcp'
 
 
config bridge-vlan
        option device 'br-lan'
        option vlan '2'
        list ports 'lan:t'
 
 
config interface 'iot'
        option device 'br-lan.2'
        option proto 'none'
 
 
config bridge-vlan
        option device 'br-lan'
        option vlan '3'
        list ports 'lan:t'
 
 
config interface 'guest'
        option device 'br-lan.3'
        option proto 'none'
```

brctl show

```
bridge name     bridge id               STP enabled     interfaces
br-lan          7fff.74acb915ff33       no              lan
                                                        wlan0
                                                        wlan1
                                                        lan.3
                                                        wlan0-1
                                                        lan.2
                                                        wlan1-1
                                                       
                                                        
```

With the ip-bridge package installed you can run

```
bridge v
port              vlan-id  
lan               1 PVID Egress Untagged
                  2
                  3
br-lan            1
                  2
                  3
wlan0             1 PVID Egress Untagged
wlan1             1 PVID Egress Untagged
wlan0-1           2 PVID Egress Untagged
wlan1-1           3 PVID Egress Untagged
```

If the above does not work you may need to install the **ip-full** package.

PS/2 This configuration assumes another device is providing DHCP servers per network segment (on the untagged LAN, and on the tagged VLAN 2 &amp; 3 on the same link).
