# LOG MESSAGES

In 12.09 The content of the membuffer that syslogd writes to, by default, consists of up to 16 KB utf-8/ASCII encoded characters. Remember this if/when you use `logger`. To read the content of the membuffer that syslogd writes to, use the `logread` utility (for kernel messages use `dmesg`). Let's have a look at the MESSAGES different program produces: on OpenWrt they all start with the name of the program that send the message plus its PID.

It would be foolish to even try to display and explain all the Log messages the programs used with OpenWrt generate. We need external links.

## dropbear

```
Feb  4 21:45:43 openwrt user.info dropbear[9815]: Child connection from 192.168.1.1:46247
Feb  4 21:45:43 openwrt user.notice dropbear[9815]: password auth succeeded for 'username' from 192.168.1.1:46247
Feb  5 00:03:34 openwrt user.info dropbear[9815]: exit after auth (username): Exited normally
Feb  5 03:13:39 openwrt user.warn dropbear[10221]: bad password attempt for 'root' from 192.168.1.1:51570
Feb  5 03:13:40 openwrt user.warn dropbear[10221]: bad password attempt for 'root' from 192.168.1.1:51570
Feb  5 03:13:42 openwrt user.warn dropbear[10221]: bad password attempt for 'root' from 192.168.1.1:51570
Feb  5 03:13:43 openwrt user.warn dropbear[10221]: bad password attempt for 'root' from 192.168.1.1:51570
Feb  5 03:13:45 openwrt user.warn dropbear[10221]: bad password attempt for 'root' from 192.168.1.1:51570
Feb  5 03:13:48 openwrt user.info dropbear[10221]: exit before auth (user 'root', 5 fails): Disconnect received
```

- dropbear\[PID]: dropbear with the PID 999 is running all the time. This instance (PID=9815) has been spawn for this ssh session.
- password auth succeeded for 'username' from 192.168.1.1:46247: \\\\this is going to spawn an ash instance with the PID 9687

As you see, it is possible to try many many passwords. You can put an end to this by configuring dropbear or with netfilter. You can (and should) read your logs regularly, but of course you can also initiate thing with logs.

- When you debug, you should create a lot of logs.
- During normal service, you should create logs
  
  - to WARN you *read them regularly*
  - LOGs in order to be able to reconstruct things. *read them when need it*

Yes, when you have any service running 24/7, you are responsible for it. “I didn't know” doesn't really count in court. It is your responsibility to keep yourself informed!

## netfilter

`Feb 3 16:04:14 openwrt user.warn kernel: IPT_dsl-Rej IN=pppoe-dsl OUT= MAC= SRC=119.121.32.2 DST=141.70.120.8 LEN=79 TOS=0x00 PREC=0x00 TTL=53 ID=22415 PROTO=UDP SPT=15758 DPT=38565 LEN=59`

```
kernel: IPT_dsl-Rej IN=pppoe-dsl OUT= MAC= SRC=222.155.169.237 DST=79.128.154.27 LEN=60 TOS=0x00 PREC=0x40 TTL=46 ID=7247 DF PROTO=TCP SPT=4709 DPT=23 WINDOW=5808 RES=0x00 SYN URGP=0
```

