# Routed Client

In the default configuration, OpenWrt bridges the wireless network to the LAN of the device. Most wireless drivers do not support bridging in client mode, therefore the traffic between LAN and the wireless client must be routed.

## Using MASQUERADE

If you have no administrative access (e.g. ability to configure static route entries) to the target Access Point, the local LAN subnet must be *masqueraded* to ensure proper routing.  
When configuration of the target Access Point is possible, start with the *masqueraded* configuration below and proceed with the steps in the [Using routing](#using_routing "docs:guide-user:network:routedclient ↵") section to define a fully routed setup.

[![Masqueraded](/_media/doc/howto/802.11-routed-masq.png "Masqueraded")](/_detail/doc/howto/802.11-routed-masq.png?id=docs%3Aguide-user%3Anetwork%3Aroutedclient "doc:howto:802.11-routed-masq.png")

The steps outlined below cover the process of putting the radio into client mode and reusing the existing WAN interface and its NAT firewall rules to connect to the target network.

This article may contain network configuration that depends on migration to DSA in OpenWrt 21.02

- Check if your device uses DSA or swconfig as not all devices have been migrated
- ifname@interface has been moved to device sections
- [DSA Networking](/docs/guide-user/network/dsa/start "docs:guide-user:network:dsa:start")
- [Mini tutorial for DSA network config](https://forum.openwrt.org/t/mini-tutorial-for-dsa-network-config/96998 "https://forum.openwrt.org/t/mini-tutorial-for-dsa-network-config/96998") on the forum
- [DSA in the 21.02 release notes](https://openwrt.org/releases/21.02/notes-21.02.0#new_network_configuration_syntax_and_boardjson_change "https://openwrt.org/releases/21.02/notes-21.02.0#new_network_configuration_syntax_and_boardjson_change")

### Configuration

The changes below assume an OpenWrt default configuration, the relevant files are:

- [/etc/config/network](/docs/guide-user/base-system/basic-networking "docs:guide-user:base-system:basic-networking")
- [/etc/config/wireless](/docs/guide-user/network/wifi/basic "docs:guide-user:network:wifi:basic")

Before doing any actual configuration, the wifi interface must be enabled and put into station mode in order to be able to scan for networks in the vicinity:

```
uci del wireless.@wifi-device[0].disabled
uci del wireless.@wifi-iface[0].network
uci set wireless.@wifi-iface[0].mode=sta
uci commit wireless
wifi
```

- Remove the *disable 1* option from the wireless configuration
- Set the *mode* option to station
- Save changed configuration file
- Start wireless using the *wifi* command

Now we can issue the `iwlist scan` command to list networks in range, the required information is highlighted (see scan below).

Attention - Update according to forum entries

mk24 wrote: Whoever wrote the wiki was using an old Broadcom device. For anything modern, use:

```
iwinfo wlan0 scan
```

A low level scan (more detailed) can be done directly through iw:

```
iw dev wlan0 scan
```

And of course on a **dual band router** changing to wlan1 would scan the other band. The scan is not necessary if you already know the SSID and encryption type of the AP that you want to connect to.

`root@OpenWrt:~# iwlist scan wlan0 Scan completed :           Cell 01 - Address: 00:1D:19:0E:03:8F                     ESSID:“Vodafone-0E0301“                     Mode:Managed                     Channel:9                     Quality:3/5 Signal level:-69 dBm Noise level:-92 dBm                     IE: IEEE 802.11i/WPA2 Version 1                         Group Cipher : TKIP                         Pairwise Ciphers (2) : TKIP CCMP                         Authentication Suites (1) : PSK                        Preauthentication Supported                     IE: WPA Version 1                         Group Cipher : TKIP                         Pairwise Ciphers (2) : TKIP CCMP                         Authentication Suites (1) : PSK                     Encryption key:on                     Bit Rates:1 Mb/s; 2 Mb/s; 5.5 Mb/s; 6 Mb/s; 9 Mb/s                               11 Mb/s; 12 Mb/s; 18 Mb/s; 24 Mb/s; 36 Mb/s                               48 Mb/s; 54 Mb/s`

- *ESSID* is the name of the network
- *Channel* specifies at which frequency the corresponding network is operating on
- The lines starting with *IE:* report which encryption capabilities are supported by the access point:
  
  - *IEEE 802.11i/WPA2 Version 1* indicates WPA2
  - *WPA Version 1* indicates WPA
  - If both WPA and WPA2 are present, the network is most likely operating in WPA/WPA2 mixed mode
  - If no *IE:* appears after the scanning, the wireless network could be using WEP mode.

![](/_media/meta/48px-dialog-warning.svg.png) If you see a message like `Device or resource busy`, a *wpa\_supplicant* instance is most likely locking the interface. In this case kill the running process and repeat the scan:

```
killall -9 wpa_supplicant
iwlist scan
```

#### Step 1: Change the WAN interface

Edit `/etc/config/network` and change the WAN interface by editing the existing `ifname` option:

`config 'interface' 'wan'         option 'proto' 'dhcp'`

Note that the `wan` network section **must not** contain any `ifname` option.

#### Step 2: Change the existing wireless network

Supposed we want to connect to the network called “Vodafone-0E0301”, the previous scan result revealed the following information:

- ESSID is `Vodafone-0E0301`
- Channel is `9`
- The network uses WPA/WPA2 mixed mode

In `/etc/config/wireless`, locate the existing `wifi-iface` section and change its network option to point to the WAN interface. Change the `mode` option to `sta` (Station) and alter the SSID and [encryption options](/docs/guide-user/network/wifi/encryption "docs:guide-user:network:wifi:encryption") to match those of the target network. Channel doesn't necessary have to match.

`config 'wifi-device' 'wlan0'         option 'type' 'broadcom'         option 'channel' '9' config 'wifi-iface'         option 'device' 'wlan0'         option 'network' 'wan'         option 'mode' 'sta'         option 'ssid' 'Vodafone-0E0301'         option 'encryption' 'psk2'         option 'key' 'secret-key'`

### Apply changes

Reconfigure the wireless network.

```
ifup wan
wifi
```

![](/_media/meta/48px-dialog-warning.svg.png) If the target network uses the 192.168.1.0/24 subnet, you **must** change the default LAN IP address to a different subnet, e.g. 192.168.**2**.1 .  
You can determine the assigned WAN address with the following command:

```
. /lib/functions/network.sh; network_get_ipaddr IP_WAN wan; echo $IP_WAN
192.168.1.30
```

At this point, the masqueraded client configuration should be finished. Optionally you can bridge former wan ethernet port to switch, so you will be able to use all ethernet ports as lan clients. Note, that following config works for atheros routers, where wan port is usually eth1, but you should find the correct port name using **ifconfig** command.

```
vi /etc/config/network
```

`config interface 'lan'         option ifname 'eth0 eth1'         option type 'bridge'         option proto 'static' . .`

## Using routing

In contrast to *masquerading*, a fully routed setup allows access from hosts of the Access Point network to hosts in the client network by using the client routers WAN IP address as gateway for the client network behind it.

This kind of network topology is not possible when the client does NAT, since the addresses behind the NAT are not reachable from the outside, unless additional measures like port forwardings are configured.

[![Routed network topology](/_media/doc/howto/802.11-routed-client.png "Routed network topology")](/_detail/doc/howto/802.11-routed-client.png?id=docs%3Aguide-user%3Anetwork%3Aroutedclient "doc:howto:802.11-routed-client.png")

This section covers the process of changing the firewall config to allow incoming WAN traffic and disabling *masquerading* in the corresponding zone.

* * *

![](/_media/meta/48px-dialog-warning.svg.png) The fully routed client configuration is based on the [masqueraded config](#usingmasquerade "docs:guide-user:network:routedclient ↵") and assumes an already working client setup.  
**Only proceed with the routed configuration below if you have the ability to reconfigure the remote Access Point!**

* * *

### Configuration

In addition to the files in the [masqueraded setup](#usingmasquerade "docs:guide-user:network:routedclient ↵"), the relevant config files are:

- [/etc/config/firewall](/docs/guide-user/firewall/firewall_configuration "docs:guide-user:firewall:firewall_configuration")

#### Step 1: Change the firewall configuration

Edit the `/etc/config/firewall` file and locate the WAN [zone](/inbox/firewall/firewall3/fw3_network "inbox:firewall:firewall3:fw3_network") definition. Disable masquerading and set the incoming traffic policy to ACCEPT:

`config 'zone'         option 'name' 'wan'         option 'input' 'ACCEPT'         option 'output' 'ACCEPT'         option 'forward' 'REJECT'         option 'mtu_fix' '1'         option 'masq' '0'`

Proceed with adding a new [forwarding](/docs/guide-user/firewall/firewall_configuration#forwardings "docs:guide-user:firewall:firewall_configuration") section allowing traffic flow from WAN to LAN:

`config 'forwarding'         option 'src' 'wan'         option 'dest' 'lan'`

#### Step 2: Configure the Access Point

In order to make the local LAN subnet reachable for clients in the Access Point subnet, you need to configure a *static route* pointing to our LAN network on the AP. How to configure leases and routes on the Access Point differs from model to model. In doubt, consult the operation manual.

Since static routes need a static gateway to work properly, the WAN IP address of the client mode wireless must be fixed, there are two possible ways to achieve that:

- **Use a static DHCP lease** - the AP will associate the MAC address of the requesting client mode wireless adapter to a fixed IP address in the AP network, e.g. 192.168.1.30
- **Use a fixed IP on WAN** - the client mode wireless adapter will not request DHCP at all but use a fixed IP configuration instead.

When using the fixed IP approach, the WAN interface in `/etc/config/network` must be changed from the DHCP protocol to `static`:

`config 'interface' 'wan'         option 'proto' 'static'         option 'ipaddr' '192.168.1.30'         option 'netmask' '255.255.255.0'`

![](/_media/meta/48px-dialog-warning.svg.png) Make sure that the address range does not overlap with the LAN network.  
You **must** change the LAN address if it is in the same subnet, e.g. to 192.168.**2**.1

After fixing the WAN address, a static route must be added to the Access Point with the following information:

- IP address: 192.168.2.1 (IP address of our LAN interface)
- Destination LAN NET (required in DD-WRT): 192.168.2.0 (our LAN interface subnet)
- Netmask: 255.255.255.0 (Netmask of our LAN interface)
- Gateway: 192.168.1.30 (IP address of our WAN interface)

You may also need to set the policy of the firewall of the Access Point to 'ACCEPT' forwarded traffic for the LAN zone, in order for hosts in the Client network to communicate with hosts (other than directly to the router itself) on the Access Point network. E.g. (referring to the diagram) for Client Host 1 to communicate with LAN Host 1.

### Apply changes

Reconfigure the wireless network.

```
ifup wan
wifi
```

Restart the firewall.

```
/etc/init.d/firewall restart
```

### After setup everything works BUT client subnet cannot access internet

This is due to the reason that AP router (in this case 192.168.1.1) does not masquerade client subnet (192.168.2.0/24).

If you cannot (or don't want to) modify AP router's firewall in deep, you can configure client router (192.168.2.1) in the following way:  
Edit the `/etc/config/firewall` file and locate the WAN [zone](/inbox/firewall/firewall3/fw3_network "inbox:firewall:firewall3:fw3_network") definition.

`config 'zone' option 'name' 'wan' option 'input' 'ACCEPT' option 'output' 'ACCEPT' option 'forward' 'REJECT' option 'mtu_fix' '1' option masq_dest !192.168.1.0/24 option 'masq' '1'`

Please note that in this way client router (192.168.2.1) will masquerade everything EXCEPT AP subnet and AP router (192.168.1.1) will handle packets from client subnet to internet and vica-versa.  
This is double masquerading which works fine especially if you cannot make it work otherwise. Avoid double NATting whenever possible!!

## Using routing : an alternative solution

(assumption: you know how to apply the changes)

### Scenario description

There is a router access point (based on openwrt 12.09 final ) and a router wifi client (based on openwrt 12.09 final). The router access point from now on is called WP (wifi provider) and the router wifi client is called WC (wifi client) The diagram of the network is the following:

```
Internet <---wired---> WP <---wireless---> WC
```

The **WP** is creating a lan network, through wireless and lan ports, using the subnet `192.168.10.0/24`. The **WP** lan interface is configured as follows (file `etc/config/network` ):

```
config interface 'lan'
        option type 'bridge'
        option ifname 'eth0.0'
        option proto 'static'
        option netmask '255.255.255.0'
        option ipaddr '192.168.10.1'
```

The **WC** instead, is using the wireless to connect to the **WP** and to create a second wifi network. In this case the wireless interface is attached to the network `wan` as `sta` mode and is attached to the network `lan` as `ap` mode, as follows (file `/etc/config/wireless` ):

```
config wifi-iface
        option device   radio0
        option network  lan
        option mode     ap
        option ssid     'Second wifi'
        option encryption       psk2
        option key      'password.2'

config wifi-iface
        option device   radio0
        option network  wan
        option mode     'sta'
        option ssid     'Master wifi'
        option encryption       psk2
        option key      'password.1'
```

The second network created by the **WC** is using the subnet `192.168.11.0/24` and is getting a dhcp IP on the wan interface, as follows:

```
config interface 'lan'
        option ifname 'eth0'
        option type 'bridge'
        option proto 'static'
        option ipaddr '192.168.11.1'
        option netmask '255.255.255.0'
        
config interface 'wan'
        option proto     'dhcp'
        option hostname  'WC'
```

Now we want that both networks see each other.

### Connecting WC lan side to the WP lan side and to the internet

For the lan side of **WC** there is not so much problem to reach the `192.168.10.0/24` provided by the **WP**. Because the latter is seen as wan network, and to reach that network from the lan side of **WC** only the 'classic' forwarding lan→wan is needed. This means, in the file `/etc/config/firewall`, that the following rule is needed:

```
config forwarding
        option src              lan
        option dest             wan
```

In this way requests from the **WC** lan side are allowed to reach the **WC** wan side that contains the **WP** lan network.

But we should not forget about masquerading (explained briefly at least here [basic-networking](/docs/guide-user/base-system/basic-networking "docs:guide-user:base-system:basic-networking") ). By default the wan zone has masquerading, but this means that when a computer from the **WC** lan side wants to connect to a computer on the **WP** lan side, its ip will be masqueraded. Therefore we should avoid masquerading when a computer on the **WC** lan side wants to reach an IP address in the network `192.168.10.0/24` this is done in this way (file `/etc/config/firewall` ):

```
config zone
        option name                 wan
        list   network              'wan'
        option input                REJECT
        option output               ACCEPT
        option forward              REJECT
        option masq                 1
        #routed bridged wireless network - start
        option masq_dest            '!192.168.10.1/24'
        list comment '(do not with !)'
        list comment ' masquerade what is going to the declared subnet(s)'
        list comment 'remember that is "masq_destination"'
        #routed bridged wireless network - end
        option mtu_fix              1
```

In this way the **WC** lan side is able to reach the **WP** lan side without “obscuration” and the internet side (this with obscuration by masquerading).

### Connecting WP lan side to the WC lan side

First we should enable the possibility that packets coming on the wan side of **WC** could reach the lan side of **WC**. This is done through forwarding (see [Firewall Documentation](/docs/guide-user/firewall/start "docs:guide-user:firewall:start") and [iptables\_and\_firewall](/docs/guide-user/firewall/netfilter-iptables/iptables_and_firewall "docs:guide-user:firewall:netfilter-iptables:iptables_and_firewall") ).

In particular we want that if a packet coming on the wan side of **WC** has the source in the network `192.168.10.0/24` then it is allowed to go through the device (that is: coming from an interface and going to another interface decided by routing rules). So on **WC** in `/etc/config/firewall` we add:

```
config rule 'forward_from_master_net'
        option src      wan
        option dest     lan
        option src_ip   '192.168.10.0/24'
        option proto    all
        option target   ACCEPT
        
#this means: if a packet, of whatever protocol, is coming on the wan side from a source in 192.168.10.0/24
#            and the routing rules are sending it towards the lan side, let it pass.
```

Now it is the turn of configuration on **WP**. First **WP** should know that the **WC** is 'a device to ask' about the network `192.168.11.0/24` and this means a static routing rule. But a static routing rule requires a gateway that is consistently reachable. Since **WC** is using dhcp on lan, we have to assign a static dhcp on the **WP** side for **WC**. So on **WP** we modifiy `/etc/config/dhcp` adding a reservation for **WC**.

```
config host wc
        option ip       192.168.10.20
        option mac      '<mac address>'
```

Now (after we applied the changes on both systems) we have the possibility of defining a static route on **WP** in `/etc/config/network`:

```
config 'route' 'to_repeater'
        option 'interface' 'lan'
        option 'target' '192.168.11.0'
        option 'netmask' '255.255.255.0'
        option 'gateway' '192.168.10.20'
        list comment 'to the wifi repeater'
        list comment 'as routed wireless client'
        list comment 'as exposed in the owrt wiki'
```

It seems all but it is not. It is a subtle problem of how the networking standards behave (but once you know them, it is ok). On the **WP** the command `route -n` shows this:

```
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
...lines...
192.168.10.0    0.0.0.0         255.255.255.0   U     0      0        0 br-lan
192.168.11.0    192.168.10.20   255.255.255.0   UG    0      0        0 br-lan
```

So it seems that if a packet is coming from br-lan and wants to go to 192.168.11.0, since it will go through the same interface, no problem should occur. And instead not, different routes, even on the same interface, create a bit of obstacles. It is like that only packets coming from an interface and going through the same interface, when the source of the packet and the destination of the packet are matched by the same routing rule, do not create any problem.

In the case that the interface is the same (for input and output) but the source of the packet differs from the destination shown in the routing rule, then the packet is stopped. What do we need then? Seems counter-intuitive but: forwarding.

On **WP** in `/etc/config/firewall` we need a rule that says “a packet coming on the lan side can go through the lan side without being stopped”:

```
config forwarding
        option src 'lan'
        option dest 'lan'
```

And with this we have ended our problems. Computer in `192.168.10.0/24` can communicate with computers in `192.168.11.0/24` and viceversa using original ip addresses.
