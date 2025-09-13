# Wi-Fi Extender/Repeater with Bridged AP over Ethernet

Bridged AP configuration (sometimes known as a “Dumb AP” or simply an “AP”) is used to add WiFi to an existing network using an **Ethernet uplink**. This is commonly used in situations where the router does not have wifi and/or where there is a need to increase wifi coverage throughout a space by adding one or more dedicated APs. As mentioned, this method requires that the bridged AP is connected to the upstream network with a wired Ethernet connection, and it simply transparently bridges the wired LAN with a Wifi SSID. This configuration allows your wifi devices to participate on the same network as your wired ones, and broadcast traffic from LAN-to-WLAN and vice versa works without any additional configuration.

As an AP, the device will not perform any duties beyond simply bridging Ethernet and Wifi. That is to say that it will not be responsible for routing, firewall, DHCP, or DNS, as these are performed by the upstream router and/or other device(s). Wireless clients connecting to the AP will get an IP address from the DHCP server already running on the network, and will send traffic to the existing router to reach the internet.

[![Bridged AP example](/_media/doc/recipes/bridged.ap_v3.png?w=450&tok=38e09e "Bridged AP example")](/_detail/doc/recipes/bridged.ap_v3.png?id=docs%3Aguide-user%3Anetwork%3Awifi%3Awifiextenders%3Abridgedap "doc:recipes:bridged.ap_v3.png")

Overview of configuration for a Wireless AP:

1. The wireless AP is connected LAN-to-LAN to the router/upstream network by **Ethernet**.
2. The wireless AP bridges its LAN interface to an SSID (wifi network). WiFi traffic will traverse the bridge to reach the router and/or other lan devices.
3. The wireless AP device may hold either a static IP address on the same subnet as the upstream network, or it may obtain an address via DHCP from the upstream DHCP server.
4. The wireless AP does not provide services such as DHCP, DNS, or firewall as this is done on the router and/or other device(s).

## Method 1: Configuration via Editing Config Files

The changes below assume a default OpenWrt configuration. The relevant files are:

- [/etc/config/network](/docs/guide-user/network/network_configuration "docs:guide-user:network:network_configuration")
- [/etc/config/dhcp](/docs/guide-user/base-system/dhcp "docs:guide-user:base-system:dhcp")
- [/etc/config/wireless](/docs/guide-user/network/wifi/basic "docs:guide-user:network:wifi:basic")

### Step 1: Change the LAN interface

Edit `/etc/config/network` and change the lan `interface` section to set the IP your access point should have in the future:

```
config interface 'lan'
        option device 'br-lan'
        option proto 'static'
        option ipaddr '192.168.1.2'
        option netmask '255.255.255.0'
        option gateway '192.168.1.1'
        option dns '192.168.1.1'
```

This must be an *unused* IP within the network subnet of the main router. You could also change `proto` from `static` to `dhcp` if you want the main DHCP server to provide an address to the AP. When using DHCP client mode, remove the last 4 lines above. Keep in mind that the access point needs a DHCP server to obtain an address. Should the DHCP server be unavailable, it is possible that the AP will not have an address and it will not be possible to administer the AP until it has obtained a new DHCP lease.

### Step 2: Configure and enable the wireless network

In `/etc/config/wireless`, locate the existing `wifi-device` and `wifi-iface` sections. Change the SSID, encryption type, and passphrase according to your needs, set your country code, and then enable the radio. When you're done, it will look something like this:

```
config wifi-device 'radio0'
	option type 'mac80211'
	option path 'platform/soc/18000000.wifi'
	option channel '1'
	option band '2g'
	option htmode 'HE20'
	option disabled '0'
	option cell_density '0'
	option country 'US'
 
config wifi-iface 'default_radio0'
	option device 'radio0'
	option network 'lan'
	option mode 'ap'
	option ssid 'YourSSID'
	option encryption 'psk2'
	option key 'YourSecurePassphrase'
```

If your device contains multiple radios, such as a 2G and 5G bands, you'll probably want to do the same for the other radio(s). It is generally recommended to use the same SSID and passphrase for all bands so that the client device can use its own internal logic to determine the best band to use at any given time.

### Step 3: Disable the DHCP server on the lan interface

