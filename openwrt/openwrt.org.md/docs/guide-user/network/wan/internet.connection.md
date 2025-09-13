# Internet connection

A connection to the Internet can be realized with different [Internet access technologies](/docs/techref/hardware/internet.access.technologies "docs:techref:hardware:internet.access.technologies") implementing diverse protocols:

![](/_media/meta/icons/tango/dialog-information.png) ***`Note1`:*** – forwarding of IPv4 is already `enabled` (in file `/etc/sysctl.conf`)  
***`Note2`:*** – `MASQUERADING` is also already `enabled` (in file `/etc/config/firewall`)  
***`Note3`:*** – The LAN and the wireless [network interfaces](/docs/guide-developer/networking/start#network_interfaces "docs:guide-developer:networking:start") are bridged together  
***`Note4`:*** The WLAN is `disabled` by default (in file `/etc/config/wireless`)

## General configuration

The network is configured using the [uci](/docs/guide-user/base-system/uci "docs:guide-user:base-system:uci") file `/etc/config/network`. This file may be edited manually or using the [uci command line](/docs/guide-user/base-system/uci#command_line_utility "docs:guide-user:base-system:uci").

See the following sections that pertain to your particular connection requirements:

- **DSL** → [PPP](/docs/guide-user/network/wan/wan_interface_protocols#protocol_ppp_ppp_over_modem "docs:guide-user:network:wan:wan_interface_protocols") or [PPPoE](/docs/guide-user/network/wan/wan_interface_protocols#protocol_pppoe_ppp_over_ethernet "docs:guide-user:network:wan:wan_interface_protocols") or [PPPoA](/docs/guide-user/network/wan/wan_interface_protocols#protocol_pppoa_ppp_over_atm_aal5 "docs:guide-user:network:wan:wan_interface_protocols").
  
  - via built-in modem. Here is an example of a dummy pppoe over atm (most common) configuration, the values that you have to use vary depending on your ISP:
    
    ```
    # Configure pppoe connection
    uci set network.wan.proto=pppoe
    uci set network.wan.username='yougotthisfromyour@isp.su'
    uci set network.wan.password='yourpassword'
    # Configure atm bridge
    uci set network.atm.encaps='llc'
    uci set network.atm.payload='bridged'
    uci set network.atm.vpi='8'
    uci set network.atm.vci='32'
    # Configure adsl settings
    uci set network.adsl.fwannex='a'
    uci set network.adsl.annex='a2p'
    # Save changes
    uci commit network
    # Restart network service to reflect changes
    /etc/init.d/network restart
    # Bring up the atm bridge and start it automatically on boot
    /etc/init.d/br2684ctl start
    /etc/init.d/br2684ctl enable
    ```
  - via a modem connected over an Ethernet cable: you could [access.modem.through.nat](/docs/guide-user/network/wan/access.modem.through.nat "docs:guide-user:network:wan:access.modem.through.nat") (imo uncommon to need to do this), or just log on through it with PPPoE after setting it up:
    
    ```
    uci set network.wan.proto=pppoe
    uci set network.wan.username='yougotthisfromyour@isp.su'
    uci set network.wan.password='yourpassword'
    uci commit network
    ifup wan
    ```
    
    One might read more at [network\_configuration](/docs/guide-user/network/network_configuration "docs:guide-user:network:network_configuration")
- **DOCSIS** → [DHCP](/docs/guide-user/network/protocol.dhcp "docs:guide-user:network:protocol.dhcp") or [static IP address](/docs/guide-user/network/protocol.static "docs:guide-user:network:protocol.static")
  
  - via built-in modem: you can carry out adjustments
  - via a modem connected over an Ethernet cable: you could [access.modem.through.nat](/docs/guide-user/network/wan/access.modem.through.nat "docs:guide-user:network:wan:access.modem.through.nat")
- HSDPA/**UMTS**/EDGE/GPRS/GSM → [3G](/docs/guide-user/network/wan/wan_interface_protocols#protocol_3g_ppp_over_ev-do_cdma_umts_or_gprs "docs:guide-user:network:wan:wan_interface_protocols")
  
  - via built-in modem:
  - via a modem connected over USB (often called a *3G dongle*):
- via plain **Ethernet**
  
  - [DHCP](/docs/guide-user/network/protocol.dhcp "docs:guide-user:network:protocol.dhcp") (default)
  - [Static IP](/docs/guide-user/network/protocol.static "docs:guide-user:network:protocol.static")
    
    - Example configuration commands:
      
      ```
      uci set network.wan.proto=static
      uci set network.wan.ipaddr=74.125.115.103
      uci set network.wan.netmask=255.255.255.0
      uci set network.wan.gateway=74.125.115.1
      uci set network.wan.dns='8.8.8.8 8.8.4.4'
      uci commit network
      ifup wan
      ```
  - [VPN](/docs/guide-user/services/vpn/start "docs:guide-user:services:vpn:start")
- via [protocol\_l2tp\_ppp\_over\_l2tp\_tunnel](/docs/guide-user/network/ipv6_ipv4_transitioning#protocol_l2tp_ppp_over_l2tp_tunnel "docs:guide-user:network:ipv6_ipv4_transitioning") + [connect\_by\_l2tp](/docs/guide-user/network/wan/connect_by_l2tp "docs:guide-user:network:wan:connect_by_l2tp")
- via **wireless** (one of the 802.11x-standards)
- for **multiple connections** to the Internet, you should first make them each working solitary with OpenWrt before trying this: [MultiWAN](/docs/guide-user/network/wan/multiwan/multiwan_package "docs:guide-user:network:wan:multiwan:multiwan_package")
- via [**USB tethering**](/docs/guide-user/network/wan/smartphone.usb.tethering "docs:guide-user:network:wan:smartphone.usb.tethering") through your smartphone
  
  - **`Note:`** The opposite ([*USB reverse tethering*](/docs/guide-user/network/wan/smartphone.usb.reverse.tethering "docs:guide-user:network:wan:smartphone.usb.reverse.tethering") aka *USB internet passthrough*) is also possible.

## NGN: VoIP and IPTV

[Next-generation network](https://de.wikipedia.org/wiki/Next-generation%20network "https://de.wikipedia.org/wiki/Next-generation network") comprises [VoIP (aka Voice over IP protocol)](/docs/guide-user/services/voip/start "docs:guide-user:services:voip:start") and [IPTV / UDP multicast](/docs/guide-user/network/wan/udp_multicast "docs:guide-user:network:wan:udp_multicast") and everything is based on the [Internet Protocol](https://en.wikipedia.org/wiki/Internet%20Protocol "https://en.wikipedia.org/wiki/Internet Protocol")! These data streams should be separated from the usual data stream and routed to some hardware port where you can grab them with whatever device you wish to use them. If the output does not take place over a standard Ethernet Port, but e.g. over an ISDN- or a [TAE connector](https://en.wikipedia.org/wiki/TAE%20connector "https://en.wikipedia.org/wiki/TAE connector"), a corresponding signal has to be generated in hardware. This needs Linux support as well.

### Da trick with the VLAN trunking

A trick to make the data packets belonging to the different services easily distinguishable from one another, is the usage of VLAN trunking. It has to be done on both sides, and you have to utilize the same VIDs as your ISP does. So, go learn about VLANs.

While you learn about VLAN and VLAN trunking it might be helpful to keep in mind, that with VLAN trunking you send three (respectively two) data services over one line, but want to simulate that you do this over three (respectively two) lines. So you have three virtual ports on the ISP side, each sends its packets over its own virtual line, to each its virtual port in your router. Now to get the data OUT of your router, each of the three virtual ports, has to have second port connected to it.

So, on your side, you would need six ports and three lines, but you (most likely) have only four ports and one line. So make the one port with the line connected to it, act as if it was three ports with each one separate line connected to it. That's it. As easy as eating pancakes or opening a can with an electrical can opener.

![](/_media/meta/icons/tango/48px-dialog-error-round.svg.png) **`Note:`** If you have [**Dual/Triple/Quadruple Play**](https://en.wikipedia.org/wiki/Triple%20play%20%28telecommunications%29 "https://en.wikipedia.org/wiki/Triple play (telecommunications)") you may find some help here: [x.play](/docs/guide-user/network/wan/x.play "docs:guide-user:network:wan:x.play").

## IPv6

- →[configuration](/docs/guide-user/network/ipv6/configuration "docs:guide-user:network:ipv6:configuration")

## Automatic Configuration

- We do not recommend this: [user.beginner.lazy](/doc/howto/user.beginner.lazy "doc:howto:user.beginner.lazy")

Some ISPs offer Information about Settings on [3rd\_Party\_Routers](http://www.beusergroup.co.uk/technotes/index.php?title=Main_Page#3rd_Party_Routers "http://www.beusergroup.co.uk/technotes/index.php?title=Main_Page#3rd_Party_Routers")
