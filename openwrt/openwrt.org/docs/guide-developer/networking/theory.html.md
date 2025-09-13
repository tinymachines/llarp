# Theory

## Networking

### ... is packet based

Information (data) is broken into [packets](/docs/guide-user/network/traffic-shaping/packet.scheduler.theory#packets "docs:guide-user:network:traffic-shaping:packet.scheduler.theory") prior to being transported to their destination(s).

**Example:**

- [Ethernet](https://en.wikipedia.org/wiki/Ethernet "https://en.wikipedia.org/wiki/Ethernet") (see [IEEE 802](https://en.wikipedia.org/wiki/IEEE%20802 "https://en.wikipedia.org/wiki/IEEE 802") for even more standards) is a huge and successful family of modular *communication protocols*, [Fast Ethernet](https://en.wikipedia.org/wiki/Fast%20Ethernet "https://en.wikipedia.org/wiki/Fast Ethernet") comprises the ones that have a gross throughput ([Data signaling rate](https://en.wikipedia.org/wiki/Data%20signaling%20rate "https://en.wikipedia.org/wiki/Data signaling rate")) of 100MBit/s and [100BASE-TX](https://en.wikipedia.org/wiki/100BASE-TX "https://en.wikipedia.org/wiki/100BASE-TX") is one distinct example, one specific standard.
  
  - [Ethernet frame](https://en.wikipedia.org/wiki/Ethernet%20frame "https://en.wikipedia.org/wiki/Ethernet frame") is the denomination for data chunk, a packet transmitted over Ethernet. This is common for all Ethernet standards, whereas the cabling, the encoding and other stuff is not. Depending on the wiring [CSMA/CD](https://en.wikipedia.org/wiki/Carrier%20sense%20multiple%20access%20with%20collision%20detection "https://en.wikipedia.org/wiki/Carrier sense multiple access with collision detection") could be avoided.
  - *As you can see, this layer, has very technical aspects, and also some theoretical, logical or software aspects.*

### ... is layer based

The [OSI model](https://en.wikipedia.org/wiki/OSI%20model "https://en.wikipedia.org/wiki/OSI model") outlines the various layers that data must traverse on it's journey from its source to its destination(s).

Each layer has it's own set of rules (protocols) for handling data packets and adds or removes it's own header (and sometimes a footer) before passing data packets to the next layer. It treats each packet, with or without formatting from other layers, as a simple payload, ignoring it's contents. This process is referred to as [encapsulation](https://en.wikipedia.org/wiki/Encapsulation_%28networking%29 "https://en.wikipedia.org/wiki/Encapsulation_(networking)").

The software and hardware associated with each individual layer is not concerned with, and in fact, not even aware of what happens to the packets in the other layers. It's only function is to format the packets it receives from the layer above or below in a predictable fashion. In this way a very complex process is broken down into a series of simple steps which allows all kinds of different technologies to simply and reliably interact with one another.

- [Encapsulation](http://www.routemybrain.com/wp-content/uploads/2010/04/encapsulation.jpg "http://www.routemybrain.com/wp-content/uploads/2010/04/encapsulation.jpg")
- [Detailed abstract data flow NOT through the layers in one host](http://upload.wikimedia.org/wikipedia/commons/3/37/Netfilter-packet-flow.svg "http://upload.wikimedia.org/wikipedia/commons/3/37/Netfilter-packet-flow.svg")
- [Data flow through OSI layers](http://www.infocellar.com/networks/images/osi.gif "http://www.infocellar.com/networks/images/osi.gif")

The *physical layer* always concerns itself with the medium the signal traverses through (or over) while the *link layer* could be split into two sub-layers: [*Media Access Control*](https://en.wikipedia.org/wiki/Media%20Access%20Control "https://en.wikipedia.org/wiki/Media Access Control") and [*Logical Link Control*](https://en.wikipedia.org/wiki/Logical%20Link%20Control "https://en.wikipedia.org/wiki/Logical Link Control"). The [Media Independent Interface](https://en.wikipedia.org/wiki/Media%20Independent%20Interface "https://en.wikipedia.org/wiki/Media Independent Interface") is again something different, this is used to connect the distinct switch-chip to the SoC.

How big a packet is, and how it's header looks like depends on the protocol or standard it abides by. Read about this: , [IP packet](https://en.wikipedia.org/wiki/IP%20packet "https://en.wikipedia.org/wiki/IP packet"), for an overview. For real precise technical data, read the corresponding RFCs.

These protocols, in turn,

### Packet Structure

Protocol Header Size in Bytes Total Size in Bytes [Ethernet frame](https://en.wikipedia.org/wiki/Ethernet%20frame "https://en.wikipedia.org/wiki/Ethernet frame") 38–42 Size: 84–1542Bytes, with [Jumbo frame](https://en.wikipedia.org/wiki/Jumbo%20frame "https://en.wikipedia.org/wiki/Jumbo frame") up to 9042 [IEEE 802.11](https://en.wikipedia.org/wiki/IEEE%20802.11 "https://en.wikipedia.org/wiki/IEEE 802.11") ??? ???? [Cisco Picture](http://www.cisco.com/web/about/ac123/ac147/images/ipj/ipj_11-4/114_wireless-fig1b_lg.gif "http://www.cisco.com/web/about/ac123/ac147/images/ipj/ipj_11-4/114_wireless-fig1b_lg.gif") [WLAN mac mode](http://spacehopper.org/mirrors/www.geocities.com/backgndtest/wlan_mac_frame.jpg "http://spacehopper.org/mirrors/www.geocities.com/backgndtest/wlan_mac_frame.jpg") [PPDU Frame](http://wireless.agilent.com/wireless/helpfiles/n7617b/ppduframeb_2.gif "http://wireless.agilent.com/wireless/helpfiles/n7617b/ppduframeb_2.gif") [IPv4 Packet Structure](https://en.wikipedia.org/wiki/IPv4#Packet_structure "https://en.wikipedia.org/wiki/IPv4#Packet_structure") 20–60 Size: 20– (20-byte header + 0 bytes data) 65.535 [IPv6 Packet Structure](https://en.wikipedia.org/wiki/IPv6%20packet "https://en.wikipedia.org/wiki/IPv6 packet") 40 fixed, Optional Extension Header possible up to 65.535 [TCP Segment Structure](https://en.wikipedia.org/wiki/Transmission_Control_Protocol#TCP_segment_structure "https://en.wikipedia.org/wiki/Transmission_Control_Protocol#TCP_segment_structure") 20–60 up to 65.535 [UDP Packet Structure](https://en.wikipedia.org/wiki//User_Datagram_Protocol#Packet_structure "https://en.wikipedia.org/wiki//User_Datagram_Protocol#Packet_structure") 4–8 with IPv4 and 6–8 with IPv6 up to 65.535

Please see [MTU](https://en.wikipedia.org/wiki/Maximum%20transmission%20unit "https://en.wikipedia.org/wiki/Maximum transmission unit")

Ethernet Preamble Start of frame delimiter MAC dest MAC source 802.1Q tag (opt.) Ethertype or length **Payload** CRC Interframe gap Octets 7 1 6 6 4 2 **46–1500** 4 12 IPv4 Version Header Length Differentiated Services Code Point Explicit Congestion Notification Total Length Identification Flags Fragment Offset Time to Live Protocol Header Checksum Source IP Address Destination IP Address Options ( if Header Length &gt; 5 ) **Payload** Bits 4 4 6 2 16 16 3 13 8 8 16 32 32 ? 1440-1480Bytes TCP Source port Destination port Sequence number Acknowledgment number Data offset Reserved Flag Window Size Checksum Urgent pointer Options (if Data Offset &gt; 5) padding **Payload** Bits 16 16 32 32 4 4 8 16 16 16 Options (if Data Offset &gt; 5) 8 **Payload**

Please note, that the Ethernet protocol family comprises standards of Layer 2 and also Layer 1. The latter are e.g. 100Base-TX or 1000Base-T. [PPPoE](https://en.wikipedia.org/wiki/Point-to-Point%20Protocol%20over%20Ethernet "https://en.wikipedia.org/wiki/Point-to-Point Protocol over Ethernet") is yet another Layer 2 communication protocol! And DSL is another Layer 1 communication protocol. So the Modem on the customers side communicates over some DSL-protocol with the [DSLAM](https://en.wikipedia.org/wiki/DSLAM "https://en.wikipedia.org/wiki/DSLAM") on the ISP side and the router communicates with the [DSL-AC](https://en.wikipedia.org/wiki/Broadband%20Remote%20Access%20Server "https://en.wikipedia.org/wiki/Broadband Remote Access Server") over PPPoE.

Being Layer 1 protocols, 1000Base-T or DSL don't care about packets or whatever. Their logic is only concerned with transmitting the data over the specified medium.

### Networking Protocols

#### Layer1 and Layer2

- [Ethernet](https://en.wikipedia.org/wiki/Ethernet "https://en.wikipedia.org/wiki/Ethernet")
  
  - [PPPoE](https://en.wikipedia.org/wiki/Point-to-Point%20Protocol%20over%20Ethernet "https://en.wikipedia.org/wiki/Point-to-Point Protocol over Ethernet")
- [ATM](https://en.wikipedia.org/wiki/Asynchronous%20Transfer%20Mode "https://en.wikipedia.org/wiki/Asynchronous Transfer Mode")
  
  - [PPPoA](https://en.wikipedia.org/wiki/Point-to-Point%20Protocol%20over%20ATM "https://en.wikipedia.org/wiki/Point-to-Point Protocol over ATM")
- [IEEE 802.11](https://en.wikipedia.org/wiki/IEEE%20802.11 "https://en.wikipedia.org/wiki/IEEE 802.11")
