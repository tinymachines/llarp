# Accessing the modem through the router

This article relies on the following:

- Accessing [web interface](/docs/guide-quick-start/walkthrough_login "docs:guide-quick-start:walkthrough_login") / [command-line interface](/docs/guide-quick-start/sshadministration "docs:guide-quick-start:sshadministration")
- Managing [configs](/docs/guide-user/base-system/uci "docs:guide-user:base-system:uci") / [packages](/docs/guide-user/additional-software/managing_packages "docs:guide-user:additional-software:managing_packages") / [services](/docs/guide-user/base-system/managing_services "docs:guide-user:base-system:managing_services") / [logs](/docs/guide-user/base-system/log.essentials "docs:guide-user:base-system:log.essentials")

## Introduction

- This how-to describes the method for accessing the modem connected to your OpenWrt router.
- It helps to reach the administrative interface of a DSL/DOCSIS modem operating in the bridge mode.
- The prerequisite is to know the modem's IP address, port/protocol and username/password.

## Goals

- Access the modem operating in the bridge mode through the router.

## Web interface instructions

Assuming your modem's IP address is `192.168.100.1` and it is connected to the router's WAN interface.

1. Navigate to **LuCI → Network → Interfaces**.
2. Click **Add new interface...** and specify:
   
   - Name: `modem`
   - Protocol: Static address
   - Interface: `@wan`
3. Click **Create interface**.
4. On the **General Settings** tab specify:
   
   - IPv4 address: `192.168.100.2`
   - IPv4 netmask: `255.255.255.0`
5. On the **Firewall Settings** tab specify:
   
   - Create / Assign firewall-zone: `wan`
6. Click **Save**, then **Save &amp; Apply**.

Make sure the modem subnet doesn't overlap with your LAN, otherwise change the LAN subnet.

1. Navigate to **LuCI → Network → Interfaces**.
2. Click **Edit** on the `lan` interface and change the IP address:
   
   - IPv4 address: `192.168.2.1`
3. Click **Save**, then **Save &amp; Apply** and then **Apply unchecked**.

At this point the modem should be reachable from any host in the LAN.

#### NOTE

If you are using the BanIP package, make sure to add the IP to the allowlist. Ex. `192.168.100.0/24`

## Command-line instructions

Assuming your modem's IP address is `192.168.100.1` and it is connected to the router's WAN interface.

Set up a static WAN [alias](/docs/guide-user/network/network_interface_alias "docs:guide-user:network:network_interface_alias") and assign it to the WAN zone.

```
# Configure network
uci -q del network.modem
uci set network.modem="interface"
uci set network.modem.proto="static"
uci set network.modem.device="@wan"
uci set network.modem.ipaddr="192.168.100.2"
uci set network.modem.netmask="255.255.255.0"
uci commit network
service network restart
 
# Configure firewall
uci del_list firewall.@zone[1].network="modem"
uci add_list firewall.@zone[1].network="modem"
uci commit firewall
service firewall restart
```

Make sure the modem subnet doesn't overlap with your LAN, otherwise change the LAN subnet.

```
# Configure network
uci set network.lan.ipaddr="192.168.2.1"
uci commit network
service network restart
```

If the WAN L2 device doesn't match L3 device like in case of PPPoE, change the modem interface.

```
# Fetch WAN L2 device
. /lib/functions/network.sh
network_flush_cache
network_find_wan NET_IF
network_get_physdev NET_L2D "${NET_IF}"
 
# Configure network
uci set network.modem.device="${NET_L2D}"
uci commit network
service network restart
```
