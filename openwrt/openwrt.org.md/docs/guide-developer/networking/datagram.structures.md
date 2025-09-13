# Datagram Structures

Please read [Datagram](https://en.wikipedia.org/wiki/Datagram "https://en.wikipedia.org/wiki/Datagram") and [OSI model](https://en.wikipedia.org/wiki/OSI%20model "https://en.wikipedia.org/wiki/OSI model").

## OSI Layer 2

[OSI Layer 2](https://en.wikipedia.org/wiki/OSI_model#Layer_2%3A_data_link_layer "https://en.wikipedia.org/wiki/OSI_model#Layer_2%3A_data_link_layer") datagrams are called **frames**.

### Ethernet

- [IEEE 802.3](https://en.wikipedia.org/wiki/Ethernet "https://en.wikipedia.org/wiki/Ethernet")
- [IEEE 802.1q: VLANs](https://en.wikipedia.org/wiki/IEEE%20802.1Q "https://en.wikipedia.org/wiki/IEEE 802.1Q")

### Wireless LAN

- [Wireless LAN](https://en.wikipedia.org/wiki/Wireless_lan "https://en.wikipedia.org/wiki/Wireless_lan").

### ATM cell

Layer 2 datagrams of the ATM protocol are called **cells**.

- [ATM cell structure](https://en.wikipedia.org/wiki/Asynchronous_Transfer_Mode#Structure_of_an_ATM_cell "https://en.wikipedia.org/wiki/Asynchronous_Transfer_Mode#Structure_of_an_ATM_cell")

### PPP

The [PPP (Point-to-point protocol)](https://en.wikipedia.org/wiki/Point-to-point%20protocol "https://en.wikipedia.org/wiki/Point-to-point protocol") is a somewhat of a partial Layer 2 protocol. It is always used in conjunction with a second Layer 2 protocol, working as a carrier.

PPP Header or Field or Tag Field Version Type Code Session-ID Length PPP protocol **Payload** Bit 4 4 8 16 16 16 x

Such PPP frames are encapsulated into the carrier frame: common are Ethernet and ATM. So we talk about

- **PPPoE Frame**: TODO (or simply combine the already given information)
- **PPPoA Cell**: TODO (or simply combine the already given information)

But since ATM protocol is ever present, you only seldom have pure PPPoE over the whole distance from your Modem to the DSLAM. You have ATM as well as Ethernet. And this gives you two possibilities to combine the two protocols. You can either encapsulate or bridge:

- Encapsulating: **PPPoEoA Frame**: [Point-to-Point\_Protocol\_over\_Ethernet#How\_PPPoE\_fits\_in\_the\_DSL\_Internet\_access\_architecture](https://en.wikipedia.org/wiki/Point-to-Point_Protocol_over_Ethernet#How_PPPoE_fits_in_the_DSL_Internet_access_architecture "https://en.wikipedia.org/wiki/Point-to-Point_Protocol_over_Ethernet#How_PPPoE_fits_in_the_DSL_Internet_access_architecture")
- Briding: **PPPoE-2-PPPoA** this means that the Modem, strips the PPPoE header of every frame and replaces it with a PPPoA header.

<!--THE END-->

- Pure PPPoE: it is being claimed that many VDSL2 connections relinquish the ATM protocols, and use pure PPPoE.

## OSI Layer 3

Datagrams at [OSI Layer 3](https://en.wikipedia.org/wiki/OSI_model#Layer_3%3A_network_layer "https://en.wikipedia.org/wiki/OSI_model#Layer_3%3A_network_layer") are called **packets**.

### IP

- [IPv4 Packet](https://en.wikipedia.org/wiki/IPv4#Packet_structure "https://en.wikipedia.org/wiki/IPv4#Packet_structure")
- [IPv6 Packet](https://en.wikipedia.org/wiki/IPv6%20packet "https://en.wikipedia.org/wiki/IPv6 packet")

### ICMP

- [ICMPv4 Packet](https://en.wikipedia.org/wiki/Internet%20Control%20Message%20Protocol "https://en.wikipedia.org/wiki/Internet Control Message Protocol")
- [ICMPv6 Packet](https://en.wikipedia.org/wiki/ICMPv6 "https://en.wikipedia.org/wiki/ICMPv6")

## OSI Layer 4

Some [OSI Layer 4](https://en.wikipedia.org/wiki/OSI_model#Layer_4%3A_transport_layer "https://en.wikipedia.org/wiki/OSI_model#Layer_4%3A_transport_layer") datagrams are referred to as **packets**. TCP datagrams are called **segments**. By definition UDP datagrams remain **datagrams** because they are [stateless](https://en.wikipedia.org/wiki/Stateless_protocol "https://en.wikipedia.org/wiki/Stateless_protocol") but are often referred to as **packets**.

### TCP

- [TCP](https://en.wikipedia.org/wiki/Transmission_Control_Protocol "https://en.wikipedia.org/wiki/Transmission_Control_Protocol")

### UDP

- [UDP](https://en.wikipedia.org/wiki/User_Datagram_Protocol "https://en.wikipedia.org/wiki/User_Datagram_Protocol")

## Datagram Structure

Protocol Header Size in Bytes Total Size in Bytes [Ethernet frame](https://en.wikipedia.org/wiki/Ethernet%20frame#Structure "https://en.wikipedia.org/wiki/Ethernet frame#Structure") 38–42 Size: 84–1542Bytes, [Jumbo frame](https://en.wikipedia.org/wiki/Jumbo%20frame "https://en.wikipedia.org/wiki/Jumbo frame") up to 9042 [Wireless LAN](https://en.wikipedia.org/wiki/IEEE%20802.11#Frames "https://en.wikipedia.org/wiki/IEEE 802.11#Frames") ?? 23?? [IPv4 Packet](https://en.wikipedia.org/wiki/IPv4#Packet_structure "https://en.wikipedia.org/wiki/IPv4#Packet_structure") 20–60 Size: 20– (20-byte header + 0 bytes data) 65.535 [IPv6 Packet](https://en.wikipedia.org/wiki/IPv6%20packet "https://en.wikipedia.org/wiki/IPv6 packet") 40 fixed, Optional Extension Header possible up to 65.535 [TCP Segment](https://en.wikipedia.org/wiki/Transmission_Control_Protocol#TCP_segment_structure "https://en.wikipedia.org/wiki/Transmission_Control_Protocol#TCP_segment_structure") 20–60 up to 65.535 [UDP Packet](https://en.wikipedia.org/wiki/User_Datagram_Protocol#Packet_structure "https://en.wikipedia.org/wiki/User_Datagram_Protocol#Packet_structure") 4–8 with IPv4 and 6–8 with IPv6 up to 65.535

### Example

TCP segment in IPv4 packet in Ethernet frame

Ethernet Octets Preamble 7 Start of frame delimiter 1 MAC destination 6 MAC source 6 802.1Q tag (opt.) 4 Ethertype or length 2 IPv4 Bits Payload 46 -1500 Version 4 Header Length 4 Differentiated Services Code Point 6 Explicit Congestion Notification 2 Total Length 16 Identification 16 Flags 3 Fragment Offset 13 Time to Live 8 Protocol 8 Header Checksum 16 Source IP Address 32 Destination IP Address 32 Options ( if Header Length &gt; 5 ) ? Payload 1440-1480 Bytes TCP Bits Source Port 16 Destination Port 16 Sequence number 32 Acknowledgment number 32 Data offset 4 Reserved 4 Flag 8 Window Size 16 Checksum 16 Urgent pointer 16 Options (if Data Offset &gt; 5) varies padding 8 Payload Payload CRC 4 Interframe gap 12
