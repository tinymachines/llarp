# Extenders/Repeaters - an Overview

There are a numerous ways to expand the coverage of a network.  
Extenders, or Repeaters as they are also known, are used to provide access to locations that are too far from the main router to give good service, or indeed, any service at all.

***Put into simple terms, an Extender connects to the router by some means (ethernet, fibre, wireless, powerline, to name but a few) and re-broadcasts the traffic to other devices nearby.***

## Why are extenders useful?

Using an extender “repeats” the signal so your device (laptop, phone, tablet etc.) receives a strong signal.  
Your device does not have to send its signal all the way back to the router, instead it just has to talk to the extender.

- Wi-Fi radios drop to lower speeds if the signal is weak.
- Background noise (eg. other people's access points, microwave ovens, electrical machinery etc.) can overwhelm the signal from a distant access point or router.
- Multiple-hop solutions (where an extender listens to another extender that then listens to the main router) can be used to provide additional range and/or coverage.

## What are the disadvantages?

If an extender/repeater uses a cable (ethernet, fibre etc) upstream connection, there is no disadvantage, in fact performance can even be enhanced.

If an extender/repeater uses a wireless upstream connection, there is the potential for a reduction in performance, particularly if the radio channel is shared between users and upstream connection.

- A wireless extender sharing a physical radio must receive each packet and then re-broadcast it. This invariably adds a degree of latency.
- Multiple-hop solutions are likely to compound any latency degradation of a single hop.
- An extender/repeater adds more hardware to the network with more points of failure.

If you can get good service without an extender, do it. “The best part is no part. The best process is no process. It weighs nothing, costs nothing, can't go wrong”

## What are the most common types of Extender/Repeater?

Follow these links :

[**Wi-Fi Extender/Repeater with Bridged AP over Ethernet**](/docs/guide-user/network/wifi/wifiextenders/bridgedap "docs:guide-user:network:wifi:wifiextenders:bridgedap")  
This type uses a cabled connection (usually ethernet) to the router. It carries no performance penalties and as such should always be the preferred solution.

[**Wi-Fi Extender/Repeater with STA (client) link to upstream AP (Hotspot)**](/docs/guide-user/network/wifi/wifiextenders/ap_sta "docs:guide-user:network:wifi:wifiextenders:ap_sta")  
This type is the simplest and does not require any access to the configuration of the router and as such is ideal for sharing a “hotspot” or a public Wi-Fi for example in a hotel.  
It does however have a potential performance penalty especially if a physical radio is shared in the repeater device.

[**Wi-Fi Extender/Repeater with WDS**](/docs/guide-user/network/wifi/wifiextenders/wds "docs:guide-user:network:wifi:wifiextenders:wds")  
This type is similar to the previous STA (client) type, but in addition is capable of supporting numerous repeaters all from a single configuration on the router.  
It carries the same performance penalties as the previous type. In addition it requires admin access to the router in normal circumstances.

[**Wi-Fi Extender/Repeater with Bridged AP over 802.11s Mesh**](/docs/guide-user/network/wifi/wifiextenders/mesh "docs:guide-user:network:wifi:wifiextenders:mesh")  
This type is very different to any of the others as it uses the ieee802.11s mesh support built into the OpenWrt kernel.  
It is easy to use with automatic configuration option and supports multi-point to multi-point connections. It can be used on the router, requiring admin access, but can also be used with a single cable connection allowing an entire network infrastructure to be constructed.  
It has the same potential performance penalties described previously, if physical radio is shared in the repeater device.

[**Wi-Fi Extender/Repeater with RelayD**](/docs/guide-user/network/wifi/wifiextenders/relay_configuration "docs:guide-user:network:wifi:wifiextenders:relay_configuration")  
This option originates from the early days of wireless drivers when the simple STA/AP mode was not supported.  
It provides an ipv4 link between the repeater and the router using the custom “Relay Bridge” protocol to overcome lack of STA/AP support in early drivers.  
With modern wireless drivers, RelayD is no longer required but nevertheless still works.  
For a standard repeater configuration it is assumed that two physical radios exist, one to connect to the router and one to be used as an access point.  
It may be possible to use RelayD as a repeater if only a single radio exists, using modern wireless drivers, otherwise it will provide only a relay of ipv4 traffic onto the repeater lan port(s).  
Such a configuration should be avoided however.

[**Travelmate - connection manager for travel routers**](/docs/guide-user/network/wifi/wifiextenders/travelmate "docs:guide-user:network:wifi:wifiextenders:travelmate")  
Although originally intended for use as a “travel router”, Travelmate can be installed on any router to extend wifi coverage. This works anywhere, but is particularly useful in cases where you don't have access to the originating router, for example in a hotel or other hotspot/access point. Travelmate “listens” to traffic from the hotspot. You and your companions can then connect to the Travelmate router for a secure, firewalled environment.
