# B.A.T.M.A.N. / batman-adv

This article may contain network configuration that depends on migration to DSA in OpenWrt 21.02

- Check if your device uses DSA or swconfig as not all devices have been migrated
- ifname@interface has been moved to device sections
- [DSA Networking](/docs/guide-user/network/dsa/start "docs:guide-user:network:dsa:start")
- [Mini tutorial for DSA network config](https://forum.openwrt.org/t/mini-tutorial-for-dsa-network-config/96998 "https://forum.openwrt.org/t/mini-tutorial-for-dsa-network-config/96998") on the forum
- [DSA in the 21.02 release notes](https://openwrt.org/releases/21.02/notes-21.02.0#new_network_configuration_syntax_and_boardjson_change "https://openwrt.org/releases/21.02/notes-21.02.0#new_network_configuration_syntax_and_boardjson_change")

[B.A.T.M.A.N.](https://en.wikipedia.org/wiki/B.A.T.M.A.N. "https://en.wikipedia.org/wiki/B.A.T.M.A.N.") is derived from “Better Approach To Mobile Adhoc Networking” and works for stationary systems as well.

In addition to providing node-to-node and node-to-net connectivity, batman-adv can provide bridging of multiple VLANs over a mesh (or link), such as for “trusted” client, guest, IoT, and management networks. It provides an easy-to-configure alternative to other approaches to “backhaul”, such as WDS connections, GRE tunnels, and various “relay” and “pseudo-relay” approaches.

batman-adv can run on top of a variety of mesh implementations, including 802.11s, ad-hoc (IBSS), and multiple point-to-point links, wired or wireless.

batman-adv is reasonably robust to topology changes, typically adapting within a couple seconds.

batman-adv does *not* provide encryption or authentication. If required, it should be implemented either or both in the underlying transport (encrypted, authenticated mesh, for example), or protocols (IPSEC, TLS, ssh, ...).

- `batman-adv` is a mesh protocol for a Layer 2 networking (like Ethernet frames) running in the kernel
- `batmand` is a user-space daemon for an older B.A.T.M.A.N. protocol that operates at Layer 3 (like TCP/IP packets)

Unless you've got a strong reason to use the older, Layer 3 protocol (such as interoperation with an existing mesh), `batman-adv` is suggested. This page documents configuration of `batman-adv` for a local mesh.

For further information, see, for example

- [Documentation on the B.A.T.M.A.N. Project Homepage](http://www.open-mesh.org/projects/open-mesh/wiki "http://www.open-mesh.org/projects/open-mesh/wiki")
- [http://www.open-mesh.org/wiki/open-mesh/BranchesExplained](http://www.open-mesh.org/wiki/open-mesh/BranchesExplained "http://www.open-mesh.org/wiki/open-mesh/BranchesExplained")
- [batctl man page](https://downloads.open-mesh.org/batman/manpages/batctl.8.html "https://downloads.open-mesh.org/batman/manpages/batctl.8.html")

Special thanks to the authors of this OpenWrt walk-through

- [https://www.radiusdesk.com/old\_wiki/technical\_discussions/batman\_basic](https://www.radiusdesk.com/old_wiki/technical_discussions/batman_basic "https://www.radiusdesk.com/old_wiki/technical_discussions/batman_basic")

**This page now applies to OpenWrt with `batman-adv` 2019.1 and later.**

The configuration approach for `batman-adv` changed in March 2019, See [commit 54af5a2](https://git.openwrt.org/?p=feed%2Frouting.git%3Ba%3Dcommit%3Bh%3D54af5a209e0a0a75b5eb712c0ca8056e66de02c0 "https://git.openwrt.org/?p=feed/routing.git;a=commit;h=54af5a209e0a0a75b5eb712c0ca8056e66de02c0") for further details.

The last [revision of this page discussing the older configuration](https://openwrt.org/docs/guide-user/network/wifi/mesh/batman?rev=1555021785 "https://openwrt.org/docs/guide-user/network/wifi/mesh/batman?rev=1555021785") is still available.

# Installation and Configuration of batman-adv

802.11s configuration developed and tested on `openwrt-18.06` and `master` in September, 2018 on Archer C7v2 units running the non-CT firmware (see note above about configuration changes if running 18.06 and its older version of `batman-adv`.

Current (2019.1 and later) `batman-adv` configuration confirmed on EA8300 and `master` in May, 2019.

## Does Your Device Support 802.11s or IBSS?

Typically, either 802.11s or IBSS (“ad hoc”) is required to set up a mesh.

IBSS configuration is not discussed in detail on this page. See further [WiFi /etc/config/wireless](/docs/guide-user/network/wifi/basic "docs:guide-user:network:wifi:basic")

Note that not all driver / firmware combinations support 802.11s mesh (or IBSS). This may be checked with `iw phy`, looking for “mesh point” (or “IBSS”) in the various sections of the output. If the -CT drivers/firmware do not support mesh on your device, it may be the case that the “classic” (no -CT) variants do.

```
root@test:~# iw phy | fgrep mesh
		 * mesh point
		 * #{ managed } <= 16, #{ AP, mesh point } <= 16, #{ IBSS } <= 1,
		 * mesh point
		 * #{ managed } <= 16, #{ AP, mesh point } <= 16, #{ IBSS } <= 1,
		 * mesh point
		 * #{ managed } <= 16, #{ AP, mesh point } <= 16, #{ IBSS } <= 1,
```

It has been reported that certain Marvell chips supported by the `mwlwifi` driver do not support 802.11s, even if indicated in the capabilities.  
See further [https://github.com/kaloz/mwlwifi/issues?utf8=%E2%9C%93&amp;q=is%3Aissue+802.11s](https://github.com/kaloz/mwlwifi/issues?utf8=%E2%9C%93&q=is%3Aissue%20802.11s "https://github.com/kaloz/mwlwifi/issues?utf8=%E2%9C%93&q=is%3Aissue+802.11s")

## Overview

In this walk-through the following steps are described

- Install needed packages for batman-adv
- Configure a mesh on which batman-adv will run
- Configure batman-adv to use the mesh
- Configure one or more VLANs to be routed by batman-adv

While an 802.11s mesh is described here, an ad-hoc (IBSS) mesh, or point-to-point links can also be utilized.

Note that use of Ethernet links with their typical MTU of 1500 will reduce the PMTU to below 1500 due to the batman-adv headers. batman-adv is typically configured to [manage fragmentation](https://www.open-mesh.org/news/43 "https://www.open-mesh.org/news/43"), with the attendant slight reduction in throughput when packets are fragmented. For many use cases, the higher speeds, lower latency, and/or reliability of an Ethernet link will make up for this effect.

## Installation

```
opkg update
opkg install kmod-batman-adv
```

Suggested for ease of monitoring and debugging

```
opkg install batctl
```

![:!:](/lib/images/smileys/exclaim.svg) if `batctl` isn't available, install `batctl-default`.

To enable use of 802.11s mesh:

```
# Remove
opkg remove wpad-basic
opkg remove wpad-basic-wolfssl

# Install
opkg install wpad-mesh-openssl  # or wpad-mesh-wolfssl
```

If building/assembling your own image, you will need to remove the default `wpad-basic` as it conflicts with `wpad-mesh-*`.

[As of September 2019](https://github.com/openwrt/openwrt/commit/49cc712b44c76e99bfb716c06700817692975e05 "https://github.com/openwrt/openwrt/commit/49cc712b44c76e99bfb716c06700817692975e05"), `wpad-openssl` or `wpad-wolfssl` are ***also*** sufficient for 802.11s use and are the **full version** of `wpad`.

**Notes:**

1. `wpad-basic-wolfssl` only has **802.11r** and **802.11w** support.
2. `wpad-mesh-openssl` and `wpad-mesh-wolfssl` only have **802.11r/w** and **802.11s** support.
3. `wpad-openssl` and `wpad-wolfssl` are the **full version** of `wpad` and have **802.11k/v/r/w** and **802.11s** support.
4. The **full version** of `wpad` means that nothing was trimmed to reduce its size like the `basic` or `mesh` versions.

## Configuration

### General

Configuration for batman-adv from 2019.1 and onward is done in `/etc/config/network` (only). There is no `/etc/config/batman-adv` file used with current versions.

Options for an interface with `option proto 'batadv`' are described in the `batctl` man page, available at this time at [https://downloads.open-mesh.org/batman/manpages/batctl.8.html](https://downloads.open-mesh.org/batman/manpages/batctl.8.html "https://downloads.open-mesh.org/batman/manpages/batctl.8.html")

The UCI configuration is applied by `/lib/netifd/proto/batadv*.sh` at this time.

VLAN-specific configuration is not discussed here, but can be see by examining `/lib/netifd/proto/batadv_vlan.sh` and consulting the batman-adv documentation.

### (1) 802.11s Encrypted, Authenticated Mesh

For purposes of this walk-through, an 802.11s mesh is used. Other mesh and point-to-point links can be used.

***WARNING - Do not configure a full 802.11s backhaul using uci, iw or packages like mesh11sd as the resulting HWMP mac routing is incompatible with batman-adv.***

Configure *all* mesh nodes with the same `/etc/config/wireless` stanza:

```
config wifi-iface 'mesh0'
        option device 'radio5pci'
        option ifname 'mesh0'
        option network 'nwi_mesh0'
        option mode 'mesh'
        option mesh_fwding '0'
        option mesh_id '<your advertised mesh "name" goes here>'
        option encryption 'psk2+ccmp'
        option key '<your secure pass phrase goes here>'
```

*Note that in 18.01 “key” is the proper place to put the passphrase, not “sae\_password”*

Important points:

In many places I use a more descriptive name than default configuration or add a name that is not required for clarity.

- `radio5pci` needs to match the declaration in `/etc/config/wireless` of your device, such as `config wifi-device 'radio5pci`'
  
  - The radios all need to be on the same channel and be configured to interoperate with each other (basically configured the same as each other)
- `mesh0` is a *fixed* identifier for the name of the interface itself, for clarity (otherwise it will be dynamically assigned)
- `nwi_mesh0` is a reference to the entry in `/etc/config/network` that will be used to set the MTU and associate it with a batman-adv interface. Its name is selected here for readability, not to match a construct such as OpenWrt's prefixing of interface names.
- `mesh_fwding '0`' turns off 802.11s forwarding/routing; it will be handled by batman-adv at each node
- `psk2+ccmp` is believed to be the most secure option for home users at this time

Once applied, `mesh0` should be seen in the output of `ip link`.

```
8: mesh0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP mode DORMANT group default qlen 1000
    link/ether 32:23:03:xx:xx:xx brd ff:ff:ff:ff:ff:ff
```

The operation of the mesh can be confirmed with `iw dev mesh0 station dump`. You should see the other peers in the listing with `mesh plink: ESTAB` indicating that the peering has been successful.

Click to reveal example `iw dev mesh0 station dump` output

Click to reveal example `iw dev mesh0 station dump` output

```
root@test:~# iw dev mesh0 station dump
Station c6:6e:1f:xx:xx:xx (on mesh0)
	inactive time:	50 ms
	rx bytes:	40640
	rx packets:	439
	tx bytes:	966
	tx packets:	7
	tx retries:	0
	tx failed:	0
	rx drop misc:	2
	signal:  	-87 [-88, -92, -95, -95] dBm
	signal avg:	-86 [-88, -91, -95, -95] dBm
	Toffset:	366695690570 us
	tx bitrate:	6.0 MBit/s
	rx bitrate:	6.0 MBit/s
	rx duration:	0 us
	last ack signal:-95 dBm
	mesh llid:	0
	mesh plid:	0
	mesh plink:	ESTAB
	mesh local PS mode:	ACTIVE
	mesh peer PS mode:	UNKNOWN
	mesh non-peer PS mode:	ACTIVE
	authorized:	yes
	authenticated:	yes
	associated:	yes
	preamble:	long
	WMM/WME:	yes
	MFP:		yes
	TDLS peer:	no
	DTIM period:	2
	beacon interval:100
	connected time:	17 seconds
Station 1a:d6:c7:xx:xx:xx (on mesh0)
	inactive time:	50 ms
	rx bytes:	38909
	rx packets:	418
[...]
```

If testing the mesh prior to association with an entry in `/etc/config/network`, you may need to use `ip` to bring the interfaces up and modify their parameters, such as MTU.

### (2) Associate batman-adv With Mesh

Now that the mesh is (or could be) up and running, create the batman-adv interfaces for routing traffic over the mesh.

Configure *all* mesh nodes with the same two `/etc/config/network` stanzas:

The first, `bat0`, is the “control” interface. Here it is taken verbatim from [commit 54af5a2](https://git.openwrt.org/?p=feed%2Frouting.git%3Ba%3Dcommit%3Bh%3D54af5a209e0a0a75b5eb712c0ca8056e66de02c0 "https://git.openwrt.org/?p=feed/routing.git;a=commit;h=54af5a209e0a0a75b5eb712c0ca8056e66de02c0") that introduced the 2019 configuration.

Adjust if you have a reason to do so. Options for an interface with `option proto 'batadv`' are described in the `batctl` man page, available at this time at [https://downloads.open-mesh.org/batman/manpages/batctl.8.html](https://downloads.open-mesh.org/batman/manpages/batctl.8.html "https://downloads.open-mesh.org/batman/manpages/batctl.8.html")

```
config interface 'bat0'
	option proto 'batadv'
	option routing_algo 'BATMAN_IV'
	option aggregated_ogms 1
	option ap_isolation 0
	option bonding 0
	option fragmentation 1
	#option gw_bandwidth '10000/2000'
	option gw_mode 'off'
	#option gw_sel_class 20
	option log_level 0
	option orig_interval 1000
	option bridge_loop_avoidance 1
	option distributed_arp_table 1
	option multicast_mode 1
	option network_coding 0
	option hop_penalty 30
	option isolation_mark '0x00000000/0x00000000'
```

The second puts a “physical” link under the control of `bat0`.

In this case, the wireless management in OpenWrt will do the association of the wireless interface when it comes up. See the [commit 54af5a2](https://git.openwrt.org/?p=feed%2Frouting.git%3Ba%3Dcommit%3Bh%3D54af5a209e0a0a75b5eb712c0ca8056e66de02c0 "https://git.openwrt.org/?p=feed/routing.git;a=commit;h=54af5a209e0a0a75b5eb712c0ca8056e66de02c0") for suggestions of how to add other link types.

```
config interface 'nwi_mesh0'
	option mtu '2304'
	option proto 'batadv_hardif'
	option master 'bat0'
```

Important points:

- `nwi_mesh0` needs to match the declaration in `/etc/config/wireless` of your device, such as `option network 'nwi_mesh0`'
- The MTU is set to 2304 here, what an 802.11s link will support. A minimum of 1532 is suggested to provide batman-adv routing of typical 1500-byte Ethernet packets. The MTU cannot exceed the link's native MTU.

At this time (Fall, 2018, batman-adv 2018.2), the default routing algorithm is BATMAN\_IV (4). BATMAN\_V (5), in the author's experience, is not robust in this on-premise application. See, for example, [https://forum.openwrt.org/t/batman-v-routing-on-prem-connectivity-loss-seen/20432](https://forum.openwrt.org/t/batman-v-routing-on-prem-connectivity-loss-seen/20432 "https://forum.openwrt.org/t/batman-v-routing-on-prem-connectivity-loss-seen/20432")

With the mesh up and the network configuration done, you should see `bat0` in the output of `ip link`. The output of `batctl o` and/or `batctl n` should indicate that the various batman-adv nodes are “seeing” each other over the mesh.

Click to reveal diagnostic output

Click to reveal diagnostic output

```
8: bat0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000
    link/ether ea:cb:a5:xx:xx:xx brd ff:ff:ff:ff:ff:ff
9: mesh0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 2304 qdisc noqueue master bat0 state UP mode DORMANT group default qlen 1000
    link/ether 32:23:03:xx:xx:xx brd ff:ff:ff:ff:ff:ff
    
root@test:~# batctl n
[B.A.T.M.A.N. adv openwrt-2019.2-0, MainIF/MAC: mesh0/32:23:03:xx:xx:xx (bat0/ea:cb:a5:xx:xx:xx BATMAN_IV)]
IF             Neighbor              last-seen
        mesh0	  c6:6e:1f:xx:xx:xx    0.730s
        mesh0	  32:b5:c2:xx:xx:xx    0.950s
        mesh0	  1a:d6:c7:xx:xx:xx    0.140s
```

### (3) Bridge VLANs Over batman-adv

*Note: This does not discuss how to [configure switches for VLANs](/docs/guide-user/base-system/basic-networking "docs:guide-user:base-system:basic-networking"), [associate wireless interfaces with bridges](/docs/guide-user/network/wifi/basic "docs:guide-user:network:wifi:basic"), or [firewall traffic](/docs/guide-user/firewall/start "docs:guide-user:firewall:start"). Please consult other documentation for details of those operations as they may apply to your situation.*

With batman-adv now able to route packets among peers, the remaining step is to use that facility to route “useful” traffic.

As appropriate for each node, edit `/etc/config/network` based on these examples. Multiple VLANs can be bridged/routed over a single batman-adv interface.

The `option delegate '0`' “turns off” certain IPv6-related features on the interface. If you are using IPv6, you should examine if this is the proper setting for your application.

By current convention, OpenWrt will name the interfaces for bridges by prefixing them with `br-` yielding `br-vlan1111` and the like. There is the typical 15-character limit on interface names in the Linux kernel, which needs to include the `br-` prefix.

These bridges will have an MTU no larger than the smallest MTU of its bridged interfaces. As soon as a typical Ethernet-like interface is included, the MTU will be 1500 or less, even if one or more members of the bridge have a larger MTU. This is how bridges operate in Linux, in general, not an OpenWrt-specific limitation.

#### Bridge With IPv4 Address

```
config interface 'vlan1111'
        option type 'bridge'
        option stp '1'
        option ifname 'eth1.1111 bat0.1111'
        option proto 'static'
        option ipaddr '192.168.11.11'
        option netmask '255.255.255.0'
        option delegate '0'
```

#### Bridge Without IPv4 Address

```
config interface 'vlan2222'
        option type 'bridge'
        option stp '1'
        option ifname 'eth1.2222 bat0.2222'
        option proto 'none'
        option auto '1'
        option delegate '0'
```

#### Bridge Without Ethernet Interface

(such as for “only” a bridged wireless interface)

```
config interface 'vlan3333'
        option type 'bridge'
        option stp '1'
        option ifname 'bat0.3333'
        option proto 'none'
        option auto '1'
        option delegate '0'
```

### Bridging with DSA

Since OpenWrt version 21.02.0, DSA architecture is used for the switch instead of `swconfig`.  
For any of the above examples to work, you must first make the Bridge and VLANs in `/etc/config/network` and bridge the Batman VLANs.

You can change what's bridged, you can refer to [DSA Mini-Tutorial](/playground/richb/dsa-mini-tutorial "playground:richb:dsa-mini-tutorial") AND [Converting to DSA](/docs/guide-user/network/dsa/converting-to-dsa "docs:guide-user:network:dsa:converting-to-dsa")

#### Bridging all LAN ports and Batman VLAN interfaces (later to be separated by VLANs)

```
config device
	option name 'br-lan'
	option type 'bridge'
	list ports 'lan1'
	list ports 'lan2'
	list ports 'lan3'
	list ports 'lan4'
	list ports 'bat0.1' # Batman VLAN 1
	list ports 'bat0.2' # Batman VLAN 2
	option stp '1'
	option igmp_snooping '1'
	option ipv6 '0'
	option mtu '2304'
```

#### Driver-level VLANs

```
# VLAN 1, br-lan.1, the VLAN with all ports bridged together (you can change what to bridge)
config bridge-vlan
	option device 'br-lan'
	option vlan '1'
	list ports 'lan1'
	list ports 'lan2'
	list ports 'lan3'
	list ports 'lan4'
	list ports 'bat0.1'

# VLAN 2, br-lan.2, using only Batman's 2nd VLAN, separated from the rest
config bridge-vlan
	option device 'br-lan'
	option vlan '2'
	list ports 'bat0.2'
```

#### Network interfaces

```
# LAN with VLAN 1, and bridged(as stated above) with Batman VLAN 1 and all 4 Ethernet ports
config interface 'lan'
	option device 'br-lan.1' # VLAN number 1
	option proto 'static'
	option ipaddr '192.168.1.254'
	option netmask '255.255.255.0'
	option force_link 'yes'

# Guest network in VLAN 2, and bridged(as stated above) with Batman VLAN 2
config interface 'guest'
	option device 'br-lan.2'
	option proto 'static'
	option ipaddr '192.168.2.254'
	option netmask '255.255.255.0'
	option force_link 'yes'
```

The 2nd node should disable DHCP and sport a similar setup, the only difference is to use different IPs for the networks (lan: `192.168.1.254` and guest: `192.168.2.254` should use another IP in that subnet)

```
# LAN with VLAN 1, and bridged(as stated above) with Batman VLAN 1 and all 4 Ethernet ports
config interface 'lan'
	option device 'br-lan.1' # VLAN number 1
	option proto 'static'
	option ipaddr '192.168.1.100'
	option netmask '255.255.255.0'
	option force_link 'yes'

# Guest network in VLAN 2, and bridged(as stated above) with Batman VLAN 2
config interface 'guest'
	option device 'br-lan.2'
	option proto 'static'
	option ipaddr '192.168.2.100'
	option netmask '255.255.255.0'
	option force_link 'yes'
```

### (Optional) /etc/bat-hosts

*This is not a required step -- It makes some diagnostic output easier to read.*

By creating the file `/etc/bat-hosts` the output of many `batctl` commands will replace the MAC addresses with symbolic names. These names do not need to be the host name, nor be consistent with DNS.

The MAC address to use is that of the “raw” interfaces that are used by `bat0` -- in this example configuration, those of `mesh0` on each of the nodes.

```
32:b5:c2:aa:aa:aa	office.5g
c6:6e:1f:bb:bb:bb	garage.5g
32:b5:c2:cc:cc:cc	front.5g
1a:d6:c7:dd:dd:dd	back.5g
c6:e9:84:ee:ee:ee 	devel.5g
```

### batman-adv Options for bat0 (the main mesh interface)

These are options for the main network interface in `/etc/config/network` for batman-adv.

**This section was written using the official batman-adv docs as reference and is subject to change, please read the official documentation if something doesn't work as expected**

Name Type Default Range Description `aggregated_ogms` boolean `1` `0`, `1` **OGMs** AKA **Originator Messages** are messages used to determine the qualities needed to direct neighbors and spreading this message throughout the whole mesh, aggregating them reduces the number of packets being sent. `routing_algo` string `BATMAN_IV` `BATMAN_IV` or `BATMAN_V` Which routing algorithm to use - more info below but for now use `BATMAN_IV` until `BATMAN_V` is ready for actual use. `bonding` boolean `0` `0`, `1` If some interfaces are similar in quality and speed, it's possible to distribute frames through them using Round Robin which shows a 50% throughput increase, but if the links aren't similar in speed and since it isn't detected by BATMAN\_IV, you may actually lose throughput, so it should be done explicitly on known nodes. `fragmentation` boolean `1` `0`, `1` Since batman-adv prepends its own headers and some clients aren't aware of that, packets are optimized for 1500 MTU even though 1528 is required, if it isn't possible with some devices fragmentation is used(the algorithm that handles fragmented data). `gw_mode` string `off` `off`, `client`, `server` Gateway mode, if set to `server` other nodes are notified of that node's internet connection and **must** be complemented by `gw_bandwidth`, that notifies the algorithm that server is one of the best paths for internet access.  
If set to `client`, the criteria by which batman-adv will choose a gateway(other nodes with `gw_mode` set as `server`) is **required** to be set with `gw_sel_class`. `gw_bandwidth` string `10000/2000` `not specified` **(Server)** Set the bandwidth, so `client` nodes will know about the gateway's quality stated by `download/upload`, units can be suffixed with `mbit` or `kbit` (`10mbit/2mbit`), if you state download but not upload, upload defaults to the value of `download / 5`, so 100mbit without upload would default to 100 / 5 = 20mbit. `gw_sel_class` integer **BATMAN\_IV** `20`  
**BATMAN\_V** `5000` **BATMAN\_IV** `1`, `256`  
**BATMAN\_V** `0`, `Not specified` **(Client)** Set the criteria by which to select a gateway(internet connection) indicated by TQ.  
With **BATMAN\_IV\_** set in `routed_algo`:  
default: `20` (late switch)  
`1` (Fast), prioritize by advertised throughput and link quality, use until gateway disappears.  
`2` (Stable), prioritize by link quality only, use until gateway disappears.  
`3` (Fast Switch), prioritize link quality only, but scan and switch to a better gateway if found.  
`XX` (Late Switch), prioritize link quality only, but scan and switch to a better gateway if found, which is at least `XX` TQ better than the currently selected gateway, where XX is between 3-256.  
With **BATMAN\_V** set in `routed_algo`:  
default: `5000` (Late Switch), 5000 kbit/s throughput.  
example: `1500` (Fast Switch), scan and switch to another gateway only if its throughput is at least 1500 kbit/s faster than the current, throughput is evaluated by determining what's lower: advertised throughput or the maximum bandwidth across the entire path. `log_level` integer `0` `0`, `255` (8 bit Bitmask) Standard warning/error messages are sent to the kernel log, but more is possible(depending if compiling with debugging enabled).  
\[0] all debug output disabled (none)  
\[1](BIT 0 set) messages related to routing / flooding / broadcasting (batman),  
\[2](BIT 1 set) messages related to route added / changed / deleted (routes)  
\[4](BIT 2 set) messages related to translation table operations (tt)  
\[8](BIT 3 set) messages related to bridge loop avoidance (bla)  
\[16](BIT 4 set) messages related to arp snooping and distributed arp table (dat)  
\[32](BIT 5 set) messages related to network coding (nc)  
\[64](BIT 6 set) messages related to multicast (mcast)  
\[128](BIT 7 set) messages related to throughput meter (tp)  
\[255](ALL BITS set) Enable all messages  
**NOTE:** Integer values are form the [Kernel docs](https://www.kernel.org/doc/html/v5.0/networking/batman-adv.html#logging-debugging "https://www.kernel.org/doc/html/v5.0/networking/batman-adv.html#logging-debugging") and bitfield from [batman-adv source](https://github.com/open-mesh-mirror/batman-adv/blob/master/net/batman-adv/log.h#L38 "https://github.com/open-mesh-mirror/batman-adv/blob/master/net/batman-adv/log.h#L38") `orig_interval` integer `1000` `not specified` Specified in milliseconds, the interval in which batman-adv floods the network with its protocol information, '1000' as a default means a message per second which allows batman to recognize a route change up to a minute. In a static environment(nodes aren't moving, rare up/down of nodes) you might want to increase the interval value to save bandwidth, inversely, in a highly mobile environment(cars) but remember that will drastically increase traffic.  
It's recommended to keep the default unless there are problems. `bridge_loop_avoidance` boolean `1` `0`, `1` In bridged LAN setups, this should be enabled in order to avoid broadcast loops that can completely flood the entire LAN(this option might need to be compiled), if you don't connect multiple batman-adv hosts to the same ethernet or don't use bridging, you can disable this option. `distributed_arp_table` boolean `1` `0`, `1` Mesh-wide ARP table cache, helps non-mesh clients get ARP responses more reliably without much delay(this option might need to be compiled). `multicast_mode` boolean `1` `0`, `1` A more efficient, group aware multicast forwarding infrastructure, aiming to reduce unnecessary packet transmissions, if disabled, every multicast traffic will flood every node(broadcast). `multicast_fanout` integer `16` `not specified` Requires and related to `multicast_mode`, batman-adv detects potential multicast listeners who are interested in traffic to a given multicast destination address, so no listeners means nothing is transmitted.  
The default value of `16` is the max number of listeners before a classic flooding of all multicast frames is used, if it's equal or under `16`, batman-adv can use individual unicast transmissions instead - that's the fanout  
**NOTE:** Classic multicast flooding will still happen if:  
\-- No IGMP/MLD querier  
\-- The packet's destination is an IPv4 multicast  
\-- The IPv6 multicast destination is `ff02::1`. `network_coding` boolean `1` `0`, `1` Combine two packets into a single transmission, which saves air-time but **requires**:  
\-- At least 3 nodes to be effective  
\-- One node must act as a relay which has this option enabled  
\-- Relay must support Promiscuous mode (both receive and send)  
\-- Support MTU value of at least 1546. `hop_penalty` boolean `30` `not specified` Modify batman\_adv's preference for multihop routes vs short routes, the value is applied to the TQ of each forwarded OGM, propagating the cost of an extra hop(packet must be received and re-transmitted), the higher it's the more unlikely other nodes will choose the current node as an intermediate hop towards any node, otherwise, a lower value will result in longer routes because re-transmissions aren't penalized. `ap_isolation` boolean `0` `0`, `1` Standard WiFi APs support AP Isolation, which prevents clients communicating with each other, if the WiFi AP interface is bridged into batman-adv mesh network, it might be desirable to extend this isolation throughout the mesh by enabling this option. `isolation_mark` string `0x00000000/0x00000000` `0`, `1` An extension of `ap_isolation`, it allows the user to decide which client is classified as isolated via firewall rules, increasing the flexibility of the isolation, batman-adv extracts the fwmark the firewall attached to each packet it receives through the soft-interface and decides based on that value if the source client is isolated or not, this value is defined as a `value/mask`, in the firewall, a simple case is to mark all the packets coming with a fwmark using `tc`, you then set the fwmark you've set with `tc` in this option for it to work.

![:!:](/lib/images/smileys/exclaim.svg) Options that might need to be compiled are options the official B.A.T.M.A.N docs state which require compiling, OpenWrt packages batman-adv so you might not need to and it depends on what's actually compiled.

**BATMAN\_IV** uses OGM to determine link quality and spread the message in the mesh, there are drawbacks, wireless interfaces suffer packet loss over time, which ends with more overhead(due to the transmission protocol), also it would be better to detect link quality changes faster than spreading it through the mesh first(far-end of mesh doesn't care anyways) and it might be possible to avoid OGM for certain tasks.

**BATMAN\_V** apparently has some problems on-site currently, but it's the better algorithm, since ELP(Echo Location Protocol) was introduced, which is a packet that doesn't forward/re-broadcast in the mesh used for neighbor discovery, besides, OGM v2 is used to further determine the overall best transmit paths and that task separation is what leads to reduced overhead, neighbor discovery can be individual and multiple interface handling can be reduced and finally BATMAN\_V uses throughput as a metric \*instead* of a packet loos metric like in BATMAN\_IV.

**TQ** - **Transmit Quality** algorithm (Batman IV), used to define a better path by finding both the receiving **and** transmitting quality of a node, where transmit speed is prioritized, TQ is calculated by propagating an OGM message and finding the best paths, the value of TQ starts as the max 255(count from 255 to 0) and through each node's TQ is re-calculated and transmitted to the next node etc..

# In Operation

## On- and Off-Mesh Access

When bridging VLANs as described above, with one node bridging to the wired networks, off-mesh clients have access to mesh clients and vice-versa without any additional configuration. Off-mesh clients can also access other off-mesh clients over the mesh (such as clients of different APs and/or those on the wired network). With a five-node, on-premise mesh using BATMAN\_IV, initial ping requests are typically returned within one or two seconds.

## Multiple Nodes Bridging to Same Network Segment

Use of multiple nodes bridged to the same wired networks has not been deeply examined at this time. STP *might* be sufficient as a “poor-man's” approach, though there have been cases with other networking protocols where bridge loops involving the on-device switches did not seem to be detected and resolved by STP alone.

A quick test with two of the OpenWrt nodes (of the five deployed and participating in batman-adv) connected to the wired network through Cisco SG300-series switches had a “fail-over” occur after unplugging the “active” cable in ~90 seconds, with disturbances evident for another half minute. The output of `batctl cl` (“claim table”) appears to empty and update on about the same time scale. STP in the OpenWrt bridges has a hello\_time of 2.00 s, max\_age of 20.00 s, and forward\_delay of 2.00 s, suggesting an STP cut-over time of ~26 seconds. Watching the claim table on one node while bringing down `bat0` on the “preferred gateway” (without changing Ethernet connectivity) showed a one-minute delay before those associated with the down node were removed. As a result, at this time the delays are believed to be primarily due to batman-adv operation.

There is a [batman-adv feature around advertising gateways](https://www.open-mesh.org/projects/batman-adv/wiki/Gateways "https://www.open-mesh.org/projects/batman-adv/wiki/Gateways"). It appears to be designed for larger-scale deployments and seems to work by moderating DHCP assignments, rather than by dynamically routing packets with the mesh-routing logic itself.

## Other Systems' Logs Flooded With kernel: arp: 43:05:43:05:00:00 is multicast

The batman-adv [Bridge Loop Avoidance Protocol](https://www.open-mesh.org/projects/batman-adv/wiki/Bridge-loop-avoidance-Protocol "https://www.open-mesh.org/projects/batman-adv/wiki/Bridge-loop-avoidance-Protocol") appears to use gratuitous ARP for 0.0.0.0 with the multicast bit set, acknowledging that “this is a misuse of ARP packets”. Some RFC-compliant systems will log this as an error, as “Installing such entries is an [RFC 1812](https://tools.ietf.org/html/rfc1812#section-3.3.2 "https://tools.ietf.org/html/rfc1812#section-3.3.2") violation, but some proprietary load balancing techniques require routers to do so.”

Disabling Bridge Loop Avoidance Protocol in `/etc/config/batman-adv` with `option bridge_loop_avoidance 0` is one way to resolve this, though STP or other loop-avoidance methods are strongly suggested if this done.

For FreeBSD and FreeBSD-based systems, setting `net.link.ether.inet.allow_multicast=1` should remove the log messages, but will “pollute” the ARP table as described in [arp(4)](http://man.cx/arp%284%29 "http://man.cx/arp%284%29").
