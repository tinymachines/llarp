# Network Components

This section is intended as a primer for how to setup a home or small office network. The following explanation is intended as a basic intro into the components and their respective roles. As always in networking (as it was intended from the beginning) there multiple ways of setting up the topology, depending on the goals you are trying to achieve.

## Ideal Topology: Star

The following picture describes the ideal layout of a network using the [Star topology](https://en.wikipedia.org/wiki/Star_network "https://en.wikipedia.org/wiki/Star_network") as this gives every client maximum performance (highest bandwidth, lowest latency) when reaching every other component and the internet.

[https://forum.openwrt.org/uploads/default/original/3X/b/d/bd40bd8526af33f0a2ff7ab6aa9089f867f60ec5.jpeg](https://forum.openwrt.org/uploads/default/original/3X/b/d/bd40bd8526af33f0a2ff7ab6aa9089f867f60ec5.jpeg "https://forum.openwrt.org/uploads/default/original/3X/b/d/bd40bd8526af33f0a2ff7ab6aa9089f867f60ec5.jpeg")

The components present are:

- The network entry is done trough a component which provides the functions:
  
  - [Router](https://en.wikipedia.org/wiki/Router_%28computing%29 "https://en.wikipedia.org/wiki/Router_(computing)") - Sends requests between the internal network and external network (internet)
    
    - This will have a connection to the [ISP](https://en.wikipedia.org/wiki/Internet_service_provider "https://en.wikipedia.org/wiki/Internet_service_provider") which can be done over:
      
      - Ethernet either directly (e.g. [PPPoE](https://en.wikipedia.org/wiki/Point-to-Point_Protocol_over_Ethernet "https://en.wikipedia.org/wiki/Point-to-Point_Protocol_over_Ethernet"))
      - Trough a [modem](https://en.wikipedia.org/wiki/Cable_modem "https://en.wikipedia.org/wiki/Cable_modem")
      - [Fiber optic cable](https://en.wikipedia.org/wiki/Fiber-optic_cable "https://en.wikipedia.org/wiki/Fiber-optic_cable") plugged into the [SFP transceiver](https://en.wikipedia.org/wiki/Small_Form-factor_Pluggable "https://en.wikipedia.org/wiki/Small_Form-factor_Pluggable") for that type of cable, which then gets inserted into the SFP port on the device
      - Other external component
    - It can be also be configured to provide access from multiple ISP for increased internet bandwidth and/or fail-over in case one ISP fails
  - [Firewall](https://en.wikipedia.org/wiki/Firewall_%28computing%29 "https://en.wikipedia.org/wiki/Firewall_(computing)") - Prevents unauthorized access to the internal network
  - [DHCP](https://en.wikipedia.org/wiki/Dynamic_Host_Configuration_Protocol "https://en.wikipedia.org/wiki/Dynamic_Host_Configuration_Protocol") - Provides a unique IP addresses to each individual client on the internal network
- The [switch](https://en.wikipedia.org/wiki/Network_switch "https://en.wikipedia.org/wiki/Network_switch") where all the clients are directly connected to trough physical connections using either Ethernet or SFP (e.g. fiber optic or copper). The switch will also be connected to the Router mentioned above using physical connection (Ethernet or SFP). It can be *unmanaged* (plug and play) where all clients have access to all other clients, or with various levels of configuration options. OpenWRT can be installed on some of these to bring its feature set closer to an *enterprise managed switch*
- The [Wireless Access Points](https://en.wikipedia.org/wiki/Wireless_access_point "https://en.wikipedia.org/wiki/Wireless_access_point") which can be located in various locations to provide WiFi coverage over the entire desired area. The APs will be connected using physical connections to the switch so as to maximize available wireless bandwidth for the clients.

## Common Topology: Tree Network

Due to the difficulties implementing the Star topology, mainly cause by the need to run physical connections between every present and future client to a central location, the most common topology in practice is the [Tree Network](https://en.wikipedia.org/wiki/Tree_network "https://en.wikipedia.org/wiki/Tree_network").

- This has the advantage of running only one (or small number) of physical connections to the central switch
- But has the disadvantage of having this connection as a potential bottleneck for bandwidth, as well as increasing the latency because every switch will necessarily have to receive and forward the network packages

Below are two examples of this topology where the function of the Router, Firewall, DHCP, Switch and Access point are been provided by a single device, plus one or more additional downstream switches.

- If additional switches *must* be deployed, ideally there should only be one.
- If two downstream switches *must* be deployed, then both of these should ideally be connected to the main switch, **NOT** [daisy chained](https://en.wikipedia.org/wiki/Daisy_chain_%28electrical_engineering%29 "https://en.wikipedia.org/wiki/Daisy_chain_(electrical_engineering)")

<!--THE END-->

- Single downstream switch
  
  - [https://forum.openwrt.org/uploads/default/original/3X/f/2/f2aaf08e9ec0143894d0729317ed9281d491604e.jpeg](https://forum.openwrt.org/uploads/default/original/3X/f/2/f2aaf08e9ec0143894d0729317ed9281d491604e.jpeg "https://forum.openwrt.org/uploads/default/original/3X/f/2/f2aaf08e9ec0143894d0729317ed9281d491604e.jpeg")
  - In this example there is only one downstream switch connected trough an higher bandwidth SFP back to the main router to reduce the effect of the bottleneck between the downstream switch and the router's internal switch
  - The server is also connected trough an high speed SFP (e.g. Direct Attach Copper Cable SFP+) back to the internal switch of the router
- Multiple downstream switches
  
  - [https://forum.openwrt.org/uploads/default/original/3X/b/a/ba2a4fe5555cbb3fad8463d4a71882733e6a578b.jpeg](https://forum.openwrt.org/uploads/default/original/3X/b/a/ba2a4fe5555cbb3fad8463d4a71882733e6a578b.jpeg "https://forum.openwrt.org/uploads/default/original/3X/b/a/ba2a4fe5555cbb3fad8463d4a71882733e6a578b.jpeg")
  - In this example there are two switches downstream from the internal router's switch. Possible reasons for such a setup would be having one high speed switch (2.5GbE) and one low speed (1GbE or 100MbE) switch providing PoE for TVs and security cameras
  - Keep in mind that if any packages from clients in the downstream switches to clients of another downstream switch will have to traverse three switches to reach their target.

## Use of physical connections

**Most importantly**: All clients (and of course switches) that can be connected using physical connections (Ethernet, SFP+) should be connected. The reason is because when using roads as an analogy:

- Physical connections are like a private [Controlled-access\_highway](https://en.wikipedia.org/wiki/Controlled-access_highway "https://en.wikipedia.org/wiki/Controlled-access_highway"), where the communication is [Full\_duplex](https://en.wikipedia.org/wiki/Duplex_%28telecommunications%29#Full_duplex "https://en.wikipedia.org/wiki/Duplex_(telecommunications)#Full_duplex") (in the vast majority of cases).
  
  - This means that a 1GbE connection can do 1GbE download and 1GbE upload **at the same time** (for a total bidirectional speed of 2GbE) but will **not** do 2GbE in any single direction. This speed will be constant up to the [maximum allowed length](https://en.wikipedia.org/wiki/Category_6_cable#Maximum_length "https://en.wikipedia.org/wiki/Category_6_cable#Maximum_length") of the connection
- WiFi connections are like [roads with multiple lanes](https://en.wikipedia.org/wiki/Arterial_road "https://en.wikipedia.org/wiki/Arterial_road") shared between all devices **and** with the neighbors, and subject to [radio interference](https://en.wikipedia.org/wiki/Electromagnetic_interference "https://en.wikipedia.org/wiki/Electromagnetic_interference") and speed dropping with distance and obstacles.
  
  - Using the same analogy, a WiFi channel in the [2.4 GHz](https://en.wikipedia.org/wiki/List_of_WLAN_channels "https://en.wikipedia.org/wiki/List_of_WLAN_channels"), [5GHz](https://en.wikipedia.org/wiki/List_of_WLAN_channels#5_GHz_%28802.11a%2Fh%2Fn%2Fac%2Fax%29 "https://en.wikipedia.org/wiki/List_of_WLAN_channels#5_GHz_%28802.11a%2Fh%2Fn%2Fac%2Fax%29") or [6GHz](https://en.wikipedia.org/wiki/List_of_WLAN_channels#6_GHz_%28802.11ax_and_802.11be%29 "https://en.wikipedia.org/wiki/List_of_WLAN_channels#6_GHz_%28802.11ax_and_802.11be%29") can only ever have a certain physical width (Channel widths are 20,40, 80, 160, 320 MHz). This channel width is the maximum number of lanes that can used for both upload and download.
  - Assuming that the physical speed of the WiFi connection (WiFi 6) is 1201 Mbps (80 MHz channel, 1024-QAM, 2×2 MIMO) close to the access point, this 1201 Mbps is the maximum shared between multiple devices and neighbors. [https://www.wiisfi.com/#PHY](https://www.wiisfi.com/#PHY "https://www.wiisfi.com/#PHY")
    
    - As an example: 520 Mbps DL + 416 UL + 265 a neighbor the actual throughput (taking into account interference, losses and overhead) for the download will probably be about 365 Mbps for the device downloading, and upload of 290 Mbps for another device uploading at the same time, and approximately 185 Mbps used by the neighbor (total for upload and download)
    - In an ideal scenario where only one device is downloading using this channel and no other devices nearby the speed might actually be 840Mbps (again taking into account interference, losses and overhead).

## Choosing components

The following section describes possibilities when choosing components, not as an exhaustive list. Ever since it's inception at [ARPANET](https://en.wikipedia.org/wiki/ARPANET "https://en.wikipedia.org/wiki/ARPANET") the networking layer is designed to work with a wide range of equipment and provide redundancy in case one path fails. When installing a new network, or upgrading an existing network as described in the previous section the following items need to be considered:

- Router resources (CPU, RAM, storage); This describes the most common situation when the router, firewall and DHCP are on the same device and will be simply called router. Each of these functions can potentially be done by separate physical or virtual (VM) devices
  
  - Enough (CPU, RAM) for it's primary task: to route ([NAT](https://en.wikipedia.org/wiki/Network_address_translation "https://en.wikipedia.org/wiki/Network_address_translation")) the requests.
  - Having hardware flow offloading (and if implemented by OpenWRT for that device) decreases the necessary processing power, as the packages are forwarded without analysis but that makes it incompatible with SQM
  - Increased (CPU, RAM) if running [SQM](https://en.wikipedia.org/wiki/Active_queue_management#Active_queue_management_algorithms "https://en.wikipedia.org/wiki/Active_queue_management#Active_queue_management_algorithms") which inspects every package to decide the order in which they will be sent or dropped if the network is overloaded
  - Increased (CPU, RAM, storage) if running additional tasks (e.g. network related packages or containers like AdBlock, PiHole, Grafana)
- Switch link type (Ethernet, SFP+) speed (100MbE, 1GbE, 2.5GbE, 5GbE, 10GbE, etc.)
  
  - 100MbE should only be considered when attempting to deploy low bandwidth usage devices (TVs, security cameras, IoT devices), optionally with PoE
  - 1GbE should be considered the minimum for all other devices as it is cheap enough and widely available.
  - 2.5GbE is becoming more common in regular deployments
  - 5GbE and 10GbE are yet to be commonly adopted, requiring a use case to justify a need for the added cost
  - To get an understanding of what kind of device is needed please read this: [https://forum.openwrt.org/t/minimum-hardware-specs-to-run-open-wrt-on-pppoe-on-a-gigabit-connection/184365/9](https://forum.openwrt.org/t/minimum-hardware-specs-to-run-open-wrt-on-pppoe-on-a-gigabit-connection/184365/9 "https://forum.openwrt.org/t/minimum-hardware-specs-to-run-open-wrt-on-pppoe-on-a-gigabit-connection/184365/9")
- Physical connection link speeds (over Ethernet or SFP+).
  
  - Using the rule of thumb: cables are cheap but hard to replace while networking equipment is expensive but easy to replace then the highest speed cables should be deployed with the selected networking equipment.
  - The lengths provided are as a reference only, and account for using patch cables at each end. The reasoning is that the main cable is hard to replace or terminate, whereas the ends are the most easily replace if they are no longer working due to repeated insertions or movement.
  - [Cat 5e](https://en.wikipedia.org/wiki/Category_5_cable "https://en.wikipedia.org/wiki/Category_5_cable") should be considered as the bare minimum. It can run up to speeds of 2.5GbE at a distance of 100m or 1GbE at 100m
  - [Cat 6 or 6A](https://en.wikipedia.org/wiki/Category_6_cable "https://en.wikipedia.org/wiki/Category_6_cable") should really be used when deploying new cable. CAT 6A can run up to speeds of 10GbE at a distance of 100m and CAT 6 can run 5GbE at 100m
  - [Cat 7](https://en.wikipedia.org/wiki/ISO/IEC_11801#CAT7 "https://en.wikipedia.org/wiki/ISO/IEC_11801#CAT7") exists, but has different connectors which are not compatible with existing network cards
  - For speeds of 10GbE and higher connections using SFP+ are commonly used currently, usually with [DAC](https://en.wikipedia.org/wiki/Twinaxial_cabling#Networking_%28Direct-Attach_Copper%29 "https://en.wikipedia.org/wiki/Twinaxial_cabling#Networking_%28Direct-Attach_Copper%29") for distances under 10m or [fiber optic](https://en.wikipedia.org/wiki/Fiber-optic_cable "https://en.wikipedia.org/wiki/Fiber-optic_cable") for longer distances
- [Power over Ethernet](https://en.wikipedia.org/wiki/Power_over_Ethernet "https://en.wikipedia.org/wiki/Power_over_Ethernet")
- Access Point physical placement
  
  - The biggest impact on coverage of a WiFi network is the distance to the Access Point (one of the components of an all in one router is the Access Point).
  - To improve the coverage:
    
    - Change the placement of the existing Access Point
    - Add the coverage you need with a new Access Point using a wired connection to the main router (switch). Each additional AP should be on a different channel to reduce interference as much as possible.
  - Do not use WiFi extenders. These cut the bandwidth by more than half as every packet received in either direction needs to be resent over the same channel. Double the traffic on a channel resulting in half as much bandwidth
  - Do not use Mesh Network. While this works, it's using a separate frequency to bounce the packages from one Access Point to another adding latency and WiFi overhead.
  - Upgrading ISP speed alone will **not** have any impact on coverage.
  - Upgrading the all in one Router *might* improve coverage, most likely not. If there is an improved coverage that would be due to improved radio of the router's internal AP (e.g. higher MIMO, better antennas)
- WiFi speed: Refer to [https://www.wiisfi.com/](https://www.wiisfi.com/ "https://www.wiisfi.com/") for further information