Part of Message Meaning kernel: The kernel send this message. (because netfilter is part of the kernel) remember `iptables`/`ip6tables` are only the user space programs to configure netfilter. IPT\_dsl-Rej the string you set with `--log-prefix`, see [configuration](/docs/guide-user/firewall/netfilter-iptables/netfilter#configuration "docs:guide-user:firewall:netfilter-iptables:netfilter") IN= Incoming interface OUT= Outgoing Interface MAC= dst and src MACs and something else SRC= Source IP address DST= Destination IP address LEN= Overall length of IP packet in bytes TOS= the ToS-Flag PREC= belongs to ToS TTL= Time-to-live in `ms` or in `hops` ID= DF Don't Fragment Flag set PROTO= [transport protocol](https://en.wikipedia.org/wiki/Transport%20Layer "https://en.wikipedia.org/wiki/Transport Layer") used `TCP` `UDP` etc. SPT= source port DPT= destination port LEN= payload size in bytes WINDOW= RES= SYN SYN flag, see [Three-way handshake](https://en.wikipedia.org/wiki/Three-way%20handshake "https://en.wikipedia.org/wiki/Three-way handshake") URGP=

[http://logi.cc/en/2010/07/netfilter-log-format/](http://logi.cc/en/2010/07/netfilter-log-format/ "http://logi.cc/en/2010/07/netfilter-log-format/")

## pppd

```
Feb 22 14:20:13 openwrt daemon.info pppd[18505]: Plugin rp-pppoe.so loaded.
Feb 22 14:20:13 openwrt daemon.notice pppd[18505]: pppd 2.4.4 started by root, uid 0
Feb 22 14:20:13 openwrt daemon.info pppd[18505]: PPP session is 1561
Feb 22 14:20:13 openwrt daemon.info pppd[18505]: Using interface pppoe-dsl
Feb 22 14:20:13 openwrt daemon.notice pppd[18505]: Connect: pppoe-dsl <--> eth0.2
Feb 22 14:20:13 openwrt daemon.info pppd[18505]: CHAP authentication succeeded: access accepted : xxxxxxx
Feb 22 14:20:13 openwrt daemon.notice pppd[18505]: CHAP authentication succeeded
Feb 22 14:20:13 openwrt daemon.notice pppd[18505]: peer from calling number xx:xx:xx:xx:xx:xx authorized
Feb 22 14:20:13 openwrt daemon.notice pppd[18505]: local  IP address 123.123.123.99
Feb 22 14:20:13 openwrt daemon.notice pppd[18505]: remote IP address 123.123.123.1
Feb 22 14:20:13 openwrt daemon.notice pppd[18505]: primary   DNS address 100.150.100.200
Feb 22 14:20:13 openwrt daemon.notice pppd[18505]: secondary DNS address 100.150.100.100
Feb 22 14:20:13 openwrt user.notice ifup: Enabling Router Solicitations on dsl (pppoe-dsl)
Feb 22 14:20:15 openwrt user.notice rdate: Synced with ntp0.fau.de
---
Feb 22 23:20:11 openwrt daemon.info pppd[18196]: Terminating on signal 15
Feb 22 23:20:11 openwrt daemon.info pppd[18196]: Connect time 1268.2 minutes.
Feb 22 23:20:11 openwrt daemon.info pppd[18196]: Sent 62343675 bytes, received 1094463306 bytes.
Feb 22 23:20:11 openwrt daemon.notice pppd[18196]: Connection terminated.
Feb 22 23:20:12 openwrt daemon.info pppd[18196]: Exit.
```

**NOTE:** You can make `pppd` verbose with setting `option pppd_options debug` in your `/etc/config/network`, see [network](/docs/guide-user/network/wan/wan_interface_protocols#protocol_pppoe_ppp_over_ethernet "docs:guide-user:network:wan:wan_interface_protocols"). With `uci commit network` and then restart `pppd` (ifdown pppoe-dsl does NOT restart the daemon, you can achieve that with `???`)

Message Meaning

## dnsmasq

```
Feb  4 20:07:59 openwrt daemon.info dnsmasq-dhcp[1026]: DHCPREQUEST(eth0.1) 192.168.1.1 xx:xx:xx:xx:xx:xx
Feb  4 20:07:59 openwrt daemon.info dnsmasq-dhcp[1026]: DHCPACK(eth0.1) 192.168.1.1 xx:xx:xx:xx:xx:xx wonderwoman
Feb  4 21:16:20 openwrt daemon.info dnsmasq-dhcp[1026]: DHCPREQUEST(eth0.1) 192.168.1.1 xx:xx:xx:xx:xx:xx
Feb  4 21:16:20 openwrt daemon.info dnsmasq-dhcp[1026]: DHCPACK(eth0.1) 192.168.3.1 xx:xx:xx:xx:xx:xx superman
```
