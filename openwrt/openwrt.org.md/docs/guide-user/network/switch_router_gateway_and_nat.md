# Router vs switch vs gateway and NAT

See also: [OpenWrt as client device](/docs/guide-user/network/openwrt_as_clientdevice "docs:guide-user:network:openwrt_as_clientdevice"), [OpenWrt as router device](/docs/guide-user/network/openwrt_as_routerdevice "docs:guide-user:network:openwrt_as_routerdevice")

The following is meant as roundup:

- such that you can decide if you want to configure your device as either switch, as router or as gateway
- such that you can decide how you want to deal with the IPv4 double NAT problem in your individual home network situation.

## OpenWrt roles

Network devices can operate in 3 different modes:

- **Client**: If you want to connect your device to an existing network to provide additional functions (for example, you just want to use the Wi-Fi network it provides, the additional ethernet ports, or the device is a NAS serving files over the network, or a mini-server offering some other service).
- **Router**: If you want to run OpenWrt in its default router configuration, where the device routes traffic between several LAN devices connected to the LAN ports and another network on the WAN port (commonly to an “ethernet modem” that is in fact acting as a gateway).
- **Gateway**: Your device also behaves as router. But in contrast to the 'as router device' mode, in this mode your device either uses an integrated modem to connect to the Internet or has an external modem attached on its WAN port that needs one of the following protocols for proper operation: [WAN interface protocols](/docs/guide-user/network/wan/wan_interface_protocols "docs:guide-user:network:wan:wan_interface_protocols").

## Router/gateway and double NAT problem with IPv4 or mixed IPv4/IPv6

Are you an OpenWrt newcomer? Does this page with lots of technical network information seem scary? Are you worried that you don't know enough to make these decisions now?  
→ Just stop reading and use the default configuration for now. Your device will act as a router in a cascaded double NAT scenario which will work just fine for normal internet access, so you don't have to do anything.  
→ Alternatively, [get familiar with OpenWrt](/docs/guide-quick-start/start "docs:guide-quick-start:start") first, then come back later and decide how to proceed.

[Double NAT](/docs/guide-user/network/integrating-openwrt-introduction "docs:guide-user:network:integrating-openwrt-introduction") is an issue that exists solely with IPv4. In a few decades, when the whole world is fully IPv6 enabled devices, this won't be a problem anymore, as IPv6 strictly forbids NAT. In the meantime for IPv4, act according to this how-to.

The problem of IPv4 is that if you simply add an additional IPv4 router to an existing router of your ISP (internet service provider), you will face a problem called **double NAT** - both the newly added router and the existing ISP-supplied router do NAT, resulting in your client data traffic being “NATed” twice before it reaches the internet.

This double NAT scenario won't cause problems for basic tasks like browsing the internet, but it can cause problems when you are trying to host servers at home that you want to be reachable from the internet, or when doing peer-to-peer online gaming (which often uses the UDP protocol and does some funny firewall stuff called “UDP hole-punching”).

To deal with this double NAT problem and use IPv4 as flawlessly as possible, you need to choose how OpenWrt gets connected on its upstream side from several options. Note that in all these examples, the OpenWrt device is assumed to be on the “inside” of the network, i.e. clients ↔ OpenWrt device ↔ ISP device ↔ Internet. Since the OpenWrt device is our main concern, we'll refer to *upstream* and *downstream* connections relative to it:

- **Upstream**: the connection from the OpenWrt device to your network infrastructure
- **Downstream**: your home client devices connecting to your OpenWrt device

There is a range of options to connect the upstream side of OpenWrt to your existing home network. Each option tries to work around the double NAT problem with different technical tricks or configuration:

# Routers / gateways

