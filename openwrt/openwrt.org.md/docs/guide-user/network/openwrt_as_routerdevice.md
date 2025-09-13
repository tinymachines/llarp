# OpenWrt as router device

See also: [OpenWrt as client device](/docs/guide-user/network/openwrt_as_clientdevice "docs:guide-user:network:openwrt_as_clientdevice"), [Router vs switch vs gateway and NAT](/docs/guide-user/network/switch_router_gateway_and_nat "docs:guide-user:network:switch_router_gateway_and_nat")

If your device has some ports labeled LAN and at least a port labeled WAN and you want it to operate as a router (a connection between two different networks). Depending on actual hardware support, it may be possible to create a WAN port on a device with only LAN ports, see your device's page for more info about this. The default IP of the LAN ports of a OpenWrt device is 192.168.1.1, if the addresses of the devices in the network you connect to the WAN port are **192.168.1.X** (X=any number), you need to change the IP address of the LAN interface on your OpenWrt router to **192.168.2.1** (or to something that isn't **192.168.1.X**, anyway), or change the addressing of the other network you are connecting to. The LAN and WAN interfaces MUST have at least different subnets for routing to work.

This means:

- OpenWrt will be mostly in its default factory configuration
  
  - firewall on
  - DHCP is on
- The following steps are optional:
  
  - you can customize the router address and the address of the subnet that OpenWrt manages, but you don't have to (you preferably want to do this, if the addresses 192.168.1.* are already in use on the WAN side)
  - you can change the WAN side IP address to no longer obtain a dynamic address: if your ISP wants you to set a fixed address then set it to a fixed address instead
- If you are confused now or don't know, simply start by leaving both config parts in its default configuration. If you experience problems with these defaults, then adapt them accordingly later.

## Web interface instructions

1. Click on **Network** → **Interfaces**, then click on the **Edit** button of the LAN Network.
2. In **General Setup** tab, in **IPv4 address** type in the desired static IP address for the LAN interface of your OpenWrt Router, if your main router's address is 192.168.1.1 (most common), set the IP address of your OpenWrt router LAN interface to **192.168.2.1** (or to something that isn't **192.168.1.X**, anyway). Once you have chosen and written the IP address, write it down in the same sticker with the user/password above, it will be used to connect to your device in the future.
3. By default the WAN interface/port is set as **DHCP client**, this will allow it to work with networks where there is another router giving addresses without further configuration. If you need to set static address please see the instructions for [Client device](/docs/guide-user/network/openwrt_as_clientdevice "docs:guide-user:network:openwrt_as_clientdevice"), and change the WAN interface settings accordingly.

## Command-line instructions

Configure the LAN interface statically with the new IP address `192.168.2.1`.

```
uci set network.lan.ipaddr="192.168.2.1"
uci commit network
service network restart
```

Note that changing the IP address causes the SSH session to hang/disconnect.

Follow [OpenWrt as client device](/docs/guide-user/network/openwrt_as_clientdevice "docs:guide-user:network:openwrt_as_clientdevice") to configure the WAN interface if necessary.
