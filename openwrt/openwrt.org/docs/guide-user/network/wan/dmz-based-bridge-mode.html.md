# Poor Man's Bridge Mode

This article may contain network configuration that depends on migration to DSA in OpenWrt 21.02

- Check if your device uses DSA or swconfig as not all devices have been migrated
- ifname@interface has been moved to device sections
- [DSA Networking](/docs/guide-user/network/dsa/start "docs:guide-user:network:dsa:start")
- [Mini tutorial for DSA network config](https://forum.openwrt.org/t/mini-tutorial-for-dsa-network-config/96998 "https://forum.openwrt.org/t/mini-tutorial-for-dsa-network-config/96998") on the forum
- [DSA in the 21.02 release notes](https://openwrt.org/releases/21.02/notes-21.02.0#new_network_configuration_syntax_and_boardjson_change "https://openwrt.org/releases/21.02/notes-21.02.0#new_network_configuration_syntax_and_boardjson_change")

When you don't have hardware that can do true bridging due to various reasons (many 3G/4G and quite a few DSL or fibre lines don't allow this, especially if there is also VoiP telephone lines involved), you can still do a poor man's bridge mode to have most services that need to be on the Internet facing router to work.  
Dynamic DNS services are (currently) an exception to this as the LEDE router will only know the internal IP of the gateway, but not your true public IP given by the ISP. There are command line tools (bind-dig but also others) in LEDE repository that can allow the LEDE router to get the public IP given by the ISP (with the command dig +short myip.opendns.com @resolver1.opendns.com ), but for now the Dynamic DNS package isn't set to use them.

You must configure and enable DMZ feature on the gateway router. DMZ stands for De-Militarized Zone, and means that all traffic that reaches the gateway will be allowed to reach the devices in the DMZ without being blocked by NAT. This is a safe thing to do ONLY if the devices in the DMZ are router/firewalls/servers connected through WAN (or equivalent) ports/interfaces so they are configured to deal with it.  
In the following tutorial, the LEDE device will be called “router”, and the other device we are connecting it to will be called “gateway”. I will also assume that you know how to use the LEDE interface (either from SSH or the web interface).

01. find the gateway device's documentation (manual or online tutorials) to know how to do what will be discussed in the following points. Due to dramatic differences in how the web interfaces of devices of different brands are arranged, I can't say where exactly this feature has been placed in yours.
02. configure the gateway to be on a subnet that is not the same used in your LAN network
    
    - Example: the gateway's LAN settings will become
      
      - IP 192.168.2.1
      - netmask 255.255.255.0
03. turn off WiFi function on your gateway (you can keep DDNS settings on the gateway)
04. remove all existing port forwarding rules on the gateway. Any port forwarding should be set in the router, later.
05. in the gateway's settings, enable DMZ feature and put the Router WAN IP address into the DMZ address list
    
    - In our example, the router WAN IP address is 192.168.2.2
06. configure the router LAN
    
    - The router LAN interface should be
      
      - IP 192.168.1.1
      - netmask 255.255.255.0
07. the WAN port of your router should be set as a static IP in the same subnet of the gateway
    
    - Example: the router's WAN interface
      
      - IP 192.168.2.2
      - netmask 255.255.255.0
      - DNS server IP 8.8.8.8 (or your favourite DNS server IP)
      - gateway IP 192.168.2.1
08. set any port forwarding you need on the router device
09. connect an ethernet cable from one of the LAN ports on the gateway to the WAN port of your router
10. reboot both devices

This tutorial above follows the steps defined by Steven Frosty in [FAQ -- LTE -- is Bridge Mode supported](http://forum.vividwireless.com.au/forum/faqs-lte/faq-lte-bridge-mode-supported "http://forum.vividwireless.com.au/forum/faqs-lte/faq-lte-bridge-mode-supported")

Firewall bridge mode support in OpenWrt is provided by the [kmod-br-netfilter](/packages/pkgdata/kmod-br-netfilter "packages:pkgdata:kmod-br-netfilter") module.

The following is an example UCI configuration in a LEDE device configured as detailed above.

```
root@LEDE:~# uci show network
network.loopback=interface
network.loopback.ifname='lo'
network.loopback.proto='static'
network.loopback.ipaddr='127.0.0.1'
network.loopback.netmask='255.0.0.0'
network.globals=globals
network.globals.ula_prefix='fdee:11e6:2c49::/48'
network.lan=interface
network.lan.type='bridge'
network.lan.ifname='eth0.1'
network.lan.proto='static'
network.lan.netmask='255.255.255.0'
network.lan.ip6assign='60'
network.lan.ipaddr='192.168.1.1'
network.wan=interface
network.wan.ifname='eth0.2'
network.wan._orig_ifname='eth0.2'
network.wan._orig_bridge='false'
network.wan.proto='static'
network.wan.ipaddr='192.168.2.2'
network.wan.netmask='255.255.255.0'
network.wan.gateway='192.168.2.1'
network.wan.dns='8.8.8.8'
network.wan6=interface
network.wan6.ifname='eth0.2'
network.wan6.proto='dhcpv6'
```
