# Introduction to 802.1X

One of the lesser known features of 802.11 security, at least among home and small business users, is the ability to have individual usernames and passwords on a centralized authentication server which can be used by one or more wireless access point. A key advantage of this type of setup is that individual users can be added and removed from wireless access without disrupting other users or re-keying the network, which is why it is popular with enterprise customers. If you have a more complex setup such as Active Directory for user logins, it is possible to connect your wireless network back to your Active Directory server for authenticating these users.

The wireless encryption mode used to support this type of setup is “WPA Enterprise” or “WPA2 Enterprise” on the access point. You may also see references to 802.1X, which is the standard for authenticating users (either wired or wirelessly) through a RADIUS server, and is the underlying protocol used by the WPA/2 Enterprise wireless encryption mode.

Note that the individual usernames and passwords are stored in a RADIUS server which the access point will communicate with to authenticate users. In most cases, this RADIUS server software is running elsewhere on the network (obviously the access point will need to be able to reach it), but it is possible to install and run a RADIUS server on OpenWrt as well. The installation and configuration of a RADIUS server is outside the scope of this document however a few hints will be provided. RADIUS is a standardized protocol which is supported by many server applications including the Microsoft Windows Network Policy Server (NPS) can authenticate Active Directory users. A commonly used open source RAIDUS server is FreeRADIUS.

This article may contain network configuration that depends on migration to DSA in OpenWrt 21.02

