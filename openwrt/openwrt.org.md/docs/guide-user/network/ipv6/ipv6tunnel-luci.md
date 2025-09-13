# IPv6 with Hurricane Electric using LuCI

To provide LuCI support for IPv6-in-IPv4, navigate to **LuCI → System → Software** and install the packages [6in4](/packages/pkgdata/6in4 "packages:pkgdata:6in4") and [luci-proto-ipv6](/packages/pkgdata/luci-proto-ipv6 "packages:pkgdata:luci-proto-ipv6"). Then navigate to **LuCI → System → Startup → Initscripts** and click to **network → Restart** to be able to utilize the new protocol.

OpenWrt is fully capable of handling and routing IPv6 traffic. Many ISPs offer native IPv6, but if yours doesn't, here's a quick setup guide for experimenting with IPv6 (and getting used to the peculiar address format).

The procedure below creates a *6in4 tunnel* on the WAN6 interface of your router. This automatically wraps *(encapsulates)* all IPv6 packets inside IPv4 packets, and sends them to a designated *tunnel broker server* that unwraps them, and forwards them to the destination IPv6 host. Packets from those IPv6 hosts go to the tunnel broker server, where they're wrapped in an IPv4 packet and sent back to your router, which then unwraps them for for use on your local network.

## Create a tunnel account

Before you can configure your router, you must set up a free account at the [Hurricane Electric Free IPv6 Tunnel Broker](https://tunnelbroker.net/ "https://tunnelbroker.net/") site, then create up a **Regular Tunnel**. Be sure to click **Assign /48** for the “Routed /48” field. The Hurricane Electric **Tunnel Details** page **IPv6 Tunnel** panel (image below) shows the primary details of your tunnel. The **Advanced** panel (image below) shows the MTU of your tunnel.

[![Tunnel broker details](/_media/media/tunnelbroker-details.png "Tunnel broker details")](/_detail/media/tunnelbroker-details.png?id=docs%3Aguide-user%3Anetwork%3Aipv6%3Aipv6tunnel-luci "media:tunnelbroker-details.png") [![Tunnel broker advanced panel](/_media/media/tunnelbroker-advanced.png "Tunnel broker advanced panel")](/_detail/media/tunnelbroker-advanced.png?id=docs%3Aguide-user%3Anetwork%3Aipv6%3Aipv6tunnel-luci "media:tunnelbroker-advanced.png")

Notes:

- You can follow the [detailed instructions](https://www.bufferbloat.net/projects/cerowrt/wiki/IPv6_Tunnel/ "https://www.bufferbloat.net/projects/cerowrt/wiki/IPv6_Tunnel/") for creating the 6in4 tunnel.
- The 6in4 protocol [requires](https://forums.he.net/index.php?topic=488.0 "https://forums.he.net/index.php?topic=488.0") you to have a public IPv4 address.

## Configure your router

To complete the OpenWrt configuration, open the router's **Network → Interfaces** page in a separate tab or window, find the WAN6 interface, and click **Edit:**

- Change **Protocol** to *IPv6-in-IPv4 (RFC4213)*
- Click **Change Protocol** and confirm.

You'll see the **WAN6 Common Configuration** page (image below). Copy the values from the **Tunnel Details** page to the corresponding field of the **WAN6 Common Configuration** page:

- Leave “Local IPv4 address” empty
- Set “Remote IPv4 address” to “Server IPv4 Address” from the Tunnel Details page
- Set “Local IPv6 address” to “Client IPv6 Address”
- Set “IPv6 routed prefix” to “Routed /48” value“ (click **Assign /48** on the Tunnel Details if it's not present)
- Check the Dynamic tunnel box. This reveals more fields:
- Set “Tunnel ID” to the “Tunnel ID” field
- Set “HE.net username” to the user name you used to create the account
- Set “HE.net password” to the Update Key found on the Advanced tab of Tunnel Details page
- On the Advanced tab, set “Use MTU on tunnel interface” to the MTU found on the Advanced tab of Tunnel Details page
- On newer versions of OpenWRT, go to the Firewall tab, and select the same zone as your WAN (this is needed at least in 23.05.2). On older versions, you can keep the default settings of the Firewall tabs as-is
- Click **Save and Apply**

At this point, your computer should have direct IPv6 connectivity with the rest of the Internet. (You may need to restart the router, or disable and re-enable the network interface of your computer before the 6in4 addressing works.) To test, type `ping ipv6.google.com`

Legacy notes:

- OpenWrt has handled IPv6 since at least Backfire (10.03.1). This procedure should work with 17.01 and newer, and was tested with 18.06.1
- There is a [tunnelbroker.sh](https://github.com/richb-hanover/OpenWrtScripts/blob/master/tunnelbroker.sh "https://github.com/richb-hanover/OpenWrtScripts/blob/master/tunnelbroker.sh") script over at [OpenWrt scripts](https://github.com/richb-hanover/OpenWrtScripts "https://github.com/richb-hanover/OpenWrtScripts"). That script is convenient if you need to reconfigure the router frequently. Otherwise, it's just as simple to use the LuCI web interface.

[![WAN6 general configuration panel](/_media/media/configurewan6-general.png "WAN6 general configuration panel")](/_detail/media/configurewan6-general.png?id=docs%3Aguide-user%3Anetwork%3Aipv6%3Aipv6tunnel-luci "media:configurewan6-general.png")

[![WAN6 advanced configuration panel](/_media/media/configurewan6-advanced.png "WAN6 advanced configuration panel")](/_detail/media/configurewan6-advanced.png?id=docs%3Aguide-user%3Anetwork%3Aipv6%3Aipv6tunnel-luci "media:configurewan6-advanced.png")
