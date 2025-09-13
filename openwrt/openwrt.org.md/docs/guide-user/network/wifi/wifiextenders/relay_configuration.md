# Wi-Fi Extender/Repeater with RelayD

This article describes how to make an OpenWrt router into a Wi-Fi extender/repeater. The extender makes an “uplink” Wi-Fi connection to the main router with one of its radios, and acts as an AP (access point) for local devices with its other radio(s). The extender then relies on the `relayd` package to bridge between the two connections.

For simplicity, this article will use the term “Wi-Fi extender” or “extender” from now on.

Use this configuration in situations when you do not control the main router, or the main router does not run OpenWrt, or the main router does not support the preferred [Wireless Repeater/Extender with WDS](/docs/guide-user/network/wifi/atheroswds "docs:guide-user:network:wifi:atheroswds") or [802.11s Mesh Networking](/docs/guide-user/network/wifi/mesh/80211s "docs:guide-user:network:wifi:mesh:80211s").

The image below shows the normal configuration. The **main router** is on the right: its LAN port (192.168.1.1/24) serves local clients while its WAN port (not shown) connects to the internet. The **Wi-Fi extender** is on the left. It makes a wireless uplink connection (labeled “W-LAN (Client)”) to the main router. The Wi-Fi extender's other radio(s) act as an access point for local devices.

