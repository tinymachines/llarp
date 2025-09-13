# DSA Mini-Tutorial

## Introduction

[Distributed Switch Architecture](https://www.kernel.org/doc/html/latest/networking/dsa/dsa.html "https://www.kernel.org/doc/html/latest/networking/dsa/dsa.html") (DSA) is the Linux kernel subsystem for network switches. Due to this upstream feature, OpenWrt implemented *DSA* to replace *swconfig* and many new routers use DSA drivers instead of swconfig drivers.

DSA does not affect wireless configuration in `/etc/config/wireless`. In particular the wireless config option `ifname` continues to be valid for specifying a custom name for a WiFi interface.

Note: due to the change to DSA if you are upgrading OpenWrt from a version prior to 21.02 (or prior to your device being changed from swconfig to DSA) it is best practice to not keep configuration. You should read the [Converting to DSA](/docs/guide-user/network/dsa/converting-to-dsa "docs:guide-user:network:dsa:converting-to-dsa") and [Upgrading to OpenWrt 21.02.0](/docs/guide-user/network/dsa/upgrading-to-2102 "docs:guide-user:network:dsa:upgrading-to-2102") articles. There is also a very good [Youtube video from onemarcfifty](https://www.youtube.com/watch?v=qeuZqRqH-ug "https://www.youtube.com/watch?v=qeuZqRqH-ug") that discusses VLANs and other differences between OpenWrt 19.07 and 21.02.

*This page is a Work In Process. It contains requests for information from future editors. Specifically, it needs:*

- *An example for a config file for wireless in Item 1 below*
- *A discussion of configuring wireless devices and interfaces*
- *Careful vetting of the information for Items 3 &amp; 4 below*

*If you can contribute your knowledge, we would be pleased for the help.*

## OpenWrt and DSA

OpenWrt allows you to configure the ports of your device using either LuCI or by editing the configuration file at `/etc/config/network`. The remainder of this document describes several common configurations:

1. Bridging all LAN ports
2. Multiple bridged networks
3. Multiple networks using VLANs
4. Multiple networks using VLAN tagging

To check your device for DSA you may use a simple search via SSH (note: might not work on all devices):

```
if grep -sq DEVTYPE=dsa /sys/class/net/*/uevent; then 
  echo "You have DSA"
fi
```

### 1. Bridging all LAN ports

In the initial (and very common) scenario, all LAN switch ports are bridged together into a single 'br-lan' device. OpenWrt configures that device with an IP protocol, address, etc. In this configuration, everything that's connected to those physical bridged ports can communicate with each other and the router itself.

**Configuring the LuCI web interface for a Bridged LAN:** The first image shows all the LAN ports (`lan1` .. `lan4`) are part of a *Bridge device* named “br-lan”. The second image shows an interface (“LAN”) that incorporates the “br-lan” device and been assigned a static address 192.168.1.1.

To add a wireless device (such as `wlan0`), open **Network → Wireless**. Edit the *Device Configuration* section to select the proper radio channel etc. Edit the *Interface Configuration* section (third image) to select the desired interface (from the Network: dropdown) and the SSID, security mode, etc.

[![](/_media/media/dsa/dsa-01-device.png?w=800&tok=589634)](/_detail/media/dsa/dsa-01-device.png?id=docs%3Aguide-user%3Anetwork%3Adsa%3Adsa-mini-tutorial "media:dsa:dsa-01-device.png")

[![](/_media/media/dsa/dsa-01-interface.png?w=800&tok=c9fd6e)](/_detail/media/dsa/dsa-01-interface.png?id=docs%3Aguide-user%3Anetwork%3Adsa%3Adsa-mini-tutorial "media:dsa:dsa-01-interface.png")

[![](/_media/media/dsa/dsa-01-wireless.png?w=800&tok=c4d039)](/_detail/media/dsa/dsa-01-wireless.png?id=docs%3Aguide-user%3Anetwork%3Adsa%3Adsa-mini-tutorial "media:dsa:dsa-01-wireless.png")

**Configuration file for a Bridged LAN:** The first half of the file below shows how the `config device` section groups the physical ports into a *bridge device* named 'br-lan'. The `config interface 'lan'` section then incorporates that 'br-lan' device, and sets its IP protocol type, address, etc. *Need to add the configuration for `wlan0` to this file.*

```
# ... in /etc/config/network

config device
	option name 'br-lan'
	option type 'bridge'
	list ports 'lan1'
	list ports 'lan2'
	list ports 'lan3'
	list ports 'lan4'

config interface 'lan'
	option device 'br-lan'
	option proto 'static'
	option ipaddr '192.168.1.1'
	option netmask '255.255.255.0'
```

### 2. Multiple bridged networks

OpenWrt can set up its switch to group multiple ports together into different bridge *interfaces* so their traffic remains separate, even though devices are plugged into the same router. For example, it might be useful to set aside certain ports for “home use” and others for “office use”.

You need only create two bridge devices: one for home and one for office, and assign different ports to each. You then create separate interfaces, and assign different IP address ranges (“subnets”) to each of those bridge devices. For example, home devices might have addresses from the range 192.168.1.1 to 192.168.1.254, while the office devices will be 192.168.13.1 to 192.168.13.254. Devices plugged into the home ports will be able to communicate with each other, and the devices in the office ports can also talk together. But the “home” ports will *not* be able to communicate with “office” ports unless there is a routing or firewall rule to allow it.

**Configuring the LuCI web interface for multiple bridged networks:** The LuCI interface created two separate bridge devices - *br-home* with the first two lan ports, and *office* with the next two ports. Next, two interfaces are created:

- *HOME*, that uses the *br-home* bridge device, and assigns the address range 192.168.1.1 to 192.168.1.254
- *OFFICE*, that uses the *office* bridge device, and assigns the address range 192.168.13.1 to 192.168.13.254

[![](/_media/media/dsa/dsa-02-device-home-office.png?w=800&tok=282d69)](/_detail/media/dsa/dsa-02-device-home-office.png?id=docs%3Aguide-user%3Anetwork%3Adsa%3Adsa-mini-tutorial "media:dsa:dsa-02-device-home-office.png")

[![](/_media/media/dsa/dsa-02-interface-home-office.png?w=800&tok=b04d58)](/_detail/media/dsa/dsa-02-interface-home-office.png?id=docs%3Aguide-user%3Anetwork%3Adsa%3Adsa-mini-tutorial "media:dsa:dsa-02-interface-home-office.png")

**Configuration file for multiple bridged LANs:** Here's the same example in `/etc/config/network`. The first half of the file below shows how each `config device` section groups two physical ports into a bridge device named *br-home* and two more ports into *office*. The `config interface 'home'` section defines an *interface* that incorporates the *br-home* device, and sets its IP protocol type, address, etc. Similarly, the `config interface 'office'` section incorporates the *office* device, and sets its configuration.

```
# ... in /etc/config/network
config device
	option name 'br-home'
	option type 'bridge'
	list ports 'lan1'
	list ports 'lan2'

config device
	option name 'office'
	option type 'bridge'
	list ports 'lan3'
	list ports 'lan4'

config interface 'home'
	option device 'br-home'
	option proto 'static'
	option ipaddr '192.168.1.1'
	option netmask '255.255.255.0'

config interface 'office'
	option device 'office'
	option proto 'static'
	option ipaddr '192.168.13.1'
	option netmask '255.255.255.0'
```

### 3. Multiple networks using VLANs

Ports can also be separated (grouped) using single bridge with multiple VLANs. That requires assigning interfaces to correct software VLANs. *This item needs careful vetting...*

Example:

[![](/_media/media/dsa/dsa-03-device.png?w=800&tok=ebc16a)](/_detail/media/dsa/dsa-03-device.png?id=docs%3Aguide-user%3Anetwork%3Adsa%3Adsa-mini-tutorial "media:dsa:dsa-03-device.png")

```
config device
	option name 'br-lan'
	option type 'bridge'
	list ports 'lan1'
	list ports 'lan2'
	list ports 'lan3'
	list ports 'lan4'

config bridge-vlan
	option device 'br-lan'
	option vlan '1'
	list ports 'lan1'
	list ports 'lan2'

config bridge-vlan
	option device 'br-lan'
	option vlan '2'
	list ports 'lan3'
	list ports 'lan4'
```

[![](/_media/media/dsa/dsa-03-interface-home-office.png?w=800&tok=489b19)](/_detail/media/dsa/dsa-03-interface-home-office.png?id=docs%3Aguide-user%3Anetwork%3Adsa%3Adsa-mini-tutorial "media:dsa:dsa-03-interface-home-office.png")

```
config interface 'home'
	option device 'br-lan.1'
	option proto 'static'
	option ipaddr '192.168.1.1'
	option netmask '255.255.255.0'

config interface 'office'
	option device 'br-lan.2'
	option proto 'static'
	option ipaddr '192.168.13.1'
	option netmask '255.255.255.0'
```

### 4. Multiple networks using VLAN tagging

With proper bridge VLAN configuration it's also possible for selected port to use VLAN tagged traffic. It also requires assigning OpenWrt interface to the correct software VLAN. *This item needs careful vetting...*

Example:

Port `lan4` uses tagged packets for VLAN 1 and has PVID 2.

[![](/_media/media/dsa/dsa-04-device.png?w=800&tok=cc2fd4)](/_detail/media/dsa/dsa-04-device.png?id=docs%3Aguide-user%3Anetwork%3Adsa%3Adsa-mini-tutorial "media:dsa:dsa-04-device.png")

```
config device
	option name 'br-lan'
	option type 'bridge'
	list ports 'lan1'
	list ports 'lan2'
	list ports 'lan3'
	list ports 'lan4'

config bridge-vlan
	option device 'br-lan'
	option vlan '1'
	list ports 'lan1'
	list ports 'lan2'
	list ports 'lan3'
	list ports 'lan4:t'

config bridge-vlan
	option device 'br-lan'
	option vlan '2'
	list ports 'lan4:u*'
```

[![](/_media/media/dsa/dsa-04-interface.png?w=800&tok=4df6a6)](/_detail/media/dsa/dsa-04-interface.png?id=docs%3Aguide-user%3Anetwork%3Adsa%3Adsa-mini-tutorial "media:dsa:dsa-04-interface.png")

```
config interface 'lan'
	option device 'br-lan.1'
	option proto 'static'
	option ipaddr '192.168.1.1'
	option netmask '255.255.255.0'
```

### 5. Firewall zones for VLANs

Every interface should have a correctly configured firewall zone. However, if you want to only use layer 2 and not layer 3 routing on a VLAN (only switching, no traffic between VLANs), you can set the interface as unmanaged (option proto 'none'), in which case do not set a firewall zone for the interface.

Keep in mind, that at least one interface should have an address (static or DHCP) in order to connect to the device for administrative purposes. That interface must be associated with a firewall zone (or rules) to accept input.

Example, where VLAN 1, 2 and 3 are only used for switching and VLAN 1 can be used to connect to the device:

config/network

```
config device 'switch'
	option name 'switch'
	option type 'bridge'
	option macaddr 'REDACTED'
	list ports 'lan1'
	list ports 'lan2'
	list ports 'lan3'
	list ports 'lan4'

config bridge-vlan 'lan_vlan'
	option device 'switch'
	option vlan '1'
	list ports 'lan1:u*'
	list ports 'lan4:t'

config bridge-vlan
	option device 'switch'
	option vlan '2'
	list ports 'lan1:u*'
	list ports 'lan4:t'

config bridge-vlan
	option device 'switch'
	option vlan '3'
	list ports 'lan3:u*'
	list ports 'lan4:t'

config interface 'lan'
	option proto 'dhcp'
	option device 'switch.1'
	
config interface 'iot'
	option proto 'none'
	option device 'switch.2'

config interface 'guest'
	option proto 'none'
	option device 'switch.3'
```

config/firewall

```
config defaults
	option syn_flood '1'
	option input 'ACCEPT'
	option output 'ACCEPT'
	option forward 'REJECT'

config zone
	option name 'lan'
	option input 'ACCEPT'
	option output 'ACCEPT'
	option forward 'ACCEPT'
	list network 'lan'
```

### 6. Security Considerations with VLANs

See [Wikipedia - VLAN Hopping](https://en.wikipedia.org/wiki/VLAN_hopping#Double_tagging "https://en.wikipedia.org/wiki/VLAN_hopping#Double_tagging")

- If using separated VLANs, it is often recommended not to use VLAN 1 for any data networks. This is because VLAN 1 is often hardcoded as a default on a lot of networking equipment and is therefore more often used in attacks and prone to accidental misconfiguration.

<!--THE END-->

- It is also often recommended to change the native VLAN on all trunk ports to an unused VLAN ID to explicitly only allow tagged traffic on trunk ports. Note that some hardware doesn't allow to mix tagged with untagged VLAN on one port, so this method cannot be used on it.

<!--THE END-->

- Similarly, for added security any unused LAN ports can be also added (as u|\*) to an unused VLAN ID.

As an example let's assume a setup where:

- VLANs 10, 20 and 30 are used for seperated VLANs without any Layer 3 routing
- Ports lan1 and lan2 are trunked ports with all VLANs
- Port lan3 is only for untagged VLAN 10
- Port lan4 is unused
- VLAN 90 is not used anywhere else and is only there for added security

Note: Because local is not checked for VLAN 90, OpenWrt won't even create a device for it and there should be no interface for it, unlike the other VLANs.

```
+---------+-------+------+------+------+------+
| VLAN ID | Local | lan1 | lan2 | lan3 | lan4 |
+---------+-------+------+------+------+------+
|    10   |   X   |   t  |   t  |  u|* |   -  |
+---------+-------+------+------+------+------+
|    20   |   X   |   t  |   t  |   -  |   -  |
+---------+-------+------+------+------+------+
|    30   |   X   |   t  |   t  |   -  |   -  |
+---------+-------+------+------+------+------+
|    90   |       |  u|* |  u|* |   -  |  u|* |
+---------+-------+------+------+------+------+
```

```
config device 'switch'
	option name 'switch'
	option type 'bridge'
	option macaddr 'REDACTED'
	list ports 'lan1'
	list ports 'lan2'
	list ports 'lan3'
	list ports 'lan4'

config bridge-vlan 'lan_vlan'
	option device 'switch'
	option vlan '10'
	list ports 'lan1:t'
	list ports 'lan2:t'
	list ports 'lan3:u*'

config bridge-vlan
	option device 'switch'
	option vlan '20'
	list ports 'lan1:t'
	list ports 'lan2:t'

config bridge-vlan
	option device 'switch'
	option vlan '30'
	list ports 'lan1:t'
	list ports 'lan2:t'

config bridge-vlan
	option device 'switch'
	option vlan '90'
	list ports 'lan1:u*'
	list ports 'lan2:u*'
	list ports 'lan4:u*'
	option local '0'

config interface 'lan'
	option proto 'dhcp'
	option device 'switch.10'
	
config interface 'iot'
	option proto 'none'
	option device 'switch.20'

config interface 'guest'
	option proto 'none'
	option device 'switch.30'
```