NAT Usage variant Visualization single [OpenWrt as router and having an internet ISP device configured as modem-bridge](#device_as_router_internet_isp_device_as_modem-bridge "docs:guide-user:network:switch_router_gateway_and_nat ↵") clients ↔ OpenWrt router with NAT ↔ ISP bridge (no NAT) ↔ Internet single [OpenWrt as router, OpenWrt router being "exposed host" in the ISP router](#device_as_router_as_exposed_host_in_the_isp_router "docs:guide-user:network:switch_router_gateway_and_nat ↵") clients ↔ OpenWrt router with NAT ↔ ISP router with NAT + “exposed host” feature ↔ Internet double [OpenWrt as router acting in default cascaded router double-NAT configuration](#openwrt_as_cascaded_router_behind_another_router_double_nat "docs:guide-user:network:switch_router_gateway_and_nat ↵") clients ↔ OpenWrt router with NAT ↔ ISP router with NAT ↔ Internet double [OpenWrt as router in double-NAT configuration with Dualstack Lite on ISP side](#device_as_double-nat_router_with_dual-stack_lite "docs:guide-user:network:switch_router_gateway_and_nat ↵") clients ↔ OpenWrt router with NAT ↔ ISP router with DS-Lite NAT ↔ Internet single [OpenWrt as router with disabled NAT, additional routing rules in both routers](#device_as_router_with_disabled_nat_additional_routing_rules "docs:guide-user:network:switch_router_gateway_and_nat ↵") clients ↔ OpenWrt router (no NAT) ↔ routing rules ↔ ISP router with NAT ↔ Internet 0 [look-out: OpenWrt as router in IPv6 only configuration + ISP router](#device_as_router_in_an_ideal_ipv6-only_configuration "docs:guide-user:network:switch_router_gateway_and_nat ↵") clients ↔ OpenWrt router (no NAT) ↔ ISP router (no NAT) ↔ Internet single [OpenWrt as gateway using either OpenWrt-device-built-in or external modem](#device_as_a_gateway_with_a_true_modem_between_it_and_the_internet "docs:guide-user:network:switch_router_gateway_and_nat ↵") clients ↔ OpenWrt as gateway with NAT ↔ built-in/external modem (no NAT) ↔ Internet

# Switches and client APs

single Three usage Variants:  
[OpenWrt as wireless repeater (Wi-Fi &lt;-&gt; Wi-Fi switch)](#openwrt_as_wireless_repeater_wifi_wifi_switch "docs:guide-user:network:switch_router_gateway_and_nat ↵")  
[OpenWrt as wireless access point (Wi-Fi &lt;-&gt; wired switch)](#openwrt_as_wireless_access_point_wifi_wired_switch "docs:guide-user:network:switch_router_gateway_and_nat ↵")  
[OpenWrt as wire (wire &lt;-&gt; wire switch)](#openwrt_as_a_wire_wire_switch "docs:guide-user:network:switch_router_gateway_and_nat ↵") clients ↔ OpenWrt as switch (no NAT) ↔ ISP router (with NAT) ↔ Internet

\* all variants can handle both wireless and wired clients on the downstream side (i.e. client devices connected to your LAN)

- all variants can host software services for both downstream and upstream sides (like NAS shares)

### OpenWrt as cascaded router behind another router (double NAT)

This is the default (and easiest) option for your OpenWrt device. For this scenario you simply connect the OpenWrt WAN port to an unused LAN port of your existing ISP router.

- usually the ISP router has its firewall and NAT on, and provides DHCP on the downstream side (which is the upstream side of your OpenWrt)
- OpenWrt also has its firewall and NAT on, and it provides DHCP as well on its downstream (which is the upstream side of your connecting clients)

So what's the problem? Some traffic scenarios do not work through double NAT, such as hosting servers or playing online games.

The problem isn't so much IPv4 NAT, it's a combination of:

1. NAT usage
2. how firewalls in consumer routers treat UDP traffic.\\\\The firewall treats UDP traffic as **stateful**. This means that if a sourceIP:sourcePort → targetIP:targetPort package goes out, it will lower the firewall in the reverse direction for a short time, such that the target can answer with the same combination of address and ports (sourceIP:sourcePort ← targetIP:targetPort).
3. many online games use tricks to get peer-to-peer data traffic of other players through your firewall(s) to your game client

Unfortunately the firewall details aren't a fully standardized behavior. And the NAT behavior that happens in parallel isn't predictable either - every router has a slightly different method of deciding how to map addresses to ports on outgoing traffic. Most games and game consoles report this as the “NAT status” of your router, using four broad categories of *open*, *moderate*, *strict*, and *blocked*, which aren't standardized either - each game vendor may use them for slightly different technical details.

So should you use this double NAT scenario and be happy with it? It highly depends on your equipment and your usage scenario. Double NAT is not automatically bad. - if you just do browsing and email, you don't have to care (your internet browsing will not even be slowed down by double NAT) - check if you want to run servers at home that you want to expose to the internet (e.g. a VPN or web server) - such hosting will definitely not work over double NAT - check if your usual online games work flawlessly

Most online games use weird UDP tricks to temporarily bypass your router firewall (without opening your firewall to the whole world), to get less-laggy UDP packets to your game client. Usually those tricks can only bypass a single NATed home router, not two as in double NAT. You will find out, if you either cannot connect at all to online sessions or if there is noticeably more game lag than usual (more lag happens because most games will first try to fallback from UDP to TCP, before giving up, if the so called “UDP hole punching” through your 2 firewalls/NATs won't work - this TCP-fallback will sometimes be noticeable). Most online games report this as “NAT status” in the game settings. Your aim usually will be to either have this status “open” or “moderate”. If your game engine reports anything else, it is usually failing on your two firewalls and double NAT, and it will then fallback to the slower TCP and can even fail completely to connect to a game session (and you should be able to notice that, if you are left alone in an online game session).

The next few sections explain what you can do to bypass these problems, while keeping both routers and firewalls enabled. Just keep in mind: don't try to fix problems that you do not have.

### Device as router, internet ISP device as modem-bridge

Follow: [Bridge mode](/docs/guide-user/network/wan/bridge-mode "docs:guide-user:network:wan:bridge-mode")

Mostly for cable internet, you can often choose to reconfigure your ISP cable router into either **router mode** or **bridge mode**. Sometimes you have to configure this in nested online portal menus of your ISP (and not on your ISP router web GUI).

When set to bridge mode, the ISP router starts behaving like a pass through device: it will superficially act as a modem and will authenticate you as a legitimate customer, but will otherwise just pass through the IPv4 traffic unchanged to your OpenWrt router. The firewall and NAT and DHCP and all the normal “router” services of the ISP device will simply be disabled when set to bridge mode.

### Device as double-NAT router with DS-Lite

Often you do not have a choice whether your ISP gives you a real IPv4 address or a discredited [DS-Lite](https://en.wikipedia.org/wiki/IPv6_transition_mechanism#Dual-Stack_Lite_%28DS-Lite%29 "https://en.wikipedia.org/wiki/IPv6_transition_mechanism#Dual-Stack_Lite_%28DS-Lite%29") IPv4 address. If you want to understand DS-Lite in contrast to regular dual stack, please research the [RFC 6333](https://tools.ietf.org/html/rfc6333 "https://tools.ietf.org/html/rfc6333").

Very often DS-Lite is offered as a default package by cable TV- or fiber-based ISPs. A key feature of DS-Lite is that it has so called *carrier-grade NAT* happening in some network equipment several blocks away from your home at your ISP's site, not in your ISP router at home.

It is important to mention that DS-Lite and this carrier-grade NAT isn't really implemented in a standardized way. It can have slightly different implementation behaviour, depending on the actual equipment that the ISP has bought and how this equipment is configured.

Sadly this technique won't help you to expose any home services over IPv4 on the internet - this won't be possible with DS-Lite in any case. But if online gaming over DS-Lite is your only concern, you might want to check if your double NAT on IPv4 is a problem at all in your favorite online games. Nowadays, often the carrier-grade NAT of DS-Lite is configured in a manner very friendly to online games, resulting in a “moderate” NAT rating in the game engine even when having the additional OpenWrt NAT cascaded in front of it and even when running with default firewall rules.

So if gaming (and game-related UDP peer-to-peer traffic handling) is your only concern regarding the double-NAT problem, you may just want to check your online games first and their reported NAT status, before investing extensive time in solving a double NAT problem that might not even cause a problem in everyday use.

## Device as router with disabled NAT, additional routing rules

Using this scenario depends on whether your ISP router supports custom routing rules. This requires that your ISP router allows you to define forward routing rules (often ISP routers are restricted in function and do not allow this).

The idea of this solution is

- to disable NAT on the OpenWrt router, but keep its routing (and firewall) on
- routing on the ISP router is also enabled
- you have to define non-overlapping IP ranges and static IP addresses for the two routers
- as OpenWrt's NAT is disabled, you need to manually set static routes, such that clients on both routers can send traffic to the other router
- you need to add a static route on the OpenWrt router to forward all Internet-address ranges to the ISP router
- you need to add a static route on the ISP router to forward the local address range managed by OpenWrt to the OpenWrt router

## Device as router as "exposed host" in the ISP router

Follow: [Poor man's bridge](/docs/guide-user/network/wan/dmz-based-bridge-mode "docs:guide-user:network:wan:dmz-based-bridge-mode")

Only some ISP routers have this feature, sometimes called a *DMZ* (demilitarized zone), *DMZ for single server*, *exposed host*, *IP passthrough*, or *poor man's bridge mode* (there is no standardized name). This feature enables your ISP router to define a single one of its downstream clients to be a so called “exposed host”. The ISP router will then forward all incoming Internet traffic from its upstream side to this “exposed host”.

This effectively disables NAT on the ISP router only for a single connected device on the ISP router downstream side: for obvious reasons, we will be connecting our OpenWrt router as this exposed host. So in the end, we have achieved single NAT solely in the network chain towards the OpenWrt router.

Remember you still need to define the usual port forwarding rules in your OpenWrt router if you want to expose OpenWrt-connected servers to the Internet, since we haven't set up an exposed host on the internal network.

Drawbacks of this method are: - the feature may not be supported by your ISP router, you'll have to find out if it does - the OpenWrt upstream port is exposed to the Internet, so be sure that you have not added any careless or extraneous rules to the ruleset - one of your ISP router ports is now without firewall protection, so be careful with this one downstream ISP router port in case you ever connect something else to it

## Device as router in an ideal IPv6-only configuration

Obviously this ideal world does not yet exist, it's just a prospect for much later. Once this happens, the previous chapters of this page can be ignored. This will then be the default and only router option required for your IPv6 OpenWrt device, as you it will just work out of the box for all business cases. There will be no NAT issues, there is no longer a discussion whether to switch the ISP router to bridged or routed, and no more discussion whether an “exposed host” configuration is needed. You will be able to choose three ways of running OpenWrt:

- as a router (without variants), if you want to have an extra firewall active inside your home network (in addition to the firewall of your ISP router)
- as a switch instead (see below), if you don't want the extra bit of routing and firewall inside your home network
- as a gateway instead (see below), if you need to connect to Internet via a special modem protocol

## Device as a gateway, with a true modem between it and the Internet

Follow: [Internet connection](/docs/guide-user/network/wan/internet.connection "docs:guide-user:network:wan:internet.connection")

If your OpenWrt device has no WAN port at all out of the box and has a built-in modem with something like a VDSL-phone port, or if it has a WAN port and you have an external modem that can be put in “bridge mode” (either full bridge or half bridge), this is for you.

## OpenWrt as wireless repeater (wireless-to-wireless switch)

Follow: [Wi-Fi extender or repeater or bridge configuration](/docs/guide-user/network/wifi/relay_configuration "docs:guide-user:network:wifi:relay_configuration")

If your OpenWrt device does not have LAN ports or if you don't want to connect any other devices using RJ45 LAN cables, then most probably you want to use the OpenWrt device as a WiFi repeater in your existing network.

OpenWrt as a wireless repeater (also called wireless range extender) takes an existing signal from a wireless router or wireless access point and rebroadcasts it to create a second network.

- the other wifi network provides Internet access
- OpenWrts upstream side (the other wifi network it will connect to) will be a wireless connection to another access point. OpenWrt acts as a client of this existing other network.
- OpenWrts downstream side (the wifi network that OpenWrt will provide) will be an access point for your wireless clients.
- the existing network on the wireless upstream side provides the DHCP service (OpenWrt's own DHCP will be off)
- usually some other network device of the connected wifi has a firewall and NAT on and provides DHCP
- OpenWrts firewall and NAT will be off (As OpenWrt will operate in switch mode which cannot use NAT)
- as long as you do not purposely disable the LAN downstram ports, OpenWrt will also act as a wire-to-wifi switch
- summed up, OpenWrt acts as a wifi-to-wifi switch
- Note that OpenWrt will no longer listen on the typical default router address of your subnet (e.g. ip-address 192.168.1.1), but will get a custom address (either by DHCP from your other router or you have manually set a static address of the subnet of the other wifi)

Note: In case you are interested in creating a so called “wireless mesh” instead of a wireless repeater, you will have to refer to other projects, e.g. [https://libremesh.org/](https://libremesh.org/ "https://libremesh.org/") or [https://open-mesh.org/](https://open-mesh.org/ "https://open-mesh.org/") at this time.

## OpenWrt as wireless access point (wireless-to-wired switch)

Follow: [Wi-Fi access point](/docs/guide-user/network/wifi/dumbap "docs:guide-user:network:wifi:dumbap")

As a wireless access point, OpenWrt connects to the existing network by wire. OpenWrt then acts as a networking device that allows your Wi-Fi devices to connect to the wired network over OpenWrt.

- the wired network provides Internet access
- OpenWrts upstream side (the other wired network it will connect to) will be a wired connection to the existing router. So OpenWrt acts as a client of this existing other network.
- OpenWrts downstream side (the Wi-Fi network that OpenWrt will provide) will be an access point for your wireless clients
- the existing router on the wired upstream side provides the DHCP service (OpenWrt's own DHCP will be off)
- some other network device on your network will have a firewall and NAT on and provides DHCP
- OpenWrts firewall and NAT will be off (As OpenWrt will operate in switch mode which cannot use NAT)
- summed up, OpenWrt acts as a wireless-wired switch
- as long as you do not purposely disable the LAN downstream ports, OpenWrt will also act as a wire-to-wire switch
- Note that OpenWrt will no longer listen on the typical default router address of your subnet (e.g. ip-address 192.168.1.1), but will get a custom address (either by DHCP from your other router or you have manually set a static address of the subnet of the other Wi-Fi)

## OpenWrt as a wire-to-wire switch

This scenario has already been covered in the previous described access point scenario, as the downstream LAN ports in OpenWrt are active by default, providing switching: All your wired and wireless clients connected to either OpenWrt or your other network switches can talk to each other without restrictions, as no firewall is active on the OpenWrt device.

- so just follow the wireless access point description - just with the difference: if you only need a wire-to-wire switch, then just do not enable the downstream Wi-Fi
- OpenWrt will then act as a wire-to-wire switch between the different OpenWrt-attached downstream devices and between the downstream ↔ upstream ports
- in switch mode, OpenWrt cannot use NAT
- Note that OpenWrt will no longer listen on the typical default router address of your subnet (e.g. ip-address 192.168.1.1), but will get a custom address (either by DHCP from your other router or you have manually set a static address of the subnet of the other Wi-Fi)