- Check if your device uses DSA or swconfig as not all devices have been migrated
- ifname@interface has been moved to device sections
- [DSA Networking](/docs/guide-user/network/dsa/start "docs:guide-user:network:dsa:start")
- [Mini tutorial for DSA network config](https://forum.openwrt.org/t/mini-tutorial-for-dsa-network-config/96998 "https://forum.openwrt.org/t/mini-tutorial-for-dsa-network-config/96998") on the forum
- [DSA in the 21.02 release notes](https://openwrt.org/releases/21.02/notes-21.02.0#new_network_configuration_syntax_and_boardjson_change "https://openwrt.org/releases/21.02/notes-21.02.0#new_network_configuration_syntax_and_boardjson_change")

## Prerequisites

Before beginning you will want to make sure you have completed the following steps:

- Installed a RADIUS server such as [FreeRADIUS](/docs/guide-user/network/wifi/freeradius "docs:guide-user:network:wifi:freeradius") (on OpenWrt or on another server). Note that in 802.1X documentation the system holding the username/password database is referred to as the “authentication server” or sometimes just the “server”.
- Configured your router as a “client” on the RADIUS server. The IP address of your router/access point must be allowed to connect to the RADIUS server and have an associated key/password which it will use to authenticate to the RADIUS server. Note that in 802.1X documentation the router/access point is referred to as the “client” or sometimes as the “authenticator” to distinguish it from the end user device which is attempting to authenticate and which is called the “supplicant”.
- Configured one or more usernames and passwords on the RADIUS server. Note that the user passwords must be stored in a format which matches the format the supplicant is using to check the password. For Windows clients this means you need to store the password as an NT/LM Hash value, for other clients it would usually be Crypt/MD5/SHA. To simplify things you can store the password as cleartext and the RADIUS server will then be able to generate the needed hashes on the fly but this has obvious security downsides and should be considered carefully but may be of use for troubleshooting.

## Basic 802.1X Wireless User Authentication

Enterprise WPA is not supported by the wpad-mini access point software on OpenWrt so you will need to remove that and install the full version of hostapd:

```
opkg update
opkg remove wpad-mini
opkg install wpad
# as of 19.07, older versions of OpenWrt may require hostapd instead of wpad
```

Next, you can modify your `/etc/config/wireless` file to support WPA Enterprise authentication. Specifically you will need to create a `wifi-iface` with the encryption option set to wpa2, a server address, and a key. One example might be:

```
config wifi-iface
      option device 'radio1'
      option mode 'ap'
      option ssid 'Test8021xNetwork'
      option network 'lan'
      option encryption 'wpa2'
      option server '192.168.1.10'
      # if you are running server on your router then server would be 127.0.0.1 meaning localhost
      option key 'MyClientPassword'
```

Where 192.168.1.10 is a previously configured RADIUS server which is expecting connections from this client (router/AP) using the password “MyClientPassword”.

## 802.1X Dynamic VLANs on an OpenWrt Router

### Introduction

In the following example we'll extend our previous 802.1X wireless network authentication to automatically assign users connecting to the SAME SSID to either the main “lan” network or a new “guest” network depending on their username. Note that some of the functionality needed to make this work was not included in OpenWrt until the “Chaos Calmer” release. It is technically possible to make dynamic VLANs work in prior releases but it requires modifying some system files, it is suggested that you run “Chaos Calmer” r43473 or newer releases if you want to use 802.1X dynamic VLANs on a router. If you really want the details on what needs to be changed see [r43473](https://dev.openwrt.org/changeset/43473/ "https://dev.openwrt.org/changeset/43473/"), [r42787](https://dev.openwrt.org/changeset/42787 "https://dev.openwrt.org/changeset/42787"), and [r41872](https://dev.openwrt.org/changeset/41872 "https://dev.openwrt.org/changeset/41872").

NOTE: You'll be working on changing the way your router's CPU connects to the switch as part of these configuration changes. If done improperly it's possible to lock yourself out of the router. If you do this you will need to be familiar with the recovery mechanism of your router so that you can get back in and reset or fix your configurations. It's a good idea to **have a backup of your working configuration before starting** and to be familiar with the way OpenWrt handles VLAN configuration (which can vary a bit from router to router). If you have physical access to your router you shouldn't be able to brick the router in such a way that it's impossible to recover but if you're working wirelessly or remotely it is possible. *It's best to setup a test network on a second router and work on that until you are familiar with the configuration as this is a tricky process to get right at first.*

### Configuration

Because we'll be working with multiple VLANs we need to create an additional VLAN for the guest network and enable VLAN tagging on the CPU port for the “lan” and “guest” VLANs so that the router can communicate with both VLANs. In this case we'll keep the “lan” network on VLAN 1 and create a new “guest” network on VLAN 3. We're skipping over VLAN 2 because the particular router used to create this demonstration uses VLAN 2 to connect the WAN port to the CPU, not all routers do this, some wire the WAN port directly to the CPU. More information on the switch port layout can be found on the OpenWrt wiki page for your particular router.

First, modify the existing “lan” VLAN to tag traffic going to the CPU port. In this example the CPU is on port 0 and ports 2, 3, 4 and 5 are the existing LAN switch ports (which we want to keep on the “lan” VLAN as they were). Port 1 on this router is a secondary CPU port used for the WAN connection. **Ports on your own router may vary, check the switch port details for your router on the OpenWrt wiki page for your specific router.** On this router the existing VLAN 1 switch configuration in the `/etc/config/network` file looks like:

```
config switch_vlan
      option device 'switch0'
      option vlan '1'
      option ports '0 2 3 4 5'
```

To start tagging VLAN 1 traffic to the CPU change it to look like:

```
config switch_vlan
      option device 'switch0'
      option vlan '1'
      option ports '0t 2 3 4 5'
```

Now create the new VLAN for guests (we're using VLAN 3 on this router):

```
config switch_vlan
      option device 'switch0'
      option vlan '3'
      option ports '0t'
```

Note that the only port in this VLAN is a tagged connection to the CPU port right now but the router will automatically bridge guest wireless users onto this VLAN following the 802.1X server's instruction. You can create additional VLANs as needed for your network design but beware the limits of the switch chip in your router. Many switch chips in consumer routers are limited to 15 VLANs.

Next we need to modify the interface configuration in the same file. Because we're now tagging VLAN traffic we need to modify the “lan” interface configuration slightly. On this router the LAN CPU port is eth1, *check the switch port details for your router on the OpenWrt wiki page for your router to determine the LAN CPU port on your own router*. Where we previously found a section like:

```
config interface 'lan'
      option ifname 'eth1'
      option type 'bridge'
      option proto 'static'
      option ipaddr '192.168.1.1'
```

We now need to make it:

```
config interface 'vlan1'
      option ifname 'eth1.1'
      option type 'bridge'
      option proto 'static'
      option ipaddr '192.168.1.1'	
```

There are TWO important changes to be made here. First, the interface MUST be named `vlan1` so that the hostapd program can find the correct interface to attach the user to. Second, the ifname MUST be changed to `eth1.1` because the traffic is now being tagged on VLAN 1 between the switch and CPU.

We also need to add a new interface on VLAN 3 for our guest network.

```
config interface 'vlan3'
      option proto 'static'
      option ipaddr '192.168.3.1'
      option netmask '255.255.255.0'
      option type 'bridge'
      option ifname 'eth1.3'
```

Note that the ifname is `eth1.3`, indicating this interface should interact with VLAN 3 on the switch CPU port and that the `ipaddr` is on a different network than VLAN 1. For simplicity's sake, I have made the third octet of the IP address equal to the VLAN number, but this is not a requirement. The connection to the VLAN is made by the interface name, the ifname option, and switch configuration only.

**Important Note:** Because you changed the name of your primary interface from “lan” to “vlan1” you will need to update your `/etc/config/dhcp` (the interface option) and `/etc/config/firewall` (the network option in the zones) files to reflect that change. *Failure to do this can lock you out of the router!*

Save the changes to your `/etc/config/network` file and issue a `/etc/init.d/network` reload command to apply them. If you did everything correctly, your command prompt will return in a few moments and you should still have access to the router. If you have a problem accessing the router, you likely disconnected your CPU port from the switch and you'll need to use the recovery mechanism of your router to get back in.

You might want to set a DHCP server up for this guest interface as well as appropriate firewall rules to allow access to the Internet yet prevent access to the other LAN systems, but doing those things is outside the scope of this document. We'll proceed assuming that you have addressing and firewall rules set up and working. Before proceeding you may want to temporarily set a separate wireless SSID up on the router which: does NOT use 802.1X; is bridged to the guest network; is verified working. Otherwise, figure that out before adding in the 802.1X dynamic VLAN complexity.

Now that we have a guest network functioning on the router, we can modify our wireless configuration to support 802.1X dynamic vlans. To do this, modify the SSID setup in your `/etc/config/wireless` file and remove the `network` option and add the `dynamic_vlan` and `vlan_tagged_interface` options. Note that `dynamic_vlan` is a tri-state setting, e.g. off=0, on=1, require=2, and is not a setting for the actual VLAN number. An example with the basic 802.1X setup found above would be:

```
config wifi-iface
      option device 'radio1'
      option mode 'ap'
      option ssid 'Test8021xNetwork'
      option encryption 'wpa2'
      option server '192.168.1.10'
      option key 'MyClientPassword'
      option dynamic_vlan     '2'
      option 'vlan_tagged_interface' 'eth1'
      option 'vlan_bridge' 'br-vlan'
      option 'vlan_naming' '0'
```

Finally, you need to ensure that your RADIUS server sends VLAN information. On FreeRADIUS each username section should look like:

```
"username"      Cleartext-Password := "password"
                Tunnel-Type = "VLAN",
                Tunnel-Medium-Type = "IEEE-802",
                Tunnel-Private-Group-ID = "1"
```

The important part being the three “Tunnel-\*” settings, where `Tunnel-Private-Group-ID` is set to the VLAN that user should be assigned.

If everything has been done correctly to this point, you should be able to reboot your router and test with some different usernames with different VLANs associated to each user respectively.

### How It Works/Troubleshooting

If you were able to make standard 802.1X work on your router and also can make VLANs work on your router but are having problems trying to do 802.1X with dynamic VLANs or you want to customize your configuration it is helpful to know how OpenWrt handles dynamic VLANs.

When we set the interface names in the above example to `vlan1` and `vlan3` and set their type to `bridge`, OpenWrt automatically created two bridges (software switches) on the router named `br-vlan1` and `br-vlan3`. You can see these bridges, and which ports they're connected to, by running the `brctl show` command which gives output like this:

```
root@OpenWrt:~# brctl show
bridge name     bridge id               STP enabled     interfaces
br-vlan1                7fff.e894f690dfb0       no              eth1.1
br-vlan3                7fff.e894f690dfb0       no              eth1.3
```

In this example output you can see the two bridges and that `eth1.1` (the CPU port for VLAN 1) and `eth1.3` (the CPU port for VLAN 3) are the only members of each respective bridge. When an 802.1X dynamic VLAN wireless client joins VLAN 1 the output will change like this:

```
root@OpenWrt:~# brctl show
bridge name     bridge id               STP enabled     interfaces
br-vlan1                7fff.e894f690dfb0       no              eth1.1
                                                                wlan0.1
br-vlan3                7fff.e894f690dfb0       no              eth1.3
```

As you can see the wlan0.1 interface (the connection for VLAN 1 traffic to wireless users on wlan0) is now a member of br-vlan1. Because `eth1.1` is a member of the same bridge, wireless users on VLAN 1 can exchange traffic with the CPU VLAN 1 port.

But how does `wlan0.1` know to connect to `eth1.1` on br-vlan1? The answer lies in the hostapd software and in the additional configuration we did in `/etc/config/wireless`.

On a normal Linux based access point, the idea is that you only need to set a `vlan_tagged_interface` option in your configuration which lets hostapd know what tagged CPU interface contains access to all VLANs. Hostapd would then automatically create sub-interfaces like `ethX.Y` where `ethX` is the tagged interface and `Y` is the VLAN number. Unfortunately this simple configuration does not work with OpenWrt because most users ALREADY use bridging on their CPU interface by setting the interface type to bridge in `/etc/config/network` which is part of the standard OpenWrt configuration as it is how non-802.1X wireless users connect to the CPU port. When you set things up that way, OpenWrt automatically creates a bridge called `br-lan` or `br-*` in front of whatever the interface name is and, then adds the physical interface such as `eth1.1` to the bridge. Run `brctl show` on an OpenWrt router which is not configured for 802.1X dynamic VLANs to see this setup.

Because a physical interface can only be a member of ONE bridge hostapd is not then able to add eth1.1 to a new hostapd created bridge for wlan0.1 so you end up with no communication. If you ran `brctl show` on a mis-configured router like this you would see one or more bridge interfaces created by OpenWrt through the `/etc/config/network` file and one bridge interface created by hostapd for each VLAN a user had tried to connect to which ONLY had the `wlan0.Y` interface as a member. Obviously if the wlan interface is the only member of a bridge, the traffic has nowhere to go so the user is unable to obtain an IP address or go anywhere.

To work around this problem we make a few changes. First, we must name our interfaces in `/etc/config/network` based on their VLAN such as `vlan1` and `vlan3`. This causes OpenWrt to name the bridges it creates `br-vlan1` and `br-vlan3`. Second, we set the `vlan_bridge` option in `/etc/config/wireless` to “br-vlan” and the `vlan_naming` option to “0” what this does is tell hostapd to create bridges using the `br-vlanY` naming convention (where `Y` is the VLAN number). As you can see those bridges will already exist based on the OpenWrt configuration and because you can only have one bridge with the same name, hostapd just adds the `wlan0.Y` interface to the existing bridge, allowing it to communicate with the `eth1.Y` interface that OpenWrt placed there.

If you have problems when you are using PEAP as EAP method, check your errors using logread. If you see this error: “IEEE 802.1X: authentication server did not include required VLAN ID in Access-Accept” you might solve it enabling `use_tunneled_reply` on radius PEAP configuration. If you are using freeradius, edit eap config (e.g. /etc/freeradius3/mods-enabled/eap), and change the `use_tunneled_reply` configuration inside of pear { ... } to `use_tunneled_reply = yes`, then restart freeradiusd (reload is not enough) and try again. Note that this possibly applies to other methods too.

Hopefully this section allowed you to understand how hostapd interacts with OpenWrt to allow for dynamic VLANs over 802.1X. As you can see it's a bit of a tricky configuration. When things don't seem to be working correctly with dynamic VLANs but work with fixed VLANs, a good place to start is by checking the output of the `brctl show` command to see which interfaces are being connected to each other. Once you verify that this is the problem lies, it gives you a starting point to figure out what must be modified in the configuration to get the correct interfaces bridged together.

## Encryption on wired networks

Upstream hostapd and the Linux kernel supports encryption on wired networks (using IEEE 802.1AE “MACsec” to perform encryption at layer 2), but this is not yet supported in OpenWRT. More details can be found in [this forum post](https://forum.openwrt.org/t/macsec-802-1ae-with-802-1x-eapol-key-management-with-wpa-supplicant/194433 "https://forum.openwrt.org/t/macsec-802-1ae-with-802-1x-eapol-key-management-with-wpa-supplicant/194433").

## Additional Resources

WPA Enterprise options can be found in the [Wireless documentation](/docs/guide-user/network/wifi/basic#wpa_enterprise_access_point "docs:guide-user:network:wifi:basic").
