# Wi-Fi Extender/Repeater with WDS

This network setup features a wireless access point and a wireless repeater. The access point connects to the main network via a wired connection and provides internet access. The repeater connects wirelessly to the access point as a client device, creating a point-to-point link that extends network and internet access to any devices connected to the repeater, whether wireless or wired. This configuration is ideal for extending Wi-Fi coverage in your area.

![](/_media/media/doc/802.11-wds-bridge.png)

***Note***: This wiki article was originally located [at this location.](/docs/guide-user/network/wifi/atheroswds "docs:guide-user:network:wifi:atheroswds") You can view the original contribution history [here](/docs/guide-user/network/wifi/atheroswds?do=revisions "docs:guide-user:network:wifi:atheroswds").

The setup described in this article establishes a backhaul link at layer 2 of the OSI model, allowing all broadcast packets, such as DHCP requests, to be transmitted in both directions over the link. The original MAC addresses of devices on both sides are preserved across the bridge.

Devices connected to both the access point and the repeater will share the same subnet, enabling visibility between them and facilitating the use of protocols like Zeroconf. Both the access point and the repeater remain accessible over the network.

Two wireless protocols can be used to achieve this: WDS and 802.11s mesh.

This document focuses on WDS. For 802.11s mesh, refer to [802-11s](/docs/guide-user/network/wifi/mesh/802-11s "docs:guide-user:network:wifi:mesh:802-11s").

WDS (Wireless Distribution System) is required to create a network connection over a wireless link between the access point and the repeater. Although the IEEE 802.11-1999 standard defines WDS as a mechanism using a 4-address format, it does not specify implementation details, leading to potential issues when using WDS between devices from different chipset or firmware vendors. Therefore, **it is recommended to use OpenWrt on both the access point and repeater** to ensure compatibility and optimal performance. Most wireless drivers in OpenWrt support WDS mode.

If WDS or 802.11s mesh is not an option due to access point limitations, consider using [Relayd - Wireless Repeater/Extender](/docs/guide-user/network/wifi/relay_configuration "docs:guide-user:network:wifi:relay_configuration") or a [simple wireless client](/docs/guide-user/network/wifi/connect_client_wifi "docs:guide-user:network:wifi:connect_client_wifi").

## Configuration

- Tested with OpenWrt 12.09 using a TP-Link TL-WR1043ND as the upstream wireless access point and a Rosewill RNX-N300RT as the repeater.
- Tested with OpenWrt 15.05 using two TP-Link TL-WR1043ND.
- Tested with OpenWrt 15.05.1 using a Netgear WNDR3700v4 as the upstream access point and a Nexx WT3020 as the repeater.
- Tested with OpenWrt 19.07.2 to 19.07.6 using a Netgear R6220 as the upstream access point and a Wavlink WL-WN575A3 as the repeater. There were some glitches in 19.07.5 on the R6220, but seemingly not related to WDS.
- Tested with OpenWrt 21.02.1 with both a TP-Link EAP235-Wall V1 and a Netgear R6800 as upstream wireless access point, and D-Link DIR-878 A1 as the repeater (all MediaTek 802.11ac devices).
- Tested with OpenWrt 21.02.3 with Linksys WRT1900ACS v2 as upstream wireless access point, and Linksys EA8500 as the repeater.
- Tested with OpenWrt 22.03.2 with Banana PI BPI-R64 as upstream wireless access point, and Banana PI BPI-R2 as the repeater (AsiaRF AW7915-NP1 cards on both sides).
- Tested with OpenWrt 24.10.0 with GL.iNet GL-MT6000 (Flint 2) as upstream wireless access point, and TP-Link Archer C7 AC1750 v2 as the repeater.
- Tested with OpenWrt 24.10.1 with OpenWrt One as upstream wireless access point, and Mi Router 3 Pro as the repeater.

The network configuration process may be performed both via the command line (with [uci](/docs/guide-user/base-system/uci "docs:guide-user:base-system:uci") and SSH) and via a GUI (with [luci](/docs/guide-user/luci/luci.essentials "docs:guide-user:luci:luci.essentials") and a web browser). It is split in two sections:

1. The access point or AP.
2. The station or STA.

It is important to follow the order of the steps as failure to do so could render the routers inoperable.

### Using the command line over SSH

#### The upstream access point

Open a terminal and connect to this device over SSH. Make sure that this router has already been set up as a regular wireless access point and that wireless clients can connect to it fine. The procedure to do so is described at [Enabling a Wi-Fi access point on OpenWrt](/docs/guide-quick-start/basic_wifi "docs:guide-quick-start:basic_wifi").

Now, open the [/etc/config/wireless](/docs/guide-user/network/wifi/basic "docs:guide-user:network:wifi:basic") configuration file and add the following line to the `wifi-iface` section in use by the access point for operational network functionality:

```
option wds '1'
```

Note that there may be multiple `wifi-iface` sections in this file, especially if the router is a dual-band device, in which case you need to ensure that you are editing the correct section.

