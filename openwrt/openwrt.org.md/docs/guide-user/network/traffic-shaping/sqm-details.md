# SQM Details

If you want to set up SQM to minimize bufferbloat, you should start at the [SQM Howto](/docs/guide-user/network/traffic-shaping/sqm "docs:guide-user:network:traffic-shaping:sqm") page.

The remainder of this page gives some of the theory behind SQM, should you be curious about it. You should also check the [Bufferbloat site](http://bufferbloat.net "http://bufferbloat.net") for considerably more detail.

## SQM: The Longer Description

Smart Queue Management (SQM) is our name for an intelligent combination of better packet scheduling (flow queueing) techniques along with with active queue length management (AQM).

OpenWrt/LEDE has full capability of tuning the network traffic control parameters. If you want to do the work, you can read the full description at the [QoS HOWTO](/docs/guide-user/network/traffic-shaping/packet.scheduler "docs:guide-user:network:traffic-shaping:packet.scheduler"). You may still find it useful to get into all the details of classifying and prioritizing certain kinds of traffic, but the SQM algorithms and scripts (fq\_codel, cake, and sqm-scripts) require a few minutes to set up, and work as well or better than most hand-tuned classification schemes.

Current versions of OpenWrt/LEDE have SQM, fq\_codel, and cake built in. These algorithms were developed as part of the [CeroWrt](http://www.bufferbloat.net/projects/cerowrt/wiki "http://www.bufferbloat.net/projects/cerowrt/wiki") project. They have been tested and refined over the last four years, and have been accepted back into OpenWrt, the Linux Kernel, and in dozens of commercial offerings.

To use SQM in your router, use the **SQM QoS** tab in the web interface. This will optimize the performance of the WAN interface (generally eth0) that connects your router to the ISP/the Internet. There are three sub-tabs in the **SQM QoS** page that you may configure:

- **Basic Settings** sets the download and upload speeds of the uplink. Be sure to read about the adjustment you should make when entering speeds.
- **Queue Discipline** selects which queueing discipline to use on the WAN link. The default settings are good in almost every case.
- **Link Layer Adaptation** calculates the proper overheads for WAN links such as DSL and ADSL. If you use any kind of DSL link, you should review this section.

### SQM: Basic Settings Tab

Set the **Download** and **Upload** speeds in the web GUI for the speed of your Internet connection. To do this

1. Get a speed measurement. See [Preparations](#preparationmeasure_your_current_speed_and_latency "docs:guide-user:network:traffic-shaping:sqm-details ↵") above.
2. Set Download and Upload according to those link speeds. See examples below.
3. Be sure to check the **Enable** box and set the Interface for your WAN interface.
4. (Optional) Read [A little bit about tuning SQM](#a_little_bit_about_tuning_sqm "docs:guide-user:network:traffic-shaping:sqm-details ↵") above.

**Example 1:** If your your provider boasts “7 megabit download/768 kbps upload”, set **Download** to 5950 kbit/s and **Upload** to 653 kbit/s. Those numbers are 85% of the advertised speeds.

**Example 2:** If you have measured your bandwidth with a speed test (be sure to disable SQM first), set the **Download** and **Upload** speeds to 95% of those numbers. For example, if you have measured 6.2 megabits down and 0.67 megabits up (6200 kbps and 670 kbps, respectively), set your **Download** and **Upload** speeds to 95% of those numbers (5890 and 637 kbps, respectively)

**Basic Settings - the details...**

SQM is designed to manage the queues of packets waiting to be sent across the slowest (bottleneck) link, which is usually your connection to the Internet. The algorithm cannot automatically adapt to network conditions on DSL, cable modems or GPON without any settings. Since the majority of ISP provided configurations for buffering are broken today, you need take control of the bottleneck link away from the ISP and move it into the router so it can be fixed. You do this by entering link speeds that are a few percent below the actual speeds.

Use a speed test program or web site like the [DSL Reports Speed Test](https://www.dslreports.com/speedtest "https://www.dslreports.com/speedtest") to get an estimate of the actual download and upload values. After setting the initial Download and Upload entries, you should feel free to try the suggestions at [A little about tuning SQM](#a_little_about_tuning_sqm "docs:guide-user:network:traffic-shaping:sqm-details ↵") above to see if you can further increase the speeds.

*Note:* sqm-scripts shaper interprets the bandwidth values as gross bandwidth, while speedtests typically report TCP/IPv4 good-put. So how to estimate what speedtest result is a good match for a given shaper bandwidth? Just use the following formula and plug in the correct values:

`${ShaperBandwidth} * (${pMTU} - ${IPv4Header} - ${TCPHeader}) / (${pMTU} + ${Overhead})`

with: pMTU typically around 1500, IPv4Header = 20 bytes, TCPHeader = 20 bytes, Overhead the value you specified in the shaper (or typically 14 bytes if you did not explicitly configured this)

E.g.: for a DOCSIS link with 18 bytes overhead you at best get a 100-100\*(1500-20-20)/(1500+18) = 3.82% lower good-put than gross bandwidth.

### SQM: Queue Discipline Tab

The **Queue Discipline** tab controls how packets are prioritized for sending and receipt. The default settings shown here work very well for nearly all circumstances. Those defaults are:

- *cake* queueing discipline
- *piece\_of\_cake.qos* queue setup script
- *ECN* for inbound packets
- *NOECN* for outbound packets
- The default values of the **Advanced Configuration** work fine

**Queueing Discipline - the details...**

The default *cake* queueing discipline works well in virtually all situations. Feel free to try out other algorithms to see if they work better in your environment.

The default *piece\_of\_cake.qos* script has a traffic shaper (the Queueing Discipline you select) and three classes with different priorities for traffic. This provides good defaults.

Explicit Congestion Notification (ECN) is a mechanism for notifying a sender that its packets are encountering congestion and that the sender should slow its packet delivery rate. Instead of dropping a packet, fq\_codel marks the packet with a congestion notification and passes it along to the receiver. That receiver sends the congestion notification back to the sender, which can adjust its rate. This provides faster feedback than having the router drop the received packet. *Note:* this technique requires that the TCP stack on both sides enable ECN.

At low bandwidth, we recommend that you turn ECN off for the Upload (outbound, egress) direction, because fq\_codel handles and drops packets before they reach the bottleneck, leaving room for more important packets to get out. For the Download (inbound, ingress) link, we recommend you turn ECN on so that fq\_codel can inform the local receiver (that will in turn notify the remote sender) that it has detected congestion without loss of a packet.

The “Dangerous Configuration” options allow you to change other parameters. They are not heavily error checked, so be careful that they are exactly as shown when you enter them. As with other options in this tab, it is safe to leave them at their default. They include:

- **Hard limit on ingress queues:** This is a limit the ingress (inbound) queues, measured in packets. Leave it empty for default.
- **Hard limit on egress queues:** This is a limit on the egress (outbound) queues. Similar to the ingress hard limit.
- **Latency target for ingress:** The codel algorithm specifies a target, expressed in msec. Leave empty or use “auto” for a calculated compensation for slow links (less than 4 mbps). Use “default” for the qdisc's default.
- **Latency target for egress:** The target setting for the egress queues. Similar to the ingress latency target.
- **Advanced option string for ingress:** This string passes additional parameters to the ingress queueing discipline. There is no error checking, so enter carefully. Empty is the default.
- **Advanced option string for egress:** Similar to the ingress advanced option string.

Please note that if any of the “Advanced option strings” contain values that are not interpreted by the selected qdisc, sqm will \_silently_ fail to instantiate, so make sure to always check these two field on changing the qdisc. Also run “tc -d qdisc ; tc -s qdisc” on the router's command line to check whether the expected shapers (ingress/egress) were instantiated, “not heavily error checked” for these two fields is emphatic for “not at all” and the placement under “Dangerous Configuration” quite fitting.

### SQM: Link Layer Adaptation Tab

The purpose of Link Layer Adaptation is to give the shaper more knowledge about the actual size of the packets so it can calculate how long packets will take to send. When the upstream ISP technology adds overhead to the packet, we should try to account for it. This primarily makes a big difference for traffic using small packets, like VOIP or gaming traffic. If a packet is only 150 bytes and say 44 bytes are added to it, then the packet is 29% larger than expected and so the shaper will be under-estimating the bandwidth used if it doesn't know about this overhead.

Getting this value exactly right is less important than getting it close, and over-estimating by a few bytes is generally better at keeping bufferbloat down than underestimating. With this in mind, to get started, set the Link Layer Adaptation options based on your connection to the Internet. The general rule for selecting the Link Layer Adaption is:

- Choose **ATM: select for e.g. ADSL1, ADSL2, ADSL2+** and set the Per-packet Overhead to 44 bytes if you use any kind of DSL/ADSL connection to the Internet other than a modern VDSL high speed connection (20+Mbps). In other words if you have your internet service through a copper telephone line at around 1 or 2Mbps.
- Choose **Ethernet with overhead: select for e.g. VDSL2** and set the Per-packet Overhead to 34 if you know you have a VDSL2 connection (this is sometimes called Fiber to the Cabinet, for example in the UK). VDSL connections operate at 20-100Mbps over higher quality copper lines. If you are sure that PPPoE is not in use, you can reduce this to 26.
- If you have a cable modem, with a coaxial cable connector, you can try 22 bytes, or see the **Ethernet with Overhead** details below. If your shaper rate is set greater than 760 Mbps set overhead 42 (mpu 84) as the ethernet link to the modem now affects worst case per-packet-overhead.
- Choose **Ethernet with overhead** if you have an actual Fiber to the Premises or metro-Ethernet connection and set the Per-Packet Overhead to 44 bytes. This can be reduced somewhat for example if you know you are not using VLAN tags, but will usually work well.
- Choose **none (default)** if you have some reason to not include overhead. All the other parameters will be ignored.

If you are not sure what kind of link you have, first try using Ethernet with Overhead and set 44 bytes. Then run the Quick Test for Bufferbloat. If the results are good, you’re done. If you get your internet through an old-style copper wired phone line and your speeds are less than a couple of megabits, you have ATM so see above for the ATM entry. If you have a slow connection such as less than 2Mbps in either direction and/or you regularly use several VOIP calls at once while gaming etc (so that more than 10 to 20% of your bandwidth is small packets) then it can be worth it to tune the overhead more carefully, see below for extra details.

An important exception to the above rules is when the bandwidth limit is set by the ISP's traffic shaper, not by the equipment that talks to the physical line. Let's consider an example. The ISP sells a 15 Mbit/s package and enforces this limit, but lets the ADSL modem connect at whatever speed is appropriate for the line. And the modem “thinks” (as confirmed in its web interface) that 18 Mbps is appropriate. In this case, the ATM Link Layer Adaptation is likely inappropriate, because the ISP's shaper is the only relevant speed limiter, and it does not work at the ATM level. In fact, it is more likely to work at the IP level, which means that **none** is the appropriate setting. EDIT: This section is confused and none is ALMOST NEVER the correct overhead (however there are situations where the overhead setting is not all that important). As a rule of thumb to be on the save side set the shaper overhead to &gt;= max(overhead along the path) and the shaper rate to ⇐ min(rate along the path). TO stich with the above example, even if @15Mbps with full sizes packets (MTU ~1500) the ISP shaper might be the relevant bottleneck defining the relevant overhead, once the link is saturated with smaller packets this likely reverses and the ATM link becomes relevant for the per-packet overhead. But to repeat, underestimating the overhead can easily result in increased latency under load, while overestimating it (within reason) only costs a little potential throughput, so if in doubt over estimate the per packet overhead; hence the recommendation to set it to 44 or 48 and forget about it.

**Link Layer Adaptation - the details…**

Various link-layer transmission methods affect the rate that data is transmitted/received. Setting the Link Layer properly helps SQM make accurate predictions, and improves performance. There are several components of overhead, the first comes from the basic transport technology itself:

- **ATM:** It is especially important to set the Link Layer Adaptation on links that use ATM framing (almost all DSL/ADSL links do), because ATM adds five additional bytes of overhead to a 48-byte frame. Unless the SQM algorithm knows to account for the ATM framing bytes, short packets will appear to take longer to send than expected, and will be penalized. For true ATM links, one often can measure the real per-packet overhead empirically, see [https://github.com/moeller0/ATM\_overhead\_detector](https://github.com/moeller0/ATM_overhead_detector "https://github.com/moeller0/ATM_overhead_detector") for further information how to do that. Getting the mpu right is tricky since ATM/AAL5 can either include the FCS or not, but setting mu to 96 should be save (that results in 2 ATM cells).
- **Ethernet with Overhead:** SQM can also account for the overhead imposed by *VDSL2* links - add 22 bytes of overhead (mpu 68). Cable Modems (*DOCSIS*) set both up- and downstream overhead to 18 bytes (6 bytes source MAC, 6 bytes destination MAC, 2 bytes ether-type, 4 bytes FCS), to allow for a possible 4 byte VLAN tag it is recommended to set the overhead to 18 + 4 = 22 (mpu 64); if you want to set shaper rates greater than 760 Mbps set overhead 42 (mpu 84) as now the worst case per-packet-overhead is on the ethernet link to the modem. For *FTTH* the answer is less clear cut, since different underlaying technologies have different relevant per-packet-overheads; however underestimating the per-packet-overhead is considerably worse for responsiveness than (gently) overestimating it, so for *FTTH* set the overhead to 44 (mpu 84) unless there is more detailed information about the true overhead on a link available.
- **None:** All shaping below the physical gross-rate of a link requires correct per-packet overhead accounting to be precise, so **None** is only useful if approximate shaping is sufficient, say if you want to clamp a guest network to at best ~50% of the available capacity or similar tasks, but even then configuring an approximate correct per-packet-overhead is recommended (overhead 44 (mpu 84) is a decent default to pick).

In addition to those overheads it is common to have VLAN tags (4 extra bytes) or PPPoE encapsulation (8 bytes) or even more exotic issues such as ipv4 provided over ipv6 in the DS-Lite scheme (where ipv4 packets experience a 40 byte ipv6 header overhead). Because of these variables and the fact that overestimation is generally better, we offer the default suggested sizes in the first table).

The “Advanced Link Layer” choices are relevant if you are sending packets larger than 1500 bytes. This would be unusual for most home setups, since ISPs generally limit traffic to 1500 byte packets. UPDATE 2017, most recent link technologies will transfer complete L2 ethernet frames including the FCS; that in turn means that they will effectively all inherit the ethernet minimal packet size of 64 bytes. It is hence recommended to set tcMPU to 64 (the actual values depends on the link technology and ranges from 0-96bytes). Note that most (but not all) ATM based links will exclude the FCS and hence probably do not require that setting. As of March 2017 sqm-scripts does not evaluate tcMPU if cake is selected as “link layer adaptation mechanism”. In that case add “mpu 64” to the advanced option strings for ingress and egress. As of middle of 2018 sqm-scripts will try to evaluate tcMPU for cake also. Getting the mpu right seems not overly important at first since it only affects the accounting of the smallest of packets and will only be relevant if a link is saturated. But often especially DOCSIS/cable links are close to an 1/40 asymmetry between up- and downstream, and that is the same 1/40 ratio between data and reverse ACK traffic rates/volumes for TCP (think TCP Reno), and that in turn means that when saturating the Downstream-direction with a big TCP-download the upstream direction will als be close to saturated with ACK packets, and pure ACK packets can actually fall under the mpu limit resulting in both a saturated link and mostly small packets that need to be accounted with a size of &gt;= mpu. In short getting the mpu right is not a purely theoretical exercise.

Please note that as of middle 2018 cake, and cake only, will try to interpret any given overhead to be applied on top of IP packets, all other qdiscs (and cake if configured with the “raw” keyword) will add the specified overhead on top of the overhead the kernel already accounted for. This seems confusing, because it is ;) so if in doubt stick to cake.

Unless you are experimenting, you should use the default choice for the link layer adaptation mechanism. This will select cake if cake is used as qdisc other wise tc\_stab.

Now, the real challenge with the shaper gross rate and the per-packet-overhead is that they are not independent; say a link has a true gross rate of 100 rate-units and a true per-packet-overhead of 100 bytes (numbers are unrealistic, but allow for easier math) and an payload size of 1000 bytes, the expected throughput at the ethernet payload level is:

```
gross-rate * ((payload-size) / (pay_load-size + per-packet-overhead))
100 * ((1000) / (1000+100)) = 90.91
```

now, any combination of gross-shaper rate and per-packet-overhead, that results in a throughput ⇐ 90.91 will effectively remove bufferbloat (that is not fully correct for downstream shaping, but the logic also holds if we aim for say, 90% of 90.91 instead). so in the extreme we can set the per-packet-overhead to 0 as long as we also set the shaper gross speed to 90.91:

```
90.91 * (1000+0) / (1000) = 90.91
90.91 * ((1000) / (1000+0)) = 90.91
```

or the other way around, if we set the per-packet-overhead to an absurd 1000 bytes, we still will see the expected throughput if we also configure the shaper gross rate at 182:

```
90.91 * (1000+1000) / (1000) = 181.82
181.82 * ((1000) / (1000+ 1000)) = 90.91
```

To sanity check whether a given combination of gross rate and per-packet-overhead seems sane (say, there is too little information about the true link properties available to make an educated guess) ione needs to repeat speedtests at different packet sizes. The following stanza added to /etc/firewall.user will use OpenWrt's MSS clamping to bidirectionally force the MTU to 216 (as e.g. Macosx will not accept smaller MSS values by default)

```
# special rules to allow MSS clamping for in and outbound traffic                                                                   
# use ip6tables -t mangle -S ; iptables -t mangle -S to check                                                                       
forced_MSS=216                                                                                                                      
                                                                                                                                    
# affects both down- and upstream, egress seems to require at least 216                                                             
iptables -t mangle -A FORWARD -p tcp -m tcp --tcp-flags SYN,RST SYN -m comment --comment "custom: Zone wan MTU fixing" -j TCPMSS --set-mss ${forced_MSS}                                                                                                               
ip6tables -t mangle -A FORWARD -p tcp -m tcp --tcp-flags SYN,RST SYN -m comment --comment "custom6: Zone wan MTU fixing" -j TCPMSS  --set-mss ${forced_MSS}     
```

Now, if we plug this into the numbers from above we get (note, MSS is the TCP/IP payload size, which in the IPv4 case is 40 bytes smaller than the ethernet payload):

```
100 * ((216+40) / (216+40+100)) = 68.3544303797 # as expected the throughput is smaller, since the fraction of overhead is simply larger
```

now, if we underestimated the per-packet-overhead we get:

```
90.91 * ((216) / (216 +0)) = 90.91
```

since 90 &gt;&gt; 68 we will admit too much data into the link and will encounter bufferbloat.

And the reverse error:

```
181.82 * ((216) / (216 + 1000)) = 32.2969736842
```

here we do not get bufferbloat (since 32 &lt;&lt; 68) but we sacrifice way to much throughput.

So the proposal is to “optimize” shaper gross-rate and per-packet-overhead at the normal MSS value and then measure at a considerable smaller MSS to confirm whether both bufferbloat and throughput are still acceptable.

Please note one additional challenge here: testing a saturating load with small(er) packets will result in a considerably higher rate of packets the router needs to process (e.g. if you switch from MSS 1460 to MSS 146 you can expect ~10 times as many packets) and not all routers are capable of saturating a link with small packets, so for this test it is essential to confirm that the router does not run out of CPU cycles to process the data and as a consequence that the measured throughput is close to the theoretically expected one.

Please note to compare throughput measured with on-line speedtests with the theoretical prediction the following approximate formula can be used:

```
gross-rate * ((IP-packet-size - IP-header-size - TCP-header-size) / (IP-packet-size + per-packet-overhead))
e.g. for an ethernet link (effectively 38B overhead) with a VLAN tag (4B) and PPPoE (6+2=8B), IPv4 (without options: 20B), TCP (with rfc 1323 timestamps: 20+12=32B) 
one can expect ~93% throughput
100 * ((1500 - 8 - 20 - 20 - 12) / (1500 + 38 + 4)) = 93.39
```

## Selecting the optimal queue setup script

**TL;DR:** Use cake, not fq\_codel.

*Note:* As of early 2017, cake is an improvement both in speed and capabilities over the original fq\_codel algorithm first deployed in May 2012. cake is in every way better than fq\_codel. The following description is preserved for historical information.

The right queue setup script (simple, hfsc\_lite, ...) for you depends on the combination of several factors like the ISP connection's speed and latency, router's CPU power, wifi/wired connection from LAN clients etc.. You will need likely to experiment with several scripts to see which performs best for you. Below is a summary of real-life testing with three different setup scripts.

This was tested with WNDR3700 running trunk with kernel 4.1.16 and SQM 1.0.7 with simple, hfsc\_lite and hfsc\_litest scripts with SQM speed setting 85000/10000 (intentionally lower than ISP connection speed), 110000/15000 (that should exceed the ISP connection speed and also totally burden the router's CPU), as well as 110000/15000 using Wifi.

```
           wired 85/10             wired 110/15         Wifi 110/15
         Download/Up/Latency     Download/Up/Latency    Download/Up/Latency
Simple       19.5/2.1/18.5           21.2/2.7/19          11.0/3.0/21
hfsc_lite    20.7/2.2/19.5           25.0/2.7/50          19.0/2.9/35
hfsc_litest  20.7/2.2/18.7           25.0/2.7/52          18.0/2.8/35
```

(“flent” network measurement tool reports the overview as average of the 4 different traffic classes, so the total bandwidth was 4x the figures shown in the above table that shows “per-class” speed. The maximum observed combined download+upload speed was ~110 Mbit/s.)

With wired 85/10 the experience was almost identical with all four qdisc strategies in SQM. Approx. 20 Mbit/s download / 2.1 Mbit/s upload and 19 ms latency shown in the flent summary graph.

With wired 110/15 there was more difference. Interestingly “simple” kept latency at 20 ms, while with the other 3 strategies latency jumped to 50 ms after ~20 seconds. (Might be a flent peculiarity, but still mentioning it.) “simple” kept low latency at 19 ms and 21 Mbit/s download, while the other 3 strategies had 50 ms latency while having 24-25 Mbit/s download per class.

But when the LAN client connected with Wifi to the router with 110/15 limits, “simple” lost its download speed. Latency was still low, but download speed was really low, just half of the normal. Likely the CPU power required for wifi limited the CPU available for other processing and the router choked.

At least on the tested setup, the download speed using wifi and SQM “simple” was half of that what could achieved with hfsc\_lite+wifi, or simple+wired.

The key message of this note is that the right setup script for you will depend on your connection, your router and your LAN clients. It pays off to test the various setup scripts.

## Making cake sing and dance, on a tight rope without a safety net (aka advanced features)

**By now, we hope the SQM message has been clear: stick to the defaults and use cake.**

But cake offers new options that make it the nicest and most complete shaper for a typical home network: Per-Host Isolation in the presence of network address translation (NAT), so that all hosts' traffic shares are equal. (You can choose to isolate per-internal or per-external host IP addresses, but typically fairness by internal host IPs seems in bigger demand.)

A quick aside about Network Address Translation (NAT): ISPs usually assign only one external IP address to each customer. The home router assigns unique internal addresses for each computer in the home, and uses a technique called NAT (or “masquerading”) to rewrite those internal IP addresses and ports to work across the single external address.

NAT works pretty well, too, but causes problems when shaping traffic. Since all the traffic going to/from the ISP has the same external IP address, cake treats every traffic *flow* (or *stream* or *connection*) identically: a single Netflix stream to one internal computer gets the same bandwidth as a single BitTorrent stream to another. But since a BitTorrent client can start many BitTorrent streams, the second machine can get “more than its share” of the capacity.

Recent versions of cake (in OpenWrt/LEDE 17.01.0 and newer) have two options that avoid this problem:

1. Cake can now access the kernel's internal translation tables and get access to the true source and destination addresses of incoming and outgoing packets;
2. Cake can use the information about true source and destination addresses to control traffic from/to internal external hosts by true IP address, not per-stream.

Cake's original isolation mode was based on *flows*: each stream was isolated from all the others, and the link capacity was divided evenly between all active streams independent of IP addresses. **More recently Cake switched** to `triple-isolate`, which will first make sure that no internal *or* external host will hog too much bandwidth and then will still guarantee for fairness for each host. In that mode, Cake mostly does the right thing. It would ensure that no single stream and no single host could hog all the capacity of the WAN link. However, it can't prevent a BitTorrent client - with multiple connections - from monopolizing most of the capacity. And running speedtests from multiple internal hosts to the same speedtest server can give unpredictable results.

Cake now uses the true source/destination address information to create Per-Host Isolation, and dynamically distributes the available bandwidth fairly between the currently-active IP addresses. So a single Netflix stream to one host ideally gets just as much capacity as all the BitTorrent traffic destined to another.

**To enable Per-Host Isolation** Add the following to the “Advanced option strings” (in the *Interfaces → SQM-QoS* page; *Queue Discipline* tab, look for the *Dangerous Configuration* options):

For queueing disciplines handling incoming packets from the internet (internet-**ingress**): `nat dual-dsthost`

For queueing disciplines handling outgoing packets to the internet (internet-**egress**): `nat dual-srchost`

Please note the addition of the ingress keyword to the “Advanced option strings”

Regarding cake's “ingress” keyword: Conceptually a traffic shaper will drop and/or delay packets in a way that the rate of packets leaving the shaper is smaller or equal to the configured shaper-rate. This works well on egress, but for post-bottleneck shaping as is typical for the internet ingress (the download direction) this is not ideal. For this kind of shaping we actually want to make sure that there is as little as possible packet-backspill into the upstream devices buffers (if those buffers where sized and managed properly we would not need to shape on ingress in the first place). And to avoid backspill we need to make sure that the combined rate of packets coming into the upstream device (rarely) exceeds the bottleneck-link's true capacity. The “ingress” keyword instructs cake to basically try to keep the incoming packet rate ⇐ the configured shaper rate. This leads to slightly more aggressive dropping, but this also ameliorates one issue we have with post-bottleneck shaping, namely the inherent dependency of the required bandwidth “sacrifice” with the expected number of concurrent bulk flows. As far as I can tell the more aggressive dropping in ingress-mode automatically scales with the load and hence it should make it possible to get away with configuring an ingress-mode rate closer to the true bottleneck-rate, and actually also get higher throughput if only few bulk flows are active. For further reference I recommend to have a look at cake's source at [https://github.com/dtaht/sch\_cake?files=1](https://github.com/dtaht/sch_cake?files=1 "https://github.com/dtaht/sch_cake?files=1")

With the 'ingress' keyword, the above example for incoming packets from the internet would be `nat dual-dsthost ingress`

**Notes:**

- “Internet-Ingress” is the shaper instance handling traffic coming from the internet, “into” the router.

<!--THE END-->

- “Internet-Egress” is the shaper instance handling traffic towards the internet, “from” the router.

<!--THE END-->

- Enter these strings carefully and exactly. If things do not seem to work, your first troubleshooting step should be to clear these advanced option strings!

<!--THE END-->

- At some point in time, these advanced cake options may become better integrated into luci-app-sqm, but for the time being this is the way to make cake sing and dance…

<!--THE END-->

- This discussion assumes SQM is instantiated on an interface that directly faces the internet/WAN. If it is not (e.g., on a **LAN port**) the meaning of ingress/egress **flips** and now your **Download** has to put it in **Upload speed (kbit/s) (egress)** and your **Upload** has to put it in **Download speed (kbit/s) (ingress)**, also **don't have to add the** `nat` **option** on **LAN interfaces** (this option should only be used in the **WAN interface**) or **Per-Host Isolation** stops working. In that case, just add in **egress queueing disciplines** `dual-dsthost ingress` and in **ingress queueing disciplines** `dual-srchost` (remember that ingress/egress **flips** on **LAN interfaces**).

## FAQ

**SQM seems to be confused, my measured download speed is actually close to my configured upload speed:**

Depending on the directionality of the interface with the directionality towards the internet that is not unexpected; try to flip the values in the GUI and see whether measured values better match your expectation.

**SQM seems confused, both download and upload bandwidth in speedtests measure around the lower value of the configured download and upload bandwidth:**

This situation can arise when using a router that uses one of its switch ports as the WAN port and only has one CPU to switch port; assuming the cpu port to the switch is eth0 and VLAN 2 is used for WAN, VLAN 1 for LAN;in that case the appropriate WAN interface from sqms perspective is eth0.2. Instantiating sqm on eth0 (note the lack of the VLAN tags) will make sure that eth0.2 is effectively throttled to min(download\_bandwidth, upload\_bandwidth), as eth0 egress shaping will affect both internet egress (via eth0.2 egress) as well as internet ingress (via eth0.1 egress). In short make sure to instantiate sqm on the real wan interface if internet shaping is intended...

**How to figure out which interface is actually connected to the internet:**

From the **Network→Interfaces** GUI From the Command Line The WAN port box shows the  
name of the WAN interface:  
[![](/_media/media/docs/lede-wan-port-small.png)](/_detail/media/docs/lede-wan-port-small.png?id=docs%3Aguide-user%3Anetwork%3Atraffic-shaping%3Asqm-details "media:docs:lede-wan-port-small.png") Run the following from the router's command line:

`ifstatus wan | grep -e l3_device`

The command above might display:

`“l3_device”: “eth0”,`

which means `eth0` is the WAN interface. Select it in **Network→SQM QoS** GUI,  
if you want the typical “shape my internet access” configuration.

**Measured goodput in speed tests with SQM is considerably lower than without**

Traffic shaping is relative CPU intensive, not necessarily as sustained load. To be able to keep buffering in the device driver low SQM only releases small amounts of packets into the next layer (often the device driver). To keep throughput up, the qdisc now only has the small time window from handing the last packets up to the diver and the point these packets will be transmitted at the desired shaper rate to hand more packets to the driver. If SQM does not get access to the CPU inside that time window, it will effectively not use some nominal transmit opportunities, and hence throughput will stay below the configured rate.

One sign of such under-throughput by CPU-overload is that the CPU rarely falls idle. Aquick an dirty test for that is to run \`top -d 1\` and watch the %idle column in one of the upper rows, if that gets too close to 0% (you need to generate a load, like a speedtest and while this test runs observe the %idle column and try to get a feel what the minimum %idle is that shows up) sqm is likely CPU bound. Since that test will only show aggregate usage over full second intervals, but SQM operates on smaller time windows, often an observed min %idle of 10% already indicates CPU limitations to sqm. Please note that for multicore routers reading %idle gets more complicated, as 50% idle on a dual core, might mean one core is fully loaded and one is idle (bad if sqm runs on the overloaded core) or that both cores are loaded only 50%. Please note that htop (\`opkg update ; opkg install htop\`) has a per CPU stats display that can be toggled by pressing t and includes the traditional mode as well:

```
top - 11:29:29 up 12 days, 14:42,  0 users,  load average: 0.06, 0.02, 0.00
Tasks: 158 total,   1 running, 157 sleeping,   0 stopped,   0 zombie
%Cpu0  :  2.0 us,  0.0 sy,  0.0 ni, 97.0 id,  0.0 wa,  0.0 hi,  1.0 si,  0.0 st
%Cpu1  :  3.0 us,  1.0 sy,  0.0 ni, 93.1 id,  0.0 wa,  0.0 hi,  3.0 si,  0.0 st
```

This should allow to eye-ball whether a single core might be pegged. In this example without load, both CPUs idle &gt; 90% of the time, no sign of any overload ;) Pressing F1 in htop, shows the color legend for the CPU bars, and F2 Setup → Display options → Detailed CPU time (System/IO-Wait/Hard-IRQ/Soft-IRQ/Steal/Guest), allows to enable the display of the important (for network loads) Soft-IRQ category.

Also to make things even more complicated, CPU power/frequency scaling (to save power) can interfere negatively with SQM. Probably due to SQM's bursty nature it might not be recognised by the power governor and the CPU (that at 100% is capable of shaping to the desired sqm rate) gets too slow to service SQM in time and throughput suffers, and due to the burstyness the governor might never realise it should scale frequency back up. This can be remedied by trying to optimise the transition rules for up-scaling frequency/power or by switching to a non-scaling governor. The former requires a bit of trial and error but maintains power saving, while the latter probably is easier to achieve and hence might be a good way to figure out whether power saving might be an issue in the first place. @experts, please feel free to elaborate on which power save settings are worth exploring.

**How do I get cake to consider IPv6 traffic in a 6in4 tunnel as separate flows?**

See [6in4 with cake config](/docs/guide-user/network/ipv6/ipv6_henet#in4_with_cake_sqm "docs:guide-user:network:ipv6:ipv6_henet")

## Troubleshooting SQM

The commands below help to collect the information required to debug problems with SQM. To use them, [SSH into the router,](/docs/guide-quick-start/sshadministration "docs:guide-quick-start:sshadministration") and enter each line, one at a time. Then copy/paste the entire terminal session in your report.

Display all currently defined sqm instances (enabled and disabled):

```
  cat /etc/config/sqm
```

Display all information about the WAN interface:

```
  ifstatus wan
```

Display relatively detailed output of the process of stopping and starting SQM:

```
  SQM_DEBUG=1 SQM_VERBOSITY_MAX=8 /etc/init.d/sqm stop ; SQM_DEBUG=1 SQM_VERBOSITY_MAX=8 /etc/init.d/sqm start
```

Display the log file created by the commands above:

```
  cat /var/run/sqm/*debug.log
```

Display the logread output of the sqm start and stop:

```
  logread | grep SQM
```

Display the *detailed* output of linix's `tc` (traffic control) system:

```
  tc -d qdisc
```

Display the *statistics* output of `tc` system:

```
  tc -s qdisc
```

Now generate some traffic through the router (and the SQM instance). The easiest way to do this used to be to run the DSLReports Speedtest ([http://www.dslreports.com/speedtest](http://www.dslreports.com/speedtest "http://www.dslreports.com/speedtest")) but nowadays the waveform bufferbloat test ([https://www.waveform.com/tools/bufferbloat](https://www.waveform.com/tools/bufferbloat "https://www.waveform.com/tools/bufferbloat")) or cloudflare's capacity test ([https://speed.cloudflare.com](https://speed.cloudflare.com "https://speed.cloudflare.com")) are preferable.

Now display the `tc` statistics again: this shows the increased traffic the SQM instance should have seen.

```
  tc -s qdisc
```

Finally, copy/paste the entire session into your report.

### How-To: setting up SQM on a WAN link

Now, this is quite a lot of information to ponder, but most of it is rather for additional education and not strictly necessary for getting things going. So here is a quick recipe for iteratively getting SQM configured reasonably. I will take my rather boring (VDSL2/PTM/PPPoE) link as example here (this assumes that luci-app-sqm and sqm-scripts are installed already):

**Define sane starting values**

1. WiFi drags in its own set of challenges for throughput and latency under load, to avoid conflating these issues with WAN bufferbloat, connect a computer/laptop/tablet to the OpenWrt/SQM router via ethernet; make sure that the ethernet link-rate is not (much) slower than the maximum of the two WAN rates.
2. With sqm disabled (\`/etc/init.d/sqm stop\`) run a few of your preferred capacity tests to get an idea about the achievable throughout without sqm's quite expensive traffic shaping. I like both waveform's bufferbloat test ([https://www.waveform.com/tools/bufferbloat?test-id=226d9b8a-180b-4fb7-bb92-9f0294575369](https://www.waveform.com/tools/bufferbloat?test-id=226d9b8a-180b-4fb7-bb92-9f0294575369 "https://www.waveform.com/tools/bufferbloat?test-id=226d9b8a-180b-4fb7-bb92-9f0294575369")) as well as cloudflare's tests ([https://speed.cloudflare.com](https://speed.cloudflare.com "https://speed.cloudflare.com")) as both not only report the achieved throughput, but also offer estimates for the latency under load or bufferbloat.
3. Figure out your contracted maximum rates your ISP promised for the download and the upload direction. In my case these rates are 100/40 Mbps (in a small twist my ISP contractually is obligated to specify net throughput rates, not gross rates, but we really do not care much for our purpose 100/40 is just fine we only take these as starting points anyway).
4. Figure out a reasonable estimate of the per-packet-overhead, or simply follow the recommendations and set this to 44 bytes (and MPU to 84 bytes)
5. Figure out the linux interface to use. The following command `ifstatus wan | grep -e l3_device` should return the name of the interface to instantiate sqm on, in my case this returns `“l3_device”: “pppoe-wan”`

Armed with that information we can create the starting sqm-scripts config file (or rather edit the existing one at `/etc/config/sqm`, I prefer to use the nano editor for that but use what ever tickles your fancy). The goal is to start out with a setting that should in all likelihood be on the save side, so for both ingress and egress capacity/rate we are going to select 50% of the maximum of the rates from the capacity tests and the contractual rates, in my case that is 50/20 Mbps or 50000/20000 Kbps (sqm's config requires rates in Kbps) and we are going to remember maximum of the rates from the capacity tests and the contractual rates as 100% for download and upload.

```
config queue 'eth1'
	option enabled '1'
	option interface 'pppoe-wan'
	option download '50000'
	option upload '20000'
	option debug_logging '1'
	option verbosity '5'
	option qdisc 'cake'
	option script 'piece_of_cake.qos'
	option qdisc_advanced '1'
	option squash_dscp '0'
	option squash_ingress '0'
	option ingress_ecn 'ECN'
	option egress_ecn 'ECN'
	option qdisc_really_really_advanced '1'
	option itarget 'auto'
	option etarget 'auto'
	option iqdisc_opts 'ingress nat dual-dsthost'
	option eqdisc_opts 'nat dual-srchost'
	option linklayer 'ethernet'
	option overhead '42'
	option linklayer_advanced '1'
	option tcMTU '2047'
	option tcTSIZE '128'
	option linklayer_adaptation_mechanism 'default'
	option tcMPU '84'
```

Based on that configuration we can now iteratively increase the shaper rates until we notice an increase in latency under load. To make things simpler we start by keeping the download rate at 50% and first try to find the highest upload rate that avoids noticeable bufferbloat. Once we found that rate we will set the upload rate to that value and repeat the procedure for the download rate. To measure bufferbloat we will simply use the waveform or cloudflare tests and notice when the latency under loads starts to differ noticeably from the idle latency (at which point the rate is set too high). To expedite the search we will do a binary search in the range from our 50% to 100% of the rate we deduced as sane starting values.

#### SQM disabled capacity test

Waveform results (firefox): A: 13 ms: +27 ms: +12 ms Capacity:

```
Download: 104.4 Mbps
Upload: 42.5 Mbps
```

Latency \[min; mean; 95%ile; jitter ]:

```
Unloaded: 10,1; 12.9; 15.1; 1.2
Download: 9.9; 40.2; 53.3; 9.5
Upload: 18.8; 25.4; 31.1; 1.5
```

This is not completely terrible to begin with, but during download things could be tighter... for bufferbloat the 95%ile is the best indicator. This gives us 100% capacity at 105 and 43 Mbps (I just round this up here), but I note these are net throughput rates not actual gross shaper rates. We could try to better estimate the corresponding true gross rate, but especially for the download direction we need to keep some distance from the true bottleneck rate anyway so operating on net throughput here is a reasonable shortcut. Download 100%: 105000 Kbps Upload 100%: 43000 Kbps

So our first shaper settings will be: 0.5 * 105000 = 52500 0.5 * 43000 = 21500

Waveform results: A+: 14 ms: +0 ms: + 0 ms Capacity:

```
Download: 43.9 Mbps
Upload: 19.6 Mbps
```

Latency \[min; mean; 95%ile; jitter ]:

```
Unloaded: 10.9; 13.6; 15.6; 1.1
Download: 9.6; 11.8; 13.4; 0.9
Upload: 9.5; 11.9; 13.4; 0.9
```

This is a bit better... and both down and upload working latency is virtually indistinguishable from idle latency, so we have head room to increase the shaper rates. Since we first focus on the upload direction we change rates to: 0.5 * 105000 = 52500 1.0 * 43000 = 43000

Waveform results: A+: 14 ms: +0 ms: +0 ms Capacity:

```
Download: 38.8 Mbps
Upload: 39.4 Mbps
```

Latency \[min; mean; 95%ile; jitter ]:

```
Unloaded: 11.7; 14;.2 18.4; 1.1
Download: 9.9; 12.2; 14.0; 0.8
Upload: 9.9; 12.4; 14.9; 1.0
```

This looks like we get decent low latency under load increase if we go to 100% of the net rate we can get on this link. So we are done with the upload shaper setting. Next we focus on the download shaper: 1.0 * 105000 = 105000 1.0 * 43000 = 43000 % since this rare worked well, we simply keep this...

Waveform results: A+: 13 ms: +0 ms: +0 ms Capacity:

```
Download: 86.6 Mbps
Upload: 40.0 Mbps
```

Latency \[min; mean; 95%ile; jitter ]:

```
Unloaded: 10.0; 13.1; 15.3; 1.2
Download: 9.6; 12.3; 16.4; 1.4
Upload: 9.7; 11.8; 13.4; 0.8
```

Here both download and upload shaper seem to work well, without an unduly latency under load increase. We could call it a day. And normally I would, but since we did not run into any bufferbloat this does not really illustrate what happens if the shaper is set a bit too high.

So we simply remember that for this VDSL2 link we have the gross sync rates available download sync-rate: 116.790 Mb/s, upload sync-rate: 46.719 Mb/s, so for educational purposes we are going to set our shaper to match the sync rates: 1.0 * 116790 = 116790 1.0 * 46719 = 46719 % since this rare worked well, we simply keep this...

Waveform results: A: 14 ms: +16 ms: +11 ms Capacity:

```
Download: 105.3 Mbps
Upload: 41.8 Mbps
```

Latency \[min; mean; 95%ile; jitter ]:

```
Unloaded: 11.4; 13.8; 15.1; 0.8
Download: 11.0; 29.4; 37.6; 4.7
Upload: 17.8; 33.4; 28.9; 1.7
```

Again the latency increase under load is not terrible, it certainly is noticeable, and now we need to reduce the shaper rates again: 105000/43000 worked well, 116790/46719 showed bufferbloat in both directions, so want to reduce both closer to the last working rates: 105000 + (116790 - 105000)/2 = 110895 → 110000 (let's operate with somewhat rounder numbers for convenience) 43000 + (46719 - 43000)/2 = 44859.5 → 45000

Waveform results: A+: 13 ms: +1 ms: +0 ms Capacity:

```
Download: 97.0 Mbps
Upload: 41.3 Mbps
```

Latency \[min; mean; 95%ile; jitter ]:

```
Unloaded: 9.9; 12.9; 17.5; 1.5
Download: 8.7; 14.3; 23.4; 3.3
Upload: 9.7; 12.3; 15.9; 1.2
```

Now the upload looks decent (so we can keep it at 45 Mbps if we want), but the download 95%ile and jitter indicate that we are cutting is close already, so for the download we still want to reduce it further: 105000 + (110000 - 105000)/2 = 107500 (let's operate with somewhat rounder numbers for convenience) 43000 + (46719 - 43000)/2 = 44859.5 → 45000

Waveform results: A+: 14 ms: +1 ms: +0 ms Capacity:

```
Download: 91.5 Mbps
Upload: 41.8 Mbps
```

Latency \[min; mean; 95%ile; jitter ]:

```
Unloaded: 11.8; 14.0; 15.5; 0.8
Download: 9.5; 12.9; 18.1; 1.8
Upload: 9.8; 12.5; 14.3; 1.0
```

Now, both upload and download seem reasonably bufferbloat free... And at that point we could call it a day ands declare success. However, there is one thing to keep in mind, for the upload direction our traffic shaper sits before the true bottleneck buffer (in my case the VDSL2 modem) and hence we have full control over what gets send to to the modem and over the DSL link to the DSLAM, in the download direction we have much less control and if data arrives too fast fore the link, there will be some (hopefully transient) back-spill into the ISP's badly managed buffers. We already try to remedy this partly by adding the 'ingress' keyword to iqdisc\_opts which results in a more aggressive shaping of ingress traffic, but to be on the safe side we probably should increase the difference between the true bottleneck rate and our shaper rate by reducing our ingress shaper rate a bit more, so I opted for setting the ingress shaper to 100000 and call it a day.

##### bits and pieces

1. After each change of the shaper settings I typically run 'tc -s qdisc' on the router via SSH to confirm that the settings I want to see in the shaper arte actually set there.
2. The waveform test is a great help, and modern browsers are marvels of utility, but they are not a great science-grade measurement environment so one needs to use common sense to interpret the waveform data... Somme browsers, especially Safari, tend to show bands of higher latency probes (often very similarly in all three testing conditions) that correlate not with actual network events, but with browser internal processes (I suspect garbage collection timers here). That is why we only look at the 95%ile and not the maximum, and even fore the 95%ile one needs to look carefully whether that is reasonable (a simple test is to simply run this test with all major browsers and compare the results).
3. Cake, while IMHO the preferable AQM for home internet access links, is quite CPU hungry, and if cake runs out of CPU we see increased queueing latency; this how-to will teach you to detect that increased bufferbloat but can result in shaper settings that might feel to far of the contracted rates (but try it out, often proper working SQM beats higher throughput without SQM), in such cases try to use simplest.qos with fq\_codel or even simplest\_tbf.qos with fq\_codel, make sure to clear both 'iqdisc\_opts' and 'eqdisc\_opts'...

## MORE HINTS &amp; TIPS &amp; INFO

How I use CAKE to control bufferbloat and fair share my Internet connection on Openwrt.

CAKE has been my go to solution to bufferbloat for years, not just because of solving bufferbloat but also for fairer sharing of my link. Whilst CAKE has some sensible defaults there are a few extra options &amp; tweaks that can improve things further.

This note assumes that you have an Internet facing interface, usually eth0 and will call traffic leaving that interface TO the ISP egress traffic. Traffic received on that interface FROM the ISP is called ingress traffic. This interface is usually connected to an ISP's modem.

Controlling egress bufferbloat to the ISP's modem is relatively straightforward. If you ensure that traffic doesn't arrive at the modem faster than it can pass to the ISP then bufferbloat within the ISP's modem is eliminated. This involves using something called a shaper to control how quickly data leaves eth0. CAKE has a built in packet shaper that times the release of packets out of the interface so as to not overload the upstream modem. Packets also tend to accumulate extra data or overhead the closer they get to the ISP's link. For example VDSL modem links will have some framing overhead and may also acquire a 4 byte VLAN tag. CAKE's shaper is also able to take into account a wide variety of overheads adjusting its timed release mechanism to cope.

For my ISP (Sky UK) things are straightforward. They basically run ethernet over PTM over VDSL2 and I have an 80mbit ingress / 20mbit egress link. Looking at my modem's status page I can see that the egress of 20mbit is achieved but the ingress is slightly lower than 80mbit. BT are the incumbent VDSL2 infrastructure provider and require a VLAN ID 101 tag on packets across the link so we have to account for that. Similarly there's a minimum packet size limit, which empirically I'll set to 72 bytes, based on the smallest packets we ever see on the ingress side. so we're already at a stage where we can start specifying things to cake:

egress: 19950 bridged-ptm ether-vlan mpu 72 ingress: 78000 bridged-ptm ether-vlan mpu 72 ingress

We'll come back to the 'ingress' option a little later.

CAKE also has a means of fair sharing bandwidth amongst hosts. A simple example/question: If I have two hosts one which starts 2 data streams and the other starts 8, then one host would get 80% of the bandwidth allocated to it and the other 20%. From a fairness point of view it would be better if the available bandwidth was split evenly across the active hosts irrespective of the number of flows each host starts, such that one host cannot obtain all of the bandwidth just because it starts all of the transfers.

By default CAKE does 'triple-isolate' fair sharing which fair shares across both source machine addresses (internal lan) and destination addresses (external wan). In other words (and a bit simplistically) google's hosts cannot monopolise all the bandwidth from Apple's hosts (or Microsoft, Facebook, github etc) in the same way that one internal host cannot monopolise all the bandwidth.

There is a small fly in this ointment in the form of IPv4 Network Address Translation (NAT) where typically the ISP subscriber is given one Internet facing IPv4 address in which all the internal LAN traffic (usually in 192.168.x.x) is masqueraded behind. Since all the internal addresses have been hidden behind this one external Internet address, how can CAKE fair share across the internal hosts? If CAKE is running on the device performing IPv4 NAT then it can look into the device's NAT tables to determine the internal addresses and then base the fairness on that. Unfortunately it's not the default, so we have to specify it:

egress: 19950 bridged-ptm ether-vlan nat mpu 72 ingress: 78000 bridged-ptm ether-vlan nat ingress

In fact what I do is force cake to only worry about internal fairness. In other words I care that my internal machines get a fair share of the traffic irrespective of number of flows each machine has, but I don't care if external machines are unbalanced (eg. google vs netflix)

egress: 19950 dual-srchost bridged-ptm ether-vlan nat mpu 72 ingress 78000 dual-dsthost bridged-ptm ether-vlan nat ingress

Having dealt with host fairness we now need to deal with flow fairness &amp; control. A full link isn't a bad thing, in fact it's the best thing since we're using all the bandwidth that we're paying for. What is bad is when access to that link cannot be achieved in a timely manner because an excessive queue has built up in front of our packet. CAKE prevents the queue building up and ensures fair access by using a variation of codel to control delay (latency) on individual flows.

Simplistically, codel works by looking at how long a packet has been in a queue at the time it is scheduled to be sent and if it is too old the packet gets dropped. This may seem like madness after all 'isn't packet loss bad?', well packet loss is a mechanism that TCP uses to determine whether it is sending too much data and overflowing a link capacity. So shooting the right packets at the right time is actually a fundamental signalling mechanism to avoid excessive queueing. Some TCP stacks/connections support another signalling mechanism called ECN, whereby packets are marked or flagged instead of being dropped. CAKE supports ECN marking too.

CAKE looks at each data flow in turn and either releases or drops a packet from each flow to match the shapers' schedule and by dropping packets from a flow before it has built up a significant queue is able to keep each flow under control.

ingress mode modifies how CAKE's shaper accounts for dropped packets, in essence they still count to the bandwidth used calculation even though they're dropped - this makes sense, since they arrived with us but we decided that the particular flow was occupying too much bandwidth so we dropped a packet to signal the other end to slow down. The shaper on egress doesn't count dropped packets, instead it looks in the queues to find a more worthy packet to occupy the space. The bottom line, if you're trying to control ingress packet flow use ingress mode, else don't.

Traffic classification.

At this point we have a reasonably fair system. Flow fairness has been handled by a variation codel and we deliberately make that unfair if required by ensuring per-host fairness. But what if I have some types of traffic that are less or more important than others? CAKE deals with traffic classification by dividing it up into priority tins based on packet DSCP (diffserv) values. By default CAKE uses a 3 tin classification mode called 'diffserv3'. Other modes of possible interest are 'besteffort', 'diffserv4' and 'diffserv8'. Besteffort effectively ignores DSCP values, every packet is as important as the other and so just flow &amp; host fairness come into play. The diffserv modes split DSCP into an increasing number of tins. I prefer diffserv4 as I then have 4 traffic categories in increasing order of importance: 'Bulk', 'Best Effort', 'Video', 'Voice'. CAKE enforces minimum bandwidth limits for each category, Voice gets a minimum of 1/4 bandwidth, Video 1/2, Bulk 1/16th and Best Effort has a minimum of all of it(!?) Note these are minimums so if 'Video' needed all the bandwidth and there was no other competing traffic in any other category it can by all means take it. Similarly, the lowest priority tin 'Bulk' can have all the capacity if there's no other traffic, though it is guaranteed 1/16th of the bandwidth in order to prevent it from being completely starved. Best effort having the full bandwidth as a minimum appears mad but what it is in essence saying is it can have whatever is left from full - (1/2 + 1/4 + 1/16)

I use diffserv4 over diffserv3 because of the 'Bulk' category - in other words I have somewhere to de-prioritise traffic to, eg. a long term download or upload (think network backup) probably isn't important in 'wall clock time' but I don't want it disturbing general web browsing or worse video streaming or worse voip/facetime calls. I've had backups running for days at Bulk, vacuuming up all the spare upload capacity and it's completely unnoticeable (my network monitoring tells me there's an average 2mS increase in latency with peaks up to 4mS)

egress: 19950 diffserv4 dual-srchost bridged-ptm ether-vlan nat mpu 72 ingress 78000 diffserv4 dual-dsthost bridged-ptm ether-vlan nat ingress

The cherry on top.

This is only really relevant for egress traffic and for asymmetric links. In essence TCP acknowledgements can be sitting in a queue waiting to be sent. We only really need the newest ack to be sent, since it acknowledges everything the 'old' acks acknowledge - so let's not send too many of the old acks - it saves a little egress bandwidth.

egress: 19950 diffserv4 dual-srchost bridged-ptm ether-vlan nat mpu 72 ack-filter ingress 78000 diffserv4 dual-dsthost bridged-ptm ether-vlan nat ingress
