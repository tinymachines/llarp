# Setting up Wi-Fi repeaters with multiple SSIDs with separated private, tor and guest network

--- *[a humbly committed student](mailto:og.openwrt@gmail.com "og.openwrt@gmail.com") 2019/01/19 10:31*

The purpose of this article is to show users how to configure a main router and multiple access points to repeat multiple SSIDs through the use of tagged VLAN switches.

This example contains one main router that will supply the Wi-Fi SSIDs and DHCP service and two routers configured as access points. In this example, the Linksys WRT 3200acm router with OpenWrt 18.01 was used for all devices.

These procedures can be done primarily on the LuCI web interface but due to me not being able to attach screenshots, I have done the configuration through the routers config files located in /etc/config during an SSH session into each router.

It is recommended to be familiar with the following wiki articles to perform this task.

- [How-to: Creating an additional virtual switch on a typical home router](/docs/guide-user/network/vlan/creating_virtual_switches "docs:guide-user:network:vlan:creating_virtual_switches")
- [Wi-Fi Extender or Repeater or Bridge Configuration](/docs/guide-user/network/wifi/relay_configuration "docs:guide-user:network:wifi:relay_configuration")
- [Routed AP](/docs/guide-user/network/wifi/routedap "docs:guide-user:network:wifi:routedap")
- [802.11s based wireless mesh network](/docs/guide-user/network/wifi/mesh/80211s "docs:guide-user:network:wifi:mesh:80211s")

This article may contain network configuration that depends on migration to DSA in OpenWrt 21.02

