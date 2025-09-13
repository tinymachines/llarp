# Particularities of Single-Port Devices

By default, devices with a single ethernet port (e.g. the [TL-WR703N](/toh/tp-link/tl-wr703n "toh:tp-link:tl-wr703n"), [TL-MR3020](/toh/tp-link/tl-mr3020 "toh:tp-link:tl-mr3020"), [TL-WA901ND](/toh/tp-link/tl-wa901nd "toh:tp-link:tl-wa901nd") or the [DIR-505](/toh/d-link/dir-505 "toh:d-link:dir-505"), amongst others) come with their only ethernet port assigned to LAN through which they will need to be initially configured.

## Using a Single-Port Device in an existing LAN (Access Point, NAS)

If you want to connect your single-port device to an existing LAN and access the Internet through an existing router. This is the base configuration that will then allow you to turn your device in an Access Point or a NAS.

The recommended setup is to use a static IP address so you can still easily reach this device later if you need to change settings or access its shared folders (or other services).

You can also optionally set the AP to use dynamic IP, this will be quicker to change but will mean the next time you want to connect to the device you will have to look at your current router's **DHCP Leases** table to find out what is its current IP. In most routers (also in OpenWrt routers) you can usually set a **static mapping** in your router's **DHCP Leases** table so that this device always gets the same IP from that router.

This tutorial will cover how to do this from Luci web interface, if you need to do this from [command line interface](/docs/guide-quick-start/sshadministration "docs:guide-quick-start:sshadministration") , please follow the steps for the [Dumb Access Point](/docs/guide-user/network/wifi/dumbap "docs:guide-user:network:wifi:dumbap") article.

### Set static IP with Luci web interface

Connect to the device and then click on **Network** menu and then on **Interfaces**. You should see something like this, a single interface called LAN

[![](/_media/docs/guide-user/network/single_eth_interfaces_ap1.png?w=600&tok=8a2765)](/_media/docs/guide-user/network/single_eth_interfaces_ap1.png "docs:guide-user:network:single_eth_interfaces_ap1.png")

Click on **Edit** button and then set the IP address you have chosen in the **IPv4 address** field, and also write the router's IP address in the **IPv4 gateway** field.

In the example, the modem/router of this network has IP 192.168.11.254, and I have decided to give IP 192.168.11.1 to this device

[![](/_media/docs/guide-user/network/single_eth_interfaces_ap2.png?w=600&tok=7e450a)](/_media/docs/guide-user/network/single_eth_interfaces_ap2.png "docs:guide-user:network:single_eth_interfaces_ap2.png")

Now click on the **DHCP server** tab, and in the **General Settings** subtab select **Disable DHCP for this interface**. This disables DHCP server on IPv4. Since this is a device in an existing network, the existing router is also the DHCP server.

[![](/_media/docs/guide-user/network/single_eth_interfaces_ap3.png?w=600&tok=d10808)](/_media/docs/guide-user/network/single_eth_interfaces_ap3.png "docs:guide-user:network:single_eth_interfaces_ap3.png")

Then click on the **IPv6 settings** subtab and select “**disabled**” for **RA-service**, **DHCPv6-service** and **NDProxy-service**. This disables DHCP on IPv6, same reasons as above.

[![](/_media/docs/guide-user/network/single_eth_interfaces_ap4.png?w=600&tok=f372f2)](/_media/docs/guide-user/network/single_eth_interfaces_ap4.png "docs:guide-user:network:single_eth_interfaces_ap4.png")

Then click **Save**.

*Make sure that you changed the IP to what you actually wanted,* because if you made a mistake the device will become inaccessible when we will save the configuration. (it will be accessible at the wrong address you have set)

So, since we made a change that touches the IP address of the device we need to save without the rollback feature. If you just click on the **Save and Apply** button on the bottom right, the system will lose contact, and then rollback the change.

Click the *little arrow on the side of the Save and Apply button* and select **Apply Unchecked**. Confirm if needed.

If you have changed the IP of the device, now it will become accessible at this new IP, so you can now connect its ethernet cable to the existing LAN's ethernet and access it at its new IP address. In my example, it will be at 192.168.11.1.

### Set Dynamic IP with Luci web interface

First thing, change the hostname so you can easily identify this device from the router's DHCP Lease table later

Connect to the device and then click on **System** menu and then on **System**.  
Write the name you want to give to this device, without spaces, in the **Hostname** field, (in the example I have chosen “**MyAccessPoint**”) then press the **Save and Apply button**.

[![](/_media/docs/guide-user/network/single_eth_interfaces_ap_optional1.png?w=600&tok=5ab128)](/_media/docs/guide-user/network/single_eth_interfaces_ap_optional1.png "docs:guide-user:network:single_eth_interfaces_ap_optional1.png")

After it is done, click on **Network** menu and then on **Interfaces**. You should see something like this, a single interface called LAN

[![](/_media/docs/guide-user/network/single_eth_interfaces_ap1.png?w=600&tok=8a2765)](/_media/docs/guide-user/network/single_eth_interfaces_ap1.png "docs:guide-user:network:single_eth_interfaces_ap1.png")

Click on **Edit** button and then on the **Protocol** field select **DHCP client**. Click on the **Really Switch Protocol** button, then click on the Save button

[![](/_media/docs/guide-user/network/single_eth_interfaces_ap_optional2.png?w=600&tok=4fce94)](/_media/docs/guide-user/network/single_eth_interfaces_ap_optional2.png "docs:guide-user:network:single_eth_interfaces_ap_optional2.png")

Since we made a change that touches the IP address of the device we need to save without the rollback feature. If you just click on the **Save and Apply** button on the bottom right, the system will lose contact, and then rollback the change.

Click the *little arrow on the side of the Save and Apply* button and select **Apply Unchecked**. Confirm if needed.

You can now connect its ethernet cable to the existing LAN's ethernet, look at the router's **DHCP Lease** table for the device with the name you set above, and access it at its new IP address.

If your router device is also running OpenWrt, you can reach that page by connecting to its IP, then click on **Network** and then on **DHCP and DNS**, and then click on the **Static Leases** tab.

[![](/_media/docs/guide-user/network/single_eth_interfaces_ap_optional3.png?w=600&tok=7bd2cb)](/_media/docs/guide-user/network/single_eth_interfaces_ap_optional3.png "docs:guide-user:network:single_eth_interfaces_ap_optional3.png")

In this screenshot, you can see the devices where the DHCP server has assigned a dynamic address in the **Active DHCP Leases** part in the middle. The list of names and MAC addresses above it is the way to set static IPs for the devices in DHCP from the router. Click on the **Add** button to add a new static mapping of IP/hostname or IP/mac address for your new device.

## Using a Single-Port Device as Router/Access Point

In order to use a single-port device as a regular router/access point, the single ethernet port needs to be reassigned to a newly created WAN interface. Before that, their Wifi needs to be configured and activated to allow access to the router because the default firewall configuration will allow neither Telnet, SSH, nor access to the LuCI web interface through the WAN interface, effectively disabling configuration through the ethernet port.

The article at [https://stuff.purdon.ca/?page\_id=370](https://stuff.purdon.ca/?page_id=370 "https://stuff.purdon.ca/?page_id=370") explains the process for a TP-Link WR703N (but can be used for other devices as well). (Note: This is only a placeholder until this information is included in this page.)
