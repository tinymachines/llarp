# SNMPD

**Under Construction!**  
This page is currently under construction. You can edit the article to help completing it.

There are two options: mini-snmpd or snmpd.

## How to install snmpd

```
opkg install snmpd
```

Then Edit the /etc/config/snmpd file and finetune what you need. More advanced configurations might need to edit the snmpd init script and make the snmpd program to load another custom config.

## Usage notes for snmpd

Basic information about WIFi 802.11 interfaces can be obtained using the OID 1.2.840.10036, the [MIB file for this OID is available for download from sourceforge](https://sourceforge.net/p/net-snmp/patches/_discuss/thread/35fa2f88/2b10/attachment/80211-MIB.txt "https://sourceforge.net/p/net-snmp/patches/_discuss/thread/35fa2f88/2b10/attachment/80211-MIB.txt").

## How to install mini-snmpd

```
opkg install mini_snmpd
```

**Note:** minisnmpd uses a 32 bit counter, which maxes out at 4294967295. This means any traffic over that does not appear on the counter, making it appear that you no longer have traffic. This is by design of minisnmpd. See [Bug Report](https://dev.openwrt.org/ticket/13597 "https://dev.openwrt.org/ticket/13597") and minisnmpd [project page](http://freecode.com/projects/minisnmpd "http://freecode.com/projects/minisnmpd")

## Basic configuration for mini-snmpd

Open /etc/config/mini\_snmpd and update the entries in the brackets to something that makes sense for you:

```
config mini_snmpd
        option enabled 1
        option ipv6 0
        option community <SNMP COMMUNITY>
        option location '<WHERE YOUR OPENWRT IS :)>'
        option contact '<YOUR CONTACT DETAILS>'
        option disks '/tmp,/jffs,<ANY OTHER DISKS>'
        option interfaces 'lo,br-lan,eth0.1,eth1' # Max 4
```

## 64-bit counters issues

![](/_media/meta/icons/tango/48px-outdated.svg.png) As of [r25486](https://dev.openwrt.org/changeset/25486 "https://dev.openwrt.org/changeset/25486") this patch is in the tree.

Take a look at the [forum post](https://forum.openwrt.org/viewtopic.php?pid=127560#p127560 "https://forum.openwrt.org/viewtopic.php?pid=127560#p127560") (“64 bit counter support in SNMP (TL-WR1043ND)”), i.e. get the patch from [Ticket 8818](https://dev.openwrt.org/ticket/8818 "https://dev.openwrt.org/ticket/8818") (“Enable 64 bit counters in net-snmp”), build and reinstall the whole kernel/system (rebuild and opkg install the new snmp package didn't work).

## Usage with Cacti

For some reason, Cacti doesn't like the system response that mini\_snmpd gives (eg uptime, syslocation etc). In order to get your graphs correctly generated within Cacti, you need to change the way Cacti polls the OpenWRT system to see if it is up - on the device page within Cacti you should change the 'downed device detection' method to 'Ping' and the ping method to 'ICMP Ping'. This should then work :)

## Wireless signal and noise

Here is a small patch for mini\_snmpd to support monitoring wireless signal and noise with Cacti. Here is the [patch for mini\_snmpd](http://nottheoilrig.com/openwrt/201212090/wireless.patch "http://nottheoilrig.com/openwrt/201212090/wireless.patch") and here is a patch to [add it to OpenWrt](http://patchwork.openwrt.org/patch/3061/ "http://patchwork.openwrt.org/patch/3061/"). Here is a blog post about [how to configure Cacti](http://jdbates.blogspot.com/2012/12/heres-patch-for-mini-snmp-daemon-to.html "http://jdbates.blogspot.com/2012/12/heres-patch-for-mini-snmp-daemon-to.html") to make graphs from signal and noise data.

The OIDs in the patch are chosen to work with the kbridge.xml SNMP query this is distributed with Cacti.

[![http://nottheoilrig.com/openwrt/201212090/](/lib/exe/fetch.php?tok=a59450&media=http%3A%2F%2Fnottheoilrig.com%2Fopenwrt%2F201212090%2Findex_files%2Fgraph_image_003.png "http://nottheoilrig.com/openwrt/201212090/")](/lib/exe/fetch.php?tok=a59450&media=http%3A%2F%2Fnottheoilrig.com%2Fopenwrt%2F201212090%2Findex_files%2Fgraph_image_003.png "http://nottheoilrig.com/openwrt/201212090/index_files/graph_image_003.png")
