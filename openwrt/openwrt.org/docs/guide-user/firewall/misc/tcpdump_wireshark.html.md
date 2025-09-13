# How to capture, filter and inspect packets using tcpdump or wireshark tools

OpenWrt is a versatile platform base on GNU/Linux, offering state-of-the art solutions. You may use [tcpdump](http://www.tcpdump.org "http://www.tcpdump.org"), [Wireshark](https://www.wireshark.org "https://www.wireshark.org") or even collect data from a switch and send it to a remote analysis system. This article does not cover network intrusion detection, which is documented separately.

This HOWTO is based on a discussion on LEDE Forum, please discuss using this link:

[https://forum.lede-project.org/t/tp-wdr3600-monitoring-capturing-wireless-traffic-howto/3308](https://forum.lede-project.org/t/tp-wdr3600-monitoring-capturing-wireless-traffic-howto/3308 "https://forum.lede-project.org/t/tp-wdr3600-monitoring-capturing-wireless-traffic-howto/3308")

This has not been tested recently. It **should** work if the packages can be installed on the target.

Update 2019-01-01: One person has confirmed its still working on a Buffalo device (Atheros AR71xx) running 18.06.1

Update 2019-02-22: One person has confirmed its still working on a Netgear device (Atheros ar71xx) running 18.06.2

Update 2020-09-19: One person has confirmed its still working on a iptime device (mt7620) running 20.172.67167

Update 2023-01-24: One person has confirmed its still working on a Xiaomi and Raspberry Pi device running 22.03.2

## Capturing packets from an OpenWrt appliance

tcpdump is a network capture and analysis tool. It may be used to capture packets on the fly and/or save them in a file for later analysis. tcpdump relies on libcap, therefore it can produce standard pcap analysis files which may be processed by other tools.

To install [tcpdump](http://www.tcpdump.org "http://www.tcpdump.org") on your device:

```
opkg install tcpdump
```

To capture all packets on the WAN (the below assumes that interface eth1 is the WAN interface):

```
# killall tcpdump; tcpdump -n -i eth1
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on eth1, link-type EN10MB (Ethernet), capture size 262144 bytes
13:16:55.036711 IP 192.168.1.94.41146 > 121.59.12.182.443: Flags [.], ack 2010466204, win 444, options [nop,nop,TS val 1064304519 ecr 2837800946], length 0
13:16:55.056721 IP 139.59.210.197.443 > 192.168.1.94.41146: Flags [.], ack 1, win 1050, options [nop,nop,TS val 2837803506 ecr 1064299424], length 0
13:16:56.018900 IP 192.168.1.94.38886 > 139.59.209.225.443: Flags [P.], seq 3899787899:3899788551, ack 1045321715, win 1043, options [nop,nop,TS val 689756067 ecr   651566707], length 652
13:16:56.072201 IP 139.59.209.225.443 > 192.168.1.94.38886: Flags [.], seq 1:1449, ack 652, win 368, options [nop,nop,TS val 651567951 ecr 689756067], length 1448 
```

To capture all packets from a specific host on the network:

```
# tcpdump -i eth0 host 192.168.2.102 -U -s0 -w /tmp/dump.txt
```

You may also use Wireshark capture and analysis tool.

To capture all packets on the the 'eth0' interface, excluding port 22 (SSH) traffic, assuming Wireshark is installed in the default location:

1. Enable SSH connection with certificated (to avoid password prompt)
2. on a Linux system:

```
ssh user@myledebox tcpdump -i eth1 -U -s0 -w - 'not port 22' | sudo wireshark -k -i -
```

1. on a macOS system:

```
ssh user@myledebox tcpdump -i eth1 -U -s0 -w - 'not port 22' | sudo /Applications/Wireshark.app/Contents/MacOS/wireshark -k -i -
```

1. or, on a Windows system:

```
ssh root@myledebox tcpdump -i eth1 -U -s0 -w - 'not port 22' | "C:\Program Files\Wireshark\Wireshark.exe" -k -i -
```

Another option is to use the sshdump tool in wireshark, like so:

```
wireshark '-oextcap.sshdump.remotehost:OpenWrt.lan' '-oextcap.sshdump.remoteusername:root' -i sshdump -k
```

## Capturing packets from a switch

Modern switches offer port-mirroring, i.e. the ability to copy all network packets from a given number of ports to a single-port, usually for analysis purpose. Usually, switches with port-mirroring are called “manageable switches”. Port mirroring happens in hardware, so your switch might not slow down. Check your documentation if port mirroring is supported.

Connect your LEDE device to the monitoring interface of your switch.

Then simply use tcpdump or wireshark to monitor traffic.

## Sending packets for remote analysis on the WWW

[CloudShark](https://www.cloudshark.org "https://www.cloudshark.org") is an cloud analysis platform, independent and not related to LEDE. It relies on cshark plugin to send packets remotely for analysis. Please check your internal rules, whether sending network traffic to a cloud platform is allowed.

Install cshark and luci-app-cshark:

```
opkg install cshark luci-app-cshark
```

Please check [Cloud shark documentation](https://support.cloudshark.org/openwrt/openwrt-cloudshark.html "https://support.cloudshark.org/openwrt/openwrt-cloudshark.html") for more information.

## Questions remaining to be documented

Please insert here what remains to be documented:

\- How to send (automatically) pcap files remotely for later analysis, on your own network.

\- How to trap network traffic using simple rules and log them to syslog/rsyslog.

\- Are there uci / luci apps allowing to manage tcpdum rules, traffic analysis, etc ...
