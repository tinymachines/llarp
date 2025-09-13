# Extending the router ports with a managed switch with VLANs

## Prerequired knowledge

See *Switch documentation* and *Network documentation*.

This article may contain network configuration that depends on migration to DSA in OpenWrt 21.02

- Check if your device uses DSA or swconfig as not all devices have been migrated
- ifname@interface has been moved to device sections
- [DSA Networking](/docs/guide-user/network/dsa/start "docs:guide-user:network:dsa:start")
- [Mini tutorial for DSA network config](https://forum.openwrt.org/t/mini-tutorial-for-dsa-network-config/96998 "https://forum.openwrt.org/t/mini-tutorial-for-dsa-network-config/96998") on the forum
- [DSA in the 21.02 release notes](https://openwrt.org/releases/21.02/notes-21.02.0#new_network_configuration_syntax_and_boardjson_change "https://openwrt.org/releases/21.02/notes-21.02.0#new_network_configuration_syntax_and_boardjson_change")

## Explanation of the need

You have a powerful machine running OpenWrt. *Powerful* here means: a device able to process the amount of network packets created by your activities by a big margin. Like you create a flow of 50 Mbit and your device is able to process until 800 Mbit.

The problem is: somehow you have several WAN connections (maybe using mwan3), or several internal connections for whatever reasons and the device does not have enough Ethernet ports.

You can extend the Ethernet ports of the device using a managed switch (and it means that you have a bit of money/resources and you are in a homeoffice or small office scenario).

## Configuring a managed switch with VLANs

The technology that enables an OpenWrt based device to be extended in terms of ports is VLAN.

### Notes

- Most devices only use one VLAN by default (VLAN ID 1). The instructions that follow assume this is the case. Double check before proceeding.
- VLAN IDs match the virtual interfaces listed by ifconfig, i.e. a VLAN with ID 3 will show as ethX.3 (where X is your real interface, e.g. eth0).
- VLAN IDs should be identical across all network devices.
- A port can have three states: Off (not part of a specific VLAN), Untagged (when part of the default VLAN, or of more than one VLAN), Tagged (when part of two or more VLANs).
- For a lot of switches, a port that is part of multiple VLANs needs to be set to Tagged in every single VLAN it is part of. Make sure to check whether your hardware supports mixing tagged/untagged on the same port and confirm you can recover from faulty configurations if needed (e.g. OpenWrt failsafe or recovery).
- Every VLAN should also include the CPU (tagged by default).
- The VLAN definitions use **internal port numbers**. Make sure you have identified the ports correctly. Quite a few devices (e.g. the [Netgear WNDR3700 v1](/toh/netgear/wndr3700 "toh:netgear:wndr3700")) number their internal ports differently from the numbers on the enclosure! Tagged ports are clearly visible as such in the UI, in the configuration file they're marked by a **t** behind the port number.
- Creating a new VLAN with port X already part of another VLAN means port X should be set to tagged **in all the existing VLAN(s) it is part of. Failure to do so may render your switch inoperable.** We cannot stress this enough! Only certain switches support ports being untagged in one and tagged in another VLAN at the same time.
- For a guest WLAN, only the port(s) connecting a network device to another one should be part of the VLAN. In practice, this means that in a router - access point setup, on each device only the port connecting to the other network device goes into the VLAN.

Some tips (normally a decent explanation of how the VLAN works is included in the switch's manufacturer manual):

An **untagged** port, with VID X, in a switch assign the VLAN tag X to incoming packets. When the packet is leaving the untagged port, and was tagged with the VID X, the VLAN tag is removed. This helps, for example, to communicate between tagged and untagged ports. A packet without VID, going inside an untagged port, gets the VID X and can be routed out other ports belonging to the same VID (apart from bridged ports).

A **tagged** port, with VID Y, accepts only packets tagged with the VID Y in input, while let packets tagged with VID Y going out to the port. Note that one port could be untagged only once, while can be tagged with several VID.

With a brief schema you have:

```
internal stack of the switch  +  External network                                                                                                        
                              |                                                                                                                          
                              |                                                                                                                          
                              |                                                           internal stack of the switch  +  External network              
                              |                                                                                         |                                
                              | Tagged port with VID Y, X and Z                                                         |                                
                              |                                                                                         |                                
 packet with VID Y            |                                                                                         | Untagged port with VID W       
                              |                                                                                         |                                
             +--------------------------------------->                                      gets the VID W afterwards   |           packet with no VID   
                              |                                                                        <--------------------------------------+          
 packet with VID X            |                                                                                         |                                
                              |                                                                                         |                                
             +--------------------------------------->                                     packet with VID W            |                                
                              |                                                                                         |        No VID afterwards       
 packet with VID Z            |                                                                 +-------------------------------------------->           
                              |                                                                                         |                                
             +--------------------------------------->                                                                  |                                
                              |                                                                 keep the VID            |               packet with VID W
                              |           packet with VID Y                                      <----------------------------------------------+        
             <--------------------------------------+                                                                   +                                
                              |                                                                                                                          
                              |           packet with VID X                                                                                              
             <--------------------------------------+                                                                                                    
                              |                                                                                                                          
                              |           packet with VID Z                                                                                              
             <--------------------------------------+                                                                                                    
                              |                                                                                                                          
                              |                                                                                                                          
 packet with VID W            |                                                                                                                          
                           XX |                                                                                                                          
      +--------------------XX |                                                                                                                          
                           XX |                                                                                                                          
                              |                                                                                                                          
                              |  XX           packet with VID W                                                                                          
                              |  XX-------------------+                                                                                                  
                              +  XX                                                                                                                      
```

### Configuration

So, imagine to have a 16 ports switch, we want to extend our router with 8 ports. We choose the first 8.

So the ports 9-16 of the switch will retain the VID 1, and be untagged, with the VID 1 used also for management.

Then we create the VID 100 to assign it to trunks or hybrid ports (a **trunk** is a port that is assigned to all the VLAN IDs, and **hybrid** port is a port assigned to some VIDs).

Then we assign:

1. The port 1 to the VID 101 untagged.
2. The port 2 to the VID 102 untagged.
3. ...
4. The port 7 to the VID 107 untagged.
5. The port 8 to the VID 100 untagged and VID 101 to 107 tagged.

This because we want that the packets coming from the port 1 to the port 7 can pass through the port 8, and the **tagged** packets coming from the port 8 can pass through the ports 1 to 7, without tag (because other devices could not recognize the tag or reject the packet if tagged).

## Configuring an OpenWrt router

Now we want to make use of this. For example, let's say that we connect to the port 1 of the switch the modem for the wan connection 'wan', and on the port 2 the modem for the wan connection 'wan2'.

### With programmable switch

On a TP-Link [TL-WDR3600](/toh/tp-link/tl-wdr3600_v1 "toh:tp-link:tl-wdr3600_v1") we have something like this:

```
# /etc/config/network
 
...
 
config switch
        option name  'eth0'
        option reset '1'
        option enable_vlan '1'
 
## Port: internet
config disabled_switch_vlan
        option device 'eth0'
        option vlan   '1'
        option ports  '0t 1'
        list comment  'port internet, eth0.1'
        list comment  'we cannot have an untagged port'
 
config switch_vlan
        option device 'eth0'
        option vlan   '101'
        option ports  '0t 1t'
        list comment  'port internet, eth0.101'
 
config switch_vlan
        option device 'eth0'
        option vlan   '102'
        option ports  '0t 1t'
        list comment  'port internet, eth0.102'
 
...
 
config interface 'wan'
        option ifname           eth0.101
        option proto            'dhcp'
        option disabled_type    'bridge'
        list comment            'mwan3 does not like bridges, as far as the documentation goes'
        option peerdns          0
        option metric           10
 
config interface 'wan2'
        option ifname           eth0.102
        option proto            'dhcp'
        option disabled_type    'bridge'
        list comment            'mwan3 does not like bridges, as far as the documentation goes'
        option peerdns          0
        option metric           20
 
...
```

### Without programmable switch

On a routerOS metarouter or a x86 device with have something similar to this.

```
# /etc/config/network
 
...
 
config interface 'wan'
        option ifname           eth0.101
        option proto            'dhcp'
        option disabled_type    'bridge'
        list comment            'mwan3 does not like bridges, as far as the documentation goes'
        option peerdns          0
        option metric           10
 
config interface 'wan2'
        option ifname           eth0.102
        option proto            'dhcp'
        option disabled_type    'bridge'
        list comment            'mwan3 does not like bridges, as far as the documentation goes'
        option peerdns          0
        option metric           20
 
...
```

## Conclusion

In this way you have your extended router with way more ports, overcoming the limits of the table of hardware that actually does not offer any device with more than 5 gigabit ports easy to install (the Mikrotik ones are a bit complicated to install).

The limits to take care of are: how much traffic will pass through a port, normally for SOHO even combining multiple WANs it should not exceed 200-300 Mbit, and the processing power of the device itself (that will be under stress already for checking the vlan tag) with OpenWrt (that sometimes cannot use hardware acceleration),

But this could enable the usage of very powerful devices with just 2 ports, for example.

## Practical applications for productive work

### How to configure the managed switch with VLAN allowed

#### Reserving and grouping ports in rows or 'nibbles'

So the idea is to reserve some ports in a managed switch with VLANs to configure them as extension for a OpenWrt based gateway. A point that should not be underestimated is how to choose and reserve ports for specific roles. For now we can decide to divide the role of the ports in two main groups: *external connection* and *internal connections*. This because if we do not reserve enough ports, in case of small expansion of the network needs, we end up on a switch that has a minefield (and no clear structure) of VLANs. Furthermore consider that we are going to use one gigabit port as connection to the router, therefore we expect that the traffic on every port is way less than one gigabit, else we have congestion. In our case the traffic generated between logical networks is less than 50 Mbit on average, even if a gigabit port has to channel several logical networks it will be enough. Of course the solution is not extremely scalable but for small networks (the ones covered by us), it is way enough.

So for example 'external connections' are the WAN connections, and currently we can assume that is unlikely that we will deploy more than 3 wan connections (mostly we deploy 2 wan, and in the case we upgrade the single wan connection). Therefore we can define 4 ports for the wan connections. Why 4? Three ports are needed for connecting Ethernet cables to the modem provided by the ISP, one port will be the port that will send the data to the gateway, the port will be either a trunk or a hybrid port.

The same applies for internal connections. We should see the port on the switch as 'managed ports' by the router (through VLANs), so even internal network ports should be defined. For internal networks the number of assigned port should be a bit 'expansion proof' since internal necessities can arise and we want to have a standard that does not change every moment.

The internal logical network that is likely that could be covered are: voip, lan, lan2 (another company or an old network), wifi. So mostly 4. We can put a bit of margin, because creating an internal need is way more cheap than creating another contract for wan connection, so let's extend to 7, so we have 8 port used (one has to go to the router).

Now it is about grouping. Mostly we will use switches with 16 ports until 48, and those normally have 2 rows of Ethernet ports. One way is to use rows, one way is to use nibbles (that are rectangular grouping). We will see later how to use nibbles, because using a row of N contiguous ports it is the simpler way.

#### Assigning VLANS

We decide to assign to external ports VLAN PVID starting from 101 to 199 (consider that we have until 4095), while we can assign 201 to 299 for internal ports. While the hybrid/trunk ports will have 100 or 200.

With a 24 port switch like an **hp 1810-24 j9803A** we can use 12 ports like this (note that we assign the logical network numbers following the numbers of the device for easy of maintenance. This is one of the small factor in our 'parametric standard'):

port 1 - wan1  
PVID 101 port 3 - wan3  
PVID 103 port 5 - lan1  
PVID 201 port 7 - lan3  
PVID 203 port 9 - lan5  
PVID 205 port 11 - lan7  
PVID 207 port 2 - wan2  
PVID 102 port 4 to the wan 'collector' port on the router  
PVID 100  
tagged VID 101,102,103 port 6 - lan2  
PVID 202 port 8 - lan4  
PVID 204 port 10 - lan6  
PVID 206 port 12 to the LAN 'collector' port on the router  
PVID 200  
tagged VID 201,202,203,204,205,206,207

You can see the rectangular grouping called also 'nibble'. An advantage of not using 'trunk' ports over 'hybrid' is that we separated neatly the groupings and we do not risk that a port is sending data also to an unwanted port.

#### Example configuration

An example of configuration to use part of the managed switch configuration.

```
# Copyright (C) 2006 OpenWrt.org
 
config interface loopback
        option ifname   lo
        option proto    static
        option ipaddr   127.0.0.1
        option netmask  255.0.0.0
 
#eth0 lan1
#eth1 lan2
#eth2 lan3
 
config interface rescue
        option ifname   eth0
        option type     bridge
        option proto    static
        option ipaddr   192.168.1.1
        option netmask  255.255.255.0
        list comment 'for rescuing and management operations'
 
config interface wan
        option ifname   eth1.101
        option no_type_with_mwan3       1
        option 'proto'          'static'
        option 'ipaddr'         '1.2.3.4'
        option 'netmask'        '255.255.255.248'
        option 'gateway'        '1.2.3.3'
        option metric           10
 
config interface wan2
        option ifname   eth1.102
        option no_type_with_mwan3       1
        option 'proto'          'static'
        option 'ipaddr'         '1.2.3.5'
        option 'netmask'        '255.255.255.248'
        option 'gateway'        '1.2.3.6'
        option metric           20
 
config interface wan3
        option ifname   eth1.103
        option proto    dhcp
        option metric   30
 
config interface lan
        option ifname   eth2.201
        option proto    static
        option ipaddr   172.18.21.9
        option netmask  255.255.255.0
 
config interface lan_gw
        option ifname   eth2.201
        option proto    static
        option ipaddr   172.18.21.1
        option netmask  255.255.255.0
 
config interface lan_gw2
        option ifname   eth2.201
        option proto    static
        option ipaddr   172.18.21.253
        option netmask  255.255.255.0
 
config interface lan_old
        option ifname   eth2.201
        option proto    static
        option ipaddr   10.200.1.9
        option netmask  255.255.255.0
 
config interface lan_old_g
        option ifname   eth2.201
        option proto    static
        option ipaddr   10.200.1.253
        option netmask  255.255.255.0
 
config interface voip
        option ifname   eth2.202
        option proto    static
        option ipaddr   172.18.22.9
        option netmask  255.255.255.0
 
config interface voip_gw
        option ifname   eth2.202
        option proto    static
        option ipaddr   172.18.22.1
        option netmask  255.255.255.0
 
config interface wlan
        option ifname   eth2.203
        option type     bridge
        option proto    static
        option ipaddr   172.18.24.9
        option netmask  255.255.255.0
 
config interface wlan_gw
        option ifname   eth2.203
        option proto    static
        option ipaddr   172.18.24.253
        option netmask  255.255.255.0
 
config interface vpn0
        option ifname   tun0
        option proto    none
 
config interface vpn1
        option ifname   tun1
        option proto    none
 
config interface vpn2
        option ifname   tun2
        option proto    none
 
config interface vpn3
        option ifname   tun3
        option proto    none
 
config interface vpn4
        option ifname   tun4
        option proto    none
 
config interface vpn5
        option ifname   tun5
        option proto    none
 
config route
        list comment 'routing all possible private addresses to VPN server'
        list comment 'with different metric'
        option interface        lan
        option target           10.0.0.0
        option netmask          255.0.0.0
        option gateway          172.18.21.4
        option metric           100
 
config route
        list comment 'routing all possible private addresses to VPN server'
        list comment 'with different metric'
        option interface        lan
        option target           172.16.0.0
        option netmask          255.240.0.0
        option gateway          172.18.21.4
        option metric           100
 
config route
        list comment 'routing all possible private addresses to VPN server'
        list comment 'with different metric'
        option interface        lan
        option target           192.168.0.0
        option netmask          255.255.0.0
        option gateway          172.18.21.4
        option metric           100
```
