# QoS configuration /etc/config/qos

This is the documentation for the UCI configuration file `/etc/config/qos`. It is used by the package `qos-scripts` only.

![](/_media/meta/icons/tango/48px-emblem-important.svg.png) Do NOT install multiple QoS-packages simultaneously! Uninstall the old package before installing a new one.  
There are at least two other QoS/ToS packages in the OpenWrt repositories regarding: `sqm-scripts` and `wshaper`. They do NOT use this file.

`sqm-scripts` is the most modern and has Luci support. Configuration advice for it can be found at [http://www.bufferbloat.net/projects/cerowrt/wiki/Setting\_up\_SQM\_for\_CeroWrt\_310](http://www.bufferbloat.net/projects/cerowrt/wiki/Setting_up_SQM_for_CeroWrt_310 "http://www.bufferbloat.net/projects/cerowrt/wiki/Setting_up_SQM_for_CeroWrt_310")  
`qos-scripts` is written in AWK/shell script and uses [sch\_hfsc](/docs/guide-user/network/traffic-shaping/sch_hfsc "docs:guide-user:network:traffic-shaping:sch_hfsc") and [sch\_fq\_codel](/docs/guide-user/network/traffic-shaping/sch_fq_codel "docs:guide-user:network:traffic-shaping:sch_fq_codel")  
`wshaper` uses [sch\_sfq](/docs/guide-user/network/traffic-shaping/sch_sfq "docs:guide-user:network:traffic-shaping:sch_sfq") [sch\_htb](/docs/guide-user/network/traffic-shaping/sch_htb "docs:guide-user:network:traffic-shaping:sch_htb") [act\_police](/doc/howto/packet.scheduler/act_police "doc:howto:packet.scheduler:act_police"); [http://lartc.org/wondershaper/](http://lartc.org/wondershaper/ "http://lartc.org/wondershaper/") (Last release has been in 2002, so it is mostly unmaintained)

For help writing your own script please see [Traffic Control on OpenWrt: configuring the Linux Network Scheduler](/docs/guide-user/network/traffic-shaping/packet.scheduler "docs:guide-user:network:traffic-shaping:packet.scheduler").

![](/_media/meta/icons/tango/dialog-information.png) You can browse the scripts here: `qos-scripts`  
There is direct LuCI-support for `qos-scripts` called: `luci-app-qos`.  
NOTE: `luci-app-qos` won't start until you enable the `qos` Initscript within the System-→Startup tab as well as enable qos under Network-→QoS

![](/_media/meta/icons/tango/48px-outdated.svg.png) As of [r31759](https://dev.openwrt.org/changeset/31759 "https://dev.openwrt.org/changeset/31759") `qos-scripts` replaced sfq/red with fq\_codel to massively improve latency under load.

As of [r25641](https://dev.openwrt.org/changeset/25641/trunk "https://dev.openwrt.org/changeset/25641/trunk") `qos-scripts` dropped the use of IMQ (package `iptables-mod-imq` – Intermediate Queueing Device). Its successor is [IFB (Intermediate Functional Block device)](http://www.linuxfoundation.org/collaborate/workgroups/networking/ifb "http://www.linuxfoundation.org/collaborate/workgroups/networking/ifb"), (requires package: `kmod-ifb` and the scheduler action [*act\_connmark*](https://dev.openwrt.org/browser/trunk/package/iproute2/patches/200-act_connmark.patch?rev=25639 "https://dev.openwrt.org/browser/trunk/package/iproute2/patches/200-act_connmark.patch?rev=25639") included).

![:!:](/lib/images/smileys/exclaim.svg) `luci-app-qos` won’t start until you enable the `qos` Initscript within the System-→Startup tab as well as enable qos under Network-→QoS

## Sections

A minimal QoS configuration usually consists of:

- one *interface* section
- some *rules* allocating packets to at least two buckets
- *configuration* of the buckets.

### Interface

Each Interface can have its own buffer. The `interface` section declares global characteristics of the connection on which the specified interface is communicating. The following options are defined within this section:

```
config interface dsl
        option enabled      1
        option classgroup  "Default"
        option overhead     1
        option upload       512
        option download     4096
```

Name Type Required Default Description `enabled` boolean yes `1` Enable/Disable QoS `classgroup` string yes `Default` Specify `classgroup` used for this interface (see description of `classgroup` below) `overhead` boolean yes `1` decrease upload and download ratio to prevent link saturation `download` integer yes `4096` Download limit in `kilobits/second` `upload` integer yes `512` Upload limit in `kilobits/second`

### Rules

Each `classify` section defines one group of packets and which target (i.e. bucket) this group belongs to. All the packets share the bucket specified.

Name Type Required Default Description `target` bucket yes *(none)* The four defaults are: `Priority, Express, Normal` and `Bulk` `proto` string no `0` Packets matching this protocol belong to the bucket defined in target `srchost` string no *(none)* Packets matching this source host(s) (single IP or in CIDR notation) belong to the bucket defined in target `dsthost` string no *(none)* Packets matching this destination host(s) (single IP or in CIDR notation) belong to the bucket defined in target `ports` integer no *(none)* Packets matching this, belong to the bucket defined in target `srcports` integer no *(none)* Packets matching this, belong to the bucket defined in target `dstports` integer no *(none)* Packets matching this, belong to the bucket defined in target `portrange` integer no *(none)* Packets matching this, belong to the bucket defined in target `pktsize` integer no *(none)* Packets matching this exact length or length, a range of length separated by a dash. This is handled by the length match of iptables. `tcpflags` string no *(none)* Packets matching this, belong to the bucket defined in target `mark` string no *(none)* Packets matching this, belong to the bucket defined in target `connbytes` int no *(none)* Packets matching this, belong to the bucket defined in target `tos` string no *(none)* Packets matching this, belong to the bucket defined in target `dscp` string no *(none)* Packets matching this, belong to the bucket defined in target `direction` string no *(none)* Packets matching this traffic direction (`in` or `out`) belong to the bucket defined in target

Note: the already broken 'layer7' option was removed by r45425.

### Classgroup

As we can have more then one interface, we can have more then one classgroup.

```
config classgroup "Default"
	option classes      "Priority Express Normal Bulk"
	option default      "Normal"
```

Name Type Required Default Description `classes` bucket names yes *(none)* Specifies the list of names of *classes* `default` bucket name yes *(none)* Defines which *class* is considered default

### Classes

Each Bucket has its own configuration.

Example:

```
config class "Normal"
	option packetsize  1500
	option packetdelay 100
	option avgrate     10
	option priority    5
```

Name Type Required Default Description `packetsize` integer yes *(none)* in bytes `packetdelay` integer yes *(none)* in ms `maxsize` integer yes *(none)* in bytes `avgrate` integer yes *(none)* Average rate for this class, value in % of bandwidth (this value uses for calculate vaues 'Nx' of `'tc ... hfsc rt m1 N1 d N2 m2 N3`') `limitrate` integer no 100 Defines to how much percent of the available bandwidth this class is capped to, value in % `maxsize` integer yes *(none)* in bytes `priority` integer yes *(none)* in %

### Classes (For Advanced Users)

Below is unverified technical breakdown of each /etc/config/qos class parameters. Source: [http://pastebin.com/YL55na2E](http://pastebin.com/YL55na2E "http://pastebin.com/YL55na2E")

```
### Params:
#
# maxsize:
#       limits packet size in iptables rule
#
# avgrate: (note: sum(avgrates) ~ 100)
#       rt m1 = avgrate / sum (avgrate) * max_bandwidth
#       rt m2 = avgrate * max_bandwidth / 100
#       ls m1 = rt m1
#
# packetsize & packetdelay: (only works if avgrate is present)
#       rt d = max( packetdelay, 'time required for packetsize to transfer' ) (smaller ps -> smaller d)
#       ls d = rt d
#
# priority:
#       ls m2 = priority / sum (priority) * max_bandwidth
#
# limitrate:
#       ul rate = limitrate * max_bandwidth / 100
```

## Quick start guide

![:!:](/lib/images/smileys/exclaim.svg) check free space first. At least 200kb free. Run **df** ![:!:](/lib/images/smileys/exclaim.svg) if you get no left space... opkg may has been corrupted. I recommend re-flash ( sysupgrade firware file stuff ) before reboot

1\. Install the qos-scripts package:

```
opkg install qos-scripts
```

2\. Basic configuration using UCI command line:

```
uci set qos.wan.upload=1000            # Upload speed in kBits/s
uci set qos.wan.download=16000         # Download speed in kBits/s
uci set qos.wan.enabled=1
uci commit qos
```

3\. Start it and look for error output and test):

```
/etc/init.d/qos start
```

4\. Make script run at every boot up:

```
/etc/init.d/qos enable
```

## Troubleshooting

(Last updated for: Barrier Breaker 14.07)

If your QoS doesn't seem to be working, it may be an error or typo in the config file is preventing it from loading properly.

- Check `enabled` is set to 1 in `/etc/config/qos`(!)

<!--THE END-->

- Run `iptables-save` and check there are lines near the top prefixed with either `-A qos_Default` or `-A qos_Default_ct`, and featuring the `--set-xmark` directive. Here's an example:

```
-A qos_Default -p tcp -m mark --mark 0x0/0xf0 -m tcp --sport 1024:65535 --dport 1024:65535 -j MARK --set-xmark 0x44/0xff
```

The `--set-xmark` is what flags the packet so it is picked up the traffic control subsystem.

- Look at the generated traffic control qdisc settings by running:

```
tc qdisc
```

The default (ie no-QoS-applied) values for any interface look like this:

```
qdisc fq_codel 0: dev eth0 root refcnt 2 limit 1024p flows 1024 quantum 300 target 5.0ms interval 100.0ms ecn
```

Any interface with only a single qdisc line printed, showing the same settings as this line (this one is for `dev eth0`), indicates no QoS on that interface.

Network interfaces with QoS enabled will have multiple qdisc lines printed, each corresponding to a QoS class, etc.

- If the printed qdisc settings don't seem to be correct, you can preview the `tc` commands generated from the OpenWRT `/etc/config/qos` by running:

```
/usr/lib/qos/generate.sh interface wan
```

(Replace `wan` with the OpenWRT interface name you're debugging, as given in the `/etc/config/qos` file.)

This should print a series of `insmod` and `tc` commands used to set up the QoS subsystem. You can debug any errors caused by running these commands by running:

```
/usr/lib/qos/generate.sh interface wan | sh -x
```

(Note `-x` option which tells `sh` to print each line as it is executed.)

The output of `/usr/lib/qos/generate.sh` is normally executed automatically as part of `/etc/hotplug.d/iface/10-qos`.

## txqueuelen

*Recent versions of trunk uses [CoDel](http://www.bufferbloat.net/projects/codel/wiki "http://www.bufferbloat.net/projects/codel/wiki") (pronounced: Coddle), so this should not be needed. [bufferbloat.net](http://www.bufferbloat.net/projects/bloat/wiki/Linux_Tips#Reduce-transmit-queue-length "http://www.bufferbloat.net/projects/bloat/wiki/Linux_Tips#Reduce-transmit-queue-length")*

Note: after i know about bufferbloat - websearchd and many misguided users are asking about *raising* txqueuelen, or how to set it, and this was a recommended read posted for them -, and that just enabling QoS and setting up the rules i wanted didnt produce results, i thought of reduce txqueuelen from the default size of 1000 packets. On most SOHO applications the upload speed is much-much lower than the interface speed (100M or 1G), and it's written that the def buffer is tailored for enterprise size usage. I used values of 90 where\[only] it was 1000 and it is wonderfully responsive and effective now, on a 256k connection. I also raised lenghts of 3 and 5 to 20 as i imagined it might be hard to do any queuing/shaping on such ultra short buffers. Leave the 0-s as 0. Btw, the 90 came by, that with 1500byte packet size and 256kbit speed, it takes just half a sec to empty it. Well, i mistakenly took mtu as bits so it's 4 second really but i didnt have the courage for a drastically smaller than default value, 90 already seem so smallish, and it works nicely anyway, awesome lack of latency, jitter and packetloss on the other machine, according to [http://pingtest.net](http://pingtest.net "http://pingtest.net"), before of this there was no difference between mine and that. Note that this time doesnt correspond to ping values. The point is to allow built-in TCP congestion control *to work* to reduce “spamming”, set speeds as it was envisioned, and keep things leveled out rather than fluctuating widely. While this doesnt directly effects QoS-ing itself, it is extremely beneficial, even essential, to the results usually expected from employing it. It sets a foundation, a healthy network environment over which QoS to function.

```
ifconfig
ifconfig eth0 txqueuelen 90
ifconfig pppoe-wan txqueuelen 20
uci commit
/etc/init.d/network reload
```

## Types and Groups

The `qos-scripts` package didn't come with documentation and there has been some confusion about its features, among users. The information in this section comes straight from nbd (the developer), so it should come a long way to clearing some confusion on two major issues.

The biggest item of contention was which group setting gives better performance, **Priority** or **Express**. As it turns out, it depends on the application. **Priority** boosts low-bandwidth small frames, such as TCP-ACKs and DNS more than Express. **Express** is for prioritizing bigger frames, which would include stuff like VoIP (port 5060).

Another biggie was the exact meaning of each type. Types are necessary for connection tracking. By default, **Classify** is not run on a connection that had already been assigned a traffic class, so it is the initial connection-tracked classification. **Reclassify** can override the traffic class per packet, without altering the connection tracking mark. **Default** is a fall-back for everything that has not been marked by Classify/Reclassify. Rules get processed by type first (Classify gets processed first, then Reclassify and finally Default) and then based on the order in the configuration file (top to bottom).

## Traffic Shaping

Basic Shaping

Create a new classes at the end of qos file:

```
config class "X1"
	option packetsize  1500
	option packetdelay 100
	option avgrate     1
	option limitrate   50  # max rate in %
 
config class "X2"
	option packetsize  1500
	option packetdelay 100
	option avgrate     1
	option limitrate   30  # max rate in %
```

Add it to class group:

```
config classgroup "Default"
	option classes      "Priority Express Normal Bulk X1 X2"
	option default      "Normal"
```

Add next stuff to begin of qos file, after Priority, Express...

Shaping a user:

```
config classify
	option target 'X1'
	option srchost '192.168.1.100'
	option comment 'user'
```

Shaping a site:

```
config classify
	option target 'X1'
	option dsthost '8.8.8.8'
	option comment 'site'
```

Two users: will share X1. Example: 500kB/s for both. Max user1+user2=500kB/s !

```
config classify
	option target 'X1'
	option srchost '192.168.1.101'
	option comment 'user1'
 
<code bash>
config classify
	option target 'X1'
	option srchost '192.168.1.102'
	option comment 'user2'
```

Two users: diferent buckets. 500kB/s and 300kB/s .. as example. Max 500+300=800kB/s !

```
config classify
	option target 'X1'
	option srchost '192.168.1.101'
	option comment 'user1'
 
config classify
	option target 'X2'
	option srchost '192.168.1.102'
	option comment 'user2'
```

Calc %:

8000kbps * 50% / 8 = 500kB/s

Notes:

Will affect both upload/download. A 12000/1000 line will be shaped at 6000/500...

edit: \*X1* limit upload or both if \*X1\_down* not present... \*X1\_down* limit down...

## TS: 8Mb/8Mb LTE

**Why shaping?**

\- Now i have 100GB quota, it will go wasted easly with youtube...

\- Youtube android app cache all video, even if you only see a few seconds

\- 1080p smart tv are :evil:

**About Youtube**

\- Shape google 216.* may not work, because cache.google.com are in your ISP

\- Shaping YouTube will shape all cacheable contents: Play Store...

\- YouTube use port 443 almost

\- Almost all web traffic are port 443. Http priority is useless today

```
config interface 'wan'
	option classgroup 'nikito'
	option upload   '8000'
	option download '8000'
	option overhead '0'
	option enabled  '1'
 
config classify
	option target 'yt'
	option proto 'tcp'
	option dstports '80,443'
	option srchost '10.2.1.90'
	option comment 'tv youtube'
 
config classgroup 'nikito'
	option classes 'n yt'
	option default 'n'
 
config class 'n'
	option packetsize '1500'
	option packetdelay '100'
	option avgrate '10'
	option priority '5'
 
config class 'n_down'
	option avgrate '20'
 
config class 'yt'
	option avgrate   '10'
 
config class 'yt_down'
	option avgrate   '10'
	option limitrate  '10'
```
