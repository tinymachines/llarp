# Using multiple wan with multiple routers

## Problem

The concept is: we have two or more router and every router has one wan connection active providing **one** public ip address.. Every router is connected to the same internal network (for now on called **lan**), and in the lan there are severs providing services. We want to ensure to be able to connect to those services from every wan (therefore if one wan is down, we can use another wan connection to reach the services). For now load balancing and other stuff are not required. We want availability.

This article may contain network configuration that depends on migration to DSA in OpenWrt 21.02

- Check if your device uses DSA or swconfig as not all devices have been migrated
- ifname@interface has been moved to device sections
- [DSA Networking](/docs/guide-user/network/dsa/start "docs:guide-user:network:dsa:start")
- [Mini tutorial for DSA network config](https://forum.openwrt.org/t/mini-tutorial-for-dsa-network-config/96998 "https://forum.openwrt.org/t/mini-tutorial-for-dsa-network-config/96998") on the forum
- [DSA in the 21.02 release notes](https://openwrt.org/releases/21.02/notes-21.02.0#new_network_configuration_syntax_and_boardjson_change "https://openwrt.org/releases/21.02/notes-21.02.0#new_network_configuration_syntax_and_boardjson_change")

## Assumptions

The connection from the ISP does not block any port.

## Concept: using a lot of redirections on the main gateway

The scenario is the following:

```
router1 / lan gateway <----> access from ISP1
                      <----> router2 <----> modem/router from ISP2
                      <----> router3 <----> modem/router from ISP3
                      ...
                      <----> routerN <----> modem/router from ISPN
```

We don't want to increase the configuration in the lan network, therefore we will use the router1 as gateway from every machine in the lan.

What we have to do is consider every additional router as a sort of “gateway” even if we keep every router connected to the lan (for a fast switch in the case that the router1 gives up). To do this we can observe that for the actual implementation of tools, we can simply add ip addresses on the same interface.

Therefore if the lan interface is 192.168.1.1/24 then every router will have an additional ip address on the same interface used for the lan. (search for interface alias in this wiki) For example the router 1 has 192.168.1.1 and it will have also 172.16.1.1/24 on the same interface, the router2 can have 192.168.1.2/24 and 172.16.1.2/24, and so forth. In this way we are creating, just by ip addresses, two logical network on the same cabling of the lan, the 192.168.1.1/24 network (used by lan computers and routers) and the 172.16.1.1/24 (defined only on the routers).

Defined the network for the routers, we can work with redirects. If i want to reach the service rdp 192.168.1.50:3389 from outside i have to do DNAT redirect (or “open the port”) on every wan interface. On the router1 i will setup a rule like: “From the wan zone, if the packet wants to reach the destination port 3389, do a DNAT redirect to the ip 192.168.1.50” . In this way the packet destination, that was the wan address of router1, will become 192.178.1.1:50 .

The same on the router2, router3 and so on, but with an exception. Since the gateway (that is, the IP destination to send the packets when we the destination of the packet is not directly known) of the lan is the router1, then we have to redirect the packets to the router1, therefore we will write rules like: “From the wan zone, if the packet wants to reach the destination port 3389, do a DNAT redirect to the ip 172.16.1.1”

In this way, whatever request is coming from the wan will be routed to the gateway of the lan. On the router1 we have to redirect those already redirect request to the proper lan computer. So on the router1 we have to add the redirect: “if a packet is coming from the ip 172.16.1.2, if the packet wants to reach the destination port 3389, do a DNAT redirect to the ip 192.168.1.50 mark the connection with a mark router2”. (the same for every other router, therefore 172.16.1.2 has the mark router2, 172.16.1.3 has the mark router3 and so on)

Why do we need to mark the connection? Because the response from 192.168.1.50:3389 has to go through the same wan connection (therefore the same router), else the connection is disrupted (because, in terms of wan addresses, the request is going to the wan address of the router2 , for example, and it does not expect a response from the wan address of the router1). If we keep track of the connection we can route the packets of that connection properly, because we have a “memory” of the connection.

So when the response from 192.168.1.50:3389 is going to the router1, the router1 recognize the connection, and so we have to add an additional rule: “if something is coming from the lan network 192.168.1.0/24 and the connection is marked with router2, then mark the packet with the routing mark ToRouter2”.

Why do we need to mark with the routing mark? To use the other router as gateways, **but only seen so by the router1**. So, for every additional router in the lan network, we need a routing mark as written before.

Finally, we need the routing rule, that says: “if the packet wants to go to 0.0.0.0/0 (the wan network, even if it is not so accurate), and has routing mark router2, the gateway is 172.16.1.2 and the metric is 10”

And this has to be done for every other router.

The metric should be higher (that means: the routing rule will be checked after) than the default routing rule of the router1, because the router1 itself is able to directly talk with the wan network.

In this way a packet of a certain connection coming from the wan address of the router2 will do the following travel

```
to wan_address_router2:3389 --> 
  router2 --> 
    redirect to 172.16.1.1:3389 --> 
        router1 --> 
          mark connection as "router2" and redirect to 192.168.1.50:3389 ; 
response from 192.168.1.50:3389 to router1 --> 
    router1 --> 
      recognize the connection marked as "router2" and therefore mark the packet with routing mark "ToRouter2" -->
        choose the routing rule that matches because there is the routing mark --> 
          to 172.16.1.2 --> 
            router2 --> 
              to wan
```

### Drawbacks

The drawback is that for every service using a port we have to set a redirect on router1, router2, router3 and so on, plus we have to set a redirect on the router1 for every other router, plus a rule for connection marking and a routing rule.

That is quite a lot of work if there are several services. There should exist leaner methods and we should investigate them.

## Concept: using less redirection

towrite

(

by nikito:

Use mwan3 and kmod-macvlan on gateway lan

kmod-macvlan - create virtual devices

```
config device 'eth5'
      option name 'eth5'
      option type 'macvlan'
      option ifname 'eth0.2'
```

```
config device 'eth7'
      option name 'eth7'
      option type 'macvlan'
      option ifname 'eth0.2'
```

```
config interface 'wan'
      option ifname 'eth5'
      option proto 'static'
      option ipaddr '192.168.5.2'
      option netmask '255.255.255.0'
      option gateway '192.168.5.1'
      option metric '10'
```

```
config interface 'wanb'
      option ifname 'eth7'
      option proto 'static'
      option ipaddr '192.168.7.2'
      option netmask '255.255.255.0'
      option gateway '192.168.7.1'
      option metric '20'
```

)

## Implementation on openwrt

towrite
