# Reference network topology

This is the network topology used as a common reference for most configurations for this section.

Starting from the top of the diagram is the public internet. The network has a single public IPv4 address leased from Verizon ($5US/month) terminating on a Verizon [Multimedia over Coax Alliance (MoCA)](http://www.mocalliance.org/ "http://www.mocalliance.org/") router. This router handles the telephones, video set top boxes and internet access (triple play). There is a single GigE 802.3 interface to the **MAIN** router for all internal wired and wireless internet access.

![:!:](/lib/images/smileys/exclaim.svg) Interestingly, the Verizon MoCA router runs on an ARM926 using the jungo `openrq` firmware, based on Linux 2.6.16. jungo appears to have been purchased by cisco systems many years ago; cisco is now selling [openrq](https://www.cisco.com/c/en/us/products/video/videoscape-openrg/index.html "https://www.cisco.com/c/en/us/products/video/videoscape-openrg/index.html"). It looks like Verizon has been limping along without developer support since then...

Now on to more recent technology...

The router switch in **MAIN** is configured to bridge all LAN-side traffic as the default `br-lan` interface on the `192.16.3.0/24` network. See [lan bridge](/docs/guide-user/firewall/fw3_network#lan-bridge "docs:guide-user:firewall:fw3_network") for a description of this. **MAIN** handles all the internal stations using the `192.168.3.0/24` network, mostly WLAN stations but several wired Ethernet stations for printing and NAS. In the firewall test network:

- **MAIN** is the OpenWrt production router,
- **STA1** is a linux laptop from where most of testing is initiated,
- **DUT** is the OpenWrt `Device Under Test` router wired to one of the **MAIN** 802.3 Ethernet ports,
- **STA2** is a linux laptop,
- **STA3** and **STA4** are 802.11 wifi devices (tablet, phone, etc.)
- **STA-server1** is a linux server wired to a DUT 802.3 Ethernet port in vlan 102,
- **STA-server2** is a linux desktop wired to a DUT 802.3 Ethernet port in vlan 103.

Unless otherwise noted, an IPv4 address is assigned using DHCP.

**MAIN** is provisioned with a static lease added for **DUT** so the **DUT** will always gets the same IP address: `192.168.3.11`. Static routes to the **DUT** network(s) must also be added to the **MAIN** routing table so **STA1** can communicate with devices in vlan 102 and vlan 103. See [ipv4 configuration](/docs/guide-user/network/ipv4/start "docs:guide-user:network:ipv4:start") for provisioning static routes.

The **DUT** is configured with two VLANs. `eth0.102` is a lan bridge using the `192.168.10.0/24` network for basic firewall testing. `eth0.103` has a single wired Ethernet port using the `192.168.30.0/24` network for [DMZ](/docs/guide-user/firewall/fw3_configurations/fw3_dmz "docs:guide-user:firewall:fw3_configurations:fw3_dmz") testing.

The reference topology allows firewall rules to be modified on the **DUT** in a sandbox without exposing it to the Internet; only **MAIN** LAN-side stations can access the **DUT**. Of secondary importantce, firewall rule testing has little probability of causing complete comms loss from **STA1** to the **DUT** (but it can still happen if I really hose the firewall rule set!)

![:!:](/lib/images/smileys/exclaim.svg) Generally the policy is set to ACCEPT for LAN to WAN so all traffic initiated from the LAN-side is forwarded. In our topology, the policy is set to REJECT, so a firewall rule must be explicitly added for each service from LAN to WAN (e.g. ICMP, SSH, HTTP). This results in less confusion when a packet is forwarded but is expected to be rejected or dropped.

[![](/_media/media/firewall-test-topov4.png?w=800&tok=3e7318)](/_media/media/firewall-test-topov4.png "media:firewall-test-topov4.png")
