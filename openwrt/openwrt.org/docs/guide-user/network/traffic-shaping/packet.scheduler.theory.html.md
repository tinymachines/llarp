# Linux Packet Scheduling

- Packet Scheduler, Queueing Discipline(QDisc), queueing algorithm and packet scheduler algorithm are all names for the same thing. Usually contained in distinct kernel modules, one of multiple schedulers can be loaded into the kernel and utilized to make scheduling decisions.
- The packet scheduler is integral to the network parts of the Kernel - embedded in the network stack and the network driver. You can find the source code in: [net/sched](http://lxr.free-electrons.com/source/net/sched/ "http://lxr.free-electrons.com/source/net/sched/")
- The packet scheduler is configured with the program `tc`.

<!--THE END-->

- [http://lca2013.linux.org.au/schedule/30118/view\_talk](http://lca2013.linux.org.au/schedule/30118/view_talk "http://lca2013.linux.org.au/schedule/30118/view_talk")
  
  - [Video: lca2013 Bufferbloat from a Plumber's point of view 41min](http://www.youtube.com/watch?v=y5KPryOHwk8 "http://www.youtube.com/watch?v=y5KPryOHwk8") ([Download link](http://r1---sn-35cxacf-935e.c.youtube.com/videoplayback?title=%5BLinux.conf.au%202013%5D%20-%20Bufferbloat%20from%20a%20Plumber%27s%20point%20of%20view&itag=44&mv=m&ipbits=8&fexp=916602%2C902903%2C919318%2C935800%2C932304%2C909546%2C906397%2C929117%2C929121%2C929906%2C929907%2C929127%2C929129%2C929131%2C929930%2C925720%2C925722%2C925718%2C925714%2C929917%2C929919%2C912521%2C932306%2C904830%2C919373%2C904122%2C929609%2C911423%2C909549%2C935006%2C900816%2C912711%2C935802%2C904494%2C906001&ms=au&sver=3&cp=U0hWS1FQUl9FTkNONl9JSlZIOjAtaFg4NkJmSldF&ip=37.209.1.176&upn=-gFRS1tnMuA&mt=1376129826&sparams=cp%2Cid%2Cip%2Cipbits%2Citag%2Cratebypass%2Csource%2Cupn%2Cexpire&ratebypass=yes&expire=1376154704&key=yt1&source=youtube&id=cb928faf2387c24f&signature=67DE7167FCEF80A35CA7E3CFEC4C7506A11E05A0.936390E1B9B03E6D46EB5F8C61F03111FF343675 "http://r1---sn-35cxacf-935e.c.youtube.com/videoplayback?title=%5BLinux.conf.au%202013%5D%20-%20Bufferbloat%20from%20a%20Plumber%27s%20point%20of%20view&itag=44&mv=m&ipbits=8&fexp=916602%2C902903%2C919318%2C935800%2C932304%2C909546%2C906397%2C929117%2C929121%2C929906%2C929907%2C929127%2C929129%2C929131%2C929930%2C925720%2C925722%2C925718%2C925714%2C929917%2C929919%2C912521%2C932306%2C904830%2C919373%2C904122%2C929609%2C911423%2C909549%2C935006%2C900816%2C912711%2C935802%2C904494%2C906001&ms=au&sver=3&cp=U0hWS1FQUl9FTkNONl9JSlZIOjAtaFg4NkJmSldF&ip=37.209.1.176&upn=-gFRS1tnMuA&mt=1376129826&sparams=cp%2Cid%2Cip%2Cipbits%2Citag%2Cratebypass%2Csource%2Cupn%2Cexpire&ratebypass=yes&expire=1376154704&key=yt1&source=youtube&id=cb928faf2387c24f&signature=67DE7167FCEF80A35CA7E3CFEC4C7506A11E05A0.936390E1B9B03E6D46EB5F8C61F03111FF343675"))
- [http://www.bufferbloat.net/projects/cerowrt/wiki/Bloat-videos](http://www.bufferbloat.net/projects/cerowrt/wiki/Bloat-videos "http://www.bufferbloat.net/projects/cerowrt/wiki/Bloat-videos")

## Packets

We will start with what you probably already know - that almost all network communication takes place in chunks and not as a continuous flow. If you do not, this [networking article](/docs/guide-developer/networking/start "docs:guide-developer:networking:start") should help.

These chunks are more commonly referred to as packets, so network communication is packet-based.

These packets begin their lives as data on a computing device that needs to get from where it presently resides to another device somewhere on the local area network or a different network.

This data is first broken into packets. Then a header and sometimes a footer are added with delivery instructions and other information. This process is repeated each time the packet traverses an application or device that uses a different format for handling packets.

The opposite takes place as the packet nears its destination. The various headers and footers are removed and the packet reaches the end of it's journey as it began - the same chunk of data we started with. When combined with all the other chunks, in the correct order, we end up with the same data we started with only that data is in a new location. A [real world analogy](http://www.tcpipguide.com/free/t_UnderstandingTheOSIReferenceModelAnAnalogy.htm "http://www.tcpipguide.com/free/t_UnderstandingTheOSIReferenceModelAnAnalogy.htm").

We use QoS to ensure packets get to their destination in a timely fashion and that they are not delayed by lower priority traffic. While we don't have much control of what happens to packets outside of our own network, there are QoS options that allow us to drop or reorder packets at each of our own network interfaces. The most important of these is usually the WAN port of our router.

Why?

Well, this where LAN traffic converges to be transferred to another network, often over a lower capacity connection. Similar to the way traffic backs up on a busy freeway when multiple lanes merge into one, packets are either dropped or backed up in the interface queue waiting for their turn to pass through the bottleneck.

In fact unless there is traffic congestion there is no need for QoS. By itself QoS does not increase bandwidth or make packets travel faster. It queues, or drops packets in cases where there is less bandwidth available than needed. We could also eliminate the congestion by increasing the bandwidth of the connection, but this is not always possible or practical.

## Network Interfaces

Network interfaces can drop, forward, queue, delay and re-order packets.

### Queues

Every network interface has two queues, also referred to as a buffers, where packets reside briefly before being transmitted. The queue for incoming packets is called the **ingress queue**. The queue for outgoing packets is called the **egress queue**.

#### Egress Queue

Let us look at the **egress queue** of a typical [network interface](/docs/guide-developer/networking/network.interfaces "docs:guide-developer:networking:network.interfaces").

We can determine and change the size of the queue using the `ifconfig` command. The `txqueuelen:` in the response indicates the capacity of the queue.

Queue capacity is not measured in bytes or bits as you might expect, but by the number of packets it can hold. When the queue is full, any further incoming packets will “overflow”. They are dropped and never reach the intended recipient.

Activating QoS is not necessary with Linux as it is already active by default. The standard packet scheduler that manages egress queues in Linux, is “pfifo\_fast”, which means “prioritized first in first out”. It is based on the QoS/TOS flags in the packet headers.

Network interfaces are serial devices. Packets leave the queue one a time, and are transmitted one after the other, single file. The task of the scheduler is to decide which packet leaves next. It does this by ordering the packets according to an algorithm and its configuration. In the case of “pfifo\_fast”, the first packet to the enter the buffer is the first to leave.

#### Ingress Queue

Unlike the egress queue, the ingress queue has limited control over the packets it receives. Other than forwarding packets as they are received it's only other capability is to drop packets. This can be used to advantage though with the TCP protocol which uses flow and congestion control. Dropping TCP “ACK” packets will imply congestion to the transmission source which will reduce it's transmission rate. There is no similar mechanism available for UDP packets however.

## Putting it all together

A basic QoS setup.

```
                                                               ____
User1==============\                                       ___(    )__
         Line_A     \                                    _(           )_
User2===============[ROUTER]·············[ISP]≡≡≡≡≡≡≡≡≡≡(_  Internet  __)
         Line_B     /          Line_X           Line_Z   (_        __)
User3==============/                                       (______)
         Line_C

Line_A, Line_B and Line_C are Gigabit Ethernet
Line_X  phone line using ADSL2+ protocol
Line_Z 10 Gigabit fiber 

We implement QoS at the [ROUTER] WAN interface.

-->-->--[egress queue]-->-->--[interface output]-->-->--Internet
           \    /
            \  /
            QDisc  

1. Drop packets exceeding available bandwidth.
2. Reorder packets currently in the buffer. 

-->-->--[ingress queue]-->--[bridge check]-->-->--intranet
            \    /
             \  /
             QDisc  

1. Drop packets that exceed configured bandwidth ("policing") 
   With TCP => no line congestion
2. No reordering
```

- We limit outgoing traffic to a rate slightly below the capacity of the outgoing connection. This moves the traffic bottleneck upstream to the router where we can control congestion instead of downstream where we cannot.

<!--THE END-->

- We drop incoming packets that exceed bandwidth. TCP recognizes this as a sign of traffic congestion and reduces the transmission rate at the source.

Below are some articles about packet reordering:

- [tc command manual](http://linux.die.net/man/8/tc "http://linux.die.net/man/8/tc")
- [Linux Advanced Routing &amp; Traffic Control HowTo](http://lartc.org/howto/index.html "http://lartc.org/howto/index.html")
  
  - [9. Queueing Disciplines for Bandwidth Management](http://lartc.org/howto/lartc.qdisc.html "http://lartc.org/howto/lartc.qdisc.html")
  - [11. Netfilter &amp; iproute - marking packets](http://lartc.org/howto/lartc.netfilter.html "http://lartc.org/howto/lartc.netfilter.html")
  - [12. Advanced filters for (re-)classifying packets](http://lartc.org/howto/lartc.adv-filter.html "http://lartc.org/howto/lartc.adv-filter.html")
- [HTB Linux queuing discipline manual - user guide](http://luxik.cdi.cz/~devik/qos/htb/manual/userg.htm "http://luxik.cdi.cz/~devik/qos/htb/manual/userg.htm")
- [Hierarchical Packet Fair Queueing (H-PFQ) and Hierarchical Fair Service Curve (H-FSC)](http://www.cs.cmu.edu/~hzhang/HFSC/main.html "http://www.cs.cmu.edu/~hzhang/HFSC/main.html")
