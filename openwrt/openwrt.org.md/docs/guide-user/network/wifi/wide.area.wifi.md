# Wide area Wi-Fi coverage

This article may contain network configuration that depends on migration to DSA in OpenWrt 21.02

- Check if your device uses DSA or swconfig as not all devices have been migrated
- ifname@interface has been moved to device sections
- [DSA Networking](/docs/guide-user/network/dsa/start "docs:guide-user:network:dsa:start")
- [Mini tutorial for DSA network config](https://forum.openwrt.org/t/mini-tutorial-for-dsa-network-config/96998 "https://forum.openwrt.org/t/mini-tutorial-for-dsa-network-config/96998") on the forum
- [DSA in the 21.02 release notes](https://openwrt.org/releases/21.02/notes-21.02.0#new_network_configuration_syntax_and_boardjson_change "https://openwrt.org/releases/21.02/notes-21.02.0#new_network_configuration_syntax_and_boardjson_change")

## Introduction

This HOWTO requires proficienciy in an [OpenVPN](https://en.wikipedia.org/wiki/OpenVPN "https://en.wikipedia.org/wiki/OpenVPN")-based [Virtual private network](https://en.wikipedia.org/wiki/Virtual%20private%20network "https://en.wikipedia.org/wiki/Virtual private network") (cf. [server.tap](/docs/guide-user/services/vpn/openvpn/server.tap "docs:guide-user:services:vpn:openvpn:server.tap")/[client.tun](/docs/guide-user/services/vpn/openvpn/client.tun "docs:guide-user:services:vpn:openvpn:client.tun") and [server.tap](/docs/guide-user/services/vpn/openvpn/server.tap "docs:guide-user:services:vpn:openvpn:server.tap")/[client.tap](/docs/guide-user/services/vpn/openvpn/client.tap "docs:guide-user:services:vpn:openvpn:client.tap")), Networking configuration on [RHEL](https://en.wikipedia.org/wiki/Red%20Hat%20Enterprise%20Linux "https://en.wikipedia.org/wiki/Red Hat Enterprise Linux")/[CentOS](https://en.wikipedia.org/wiki/CentOS "https://en.wikipedia.org/wiki/CentOS"), [Shorewall](https://en.wikipedia.org/wiki/Shorewall "https://en.wikipedia.org/wiki/Shorewall") (cf. [shorewall-on-openwrt](/docs/guide-user/firewall/shorewall/shorewall-on-openwrt "docs:guide-user:firewall:shorewall:shorewall-on-openwrt")).

In the proposed scenario a big area must be covered with Wi-Fi access and no Access Point alone can provide that kind of reachability. Three different Wi-Fi networks are configured for different access levels. Traffic from these networks will be isolated and controlled by a central Linux box running Shorewall. A wired Ethernet backbone will carry traffic from the Access Points (three in our example). The encapsulation protocol for different network traffic will be OpenVPN with no cypher(encryption can be enabled with one liner 'cypher' statement if required). The author has successfully done a similar setup using 802.1q (VLAN) encapsulation. L2tp is a another reasonable alternative for traffic encapsulation (cf. [network.interfaces](/docs/guide-developer/networking/network.interfaces "docs:guide-developer:networking:network.interfaces")).

The following is a simplified scheme of the network structure of the solution described here:

[![](/_media/media/doc/howtos/wide_area_wifi_howto.png)](/_detail/media/doc/howtos/wide_area_wifi_howto.png?id=docs%3Aguide-user%3Anetwork%3Awifi%3Awide.area.wifi "media:doc:howtos:wide_area_wifi_howto.png")

Configuration files are provided, but nothing prohibits the much more easy configuration with the LuCi web interface.

### Acess Point Configuration

- Flash OpenWrt Attitude Adjustment on your router (i've used the venerable tp-link 1043nd)
- Connect it to internet and do “opkg install openvpn” from console
- Setup hostname, date, timezone and password as you wish
- Configure Networks (/etc/config/network) (Plan your addressing based on the previous diagram)
  
  ```
  config interface 'loopback'                                                     
          option ifname 'lo'                                                      
          option proto 'static'                                                   
          option ipaddr '127.0.0.1'                                               
          option netmask '255.0.0.0'                                              
                                                                                  
  config interface 'lan'                                                          
          option ifname 'eth0.1'                                                  
          option type 'bridge'                                                    
          option proto 'static'                                                   
          option netmask '255.255.255.0'                                          
          option ipaddr '192.168.1.3'                                             
          option dns '192.168.1.2'                                                
          option gateway '192.168.1.2'                                            
                                                                                  
  config switch                                                                   
          option name 'rtl8366rb'                                                 
          option reset '1'                                                        
          option enable_vlan '1'                                                  
          option enable_vlan4k '1'                                                
                                                                                  
  config switch_vlan                                                              
          option device 'rtl8366rb'                                               
          option vlan '1'                                                         
          option ports '0 1 2 3 4 5t'                                             
                                                                                  
  config interface 'workers'                                                      
          option type 'bridge'                                                    
          option ifname 'tapWorkers'                                              
          option _orig_ifname 'tapWorkers wlan0-1'                                
          option _orig_bridge 'true'                                              
          option proto 'static'                                                   
          option ipaddr '192.168.2.2'                                             
          option netmask '255.255.255.0' 
  
  config interface 'guests'             
          option type 'bridge'
          option proto 'static'
          option ifname 'tapGuests'
          option ipaddr '192.168.3.2'
          option netmask '255.255.255.0'                                         
                     
  ```

<!--THE END-->

- Configure wireless (/etc/config/wireless). 'Access' network is not tunneled and goes to raw ethernet, 'guests' goes to the unsecure network and 'workers' to the secure network. **Put your own SSID, MAC Address and PSK**
  
  ```
  .
  config wifi-device 'radio0'
          option type 'mac80211'
          option macaddr '54:e6:fc:fb:a7:10'
          option hwmode '11g'
          option htmode 'HT20'
          list ht_capab 'SHORT-GI-40'
          list ht_capab 'DSSS_CCK-40'
          option channel '6'
          option txpower '27'
          option country 'US'
          option distance '15'
  
  config wifi-iface
          option device 'radio0'
          option network 'lan'
          option mode 'ap'
          option encryption 'psk2'
          option key 'secretisssimo'
          option ssid 'SuperCompany (Access)'
  
  config wifi-iface
          option device 'radio0'
          option mode 'ap'
          option encryption 'psk2'
          option network 'workers'
          option key '123supersecret'
          option ssid 'SuperCompany (Workers)'
  
  config wifi-iface
          option device 'radio0'
          option mode 'ap'
          option encryption 'psk2'
          option ssid 'SuperCompany (Guests)'
          option network 'guests'
          option key 'welcomeguests'
  
  ```

<!--THE END-->

- Disable DHCP (/etc/config/dhcp). The linux box is the global DHCP server here.
  
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
  
  config dhcp 'lan'
          option interface 'lan'
          option ignore '1'
  ```

<!--THE END-->

- Disable Firewall (config/firewall). There isn't any reason to filter traffic in the Access Point
  
  ```
  config defaults
          option input 'ACCEPT'
          option output 'ACCEPT'
          option forward 'ACCEPT'
  
  config include
          option path '/etc/firewall.user'
  ```

<!--THE END-->

- Configure OpenVPN (config/openvpn). Upload your keys (you need to generate them in the Linux box using easy-rsa scripts)
  
  ```
  package openvpn
  
  config openvpn confWorkers
  
          option enabled 1
          option client 1
  
          option dev tapWorkers
          list remote "192.168.1.2 1194"
          option lport 1194
          option proto udp
          option resolv_retry infinite
  
          option ca /etc/openvpn/ca.crt
          option cert /etc/openvpn/ap01.supercompany.tld.crt
          option key /etc/openvpn/ap01.supercompany.tld.key
          option cipher none
  
          option verb 3
          option mute 20
  
  config openvpn confGuests
  
          option enabled 1
          option client 1
  
          option dev tapGuests
          list remote "192.168.1.2 1195"
          option lport 1195
          option proto udp
          option resolv_retry infinite
  
          option ca /etc/openvpn/ca.crt
          option cert /etc/openvpn/ap01.supercompany.tld.crt
          option key /etc/openvpn/ap01.supercompany.tld.key
          option cipher none
  
          option verb 3
          option mute 20
  ```

Repeat all these steps for ap02 and ap03. **Rembember to change IP and MAC address and openvpnc keys for each Access Point!. Set each AP in different channels to prevent interference!!!!**

### Linux Box Configuration

The linux box is used as the OpenVPN concentrator for the traffic coming from the Access points. Shorewall is used to the traffic policing. OpenVPN keys are administered with “easy-rsa” scripts. CentOS 6.4 is used in this example.

#### Networking

- Configure the tunnel interfaces /etc/sysconfig/network-scripts/ifcfg-(tapGuests|tapWorkers).
  
  ```
  DEVICE=tapWorkers
  TYPE=Ethernet
  ONBOOT=yes
  BOOTPROTO=none
  NM_CONTROLLED=no
  IPADDR=192.168.2.1
  NETMASK=255.255.255.0
  TYPE=Tap
  ```

```
DEVICE=tapGuests
TYPE=Ethernet
ONBOOT=yes
BOOTPROTO=none
NM_CONTROLLED=no
IPADDR=192.168.3.1
NETMASK=255.255.255.0
TYPE=Tap
```

- Configure your wan and lan interface as you wish. Here eth0 is LAN and eth1 is WAN
  
  ```
  . 
  DEVICE=eth0
  HWADDR=E8:40:F2:3D:7F:48
  TYPE=Ethernet
  UUID=07a338a7-6753-4b4c-90fa-3a2866a10493
  ONBOOT=yes
  NM_CONTROLLED=no
  BOOTPROTO=static
  IPADDR0=192.168.1.1
  NETMASK0=255.255.255.0
  IPADDR1=192.168.1.2
  NETMASK1=255.255.255.0
  ```

```
DEVICE=eth1
HWADDR=C8:3A:35:DA:B6:80
TYPE=Ethernet
UUID=3cbafbed-181a-4025-b31e-9ab7c08eebca
ONBOOT=yes
NM_CONTROLLED=no
BOOTPROTO=static
IPADDR0=201.n.n.n
NETMASK0=255.255.255.248
IPADDR1=201.n.n.n
NETMASK1=255.255.255.248
GATEWAY=201.n.n.n
```

#### OpenVPN Server Configuration

- Configure OpenVPN (/etc/openvpn/(guests|workers).conf)
  
  ```
  mode server
  tls-server
  dev tapGuests
  port 1195
  proto udp
  keepalive 10 60
  client-to-client
  
  syslog openvpn(Guests)
  verb 3
  
  ca easy-rsa/keys/ca.crt
  cert easy-rsa/keys/net01.supercompany.tld.crt
  key easy-rsa/keys/net01.supercompany.tld.key
  dh easy-rsa/keys/dh1024.pem
  cipher none
  ```

```
mode server
tls-server
dev tapWorkers
port 1194
proto udp
keepalive 10 60
client-to-client

syslog openvpn(Workers)
verb 3

ca easy-rsa/keys/ca.crt
cert easy-rsa/keys/net01.supercompany.tld.crt
key easy-rsa/keys/net01.supercompany.tld.key
dh easy-rsa/keys/dh1024.pem
cipher none
```

#### Shorewall Configuration

Shorewall was installed from rpms (provided at their homepage).

- Define zones (/etc/shorewall/zones)
  
  ```
  #
  # Shorewall version 4 - Zones File
  #
  # For information about this file, type "man shorewall-zones"
  #
  # The manpage is also online at
  # http://www.shorewall.net/manpages/shorewall-zones.html
  #
  ###############################################################################
  #ZONE   TYPE            OPTIONS         IN                      OUT
  #                                       OPTIONS                 OPTIONS
  fw      firewall
  wan     ipv4
  lan     ipv4
  guest   ipv4
  ```

<!--THE END-->

- Define interfaces shorewall/interfaces
  
  ```
  #
  # Shorewall version 4 - Interfaces File
  #
  # For information about entries in this file, type "man shorewall-interfaces"
  #
  # The manpage is also online at
  # http://www.shorewall.net/manpages/shorewall-interfaces.html
  #
  ###############################################################################
  ?FORMAT 2
  ###############################################################################
  #ZONE           INTERFACE               OPTIONS
  wan             eth1
  lan             eth0                    
  lan             tapWorkers
  guest           tapGuests
  ```
- The policy and rules are up to you