- Check if your device uses DSA or swconfig as not all devices have been migrated
- ifname@interface has been moved to device sections
- [DSA Networking](/docs/guide-user/network/dsa/start "docs:guide-user:network:dsa:start")
- [Mini tutorial for DSA network config](https://forum.openwrt.org/t/mini-tutorial-for-dsa-network-config/96998 "https://forum.openwrt.org/t/mini-tutorial-for-dsa-network-config/96998") on the forum
- [DSA in the 21.02 release notes](https://openwrt.org/releases/21.02/notes-21.02.0#new_network_configuration_syntax_and_boardjson_change "https://openwrt.org/releases/21.02/notes-21.02.0#new_network_configuration_syntax_and_boardjson_change")

## Use-case scenario

This is a network topology for this example:

[Network Topology Example](https://creately.com/diagram/jqvt7mog/XMLuTm22lf8t2ZGA2XqaZx0sSn8%3D "https://creately.com/diagram/jqvt7mog/XMLuTm22lf8t2ZGA2XqaZx0sSn8%3D")

### Wi-Fi and VLAN Configuration Breakdown

The SSIDs were created and bridged to their respective Network interface. Each Network interface was added to their own specific VLAN ID.

The two APs were configured to use the WAN port to receive the tagged uplink connection from the tagged interface port of the previous router/hop. I did this to allow me to utilize the 4 ports of the LAN which gave me more ports to connect devices to.

It becomes a matching game to ensure the VLAN ID number that is attached to each of the Wi-Fi interfaces are consistent on all devices i.e. private is on VLAN1 (eth0.1), guest is on VLAN3 (eth0.3), tor is on VLAN4 (eth0.4), etc. so that each router knows the existence of the VLANs.

List of Wi-Fi SSIDs:

- Private: SSID = Magick Mushroom, Gaming
- Guest: SSID = Slave
- Tor: SSID = tor

### Main Router Configuration Procedures:

#### Switch details

VLAN ID Upstream side:HW switch ↔ eth1 driver Downstream side:HW switch↔physical ports CPU (eth0) cpu (eth1) LAN1LAN2LAN3LAN4WAN 1 tagged off untaggeduntaggeduntaggedtaggedoff 2 off tagged offoffoffoffuntagged 3 tagged off offoffofftaggedoff 4 tagged off offoffofftaggedoff

\**Tip: To determine your routers WAN CPU when there are multiple CPUs listed is to use the LuCI web interface and navigate to Network&gt;Switch and see which row has both the CPU tagged and the WAN untagged, together, by default. Another way is to use the LuCI web interface to navigate to Network&gt;Interfaces and see what Interface is used under the Physical Settings of the WAN*

1\. Create extra VLANs to match the table above. The LAN4 interface was configured to be tagged with VLAN ID numbers. The LAN4 is rebroadcasting the uplink to the next router (the midrange router).

/etc/config/network

Click to see less

```
config interface 'loopback'
	option ifname 'lo'
	option proto 'static'
	option ipaddr '127.0.0.1'
	option netmask '255.0.0.0'

config globals 'globals'
	option ula_prefix 'fdfb:7e04:aca7::/48'

config interface 'lan'
	option type 'bridge'
	option ifname 'eth0.1'
	option proto 'static'
	option netmask '255.255.255.0'
	option ip6assign '60'
	option ipaddr '192.168.0.1'
	option gateway '192.168.0.1'
	option broadcast '192.168.0.255'
	option dns '8.8.8.8'

config interface 'wan'
	option ifname 'eth1.2'
	option proto 'dhcp'
	option hostname 'infraverse.network'

config interface 'wan6'
	option ifname 'eth1.2'
	option proto 'dhcpv6'

config switch
	option name 'switch0'
	option reset '1'
	option enable_vlan '1'

config switch_vlan
	option device 'switch0'
	option vlan '1'
	option vid '1'
	option ports '0t 1 2 3 5t'

config switch_vlan
	option device 'switch0'
	option vlan '2'
	option ports '4 6t'
	option vid '2'

config interface 'slave'
	option type 'bridge'
	option proto 'static'
	option ipaddr '172.16.0.1'
	option netmask '255.255.0.0'
	option ifname 'eth0.3 radio1'
	option gateway '172.16.0.1'
	option broadcast '172.16.255.255'

config interface 'tor'
	option proto 'static'
	option ipaddr '10.1.1.1'
	option netmask '255.0.0.0'
	option type 'bridge'
	option ifname 'eth0.4'

config switch_vlan
	option device 'switch0'
	option vlan '3'
	option vid '3'
	option ports '0t 5t'

config switch_vlan
	option device 'switch0'
	option vlan '4'
	option vid '4'
	option ports '0t 5t'
```

2\. Create Wi-Fi interfaces.

![:!:](/lib/images/smileys/exclaim.svg) Be sure to make the SSID names and passwords identical to what is configured on the main router

/etc/config/wireless

Click to see less

```
config wifi-device 'radio0'
	option type 'mac80211'
	option channel '36'
	option hwmode '11a'
	option path 'soc/soc:pcie/pci0000:00/0000:00:01.0/0000:01:00.0'
	option htmode 'VHT80'
	option country 'US'
	option legacy_rates '1'

config wifi-iface 'default_radio0'
	option device 'radio0'
	option network 'lan'
	option mode 'ap'
	option ssid 'Gaming'
	option encryption 'psk-mixed'
	option key 'supersecretpassword'
	option wpa_disable_eapol_key_retries '1'

config wifi-device 'radio1'
	option type 'mac80211'
	option hwmode '11g'
	option path 'soc/soc:pcie/pci0000:00/0000:00:02.0/0000:02:00.0'
	option country 'US'
	option legacy_rates '1'
	option distance '7.7'
	option channel '11'
	option htmode 'HT20'

config wifi-iface 'default_radio1'
	option device 'radio1'
	option network 'lan'
	option mode 'ap'
	option ssid 'Magick Mushroom'
	option encryption 'psk-mixed'
	option key 'supersecretpassword'
	option wpa_group_rekey '0'

config wifi-iface
	option device 'radio1'
	option mode 'ap'
	option encryption 'none'
	option ssid 'Slave'
	option isolate '1'
	option network 'slave'

config wifi-iface
	option device 'radio1'
	option mode 'ap'
	option encryption 'none'
	option ssid 'tor'
	option network 'tor'
```

3\. Create firewall rules

/etc/config/firewall

Click to see less

```
config defaults
	option syn_flood '1'
	option input 'ACCEPT'
	option output 'ACCEPT'
	option forward 'REJECT'

config zone
	option name 'lan'
	list network 'lan'
	option input 'ACCEPT'
	option output 'ACCEPT'
	option forward 'ACCEPT'

config zone
	option name 'wan'
	list network 'wan'
	list network 'wan6'
	option input 'REJECT'
	option output 'ACCEPT'
	option forward 'REJECT'
	option masq '1'
	option mtu_fix '1'

config rule
	option name 'Allow-DHCP-Renew'
	option src 'wan'
	option proto 'udp'
	option dest_port '68'
	option target 'ACCEPT'
	option family 'ipv4'

config rule
	option name 'Allow-Ping'
	option src 'wan'
	option proto 'icmp'
	option icmp_type 'echo-request'
	option family 'ipv4'
	option target 'ACCEPT'

config rule
	option name 'Allow-IGMP'
	option src 'wan'
	option proto 'igmp'
	option family 'ipv4'
	option target 'ACCEPT'

config rule
	option name 'Allow-DHCPv6'
	option src 'wan'
	option proto 'udp'
	option src_ip 'fc00::/6'
	option dest_ip 'fc00::/6'
	option dest_port '546'
	option family 'ipv6'
	option target 'ACCEPT'

config rule
	option name 'Allow-MLD'
	option src 'wan'
	option proto 'icmp'
	option src_ip 'fe80::/10'
	list icmp_type '130/0'
	list icmp_type '131/0'
	list icmp_type '132/0'
	list icmp_type '143/0'
	option family 'ipv6'
	option target 'ACCEPT'

config rule
	option name 'Allow-ICMPv6-Input'
	option src 'wan'
	option proto 'icmp'
	list icmp_type 'echo-request'
	list icmp_type 'echo-reply'
	list icmp_type 'destination-unreachable'
	list icmp_type 'packet-too-big'
	list icmp_type 'time-exceeded'
	list icmp_type 'bad-header'
	list icmp_type 'unknown-header-type'
	list icmp_type 'router-solicitation'
	list icmp_type 'neighbour-solicitation'
	list icmp_type 'router-advertisement'
	list icmp_type 'neighbour-advertisement'
	option limit '1000/sec'
	option family 'ipv6'
	option target 'ACCEPT'

config rule
	option name 'Allow-ICMPv6-Forward'
	option src 'wan'
	option dest '*'
	option proto 'icmp'
	list icmp_type 'echo-request'
	list icmp_type 'echo-reply'
	list icmp_type 'destination-unreachable'
	list icmp_type 'packet-too-big'
	list icmp_type 'time-exceeded'
	list icmp_type 'bad-header'
	list icmp_type 'unknown-header-type'
	option limit '1000/sec'
	option family 'ipv6'
	option target 'ACCEPT'

config rule
	option name 'Allow-IPSec-ESP'
	option src 'wan'
	option dest 'lan'
	option proto 'esp'
	option target 'ACCEPT'

config rule
	option name 'Allow-ISAKMP'
	option src 'wan'
	option dest 'lan'
	option dest_port '500'
	option proto 'udp'
	option target 'ACCEPT'

config include
	option path '/etc/firewall.user'

config include 'miniupnpd'
	option type 'script'
	option path '/usr/share/miniupnpd/firewall.include'
	option family 'any'
	option reload '1'

config zone
	option name 'slave'
	option forward 'REJECT'
	option output 'ACCEPT'
	option network 'slave'
	option input 'REJECT'

config rule
	option target 'ACCEPT'
	option proto 'tcp udp'
	option dest_port '53'
	option name 'Slave dns'
	option src 'slave'

config rule
	option target 'ACCEPT'
	option proto 'udp'
	option dest_port '67'
	option name 'slave dhcp'
	option src 'slave'

config zone
	option name 'tor'
	option forward 'REJECT'
	option output 'ACCEPT'
	option network 'tor'
	option input 'ACCEPT'
	option syn_flood '1'
	option conntrack '1'

config rule
	option src 'tor'
	option proto 'udp'
	option dest_port '67'
	option target 'ACCEPT'
	option name 'tor DHCP'

config rule
	option src 'tor'
	option proto 'tcp'
	option dest_port '9040'
	option target 'ACCEPT'
	option name 'tor transport'

config rule
	option src 'tor'
	option proto 'udp'
	option dest_port '9053'
	option target 'ACCEPT'
	option name 'tor dns'

config redirect
	option name 'Redirect-Tor-Traffic'
	option src 'tor'
	option src_dip '!10.1.1.1'
	option dest_port '9040'
	option proto 'tcp'
	option target 'DNAT'

config redirect
	option name 'Redirect-Tor-DNS'
	option src 'tor'
	option src_dport '53'
	option dest_port '9053'
	option proto 'udp'
	option target 'DNAT'

config forwarding
	option dest 'wan'
	option src 'lan'

config forwarding
	option dest 'wan'
	option src 'tor'

config forwarding
	option dest 'tor'
	option src 'wan'

config forwarding
	option dest 'wan'
	option src 'slave'
```

4\. Create DHCP configurations

/etc/config/dhcp

Click to see less

```
config dnsmasq
	option domainneeded '1'
	option localise_queries '1'
	option rebind_protection '1'
	option rebind_localhost '1'
	option local '/lan/'
	option domain 'lan'
	option expandhosts '1'
	option authoritative '1'
	option readethers '1'
	option leasefile '/tmp/dhcp.leases'
	option resolvfile '/tmp/resolv.conf.auto'
	option nonwildcard '1'
	option localservice '1'
	option serversfile '/tmp/adb_list.overall'
        list server '8.8.8.8'
        list server '8.8.4.4'

config dhcp 'lan'
	option interface 'lan'
	option leasetime '12h'
	option dhcpv6 'server'
	option ra 'server'
	option start '2'
	option limit '254'
	option ra_management '1'

config dhcp 'slave'
	option leasetime '12h'
	option interface 'slave'
	option start '2'
	option limit '254'

config dhcp 'tor'
	option leasetime '12h'
	option interface 'tor'
	option start '2'
	option limit '254'

config dhcp 'wan'
	option interface 'wan'
	option ignore '1'

config odhcpd 'odhcpd'
	option maindhcp '0'
	option leasefile '/tmp/hosts/odhcpd'
	option leasetrigger '/usr/sbin/odhcpd-update'
	option loglevel '4'
```

### 2nd, Mid Range AP

#### Switch details

VLAN ID Upstream side:HW switch ↔ eth1 driver Downstream side:HW switch↔physical ports CPU (eth0) cpu (eth1) LAN1LAN2LAN3LAN4WAN 1 tagged tagged untaggeduntaggeduntaggedtaggedtagged 2 off off offoffoffoffoff 3 tagged tagged offoffofftaggedtagged 4 tagged tagged offoffofftaggedtagged

1\. Create extra VLANs to match the table above. The WAN and LAN4 interfaces were configured to be tagged with VLAN ID numbers. The WAN is receiving the uplink from the main router and LAN4 is rebroadcasting the uplink to the next router (the Rear range AP router).

/etc/config/network

Click to see less

```
config interface 'loopback'
	option ifname 'lo'
	option proto 'static'
	option ipaddr '127.0.0.1'
	option netmask '255.0.0.0'

config globals 'globals'
	option ula_prefix 'fdfb:7e04:aca7::/48'

config interface 'lan'
	option type 'bridge'
	option ifname 'eth0.1'
	option proto 'static'
	option netmask '255.255.255.0'
	option ip6assign '60'
	option ipaddr '192.168.0.1'
	option gateway '192.168.0.1'
	option broadcast '192.168.0.255'
	option dns '8.8.8.8'

config interface 'wan'
	option ifname 'eth1.2'
	option proto 'dhcp'
	option hostname 'infraverse.network'

config interface 'wan6'
	option ifname 'eth1.2'
	option proto 'dhcpv6'

config switch
	option name 'switch0'
	option reset '1'
	option enable_vlan '1'

config switch_vlan
	option device 'switch0'
	option vlan '1'
	option vid '1'
	option ports '0t 1 2 3 5t'

config switch_vlan
	option device 'switch0'
	option vlan '2'
	option ports '4 6t'
	option vid '2'

config interface 'slave'
	option type 'bridge'
	option proto 'static'
	option ipaddr '172.16.0.1'
	option netmask '255.255.0.0'
	option ifname 'eth0.3 radio1'
	option gateway '172.16.0.1'
	option broadcast '172.16.255.255'

config interface 'tor'
	option proto 'static'
	option ipaddr '10.1.1.1'
	option netmask '255.0.0.0'
	option type 'bridge'
	option ifname 'eth0.4'

config switch_vlan
	option device 'switch0'
	option vlan '3'
	option vid '3'
	option ports '0t 5t'

config switch_vlan
	option device 'switch0'
	option vlan '4'
	option vid '4'
	option ports '0t 5t'
```

2\. Create Wi-Fi interfaces.

![:!:](/lib/images/smileys/exclaim.svg) Be sure to make the SSID names and passwords identical to what is configured on the main router

/etc/config/wireless

Click to see less

```
config wifi-device 'radio0'
	option type 'mac80211'
	option channel '36'
	option hwmode '11a'
	option path 'soc/soc:pcie/pci0000:00/0000:00:01.0/0000:01:00.0'
	option htmode 'VHT80'
	option country 'US'
	option legacy_rates '1'

config wifi-iface 'default_radio0'
	option device 'radio0'
	option network 'lan'
	option mode 'ap'
	option ssid 'Gaming'
	option encryption 'psk-mixed'
	option key 'supersecretpassword'
	option wpa_disable_eapol_key_retries '1'

config wifi-device 'radio1'
	option type 'mac80211'
	option hwmode '11g'
	option path 'soc/soc:pcie/pci0000:00/0000:00:02.0/0000:02:00.0'
	option country 'US'
	option legacy_rates '1'
	option distance '7.7'
	option channel '11'
	option htmode 'HT20'

config wifi-iface 'default_radio1'
	option device 'radio1'
	option network 'lan'
	option mode 'ap'
	option ssid 'Magick Mushroom'
	option encryption 'psk-mixed'
	option key 'supersecretpassword'
	option wpa_group_rekey '0'

config wifi-iface
	option device 'radio1'
	option mode 'ap'
	option encryption 'none'
	option ssid 'Slave'
	option isolate '1'
	option network 'slave'

config wifi-iface
	option device 'radio1'
	option mode 'ap'
	option encryption 'none'
	option ssid 'tor'
	option network 'tor'
```

3\. Create firewall rules

/etc/config/firewall

Click to see less

```
config defaults
	option syn_flood '1'
	option input 'ACCEPT'
	option output 'ACCEPT'
	option forward 'REJECT'

config zone
	option name 'lan'
	list network 'lan'
	option input 'ACCEPT'
	option output 'ACCEPT'
	option forward 'ACCEPT'

config zone
	option name 'wan'
	list network 'wan'
	list network 'wan6'
	option input 'REJECT'
	option output 'ACCEPT'
	option forward 'REJECT'
	option masq '1'
	option mtu_fix '1'

config rule
	option name 'Allow-DHCP-Renew'
	option src 'wan'
	option proto 'udp'
	option dest_port '68'
	option target 'ACCEPT'
	option family 'ipv4'

config rule
	option name 'Allow-Ping'
	option src 'wan'
	option proto 'icmp'
	option icmp_type 'echo-request'
	option family 'ipv4'
	option target 'ACCEPT'

config rule
	option name 'Allow-IGMP'
	option src 'wan'
	option proto 'igmp'
	option family 'ipv4'
	option target 'ACCEPT'

config rule
	option name 'Allow-DHCPv6'
	option src 'wan'
	option proto 'udp'
	option src_ip 'fc00::/6'
	option dest_ip 'fc00::/6'
	option dest_port '546'
	option family 'ipv6'
	option target 'ACCEPT'

config rule
	option name 'Allow-MLD'
	option src 'wan'
	option proto 'icmp'
	option src_ip 'fe80::/10'
	list icmp_type '130/0'
	list icmp_type '131/0'
	list icmp_type '132/0'
	list icmp_type '143/0'
	option family 'ipv6'
	option target 'ACCEPT'

config rule
	option name 'Allow-ICMPv6-Input'
	option src 'wan'
	option proto 'icmp'
	list icmp_type 'echo-request'
	list icmp_type 'echo-reply'
	list icmp_type 'destination-unreachable'
	list icmp_type 'packet-too-big'
	list icmp_type 'time-exceeded'
	list icmp_type 'bad-header'
	list icmp_type 'unknown-header-type'
	list icmp_type 'router-solicitation'
	list icmp_type 'neighbour-solicitation'
	list icmp_type 'router-advertisement'
	list icmp_type 'neighbour-advertisement'
	option limit '1000/sec'
	option family 'ipv6'
	option target 'ACCEPT'

config rule
	option name 'Allow-ICMPv6-Forward'
	option src 'wan'
	option dest '*'
	option proto 'icmp'
	list icmp_type 'echo-request'
	list icmp_type 'echo-reply'
	list icmp_type 'destination-unreachable'
	list icmp_type 'packet-too-big'
	list icmp_type 'time-exceeded'
	list icmp_type 'bad-header'
	list icmp_type 'unknown-header-type'
	option limit '1000/sec'
	option family 'ipv6'
	option target 'ACCEPT'

config rule
	option name 'Allow-IPSec-ESP'
	option src 'wan'
	option dest 'lan'
	option proto 'esp'
	option target 'ACCEPT'

config rule
	option name 'Allow-ISAKMP'
	option src 'wan'
	option dest 'lan'
	option dest_port '500'
	option proto 'udp'
	option target 'ACCEPT'

config include
	option path '/etc/firewall.user'

config include 'miniupnpd'
	option type 'script'
	option path '/usr/share/miniupnpd/firewall.include'
	option family 'any'
	option reload '1'

config zone
	option name 'slave'
	option forward 'REJECT'
	option output 'ACCEPT'
	option network 'slave'
	option input 'REJECT'

config rule
	option target 'ACCEPT'
	option proto 'tcp udp'
	option dest_port '53'
	option name 'Slave dns'
	option src 'slave'

config rule
	option target 'ACCEPT'
	option proto 'udp'
	option dest_port '67-68'
	option name 'slave dhcp'
	option src 'slave'

config zone
	option name 'tor'
	option forward 'REJECT'
	option output 'ACCEPT'
	option network 'tor'
	option input 'ACCEPT'
	option syn_flood '1'
	option conntrack '1'

config rule
	option src 'tor'
	option proto 'udp'
	option dest_port '67'
	option target 'ACCEPT'
	option name 'tor DHCP'

config rule
	option src 'tor'
	option proto 'tcp'
	option dest_port '9040'
	option target 'ACCEPT'
	option name 'tor transport'

config rule
	option src 'tor'
	option proto 'udp'
	option dest_port '9053'
	option target 'ACCEPT'
	option name 'tor dns'

config redirect
	option name 'Redirect-Tor-Traffic'
	option src 'tor'
	option src_dip '!10.1.1.1'
	option dest_port '9040'
	option proto 'tcp'
	option target 'DNAT'

config redirect
	option name 'Redirect-Tor-DNS'
	option src 'tor'
	option src_dport '53'
	option dest_port '9053'
	option proto 'udp'
	option target 'DNAT'

config forwarding
	option dest 'wan'
	option src 'lan'

config forwarding
	option dest 'wan'
	option src 'tor'

config forwarding
	option dest 'tor'
	option src 'wan'

config forwarding
	option dest 'wan'
	option src 'slave'
```

4\. Create DHCP configurations

/etc/config/dhcp

Click to see less

```
config dnsmasq
	option domainneeded '1'
	option localise_queries '1'
	option rebind_protection '1'
	option rebind_localhost '1'
	option local '/lan/'
	option domain 'lan'
	option expandhosts '1'
	option authoritative '1'
	option readethers '1'
	option leasefile '/tmp/dhcp.leases'
	option resolvfile '/tmp/resolv.conf.auto'
	option nonwildcard '1'
	option localservice '1'
	option serversfile '/tmp/adb_list.overall'
        list server '8.8.8.8'
        list server '8.8.4.4'

config dhcp 'lan'
	option interface 'lan'
	option leasetime '12h'
	option dhcpv6 'server'
	option ra 'server'
	option start '2'
	option limit '254'
	option ra_management '1'

config dhcp 'slave'
	option leasetime '12h'
	option interface 'slave'
	option start '2'
	option limit '254'

config dhcp 'tor'
	option leasetime '12h'
	option interface 'tor'
	option start '2'
	option limit '254'

config dhcp 'wan'
	option interface 'wan'
	option ignore '1'

config odhcpd 'odhcpd'
	option maindhcp '0'
	option leasefile '/tmp/hosts/odhcpd'
	option leasetrigger '/usr/sbin/odhcpd-update'
	option loglevel '4'
```

### 3rd, Rear Range AP

#### Switch details

VLAN ID Upstream side:HW switch ↔ eth1 driver Downstream side:HW switch↔physical ports CPU (eth0) cpu (eth1) LAN1 LAN2 LAN3 LAN4 WAN 1 tagged tagged untaggeduntaggeduntaggeduntaggedtagged 2 off off offoffoffoffoff 3 tagged tagged offoffoffofftagged 4 tagged tagged offoffoffofftagged

1\. Create extra VLANs to match the table above. The WAN interface was configured to be tagged with VLAN ID numbers. The WAN is receiving the uplink from the mid router.

/etc/config/network

Click to see less

```
config interface 'loopback'
	option ifname 'lo'
	option proto 'static'
	option ipaddr '127.0.0.1'
	option netmask '255.0.0.0'

config globals 'globals'
	option ula_prefix 'fdcb:2636:4335::/48'

config interface 'lan'
	option type 'bridge'
	option ifname 'eth0.1'
	option proto 'static'
	option netmask '255.255.255.0'
	option ip6assign '60'
	option ipaddr '192.168.0.252'
	option gateway '192.168.0.1'
	option broadcast '192.168.0.255'

config interface 'wan'
	option ifname 'eth1.2'
	option proto 'static'
	option netmask '255.255.255.0'
	option gateway '192.168.0.1'
	option broadcast '192.168.1.255'
	option ipaddr '192.168.0.252'

config interface 'wan6'
	option ifname 'eth1.2'
	option proto 'dhcpv6'

config switch
	option name 'switch0'
	option reset '1'
	option enable_vlan '1'

config switch_vlan
	option device 'switch0'
	option vlan '1'
	option vid '1'
	option ports '0 1 2 3 4t 5t 6t'

config switch_vlan
	option device 'switch0'
	option vlan '2'
	option vid '2'

config switch_vlan
	option device 'switch0'
	option vlan '3'
	option vid '3'
	option ports '4t 5t 6t'

config switch_vlan
	option device 'switch0'
	option vlan '4'
	option vid '4'
	option ports '4t 5t 6t'

config interface 'slave'
	option proto 'static'
	option ipaddr '172.16.0.252'
	option netmask '255.255.255.0'
	option gateway '172.16.0.1'
	option broadcast '172.16.255.255'
	option type 'bridge'
	option ifname 'eth0.3'

config interface 'tor'
	option proto 'static'
	option ipaddr '10.1.1.252'
	option netmask '255.0.0.0'
	option type 'bridge'
	option ifname 'eth0.4'
```

2\. Create Wi-Fi interfaces.

![:!:](/lib/images/smileys/exclaim.svg) Be sure to make the SSID names and passwords identical to what is configured on the main router

/etc/config/wireless

Click to see less

```
config wifi-device 'radio0'
	option type 'mac80211'
	option hwmode '11a'
	option path 'soc/soc:pcie/pci0000:00/0000:00:01.0/0000:01:00.0'
	option htmode 'VHT80'
	option country 'US'
	option legacy_rates '1'
	option channel '44'

config wifi-iface 'default_radio0'
	option device 'radio0'
	option network 'lan'
	option mode 'ap'
	option ssid 'Gaming'
	option encryption 'psk-mixed'
	option key 'supersecretpassword'
	option wpa_disable_eapol_key_retries '1'

config wifi-device 'radio1'
	option type 'mac80211'
	option hwmode '11g'
	option path 'soc/soc:pcie/pci0000:00/0000:00:02.0/0000:02:00.0'
	option htmode 'HT20'
	option country 'US'
	option legacy_rates '1'
	option channel '9'

config wifi-iface 'default_radio1'
	option device 'radio1'
	option network 'lan'
	option mode 'ap'
	option ssid 'Magick Mushroom'
	option encryption 'psk-mixed'
	option key 'supersecretpassword'
	option wpa_disable_eapol_key_retries '1'

config wifi-device 'radio2'
	option type 'mac80211'
	option channel '36'
	option hwmode '11a'
	option path 'platform/soc/soc:internal-regs/f10d8000.sdhci/mmc_host/mmc0/mmc0:0001/mmc0:0001:1'
	option htmode 'VHT80'
	option disabled '1'

config wifi-iface 'default_radio2'
	option device 'radio2'
	option network 'lan'
	option mode 'ap'
	option ssid 'OpenWrt'
	option encryption 'none'

config wifi-iface
	option device 'radio1'
	option mode 'ap'
	option encryption 'none'
	option ssid 'Slave'
	option isolate '1'
	option network 'slave'

config wifi-iface
	option device 'radio1'
	option mode 'ap'
	option encryption 'none'
	option ssid 'tor'
	option isolate '1'
	option network 'tor'
```

3\. Create firewall rules

/etc/config/firewall

Click to see less

```
config defaults
	option syn_flood '1'
	option input 'ACCEPT'
	option output 'ACCEPT'
	option forward 'REJECT'

config zone
	option name 'lan'
	option input 'ACCEPT'
	option output 'ACCEPT'
	option forward 'ACCEPT'
	option network 'lan'

config zone
	option name 'wan'
	option input 'REJECT'
	option output 'ACCEPT'
	option forward 'REJECT'
	option masq '1'
	option mtu_fix '1'
	option network 'wan wan6'

config forwarding
	option src 'lan'
	option dest 'wan'

config rule
	option name 'Allow-DHCP-Renew'
	option src 'wan'
	option proto 'udp'
	option dest_port '68'
	option target 'ACCEPT'
	option family 'ipv4'

config rule
	option name 'Allow-Ping'
	option src 'wan'
	option proto 'icmp'
	option icmp_type 'echo-request'
	option family 'ipv4'
	option target 'ACCEPT'

config rule
	option name 'Allow-IGMP'
	option src 'wan'
	option proto 'igmp'
	option family 'ipv4'
	option target 'ACCEPT'

config rule
	option name 'Allow-DHCPv6'
	option src 'wan'
	option proto 'udp'
	option src_ip 'fc00::/6'
	option dest_ip 'fc00::/6'
	option dest_port '546'
	option family 'ipv6'
	option target 'ACCEPT'

config rule
	option name 'Allow-MLD'
	option src 'wan'
	option proto 'icmp'
	option src_ip 'fe80::/10'
	list icmp_type '130/0'
	list icmp_type '131/0'
	list icmp_type '132/0'
	list icmp_type '143/0'
	option family 'ipv6'
	option target 'ACCEPT'

config rule
	option name 'Allow-ICMPv6-Input'
	option src 'wan'
	option proto 'icmp'
	list icmp_type 'echo-request'
	list icmp_type 'echo-reply'
	list icmp_type 'destination-unreachable'
	list icmp_type 'packet-too-big'
	list icmp_type 'time-exceeded'
	list icmp_type 'bad-header'
	list icmp_type 'unknown-header-type'
	list icmp_type 'router-solicitation'
	list icmp_type 'neighbour-solicitation'
	list icmp_type 'router-advertisement'
	list icmp_type 'neighbour-advertisement'
	option limit '1000/sec'
	option family 'ipv6'
	option target 'ACCEPT'

config rule
	option name 'Allow-ICMPv6-Forward'
	option src 'wan'
	option dest '*'
	option proto 'icmp'
	list icmp_type 'echo-request'
	list icmp_type 'echo-reply'
	list icmp_type 'destination-unreachable'
	list icmp_type 'packet-too-big'
	list icmp_type 'time-exceeded'
	list icmp_type 'bad-header'
	list icmp_type 'unknown-header-type'
	option limit '1000/sec'
	option family 'ipv6'
	option target 'ACCEPT'

config rule
	option name 'Allow-IPSec-ESP'
	option src 'wan'
	option dest 'lan'
	option proto 'esp'
	option target 'ACCEPT'

config rule
	option name 'Allow-ISAKMP'
	option src 'wan'
	option dest 'lan'
	option dest_port '500'
	option proto 'udp'
	option target 'ACCEPT'

config include
	option path '/etc/firewall.user'

config zone
	option name 'slave'
	option input 'ACCEPT'
	option forward 'REJECT'
	option output 'ACCEPT'
	option network 'slave'

config zone
	option name 'tor'
	option input 'ACCEPT'
	option forward 'REJECT'
	option output 'ACCEPT'
	option network 'tor'
```

4\. Create DHCP configurations

/etc/config/dhcp

Click to see less

```
config dnsmasq
	option domainneeded '1'
	option boguspriv '1'
	option filterwin2k '0'
	option localise_queries '1'
	option rebind_protection '1'
	option rebind_localhost '1'
	option local '/lan/'
	option domain 'lan'
	option expandhosts '1'
	option nonegcache '0'
	option authoritative '1'
	option readethers '1'
	option leasefile '/tmp/dhcp.leases'
	option resolvfile '/tmp/resolv.conf.auto'
	option nonwildcard '1'
	option localservice '1'

config dhcp 'lan'
	option interface 'lan'
	option dhcpv6 'server'
	option ra 'server'
	option ignore '1'
	option ra_management '1'

config dhcp 'wan'
	option interface 'wan'
	option ignore '1'

config odhcpd 'odhcpd'
	option maindhcp '0'
	option leasefile '/tmp/hosts/odhcpd'
	option leasetrigger '/usr/sbin/odhcpd-update'
	option loglevel '4'
```