It is critical that the DHCP server is disabled for the lan interface since only one DHCP server may be running on a subnet at a time. Within the \`/etc/config/dhcp\` file, find the lan DHCP server. Add \`option ignore '1'\` to the lan DHCP server as shown below and remove the DHCPv6 related entries:

```
config dhcp 'lan'
	option interface 'lan'
	option start '100'
	option limit '150'
	option leasetime '12h'
	option dhcpv4 'server'
	option ignore '1'
```

Note: It is not recommended or necessary to disable the dnsmasq service. Disabling the dnsmasq service will stop the DHCP server, but may result in it becoming reactivated should the service be started again such as during a sysupgrade event. The only way to guarantee that the DHCP server will be disabled is to set the ignore flag as shown above.

Likewise, the firewall can be left as-is and it does not need to be disabled.

### Step 4: Connect host router and openwrt router correctly

Ensure the host router is connected with a LAN port of the wireless AP, not the WAN port!

### Step 5: Apply changes

Once the changes have been made to the \`/etc/config/network\`, \`/etc/config/wireless\`, and \`/etc/config/dhcp\` files, you'll want to make sure those changes are applied. While it is certainly possible to restart the individual services, the fastest method is to simply restart your device. On the command line, you can issue \`reboot\`, or just power cycle the unit.

### Optional: Add wan port to the lan bridge

In some cases, it may be desirable to modify the configuration such that the physical wan port is 'just another port' on the lan. This is useful if the device is also being used as an ethernet switch and the extra port is needed and/or if the intent is to make all the ports functionally equivalent. This step is not required, and there is some additional nuance to this process which is different if the device uses swconfig vs DSA for managing the built-in switch. Do not mix these two methods in the configuration file, as they are not cross-compatible.

What follows is a set of examples -- one from a DSA device and another that uses swconfig. **Do not blindly implement these changes** since your device might be different. Instead, use these examples as a reference for the general method.

#### DSA

In a default DSA configuration, \`br-lan\` will contain all of the lan ports, and the wan port will be used directly as the device for the \`wan\`/\`wan6\` network interfaces. Many DSA configurations will appear the same or very similar to the one shown here, but this is not universal, so remember that this serves as an example:

```
config device
	option name 'br-lan'
	option type 'bridge'
	list ports 'lan1'
	list ports 'lan2'
	list ports 'lan3'
	list ports 'lan4'
 
...
 
config interface 'wan'
	option device 'wan'
	option proto 'dhcp'
 
config interface 'wan6'
	option device 'wan'
	option proto 'dhcpv6'
```

To add the wan port to \`br-lan\`, we simply delete the \`wan\` and \`wan6\` network interfaces and then add the wan port to the bridge like this:

```
config device
	option name 'br-lan'
	option type 'bridge'
	list ports 'lan1'
	list ports 'lan2'
	list ports 'lan3'
	list ports 'lan4'
	list ports 'wan'
```

It is important to delete the wan interfaces, or at the very least the device line from each of the wan interfaces because the wan port must only be used in one place -- a network interface or the bridge.

#### swconfig

A device that uses swconfig will have \`switch\_vlan\` configuration blocks like what is shown below. Keep in mind that this is also just an example, as there can be very significant differences in the swconfig default configuration when comparing from one device to another.

```
config switch_vlan
	option device 'switch0'
	option vlan '1'
	option ports '0 8t'
 
config switch_vlan
	option device 'switch0'
	option vlan '2'
	option ports '1 2 3 4 8t'
```

In the above swconfig example, we can see that the CPU (eth0) is logical port 8 as it is tagged (\`t\`) in both VLANs. We can also observe that VLAN 1 has logical port 0 -- the physical wan port, while VLAN 2 represents the lan with logical ports 1-4.

Here, we can either remove VLAN 1 altogether, or we can simply remove logical port 0 from that VLAN block. Then, we'll add logical port 0 to VLAN 2. Below, we have simply removed the logical port that maps to the physical wan port from VLAN 1, and added to VLAN 2:

```
config switch_vlan
	option device 'switch0'
	option vlan '1'
	option ports '8t'
 
config switch_vlan
	option device 'switch0'
	option vlan '2'
	option ports '0 1 2 3 4 8t'
