# DMZ configuration using VLANs

The [DMZ](https://en.wikipedia.org/wiki/DMZ_%28computing%29 "https://en.wikipedia.org/wiki/DMZ_(computing)") is a **security concept**. It comprises the separation of the LAN-side network into at least two networks: the user LAN and the DMZ. Generally the DMZ is imprisoned: only access to certain ports from the Internet are allowed into the DMZ, while the DMZ is not allowed to establish new connections to the WAN-side or LAN-side networks. That way, if a server inside of the DMZ is hacked the potential damage that can be done remains restricted! The whole point of the DMZ is to cleanly create a unique firewall rule set that dramatically restricts access in to, and out of the, DMZ.

Publicly accessible servers remain the most vulnerable part of any network, although they are:

- set up and hardened professionally
- updated regularly
- and also thoroughly monitored (mail Log files and read the mail)

Many of the malicious robots and spiders on the internet scan well-known TCP ports and then try to exploit vulnerabilities. The most used webserver, Apache, has numerous POVs (Point of Vulnerability) that can be exploited. See the [CVE database](http://cve.mitre.org "http://cve.mitre.org") on Apache vulnerabilities or [Apache 2.4 Vulnerabilities](https://httpd.apache.org/security/vulnerabilities_24.html "https://httpd.apache.org/security/vulnerabilities_24.html") for information - scary!

For more information on splitting up your OpenWrt LAN-side network (default is a single bridge) into more networks:

- [Network Interfaces](/docs/guide-developer/networking/network.interfaces "docs:guide-developer:networking:network.interfaces")
- [switch\_configuration](/docs/guide-user/network/vlan/switch_configuration "docs:guide-user:network:vlan:switch_configuration")

## Adding a VLAN

It is possible to set up firewall rules based simply on the IP addresses of the public servers (see [NAT for LAN-side Public Server](/docs/guide-user/firewall/fw3_configurations/fw3_nat#lan-side_public_server "docs:guide-user:firewall:fw3_configurations:fw3_nat")), but this is not the most secure topology. If an attack exploits a POV and gains access to the public server all stations behind the firewall could be available to the attacker.

A more secure topology is to set up a separate VLAN for the DMZ, stick it into a new firewall zone and groom the firewall rules for only that zone.

This following switch configuration will assign switch ports specifically to traffic to the stations in the DMZ.

![:!:](/lib/images/smileys/exclaim.svg) The DMZ station(s) should be attached to a wired ethernet switch port. First for better performance and second for easier VLAN provisioning.

Use the switch interface in [/etc/config/network](/docs/guide-user/base-system/basic-networking "docs:guide-user:base-system:basic-networking") or through the LuCI *Network → Switch* page.

This example is based on, and tested against, the [Reference Network Topology](/docs/guide-user/firewall/fw3_configurations/fw3_ref_topo "docs:guide-user:firewall:fw3_configurations:fw3_ref_topo"). The `STA-server2` station is a public webserver accessible from the internet.

The switch ports are highly dependent on the switch hardware. To view how the physical ports are configured, use:

```
swconfig list
swconfig dev switch0 show
```

![:!:](/lib/images/smileys/exclaim.svg) Confirm the switch ports align with the physical labeling on the router. Sometimes wired ports `1,2,3,4` are labelled as `4,3,2,1`.

The Ethernet switches used in this example have the following switch port mappings (Atheros/Qualcomm):

- 0: wired port to WAN (1)
- 1, 2, 3, 4: wired GigE LAN ports (4)
- 5: eth1 to the CPU
- 6: eth0 to the CPU

So where are the 802.11 WLANs? For the DUT, there is only one, a 2.4GHz 802.11n interface integrated on the CPU chip. Both the CPU and the WLAN use the CPU eth0 switch port.

The original `/etc/config/network` shows VLAN1 for the WAN-side and VLAN2 for the LAN-side. VLAN1 has port 0 and port 5: the wired WAN port and eth1 to the CPU. VLAN2 has port 1,2,3,4 and 6: the four wired ports and eth0 for the CPU and WLAN PHY.

```
config switch
	option name 'switch0'
	option reset '1'
	option enable_vlan '1'
 
config switch_vlan
	option device 'switch0'
	option vlan '1'
	option ports '0 5'
 
config switch_vlan
	option device 'switch0'
	option vlan '2'
	option ports '1 2 3 4 6'
```

To split off the DMZ on the LAN-side, pick a port (`1`) for the DMZ and use it in a vlan. Notice both VLANs have `6t` in the port list. In VLAN 102 this is the CPU and WLAN, in VLAN 103 this is just the CPU. It **must** be a tagged port to differentiate which VLAN the packet is on.

```
config switch_vlan
        option device 'switch0'
        option vlan '102'
        option ports '2 3 4 6t'
	list comment 'vlan102: LAN ports'
 
config switch_vlan
        option device 'switch0'
        option vlan '103'
        option ports '1 6t'
	list comment 'vlan103: LAN-side DMZ'
```

It is very helpful to add a comment using `list comment` and to assign vlans with some sort of pattern. The DUT switch can support up to 4095 VLANs.

![:!:](/lib/images/smileys/exclaim.svg) The `vid` option defaults to the `vlan` index so no need to specify it also. In fact, it is generally just a configuration error source.

![:!:](/lib/images/smileys/exclaim.svg) On many Realtek and Atheros switches the ARL table (where the switch stores already learned MACs and the corresponding ports), uses only the MAC address for indexing. This has the effect that the switch tries to forward a frame to a port that isn't part of the current VLAN (since it learned that the destination is at that port), notes that the destination isn't part of the current VLAN, and drops the frame. When making changes be sure to flush the router ARL cache when provisioning the new VLANs.

Next, add the interface for the DMZ:

```
config 'interface' dmz
        option 'ifname' eth0.103
        option 'proto'   static
        option 'ipaddr'  192.168.30.1
        option 'netmask' 255.255.255.0
```

Notice the `ifname` must correspond to the `<port>.<vlan>`. The subnet must be different than the other VLANs.

### Services

Once you set up the firewall, DNS should automatically be available to the new network, DHCP will not. For DHCP, you need to add a new section to `/etc/config/dhcp`. It is very similar to the `lan` section.

```
config dhcp 'dmz'
	option interface 'dmz'
	option start '50'
	option limit '70'
	option leasetime '12h'
```

Additionally, the public server **should** be very static, so it helps to add a static DHCP lease. First because it makes the firewall rules easier and second to debug future issues:

```
config host
	option name 'STA-server2'
	option dns '1'
	option mac '24:B6:FD:24:59:B9'
	option ip '192.168.30.20'
	option leasetime '12h'
```

## Setting up the firewall

Now the most important thing, the reason why you split up your network: the firewall rules. A typical DMZ can be fully provisioned using the [firewall application](/docs/guide-user/firewall/overview "docs:guide-user:firewall:overview").

Each VLAN **should** be a unique firewall zone. So create one for the DMZ. Nothing is initiated from the DM zone so the policy is to REJECT everything.

```
config 'zone'
       option 'name' 'dmz'
       option 'input' 'REJECT'
       option 'output' 'REJECT'
       option 'forward' 'REJECT'
       option 'network' 'dmz'
```

Now, the main goal is to redirect HTTP/S from the Internet to the `STA-server2`. First, allow DHCPDISCOVER and DHCPOFFER messages for DHCP to work properly. Next, allow the server to do DNS lookups. Finally, for maintenance, allow SSH from any station in the LAN zone.

```
# Make STA-server:80 publicly accessible using the public ipv4 of the router
config redirect             
        option target 'DNAT'
        option src 'wan'
        option src_dport '80 443'
        option proto 'tcp'
        option family 'ipv4'
        option dest 'dmz'
        option dest_ip '192.168.30.20'
        option dest_port '80'
        option name 'DNAT-HTTP-WAN-DNZ'
        option enabled '1'
 
# Allow DHCPDISCOVER
config 'rule'
	option src 'dmz'
	option proto 'udp'
	option family 'ipv4'
	option src_port 68
	option dest_port 67
	option target 'ACCEPT'
	option name 'ACCEPT-DHCPDISCOVER-DMZ'
	option enabled '1'
 
# Allow DHCPOFFER
config 'rule'
	option dest 'dmz'
	option proto 'udp'
	option family 'ipv4'
	option src_port 67
	option dest_port 68
	option target 'ACCEPT'
	option name 'ACCEPT-DHCPOFFER-DMZ'
	option enabled '1'
 
 
# Allow the DMZ to access a DNS server
config 'rule'
       option src 'dmz'
       option proto 'tcp udp'
       option dest 'wan'
       option dest_port 53
       option target 'ACCEPT'
       option name 'ACCEPT-DNS-DMZ-WAN'
       option enabled '1'
 
# Allow all LAN stations to SSH to DMZ stations
config rule   
       option src 'lan'
       option dest 'dmz'
       option proto 'tcp'
       option family 'ipv4'
       option dest_port '22'
       option target 'ACCEPT'      
       option name 'ACCEPT-SSH-LAN-DMZ'
       option enabled '1'
```

![:!:](/lib/images/smileys/exclaim.svg) What about using LuCI from the WAN zone now that a public webserver is sitting there? All requests coming in the WAN to port 80 are going to public web server so LuCI requests from the WAN-side would do the same.

If the requirement is to have LuCI access from the WAN-side, redirect HTTP to a new TCP port and use `http://dut:8080` to access the router's LuCI webserver.

```
config redirect
        option target 'DNAT'
        option src 'wan'
        option src_dport '8080'
        option proto 'tcp'
        option family 'ipv4'
        option dest_port '80'
        option name 'DNAT-HTTP-WAN-DEVICE'
        option enabled '1'
```
