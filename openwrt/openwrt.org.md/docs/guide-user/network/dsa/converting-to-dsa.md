# Converting to DSA

Since Openwrt 21.02 an increasing amount of devices are using DSA ([Distributed Switch Architecture](https://www.kernel.org/doc/html/latest/networking/dsa/dsa.html "https://www.kernel.org/doc/html/latest/networking/dsa/dsa.html")) for configuring network interfaces, this page aims to provide information to allow you to re-implement swconfig based configurations in DSA.

If you are upgrading your router to a firmware version that uses DSA, you should read this page.

**Note:** Follow [DSA Mini-Tutorial](/docs/guide-user/network/dsa/dsa-mini-tutorial "docs:guide-user:network:dsa:dsa-mini-tutorial") for DSA configuration information.

**Note**: DSA support does not affect wireless configuration in `/etc/config/wireless`. In particular the wireless config option ifname continues to be valid for specifying a custom name for a WiFi interface.

**Note:** Also check the [very good Youtube video from onemarcfifty](https://www.youtube.com/watch?v=qeuZqRqH-ug "https://www.youtube.com/watch?v=qeuZqRqH-ug") that talks about the theory of VLANs and describes the differences between OpenWrt 19.0x and 21.0x.

*This page is a Work In Process. If you can contribute your knowledge, we would be pleased for the help.*

## Bridge all switch ports

Gather all of the interfaces for the switch ports (wan, lan1, lan2, etc.) in one bridge interface. Remove them from other bridges if they exist.

## VLAN Configuration

Back with swconfig we had CPU ports, eth0/eth1, to tag the CPU in a VLAN (i.e. eth0.2 or eth1.2 for VLAN ID 2).

With DSA, we just create a subinterface of the bridge interface (i.e. br0.2) to get the router (CPU) involved in that VLAN.

If you specify br0.2 as the “Device” on Network → Interfaces section, OpenWrt will automatically create a subinterface of br0 with VLAN ID 2.

### swconfig &amp; DSA VLAN Configuration Comparison

Here is a comparison of VLAN configuration on swconfig and DSA.

#### swconfig

[![](/_media/media/dsa/dsa-simple-01.png)](/_detail/media/dsa/dsa-simple-01.png?id=docs%3Aguide-user%3Anetwork%3Adsa%3Aconverting-to-dsa "media:dsa:dsa-simple-01.png")

```
config switch
	option name 'switch0'
	option reset '1'
	option enable_vlan '1'

config switch_vlan
	option device 'switch0'
	option vlan '1'
	option ports '0 1 2 3 5t'
	option vid '1'

config switch_vlan
	option device 'switch0'
	option vlan '2'
	option ports '4 6t'
	option vid '2'
```

#### DSA

[![](/_media/media/dsa/dsa-simple-04.png)](/_detail/media/dsa/dsa-simple-04.png?id=docs%3Aguide-user%3Anetwork%3Adsa%3Aconverting-to-dsa "media:dsa:dsa-simple-04.png") [![](/_media/media/dsa/dsa-simple-02.png)](/_detail/media/dsa/dsa-simple-02.png?id=docs%3Aguide-user%3Anetwork%3Adsa%3Aconverting-to-dsa "media:dsa:dsa-simple-02.png")

```
config device
	option type 'bridge'
	option name 'br0'
	list ports 'lan1'
	list ports 'lan2'
	list ports 'lan3'
	list ports 'lan4'
	list ports 'wan'

config bridge-vlan
	option device 'br0'
	option vlan '1'
	list ports 'lan1:u*'
	list ports 'lan2:u*'
	list ports 'lan3:u*'
	list ports 'lan4:u*'

config bridge-vlan
	option device 'br0'
	option vlan '2'
	list ports 'wan:u*'

config interface 'lan'
        option device 'br0.1'
        option proto 'dhcp'
```

### Local

Local option will automatically assign the specified VLAN ID to the bridge interface and create a VLAN interface of the bridge interface. So the router can use the VLAN interface to be involved in that VLAN.

If you don't want the router to be involved in that VLAN, you can disable this option and run `service network restart` for this change to take effect.

### Untagged, Tagged and PVID

**Untagged Traffic**: Traffic between devices where there's no VLAN ID in the frames. Computers, printers, etc. send and receive untagged traffic by default.

**Ingress**: Traffic coming in to the bridge through an interface on the bridge

**Egress**: Traffic going out of the bridge through an interface on the bridge

**Untagged**: Frames will leave the bridge through the specified interface as untagged. Untagged ingress will be assigned to the specified VLAN ID unless PVID is set to a different VLAN ID on the interface. Tagged ingress is discarded.

**Tagged**: Frames will leave the bridge through the specified interface as tagged with the specified VLAN ID. Untagged ingress is discarded unless PVID is set to a VLAN ID on the interface. Tagged ingress is discarded if the VLAN ID on the tag doesn't match the VLAN ID(s) assigned to the interface.

**PVID**: Primary VLAN ID makes the specified VLAN ID assigned to the interface the primary one. Untagged ingress will be assigned to the specified VLAN ID. This is not useful if only a single VLAN ID is assigned to the interface as untagged.

### Egress Untagged, Egress Tagged and PVID Examples

Untagged ingress from the second interface is assigned to VLAN ID 600 in both cases.

[![](/_media/media/dsa/br-vid-filter-examples-01.png)](/_detail/media/dsa/br-vid-filter-examples-01.png?id=docs%3Aguide-user%3Anetwork%3Adsa%3Aconverting-to-dsa "media:dsa:br-vid-filter-examples-01.png")

[![](/_media/media/dsa/br-vid-filter-examples-03.png-05-29_13-48-41.png)](/_detail/media/dsa/br-vid-filter-examples-03.png-05-29_13-48-41.png?id=docs%3Aguide-user%3Anetwork%3Adsa%3Aconverting-to-dsa "media:dsa:br-vid-filter-examples-03.png-05-29_13-48-41.png")

Untagged ingress from the second interface is assigned to VLAN ID 601.

[![](/_media/media/dsa/br-vid-filter-examples-02.png)](/_detail/media/dsa/br-vid-filter-examples-02.png?id=docs%3Aguide-user%3Anetwork%3Adsa%3Aconverting-to-dsa "media:dsa:br-vid-filter-examples-02.png")

Untagged ingress from the third interface is discarded.

[![](/_media/media/dsa/br-vid-filter-examples-03.png-05-29_13-48-41.png)](/_detail/media/dsa/br-vid-filter-examples-03.png-05-29_13-48-41.png?id=docs%3Aguide-user%3Anetwork%3Adsa%3Aconverting-to-dsa "media:dsa:br-vid-filter-examples-03.png-05-29_13-48-41.png")

Untagged ingress from the third interface is assigned to VLAN 600.

[![](/_media/media/dsa/br-vid-filter-examples-04.png)](/_detail/media/dsa/br-vid-filter-examples-04.png?id=docs%3Aguide-user%3Anetwork%3Adsa%3Aconverting-to-dsa "media:dsa:br-vid-filter-examples-04.png")

Untagged ingress from the third interface is assigned to VLAN 601.

[![](/_media/media/dsa/br-vid-filter-examples-05.png-05-29_14-17-38.png)](/_detail/media/dsa/br-vid-filter-examples-05.png-05-29_14-17-38.png?id=docs%3Aguide-user%3Anetwork%3Adsa%3Aconverting-to-dsa "media:dsa:br-vid-filter-examples-05.png-05-29_14-17-38.png")

### Wireless

Back with swconfig, we couldn't directly assign wireless interfaces to VLANs. So we had to bridge wireless with an already VLAN configured ethX.X interface.

With DSA, this is not the case anymore.

Go to Network → Wireless and choose the network that wireless interfaces should attach to.

Wireless interfaces will automatically be included in the bridge and belong in the correct VLAN.

[![](/_media/media/dsa/dsa-simple-03.png)](/_detail/media/dsa/dsa-simple-03.png?id=docs%3Aguide-user%3Anetwork%3Adsa%3Aconverting-to-dsa "media:dsa:dsa-simple-03.png")

## Complex VLAN Configuration - VLANs tagged on multiple switch ports and the router

[![](/_media/media/dsa/dsa-complex-01.png)](/_detail/media/dsa/dsa-complex-01.png?id=docs%3Aguide-user%3Anetwork%3Adsa%3Aconverting-to-dsa "media:dsa:dsa-complex-01.png")

[![](/_media/media/dsa/dsa-complex-02.png)](/_detail/media/dsa/dsa-complex-02.png?id=docs%3Aguide-user%3Anetwork%3Adsa%3Aconverting-to-dsa "media:dsa:dsa-complex-02.png") [![](/_media/media/dsa/dsa-complex-03.png)](/_detail/media/dsa/dsa-complex-03.png?id=docs%3Aguide-user%3Anetwork%3Adsa%3Aconverting-to-dsa "media:dsa:dsa-complex-03.png")