```

In a swconfig device, it is not necessary to delete the wan/wan6 config blocks unless we have deleted the underlying device (in this case VLAN 1 which equates to \`eth0.1\`), but deleting those interfaces will not cause any problems, either.

**Performance Caveat for adding the wan port to the bridge** In many devices, the physical wan port is connected to the switch and is fundamentally 'just another port' on the switch chip. In these cases, the configuration of the switch chip will separate the wan port from the lan ports by the use of VLANs (this is immediately apparent in the swconfig method, but DSA obfuscates this aspect). When all ports are part of the same switch, the performance can be expected to be equivalent on all ports.

Some devices, however, may have a different architecture insofar as the wan port is not connected to the switch chip. Under these circumstances, it is possible that to observe lower performance when traffic is traversing between the wan port and the lan ports as compared to purely between the lan ports. This is because, for these devices, the switching must be performed at a software layer on hardware that is optimized for \*routing\*, not \*switching\*. If the performance penalty is noticeable, it may be best to keep the wan port separate and not use it as part of the lan bridge.

# Method 2: Configuration via LuCI

WARNING for [https://openwrt.org/toh/openwrt/one](https://openwrt.org/toh/openwrt/one "https://openwrt.org/toh/openwrt/one") devices ensure WiFi access is already working before following the instructions below.

Start by disconnecting the wireless AP from your network.  
Use an Ethernet cable to connect your computer to one of the LAN ports (not the *Internet/WAN* port) of the wireless AP.  
Be sure to turn off WiFi on your computer while configuring to ensure that the only network connection is via Ethernet between your computer and your “to be” configured wireless AP.

### Changing configuration for Bridged AP

**Open the router GUI:** From a browser, navigate to LuCI by going to [http://192.168.1.1](http://192.168.1.1 "http://192.168.1.1"), login, set the admin password if necessary.

[![](/_media/media/docs/howto/dumbap_1_interface_overview.jpg?w=750&tok=bcf821)](/_detail/media/docs/howto/dumbap_1_interface_overview.jpg?id=docs%3Aguide-user%3Anetwork%3Awifi%3Awifiextenders%3Abridgedap "media:docs:howto:dumbap_1_interface_overview.jpg")

**Set a static LAN address:** Go to *Network → Interfaces* and on the *General Settings* tab, click on the **Edit** button of the LAN interface.

Although you could configure the wireless AP to use DHCP to obtain an address from the main router,  
this guide will show how configure a static IP address for it.  
By default, the main router will have an address of 192.168.1.1, so use 192.168.1.2 (or similar).  
The wireless AP's address should be on the same subnet as your main router, but outside the DHCP range used when assigning addresses to connected devices.  
Assuming that the DHCP server is running on an upstream OpenWrt device, this means that by default the wireless AP router IP should be between 192.168.1.2 and 192.168.1.99. But be sure to check the DHCP pool range on your DHCP server to ensure that the address you use does not conflict with the DHCP server.  
When adding multiple wireless APs, you could use 192.168.1.3, 192.168.1.4, etc.  
Set the new *IPv4 address*, and click **Save** and **Save &amp; Apply**.

For OpenWrt One devices, now connect via wifi to continue setup.

[![](/_media/media/docs/howto/dumbap_2_interface_changed.jpg?w=750&tok=6a75f3)](/_detail/media/docs/howto/dumbap_2_interface_changed.jpg?id=docs%3Aguide-user%3Anetwork%3Awifi%3Awifiextenders%3Abridgedap "media:docs:howto:dumbap_2_interface_changed.jpg")

A warning screen will appear because you changed the routers IP to 192.168.1.2. Click “Apply and keep settings”.

[![](/_media/media/docs/howto/dumbap_3_connectivity.jpg?w=750&tok=3deceb)](/_detail/media/docs/howto/dumbap_3_connectivity.jpg?id=docs%3Aguide-user%3Anetwork%3Awifi%3Awifiextenders%3Abridgedap "media:docs:howto:dumbap_3_connectivity.jpg")

**Re-open the web GUI:** Navigate to new address you assigned in the previous step (e.g. [http://192.168.1.2](http://192.168.1.2 "http://192.168.1.2")).  
Make sure your browser uses the new IP address you assigned in the previous step.  
Why? Because in the next step, the gateway needs to be changed to point to the main router, and LuCI will not allow you to change the gateway to 192.168.1.1 while the wireless AP router is using that IP address.  
If things are not working as expected, unplug the network cable from your computer for 10 seconds and plug in again. The currently still active DHCP server on your wireless AP will then reassign an IP to you.

**Change the other LAN settings:** Navigate to *Network → Interfaces*, **Edit** the *LAN interface*, *General Settings* tab.

[![](/_media/media/docs/howto/dumbap_4_gateway.jpg?w=750&tok=6db4af)](/_detail/media/docs/howto/dumbap_4_gateway.jpg?id=docs%3Aguide-user%3Anetwork%3Awifi%3Awifiextenders%3Abridgedap "media:docs:howto:dumbap_4_gateway.jpg")

**Set the *IPv4 gateway*** to your main router, 192.168.1.1 by default. This means wireless AP router will use the main router as gateway to the internet.

[![](/_media/media/docs/howto/dumbap_5_dns.jpg?w=750&tok=c27dcf)](/_detail/media/docs/howto/dumbap_5_dns.jpg?id=docs%3Aguide-user%3Anetwork%3Awifi%3Awifiextenders%3Abridgedap "media:docs:howto:dumbap_5_dns.jpg")

**Set the DNS Server:** Same page but the *Advanced Settings* tab. Enter the IP of your main router in the *Use custom DNS servers* field and click *+*. The Wireless AP will use the main router for DNS lookups.

[![](/_media/media/docs/howto/dumbap_6_dhcp.jpg?w=750&tok=8c2238)](/_detail/media/docs/howto/dumbap_6_dhcp.jpg?id=docs%3Aguide-user%3Anetwork%3Awifi%3Awifiextenders%3Abridgedap "media:docs:howto:dumbap_6_dhcp.jpg")

**Disable DHCPv4:** Same page again, now the *DHCP Server* tab. Ensure the *Ignore interface* checkbox is checked. The wireless AP will *not* provide DHCP addresses, but will defer to the main router.

[![](/_media/media/docs/howto/dumbap_7_dhcp_ip6.jpg?w=750&tok=f69ae0)](/_detail/media/docs/howto/dumbap_7_dhcp_ip6.jpg?id=docs%3Aguide-user%3Anetwork%3Awifi%3Awifiextenders%3Abridgedap "media:docs:howto:dumbap_7_dhcp_ip6.jpg")

**Disable IPv6 DHCP:** Same page, *DHCP Server* tab, click on the *IPv6 Settings* sub-tab. Set the *RA-Service*, *DHCPv6-Service*, and *NDP-Proxy* dropdowns to *disabled*.

Click **Save** and **Save &amp; Apply**.

[![](/_media/media/docs/howto/dumbap_8_dhcp_sanda.jpg?w=750&tok=b3c5d6)](/_detail/media/docs/howto/dumbap_8_dhcp_sanda.jpg?id=docs%3Aguide-user%3Anetwork%3Awifi%3Awifiextenders%3Abridgedap "media:docs:howto:dumbap_8_dhcp_sanda.jpg")

The most important steps are done, your wireless AP works!

For OpenWrt One devices, now consider editing devices and edit br-lan to also include, Ethernet Adapter: “ethO” (wan, wan6), which will allow (viewing from the rear) right-hand-side port as a regular ethernet to access the existing network. See “Optional: Add wan port to the lan bridge” earlier.

### Fine Tuning

Read next steps for some fine tuning, enabling WLAN, or adding a Guest Network:

It is generally recommended to leave the dnsmasq and firewall services enabled. Some users may decide to disable these services as a means of saving resources, but the actual benefit is minimal and it is best to leave them running, while explicitly disabling the DHCP server as shown above. Importantly, there is no need to modify the firewall configuration. Leave that as-is.

If you plan to add a “GUEST” network on your wireless AP (see this guide: [guestwifi\_dumbap](/docs/guide-user/network/wifi/guestwifi/guestwifi_dumbap "docs:guide-user:network:wifi:guestwifi:guestwifi_dumbap")), it is critical that the firewall and dnsmasq services are enabled.

- Note that by default OpenWrt does not enable wireless access. So, from a default installation, at minimum will need to review the wireless SSIDs, enable wireless security, set country code, and then enable the wireless radios from the *Network → Wireless* page. More information on wifi can found on [basic\_wifi](/docs/guide-quick-start/basic_wifi "docs:guide-quick-start:basic_wifi"). Additional wifi guides can be found on [wifi](/docs/guide-user/network/wifi/start "docs:guide-user:network:wifi:start").
- Click the *Save and Apply* button.

Use an Ethernet cable to connect one of the LAN ports on your main router to one of the LAN ports (**not** the *WAN/Internet* port) of the wireless AP. You may need to reboot either or both routers, the device connecting your main router to the Internet, and potentially any connected devices. In many cases this will not be necessary.  
Done!

## Populate Hostnames in Associated Stations

Bridged APs will not have the data to display hostnames of the associated devices. Only MAC addresses are known to it. Users wanting to see the corresponding hostnames in the Associated Stations display in LuCI can manually populate `/etc/ethers` on the dumb AP:

On the router, one can extract these data with the following one-liner:

```
< dhcp.leases | awk '{print $2" "$4}'
# or
awk '$4 != "*"{print $2" "$4}' /tmp/dhcp.leases
```

See the following discussion threads for additional approaches:

- Using fping to populate ethers file: [https://forum.openwrt.org/t/associated-stations-list-in-ap-how-to-show-host-names/63475/6](https://forum.openwrt.org/t/associated-stations-list-in-ap-how-to-show-host-names/63475/6 "https://forum.openwrt.org/t/associated-stations-list-in-ap-how-to-show-host-names/63475/6")
- An improved fping approach: [https://forum.openwrt.org/t/second-device-not-getting-dns-entries-from-first-device-to-show-in-associated-stations/57005/14](https://forum.openwrt.org/t/second-device-not-getting-dns-entries-from-first-device-to-show-in-associated-stations/57005/14 "https://forum.openwrt.org/t/second-device-not-getting-dns-entries-from-first-device-to-show-in-associated-stations/57005/14")
- Propagating dhcp.leases to secondary (dumb) access points: [https://forum.openwrt.org/t/associated-stations-making-hostnames-visible-across-multiple-aps/92593](https://forum.openwrt.org/t/associated-stations-making-hostnames-visible-across-multiple-aps/92593 "https://forum.openwrt.org/t/associated-stations-making-hostnames-visible-across-multiple-aps/92593")

## Multicast

DLNA and UPnP clients, and printer or SMB discovery protocols tend to work by using multicast packets. For example PlayStation, Xbox, and TVs use DLNA to detect, communicate with and stream audio/video over the network. By default on bridged interfaces on OpenWrt multicast snooping is turned off. This means all network interfaces connected to a bridge (such as a WiFi SSID and ethernet VLAN) will receive multicast packets as if they were broadcast packets.

On WiFi the *slowest* modulation available is used for multicast packets (so that everyone can hear them). If you have “enabled legacy 802.11b rates” on your WiFi (Advanced settings checkbox in LuCI under the WiFi settings, or `option legacy_rates '1`' in /etc/config/wireless file) then 1Mbps is the rate that will be used. This can completely use up the WiFi airtime with even fairly light multicast streaming.

