# Bridge mode

See also: [Bridge firewall](/docs/guide-user/firewall/fw3_configurations/bridge "docs:guide-user:firewall:fw3_configurations:bridge")

This method relies on switching the current modem-router in bridge mode, or by buying a Ethernet modem that supports this mode. Bridge mode is a special mode of operation where the current gateway/modem acts as a network bridge, forwarding all traffic to a downstream device. Firewall bridge mode support in OpenWrt is provided by the [kmod-br-netfilter](/packages/pkgdata/kmod-br-netfilter "packages:pkgdata:kmod-br-netfilter") module.

For this to work, the gateway device must be switched to bridge mode from its own interface. The procedure to do this differs quite dramatically so it's problematic to write down a tutorial, please follow the device's manual downloaded from the manufacturer's support site for your device. Also asking your ISP's customer support to help you is an option. In many cases they have a remote connection and can do this configuration change for you (especially useful if you don't have access to the device).

![:!:](/lib/images/smileys/exclaim.svg) Please note: device manufacturers can call “bridge mode” all sorts of things, like Wi-Fi bridging (using two wireless devices to connect two Ethernet networks) or access point mode, or whatever else. It is best to specify that you want to switch their device to bridge mode because you bought a new personal router, so that they don't confuse the two.

## Half bridge

Most common in ISP-provided consumer devices is half bridge mode (cheerfully called “bridge mode” by many manufacturers). In this mode, the device handles authentication (the login/password of your Internet contract) and encapsulation, and it will duplicate the WAN IP address from the ISP to the downstream device. More often than not this makes it inaccessible on the local network so the only way to get it back to normal operation is to reset it. Some devices offer a secondary “management” IP for this mode that can be used to reach their web interface, check the manual.

### LTE/5G half bridge

Some vendors like Mikrotik are providing Half Bridge in their LTE/5G modem/routers where the user can set an interface or mac address to “bridge” the WAN IP on. For Mikrotik this feature is called “Passthrough”. Tested and working on a “LHG LTE kit” device in 12 January 2021. The device's management interface becomes inaccessible from the “bridged” router, but can be still accessed from another device in the same subnet.

From [Mikrotik documentation](https://help.mikrotik.com/docs/display/ROS/LTE#LTE-PassthroughExample "https://help.mikrotik.com/docs/display/ROS/LTE#LTE-PassthroughExample"): Starting from RouterOS v6.41 some LTE interfaces support LTE Passthrough feature where the IP configuration is applied directly to the client device. In this case modem firmware is responsible for the IP configuration and router is used only to configure modem settings - APN, Network Technologies and IP-Type. In this configuration the router will not get IP configuration from the modem. The LTE Passthrough modem can pass both IPv4 and IPv6 addresses if that is supported by modem. Some modems support multiple APN where you can pass the traffic from each APN to a specific router interface. Passthrough will only work for one host. Router will automatically detect MAC address of the first received packet and use it for the Passthrough. If there are multiple hosts on the network it is possible to lock the Passthrough to a specific MAC. On the host on the network where the Passthrough is providing the IP a DHCP-Client should be enabled on that interface to. Note, that it will not be possible to connect to the LTE router via public lte ip address or from the host which is used by the passthrough. It is suggested to create additional connection from the LTE router to the host for configuration purposes. For example vlan interface between the LTE router and host.

## Full bridge

Less common in ISP-provided consumer devices is full bridge mode. In this mode, the device acts as a dumb modem. All authentication and encapsulation etc happens on the router that is connected to it through a specific protocol, pppoE. This mode is the one that allows the most control, stability and performance, but usually requires a specialized device (usually an Ethernet modem) that supports this mode, and it's easier to set up if your ISP is using pppoE protocol for their upstream lines.

### pppoA and full bridge

If your ISP is using another protocol like pppoA in their upstream infrastructure (it is common in UK and Italy, but also NZ and AU, probably elsewhere too), you can do a full bridge only with specific Ethernet modems that do a pppoA ↔ pppoE conversion.

When I looked for these pppoA modems supporting bridge mode for my own home network, I found only [DrayTek Vigor 120](https://www.draytek.co.uk/products/business/vigor-120 "https://www.draytek.co.uk/products/business/vigor-120") --- *[Alberto Bursi](mailto:bobafetthotmail@gmail.com "bobafetthotmail@gmail.com") 2017/03/10 17:43*

TP-LINK TD-8816 works fine and is capable to make full bridge from pppoa to pppoe. Neostrada in Poland on phone line is a pppoa connection and this devices may bridge into pppoe. VPI and VCI parameters are set up in modem. Router connected with ethernet cable sees pppoe and does not use VPI/VCI. --- *Michał Stępień 2020/09/17 12:15*
