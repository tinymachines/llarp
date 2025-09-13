# Splitting VLANs

This article relies on the following:

- Accessing [web interface](/docs/guide-quick-start/walkthrough_login "docs:guide-quick-start:walkthrough_login") / [command-line interface](/docs/guide-quick-start/sshadministration "docs:guide-quick-start:sshadministration")
- Managing [configs](/docs/guide-user/base-system/uci "docs:guide-user:base-system:uci") / [packages](/docs/guide-user/additional-software/managing_packages "docs:guide-user:additional-software:managing_packages") / [services](/docs/guide-user/base-system/managing_services "docs:guide-user:base-system:managing_services") / [logs](/docs/guide-user/base-system/log.essentials "docs:guide-user:base-system:log.essentials")

This article may contain network configuration that depends on migration to DSA in OpenWrt 21.02

- Check if your device uses DSA or swconfig as not all devices have been migrated
- ifname@interface has been moved to device sections
- [DSA Networking](/docs/guide-user/network/dsa/start "docs:guide-user:network:dsa:start")
- [Mini tutorial for DSA network config](https://forum.openwrt.org/t/mini-tutorial-for-dsa-network-config/96998 "https://forum.openwrt.org/t/mini-tutorial-for-dsa-network-config/96998") on the forum
- [DSA in the 21.02 release notes](https://openwrt.org/releases/21.02/notes-21.02.0#new_network_configuration_syntax_and_boardjson_change "https://openwrt.org/releases/21.02/notes-21.02.0#new_network_configuration_syntax_and_boardjson_change")

## Introduction

This how-to virtually splits off one of your devices Ethernet ports to be used for non-LAN purposes. E.g. you could provide this Ethernet port for your guests or for a secured extra zone used for an office work computer separated from your LAN zone.

This how-to just demonstrates how to create the additional VLAN switch. The VLAN switch created by this how-to needs to be linked to a dedicated interface and a dedicated firewall zone in subsequent steps.

## Web interface instructions

### Default configuration

A typical default LEDE configuration on a home router with 5 LAN ports looks like this, when going to the “switch” menu of LuCI:

VLAN  
ID Upstream side:  
HW switch ↔ eth0 driver Downstream side:  
HW switch ↔ physical ports CPU (eth0) LAN 1 LAN 2 LAN 3 LAN 4 WAN 1 tagged untagged untagged untagged untagged off 2 tagged off off off off untagged

This default configuration provides 2 VLAN switches by default:

1. VLAN ID 1: the VLAN switch for the 4 ports (that are mapped to the LAN interface)
2. VLAN ID 2: the VLAN switch mapped to the 1 WAN port

### Modified configuration

As we can't magically add new physical ports to the existing device, we will simply reassign LAN 1 to make up a new virtual switch:

VLAN  
ID Upstream side:  
HW switch ↔ eth0 driver Downstream side:  
HW switch ↔ physical ports CPU (eth0) LAN 1 LAN 2 LAN 3 LAN 4 WAN 1 tagged off untagged untagged untagged off 2 tagged off off off off untagged 3 tagged untagged off off off off

Note the new third line and the change in the intersection of VLAN 1 and LAN 1. This updated configuration means that you will now have 3 VLAN switches:

1. VLAN ID 1: the VLAN switch for the remaining 3 ports (that are still mapped to the LAN interface)
2. VLAN ID 2: the VLAN switch mapped to the 1 WAN port
3. VLAN ID 3: the newly created VLAN switch for the 1 port LAN 1. This port is currently without function. You first have to assign it to an interface (in the “physical settings” tab of an existing or newly created interface)

Notes:

- LAN 1 in this example can no longer be used for SSH or LuCI administration, unless you link the existing LAN interface to this newly created VLAN switch eth0.3 (But usually you will want to assign this new VLAN to a newly created interface, which then has to be put into a new firewall zone).
- As long as one last LAN port remains in VLAN switch 1, you will still have access to LuCI and SSH over that port. In case you have accidentally or purposely set all ports to “off” in switch VLAN 1, in most cases you can still use your WiFi for LEDE admin access.
- The LAN IDs as used in the switch section of LuCI or in config files of UCI may not reflect the same numbering scheme used on the printed labels on the outside of your router. Due to decisions of the manufacturer, it could be inverted on some devices (4=1, 3=2, 2=3, 1=4).