There are two possible fixes for this, one is to *enable* multicast snooping: `option igmp_snooping '1`' under the appropriate /etc/config/network settings for the bridge. This will cause the bridge to forward only on bridge ports that have requested to receive the particular multicast group. On the other hand, if someone on WiFi requests the group, it will still flood the multicast there, and some people have reported problems with certain devices such as android phones and with ipv6 when igmp\_snooping is enabled (requires further debugging to identify if there is really a problem or not). By *disabling* legacy 802.11b rates (`option legacy_rates '0`') you can at least force the use of 6Mbps or more on the WiFi multicast packets, and this opens up more airtime for other uses.

## External Videos

Several videos are available on the topic which may be useful for background information.  
Bare in mind they are somewhat outdated and generally do not take into account everything.

Using OpenWrt v21 with DSA example:

Two videos which are outdated but explain firewall and APs:

WiFi roaming is much improved in newer mobile devices so configuring Fast Roaming, aka 802.11r, may not be required.  
This video can be misleading as 802.11r has nothing to do with mesh networking.

## Notes

1. Dumb AP wireless can be configured to control access via Open/WPA/WPA2/WPA3. However MAC-based access control is controlled by the main router.
2. Static DHCP is not covered here. This procedure creates an AP that provides wired/wireless access and won't interfere with Static DHCP.
3. Firewall bridge mode support in OpenWrt is provided by the [kmod-br-netfilter](/packages/pkgdata/kmod-br-netfilter "packages:pkgdata:kmod-br-netfilter") module.
