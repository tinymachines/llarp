# QoS (Network Traffic Control)

Traffic Control is the umbrella term for packet prioritizing, traffic [shaping](#shaping "docs:guide-user:network:traffic-shaping:packet.scheduler ↵"), bandwidth limiting, AQM (Active Queue Management), QoS (Quality of Service), etc. This HowTo will help you understand and set up traffic control on your router. It is one strategy to address problems caused by [Network congestion](https://en.wikipedia.org/wiki/Network%20congestion "https://en.wikipedia.org/wiki/Network congestion").

*Note: As of late 2016, the OpenWrt SQM-QoS algorithms using cake or fq\_codel have nearly eliminated bufferbloat.*  
***SQM frequently performs better in all cases - upload and download - than arduous manual QoS settings described below.***  
*SQM is simple to set up, and if it solves your problems, you're done. Check out the [SQM HOWTO](/docs/guide-user/network/traffic-shaping/sqm "docs:guide-user:network:traffic-shaping:sqm").*

![](/_media/meta/icons/tango/dialog-information.png) You *can* control, i.e. prioritize and/or shape, ANY **upload traffic**, i.e. traffic being sent from your router to the Internet. Doing so *will* solve problems that occur with congestion, i.e. [jitter](https://en.wikipedia.org/wiki/Jitter#Packet_jitter_in_computer_networks "https://en.wikipedia.org/wiki/Jitter#Packet_jitter_in_computer_networks") and delay. ![](/_media/meta/icons/tango/dialog-information.png) You do NOT have the same level of control over **download traffic**, i.e. traffic arriving at your router from the Internet. Here, you can only drop packets but not rearrange them.  
The dropping of TCP packets causes the sending site to reduce its transmission rate. The dropping of UDP packets however, will only help to keep the buffer empty.

## Preparations

1. Read about [Linux packet scheduling](/docs/guide-user/network/traffic-shaping/packet.scheduler.theory "docs:guide-user:network:traffic-shaping:packet.scheduler.theory")
2. Learn about the`tc command`
3. Determine the characteristics of the connection you are configuring the packet scheduler for:
   
   - whether it is a full-duplex or a half-duplex line [duplex](https://en.wikipedia.org/wiki/duplex "https://en.wikipedia.org/wiki/duplex")
   - the actual available upload bandwidth! The Linux packet scheduler works on Layer 2, thus you should always work with the actual bandwidth for the Layer-2-Payload:
   - ie: when you employ the Layer 1 protocol “BASE100-TX”:
     
     - you have 100Mbit/s of theoretically available bandwidth
     - Physical factors such as interference, substandard cabling or faulty hardware can reduce that bandwidth.
     - The Layer 2 protocol you use adds [protocol overhead](/docs/guide-developer/networking/datagram.structures "docs:guide-developer:networking:datagram.structures"). In the case of “Ethernet”, it adds about 2,5%, so a maximum of 97,5Mbit/s remain for the Layer-2-payload.
     - Download testing sites usually refer to Layer 4 bandwidth, which includes Layer 3 and 4 protocol overhead.
4. Be prepared to adjust your configuration. It can take some time and experimentation to find what works best for your circumstances.

### Required Packages

- **`tc`** (`traffic control`, program to configure the Linux packet scheduler)
  
  - **`kmod-sched-core`** (dependency of *tc*), package containing most used or advanced (QDiscs) and classifiers
  - **`kmod-sched`** (optional), package containing other schedulers and [classifiers](#classifier "docs:guide-user:network:traffic-shaping:packet.scheduler ↵") (those not included in the previous)
- **`iptables-mod-ipopt`** optional! Contains some matches and TARGETs for iptables: CLASSIFY, dscp/DSCP, ecn/ECN, length, mac, mark/MARK, statistic, tcpmms, tos/TOS, ttl/TTL, unclean
  
  - **`kmod-ipt-ipopt`** (module; dependency of corresponding user space module;
- **`iptables-mod-*`** optional! (modules for iptables)
  
  - **`kmod-ipt-*`** (kernel modules for iptables)
- **`l7-protocols`** optional! If you want to match Layer 7 content
- **`l7-protocols-testing`** optional! If you want to test. Check the projects own [Homepage](http://l7-filter.clearfoundation.com/ "http://l7-filter.clearfoundation.com/").

As long as your ISP does not give you access to the DSL-AC so you can install a simple TC-script, you will have to settle with [policing](#policing "docs:guide-user:network:traffic-shaping:packet.scheduler ↵") the download:

- `kmod-ifb` and act\_connmark

![](/_media/meta/icons/tango/48px-outdated.svg.png) In [r25641](https://dev.openwrt.org/changeset/25641/trunk "https://dev.openwrt.org/changeset/25641/trunk") `iptables-mod-imq` (Intermediate Queueing Device) was removed and is not supported any longer. It's successor is `kmod-ifb`. See [Intermediate Functional Block device](http://www.linuxfoundation.org/collaborate/workgroups/networking/ifb "http://www.linuxfoundation.org/collaborate/workgroups/networking/ifb")

## Installation

[opkg](/docs/guide-user/additional-software/opkg "docs:guide-user:additional-software:opkg")

```
opkg update
opkg install tc iptables-mod-ipopt
```

Since the description of `kmod-sched-core` (`kmod-sched-core` is a dependency of `tc`) does not contain any information regarding its content, after installation list the currently installed QDisc modules (try installing `kmod-sched` for other modules):

```
ls -lha /lib/modules/$(uname -r)/ | grep sch
```

To use a particular one, you need to load the kernel module into memory:

```
insmod sch_hfsc
```

You need to do this after every reboot. List of currently loaded kernel modules and to remove a module:

```
lsmod
rmmod sch_hfsc
```

After thoroughly reading this wiki page, you are going to write a shell script which will invoke `tc` a couple of times and configure the packet scheduler. Please also see the available [examples](#examples "docs:guide-user:network:traffic-shaping:packet.scheduler ↵"). When everything works good enough, proceed with [Start on boot](#start_on_boot "docs:guide-user:network:traffic-shaping:packet.scheduler ↵") and [Hotplug](#hotplug "docs:guide-user:network:traffic-shaping:packet.scheduler ↵").

## Configuration

### Hierarchy: Nesting of qdiscs &amp; classes

There are two types of scheduling algorithms [(QDiscs)](#queueingdisciplineqdisc "docs:guide-user:network:traffic-shaping:packet.scheduler ↵") - [classful](#classfulqdisc "docs:guide-user:network:traffic-shaping:packet.scheduler ↵") and [classless](#classlessqdisc "docs:guide-user:network:traffic-shaping:packet.scheduler ↵"). If you choose to employ a classful [root QDisc](#rootqdisc "docs:guide-user:network:traffic-shaping:packet.scheduler ↵"), you will be able to tailor the configuration very closely to your needs, by constructing a hierarchy of “nesting entities” and then further tune each branch of the tree separately.

`tc` is the only user space program available to set up, maintain and inspect the configuration of the Linux packet scheduler. Where `iptables`, `ip6tables` are for netfilter, `tc` is for the Linux packet scheduler. Generally only one change is made to the packet scheduler each time `tc` is executed. A small shell script containing multiple invocations of `tc` is required to achieve a meaningful overall configuration.

nesting configuration tc what command [interface](/docs/guide-developer/networking/network.interfaces "docs:guide-developer:networking:network.interfaces") parent qdisc-id classid QDisc QDisc specific parameters `tc` `qdisc` `add` `dev` eth0 `root` `handle` 1: `hfsc` default 20 `change` `dev` eth0 `root` `handle` 1: `hfsc` default 20 `replace` `dev` eth0 `root` `handle` 1: `hfsc` default 20 `link` `dev` eth0 `root` `handle` 1: `hfsc` default 20 `class` `add` `dev` eth0 `parent` 1: `classid` 1:1 `hfsc` ls rate 750kbit ul rate 1000kbit `change` `dev` eth0 `parent` 1:1 `classid` 1:10 `hfsc` ls rate 250kbit ul rate 1000kbit `replace` `dev` eth0 `parent` 1:1 `classid` 1:20 `hfsc` ls rate 250kbit ul rate 1000kbit

### Qdiscs (Packet Scheduling Algorithms)

Once you decide what your entire configuration will look like, look up the *specific configuration of the QDisc algorithm* you intend to use. Each Qdisc aka Scheduling Algorithm gives you parameters to tune:

Queueing Discipline Classfull Description kmod-sched-core kmod-sched → sch\_atm name ?? bla → sch\_blackhole Black hole queue ?? bla → [sch\_cbq](/docs/guide-user/network/traffic-shaping/sch_cbq "docs:guide-user:network:traffic-shaping:sch_cbq") Class-Based Queueing discipline ☑ very complex → [sch\_choke](/docs/guide-user/network/traffic-shaping/sch_choke "docs:guide-user:network:traffic-shaping:sch_choke") CHOKe scheduler ?? bla → [sch\_codel](/docs/guide-user/network/traffic-shaping/sch_codel "docs:guide-user:network:traffic-shaping:sch_codel") The Controlled-Delay Active Queue Management ?? available since [r31756](https://dev.openwrt.org/changeset/31756 "https://dev.openwrt.org/changeset/31756") and [r31757](https://dev.openwrt.org/changeset/31757 "https://dev.openwrt.org/changeset/31757"), mainlined in Kernel 3.5 ☑ → [sch\_drr](/docs/guide-user/network/traffic-shaping/sch_drr "docs:guide-user:network:traffic-shaping:sch_drr") Deficit Round Robin scheduler ?? can handle packets of variable size without knowing their mean size. → sch\_dsmark Differentiated Services field marker ?? bla ☑ → [sch\_esfq](/doc/howto/packet.scheduler/sch_esfq "doc:howto:packet.scheduler:sch_esfq") Enhanced Stochastic Fairness Queueing ?? removed in mainline kernel, but still available in OpenWrt ☑ → [sch\_fifo](/doc/howto/packet.scheduler/sch_fifo "doc:howto:packet.scheduler:sch_fifo") The simplest FIFO queue ?? bla ☑ → [sch\_fq\_codel](/docs/guide-user/network/traffic-shaping/sch_fq_codel "docs:guide-user:network:traffic-shaping:sch_fq_codel") Fair Queue CoDel discipline ?? available since [r31756](https://dev.openwrt.org/changeset/31756 "https://dev.openwrt.org/changeset/31756") and [r31757](https://dev.openwrt.org/changeset/31757 "https://dev.openwrt.org/changeset/31757"), mainlined in Kernel 3.5 ☑ → [sch\_generic](/doc/howto/packet.scheduler/sch_generic "doc:howto:packet.scheduler:sch_generic") Generic packet scheduler routines ?? bla → [sch\_gred](/doc/howto/packet.scheduler/sch_gred "doc:howto:packet.scheduler:sch_gred") Generic Random Early Detection ?? bla ☑ → [sch\_hfsc](/docs/guide-user/network/traffic-shaping/sch_hfsc "docs:guide-user:network:traffic-shaping:sch_hfsc") Hierarchical Fair Service Curve ☑ link sharing and low delay at the same time ☑ → [sch\_htb](/docs/guide-user/network/traffic-shaping/sch_htb "docs:guide-user:network:traffic-shaping:sch_htb") Hierarchy Token Bucket ☑ easiest configuration of link sharing, derived from CBQ, high CPU usage ☑ → [sch\_ingress](/doc/howto/packet.scheduler/sch_ingress "doc:howto:packet.scheduler:sch_ingress") Ingress qdisc ?? bla ☑ → [sch\_mq](/doc/howto/packet.scheduler/sch_mq "doc:howto:packet.scheduler:sch_mq") Classful multiqueue dummy scheduler ?? bla → [sch\_mqprio](/doc/howto/packet.scheduler/sch_mqprio "doc:howto:packet.scheduler:sch_mqprio") name ?? bla → [sch\_multiq](/doc/howto/packet.scheduler/sch_multiq "doc:howto:packet.scheduler:sch_multiq") name ?? bla → [sch\_netem](/docs/guide-user/network/traffic-shaping/sch_netem "docs:guide-user:network:traffic-shaping:sch_netem") Network emulator ☒ Drop, delay, bla packets → [sch\_pfifo\_fast](/doc/howto/packet.scheduler/sch_pfifo_fast "doc:howto:packet.scheduler:sch_pfifo_fast") FIFO with prioritizing ☒ DEFAULT, usually build-into the kernel → [sch\_prio](/doc/howto/packet.scheduler/sch_prio "doc:howto:packet.scheduler:sch_prio") Simple 3-band priority scheduler ☒ allows packet prioritization ☑ → [sch\_qfq](/doc/howto/packet.scheduler/sch_qfq "doc:howto:packet.scheduler:sch_qfq") Quick Fair Queueing Scheduler ?? bla → [sch\_red](/docs/guide-user/network/traffic-shaping/sch_red "docs:guide-user:network:traffic-shaping:sch_red") Random Early Detection ☒ bla ☑ → [sch\_sfb](/doc/howto/packet.scheduler/sch_sfb "doc:howto:packet.scheduler:sch_sfb") Stochastic Fair Blue ?? bla → [sch\_sfq](/docs/guide-user/network/traffic-shaping/sch_sfq "docs:guide-user:network:traffic-shaping:sch_sfq") Stochastic Fairness Queueing ☒ distibutes bandwidth for known tcp-connections fairly ☑ → [sch\_sfqred](/doc/howto/packet.scheduler/sch_sfqred "doc:howto:packet.scheduler:sch_sfqred") mixture of qfq and red ? → [sch\_tbf](/docs/guide-user/network/traffic-shaping/sch_tbf "docs:guide-user:network:traffic-shaping:sch_tbf") Token Bucket Filter ☒ limit bandwidth, does not work above 1mbit ☑ → [sch\_teql](/doc/howto/packet.scheduler/sch_teql "doc:howto:packet.scheduler:sch_teql") True/Trivial Link Equalizer ?? bla ☑

**`Note:`** The PRIO QDisc does contain three classes, but since they cannot be configured further, PRIO is considered to be a classless QDisc. Its classes are sometimes called bands.

### Actions

Action Description kmod-sched-core kmod-sched [act\_police](/doc/howto/packet.scheduler/act_police "doc:howto:packet.scheduler:act_police") Input police filter [act\_nat](/doc/howto/packet.scheduler/act_nat "doc:howto:packet.scheduler:act_nat") Stateless NAT actions [act\_mirred](/doc/howto/packet.scheduler/act_mirred "doc:howto:packet.scheduler:act_mirred") packet mirroring and redirect actions [act\_skbedit](/doc/howto/packet.scheduler/act_skbedit "doc:howto:packet.scheduler:act_skbedit")

### Filters

This is where you configure which network packet belongs to which queue/bucket. A rule used to allocate a group of IP packets to a certain classid consists of a number of classifiers (match) and one connected action (TARGET or VERDICT).

- In principle it works exactly like [netfilter rules](/docs/guide-user/firewall/netfilter-iptables/netfilter#configuration "docs:guide-user:firewall:netfilter-iptables:netfilter"), the only difference is that matches are called classifiers and the TARGET are called VERDICT in available documentation. However, since it is possible to do the filtering entirely with netfilter (almost, doesn't forget Layer 2 packets like arp), this does not really matter.

Filter (Classifier) Description kmod-sched-core kmod-sched → [cls\_flow](http://git.kernel.org/?p=linux%2Fkernel%2Fgit%2Ftorvalds%2Flinux.git%3Ba%3Dcommit%3Bh%3De5dfb815181fcb186d6080ac3a091eadff2d98fe "http://git.kernel.org/?p=linux/kernel/git/torvalds/linux.git;a=commit;h=e5dfb815181fcb186d6080ac3a091eadff2d98fe") flow classifier bla ☑ → [cls\_fw](/doc/howto/packet.scheduler/cls_fw "doc:howto:packet.scheduler:cls_fw") firewall classifier bla ☑ → [cls\_route](/doc/howto/packet.scheduler/cls_route "doc:howto:packet.scheduler:cls_route") route classifier bla ☑ → [cls\_tcindex](/doc/howto/packet.scheduler/cls_tcindex "doc:howto:packet.scheduler:cls_tcindex") tcindex classifier bla ☑ → [cls\_u32](/doc/howto/packet.scheduler/cls_u32 "doc:howto:packet.scheduler:cls_u32") u32 classifier bla ☑ → [cls\_basic](/doc/howto/packet.scheduler/cls_basic "doc:howto:packet.scheduler:cls_basic") basic classifier bla ☑ → [cls\_cgroup](/doc/howto/packet.scheduler/cls_cgroup "doc:howto:packet.scheduler:cls_cgroup") [cgroups](https://en.wikipedia.org/wiki/cgroups "https://en.wikipedia.org/wiki/cgroups") (Control Group) Classifier

#### Filter with packet scheduler

A filter is used by a classfull QDisc to determine in which bucket a packet will be enqueued. Whenever traffic arrives at a class with subclasses, it needs to be classified. Various methods may be used, one of which is filters. All filters attached to the class are called until one of them returns with a verdict. If no verdict is declared, other criteria may be considered. This behaviour varies between different QDiscs.

location match verdict/target tc what command interface target priority protocol filtertype \[ filtertype specific parameters ] flowid tc filter add dev eth0 `parent` 1: `prio` 10 `protocol` ip `u32` `match` ip `dport` 22 0xffff `classid` 1:202 change dev eth0 `parent` 1: `prio` 20 `protocol` ip `u32` `match` ip `dport` 22 0xffff `classid` 1:202 replace dev eth0 `parent` 1: `prio` 99 `protocol` ip `handle` 202 fw `flowid` 1:202

Rules:

- It is important to notice that filters reside within QDiscs - they are not masters of what happens. hä?
- A filter always belongs to a qdisc and never to a class!

Notes:

- `packet scheduler` classifying is slower then `netfilter` classifying!
- If you are using NAT, you cannot use the packet scheduler to filter for the source IP address of different internal hosts, because they are being replaced with the router's external IP address before the packets enter the packet scheduler! Actually you can use cls\_flow classifier, with option like nfct-src,nfct-dst,nfct-proto-src,nfct-proto-dst, it will retrieve original information from conntrack.

#### Filter with packet scheduler and netfilter

Using `iptables` and `tc filter`. *deprecated?* We first match wanted packets with netfilter and mark them, then match the mark (*handle 202*) and connect it with a certain classid (*flowid 1:202*):

```
iptables -t mangle -A POSTROUTING -j MARK --set-mark 202 -p udp --dport 22
tc filter add dev pppoe-dsl parent 1: prio 1 protocol ip handle 202 fw flowid 1:202
```

#### Filter with netfilter only

It is possible, more efficient and comes with the most options to use netfilter to match and then directly classify network packets:

```
iptables -t mangle -A POSTROUTING -j CLASSIFY --set-class 1:202 -p tcp --dport 22
```

Here we match the combination of source IP address, transport protocol, destination port and packet (not payload) length:

```
iptables -t mangle -A POSTROUTING -j CLASSIFY --set-class 1:303 -s 192.168.0.15 -p tcp --dport 80 -m length --length :512
```

Notes:

- You may read on the internet that you can use target CLASSIFY only on POSTROUTING, but it's not true since at least 2006, you can also use it on FORWARD and OUTPUT. From kernel 2.6.39, you are no longer restricted to the mangle table, and can classify with arptables (on OUTPUT and FORWARD)([http://comments.gmane.org/gmane.comp.security.firewalls.netfilter.devel/36340](http://comments.gmane.org/gmane.comp.security.firewalls.netfilter.devel/36340 "http://comments.gmane.org/gmane.comp.security.firewalls.netfilter.devel/36340")).
- The already broken layer7 filtering functionality was removed by [r45423](https://dev.openwrt.org/changeset/45423 "https://dev.openwrt.org/changeset/45423") and [r45424](https://dev.openwrt.org/changeset/45424 "https://dev.openwrt.org/changeset/45424").

## Approach to our own configuration

The configuration of the packet scheduler has to be tailored to your situation. Bear in mind what you are actually doing - controlling the behaviour of the packet scheduler managing the egress queue of a network interface.

We can:

1. Manipulate the order of packets leaving the egress queue (re-order/prioritize) which reduces [jitter](https://en.wikipedia.org/wiki/jitter "https://en.wikipedia.org/wiki/jitter") that occurs with congestion.
2. Divide the queue into sub-queues, and then drop packets when they are full (traffic shaping) which shares available bandwidth between traffic types and/or users.

So, let's check your situation and then let's configure your packet scheduler accordingly:

1. Do you require traffic control?
   
   - IF you generate more outgoing traffic than available upload bandwidth, STOP This will only clog your egress buffer and cause serious problems with jitter.
   
   <!--THE END-->
   
   1. IF your roommate is responsible for the excess traffic, and you cannot change this, THEN yes
   2. IF you do not generate more traffic then what can go through the line, but have problems with jitter then you could benefit from traffic prioritization.

<!--THE END-->

1. What can you configure?
   
   1. You can determine the behaviour of the packet scheduler through exactly three choices: the nesting (only in case the root qdisc is a classfull one), the particular algorithm(s) to be applied and particular parameters of the employed algorithm(s)
2. are you alone or is there traffic generated by multiple users at the same time?
   
   1. in case you are alone, the configuration could look very simple. See →[Examples](#examples "docs:guide-user:network:traffic-shaping:packet.scheduler ↵").
   2. in case of multiple users, there are couple of methods only for the nesting.
3. what kind of traffic is being generated?
   
   1. Given the fact that the packet scheduler can only do so much, it makes sense to distinguish between exactly only two types of traffic: traffic susceptible to jitter and time delay, and traffic that is not! Yes, can subdivide this two types further, but whether this makes sense, depends on the employed algorithm, on how full the egress buffer is and on your available upload bandwidth.

<!--THE END-->

- classfull or classless? → [implementation](/docs/guide-user/network/traffic-shaping/packet.scheduler.theory#implementation_of_classfull_with_2_levels "docs:guide-user:network:traffic-shaping:packet.scheduler.theory") that matches your situation best. Alone, use neither. Use classless.

## Examples

- [packet.scheduler.example1](/docs/guide-user/network/traffic-shaping/packet.scheduler.example1 "docs:guide-user:network:traffic-shaping:packet.scheduler.example1") PRIO; one user, simple prioritizing
- [packet.scheduler.example2](/docs/guide-user/network/traffic-shaping/packet.scheduler.example2 "docs:guide-user:network:traffic-shaping:packet.scheduler.example2") HTB; plain simple bandwidth sharing without concern for delay
- [packet.scheduler.example3](/docs/guide-user/network/traffic-shaping/packet.scheduler.example3 "docs:guide-user:network:traffic-shaping:packet.scheduler.example3") HFSC; several user with all sorts of traffic
- [packet.scheduler.example4](/docs/guide-user/network/traffic-shaping/packet.scheduler.example4 "docs:guide-user:network:traffic-shaping:packet.scheduler.example4") HFSC + FQ\_CODEL + FLOW classifier; basic fair sharing behind triple play box
- [packet.scheduler.example5](/docs/guide-user/network/traffic-shaping/packet.scheduler.example5 "docs:guide-user:network:traffic-shaping:packet.scheduler.example5") HTB: filter ROKU (or other steaming devices) using MAC addresses to save internet bandwidth

Note: The above examples do not make any use of UCI or anthing else, that is not OpenWrt-specific, so you can simply port them to any other Linux distributions and back.

If You are looking for **Per IP/MAC Download Speed** limiting, be sure to check [this](https://forum.openwrt.org/t/info-limiting-download-speed-based-on-mac/14092 "https://forum.openwrt.org/t/info-limiting-download-speed-based-on-mac/14092") forum post.

### Check results

To check on your results, use `tc` with or without the option `-s` `(statistics)`:

```
tc -s qdisc show dev pppoe-dsl
tc class show dev pppoe-dsl
tc filter show dev pppoe-dsl
iptables -nL -v -x -t mangle
```

## Testing

Once you managed to set up a working configuration, you need to test it. Thoroughly! Failure to do so could produce unpredictable results and/or problems.

Ideally you should set up your own mini-network that allows you to monitor and control the source, destination and traffic in between.

Produce all kinds of outgoing traffic and measure the bandwidth distribution.

Then measure and compare latency in different situations:

1. with minimal traffic, without QoS
2. with heavy traffic and congestion, without QoS
3. with minimal traffic, with QoS
4. with heavy traffic and congestion, with QoS

If you successful *please* **share your knowledge**!

## Start on boot

Make `init` restart your script every boot up.

```
cat << "EOF" > /etc/init.d/trafficc
#!/bin/sh
 
START=50
 
boot () {
        /etc/tc_hfsc.sh start
}
 
start() {
        /etc/tc_hfsc.sh start
}
 
stop()  {
        /etc/tc_hfsc.sh stop
}
EOF
chmod a+x /etc/init.d/traffic
/etc/init.d/traffic start
/etc/init.d/traffic enable
```

## Hotplug

If you disconnect your dsl-connection, the device `pppoe-dsl` will close and so will its QDisc.

The following script will restart it whenever you reconnect:

```
cat << "EOF" > /etc/hotplug.d/iface/30-trafficc
#!/bin/sh
# This script is executed as part of the hotplug event with
# HOTPLUG_TYPE=iface, triggered by various scripts when an interface
# is configured (ACTION=ifup) or deconfigured (ACTION=ifdown).  The
# interface is available as INTERFACE, the real device as DEVICE.
 
[ "$ACTION" = ifup -a "$INTERFACE" = "dsl" ] 
&& /etc/init.d/trafficc enabled && /etc/tc_hfsc.sh
EOF
```

## Statistical Data

Once your configuration is up and running, you may want to collect some statistical data:

- about bandwidth used by the different classes
- packets dropped (!)
- number of packets, packets size, which protocol was being used, source IP, ...
- the data `tc` and `iptables` dispense is of course not sooo well formated.
- use a tool to collect and parse data: [NGN](/doc/howto/ngn "doc:howto:ngn")

Note: If you do not log only your own traffic data, please mind **data privacy protection laws** to prevent you from going to jail or paying a fine.

## Tips

- Leave some bandwidth available in your packet scheduler configuration for unspecified traffic. This will help avoid blocking important low-volume traffic you may have forgetten to consider.
- Don't forget to classify ARP packets! (even if you match all packets in iptables, you won't match ARP packet, as iptables is layer 3 and ARP is layer 2)
- If you use any virtual interfaces, don't forget to configure the queue size using the txqueuelan traffic. The default is 0.

## Terminology

`Queueing Discipline (QDisc)` An algorithm that manages the queue of a device, either incoming (ingress) or outgoing (egress). Also referred to as a packet scheduler. `Root QDisc` Not an actual queuing discipline (QDisc), but rather the location where traffic control structures can be attached to an interface for egress (outbound traffic). It can contain any of the queuing disciplines (qdiscs) with potential classes and class structures. `Ingress QDisc` The location where ingress (incoming traffic) filters can be attached. For practical purposes, the ingress qdisc is merely a convenient object onto which to attach a policer to limit the amount of traffic accepted on a network interface. `Classless QDisc` A QDisc with no configurable internal subdivisions. `Classful QDisc` Contains multiple classes. Some of these classes contain a further QDisc, which may again be classful, but need not be. `Work-Conserving` A work-conserving QDisc never delays packets. It does NOT “shape” packets. `Non-Work-Conserving` A non-work-conserving QDiscs may delay packets and “shape” them. This means that they sometimes refuse to pass a packet, even though they have one available. `Tail drop Queue` See [Tail drop](https://en.wikipedia.org/wiki/Tail%20drop "https://en.wikipedia.org/wiki/Tail drop"). `Classes` Classes are sub-QDiscs which allow the user to configure QoS in more detail. Classes can contain additional classes. Classes do not have a queue, do not contain any network packets and cannot contain filters. `Leaf Class` End class without any child classes. Always contains a QDisc! In case one is not configure, the default pfifo\_fast is used. Leaf classes give unused bandwidth back to their parent class. `Inner Class` Classes which contain leaf-classes. `Parent Class` Parent class can dynamically pass bandwidth to leaf-classes. `Child Class` Class that has another class or a QDisc as parent and contains classes. `Classifier` Determines which class to send a packet. `Filter` Classification can be performed using filters. A filter contains a number of conditions which if matched, make the filter match. `Scheduling` A QDisc may, with the help of a classifier, decide that some packets need to leave earlier than others. This process is called scheduling. `Shaping` [Traffic Shaping](https://en.wikipedia.org/wiki/Traffic_shaping "https://en.wikipedia.org/wiki/Traffic_shaping") is the process of delaying packets to limit egress traffic to a maximum rate or smooth bursts. `Policing` [Traffic Policing](https://en.wikipedia.org/wiki/Traffic_policing "https://en.wikipedia.org/wiki/Traffic_policing") is the practice of dropping, marking or ignoring ingress packets that don't comply with user-defined criteria. `Filters` Filters are used by classful QDiscs to determine which class a packet will be queued to. `TCP Turbo` Yet another [Buzzword bingo](https://en.wikipedia.org/wiki/Buzzword%20bingo "https://en.wikipedia.org/wiki/Buzzword bingo") term; means the prioritization of TCP ACK-packets on the upload-side.

## Reference

- [Linux Advanced Routing &amp; Traffic Control](http://lartc.org "http://lartc.org")
- [Queueing Disciplines for Bandwidth Management](http://lartc.org/howto/lartc.qdisc.html "http://lartc.org/howto/lartc.qdisc.html")
- [tc man pages](http://lartc.org/manpages "http://lartc.org/manpages")
- [Linux Tips](http://www.bufferbloat.net/projects/bloat/wiki/Linux_Tips "http://www.bufferbloat.net/projects/bloat/wiki/Linux_Tips")
- [Source code](http://lxr.free-electrons.com/source/net/sched/ "http://lxr.free-electrons.com/source/net/sched/")
- [TCP and Linux' Pluggable Congestion Control Algorithms](http://linuxgazette.net/135/pfeiffer.html "http://linuxgazette.net/135/pfeiffer.html")
- [Packet scheduler and VLANs](http://www.mail-archive.com/lartc@mailman.ds9a.nl/msg17009.html "http://www.mail-archive.com/lartc@mailman.ds9a.nl/msg17009.html")
