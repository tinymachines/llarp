# OpenWrt as client device

See also: [OpenWrt as router device](/docs/guide-user/network/openwrt_as_routerdevice "docs:guide-user:network:openwrt_as_routerdevice"), [Router vs switch vs gateway and NAT](/docs/guide-user/network/switch_router_gateway_and_nat "docs:guide-user:network:switch_router_gateway_and_nat"), [Regaining access to an OpenWrt device in client mode](/docs/guide-user/security/recovering_from_clientmode "docs:guide-user:security:recovering_from_clientmode")

OpenWrt will provide additional functions for the network (for example, you just want to use the Wi-Fi network it provides, or the device is a NAS serving files over the network, or a mini-server offering whatever other service).

This means:

- The other router will provide DHCP services to your network (DHCP server will be turned off).
- The device's network firewall will be off, such that e.g. wired devices connected to the other router can contact e.g. wireless devices connected to the OpenWrt router.

## Web interface instructions

1. Click on **Network** → **Interfaces**, then click on the **Edit** button of the LAN Network.
2. In **General Setup** tab, in **Protocol**, select **Static Address**
3. In **IPv4 address** write the new static address of this device, if your old router's address is 192.168.1.1 (most common) and there are no other devices with static addresses on your network (also the most common situation for home networks) you can usually choose any address from 192.168.1.2 to 192.168.1.250. Once you have chosen and written the IP address, write it down in the same sticker with the user/password above, it will be used to connect to your device in the future.
4. In **IPv4 Netmask** select the same netmask as set in your old router's LAN Ethernet settings, it is (very) usually 255.255.255.0
5. In **IPv4 gateway** write the address of the gateway, the device that allows internet access in your local network. In most home networks, the old router is the gateway too, and its default address is 192.168.1.1.
6. Set the DNS in the Custom DNS field. A DNS is a server used to translate human-readable website names (like “[www.google.com](http://www.google.com "http://www.google.com")”) into their actual IP address. In most cases you should write there the address of the local network's router/gateway (that acts as local DNS), so 192.168.1.1, or the address of an actual DNS server in the internet, for example 8.8.8.8 that is the address of Google's DNS servers.
7. Scroll down and in **DHCP Server**, in **General** tab, select “**Disable DHCP for this interface**”, to disable automatic IP assignment on the LAN. Client devices will be connected to a network where there is a router doing DHCP server already and this will avoid conflicts with it.
8. ![:!:](/lib/images/smileys/exclaim.svg) Setting **DHCP Client** in the **Protocol** field will allow you to skip all of the above in most cases, but a device set like that will have an IP that changes depending on the current network router's decisions, so any time you need to connect to it you need to find its current IP first, which may be easy or not depending on the router's web interface or other networking tools you have on your PC/smartphone. This option is not recommended, as it makes connecting with the device unnecessarily more complex.
9. When you are done, click on **Save &amp; Apply** button at the end of the page. This will change the network configuration of the device, and will now be accessible at the IP you set above (or at an unknown dynamic IP if you used “**DHCP client option**”), so the current page you used for configuring it will fail to connect to the device. Disconnect the cable from the PC and connect it to the current network router's LAN Ethernet ports, write the IP address in your browser's address bar and you should be able to connect to it again as normal.

## Command-line instructions

Configure the LAN interface statically with the new IP address `192.168.1.2`, netmask `255.255.255.0`, gateway `192.168.1.1`, and DNS `192.168.1.1`.

```
uci set network.lan.proto="static"
uci set network.lan.ipaddr="192.168.1.2"
uci set network.lan.netmask="255.255.255.0"
uci set network.lan.gateway="192.168.1.1"
uci set network.lan.dns="192.168.1.1"
uci commit network
service network restart
```

Or configure the LAN interface dynamically with DHCP.

```
uci set network.lan.proto="dhcp"
uci commit network
service network restart
```

Note that changing the IP address causes the SSH session to hang/disconnect.

Now you can connect the network cable from the device's LAN port to your existing network, the other router's LAN ports usually.