This is an example of the [/etc/config/wireless](/docs/guide-user/network/wifi/basic "docs:guide-user:network:wifi:basic") file on an access point for the 2.4 GHz band:

/etc/config/wireless

```
config wifi-device 'radio0'
	option type 'mac80211'
	option path 'platform/ahb/18100000.wmac'
	option band '2g'
	option country 'US'

config wifi-iface 'wifinet1'
	option device 'radio0'
	option network 'lan'
	option mode 'ap'
	option ssid 'My WiFi'
	option encryption 'psk2'
	option key 'MyWiFiPassword'
	option wds '1'
```

Once that is done, save the file and reboot the device to apply the new network settings. Make sure that wireless clients are able to connect to this wireless access point and access the internet as well as they did with the old network configuration.

The `ip address` command should display a new network interface whose name is in the form of: “wlan.sta**N**”; where **N** is a number. This new interface must exist alongside the base “wlan**N**” wireless network interface. For example, if you get the “wlan.sta1” network interface, the base interface is “wlan1”.

**Note:** when tested on Barrier Breaker, there was no new interface created, neither on the AP nor on the STA, despite WDS working properly.

**Note:** The new wlan.staN interface will **not** be bridged by default with the originating WLAN interface if that interface is not itself part of a bridge. To correct this problem, you will need to create a new bridge interface in the wireless access point and associate only its WLAN interface to it.

#### The repeater

Initially, you might need to use an Ethernet cable to connect directly to the repeater and configure it. Open a terminal and connect to this device over SSH.

There are some important settings on the repeater to take into account before creating the wireless link between the repeater and the access point. For starters, the repeater must have its DHCP server disabled (assuming there is already a different DHCP server working on the network). On fresh-installs of OpenWrt, the DHCP server is usually enabled by default on the LAN interface, so to disable it you need to change the network settings of the repeater.

Open the [/etc/config/dhcp](/docs/guide-user/base-system/dhcp "docs:guide-user:base-system:dhcp") file and add the following line to the `config dhcp 'lan'` section:

```
option ignore '1'
```

This line will disable the DHCP server on the LAN interface. The DHCP server should be already disabled on the WLAN interface, so save and close the file.

**Note:** On Chaos Calmer 15.05 / LuCI (git-15.248.30277-3836b45), the DHCP6 server had to be disabled as well, by changing `option dhcpv6 'server'` to `option dhcpv6 'disabled'`.

Now, you need to assign a network address other than the default static IP assignment of 192.168.1.1/24 to the LAN interface, if it is already being used by a different device on your network. Open the [/etc/config/network](/docs/guide-user/base-system/basic-networking "docs:guide-user:base-system:basic-networking") file and change the IP address to one from the same subnet. For example, to 192.168.1.2/24. This is an example of the configuration file:

/etc/config/network

```
config device
	option name 'br-lan'
	option type 'bridge'
	list ports 'eth0.1'

config interface 'lan'
	option device 'br-lan'
	option proto 'static'
	option ipaddr '192.168.1.2'
	option netmask '255.255.255.0'
```

Alternatively, you may want to configure the repeater to fetch an IP address via DHCP from the access point, but that may leave the repeater inaccessible if the WDS connection does not work and it becomes unable to configure its network settings with DHCP. You would need to set the interface protocol to DHCP:

/etc/config/network

```
config device
	option name 'br-lan'
	option type 'bridge'
	list ports 'eth0.1'

config interface 'lan'
	option device 'br-lan'
	option proto 'dhcp'
```

Reboot the repeater to apply the new network settings. After it has restarted, remember to reconnect to the repeater via SSH on its new IP address. Keep in mind that the DHCP server is now disabled on its LAN network interface, so you might need to set a static IP address and subnet mask on the device you are using to configure the repeater.

**Note:** If you have set the LAN interface to use a dynamic IP address (DHCP client), you will need to search for the repeater's IP address every time you reboot it.

It is time to setup the actual wireless link. Open the [/etc/config/wireless](/docs/guide-user/network/wifi/basic "docs:guide-user:network:wifi:basic") file and make sure the corresponding settings in the `radioN` section (where **N** is a number) match the values in the same file of the access point. For example, to use the same band and country code.

Additionally, in this file, modify the `wifi-iface` section to set it in “sta” (client) mode, include the desired SSID to which to connect (the one broadcasted by the access point) and ensure WDS is enabled by setting this value to 1. The specific options may be different depending on the hardware but the SSID, channel, encryption type and password must match the access point, and WDS mode must be turned on.

**If you want to enable wireless access** to the repeater and, therefore, **to the main network and the Internet**, which you might want to do if your use case is **expanding the Wi-Fi coverage on your location, an additional wireless interface (`wifi-iface`) is required in this file**. Copy over the previous wifi-iface and:

- Change the mode from `sta` to `ap`.
- Remove the `option wds '1'` line.