There is a Youtube video that shows substantially this procedure: [https://www.youtube.com/watch?v=Bfmx5NjIWLQ](https://www.youtube.com/watch?v=Bfmx5NjIWLQ "https://www.youtube.com/watch?v=Bfmx5NjIWLQ") which has been tested with OpenWrt 23.05.3 (June 2024).

[![](/_media/docs/guide-user/wifirepeater_802.11-routed-relay.png)](/_detail/docs/guide-user/wifirepeater_802.11-routed-relay.png?id=docs%3Aguide-user%3Anetwork%3Awifi%3Awifiextenders%3Arelay_configuration "docs:guide-user:wifirepeater_802.11-routed-relay.png")

## Setup with LuCI Web GUI

### Configure LAN Interface

This article assumes the main router address is 192.168.1.1 (subnet 192.168.1.0/24) and the “Wi-Fi extender subnet” is 192.168.2.1 (192.168.2.0/24). These subnets MUST be different.

- Remove any wired connections between the Wi-Fi extender and the main router.
- Connect a computer with Ethernet to a LAN port on the Wi-Fi extender and log into LuCI web UI at 192.168.1.1 (default address)
- (Optional) Update the firmware of the Wi-Fi extender to the current release.
- On **System → Backup/Flash Firmware**, click **Perform reset** to return to default OpenWrt settings.
- Go to **Network → Interfaces**, click **Edit** for the LAN interface
- Set **LAN protocol** to **static address**, click **Change protocol** (image below)
- Assign an IP address using the “Wi-Fi extender subnet” (e.g. 192.168.2.1).
- Click **Save**
- Click **Save and Apply**

[![](/_media/media/docs/howto/relay_lan_changeip.jpg?w=400&tok=b39d3a)](/_detail/media/docs/howto/relay_lan_changeip.jpg?id=docs%3Aguide-user%3Anetwork%3Awifi%3Awifiextenders%3Arelay_configuration "media:docs:howto:relay_lan_changeip.jpg")

* * *

- Reconnect to the extender at its new IP address (eg. 192.168.2.1)
- From **Network → Interfaces**, click **Edit** for the LAN interface
- Click the **DHCP Server** tab and disable DHCP, IPv6 RA-Service, and DHCP-v6 Service. To do this:
  
  - On the **General Setup** tab (image below), check the “Ignore interface” box to disable DHCP for the interface.
  - On the **IPv6 Settings** tab (image below), choose “disabled” for **RA-Service** and **DHCP-v6 Service**
- Click **Save**.
- Click **Save and Apply**.
- Finally, set your **PC's Ethernet port** to use a static IP in the Wi-Fi extender subnet (e.g., 192.168.2.10) and default gateway (e.g., 192.168.2.1), then use Ethernet to connect again to the extender.

[![](/_media/media/docs/howto/relay_lan_disabledhcp.jpg?w=400&tok=b69c53)](/_detail/media/docs/howto/relay_lan_disabledhcp.jpg?id=docs%3Aguide-user%3Anetwork%3Awifi%3Awifiextenders%3Arelay_configuration "media:docs:howto:relay_lan_disabledhcp.jpg")

* * *

[![](/_media/media/docs/howto/relay_lan_disableipv6.jpg?w=400&tok=d3727e)](/_detail/media/docs/howto/relay_lan_disableipv6.jpg?id=docs%3Aguide-user%3Anetwork%3Awifi%3Awifiextenders%3Arelay_configuration "media:docs:howto:relay_lan_disableipv6.jpg")

### Configure Wi-Fi Uplink

The extender typically will have multiple radios that could serve as the uplink. Choose one that works best for your environment. 5GHz (n/ac/ax) radios have higher transmit speeds, but 2.4GHz (b/g/n) radios have longer range.

- Keep your PC connected to the Wi-Fi extender via Ethernet. Remove any other physical connections.
- Navigate to the **Network → Wireless** page
- Choose the radio for the uplink to the main router.
- Click on **Scan** button for that radio.

[![](/_media/media/docs/howto/relay_join_wifi_1.jpg?w=800&tok=039cc5)](/_detail/media/docs/howto/relay_join_wifi_1.jpg?id=docs%3Aguide-user%3Anetwork%3Awifi%3Awifiextenders%3Arelay_configuration "media:docs:howto:relay_join_wifi_1.jpg")

- From the list of SSIDs found in the scan, choose the main router's Wi-Fi SSID and click **Join Network**.

[![](/_media/media/docs/howto/relay_join_wifi_2.jpg?w=800&tok=3fec8e)](/_detail/media/docs/howto/relay_join_wifi_2.jpg?id=docs%3Aguide-user%3Anetwork%3Awifi%3Awifiextenders%3Arelay_configuration "media:docs:howto:relay_join_wifi_2.jpg")

* * *

- You'll see the “Joining Network” pane (image below).
  
  - Set the “Name of new network” to `wwan`
  - Enter any Wi-Fi credentials such as WPA passphrase
  - Select **lan** firewall zone.
- Click **Save**.
- Click **Save &amp; Apply**.

[![](/_media/media/docs/howto/relay_join_wifi_3.jpg?w=600&tok=dd7296)](/_detail/media/docs/howto/relay_join_wifi_3.jpg?id=docs%3Aguide-user%3Anetwork%3Awifi%3Awifiextenders%3Arelay_configuration "media:docs:howto:relay_join_wifi_3.jpg")

* * *

You will see the client Wi-Fi settings page (image below). Edit as required. The most important settings are on the **Operating Frequency** line.

- Set the **Mode** to **Legacy** if you are connecting to a Wi-Fi g network, or **N** if you are connecting to a Wi-Fi n (and so on).
- Set the **Width** to the same channel width as the main router
- Keep the same Wi-Fi channel number as was discovered during the scan. This will match the main router.
- Click **Save** when finished.
- Click **Save &amp; Apply**.

[![](/_media/media/docs/howto/relay_join_wifi_5.jpg?w=550&tok=5c49a3)](/_detail/media/docs/howto/relay_join_wifi_5.jpg?id=docs%3Aguide-user%3Anetwork%3Awifi%3Awifiextenders%3Arelay_configuration "media:docs:howto:relay_join_wifi_5.jpg")

### Remove redundant WAN interface and firewall zones

Although it's optional, it is recommended to delete the redundant WAN interfaces and firewall zones.

- Go to **Network → Interfaces** (image below)
- Delete both `WAN` and `WAN6` interfaces.
- Go to **Network &gt; Firewall** (image below)
- Delete the `wan` rule.
- Click **Save &amp; Apply**

**Note:** These actions will also automatically remove any redundant firewall traffic and port forwarding rules.

[![](/_media/media/docs/howto/relay_wan_delete.jpg?w=800&tok=62650d)](/_detail/media/docs/howto/relay_wan_delete.jpg?id=docs%3Aguide-user%3Anetwork%3Awifi%3Awifiextenders%3Arelay_configuration "media:docs:howto:relay_wan_delete.jpg")

[![](/_media/media/docs/howto/relay_firewall_delete_wan.jpg?w=800&tok=c7cd76)](/_detail/media/docs/howto/relay_firewall_delete_wan.jpg?id=docs%3Aguide-user%3Anetwork%3Awifi%3Awifiextenders%3Arelay_configuration "media:docs:howto:relay_firewall_delete_wan.jpg")

### Add static IP on ''wwan''

Assign a static IP address to newly created wwan interface that is in the same subnet as the main router's LAN (eg. 192.168.1.30). You can then manage the router using this address that will also be used later when creating the Relay interface.

- Go to **Network → Interfaces** (image below)
- Click **Edit** for the `wwan` interface

[![](/_media/media/docs/howto/relay_wwan_static_1.jpg?w=800&tok=96706f)](/_detail/media/docs/howto/relay_wwan_static_1.jpg?id=docs%3Aguide-user%3Anetwork%3Awifi%3Awifiextenders%3Arelay_configuration "media:docs:howto:relay_wwan_static_1.jpg")

- On the **General Settings** tab, change the protocol to 'Static Address' (image below)
- Enter an IP address from the main router's LAN subnet (e.g., 192.168.1.30); a subnet mask (e.g., 255.255.255.0); and a gateway IP address (e.g., 192.168.1.1)

[![](/_media/media/docs/howto/relay_wwan_static_2.jpg?w=500&tok=e4566e)](/_detail/media/docs/howto/relay_wwan_static_2.jpg?id=docs%3Aguide-user%3Anetwork%3Awifi%3Awifiextenders%3Arelay_configuration "media:docs:howto:relay_wwan_static_2.jpg")

- On the **Advanced Settings** tab (image below)
- Set **Use custom DNS Servers** to the IP address of the main router (e.g., 192.168.1.1).
- Press **Save**
- Press **Save &amp; Apply**

[![](/_media/media/docs/howto/relay_wwan_statis_3.jpg?w=500&tok=cc9d7b)](/_detail/media/docs/howto/relay_wwan_statis_3.jpg?id=docs%3Aguide-user%3Anetwork%3Awifi%3Awifiextenders%3Arelay_configuration "media:docs:howto:relay_wwan_statis_3.jpg")

### Test Connection

At this point, the Wi-Fi extender should be wirelessly connected to the main router. To verify the connection:

- Go to **Network → Diagnostics** (image below)
- Perform a ping test by clicking the “IPv4 Ping” button.
- A few moments later, you should see ping results if the main router is connected to the internet.

[![](/_media/media/docs/howto/relay_network_test.jpg?w=500&tok=5c0c03)](/_detail/media/docs/howto/relay_network_test.jpg?id=docs%3Aguide-user%3Anetwork%3Awifi%3Awifiextenders%3Arelay_configuration "media:docs:howto:relay_network_test.jpg")

### Install relayd package

- Go to **System → Software** (image below)
- Click **Update List** button. If the Wi-Fi extender is connected to the main router, and that is connected to the internet, a few moments later, the results of the update appears.
- Enter **luci-proto-relay** into the Filter box (image below), and click **Install**.
- When that completes, reboot the router from **System → Reboot** (image below).

[![](/_media/media/docs/howto/relay_package_1.jpg?w=800&tok=71f0bc)](/_detail/media/docs/howto/relay_package_1.jpg?id=docs%3Aguide-user%3Anetwork%3Awifi%3Awifiextenders%3Arelay_configuration "media:docs:howto:relay_package_1.jpg")

[![](/_media/media/docs/howto/relay_package_2.jpg?w=400&tok=1c9cb9)](/_detail/media/docs/howto/relay_package_2.jpg?id=docs%3Aguide-user%3Anetwork%3Awifi%3Awifiextenders%3Arelay_configuration "media:docs:howto:relay_package_2.jpg")

### Add Relay Interface

Add the `relayd` interface that will bridge between the extender's **lan** and **wwan** interfaces. To do this:

- Go to **Network → Interfaces**
- Click on **Add New Interface** (image below)

[![](/_media/media/docs/howto/relay_create_bridge_3.jpg?w=500&tok=ee5749)](/_detail/media/docs/howto/relay_create_bridge_3.jpg?id=docs%3Aguide-user%3Anetwork%3Awifi%3Awifiextenders%3Arelay_configuration "media:docs:howto:relay_create_bridge_3.jpg")

- In the **Add new interface** window (image below)
  
  - Enter a name (“repeater\_bridge” is a good choice)
  - Select **Relay bridge** protocol as shown below. (Reboot your device if the **Relay bridge** option fails to appears.)
- Click **Create Interface**

[![](/_media/media/docs/howto/relay_create_bridge_1.jpg?w=900&tok=134436)](/_detail/media/docs/howto/relay_create_bridge_1.jpg?id=docs%3Aguide-user%3Anetwork%3Awifi%3Awifiextenders%3Arelay_configuration "media:docs:howto:relay_create_bridge_1.jpg")

- In **Network → Interfaces**, click **Edit** for the new “repeater\_bridge” interface (image below)
  
  - Ensure that the **Protocol** is “Relay bridge”
  - Enter the IP address assigned to the `wwan` interface. (eg. 192.168.1.30)
  - Select both **lan** and **wwan** in the **Relay between networks** list.
- Click **Save**.
- Click **Save &amp; Apply**.
- After you have completed above steps, **reboot** the router.

[![](/_media/media/docs/howto/relay_create_bridge_2.jpg?w=500&tok=b3528d)](/_detail/media/docs/howto/relay_create_bridge_2.jpg?id=docs%3Aguide-user%3Anetwork%3Awifi%3Awifiextenders%3Arelay_configuration "media:docs:howto:relay_create_bridge_2.jpg")

### Enable the AP

Enable and configure the Wi-Fi extender to be an access point for local devices.

You may use the same Wi-Fi network name (SSID) and encryption, password, etc. settings as your main router. This allows wireless devices to roam to the best Wi-Fi network. Alternatively, you can also choose to give the Wi-Fi extender different SSID/encryption/password credentials from the main router.

- Go to **Network → Wireless**
- Click **Edit** button for any **SSID** with “**Mode:** Master”. (Don't edit the “**Mode:** Client” uplink connection to the main router.)
  
  - In the **Interface Configuration** section, configure SSID, security and other parameters so the Wi-Fi extender can act like an access point.
  - If you are configuring the radio that also serves as the uplink connection, ensure the **Operating frequency** remains the same.
  - Click **Save**
- **Enable** that wireless network.
- You may edit/enable other radios (for example, enabling both the b/g/n and n/ac/ax/etc. radios)
- Click **Save &amp; Apply**.

### You're Done! More Testing

You're done! The Wi-Fi extender should be extending the network from your main router. Change your computer back to DHCP client mode and connect to the newly-configured Wi-Fi. Your computer should be fully on the internet, having acquired a DHCP IP address from your main router.

The **Status → Overview** window (image below) shows the final result. `radio1` is a DHCP client to the main router. The client Wi-Fi has a ? in the **Host** column instead of a IP address because its `wwan` IP address is only visible in the Network Interfaces page. In the image below,`radio0` (the access point) had not been configured/enabled yet. But it would show the SSID that you configured for the extender.

[![](/_media/media/docs/howto/relay_status_1.jpg?w=800&tok=2f7c12)](/_detail/media/docs/howto/relay_status_1.jpg?id=docs%3Aguide-user%3Anetwork%3Awifi%3Awifiextenders%3Arelay_configuration "media:docs:howto:relay_status_1.jpg")

## Setup with CLI

Before doing any actual configuration, the Wi-Fi interface must be enabled in order to scan for networks in the vicinity:

```
uci set wireless.@wifi-device[0].disabled="0"
uci commit wireless
wifi
```

- Set the disabled option to 0 (to enable wireless)
- Save changed configuration file
- Start wireless using the *wifi* command

Now we can list networks in range using `iw dev wlan0 scan`, substituting your actual wireless interface for *wlan0* if different (`ifconfig` lists all available interfaces to find how your wlan is called)

`iw dev wlan0 scan` output example:

```
# iw dev wlan0 scan
BSS c8:d5:fe:c8:61:b0(on wlan0) -- associated
        TSF: 24324848870 usec (0d, 06:45:24)
        freq: 2412
        beacon interval: 100 TUs
        capability: ESS (0x0411)
        signal: -72.00 dBm
        last seen: 140 ms ago
        Information elements from Probe Response frame:
        SSID: Violetta
        RSN:     * Version: 1
                 * Group cipher: CCMP
                 * Pairwise ciphers: CCMP
                 * Authentication suites: PSK
                 * Capabilities: 1-PTKSA-RC 1-GTKSA-RC (0x0000)
BSS f8:35:dd:eb:20:f8(on wlan0)
        TSF: 24225790925 usec (0d, 06:43:45)
        freq: 2457
        beacon interval: 100 TUs
        capability: ESS (0x0431)
        signal: -90.00 dBm
        last seen: 1450 ms ago
        Information elements from Probe Response frame:
        SSID: GOinternet_EB20FB
        HT capabilities:
                Capabilities: 0x11ee
                        HT20/HT40
                        SM Power Save disabled
                        RX HT20 SGI
                        RX HT40 SGI
                        TX STBC
                        RX STBC 1-stream
                        Max AMSDU length: 3839 bytes
                        DSSS/CCK HT40
                Maximum RX AMPDU length 65535 bytes (exponent: 0x003)
                Minimum RX AMPDU time spacing: 4 usec (0x05)
                HT RX MCS rate indexes supported: 0-15, 32
                HT TX MCS rate indexes are undefined
        HT operation:
                 * primary channel: 10
                 * secondary channel offset: below
                 * STA channel width: any
        RSN:     * Version: 1
                 * Group cipher: TKIP
                 * Pairwise ciphers: TKIP CCMP
                 * Authentication suites: PSK
                 * Capabilities: 1-PTKSA-RC 1-GTKSA-RC (0x0000)
```

In the example, there are two networks, a Wi-Fi g one called Violetta and a Wi-Fi n one called GOinternet\_EB20FB. The device was configured to connect to the one called Violetta.

These are the uci values that were added or changed by the configuration procedure.  
For SSID, BSSID, and encryption you must use the info you got from the Wi-Fi scan above.  
For an explanation of why these values were changed, please read the luci tutorial above.

```
network.lan.ipaddr='192.168.2.1'
network.repeater_bridge=interface
network.repeater_bridge.proto='relay'
network.repeater_bridge.network='lan wwan'
network.wwan=interface
network.wwan.proto='dhcp'
firewall.@zone[0].network='lan repeater_bridge wwan'
dhcp.lan.ignore='1'
wireless.radio0.hwmode='11g'
wireless.radio0.country='00'
wireless.radio0.channel='1'
wireless.radio0.disabled='0'
wireless.@wifi-iface[0]=wifi-iface
wireless.@wifi-iface[0].device='radio0'
wireless.@wifi-iface[0].mode='ap'
wireless.@wifi-iface[0].encryption='none'
wireless.@wifi-iface[0].ssid='OpenWrt'
wireless.@wifi-iface[0].network='lan'
wireless.@wifi-iface[1]=wifi-iface
wireless.@wifi-iface[1].network='wwan'
wireless.@wifi-iface[1].ssid='Violetta'
wireless.@wifi-iface[1].encryption='psk2'
wireless.@wifi-iface[1].device='radio0'
wireless.@wifi-iface[1].mode='sta'
wireless.@wifi-iface[1].bssid='C8:D5:FE:C8:61:B0'
wireless.@wifi-iface[1].key='myWifiPasswordHere'
```

Please note that the Wi-Fi network generated by the device in this example (the one called OpenWrt) has no password nor encryption.  
This was done because the focus of this article was getting the relay bridge up and running.  
You will likely want to set up your device's Wi-Fi network in a more secure way, as explained in the Wi-Fi setup page [here](/docs/guide-user/network/wifi/basic "docs:guide-user:network:wifi:basic").

## Networking Details

As an alternative to using `relayd`, you might consider using [simple wireless client](/docs/guide-user/network/wifi/connect_client_wifi "docs:guide-user:network:wifi:connect_client_wifi") if a bridged network is not required. The Wi-Fi extender can be managed through its static `wwan` IP address (eg. 192.168.1.30)

Even though all end devices on the Wi-Fi extender will get a DHCP address from the main router's LAN subnet, the **LAN** interface of the Wi-Fi extender MUST be on a different subnet for relayd to work (since it is routing traffic, it expects 2 different subnets).

Since both ethernet ports and Access Point Wi-Fi network are on the same **LAN** interface, all clients connecting to the Ethernet ports and to the Access Point Wi-Fi network of the Wi-Fi extender device will be routed by **relayd** and will be connected to your main network.

The **LAN** interface subnet will be used only as a “management” interface, as devices connecting to the Wi-Fi repeater will be on the main network's subnet instead. If the relayd device becomes unreachable, you will have to configure a PC with a static address in the same subnet as the **LAN** interface (eg. 192.168.2.10 for our example) to connect and be able to use LuCI GUI or SSH.

## Troubleshooting

### Accessing the Extender

If you find the Wi-Fi extender itself is only accessible from computers directly connected to the W-LAN AP, not from the ones connected to the OpenWrt W-LAN client, when in the 192.168.1.0 subnet, make sure the `Local IPv4 address` setting in the `Relay bridge` interface matches the ip address of the wireless uplink. (The alternative is tedious: It is possible to access the OpenWrt box via its `192.168.2.1` address if you manually configure your computer to that subnet.)

### Check Firewall zones

![:!:](/lib/images/smileys/exclaim.svg) The following part of the configuration should not be necessary. The default operations should have changed them automatically. In case something isn't working, check this too.

[![](/_media/media/docs/howto/relay_firewallzone_checklan.jpg?w=800&tok=dbcb8d)](/_detail/media/docs/howto/relay_firewallzone_checklan.jpg?id=docs%3Aguide-user%3Anetwork%3Awifi%3Awifiextenders%3Arelay_configuration "media:docs:howto:relay_firewallzone_checklan.jpg")

\----  
[![](/_media/media/docs/howto/relay_firewallzone_checklan_2.jpg?w=400&tok=c44a5d)](/_detail/media/docs/howto/relay_firewallzone_checklan_2.jpg?id=docs%3Aguide-user%3Anetwork%3Awifi%3Awifiextenders%3Arelay_configuration "media:docs:howto:relay_firewallzone_checklan_2.jpg")

### Adding IPv6 support

Activate IPv6 support on your main router to get you a public IPv6 prefix. Activate IPv6 on our Wi-Fi extender to allow for [Stateless Address Autoconfiguration (SLAAC)](https://en.wikipedia.org/wiki/IPv6_address#Stateless_address_autoconfiguration "https://en.wikipedia.org/wiki/IPv6_address#Stateless_address_autoconfiguration") of your public IPv6 addresses and IPv6 traffic.

1\. Go to Network / Interfaces and create a new interface. Name it `WWAN6`, using protocol DHCPv6, cover the WWAN interface. In the Common Configuration of the new interface, configure: Request IPv6 address: disabled. In the Firewall settings: check that the “lan / repeater bridge…” line is selected. Leave the other settings by default, especially, leave the “Custom delegated IPv6-prefix” field empty. On the Interfaces / overwiew page check that the WWAN interface gets a public IPv6 address.

2\. Edit the `LAN` interface settings, DHCP server / IPv6 settings: check/modify the following settings: Router Advertisement Service: relay mode, DHCPv6 service: disabled, NDP-Proxy: relay mode.

3\. Open a SSH session on your OpenWrt device. Issue the following commands:

```
uci set dhcp.wan.interface=wwan
uci set dhcp.wan.ra=relay
uci set dhcp.wan.ndp=relay
uci set dhcp.wan.master=1
uci commit
```

We assume that you chose the `wwan` name when you joined to the other Wi-Fi network as suggested earlier in this guide. If not, change the `dhcp.wan.interface=…` line accordingly.

That's it. Restart `ophcpd` (**System → Startup** or `service odhcpd restart`) and your IPv6-network should begin to configure itself. Connected IPv6-enabled devices should get their public IPv6 addresses, derived from your public IPv6 prefix, and IPv6 traffic should go through your Wi-Fi extender.

### Known Issues

Here are a list of some recently reported issues:

1. DHCP issue caused by Access Point. [OWrt forum](https://forum.openwrt.org/t/relayd-not-forwarding-broadcast-bootp-dhcp-responses/53607/15 "https://forum.openwrt.org/t/relayd-not-forwarding-broadcast-bootp-dhcp-responses/53607/15")
2. Extremely poor upstream transfer speeds with some MT762x devices. [Owrt forum](https://forum.openwrt.org/t/question-xiaomi-mi-r3g-mir3g-5ghz-relayd-19-07-upload-performance/50248 "https://forum.openwrt.org/t/question-xiaomi-mi-r3g-mir3g-5ghz-relayd-19-07-upload-performance/50248") [Bug Report FS#2816](https://bugs.openwrt.org/index.php?do=details&task_id=2816 "https://bugs.openwrt.org/index.php?do=details&task_id=2816")
3. [Devices connected to relayd device cannot be reached.](https://forum.openwrt.org/t/relayd-double-nat-issue/134702/ "https://forum.openwrt.org/t/relayd-double-nat-issue/134702/") [2nd possibly similar case](https://forum.openwrt.org/t/wifi-bridge-only-outbound-connections-work/135973 "https://forum.openwrt.org/t/wifi-bridge-only-outbound-connections-work/135973")
4. [Cannot enable client and AP on same radio](https://forum.openwrt.org/t/how-to-use-openwrt-as-a-wi-fi-repeater-using-a-different-ssid/136177 "https://forum.openwrt.org/t/how-to-use-openwrt-as-a-wi-fi-repeater-using-a-different-ssid/136177")
5. Additional instruction for backdoor to router since once dhcp is disabled on LAN, the router become unreachable. This may occur if there are changes to the wireless access point. eg. wifi SSID, channel number or security passphrase has changed.
   
   1. Connect a computer using ethernet cable to LAN port of the Wifi bridge.
   2. Configure a static IP address on the computer. eg. if the Wifi bridge uses LAN IP address of 192.168.2.1 in above example, use static IP address: 192.168.2.10.
   3. Access LuCI at 192.168.2.1 for above example.
6. [Alternative relayd setup guide](https://www.nerd-quickies.net/2019/08/20/setup-lan-wlan-bridge-with-openwrt-luci/ "https://www.nerd-quickies.net/2019/08/20/setup-lan-wlan-bridge-with-openwrt-luci/")
7. Alternative detailed Relayd setup instructions can also be found in section 9.10 of the [1-OpenWrt-LEDE Installation Guide for HH5A](https://www.dropbox.com/sh/c8cqmpc6cacs5n8/AAA2f8htk1uMitBckDW8Jq88a?dl=0 "https://www.dropbox.com/sh/c8cqmpc6cacs5n8/AAA2f8htk1uMitBckDW8Jq88a?dl=0")
8. IPv6 on macOS 10.15+ does not work with a ULA prefix set on LAN [https://github.com/openwrt/openwrt/issues/7561](https://github.com/openwrt/openwrt/issues/7561 "https://github.com/openwrt/openwrt/issues/7561")

### Using NAT

**Comment:** This looks like the basic instructions for configuring a simple [wireless client](/docs/guide-user/network/wifi/connect_client_wifi "docs:guide-user:network:wifi:connect_client_wifi")

This method basically puts a second Wi-Fi router in cascade on the first one; i.e. usually this means that the extender's clients will be behind double NAT.

It's like connecting with a cable the WAN port on the Wi-Fi extender to the LAN ports of the main router, the Wi-Fi extender creates a new network for itself and the devices connected to it, that can go on the Internet and reach devices in the LAN network of the main router. But in this case we are doing it with wireless networks instead.

prerequisites: - router with two initial interfaces (LAN, WAN)

Setup with WebUI:

- Go in the Network → Interfaces page, click on edit lan interface,
- Set LAN as static IPv4 address as 192.168.x.1 (with x different from the network to which you will connect via Wi-Fi),
- Go in the Network → Wi-Fi, click on scan and choose the “network” link and click “Join Network”.
- Enter the Wi-Fi password, leave the “name of new network” as “WWAN” and select WWAN (or WAN) firewall zone. Click Save,
- Go in the Network → Interfaces page, click on edit wwan interface,
- Move to the Firewall tab. Click on Save and Apply.
- Go in the Network → Firewall, click edit in wan zone and check WAN and WWAN in “covered networks”, click save and apply,

Now you've correctly bounded WWAN with WAN, and consequently WWAN with LAN.

### Potentially Obsolete

*This section collects all the uncertain statements and provisos from earlier in this document. Any that are still valid should be moved to the relevant section.*

Using relayd as instructed in this article isn't guaranteed to work with all Openwrt compatible devices or wifi networks - use only as a last resort.

If supported by both devices, consider using preferred [Wireless Repeater/Extender with WDS](/docs/guide-user/network/wifi/atheroswds "docs:guide-user:network:wifi:atheroswds") or [802.11s Mesh Networking](/docs/guide-user/network/wifi/mesh/80211s "docs:guide-user:network:wifi:mesh:80211s").

If vlan support is required you can use Layer 2 GRE tunnels (“gretap”).

The most common problem is that the client router cannot pass the DHCP message between the main router and the client connected to the client router. Currently it seems to be the hardware/SOC limitation (related to MAC cloning?)

Instead of relayd it should be possible to use **kmod-trelay**, the only information about using it can be seen in [its source code](https://github.com/openwrt/openwrt/commit/c3bba7f8c61ee98265bcffef8ee86e22aa89bbe9 "https://github.com/openwrt/openwrt/commit/c3bba7f8c61ee98265bcffef8ee86e22aa89bbe9"), if you used it successfully please add a section for it in this article.

In this article you will see how to configure your device to become a Wi-Fi extender/repeater/bridge.

In some cases, the wireless drivers used in OpenWrt do not support “Layer 2” bridging in client mode with a specific “upstream” wireless system. When this occurs, one approach is to *route* the traffic between LAN and the upstream wireless system. Broadcast traffic, such as DHCP and link-local discovery like mDNS are generally not routable.

When other options don't work, the **relayd** package implements a bridge-like behavior for IPv4 (only), complete with DHCP and broadcast relaying. This configuration can be done through SSH (remote terminal) or through Luci GUI.

This image shows an example setup. **LAN** interface of the relayd device MUST be on a different subnet for relayd to work (since it is routing traffic, it expects 2 different subnets).

Since both ethernet ports and Access Point Wi-Fi network are on the same **LAN** interface, all clients connecting to the Ethernet ports and to the Access Point Wi-Fi network of the Wi-Fi extender device will be routed by **relayd** and will be connected to your main network.

The **LAN** interface subnet will be used only as a “management” interface, as devices connecting to the Wi-Fi repeater will be on the main network's subnet instead. If the relayd device becomes unreachable, you will have to configure a PC with a static address in the same subnet as the **LAN** interface (eg. 192.168.2.10 for our example) to connect and be able to use LuCI GUI or SSH.
