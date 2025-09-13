# ISP Configurations

This page describes how to connect to networks of different commercial Internet service providers. At this time, most of the DSL configurations described below only apply to **modem**-router devices using [Lantiq SoC](/docs/techref/hardware/soc/soc.lantiq "docs:techref:hardware:soc:soc.lantiq"). [There is no DSL support for Broadcom devices](/meta/infobox/broadcom_dsl "meta:infobox:broadcom_dsl").

This article may contain network configuration that depends on migration to DSA in OpenWrt 21.02

- Check if your device uses DSA or swconfig as not all devices have been migrated
- ifname@interface has been moved to device sections
- [DSA Networking](/docs/guide-user/network/dsa/start "docs:guide-user:network:dsa:start")
- [Mini tutorial for DSA network config](https://forum.openwrt.org/t/mini-tutorial-for-dsa-network-config/96998 "https://forum.openwrt.org/t/mini-tutorial-for-dsa-network-config/96998") on the forum
- [DSA in the 21.02 release notes](https://openwrt.org/releases/21.02/notes-21.02.0#new_network_configuration_syntax_and_boardjson_change "https://openwrt.org/releases/21.02/notes-21.02.0#new_network_configuration_syntax_and_boardjson_change")

## Algeria

### ADSL IDOOM Algerie telecom

the below config is tested with ADSL 8 mbps subscription and it is confirmed that is working under version OpenWrt 19.07.4

```
config atm-bridge 'atm'
        option encaps 'llc'
        option nameprefix 'dsl'
        option vpi '0'
        option vci '100'
        option payload 'bridged'

config dsl 'dsl'
        option annex 'a'
        option ds_snr_offset '0'

config interface 'wan'
        option ifname 'dsl0'
        option proto 'pppoe'
        option username 'YOURADSLUSERNAME'
        option password 'YOURADSLPASSWORD'
        list dns '8.8.8.8'
        list dns '8.8.4.4'
        option peerdns '0'
```

## Australia

### NBN

#### Telstra (FTTN)

Place the supplied Telstra modem into *bridge mode*, and plug an openwrt router into one of the LAN ports. No special settings need to be applied, just DHCP. The Telstra modem will do the authentication for you. Note: It may be useful to assign a static IP to the OpenWrt router from the modem, and optionally place it into a DMZ

#### TPG (HFC)

Plug an openwrt router into the supplied simple DOCSIS modem (or replace modem and call support to authenticate new DOCSIS serial number). The network settings for openwrt router needs to use VLAN 2 (ethX.2), probably best to spoof MAC to match supplied router WAN interface.

```
config interface 'wan'
	option ifname 'eth1.2'
	option proto 'pppoe'
	option username 'xxxx@tpg.com.au'
	option password 'zzzz'
	option mtu '1500'
	option macaddr 'xx:xx:xx:xx:xx:xx'
	option pppd_options 'debug'
	option ipv6 'auto'
```

#### TPG (FTTC)

Simply set the WAN port to use the PPPoE protocol and enter your TPG username and password. That's all. No VLAN configuration, such as setting WAN to use VLAN2 was required.

### Legacy Network (ADSL/ADSL2+)

#### TPG (ADSL2+)

A good way to configure your internet is using two devices: A dedicated modem that just accepts all ATM traffic and bridges it to its ethernet port, and a second device that acts as a router to your internal LAN, and the WAN port authenticates to your ISP via pppoe, and is physically connected to the first device over ethernet cable.

Below, I show two configs, one config for the modem, (here Netgear DM200 ADSL2+/VDSL modem) and the second config showing the necessary authentication to TPG ISP for the second device (another OpenWrt router).

```
package network                                                                 
                                                                                
config atm-bridge 'atm'                                                         
        option vpi '8'                                                          
        option vci '35'                                                         
        option encaps 'llc'                                                     
        option payload 'bridged'                                                
                                                                                
config dsl 'dsl'                                                                
        option annex 'a2p'                                                      
        option fwannex 'a'                                                      
        option firmware '/lib/firmware/lantiq-vrx200-a.bin'                     
        option xfer_mode 'atm'                                                  
                                                                                
config interface 'lan'                                                          
        option type 'bridge'                                                    
        option ifname 'eth0 nas0'                                               
        option proto 'none'                                                     
        option auto '1'                                                         
                                                                                
config device 'lan_dev'                                                         
        option name 'eth0'                                                      
        option macaddr 'yy.yy.yy.yy.yy.yy'                                      
                                                                                
config device 'wan_dev'                                                         
        option name 'nas0'                                                      
        option macaddr 'xx.xx.xx.xx.xx.xx'
```

Second device authenticates to ISP with:

```
config interface 'wan'
	option ifname 'eth1'
	option proto 'pppoe'
	option username 'xxxx@tpg.com.au'
	option password 'zzzz'
```

## Austria

### A1 Telekom Austria / VDSL2 with down- and upstream vectoring

on `/etc/config/network` we have to modify the WAN section to use vlan2

```
config interface 'wan'
        option ifname 'dsl0.2'
        option proto 'pppoe'
        option username '**********'
        option password '********'
        option ipv6 '1'
        option peerdns '0'
        option keepalive '0'
```

in the DSL section we use the annex b (and optional if you have/need it, the firmware for your modem. In this case I use a FRITZBox 7362 SL)

```
config dsl 'dsl'
        option annex 'b'
        option ds_snr_offset '0'
        option firmware '/lib/modules/vr9-B-dsl.bin'
```

### Fonira with static IPv4 and fixed IPv6 prefix

Fonira provides the option to get rid of carrier-grade NAT by purchasing a static (and non-NATed) IPv4 address, and then also provides a fixed IPv6 prefix.

```
# /etc/config/network
config interface 'wan'
        option proto 'pppoe'
        option username '******@fonira.at'  # The PPPoE username provided by Fonira.
        option password '******'  # The PPPoE password provided by Fonira.
        option device 'eth<X>.31'  # The VLAN with the ID 31 has to be used.
        option delegate '0'
        option ipv6 '1'

config interface 'wan6'
        option device '@wan'
        option proto 'dhcpv6'
        option reqaddress 'try'
        option reqprefix 'no'
        option ip6prefix '.....::/60'  # The IPv6 prefix provided by Fonira.
        option delegate '1'
```

Using the settings above, the static IPv4 address and a dynamic IPv6 address is provided to the router's WAN port by the ISP, and the fixed IPv6 prefix is used on the LAN side.

Setting `reqprefix` to `no` is needed to prevent the router from requesting an additional (dynamic) IPv6 prefix from the ISP. However, with this option set to `no`, no IPv6 route to the internet is set. This can be worked around by adding a source-route for the fixed IPv6 prefix:

```
# /etc/config/network
config route6
        option interface 'wan6'
        option target '::/0'
        option source '.....::/60'  # The IPv6 prefix provided by Fonira.
```

More details and discussions on this topic can be found in [this thread at LTEForum.at](https://www.lteforum.at/mobilfunk/statisches-ipv6-netz-mit-fonira.13760/ "https://www.lteforum.at/mobilfunk/statisches-ipv6-netz-mit-fonira.13760/") (in german).

## Azerbaijan

### CityNet (FTTB)

- Connection Type: DHCP (no PPPoE required)
- Authentication: MAC address binding (required)

**1. WAN Interface (DHCP)**

In LuCI:

1. Navigate to `Network > Interfaces > WAN`
2. Set the protocol to `DHCP Client`
3. Select the correct WAN device (e.g., \`eth0\`)

In \`/etc/config/network\`:

```
config interface 'wan'
    option ifname 'eth0'
    option proto 'dhcp'
```

**2. MAC Address Binding**

CityNet assigns your internet access to a specific MAC address (the first device connected).

- If you replace your router, you’ll need to contact CityNet support to update the MAC address on their side.
- If you know the previously registered MAC address, you can clone it on your OpenWRT device to avoid waiting.

Example:

```
config interface 'wan'
    option ifname 'eth0'
    option proto 'dhcp'
    option macaddr 'XX:XX:XX:XX:XX:XX'  # Insert the old MAC address here
```

### KATV1 (FTTB)

- Connection Type: DHCP
- Authentication: MAC address binding (mandatory)

**1. WAN Interface (DHCP)**

In LuCI:

1. Go to `Network > Interfaces > WAN`
2. Set protocol to `DHCP Client`
3. Choose the WAN device (e.g., \`eth0\`)

In \`/etc/config/network\`:

```
config interface 'wan'
    option ifname 'eth0'
    option proto 'dhcp'
```

**2. MAC Address Binding**

KATV1 locks your internet access to the MAC address of the first connected device.

- When switching to a new router (such as OpenWRT), you must contact KATV1 support and ask them to register the new MAC address of your router.
- Alternatively, you can clone the MAC address of your previous router.

Example:

```
config interface 'wan'
    option ifname 'eth0'
    option proto 'dhcp'
    option macaddr 'XX:XX:XX:XX:XX:XX'  # Replace with previously registered MAC
```

## Belgium

### EDPnet (VDSL)

EDPnet provides VDSL services through PPPoE and VLAN tagging. Keep in mind the DSL state monopolist (Proximus) still manages the backbone and keeps a whitelist of allowed modems (a few third party models, mostly AVM FRITZ!Box, and their own Proximus B-Box models).

The VLAN tagging is as follows:

- Internet: PPPoE over VLAN 10.
- VoIP: unclear.
- TV: EDPnet does not offer TV.

The following works for an [AVM FRITZ!Box 7362 SL](/toh/avm/avm_7362_sl "toh:avm:avm_7362_sl") running master (stable support won't appear with a post 18.06 release) with the whitelisted Lantiq blobs pulled off my [7490](/toh/avm/fritz.box.7490 "toh:avm:fritz.box.7490"). Besides this, the default VDSL values OpenWrt uses seem to be OK. You get reset to a fallback profile after a while, so there might be some additional background checks going on that go beyond the Lantiq driver version.

Also a TPLink WR8890 was successfully tested with firmware taken from the xDarklight repository. Testing has shown that the 'certified' blobs perform worse on these models and should be avoided as they seem to make the line unstable. A patch can be done in the VDSL driver method to return a 'certified' version string so the modem can stay on a high speed profile.

```
config interface 'wan'
    option ifname 'dsl0.10'
    option proto 'pppoe'
    option username 'b1xxxxxx'
    option password 'xxxxxx'
    option ipv6 '1'
```

### EDPnet (Fiber)

EDPnet provides Fiber services through PPPoE and VLAN tagging as well. The state monopolist (Proximus) still manages the backbone, as with VDSL, and will install an ONT to which you connect your router of choice (!) directly.

The following works on a [MikroTik RB5009UG+S+IN](/toh/mikrotik/rb5009ug_s_in "toh:mikrotik:rb5009ug_s_in") with OpenWrt 22.03 and **DSA**. At this point \`/etc/config/network\` makes a distinction between 'device' and 'interface' definitions (the latter relying on the former). I am using port 8 as WAN port and am using 'fiber' as a fancy recognisable name instead of the mundane 'p8.10' (which would be default based on the port being port 8 tagged with VLAN 10).

```
config device                                                            
        option name 'p8'                                                 
                                                                         
config device                                                            
        option type '8021q'                                              
        option ifname 'p8'                                               
        option vid '10'                                                  
        option name 'fiber'

config interface 'wan'
	option proto 'pppoe'
	option username 'blabla@EDPNET'
	option password '..............'
	option ipv6 '1'
	option device 'fiber'

config interface 'wan6'
	option proto 'dhcpv6'
	option device '@wan'
```

If you are using swconfig rather than DSA, the following is an example configuration working on an [TP-Link Archer C7](/toh/tp-link/archer_c7 "toh:tp-link:archer_c7"):

```
config interface 'wan'
        option device 'eth0.10'
        option proto 'pppoe'
        option username 'xxx'
        option password 'xxx'

config interface 'wan6'
        option device '@wan'
        option proto 'dhcpv6'

config switch
        option name 'switch0'
        option reset '1'
        option enable_vlan '1'

config switch_vlan
        option device 'switch0'
        option vlan '1'
        option ports '2 3 4 5 0t'

config switch_vlan
        option device 'switch0'
        option vlan '10'
        option ports '1t 6t'
```

## Bosnia and Herzegovina

### BH Telecom

BH Telecom provides a combination of Internet, IPTV and VoIP xDSL services via copper twisted pair.

#### ADSL2(+)

The following was tested on TP-Link TD-W8980 OpenWRT v22.03.4, using “MojaTV povremeno 1” plan via ADSL2+ connection, using default annex A xDSL firmware.

Internet PPPoE over 8/60 ATM bridge

```
config dsl 'dsl'
    option annex 'a'
    option tone 'av'
    option ds_snr_offset '0'

config atm-bridge 'atm'
    option encaps 'llc'
    option payload 'bridged'
    option nameprefix 'dsl'
    option vci '60'
    option vpi '8'
    option atmdev '0'
    option unit '0'

config device
    option name 'dsl0'

config interface 'wan'
    option device 'dsl0'
    option proto 'pppoe'
    option username 'name.surname'
    option password '**********'
    option ipv6 'auto'
```

IPTV ATM 8/40 bridge

```
# Remove some switch ports from br-lan so they can be used for bridge to IPTV STB device(s)
config device
    option name 'br-lan'
    option type 'bridge'
    list ports 'lan1'
    list ports 'lan2'
    option stp '1'
    option igmp_snooping '1'

config atm-bridge
    option encaps 'llc'
    option payload 'bridged'
    option nameprefix 'dsl'
    option vci '40'
    option vpi '8'
    option atmdev '0'
    option unit '1'

config device
    option name 'dsl1'
    option ipv6 '0'

config device
    option name 'iptv'
    option type 'bridge'
    list ports 'dsl1'
    list ports 'lan3'
    list ports 'lan4'
    option multicast '1'
    option multicast_querier '1'
    option promisc '0'
    option ipv6 '0'
```

#### VDSL2

The following was tested on TP-Link TD-W8980 OpenWRT v22.03.4, using “MojaTV povremeno 2” plan over VDSL2 connection, using default annex A xDSL firmware.

The VLAN tagging is as follows:

- Internet: PPPoE over VLAN 100.
- IPTV: Bridge to STB via VLAN 930.
- VoIP: Bridge via uknown VLAN id.

Internet PPPoE VLAN 100

```
config dsl 'dsl'
    option line_mode 'vdsl'
    option ds_snr_offset '0'
    option annex 'a'

config device
    option name 'dsl0'

config interface 'wan'
    option device 'dsl0.100'
    option proto 'pppoe'
    option username 'name.surname'
    option password '**********'
    option ipv6 'auto'
```

IPTV VLAN 930

```
# Remove some switch ports from br-lan so they can be used for bridge to IPTV STB device(s)
config device
    option name 'br-lan'
    option type 'bridge'
    option stp '1'
    option igmp_snooping '1'
    list ports 'lan1'
    list ports 'lan2'

config device
    option name 'iptv'
    option type 'bridge'
    list ports 'lan3'
    list ports 'lan4'
    list ports 'dsl0.930'
    option multicast '1'
    option multicast_querier '1'
    option promisc '0'
    option ipv6 '0'
```

## Canada

### Bell Canada Fibe

Bell Canada Fibe provides for fiber to the home (FTTH).

They use VLAN tagging and PPPoE protocol.

The VLAN tagging is usually as follows:

- Phone: VLAN 34
- Internet: PPPoE over VLAN 35
- TV: VLAN 36

```
config interface 'wan'
    option ifname 'eth1.35'
    option proto 'pppoe'
    option username 'b1xxxxxx'
    option password 'xxxxxx'
    option ipv6 'auto'

config interface 'wan6'
    option proto 'dhcpv6'
    option reqaddress 'try'
    option reqprefix 'auto'
    option ifname '@wan'
```

### MTU Settings

[Follow the MTU recommendations here](https://www.dslreports.com/forum/r31118482-Yes-you-CAN-bypass-the-HomeHub-3000 "https://www.dslreports.com/forum/r31118482-Yes-you-CAN-bypass-the-HomeHub-3000"):

- Fiddle with your MTU settings to make sure that your router doesn't have to fragment IP packets. (IP fragmentation will use more CPU on your router, increase overhead on your WAN connection, slightly degrade performance, and cause problems when connecting to networks behind misconfigured firewalls on the Internet).
- At first I used all the default settings and was getting an MTU of 1480.
- I increased the MTU on both my SFP interface and VLAN to 1520 and then set the advertised MTU and MRU settings on my PPPoE interface to 1500 and was able to get an actual MTU of 1500 on my WAN link.
- You can verify your MTU value using ping or a webservice such as the MTU test at Let Me Check.it.

### References

- How to get Bell Fibe in Quebec/Ontario (Internet and IPTV) working with pfSense [https://forum.netgate.com/topic/78892/how-to-get-bell-fibe-in-quebec-ontario-internet-and-iptv-working-with-pfsense](https://forum.netgate.com/topic/78892/how-to-get-bell-fibe-in-quebec-ontario-internet-and-iptv-working-with-pfsense "https://forum.netgate.com/topic/78892/how-to-get-bell-fibe-in-quebec-ontario-internet-and-iptv-working-with-pfsense")
- How to bypass Bell hub and use your own Route [http://forums.redflagdeals.com/please-sticky-how-bypass-bell-hub-use-your-own-router-1993629/](http://forums.redflagdeals.com/please-sticky-how-bypass-bell-hub-use-your-own-router-1993629/ "http://forums.redflagdeals.com/please-sticky-how-bypass-bell-hub-use-your-own-router-1993629/")
- Bell PPPoE and IPTV with FTTH, Guide, configuration and tidbits. [https://community.ubnt.com/t5/EdgeRouter/Bell-PPPoE-and-IPTV-with-FTTH-Guide-configuration-and-tidbits/td-p/1686977](https://community.ubnt.com/t5/EdgeRouter/Bell-PPPoE-and-IPTV-with-FTTH-Guide-configuration-and-tidbits/td-p/1686977 "https://community.ubnt.com/t5/EdgeRouter/Bell-PPPoE-and-IPTV-with-FTTH-Guide-configuration-and-tidbits/td-p/1686977")
- [Bell Fibe with your own Router](https://www.idscomm.ca/blog/bell-fibe-with-your-own-router "https://www.idscomm.ca/blog/bell-fibe-with-your-own-router")

## Croatia

### Terrakom

Terrakom runs their own FTTH infrastructure and uses PPPoE to connect. Previously they required setting just the username and password, but for recent upgrades they also set the VLAN tag to 905:

```
config interface 'PPPoE'
	option proto 'pppoe'
	option username 'xxxxxx@terrakom.hr'
	option password 'xxxxxxxxxx'
	option peerdns '0'
	option ipv6 'auto'
	option device 'wan.905'
```

### Instructions to get PPPoE parameters

For the username and password, asking the customer support nicely will do the trick.

To discover the VLAN tag (in case it's not 905 anymore), you need to trick the provided modem into trying to connect with your own PPPoE server. Here's one way how to do that:

1. Prepare a [Kali Linux Live USB](https://www.kali.org/get-kali/#kali-live "https://www.kali.org/get-kali/#kali-live") and boot into it
2. Download and compile [rp-pppoe](https://github.com/Distrotech/rp-pppoe "https://github.com/Distrotech/rp-pppoe")
3. Open wireshark and start listening on the ethernet port
4. Connect the (initially powered down) modem (use the WAN/intenet port) to your computer running Kali Linux via ethernet cable
5. Power the modem up and look at the packages sent by the modem, you should see some packages od type pppoed or similar, checking the details should give you the VLAN ID, mac address, service name and other parameters that may be important.

Another way to do this is to use a LAN hub to connect the modem (WAN/internet port), your computer running wireshark and the upstream connection. That way you can see packets for the whole process of establishing a session as exchanged between your modem and the operator infrastructure.

Both of these procedures should really work for any operator using PPPoE.

## Cyprus

### Epic (VDSL2+)

Epic provides VDSL2+ services through PPPoE and VLAN tagging (`VLAN 35`, but to be sure sniff for a while with `tcpdump -e` option).

Example configuration for AVM FritzBox 7360 V2:

```
config dsl 'dsl'
        option annex 'b'
        option ds_snr_offset '0'
        option firmware '/lib/firmware/vr9-B-dsl.bin' # Annex B Firmware for this device
        option tone 'av'
config interface 'wan'
	option proto 'pppoe'
	option ifname 'dsl0.35'
	option username 'bits*****@home'
	option password '*******'
```

### Cyta (Fiber)

Besides ADSL2+ and VDSL, Cyta provides Fiber services through PPPoE and VLAN tagging (`VLAN 42`, but to be sure sniff for a while with `tcpdum -e` option). For connection following devices are used:

- ONT like Huawei OptiXstar HG8245X6
- GPON Terminal like Huawei OptiXstar HG8010HV6 and provider's device like ZTE ZXHN H268A or your own device

Example configuration for [Xiaomi Mi Router AC2100](/toh/xiaomi/mi_router_ac2100 "toh:xiaomi:mi_router_ac2100") with OpenWrt 21.02.1, DSA and settings missed in [guide](https://www.cyta.com.cy/mp/informational/docs/settingforthirdpartymodem.pdf "https://www.cyta.com.cy/mp/informational/docs/settingforthirdpartymodem.pdf") (`username` and `password` are really dummy but not empty fields):

```
config interface 'wan'
	option proto 'dhcp'
	option hostname '*'
	option device 'wan'
	option delegate '0'

config device
	option name 'wan'
	option ipv6 '0'

config device
	option type '8021q'
	option ifname 'wan'
	option vid '42'
	option name 'wan.42'

config interface 'cyta_eth'
	option proto 'pppoe'
	option device 'wan.42'
	option username 'cyta'
	option password 'cyta'
	option ipv6 '0'
	option peerdns '0'
	list dns '1.1.1.1'
	option delegate '0'
```

### Cablenet (Fiber)

Cablenet most probably is renting Cyta's GPON to provide Fiber services through PPPoE and VLAN tagging (`VLAN 42`, but to be sure sniff for a while with `tcpdump -e` option). For connection following devices are used:

- GPON Terminal like Huawei OptiXstar HG8010HV6 and provider's device like Mikrotik RB750Gr3 (provider doesn't announce usage of your own device and doesn't provide any settings as Cyta does)

As PPPoE `username` and `password` are not dummy and not empty fields it may require to intercept them using a sniffer, setting up the VLAN and the PPPoE server on a device connected to the router's WAN port. Usually, the login is the same as the Subscription Number (SLA).

Example configuration for [MikroTik RB750Gr3](/toh/mikrotik/rb750gr3 "toh:mikrotik:rb750gr3") with OpenWrt 22.03.5 and DSA:

```
config interface 'wan'
	option proto 'dhcp'
	option hostname '*'
	option device 'wan'
	option delegate '0'

config device
	option name 'wan'
	option ipv6 '0'

config device
	option type '8021q'
	option ifname 'wan'
	option vid '42'
	option name 'wan.42'

config interface 'cablenet_eth'
	option proto 'pppoe'
	option device 'wan.42'
	option username '<username>'
	option password '<password>'
	option ipv6 '0'
	option peerdns '0'
	list dns '1.1.1.1'
	option delegate '0'
```

### Primetel (Fiber)

Primetel most probably is renting Cyta's GPON to provide Fiber services through PPPoE and VLAN tagging (`VLAN 42`, but to be sure sniff for a while with `tcpdump -e` option). For connection following devices are used:

- GPON Terminal like Huawei OptiXstar HG8010HV6 and provider's device like ZTE ZXHN H268Q (provider doesn't announce usage of your own device and doesn't provide any settings as Cyta does)

As PPPoE `username` and `password` are not dummy and not empty fields it may require to intercept them using a sniffer, setting up the VLAN and the PPPoE server on a device connected to the router's WAN port. Usually, the login looks like `provider's_router_mac_address@cpe.prime-tel.com`.

Example configuration for [Xiaomi Mi Router AC2100](/toh/xiaomi/mi_router_ac2100 "toh:xiaomi:mi_router_ac2100") with OpenWrt 21.02.1 and DSA:

```
config interface 'wan'
	option proto 'dhcp'
	option hostname '*'
	option device 'wan'
	option delegate '0'

config device
	option name 'wan'
	option ipv6 '0'

config device
	option type '8021q'
	option ifname 'wan'
	option vid '42'
	option name 'wan.42'

config interface 'primetel_eth'
	option proto 'pppoe'
	option device 'wan.42'
	option username '<provider's_router_mac_address>@cpe.prime-tel.com'
	option password '<password>'
	option ipv6 '0'
	option peerdns '0'
	list dns '1.1.1.1'
	option delegate '0'
```

## Czech Republic

### O2

O2 provides documentation for Internet [here](https://www.o2.cz/osobni/techzona-modemy-pro-adsl-vdsl/273154-ostatni_modemy_nikoli_od_o2.html?article=550534 "https://www.o2.cz/osobni/techzona-modemy-pro-adsl-vdsl/273154-ostatni_modemy_nikoli_od_o2.html?article=550534").

#### VDSL

- Protocol: PPPoE
- VLAN: 848
- Username: O2
- Password: O2

```
config interface 'wan'
        option proto 'pppoe'
        option username 'O2'
        option ifname 'dsl0.848'
        option ipv6 'auto'
        option password 'O2'
        
config dsl 'dsl'
        option annex 'b'
        option ds_snr_offset '0'
        option line_mode 'vdsl'
        option tone 'bv'
        option xfer_mode 'ptm'        
```

#### O2TV (IPTV)

O2 provides documentation for IPTV [here](https://www.o2.cz/osobni/techzona-modemy-pro-adsl-vdsl/273154-ostatni_modemy_nikoli_od_o2.html?article=550539 "https://www.o2.cz/osobni/techzona-modemy-pro-adsl-vdsl/273154-ostatni_modemy_nikoli_od_o2.html?article=550539").

- Bridge mode
- VLAN: 835

Example configuration on TP-Link TD-W8980B / TD-9980B. IPTV is plugged in port 'LAN2'.

```
config interface 'iptv'
        option type 'bridge'
        option proto 'dhcp'
        option hostname 'O2TV'
        option peerdns '0'
        option defaultroute '0'
        option ifname 'dsl0.835 eth0.835'
        
config switch
        option name 'switch0'
        option reset '1'
        option enable_vlan '1'

config switch_vlan
        option device 'switch0'
        option vlan '1'
        option ports '6t 5 2 4'
        option vid '1'

config switch_vlan
        option device 'switch0'
        option vlan '2'
        option vid '835'
        option ports '6t 0'        
```

## Egypt

### ADSL

#### WE (TE Data)

*(If using ISP-provided router-modem)*

- Delete the WAN connection form your ISP router. Create another one as **Bridge**. Use the following data for the connection:
  
  ```
  VPI/VCI: 0/35
  Encapsulation Type: LLC
  Service Type: UBR
  Type: Bridge Connection
  ```

<!--THE END-->

- For OpenWrt, you will need to add or edit the following in `/etc/config/network` for interface WAN. You should replace the username and password with those given to you by your ISP.
  
  ```
  config interface 'WAN'
          option proto 'pppoe'
          option ifname 'eth0.2'
          option username '******@tedata.net.eg'
          option password '********'
          option ipv6 'auto'
          option mtu '1500'
          option auto '0'
  ```

**Note**: Technical support say MTU should be 1420, but 1500 seem to do just fine.

## France

### Bouygues Telecom

#### FTTH

##### IPv4

You have to use VLAN 100 and spoof the bbox MAC address.

```
config device
	option name 'wan'
	option macaddr '01:23:45:67:89:ab'

config device
	option type '8021q'
	option ifname 'wan'
	option vid '100'
	option name 'wan.100'
	option macaddr '01:23:45:67:89:ab'

config interface 'wan'
	option proto 'dhcp'
	option ifname 'wan.100'
	option clientid '0123456789AB'
	option vendorid 'BYGTELIAD'
	option hostname '*'
	option macaddr '01:23:45:67:89:ab'
```

##### IPv6

you can get a ipv6 /60 prefix with IPv6-PD.

```
config interface 'wan6'
	option proto 'dhcpv6'
	option reqaddress 'try'
	option macaddr '01:23:45:67:89:ab'
	option clientid '0123456789AB'
	option device 'wan.100'
	option reqprefix 'auto'
	option ip6assign '64'
	list ip6class 'wan6'

config interface 'lan'
	[…]
	option ip6assign '64'
	option delegate '0'
```

```
config dhcp 'wan6'
	option interface 'wan6'
	option master '1'
	option ra 'hybrid'
	option dhcpv6 'hybrid'
	option ndp 'hybrid'

config dhcp 'lan'
	option interface 'lan'
	[…]
	option ra 'hybrid'
	option dhcpv6 'hybrid'
	option ndp 'hybrid'
	list ra_flags 'managed-config'
	list ra_flags 'other-config'
	option ra_default '1'
```

## Germany

### Deutsche Telekom

Deutsche Telekom provides a documentation for their network here: [https://www.telekom.de/hilfe/geraete-zubehoer/telefone-und-anlagen/informationen-zu-telefonanlagen/schnittstellenbeschreibungen-fuer-hersteller](https://www.telekom.de/hilfe/geraete-zubehoer/telefone-und-anlagen/informationen-zu-telefonanlagen/schnittstellenbeschreibungen-fuer-hersteller "https://www.telekom.de/hilfe/geraete-zubehoer/telefone-und-anlagen/informationen-zu-telefonanlagen/schnittstellenbeschreibungen-fuer-hersteller")

#### ADSL

- ADSL LINK
- ATM
  
  - VPI (Virtual Path Identifier): 1
  - VCI (Virtual Channel Identifier): 32

##### Deutsche Telekom BNG

BNG is short for Broadband Network Gateway and Deutsche Telekom's new platform. Customers are successively migrated and usually receive a letter in the mail announcing the change.

On the old platform the customer can just setup PPPOE and the Internet connection comes up. With BNG the traffic that leaves the WAN port needs to be tagged with VLAN 7 ([Details](https://www.telekom.de/hilfe/netzumschaltung "https://www.telekom.de/hilfe/netzumschaltung")).

As an example suppose you have a modem in bridge mode that is unable to handle VLAN tagging. The router connected to the modem needs to add the VLAN tag in this case. Example for Archer C7 V2 below.

Old platform:

```
config interface 'wan'
        option proto 'pppoe'
        option username '...@t-online.de'
        option password '...'
        option ipv6 'auto'
        option ifname 'eth0.2'

config switch_vlan             
        option device 'switch0'
        option vlan '2'        
        option ports '1 6t'
```

BNG platform:

```
config interface 'wan'
        option proto 'pppoe'
        option username '...@t-online.de'
        option password '...'
        option ipv6 'auto'
        option ifname 'eth0.7'

config switch_vlan
        option device 'switch0'
        option vlan '7'
        option ports '1t 6t'
```

So if you receive a letter about the platform change and your Internet access goes down, try adding the VLAN tag to the WAN port and see if it comes up again.

Some more details that may be of interest:

- When you login into [Telekom Kundencenter](https://www.telekom.de/kundencenter/startseite "https://www.telekom.de/kundencenter/startseite") there are various configuration options available (DNS behavior, Easy Login, Auto Login, phone service configuration etc.).
- When using a SIP client from your Telekom landline connection you usually don't need to authenticate. Details are available on the Internet, for instance [here](https://telekomhilft.telekom.de/t5/Telefonie-Internet/VoIP-Authentifizierung-nur-noch-ein-Fake/td-p/1379200 "https://telekomhilft.telekom.de/t5/Telefonie-Internet/VoIP-Authentifizierung-nur-noch-ein-Fake/td-p/1379200"). That means when connected to your LAN you (or somebody else) may be able to configure one of your landline phone numbers (for instance your main phone number) on a SIP client and make calls without a valid password. This may be disturbing to some. ![LOL](/lib/images/smileys/lol.svg)

##### TAL.de TALDSL MAX VDSL2 on a Telekom line

VPI1 VCI32 VLAN-ID7 DCHPv4n/a DHCPv6n/a EncapsulationPPPoE IPv4 addressPPPoE IPv4 gatewayPPPoE IPv4 nameserverPPPoE IPv6 addressPPPoE (link-local with dynamic sub-prefix) IPv6 gatewayn/a (static route to WAN device needed) IPv6 nameserver2a01:170::1 IPv6 prefix delegationn/a (assign 2a01:170:xxxx::/48 manually to LAN device(s))

```
config interface 'wan'
	option proto 'pppoe'
	option ifname 'eth0.7'
	option ipv6 '1'
	option username '...#tal@bsa-vdsl'
	option password '...'

config route6
	option interface 'wan'
	option target '::0/0'

config interface 'lan'
	option type 'bridge'
	option proto 'static'
	option ipaddr '192.168.1.1'
	option netmask '255.255.255.0'
	option ifname 'br-lan'
	option ip6addr '2a01:170:xxxx:yyyy::1/64'
```

##### 1&amp;1 or O² on a Telekom line with Annex J

When migrating from Annex B to Annex J, connection properties seem to have changed to require using VLAN 7.

The complete username (as opposed to the simplified form used by Fritz!Boxes '1und1/1234-567@t-online.de') can be obtained from a packet capture from a Fritz!Box (if internet is so far provided via one).

- Go to [http://fritz.box/html/capture.html](http://fritz.box/html/capture.html "http://fritz.box/html/capture.html")
- Press start on the '1. Internetverbindung'
- Log into the main Fritz!Box UI and press the reconnect button
- Wait until the connection is re-established
- Stop the capture and open it in Wireshark
- Use 'pap' as filter. You should be able to read the complete username and password in the detail view

The configuration of the interfaces should look like this (tested on r6788-7ff31bed98):

```
config dsl 'dsl'
	option tone 'bv'
	option annex 'j'

config interface 'wan'
	option proto 'pppoe'
	option password '***'
	option delegate '0'
	option ipv6 'auto'
	option username '1und1/(***)1234-567@t-online.de'
#or     option username 'DSL***@s92.bbi-o2.de'
	option ifname 'dsl0.7'

config device 'wan_dev'
	option macaddr '***'
	option name 'dsl0'
```

#### VDSL

The network protocols are layered in this way:

1. VDSL link (17a profile, G.993.5 depending on the DSLAM)
2. PTM (Packet Transfer Mode)
3. Ethernet with VLAN 7 (data + voice)
4. PPPoE
   
   1. For some resale accounts an “H” has to be added in front of the pppoe user name, for 1und1 it looks like this “H1und1/1234-567@t-online.de”

You global routed IPv4 address and a some IPv6 subnets

When the network supports VDSL vectoring, but the VDSL modem does not support it, the device will be put into a fall back mode using only the lower 2.2 MHz of the band, this results in reduced rates like 13 MBit/s down and 1.4 MBit/s up instead of 50 MBit/s. Details: [https://telekomhilft.telekom.de/t5/Telefonie-Internet/Fallbackprofil-bei-Vectoring/ta-p/2431567](https://telekomhilft.telekom.de/t5/Telefonie-Internet/Fallbackprofil-bei-Vectoring/ta-p/2431567 "https://telekomhilft.telekom.de/t5/Telefonie-Internet/Fallbackprofil-bei-Vectoring/ta-p/2431567")

Example VDSL configuration for Lantiq based devices:

```
config dsl 'dsl'
	option annex 'b'
	option tone 'bv'
	option xfer_mode 'ptm'

config interface 'wan'
	option proto 'pppoe'
	option _orig_ifname 'ptm0'
	option _orig_bridge 'false'
	option ifname 'dsl0.7' # OpenWrt 18
	# option ifname 'ptm0.7' # LEDE 17
        option username 'H1und1/1234-567@t-online.de'
	option password 'abcdefghijklm'
	option ipv6 'auto'
```

#### 1&amp;1 VDSL DS-Lite

1and1 is migrating (new customers) towards DSlite (Dual-Stack Lite RFC6333),

1. PPPoe as above (VLAN7)

```
config interface 'wan'
        option device 'eth0.7'
        option proto 'pppoe'
        option password 'test123'
        option username '1und1/ui1234-567@t-online.de'
        option ipv6 '1'

config interface 'wan6'
        option proto 'dhcpv6'
        option reqaddress 'try'
        option reqprefix 'auto'
        option device 'pppoe-wan'
        option norelease '1'
        option iface_dslite 'wan4'
        option zone_dslite 'wan'
```

(ifnames in example for router with external modem)

### Deutsche Glasfaser

Deutsche Glasfaser locally known as **DG** and in English the **German Fiber** uses IPoE for private customers with the support of **DHCPv4** (RFC 2131) and **DHCPv6** (RFC 8415) for all new connections.

If you are an OpenWrt user means that you are using your own router (Kundeneigener Router) whose WAN interface is connected to the DG's **ONT** (Optical Network Terminal) directly.

The minimal **wan** and **wan6** configuration needed is shown below. The DG supplies a CG-NAT IPv4 address and a public IPv6 address in addition to the `/56` IPv6 prefix for further delegation.

```
config interface 'wan'
	option proto 'dhcp'
	option device 'eth1'

config interface 'wan6'
	option proto 'dhcpv6'
	option device '@wan'
	option reqaddress 'try'
	option reqprefix 'auto'
	option norelease '1' # optional
```

Note: in this example it's assumed that `eth1` is your WAN interface; the optional option `option norelease '1'` is supported by OpenWrt version **23.05.2** and above and can be used to avoid missing PD for some hours after often restarts.

### DNS:NET

- Date of Documentation: 26.07.2025
- Hardware Router: [Sinovoip BananaPi BPI-R4](/inbox/toh/sinovoip/bananapi_bpi-r4 "inbox:toh:sinovoip:bananapi_bpi-r4")
- Hardware GPON: [https://www.luleey.com/2-5g-gpon-onu-solution/?srsltid=AfmBOooxeQKVtN11jaOS316fVCS77aJnOYh8DCrm2cef6jnAOC1TSJ4m](https://www.luleey.com/2-5g-gpon-onu-solution/?srsltid=AfmBOooxeQKVtN11jaOS316fVCS77aJnOYh8DCrm2cef6jnAOC1TSJ4m "https://www.luleey.com/2-5g-gpon-onu-solution/?srsltid=AfmBOooxeQKVtN11jaOS316fVCS77aJnOYh8DCrm2cef6jnAOC1TSJ4m")

The selected GPON has the ability to modify various parameters that are normally hard-wired, such as the serial number. This eliminates the need to report hardware replacements to the ISP. The goal of this approach was to eliminate the need to report a change to the ONT (Optical Network Termination), for example, the Fritz!Box, and thus ensure a replacement is available in the event of a defect. I will also document and link the configuration and commissioning process.

#### FTTH

DNS:NET provides a documentation for their network here:

- [https://www.dns-net.de/service/technische-dokumentation](https://www.dns-net.de/service/technische-dokumentation "https://www.dns-net.de/service/technische-dokumentation")
- [https://www.dns-net.de/hubfs/Technische%20Dokumentation/Schnittstellenbeschreibung\_GPON\_v2.3.pdf](https://www.dns-net.de/hubfs/Technische%20Dokumentation/Schnittstellenbeschreibung_GPON_v2.3.pdf "https://www.dns-net.de/hubfs/Technische%20Dokumentation/Schnittstellenbeschreibung_GPON_v2.3.pdf")

/etc/config/network

```
config interface 'gpon'                                                  
        option proto 'pppoe'                                             
        option device 'eth2.37'                                          
        option username '<USERNAME>@dnsnet'                               
        option password '<PASSWORD>'                           
        option ipv6 'auto'                                               
                                                                         
config device                                                            
        option type '8021q'                                              
        option ifname 'eth2'                                             
        option vid '37'                                                  
        option name 'eth2.37'
```

/etc/config/firewall

```
config zone
        option name 'wan'
        option input 'REJECT'
        option output 'ACCEPT'
        option forward 'REJECT'
        option masq '1'
        option mtu_fix '1'
        option family 'ipv4'
        list network 'wan'
        list network 'gpon'
```

### Vodafone

#### FTTH

/etc/config/network

```
config interface 'wan'
        option device 'eth0.7'
        option proto 'pppoe'
        option username 'vodafone-ftth.komplett/***'
        option password '***'
        option ipv6 '1'

config interface 'wan6'
        option proto 'dhcpv6'
        option reqaddress 'try'
        option reqprefix 'auto'
        option device 'pppoe-wan'

config interface 'wan4'
        option proto 'dslite'
        option peeraddr '::'
        option encaplimit 'ignore'
```

/etc/config/firewall

```
config zone
        option name 'wan'
        option input 'REJECT'
        option output 'ACCEPT'
        option forward 'REJECT'
        option masq '1'
        option mtu_fix '1'
        list network 'wan'
        list network 'wan4'
        list network 'wan6'
```

### NetCologne/NetAachen

#### FTTH (GPON)

NetCologne/NetAachen provides the technical documentation for their FTTH (GPON) deployment here:

- [Schnittstellenbeschreibung](https://www.netcologne.de/privatkunden/schnittstellenbeschreibung/ "https://www.netcologne.de/privatkunden/schnittstellenbeschreibung/")
- [Schnittstellenbeschreibung\_2024.pdf](https://www.netcologne.de/cms/api/fileadmin/user_upload/privatkunden/pdf/weitere-formulare/Schnittstellenbeschreibung_2024.pdf "https://www.netcologne.de/cms/api/fileadmin/user_upload/privatkunden/pdf/weitere-formulare/Schnittstellenbeschreibung_2024.pdf")

As NetCologne only provides an IPv4 connection via DS-Lite over IPv6, the `ds-lite` package must be installed.

The following configuration assumes your **WAN** interface is `eth1`, which is connected to the **ONT** (provided free of charge by NetCologne in my case, but their website has [contradictory information](https://www.netcologne.de/privatkunden/hilfe/eigenen-router-einrichten/glasfaser/ "https://www.netcologne.de/privatkunden/hilfe/eigenen-router-einrichten/glasfaser/")) terminating the fiber connection.

```
config interface 'wan'
        option proto 'pppoe'
        option device 'eth1.10'
        option username 'nc-*******@netcologne.de'
        option password '******'
        option ipv6 'auto'

config interface 'wan6'
        option proto 'dhcpv6'
        option device '@wan'
        option reqaddress 'try'
        option reqprefix 'auto'
```

## Greece

### Nova

This ISP is little more involved to set up. Users who wish to use their own CPEs need to get ahold of:

- The PPPoE credentials
- The telephony credentials

This can either be done by formally requesting the credentials from the ISP or by acquiring them from the router that the ISP provides.

The ISP provides internet connectivity on VLAN 835 (PPPoE) and voip telephony on VLAN 837 (DHCP).

For internet access, one must create a VLAN 835 and tag CPU and WAN. Then create a PPPoE interface, bind it on the 835 VLAN device, enter the credentials and enable “Use default gateway”.

Example configuration for internet access:

```
config device
        option name 'eth0.835'
        option type '8021q'
        option ifname 'eth0'
        option vid '835'

config interface 'wan'
        option device 'eth0.835'
        option proto 'pppoe'
        option username '{pppoe_username}'
        option password '{pppoe_password}'
        option ipv6 '0'
```

For telephony, one must create a VLAN 837 and tag CPU and WAN. Then create a DHCP interface, bind it on the 837 VLAN, disable “Use default gateway” and provide the client id for dhcp option 61 (this is usually *30xxxxxxxxxx\_cid.ims.wind.gr* where *xxxxxxxxxx* is the phone number). Please note that it has to be converted to HEX (and remove any separator) in order for OpenWRT to understand it.

Example configuration for telephony:

```
config device
        option name 'eth0.837'
        option type '8021q'
        option ifname 'eth0'
        option vid '837'
        option ipv6 '0'
        
config interface 'wan_voip'
        option proto 'dhcp'
        option device 'eth0.837'
        option clientid '{30xxxxxxxxxx_cid.ims.wind.gr or 30xxxxxxxxxx_cid.byod.nova.gr or the option 61 they communicated to you you converted to hex and removing spaces}'
        option delegate '0'
        option defaultroute '0'
```

The DHCP client will fetch the ip and the proper classless routes.

**Make sure you disable Rebind protection. Whitelisting the sip service domain will not suffice.**

**Additionally for this method you have to clone the original routers MAC if using the original credentials**

SIP Configuration:

Depending on whether you have fetched the credentials from the ISP's original router or whether you have applied for a “bring your own device” configuration, the settings will differ. For the first case, the SIP client configuration should be:

- Domain: \`sip-voice.forthnet.gr\`
- Username: Your phone number (\`30xxxxxxxxxx\`)
- Password: Your voip password (as fetched from the ISP's router)
- Server: \`sip-voice.forthnet.gr\`
- Port: \`5060\`
- SIP Transport: \`UDP\`
- SIP Address: \`30xxxxxxxxxx@sip-voice.forthnet.gr\`
- Registry Server: \`sip-voice.forthnet.gr\`
- Qualify Frequency: 0 (Nova does not handle SIP Options)

**Note some UserAgents are blocked from making calls or receiving them on the non-byod configuration, notably the FreePBX one, instead you need to spoof the useragent of a router or something instead of using that.**

For the second case the following is what needs to be the client configuration

- Domain: \`byod.nova.gr\`
- Username: Your phone number (\`30xxxxxxxxxx\`)
- Password: Your voip password (from the communication)
- Server: \`byod.nova.gr\`
- Port: \`5060\`
- SIP Transport: \`UDP\`
- SIP Address: \`30xxxxxxxxxx@byod.nova.gr\`
- Registry Server: \`byod.nova.gr\`
- Audio Codec: \`PCMA\` ONLY
- Qualify Frequency: 0 (Nova does not handle SIP Options)

**Caution, the byod.nova.gr domain is only configured on the DNS servers of the telephony VLAN,**

Alternatively you can do a custom DNS record if you don't want to use the ISP DNS the IPv4 for byod.nova.gr is 10.50.131.150

### DEI/PPC

This isp is easy to setup and offers RDNS with their static IPs They use CGNAT for both static and CGNAT customers with the difference that the static customers have a 1-1 mapping over their CGNAT implementation

You will generally not experience issues with the inbound connections to the Static IP. However their CGNAT is unreliable for IPv4 Peer2Peer connections due to missing CGNAT components.

It is required you bridge their router with a request that can be scheduled during weekdays from 9am - 3pm when the NOC is in office. DMZ and other setups are broken on their router.

**They do not yet provide ONTs so there is no other option other than bridging.**

CGNAT sample Config

```
config device
        option name 'eth0.835'
        option type '8021q'
        option ifname 'eth0'
        option vid '835'

config interface 'wan'
        option device 'eth0.835'
        option proto 'dhcp'
```

Static IP sample config

```
config device
        option name 'eth0.836'
        option type '8021q'
        option ifname 'eth0'
        option vid '836'

config interface 'wan'
        option device 'eth0.836'
        option proto 'dhcp'
```

**Note: Only static IP customers have access to both CGNAT and Static VLANS. If odd problems arise with the Static Configuration it has been adviced to try the CGNATed network too**

**Note: NATHelper will rewrite the address correctly but using SNAT to your public IP will not go through their firewall, the effect is that contact headers will always be wrong.**

**Troubleshooting: If you see a address different than the usual 100.x.x.x then you probably have not setup vlans correctly and are probably getting DHCP from the semi-bricked router. Usually you see a 192.168.1.0/24 address in this case**

## India

### ACT Fibernet

- ACT Fibernet in Bangalore works with PPOE configuration.
- There is no MAC binding done by ISP (So you can easily switch routers without ISP involved).
- Their IPv4 WAN address is CGNAT'd. Which means you cannot host services at home with IPv4 public IP.
- However, they also provide IPv6 with PD. Which is not CGNAT'd. Using IPv6 you should be able host service at home by placing necessary firewall rules in OpenWrt router.
- Configuration wan config as below,

```
config interface 'wan'
        option proto 'pppoe'
        option device 'eth1'
        option username 'xxxx'
        option password 'xxxx'
        option ipv6 'auto'
```

## Ireland

### Vodafone SIRO 1G

\* igmpproxy need to be installed for TV for my setup im using separated interface for STB, you can connect your and into LAN (but then plz change configuration of igmpproxy to point to LAN instead of eth3) config files:

`/etc/config/network`

```
config interface 'loopback'
	option ifname 'lo'
	option proto 'static'
	option ipaddr '127.0.0.1'
	option netmask '255.0.0.0'

config globals 'globals'
	option ula_prefix 'fda0:8093:6a4c::/48'

config interface 'lan'
	option type 'bridge'
	option proto 'static'
	option netmask '255.255.255.0'
	option ip6assign '60'
	option ipaddr '192.168.0.1'
	option stp '1'
	option igmp_snooping '1'
	option ifname 'eth1 eth3'

config interface 'wan'
	option proto 'pppoe'
	option ifname 'eth0.10'
	option username 'VODAFONE_ROUTER_SERIAL@vfieftth.ie'
	option password 'broadband'
	option ipv6 'auto'

config interface 'wan6'
	option ifname 'eth0'
	option proto 'dhcpv6'


config interface 'iptv'
	option proto 'dhcp'
	option delegate '0'
	option broadcast '1'
	option defaultroute '0'
	option ifname 'eth0.10'

config interface 'stb'
	option proto 'static'
	option ifname 'eth2'
	option type 'bridge'
	option igmp_snooping '1'
	option ipaddr '192.168.2.1'
	option ip6assign '64'
	option netmask '255.255.255.128'
```

`/etc/config/igmpproxy`

```
config igmpproxy
	option quickleave 1
#	option verbose [0-3](none, minimal[default], more, maximum)

config phyint
	option network iptv
	option zone wan
	option direction upstream
	list altnet 0.0.0.0/0

config phyint
	option network stb
	option zone lan
	option direction downstream
```

### Pure Telecom 100Mb SIRO FTTC

```
config atm-bridge 'atm'
        option vpi '1'
        option vci '32'
        option encaps 'llc'
        option payload 'bridged'
        option nameprefix 'dsl'

config dsl 'dsl'
        option annex 'a'
        option line_mode 'vdsl'
        option ds_snr_offset '0'
        option xfer_mode 'ptm'

config interface 'wan'
        option device 'dsl0.10'
        option proto 'pppoe'
        option username 'puretelecom@puretel.ie'
        option password 'broadband1'
        option ipv6 '0'
        option service 'internet'
```

## Italy

### Aruba FTTH

This ISP in Italy is pretty easy to set up, and it is compliant to Italian law about the utilization of your own (compatible) modem/router. Also ipv6 works and ipv4. The only thig to setup is a PPPoE connection with a 835 VLAN on the WAN port. Note that user and password are not necessary for authentication and can be whatever.

With **OpenWrt 21.02** (with DSA):

```
config interface 'wan'
	option proto 'pppoe'
	option username 'aruba'
	option password 'aruba'
	option ipv6 '1'
	option device 'wan.835'

config interface 'wan6'
    option proto 'dhcpv6'
    option reqaddress 'try'
    option reqprefix 'auto'
    option ifname '@wan'
```

With **OpenWrt 19.07** (with swconfig):

```
config interface 'wan'
    option ifname 'eth0.835'
    option proto 'pppoe'
    option username 'aruba'
    option password 'aruba'
    option ipv6 '1'

config interface 'wan6'
    option proto 'dhcpv6'
    option reqaddress 'try'
    option reqprefix 'auto'
    option ifname '@wan'
```

### TIM

TIM (a.k.a. Telecom Italia) uses the following PPPoE connection settings: [https://www.tim.it/assistenza/assistenza-tecnica/guide-manuali/modem-generico#specifiche-tecniche-di-configurazione](https://www.tim.it/assistenza/assistenza-tecnica/guide-manuali/modem-generico#specifiche-tecniche-di-configurazione "https://www.tim.it/assistenza/assistenza-tecnica/guide-manuali/modem-generico#specifiche-tecniche-di-configurazione"). VLAN 835 is required on your WAN port. In the following example, the phisical name of WAN interface is 'eth0' so with VLAN 835 will be 'eth0.835', but with different device can be somewhat like 'eth1.835'.

Configuration with **OpenWrt 21.02** (with DSA):

```
config interface 'wan'
    option ifname 'eth0.835'
    option proto 'pppoe'
    option username '[replace with your phone number]'
    option password 'timadsl'
    option ipv6 'auto'
```

### Tiscali

Tiscali uses the following ADSL PPPoA connection settings: [https://assistenza.tiscali.it/internet-telefono/modem/guida/parametri-connessione](https://assistenza.tiscali.it/internet-telefono/modem/guida/parametri-connessione "https://assistenza.tiscali.it/internet-telefono/modem/guida/parametri-connessione"). In order to configure the connection and bring up the dsl port after having flashed the firmware you have to follow these steps:

1. Check if there is a configuration entry that bridges the LAN and the dsl port by accessing the router in its default IP address, then in the LuCi menu “Interfaces”, tab “atm bridges”, *delete* any entry.
2. In the tab “DSL” set Annex = Annex A G.992.1
3. in the aforementioned tab set tone = auto
4. set Encapsulation mode = ATM
5. set DSL lne mode = “ADSL”
6. leave Downstream SNR offset = 0.0db
7. leave Firmware File with no entry.

**NOTE**: there\`s no need to upload a firmware or specify its path: the DSL connection works even if you leave it blank.

Then, in the “interface” menu, if not already present, create an interface, with these specifications, beginning from the “General Settings” tab:

1. Protocol = PPPoATM
2. Bring Up on Boot = 1
3. PPPoA Encapsulaltion = VC-Mux
4. ATM device number = 0 (leave default)
5. VCI = 35
6. VPI = 8
7. PAP/CHAP user = yourISPmail
8. PAP/CHAP password = yourPassword

Then, proceeding to “Advanced Settings” tab:

1. Use Built in IPv6 Management = 0
2. Force Link = 1
3. Obtain IPv6-Adress = disabled
4. Use Default Gateway = 1
5. Use DNS advertised by Peer = 1
6. leave every other settings to default

**NOTE**: if you want, you can set the “Use DNS advertised by Peer” to disabled: you can enter the IP address of your favorite DNS provider.

Finally, you have to assign the firewall zone in the “firewall setting” tab. For security reasons you should assign it to the WAN zone.

A sample config should look like in OpenWrt version 19.07:

```
config interface 'loopback'
	option ifname 'lo'
	option proto 'static'
	option ipaddr '127.0.0.1'
	option netmask '255.0.0.0'

config globals 'globals'

config dsl 'dsl'
	option ds_snr_offset '0'
	option annex 'admt'
	option xfer_mode 'atm'
	option line_mode 'adsl'

config interface 'lan'
	option type 'bridge'
	option ifname 'eth0'
	option proto 'static'
	option netmask '255.255.255.0'
	option ipaddr '192.168.1.1'

config device 'lan_eth0_dev'
	option name 'eth0'
	option macaddr 'XX:XX:XX:XX:XX:XX'

config interface 'wan'
	option ifname 'dsl0'
	option proto 'pppoa'
	option vpi '8'
	option encaps 'vc'
	option vci '35'
	option password 'YourISPpassword'
	option username 'YourISPUsername'
	option atmdev '0'
	option ipv6 '0'
	option delegate '0'
	option peerdns '1'

config device 'wan_dsl0_dev'
	option name 'dsl0'
	option macaddr 'XX:XX:XX:XX:XX:XX'

```

**IMPORTANT**: in the aforementioned configuration there\`s a LAN bridge between two entries. This bridge has been created during the openWrt firmware installation because the target device is a Netgear DM200 modem/router with only one dsl interface and only one LAN port.

### Sky Wifi

Sky Wifi needs *map* package to work. You need to download it with a different connection or to personalize the image.

```
config interface 'wan'
        option device '(wan_if).101'
        option proto 'dhcp'

config interface 'wan6'
        option device 'eth1.101'
        option proto 'dhcpv6'
        option reqaddress 'try'
        option reqprefix 'auto'

config device
        option type '8021q'
        option ifname '(wan_if)'
        option vid '101'
        option name '(wan_if).101'
```

## Netherlands

### KPN FTTH

You can connect the WAN port of your router directly to the fiber termination box delivered by KPN using RJ-45. Internet will be delivered on VLAN 6 using PPPoE. The username/password combination is internet/internet. To get 1500 MTU (PPPoE is 1492 default due to 8 bytes overhead) you need to set the WAN port's MTU to 1508 bytes and then set the PPPoE interface to 1500 bytes. KPN is compliant with [RFC4638](https://datatracker.ietf.org/doc/html/rfc4638 "https://datatracker.ietf.org/doc/html/rfc4638").

This is an example configuration of /etc/config/network with eth1 as the WAN port:

```
config device
	option name 'eth1'
	option mtu '1508'

config device
	option type '8021q'
	option ifname 'eth1'
	option vid '6'
	option name 'eth1.6'

config interface 'wan'
	option proto 'pppoe'
	option device 'eth1.6'
	option username 'internet'
	option password 'internet'
	option mtu '1500'
	option peerdns '0'
	list dns '8.8.8.8'
	list dns '8.8.4.4'
	option ipv6 '1'
	option metric '1'

config interface 'wan6'
	option proto 'dhcpv6'
	option device 'pppoe-wan'
	option reqaddress 'try'
	option reqprefix 'auto'
	option peerdns '0'
	list dns '2001:4860:4860::8888'
	list dns '2001:4860:4860::8844'
	option metric '0'
```

### KPN: OpenWrt behind the supplied kpn Box 12 modem (Firmware Version V12.C.24.05.08)

KPN has released a firmware version for the kpn Box 12 with a completely redesigned UI. As such, the previous chapter for the old stock firmware does not apply anymore.

One of the major additions of this firmware version is actually functional IPv6 prefix delegation.

Go into your modem's settings page by going to [http://192.168.2.254](http://192.168.2.254 "http://192.168.2.254") and do the following:

01. Log into the modem using the password on the back of the modem, or with your own password if you set one.
02. Click on `Thuisnetwerk` on the sidebar.
03. Go to the `IP-adres reserveren` tab at the top.
04. Select your OpenWrt router in the `Apparaat` dropdown, or fill in your OpenWrt router's IP and MAC address manually. If your desired OpenWrt router address is already occupied by a different device, you can reserve the other devices another IP address temporarily, after which you can freely reserve the initial address for your OpenWrt router. If you run into this, make sure to restart the modem before continuing with the next steps.
05. Click `Toevoegen` to reserve the IP address. Now your OpenWrt has a predictable IPv4 address that we can use for other settings.
06. Go to the `IPv6` tab at the top.
07. Click the `IPv6 prefix delegation` dropdown box and select `Aan met DHCPv6`.
08. Click `Toepassen` to apply the change.
09. Click on `Beveiliging` on the sidebar.
10. Go to the `DMZ` tab at the top.
11. On the `IPv4` tab, click the `Apparaat` dropdown box and select your OpenWrt router, or fill in the IP address manually below.
12. Click `Opslaan` to apply the change.
13. On the `IPv6` tab, select the `IPv6-adres` input field, and type your OpenWrt's recently acquired DHCPv6 delegated prefix. If you do not have one at this moment, you may need to configure OpenWrt accordingly, which we will do in a moment. After you know your DHCPv6 delegated prefix, you can come back to this step. As an alternative, it is possible to fill in the entire prefix that you have received from KPN. The format to fill in the prefix is `aaaa:bbbb:cccc:ff00::0/56` for example. The `0/56` at the end is important. If you want to disable firewall for your entire KPN prefix, consider using a `0/48` instead (assuming you are assigned a /48 prefix).

With this configuration, the KPN modem should now allow our OpenWrt device to pass through without any annoying firewall hurdles in between.

Now that we're done with the modem, we can set up OpenWrt. Here's the important snippet from `/etc/config/network`:

```
config interface 'lan'
	option device 'br-lan'
	option proto 'static'
	option ipaddr '192.168.1.1'
	option netmask '255.255.255.0'
	option ip6assign '60'

config interface 'wan'
	option proto 'dhcp'
	option device 'eth0'
	option hostname '*'
	option peerdns '0'
	list dns '8.8.8.8'
	list dns '8.8.4.4'

config interface 'wan6'
	option device 'eth0'
	option proto 'dhcpv6'
	option reqaddress 'try'
	option reqprefix 'auto'
	option peerdns '0'
	list dns '2001:4860:4860::8888'
	list dns '2001:4860:4860::8844'
	option clientid '00'
```

I added the `clientid` option to make the delegated prefix more predictable.

Due to proper prefix delegation support in this new firmware version, our `/etc/config/dhcp` can be greatly simplified. Now it should look more like this:

```
config dhcp 'lan'
	option interface 'lan'
	option start '100'
	option limit '150'
	option leasetime '12h'
	option dhcpv4 'server'
	option ra 'server'
	option dhcpv6 'server'
	list dns '2001:4860:4860::8888'
	list dns '2001:4860:4860::8844'
```

There is no more need to relay anything anymore.

After applying these configs, you should take a look at the OpenWrt status overview page, and take note of the `Prefix Delegated` value in `IPv6 Upstream`. You should copy and paste this value in the `Beveiliging → DMZ → IPv6 → IPv6-adres` input field on the KPN modem if it appears to be different. Do note that the KPN modem does not support OpenWrt's syntax for the prefix. It must end in `::0/56` instead of `::/56`.

Now you should be done, and you can expect to have UDP, TCP, and ICMP working properly for all your appliances connected to the OpenWrt router.

### KPN: OpenWrt behind the supplied KPN Box 12 modem (legacy firmware)

If you have the OpenWrt router's WAN port connected to your [KPN Box 12](/toh/sagemcom/fast5359 "toh:sagemcom:fast5359") modem, you will notice that it's behind NAT and as such you won't be able to enjoy a proper internet experience.

Don't get sad, though! You can set up the KPN Box 12 so that OpenWrt can automatically expose all ports through the NAT and also get IPv6 addresses for all your devices, without the modem or its firewall getting in your way.

WARNING: This configuration will expose other devices you directly connect to the modem to the internet without any firewall! This won't be a problem if you connect other devices via your OpenWrt router. Especially IPv6-enabled devices would be at risk, as the following modem configuration allows any IPv6 device connected to it to expose any port to the internet. IPv4 devices will be stuck behind NAT, and all NAT ports will be reserved for the OpenWrt router.

If you use a custom DNS on your computer, consider finding out the IP address of your KPN modem, which can be done by logging into your OpenWrt router → `Status` → `Overview` and scroll down until `Network` where the `Gateway` value in `IPv4 Upstream` is the IP address of your KPN modem. You can add this IP address to your computer's `/etc/hosts` file like so:

```
192.168.2.254  mijnmodem.kpn
```

where you replace `192.168.2.254` with the actual IP address of your KPN modem.

Now you can go into your modem's settings page by going to [http://mijnmodem.kpn](http://mijnmodem.kpn "http://mijnmodem.kpn") and do the following:

01. Log into the modem.
02. If this is the first time logging into the modem, it's going to ask you to change the admin password. DO NOT AT ANY TIME click outside this dialog or cancel, as doing so will soft-brick your modem! If you do soft-brick it, either call KPN, or use a needle to push the reset switch on the device.
03. Log back into the modem using the new password.
04. Click `My Modem`.
05. Go to the `LAN IPv4` tab.
06. Scroll down and click `Add Reserved Address` in the `DHCP` section.
07. Select your OpenWrt router's MAC address in the `Device Name` column.
08. Enter a simple IP address within the DHCP range, for example `192.168.2.1`.
09. Click `Apply` at the bottom of the page.
10. Go back to the home page by clicking the kpn logo in the top left.
11. Click `Access Control`.
12. Go to the `IPv6 Pin-holing` tab.
13. Set `Name` to whatever you like, in my case `All`.
14. Set `Device` to `Other`.
15. Leave `MAC address` empty. Inserting any invalid value into this field will soft-brick the modem, so LEAVE IT EMPTY!
16. Turn on the `DMZv6` toggle.
17. Click `Add`
18. Now go to the `DMZ` tab.
19. Turn on the `Enable` toggle.
20. Select your OpenWrt router from the MAC address dropdown menu.
21. Your OpenWrt router's IP address should automatically appear in the `Local host` input field.
22. Click `Apply`.

Now that we're done with the modem, we can set up OpenWrt. Here's the important snippet from `/etc/config/network`:

```
config interface 'lan'
	option device 'br-lan'
	option proto 'static'
	option ipaddr '192.168.1.1'
	option netmask '255.255.255.0'
	option ip6assign '60'

config interface 'wan'
	option proto 'dhcp'
	option device 'eth0'
	option hostname '*'
	option peerdns '0'
	list dns '8.8.8.8'
	list dns '8.8.4.4'

config interface 'wan6'
	option device 'eth0'
	option proto 'dhcpv6'
	option reqaddress 'try'
	option reqprefix 'auto'
	option peerdns '0'
	list dns '2001:4860:4860::8888'
	list dns '2001:4860:4860::8844'
```

Note that OpenWrt can't get a prefix through Prefix Delegation, so you may disable it. It's there in the hopes that KPN someday adds Prefix Delegation support to the kpn Box 12, which would greatly simplify the configuration. Until KPN fixes this issue, we must relay DHCPv6, RA, and NDP with the following `/etc/config/dhcp` snippet:

```
config dhcp 'lan'
	option interface 'lan'
	option start '100'
	option limit '150'
	option leasetime '12h'
	option dhcpv4 'server'
	option dhcpv6 'relay'
	option ra 'relay'
	option ndp 'relay'

config dhcp 'wan'
	option interface 'wan'
	option master '1'
	option ra 'relay'
	option dhcpv6 'relay'
	option ndp 'relay'
```

The important thing to take away from this config is that we essentially set up `lan` DHCPv6, Router Advertisements, and Neighbor Discovery to be relayed, where `wan` is the master.

And now you should have a proper internet connection again, like you would expect after installing OpenWrt appliances in your network. The kpn Box 12 inserts a `:1` after the prefix that you got assigned with your subscription. Besides that quirk, everything should work.

### Many ISPs

Many DSL and Fiber ISPs use these settings. At least Telfort, Oxxio and Tweak use these. KPN, XS4ALL and Ziggo don't. Tweak [provides settings](https://www.tweak.nl/support/apparatuur-configureren.html "https://www.tweak.nl/support/apparatuur-configureren.html") for xDSL and glassfiber. They use VLAN tagging and IPoE protocol - so DHCP in OpenWrt.

#### VDSL

The network protocols are layered in this way:

1. VDSL link (Annex B, Profile 17a, Line mode G.993.2)
2. PTM (Packet Transfer Mode)
3. Ethernet with VLAN 34
4. IPTV with VLAN 4

A sample config for VDSL would look like in OpenWrt 18.06.1 r7258-5eb055306f

```
config atm-bridge 'atm'
        option encaps 'llc'
        option payload 'bridged'
        option nameprefix 'dsl'
        option vci '34'
        option vpi '0'

config interface 'wan'
        option proto 'dhcp'
        option ifname 'dsl0.34'
        # option ifname 'ptm0.34' # LEDE 17
        option type 'bridge'        
```

A sample config for VDSL would look like in OpenWrt 19.07.6, r11278-8055e38794

```
config dsl 'dsl'
	option tone 'av'
	option annex 'b'
	option xfer_mode 'ptm'
	option line_mode 'vdsl'
	option ds_snr_offset '0'

config interface 'wan'
	option ifname 'dsl0.34'
	option proto 'dhcp'
```

#### Glassfiber

A sample config for Ethernet with VLAN 34 would look like

```
config interface 'wan'
        option ifname 'wan.34'
        option proto 'dhcp'
        option hwaddr 'AA:FB:BB:D7:CC:05'

config interface 'wan6'
        option ifname 'wan.34'
        option proto 'dhcpv6'
        option hwaddr 'AA:FB:BB:D7:CC:05'
```

Please note that the MAC address has to be set to a real one, this address is present on the physical Experia box, as well as visible via its web interface on the status page.

### XS4ALL and probably KPN

XS4ALL is another ISP from KPN like Telfort. They offer DSL and FTTH connections. For DSL it is possible to use your own router, but since latest techniques use profile 35b to get 200+ Mbit speeds over a single line, it's better (for speed) to put the provided FritzBox in bridge mode and use OpenWrt as if directly on FTTH connection.

#### Internet

FTTH (Fibre) and VDSL connections result in VLANs 6, and 4. That is, connecting the ethernet cable from the fibre's NTU or from the bridged VDSL modem, to your WAN port does nothing by itself. Internet is provided over a PPPoE connection over VLAN6, username and password don't matter here, as long as they are set. Thus, to bring up your WAN device which gets your public IP addresses (XS4ALL does both IPv4 and IPv6), configure like this:

```
config interface 'wan'
    option ifname 'eth0.6'
    option proto 'pppoe'
    option username 'FB7581@xs4all.nl'
    option password '1234'
    option ipv6 'auto'
    option mtu '1508'  # only works for FTTH since FritzBox doesn't support higher MTU

config interface 'wan6'
    option proto 'dhcpv6'
    option reqaddress 'try'
    option reqprefix 'auto'
    option ifname '@wan'
```

#### Telephony

If you use telephony and use FTTH, easiest is to connect the (unused) provided FritzBox as regular client to your OpenWrt lan. You can configure the FritzBox to take internet from there and provide telephony (which is just SIP).

#### IPTV

If you use TV, in the old setup (before March 2019) you could just bridge VLAN4 to your STBs (the black receivers provided by XS4ALL): this is called bridged mode. Since March 2019, bridged mode is no longer provided and instead, routed mode has to be setup. The obvious change visible is the additions of “interactive TV” in the STBs. Routed mode, is much like described in [IPTV / UDP multicast](/docs/guide-user/network/wan/udp_multicast "docs:guide-user:network:wan:udp_multicast"). It has a small specific twist for XS4ALL though. The official documentation for this can be found [at XS4ALL's modem setup](https://www.xs4all.nl/service/diensten/internet/installeren/modem-instellen/hoe-kan-ik-een-ander-modem-dan-fritzbox-instellen.htm "https://www.xs4all.nl/service/diensten/internet/installeren/modem-instellen/hoe-kan-ik-een-ander-modem-dan-fritzbox-instellen.htm") (Dutch).

For this to work, you need to install igmpproxy. For clarity, we use 3 different zones: wan, iptv and stbitv.

- wan: the ordinary internet connection, used for “interactive” features (e.g. YouTube)
- iptv: VLAN4-based connection, mostly used for multicast based live-streams, and STB software, some 10.200.x.x/22
- stbitv: the (client) network with the STBs in them, in this example 10.3.0.0/24

First, configure an interface, DHCP client for iptv, the VLAN 4 interface. Important, it needs to set Vendor Class Identifier to IPTV\_RG, and ignore any default gateway or dns servers advertised. The DNS is bogus (per the docs), the default route is what we don't want to use, because we want to use our real internet connection. In the DHCP reply is an additional route, you don't see this in luci, but it's correctly added to your routing table, and it basically includes all the traffic that needs to go over VLAN 4. This is basically why we don't need the default route.

```
config interface 'iptv'
    option type 'bridge'
    option ifname 'eth0.4'
    option proto 'dhcp'
    option defaultroute '0'
    option peerdns '0'
    option vendorid 'IPTV_RG'
```

Also create a firewall zone for this interface, that sets masquerading (like wan, we need to NAT some traffic over this interface):

```
config zone
    option name 'iptv'
    option input 'ACCEPT'
    option output 'ACCEPT'
    option network 'iptv'
    option masq '1'
    option mtu_fix '1'
    option forward 'REJECT'
```

Next, configure a new interface for the STBs. I isolated them on their own VLAN 7, but I think you could also plug them into an existing client network. Since there will be multicast traffic over this, you do want to separate the traffic using igmp snooping. Ensure you enable this, and if you use switches inbetween that they also enable this, else you'll flood your entire network. This is particularly bad if you have wlans in your network. The following is just what I used for this description.

```
config interface 'stbitv'
    option type 'bridge'
    option proto 'static'
    option ifname 'eth0.7'
    option ipaddr '10.3.0.1'
    option netmask '255.255.255.0'
    option igmp_snooping '1'
```

The STBs don't need any special DHCP tricks, so you just need to hand out IPs in the normal way. Only IPv4 is supported. Create firewall zone for this network, and “glue” that zone together with the iptv and wan zones, such that traffic can go both ways:

```
config zone
    option input 'ACCEPT'
    option forward 'REJECT'
    option output 'ACCEPT'
    option name 'stbitv'
    option network 'stbitv'

config forwarding
    option dest 'wan'
    option src 'stbitv'

config forwarding
    option dest 'iptv'
    option src 'stbitv'
```

Now, the last remaining bit needs to be done, which is forwarding the multicast packets that the STBs request. Since the OpenWrt router now is the terminating node as seen from the XS4ALL network, any multicast traffic arriving at the router, needs to be forwarded to the STB in the network that requested it. This is done by igmpproxy. For the proxy, upstream is the XS4ALL network, downstream the STBs in the client network. Quickleave feature is necessary to quickly terminate unnecessary streams (happening when switching between channels, “zapping”). As such, the following configuration is sufficient:

```
config igmpproxy
    option quickleave 1

config phyint
    option network iptv
    option zone iptv
    option direction upstream
    list altnet 0.0.0.0/0

config phyint
    option network stbitv
    option zone stbitv
    option direction downstream
```

Final remaining thing is to enable and start igmpproxy using `/etc/init.d/igmpproxy enable` and `/etc/init.d/igmpproxy start`.

Once you applied all this, ensure you got a 10.200.x.y IP address on the iptv interface. Check with `netstat -rn` that there is a route for destination 213.75.112.0 (could be slightly different) added with gateway your 10.200.x.1 IP address. Interface should be `br-iptv` if you followed above example. If that seems ok, and igmpproxy is running, shutdown your STBs and restart them. They should come up quite normal and settings/system should now report “routed mode”. If you get any errors reported by the devices, check the multicast traffic gets forwarded (it attempts this while STB boots) using tcpdump or something. Also check if regular internet works correctly from the STB client network.

### KPN FTTH via LuCi

1. open Network → Interfaces
2. edit your WAN device
3. change Protocol to PPPoE then click on the button Switch protocol
4. open the Device combo box and type 'eth0.6'
5. enter PPP/CHAP username '98-42-xx-xx-xx-xx@internet' (use your KPN router MAC address), PPP/CHAP password 'ppp'
6. hit Save
7. in the Devices tab change the MAC address of eth0.6 to match your KPN router MAC address (this might be optional)
8. hit Save&amp;Apply
9. if the WAN interface is in error state then reboot the modem

The WAN MTU will be 1492, don't try to change it, no other values work. A WAN\_6 virtual dynamic interface will appear upon successful connection; you can delete any other WAN device and reset any other unused eth0 virtual device.

### Ziggo

First put the modem in bridge mode (disabled routing options) via [this website](https://www.ziggo.nl/klantenservice/internet-wifi/bridge-modus/stappenplan-bridge-modus "https://www.ziggo.nl/klantenservice/internet-wifi/bridge-modus/stappenplan-bridge-modus"). Then use the following network config:

```
config interface 'wan'
	option proto 'dhcp'
	option device 'eth1'
	option hostname '*'
	option peerdns '0'
	list dns '8.8.8.8'
	list dns '8.8.4.4'

config interface 'wan6'
	option proto 'dhcpv6'
	option device 'eth1'
	option reqaddress 'try'
	option reqprefix 'auto'
	option peerdns '0'
	list dns '2001:4860:4860::8888'
	list dns '2001:4860:4860::8844'
```

Remove the 'peerdns' and 'list dns' if you want to use Ziggo's DNS servers. These servers, however, do impose censorship on certain domains.

## New Zealand

### Slingshot Fibre

#### DSA migrated devices

```
config interface 'wan'
        option proto 'dhcp'
        option device 'wan.10'
        option hostname '*'

config interface 'wan6'
        option proto 'dhcpv6'
        option device 'wan.10'
        option reqaddress 'try'
        option reqprefix 'auto'

config device
        option type '8021q'
        option ifname 'wan'
        option vid '10'
        option name 'wan.10'
```

#### Swconfig devices

```
config interface 'wan'
        option proto 'dhcp'
        option hostname '*'
        option device 'eth0.10'

config interface 'wan6'
        option proto 'dhcpv6'
        option reqaddress 'try'
        option reqprefix 'auto'
        option device 'eth0.10'

config device
        option name 'eth0.10'
        option type '8021q'
        option ifname 'eth0'
        option vid '10'
        option ipv6 '0'
```

### Simply Broadband

The Slingshot Fibre config (above) should work here too.

## Portugal

### Altice (MEO/PT Empresas)

#### GlobalConnect Pack

This enterprise VoIP and Internet services package includes a Thomson/Technicolor gateway which can be configured (by the tecnician only) in bridge mode, at installation time. In this configuration, the connection presents itself untagged at the gateway's switch port 4. The Internet service is somewhat unusual, in the sense that it requires IP aliasing (it allows the provider to spare one public IP address per connection). The addressing is static, and the configuration provided is (as an example) something along these lines:

- Local WAN IP: 100.64.194.2
- Remote WAN IP: 100.64.194.1
- Internet IP: 62.10.20.30/32

Both the Local and Remote WAN IP addresses belong to a /30 subnet. Inbound traffic arrives at the interface with the Internet IP address as the destination. To configure this connection on an OpenWrt device (let's assume interface eth1), on `/etc/config/network`, we need:

```
config interface 'wan'
	option ifname 'eth1'
	option proto 'static'
	list ipaddr '62.10.20.30/32'
	list ipaddr '100.64.194.2/30'
	option gateway '100.64.194.1'
```

Now, since the addressing is static, we can do source NAT instead of masquerading. To do so, we configure /etc/config/firewall as follows:

```
config nat
	option name 'MEO SNAT'
	option device 'eth1'
	option snat_ip '62.10.20.30'
	option src 'wan'
	option target 'SNAT'
```

#### Residential Fiber (FTTH) service

These settings are over a DSA switch and then over swconfig. You just need to, set VLAN 12 over WAN port and then configure the VLAN in the wan interface with DHCP and DHCPv6. No need to clone MAC addresses.

#### DSA implementation:

Just set a VLAN 12 device over the wan port and then set the device for wan interface with DHCP and DHCPv6.

```
config device
	option type '8021q'
	option ifname 'wan'
	option vid '12'
	option name 'wan.12'

config interface 'wan'
        option device 'wan.12'
        option proto 'dhcp'

config interface 'wan6'
        option device 'wan.12'
        option proto 'dhcpv6'
        option reqaddress 'try'
        option reqprefix 'auto'
```

#### Android and non-Andriod TV Boxes:

\# opkg install igmpproxy

\# nano /etc/config/igmpproxy

```
config igmpproxy
        option quickleave 1

config phyint
        option network wan
        option zone wan
        option direction upstream
        list altnet 0.0.0.0/0

config phyint
        option network lan
        option zone lan
        option direction downstream
```

Reboot.

## Slovakia

### Orange Slovensko

[Orange Slovensko](https://www.orange.sk/ "https://www.orange.sk/") (the owner is France-based multinational telecommunications company [Orange S.A.](https://www.orange.com/ "https://www.orange.com/")) offers FTTH service for their customers through the end CPE device.

#### FTTH (Fiber)

Orange Slovensko uses the same IPv6 /64 prefix delegation method as AT&amp;T does.

At the present moment (August 2022) there is no known way to get a /60 or /62 IPv6 prefix delegated from the LAN port of the operator's CPE device. It is only possible to send a multiple PD requests, and to get a pool of multiple /64 blocks to have them assigned into different LAN interfaces on the downstream device. So, it is possible to use these obtained /64 subnets within your OpenWrt configuration and downstream client subnets or VLANs.

Initial discussion and working OpenWrt configuration with the Orange Slovensko CPE device can be found in this post: [Link to owrt forum](https://forum.openwrt.org/t/ipv6-pd-60-for-downstream-openwrt-router-after-orange-slovensko-fiber/131707/8?u=alexq "https://forum.openwrt.org/t/ipv6-pd-60-for-downstream-openwrt-router-after-orange-slovensko-fiber/131707/8?u=alexq").

Сonfiguration details are similar to the [AT&amp;T ISP configuration](/docs/guide-user/network/wan/isp-configurations#fiber "docs:guide-user:network:wan:isp-configurations"): all the 'magic' will be achieved by the `kmod-macvlan` that allows to create multiple *wan6* virtual interfaces (hence to request and obtain multiple IPv6 /64 blocks), and to assign these virtual *wan6* interfaces into appropriate DHCPv6 clients via `ip6class` and `ip6assign 64` settings.

## Portugal &amp; Spain

### DIGI

DIGI uses PPPoE for FTTH connections, just need to call to their support number and ask for the authentication data. They offer optionaly VoIP but at the date they don't provide a way to configure, you must use the provided router if you want to have VoIP. At least in Portugal, the network supports RFC4638, giving opportunity to use full WAN MTU 1500 bytes, over PPPoE devices (MTU 1508 bytes).

#### FTTH (Fiber)

These settings are over a DSA switch and then over swconfig. You just need to, set VLAN 20 over WAN port and then configure the VLAN in the wan interface with PPPoE and the authentication data provided by technical support. No need to clone MAC address.

##### DSA:

Just set a VLAN 20 device over the wan port and then set the device for wan interface with the PPPoE authentication data.

```
config device
	option type '8021q'
	option ifname 'wan'
	option vid '20'
	option name 'wan.20'

config interface 'wan'
	option device 'wan.20'
	option proto 'pppoe'
	option username '*********@digi'
	option password '********'
	option ipv6 'auto'
```

With ipv6 auto a virtual interface wan\_6 is spawned. If you want to rename it to wan6 or configure specific settings there is a way but out of scope in this page so you can refer to [Native IPv6 connection](/docs/guide-user/network/ipv6/configuration#native_ipv6_connection "docs:guide-user:network:ipv6:configuration").

##### swconfig:

You must check the switch name and also the eth# you have for the wan port, in this example switch0 and eth0:

```
config interface 'wan'
	option device 'eth0.20'
	option proto 'pppoe'
	option username '*********@digi'
	option password '********'
	option ipv6 'auto'

config switch_vlan
	option device 'switch0'
	option vlan '3'
	option ports '1t 6t'
	option vid '20'
```

With ipv6 auto a virtual interface wan\_6 is spawned. If you want to rename it to wan6 or configure specific settings there is a way but out of scope in this page so you can refer to [Native IPv6 connection](/docs/guide-user/network/ipv6/configuration#native_ipv6_connection "docs:guide-user:network:ipv6:configuration").

### Vodafone Spain

WIP: Vodafone doesn't provide PPPoE data, you must, capture it by factory resetting the router, accessing it with generic auth data over internet, configuring port mirroring for the ppp interface to lan1 port and then with wireshark or the tool you want get the autoconfiguration data when you plug the ont rj45 or fiber cable to the router. This can be done for their non-integrated and integrated ont actual routers.

## Turkey

### Turknet

[Turknet](https://turk.net/destek/nasil-yaparim/internet-baglantimla-ilgili-sorunlari-nasil-cozebilirim/modemimi-nasil-kurarim/adsl-ve-vdsl-modem-kurulum-degerleri.html "https://turk.net/destek/nasil-yaparim/internet-baglantimla-ilgili-sorunlari-nasil-cozebilirim/modemimi-nasil-kurarim/adsl-ve-vdsl-modem-kurulum-degerleri.html") uses PPPoE for both ADSL and VDSL connections.

#### VDSL

These settings based on this post [Link to owrt forum](https://forum.openwrt.org/t/isp-configuration/72041 "https://forum.openwrt.org/t/isp-configuration/72041")

```
config dsl 'dsl'
	option annex 'b'
	option xfer_mode 'ptm'
	option line_mode 'vdsl'

config interface 'wan'
	option proto 'pppoe'
	option username '***************@turk.net'
	option password '****'
	option ifname 'dsl0.35'  # VLAN ID: 35
```

#### ADSL

```
config dsl 'dsl'
	option annex 'a'
	option xfer_mode 'atm'
	option line_mode 'adsl'

config atm-bridge 'atm'
	option encaps 'llc'
	option payload 'bridged'
	option vci '35'
	option vpi '8'

config interface 'wan'
	option proto 'pppoe'
	option username '***************@turk.net'
	option password '****'
	option ifname 'dsl0' 
```

### Turk Telekom

Turk Telekom (a major ISP in Turkey, also known with the name TTNET) provides FTTH and FTTB services through PPPoE with VLAN tagging. You can ask customer support for your PPPoE username and password.

VLAN tagging is usually as follows:

- VoIP: VLAN 46
- Internet: PPPoE over VLAN 35
- IPTV: VLAN 55 for [tivibu](https://www.tivibu.com.tr "https://www.tivibu.com.tr")

A sample config should look like on OpenWrt 21.02 (with DSA):

```
config interface 'wan'
    option device 'wan.35'
    option proto 'pppoe'
    option username 'xxxxxxx'
    option password 'xxxxxxx'
    option ipv6 'auto'

config device
    option name 'wan.35'
    option type '8021q'
    option ifname 'wan'
    option vid '35'
```

### Turkcell Superonline

Turkcell Superonline provides FTTH and FTTB services through PPPoE with VLAN tagging. In addition, you have to spoof the WAN MAC address of the stock router.

VLAN tagging is usually as follows:

- Internet: PPPoE (They only allow registered MAC addresses to authenticate with PPPoE. So you need to clone the WAN MAC address of the stock router)
- IPTV: VLAN 103 (Priority 4) for [TV+](https://tvplus.com.tr "https://tvplus.com.tr")

A basic WAN config should look like on OpenWrt 21.02 and up w/ DSA:

```
config interface 'wan'
	option device 'wan'
	option proto 'pppoe'
	option username 'xxxxxxxxxxxx@fiber'
	option password 'xxxxxxx'
	option ipv6 'auto'
	option peerdns '0'
	list dns '8.8.8.8'
	list dns '8.8.4.4'

config device
	option name 'wan'
	option macaddr 'XX:XX:XX:XX:XX:XX'
```

**Note:** Turkcell Superonline does not share PPPoE credentials with you. So you have to capture them yourself from the stock router first.

### Turksat Kablonet

Kablonet uses DHCP for Docsis and PPPoE for FTTH services.

Basic WAN configs should look like:

#### DOCSIS

```
config interface 'wan'
	option device 'wan'
	option proto 'dhcp'
	option ipv6 'auto'
	option peerdns '0'
	option dns '1.1.1.1'
	option dns '1.0.0.1'
```

#### FTTH

```
config interface 'wan'
	option device 'wan'
	option proto 'pppoe'
	option username 'xxxxxxxx@kablofiber'
	option password 'xxxxxxxx'
	option ipv6 'auto'
	option peerdns '0'
	option dns '1.1.1.1'
	option dns '1.0.0.1'
```

**Note(FTTH):** If you are using the stock modem that was given make sure it's connected to your openwrt router on LAN1.

**Note2(FTTH):** PPPoE credentials can be acquired from [TurksatKablo Customer Web Interface](https://online.turksatkablo.com.tr/ "https://online.turksatkablo.com.tr/") or by calling them.

## United Kingdom

The information below is reproduced from the '1-OpenWrt/LEDE Installation Guide for the BT Home Hub 5A', which can be downloaded from: [Dropbox](https://www.dropbox.com/sh/c8cqmpc6cacs5n8/AAA2f8htk1uMitBckDW8Jq88a?dl=0 "https://www.dropbox.com/sh/c8cqmpc6cacs5n8/AAA2f8htk1uMitBckDW8Jq88a?dl=0")

### ADSL

- ADSL LINK
- Annex A, Tone A
- ATM
  
  - VPI (Virtual Path Identifier): 0
  - VCI (Virtual Channel Identifier): 38

Configuration examples for LEDE 17 and OpenWrt 18.

Virtually all ISPs in the UK use PPPoA protocol.

```
config dsl 'dsl'
    option annex 'a'
    option tone 'a'
    option xfer_mode 'atm'
    option line_mode 'adsl'

config interface 'wan'
    option proto 'pppoa'
    option username 'your username'
    option password 'your password'
    # option username 'bthomehub@btinternet.com' # BT ADSL
    # option password ' ' # Apparently requires any non-empty password such as a space character or 'BT'
    # option username 'install@o2broadband.co.uk' # Sky and NOW ADSL on ex-o2 enabled exchanges.
    # option password ''
    option vpi '0'
    option vci '38'
    option encaps 'vc'
    option ipv6 'auto' 
```

Ensure that ATM Bridge section has been deleted, otherwise PPPoA will not connect to broadband service. It can be deleted using LuCI.

```
config atm-bridge 'atm' # Remove entire section for PPPoA
```

BT group also supports PPPoE protocol.

```
config dsl 'dsl'
    option annex 'a'
    option tone 'a'
    option xfer_mode 'atm'
    option line_mode 'adsl'

config atm-bridge 'atm'
    option encaps 'llc'
    option payload 'bridged'
    option vci '38'
    option vpi '0'

config interface 'wan'
    option ifname 'dsl0'
    # option ifname 'nas0' # for LEDE 17.01
    option proto 'pppoe'
    option username 'your username'
    option password 'your password'
    # option username 'bthomehub@btinternet.com' # BT ADSL
    # option password ' ' # Apparently requires any non-empty password such as a space character or 'BT'
```

### VDSL

The network protocols are layered in this way:

- VDSL link (17a profile, G.993.5)
- PTM (Packet Transfer Mode)
- Annex B, Tone A
- VLAN 101 (GEA lines use VLAN 2 for voice)

[Aquiss](https://support.aquiss.net/en/knowledgebase/article/generic-fttc-broadband-setup-and-router-settings "https://support.aquiss.net/en/knowledgebase/article/generic-fttc-broadband-setup-and-router-settings") uses the PPPoE protocol with authentication required.

IPv6 is supported but disabled by default. Once a line goes active, you will need to enable IPv6 within the Aquiss ebilling area and wait for a prefix to be assigned.

```
config dsl 'dsl'
    option annex 'b'
    option tone 'a'

config interface 'wan'
    option ifname 'dsl0.101'
    # option ifname 'ptm0.101' # for LEDE 17.01
    option proto 'pppoe'
    option ipv6 '1' # Aquiss has IPv6 but it needs to be enabled on your line first. Replace '0' to disable IPv6
    option mtu '1458'
    option username 'abb-username@aquiss.com'
    option password 'XXXXXXX' # Provided by email or avaiable in Aquiss ebilling area (Circuit information)
```

[BT Broadband](https://www.bt.com/broadband/fibre "https://www.bt.com/broadband/fibre") uses PPPoE protocol.

```
config dsl 'dsl'
    option annex 'b'
    option tone 'a'

config interface 'wan'
    option ifname 'dsl0.101'
    # option ifname 'ptm0.101' # for LEDE 17.01
    option proto 'pppoe'
    option ipv6 '1' # BT Broadband has IPv6. Replace '0' to disable IPv6
    option mtu '1500'
    option username 'bthomehub@btinternet.com'
    option password ' ' # Apparently requires any non-empty password such as a space character or 'BT'.
```

For 22.03.X/23.X builds.

```
config atm-bridge 'atm'
	option vpi '0'
	option vci '38'
	option encaps 'vc'
	option payload 'bridged'
	option nameprefix 'dsl'

config dsl 'dsl'
	option annex 'b'
        option tone 'a'
	option ds_snr_offset '0'
	option xfer_mode 'ptm'
	option line_mode 'vdsl'

config device
	option name 'dsl0.101'
	option type '8021q'
	option ifname 'dsl0'
	option vid '101'

config interface 'wan'
	option device 'dsl0.101'
	option proto 'pppoe'
	option username 'bthomehub@btbroadband.com'
        option password 'BT' # Apparently requires any non-empty password such as a space character or 'BT'.
	option ipv6 '1' # BT Broadband has IPv6. Replace '0' to disable IPv6
        option multicast '1' # For BT TV, Remember to install imgproxy.
        
config interface 'wan6'
        option proto 'dhcpv6'
        option reqaddress 'try'
        option reqprefix 'auto'
        option ifname 'dsl0.101'
```

[EE](https://ee.co.uk/help/help-new/broadband-and-landline/home-broadband/how-do-i-use-my-own-router-for-home-broadband "https://ee.co.uk/help/help-new/broadband-and-landline/home-broadband/how-do-i-use-my-own-router-for-home-broadband") uses PPPoE protocol.

```
config dsl 'dsl'
    option annex 'b'
    option tone 'a'

config interface 'wan'
    option ifname 'dsl0.101'
    # option ifname 'ptm0.101' # for LEDE 17.01
    option proto 'pppoe'
    option ipv6 '0' # EE has no IPv6. Replace '1' to enable IPv6
    option username '56@fs' ' # see https://ee.co.uk/help/help-new/broadband-and-landline/home-broadband/what-are-my-home-broadband-internet-settings
    option password 'XXXXX' # password that came with your EE router
```

OneStream (as of 24.10.X builds):

```
config dsl 'dsl'
    option annex 'a'
    option tone 'a'
    option xfer_mode 'ptm'
    option line_mode 'vdsl'

config interface 'wan'
    option device 'dsl0.101'
    option proto 'pppoe'
    option username 'XXXX'
    option password 'XXXX'
    option ipv6 '0'
```

[Shell Energy \*fibre* (G.993.2=VDSL2)](http://web.archive.org/web/20210505225223/https://help.shellenergy.co.uk/hc/en-us/articles/360001044438-What-if-I-want-to-use-my-own-router- "http://web.archive.org/web/20210505225223/https://help.shellenergy.co.uk/hc/en-us/articles/360001044438-What-if-I-want-to-use-my-own-router-") uses the PPPoE protocol:

```
config interface 'wan'
    option ifname 'dsl0.101'
    # option ifname 'ptm0.101' # for LEDE 17.01
    option proto 'pppoe'
    option username '<username>' # this is usually "<yourTel>@first-utility.com"
    option password 'XXXXX' # password that came with your shell energy router
```

(Shell Energy \*copper* (G.992.5=ADSL2+) uses PPPoA. For this, see the generic United Kingdom ADSL section above.)

Sky and NOW Broadband use DHCP aka. IPoE. Refer to following thread for additional instructions:

[SkyUser - obsolete instructions](http://www.skyuser.co.uk/forum/sky-broadband-fibre-help/50483-generic-open-wrt-sky-fibre-mer-guide.html "http://www.skyuser.co.uk/forum/sky-broadband-fibre-help/50483-generic-open-wrt-sky-fibre-mer-guide.html")

[OpenWrt forum - newer instructions](https://forum.openwrt.org/t/bt-homehub-5a-with-nowtv-fibre/50137/2 "https://forum.openwrt.org/t/bt-homehub-5a-with-nowtv-fibre/50137/2") - see example config below [Additional info for NOW Broadband](https://forum.openwrt.org/t/nowtv-openwrt/74624/5 "https://forum.openwrt.org/t/nowtv-openwrt/74624/5")

```
config dsl 'dsl'
        option annex 'b'
        option tone 'a'
        option xfer_mode 'ptm'
        option line_mode 'vdsl'


config interface 'wan'
        option ifname 'dsl0.101'
        # option ifname 'ptm0.101' # for LEDE 17.01
        option proto 'dhcp'
        option clientid 'anythingYouLike'   # Update: it may have to be in hexadecimal and/or of a minimum length
#        option macaddr 'AA:BB:CC:DD:EE:FF'  # optional, replace with your Sky/NOW hub's WAN mac if included

config device 'wan_dev'
        option name 'dsl0'

config interface 'wan6'
        option proto 'dhcpv6'
        option reqaddress 'try'
        option reqprefix 'auto'
        option ifname 'dsl0.101'
        option delegate '1'
```

[TalkTalk](https://community.talktalk.co.uk/t5/Articles/Set-up-a-non-TalkTalk-router/ta-p/2205383 "https://community.talktalk.co.uk/t5/Articles/Set-up-a-non-TalkTalk-router/ta-p/2205383") uses DHCP protocol. They use automated network authentication so there is no need for a username and password - IGMP V2/V3 proxy needs to be installed for TalkTalk TV for my setup im using separated LAN interface for this.

```
config dsl 'dsl'
    option annex 'b'
    option tone 'a'

config interface 'wan'
    option ifname 'dsl0.101'
    # option ifname 'ptm0.101' # for LEDE 17.01
    option proto 'dhcp'
    option mtu '1500'
    option ipv6 '0' # TalkTalk has no IPv6 support. Replace '0' to '1' to enable IPv6 for feature
```

[Vodafone UK](https://forum.vodafone.co.uk/t5/Other-broadband-queries/How-to-Set-up-a-third-party-router-with-vodafone-2019/m-p/2621214 "https://forum.vodafone.co.uk/t5/Other-broadband-queries/How-to-Set-up-a-third-party-router-with-vodafone-2019/m-p/2621214") uses PPPoE protocol with authentication needed.

```
config dsl 'dsl'
    option annex 'b'
    option tone 'a'

config interface 'wan'
    option ifname 'dsl0.101'
    # option ifname 'ptm0.101' # for LEDE 17.01
    option proto 'pppoe'
    option ipv6 '0' # Vodafone UK has no IPv6. Replace '1' to enable IPv6
    option username 'XXX@broadband.vodafone.co.uk'
    #option username 'XXXX@businessbroadband.vodafone.co.uk # for business customers
    option password ' XXXXXX' # Need password for auth
```

[Zen Internet](https://www.zen.co.uk/broadband "https://www.zen.co.uk/broadband") uses PPPoE protocol with auth (Username and Password)

```
config dsl 'dsl'
    option annex 'b'
    option tone 'a'

config interface 'wan'
    option ifname 'dsl0.101'
    # option ifname 'ptm0.101' # for LEDE 17.01
    option proto 'pppoe'
    option ipv6 '1' # Zen has IPv6. Replace '0' to disable IPv6
    option mtu '1500'
    option username 'zenXXXXXX@zen'
    option password ' XXXXXX' # Need password for auth, can get this info from Zen Customer Portal or Mobile App.
```

### Fibre Optic

#### Openreach Full Fibre (FTTP)

Openreach (a subsidiary owned by BT plc) provides fibre optic broadband to the home, [with various ISPs reselling Openreach services to end users](https://www.openreach.com/fibre-broadband/fttp-providers "https://www.openreach.com/fibre-broadband/fttp-providers"). Any provider using the Openreach FTTP network requires an ONT (Optical Network Terminal) device fitted by Openreach to provide the fibre connection to the premises. This acts as the modem that will then connect to some form of CPE or router at the customer end via ethernet.

##### Aquiss

Aquiss uses PPPoE for static IPv4. For static IPv6 /56 subnet it is DHCPv6 over PPPoE. A standard PPPoE network interface with your Aquiss abb-xxxxxx@aquiss.com and password should get you connected with your IPv4 address. IPv6 (if enabled) will be automatically configured by a virtual interface with Obtain IPv6 address set to Automatic. You can alternatively set this to manual and create your own alias interface if required.

IPv6 must be enabled on the broadband line within the Aquiss ebilling system with a prefix delegated before configuring IPv6.

= Aquiss OpenReach configuration =

Updates to /etc/config/network should include the following:

```
# on the eth1 interface that is wired to ONT, we want to enable baby jumbo frame
# this will allow pppoe client to set MTU of 1500 matching ethernet MTU on lan interface
config device
        option name 'eth1'
        option mtu '1508'

# IPv4 is provided via PPPoE
config interface 'wan'
	option device	'eth1'
	option proto	'pppoe'
	option mtu	'1500'
	option username 'abb-xxxxxxxxxx@aquiss.com'
	option password 'password'
	option ipv6	'1'
	option peerdns	'0'
	list dns        '8.8.8.8'
	list dns        '8.8.4.4'

# IPv6 is provided via DHCPv6
config interface 'wan6'
        option device   '@wan'
        option proto    'dhcpv6'
        option peerdns  '0'
        list dns        '2001:4860:4860::8888'
        list dns        '2001:4860:4860::8844'
```

If you do not need custom IPv6 configuration, just delete wan6 section completely, but also set wan ipv6 option to auto.

##### Sky Broadband

Sky used DHCP with “clientid authentication”, but any username/password will work. Working configuration, assuming ONT is connected to eth1:

```
config interface 'wan'
	option device	'eth1'
	option proto	'dhcp'
	option clientid	'613162326333653466353036406e6f7774767c6131623263336534'
	option peerdns	'0'
	list dns        '8.8.8.8'
	list dns        '8.8.4.4'

config interface 'wan6'
	option device	'eth1'
	option proto	'dhcpv6'
	option peerdns	'0'
	list dns	'2001:4860:4860::8888'
	list dns        '2001:4860:4860::8844'
```

#### Alternative networks

Outside of Openreach other connection providers in the UK are referred to as alternative networks (alt-nets), these include:

- City Fibre
- Community Fibre
- HyperOptic
- Giganet
- Virgin Media (Uses both HFC and FTTP in some areas with DOCSIS)
- Gigaclear

##### City Fibre

City Fibre provide fibre networks to business and residential customers, with selected ISPs reselling the connection to end users. These include ISPs such as Vodafone, Giganet, TalkTalk and Zen Internet.

VLAN: all traffic on the CityFibre network must be tagged as VLAN 911 or traffic will not flow.

##### Giganet

Giganet are a CityFibre and BT Openreach fibre reseller. They provide IPv4 and IPv6 connectivity to business and residential customers. They provide a static IPv4 address and a static IPv6 router address, with a /48 prefix for the client's network.

DHCPv6 is used to IPv6 prefix delegation, but the IPv6 prefix must be released by the router before the prefix will be issued again to either the same router or to another router. If this doesn't happen, an error of NoPrefixAvail during DHCPv6 negotiation, and odhcpd will complain that there is a local route, but no prefix, so it doesn't issue IPv6 addresses to LAN clients.

##### Gigabit Networks

Gigabit networks provide residential broadband through Cityfibre. They operate CGNat and operate a DHCP based service. Their requirements web pag is here: [https://support.gigabitnetworks.co.uk/portal/en/kb/articles/can-i-use-my-own-router-with-your-service](https://support.gigabitnetworks.co.uk/portal/en/kb/articles/can-i-use-my-own-router-with-your-service "https://support.gigabitnetworks.co.uk/portal/en/kb/articles/can-i-use-my-own-router-with-your-service") You need to contact their order desk to confirm the required VLAN. They do filter based on the MAC address and you need to contact their support team to clear this binding. The engineer called this “Clear the DHCP Binding process for the ONT interface.”

These are a set of working steps with a Belkin RT3200.

- WAN VLAN tagging on the appropriate VLAN
- Disabled IPv6
- No hostname required.
- Contact their support and ask for “Clear the DHCP Binding process for the ONT interface.”

##### Community Fibre

The Adtran ONT connects to any DHCP enabled router. Recommended to spoof the MAC of your router so it follows the provider one.

##### GigaClear

GigaClear use DHCP4, MAC spoofing not required. For IPv6, set the DUID (named “Client ID to send when requesting DHCP” in the wan6 interface settings) to that of the provider-router and request a /48, otherwise their DHCP6 server doesn't seem to respond (even with these settings, it took &gt;60 secs to get an IP).

```
config interface 'wan'
        option device 'eth1'
        option proto 'dhcp'
        option force_link '0'
        option classlessroute '0'
        option metric '10'
        option ipv6 '1'

config interface 'wan6'
        option proto 'dhcpv6'
        option device '@wan'
        option disabled '0'
        option peerdns '0'
        option reqaddress 'try'
        option clientid '0002030...' # DUID of the ISP-provided router (from "Connectivity" > "Internet Settings" > "IPv6")
        option reqprefix '48'
```

##### InternetTY

InternetTY use PPPoE. Contact support for PAP/CHAP credentials or copy from provided router - password is same as default WiFi password. IPv6 is unsupported (unconfirmed).

## United States

### AT&amp;T

[AT&amp;T Internet](https://www.att.com/internet/ "https://www.att.com/internet/") no longer offers DSL connections, but is offering FTTH service in certain markets.

#### Fiber

These settings based on this post [Link to owrt forum](https://forum.openwrt.org/t/configure-dhcpv6c-on-wan-for-multiple-pd-requests-for-at-t-fiber/99371/39?u=_failsafe "https://forum.openwrt.org/t/configure-dhcpv6c-on-wan-for-multiple-pd-requests-for-at-t-fiber/99371/39?u=_failsafe")

AT&amp;T Fiber connectivity with OpenWrt is most easily achieved via setting the AT&amp;T gateway device into “IP passthrough” mode. The IP passthrough mode type should be set as *DHCPS-fixed* with the passthrough fixed MAC address set to the MAC address of the WAN interface to which your OpenWrt device is connected to the AT&amp;T gateway device. In this configuration you will not be operating in a double-NAT mode as you would if you use the *DHCPS-dynamic* type of passthrough.

Additionally, if you intend for the AT&amp;T gateway device to act as transparently as possible while allowing your OpenWrt device to perform all typical firewall, NAT, and routing functions, you will also want to disable packet filters and turn off all firewall advanced features within your AT&amp;T gateway device's Firewall settings sections. This may vary by AT&amp;T gateway model, so please refer to available guides online as to how to disable those features for your particular AT&amp;T gateway device.

By default, AT&amp;T enables IPv6 connectivity, but AT&amp;T's IPv6 handling is suboptimal in that while it is DHCPv6-PD, the IPv6 subnet they provide to each customer is a /60 instead of a more desireable /56 (or even /48). Further, the AT&amp;T gateway device is assigned the /60 prefix delegation (PD) and it does not pass that /60 PD down to the passthrough connected device. The AT&amp;T gateway reserves eight (8) of the sixteen (16) /64 subnets within the /60 (64 - 60 = 4, so 2^4 = 16) for its own purposes. However, while certainly not as straight-forward as a true /56 PD granted to the OpenWrt WAN interface, it is possible to still use the remaining eight (8) /64 subnets within your OpenWrt configuration and downstream client subnets.

In order to achieve the goal of requesting the additional /64 subnets from the PD, a separate /64 PD request must be sent to the AT&amp;T gateway device, with a unique MAC address, for each /64 you wish to obtain. To meet this objective with odhcp6c, you need to create additional devices and interfaces stemming from the OpenWrt WAN interface. This requires **kmod-macvlan**:

```
opkg update && opkg install kmod-macvlan
```

With kmod-macvlan installed, in your /etc/config/network file create a 'macvlan' type device for each /64 subnet you wish to pull from the AT&amp;T gateway. In this example, we will pull and use three /64 subnets, each for a separate client VLAN/subnet that OpenWrt handles:

*Note: The 'macaddr' values in this example are arbitrary and can be set to any MAC address you choose. The key is to ensure each is unique within your entire OpenWrt device.*

```
config device 'vwan1'
	option name 'vwan1'
	option type 'macvlan'
	option ifname 'eth0'
	option macaddr '70:e7:cf:ae:f2:00'

config device 'vwan2'
	option name 'vwan2'
	option type 'macvlan'
	option ifname 'eth0'
	option macaddr '70:e7:cf:ae:f2:01'

config device 'vwan3'
	option name 'vwan3'
	option type 'macvlan'
	option ifname 'eth0'
	option macaddr '70:e7:cf:ae:f2:02'
```

The next step is to create a corresponding interface for each of the newly added devices. Again, in this example we are creating three where one is for 'LAN', one is for 'GUEST', and the third is for 'IOT':

```
config interface 'WAN6LAN'
	option proto 'dhcpv6'
	option peerdns '0'
	option device 'vwan1'
	option reqprefix '64'
	option reqaddress 'none'

config interface 'WAN6GUEST'
	option proto 'dhcpv6'
	option device 'vwan2'
	option reqprefix '64'
	option peerdns '0'
	option reqaddress 'none'

config interface 'WAN6IOT'
	option proto 'dhcpv6'
	option device 'vwan3'
	option reqaddress 'none'
	option reqprefix '64'
	option peerdns '0'
```

Finally, each of the client subnet interfaces needs to be set to hand out IPv6 addresses from its corresponding WAN6* IPv6 pool. This is achieved by using the *list ip6class* setting and *option ip6assign* option for a client facing interface in /etc/config/network:

```
config interface 'LAN'
	option proto 'static'
	option netmask '255.255.255.0'
	option ipaddr '192.168.1.1'
	option device 'eth1'
	list ip6class 'WAN6LAN'
	option ip6assign '64'

config interface 'GUEST'
	option proto 'static'
	option netmask '255.255.255.0'
	option ipaddr '192.168.9.1'
	option device 'eth1.9'
	list ip6class 'WAN6GUEST'
        option ip6assign '64'

config interface 'IOT'
	option proto 'static'
	option netmask '255.255.255.0'
	option ipaddr '192.168.99.1'
	option device 'eth1.99'
	list ip6class 'WAN6IOT'
        option ip6assign '64'
```

Bonus step: Because you no longer will be assigning addresses based on your WAN interface's PD, you can disable the request to pull a PD on your WAN interface by adding this to your /etc/config/network file (on your WAN interface):

```
option reqprefix 'no'
```

Your WAN interface will still request a usable IPv6 (SLAAC) address from the AT&amp;T gateway for OpenWrt purposes.

## General xDSL configuration (step by step)

1. Connect to box:
   
   ```
   ssh root@192.168.1.1
   ```
2. (optional) Patch DSL Firmware to appropriate Annex (not at all boxes):
   
   ```
   cd /lib/firmware/
   ls
   bspatch lantiq-vrx200-a.bin firmware-b.bin lantiq-vrx200-a-to-b.bspatch
   ```
   
   Note that since [March 2016](https://github.com/openwrt/openwrt/commit/a937e160c8f7d8ac11f615c1d0cd5eea1c049247 "https://github.com/openwrt/openwrt/commit/a937e160c8f7d8ac11f615c1d0cd5eea1c049247"), **manually** patching the “annex a” firmware is **not** necessary. Simply include:
   
   ```
   config dsl 'dsl'
     option annex 'b'
   ```
   
   in /etc/config/network, and the “annex a” firmware will be ["automagically" patched](https://github.com/openwrt/openwrt/blob/master/package/network/config/ltq-vdsl-app/files/dsl_control#L254 "https://github.com/openwrt/openwrt/blob/master/package/network/config/ltq-vdsl-app/files/dsl_control#L254") when the wan interface is created.
3. set Annex:
   
   ```
   vi /etc/config/network
   
   config dsl 'dsl'
   	option annex 'j'	# try 'b' or 'j' in Germany/Austria
   	option firmware '..'	# (optional) set to '/lib/firmware/firmware-b.bin'
   ```
   
   vi press: \[d] → delete line; \[i] → insert mode; \[ESC] → \[:] → \[w]\[q] → \[return] → write and quit
4. Connect DSL → f.e. Germany: TAE middle port to box DSL port (cable both middle pins populated)
5. Restart DSL-modem:
   
   ```
   /etc/init.d/dsl_control restart
   ```
   
   O²Box6431: did not need box reboot / SpeedportW504VTypeA: had to reboot box for DSL connection
6. Check if firmware is loaded (if Annex is already set right there will be more values), repeat a few times:
   
   ```
   (O²Box6431)
   root@OpenWrt:~# /etc/init.d/dsl_control status
   
   ATU-C Vendor ID:                          
   ATU-C System Vendor ID:                   
   Chipset:                                  Lantiq-VRX200
   Firmware Version:                         5.7.9.9.0.6
   API Version:                              4.17.18.6
   XTSE Capabilities:                        , , , , , , , 
   Annex:                                    
   Line Mode:                                
   Profile:                                  
   Line State:                               DOWN [0x200: silent]
   ```
7. Check connection attempts - repeat a few times:
   
   ```
   /etc/init.d/dsl_control status
   
   Line State:
   
   DOWN [0x100: idle]
   DOWN [0x200: silent]
   
   [..]
   DOWN [0x300: handshake]
   
   [..]
   DOWN [0xff: idle request]
   
   [..]
   DOWN [0x300: handshake]
   
   [..till]
   UP [0x801: showtime_tc_sync]
   ```
   
   Try an other Annex if it loops between idle and handshake → f.e. O²Box6431: AnnexA not working due AnnexB/J in Germany → Patch DSL Firmware to appropriate Annex
8. Working DSL connection (SpeedportW504VTypeA, O² DSL):
   
   ```
   /etc/init.d/dsl_control status	
   
   ATU-C Vendor ID:                          Broadcom 178.17
   ATU-C System Vendor ID:                   0F,00,4E,4F,4B,42,00,00
   Chipset:                                  Ifx-Danube
   Firmware Version:                         2.4.1.7.0.2
   API Version:                              3.24.4.4
   XTSE Capabilities:                        0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x1, 0x0
   Annex:                                    J
   Line Mode:                                G.992.5 (ADSL2+)
   Profile:                                  
   Line State:                               UP [0x801: showtime_tc_sync]
   Forward Error Correction Seconds (FECS):  Near: 0 / Far: 1
   Errored seconds (ES):                     Near: 0 / Far: 2
   Severely Errored Seconds (SES):           Near: 0 / Far: 0
   Loss of Signal Seconds (LOSS):            Near: 0 / Far: 0
   Unavailable Seconds (UAS):                Near: 60 / Far: 60
   Header Error Code Errors (HEC):           Near: 0 / Far: 81
   Non Pre-emtive CRC errors (CRC_P):        Near:  / Far: 
   Pre-emtive CRC errors (CRCP_P):           Near:  / Far: 
   Power Management Mode:                    L0 - Synchronized
   Latency [Interleave Delay]:               8.0 ms [Interleave]   7.50 ms [Interleave]
   Data Rate:                                Down: 19.926 Mb/s / Up: 1.901 Mb/s
   Line Attenuation (LATN):                  Down: 15.2 dB / Up: 24.2 dB
   Signal Attenuation (SATN):                Down: 13.8 dB / Up: 9.8 dB
   Noise Margin (SNR):                       Down: 6.1 dB / Up: 24.2 dB
   Aggregate Transmit Power (ACTATP):        Down: 18.2 dB / Up: 12.8 dB
   Max. Attainable Data Rate (ATTNDR):       Down: 19.956 Mb/s / Up: 1.901 Mb/s
   Line Uptime Seconds:                      418
   Line Uptime:                              6m 58s
   ```
9. Set specific ISP Configuration → ![:!:](/lib/images/smileys/exclaim.svg) VLAN for working WAN/Uplink