In this new Wi-Fi interface on the repeater, the SSID and the secret key may be the same as the access points to allow transparent roaming, but they can also be different. As long as you connect this new interface to the LAN network, which is the default, your other wireless devices connecting through this AP will also be seen as part of the big network.

This is an example of the [/etc/config/wireless](/docs/guide-user/network/wifi/basic "docs:guide-user:network:wifi:basic") configuration file on a repeater for the 2.4 GHz band.

/etc/config/wireless

```
config wifi-device 'radio0'
	option type 'mac80211'
	option path 'platform/ahb/18100000.wmac'
	option band '2g'
	option country 'US'

config wifi-iface 'wifinet1'
	option device 'radio0'
	option network 'lan'
	option mode 'sta'
	option ssid 'My WiFi'
	option encryption 'psk2'
	option key 'MyWiFiPassword'
	option wds '1'

config wifi-iface 'wifinet2'
	option device 'radio0'
	option network 'lan'
	option mode 'ap'
	option ssid 'My WiFi'
	option encryption 'psk2'
	option key 'MyWiFiPassword'
```

See the [Configure Wi-Fi encryption](/docs/guide-user/network/wifi/encryption "docs:guide-user:network:wifi:encryption") wiki page for a reference on how to specify encryption and keys.

Disconnect the repeater from the wired network and reboot it, for example, by using its power button.

The repeater should boot and connect automatically to the access point wirelessly via WDS. It may take a few minutes for the repeater to associate and connect to the access point. Once this has happened, and if you decided to enable the DHCP client on the LAN interface (dynamic address), the wired interface of the repeater should succeed in getting a DHCP address through the new wireless backhaul connection. The wireless interface on the repeater does not get an IP address as it is now acting as a transparent bridge.

Any client devices connected to the repeater via an Ethernet cable (wired clients) should now be transparently connected into the main network over the wireless (WDS) link.

### LuCI

Everything shown in the command-line configuration with SSH section should be reproducible using LuCI in OpenWrt.

#### The upstream access point

![](/_media/media/doc/howtos/wds-screenshot-1.png)

1. Open LuCI in a browser.
2. Go to the “Network” tab then select “Wireless” from the dropdown.
3. Click “Edit” on the radio.
4. Under “Interface Configuration”, set the Mode to “Access Point (WDS)”.
5. Click the green “Save” button at the bottom of the popup.
6. Click the blue “Save &amp; Apply” button at the bottom of the page.

#### The repeater

On the LAN network interface of the repeater, change the default IP to a different one from the same subnet as upstream access point. 'Save &amp; Apply' the change.

![](/_media/media/doc/howtos/wds-screenshot-2.png)

Reconnect to the repeater at its new LAN IP address, and disable the DHCP server.

![](/_media/media/doc/howtos/wds-screenshot-3.png)

For a wireless interface working on the same frequency band as the access point, click **Scan**, join the previously created wireless network and when asked, set the firewall zone to `lan`.

The wireless mode should be `Client (WDS)` and the **Network** in **Interface Configuration** has to be changed from `wwan` to `lan`.

![](/_media/media/doc/howtos/wds-screenshot-4.png)

Go to **Network**, **DHCP and DNS**, **Forwards**. Set `DNS forwardings` to the IP address of the access point.

Go to **Network**, **Interfaces**, **lan**, **Edit**. Set `IPv4 gateway` to the IP address of the access point.

Go to **Network**, **Interfaces**, **Devices** tab, **Configure...** on br-lan, **Advanced device options** and enable `STP`. Failing to do so can allow a network loop to form that will take down all routers.

Finally, add a new Wi-Fi network if you want to enable wireless access to the network. It can have the same name (SSID), password and settings as the access point, to allow transparent roaming, or they can be different. When creating the new Wi-Fi network, under **General Setup**, ensure that **Mode** is `Access Point` and **Network** is set to `lan`.

## Old Stuff

Relevant configuration files:

- [/etc/config/wireless](/docs/guide-user/network/wifi/basic "docs:guide-user:network:wifi:basic")
- [/etc/config/firewall](/docs/guide-user/firewall/start "docs:guide-user:firewall:start")
- [/etc/config/dhcp](/docs/guide-user/base-system/dhcp "docs:guide-user:base-system:dhcp")

Multiple *WDS Stations* can connect to a single *WDS Access Point*.

- On the access point, add `option wds '1'` to the existing `wifi-iface` section and proceed with configuring SSID, channel, encryption etc.
- On the client, set `option mode 'sta'` and add `option wds '1'` to the `wifi-iface` section. Disable the DHCP server by adding `option ignore '1'` for the LAN interface in /etc/config/dhcp.
- To create a repeater, add a WDS access point along with the WDS station on the client (with the same ssid and key, or not). Do not forget to add the newly created AP to the LAN firewall Zone.

On MAC80211, OpenWrt uses 4 address (option wds 1) (with ap or sta mode) and not repeater mode.
