# Simple WAN Failover with 3G/LTE WWAN - Using a second router in the same LAN

Have you ever had the situation when you are abroad and suddenly the internet connection fails at home? Now you are left in the dark about your home devices since there is no way to get into your home network and check what could potentially have gone wrong.

This article explains how to get around this situation with the simplest technical approach.

## Scenario

The below scenario allows to automatically failover to the WWAN router (Router B) internet connection as soon as the WAN interface on the OpenWrt router (Router A) goes offline. At that moment the automatically created default route 0.0.0.0/0 with metric 0 is removed from the routing table on the OpenWrt WAN router (Router A) and the secondary default route with metric 100 becomes active which forwards all traffic from the LAN to the WWAN router (Router B).

```
                                 +---------------------------------+
                                 |                                 |
           +--WAN (xDSL/Cable)---+            Internet             +----WWAN (3G/LTE)-----+
           |                     |                                 |                      |
           |                     +---------------------------------+                      |
           |                                                                              |
           |                                                                              |
           |                                                                              |
           |                                                                              |
 +---------+----------+                                                        +----------+-----------+
 | Router A (Primary) |                                                        | Router B (Secondary) |
 +----+---------------+                                                        +-----------------+----+
      | 192.168.001.001 /24                                                  192.168.001.250 /24 |
      |                                                                      GW: 192.168.001.001 |
      | Routing Table:                                                                           |
      | 0.0.0.0/0 -> WAN-If Metric 0                                                             |
      | 0.0.0.0/0 -> 192.168.001.250 Metric 100                                                  |
      |                                                                                          |
      |                                                                                          |
      |                                                                                          |
+-LAN-+---------+-----------------------------------+------------------------------------+-------+-----+
                |                                   |                                    |
                |                                   |                                    |
                |                                   |                                    |
                |                                   |                                    |
                |                                   |                                    |
                |                                   |                                    |
                |                                   |                                    |
          +-----+----+                        +-----+----+                         +-----+----+
          | Device 1 |                        | Device 2 |                         | Device 3 |
          +----------+                        +----------+                         +----------+

          192.168.001.100 /24                 192.168.001.101 /24                  192.168.001.102 /24
          GW: 192.168.001.001                 GW: 192.168.001.001                  GW: 192.168.001.001
```

## Requirements

- OpenWrt Router with WAN uplink
- 3G/LTE Router with WWAN uplink (Not necessarily OpenWrt)
- SIM card with data package (Recommended is a PrePaid SIM with a data package that does not expire)

## Configuration

It's assumed that the WAN router (Router A) and the local LAN is already installed and configured.

01. Install WWAN router and assing a local LAN ip (Example: 192.168.001.250)
02. Open LuCI and go to Network &gt; Static Routes
03. Click Add
04. Interface: LAN
05. Target: 0.0.0.0
06. SubnetMask: 0.0.0.0
07. Gateway: WWAN\_Router\_IP (192.168.1.250)
08. Change to Advanced Settings
09. Metric: 100
10. Click Save

## Considerations

- If the WAN router running OpenWrt goes completely offline (HW failure) then the network devices will not be able to automatically use the WWAN router (Router B).
- If there are port forwardings and/or a static IP on the WAN router used, these would not work while the internet connection is running in failover mode through the WWAN router (Router B).
- It's recommended to setup URL filters (Blacklist) on the WWAN router (Router B) to not allow any devices in the network to download large data which would easily consume your prepaid data volume.

Potential Blacklist entries:

- Any media streaming services
- Windows or other update services (Google for the URL's)

## Tested Setup

- WAN Router : D-Link DIR825 B1 with OpenWrt 19.07.0 r10860-a3ffeb413b / LuCI openwrt-19.07 branch git-20.006.26738-35aa527.
- WWAN Router : AVM Fritz!Box 6820 LTE v2 FRITZ!OS: 07.13
- Coop Mobile PrePaid SIM Card (Switzerland) with non expiring data package (1.5GB/14.90CHF).
