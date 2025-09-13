# Example4: HFSC + FQ\_CODEL + FLOW classifier

## Basic ip-based fair sharing behind triple play box

In this example, the router is not connected directly to internet, but through another router (a triple play box with an ADSL connection in this instance).

For fq\_codel to work, the point where packets are queued has to be the Router, rather than the triple play box (the Router can only re-order packets if it contains the queue).

As the link between the Router and the triple play box is much bigger than the ADSL connection (100mbits vs 1mbits up), rate limiting has to be applied at the Router's WAN connection.

However, we still want to have the full speed when we access the triple play box or the TV Box directly from within the LAN. Finally, we want to implement fair sharing of bandwidth based on source ip (even with NAT activated on “ROUTER”).

```
                                                                                ____
User 1==============\          [TV Box]===\                                 ___(    )__
                     \                     \                              _(           )_
User 2===============[Router]=============[triple play box]··············(_  internet  __)
                     /                                                     (_       __)
User N==============/                                                        (______)
      LAN_SUBNET               WAN_SUBNET                     REAL_WAN
```

```
#!/bin/sh /etc/rc.common
#
# License GPLv2
# Version 0.1
 
START=99
EXTRA_COMMANDS="status"
 
##############################################################
# Variables
IF_WAN="br-wan" 		#-- wan interface
WAN_NET="192.168.1.0/24" 	#-- wan local subnet
UP_RATE=900 			#-- 90% of internet upload bandwidth in kilobits/sec
PHY_RATE=90 			#-- 90% of wan phy bandwidth in megabits/sec
TC=/usr/sbin/tc 		#-- location of traffic control
 
MODULES='sch_hfsc sch_ingress sch_fq_codel cls_flow cls_u32'
 
##############################################################
status() {
	echo "### Statistics ###"
	echo "# qdiscs #"
	tc -s qdisc show dev $IF_WAN
	echo "# class #"
	tc -s class show dev $IF_WAN
 
	echo "# filter #"
	tc -s filter show dev $IF_WAN root
	tc -s filter show dev $IF_WAN parent 1:
	tc -s filter show dev $IF_WAN parent 11:
}
##############################################################
 
 
 
##############################################################
stop() {
	# Delete existing qdiscs (hide errors)
	$TC qdisc del dev $IF_WAN root    2> /dev/null > /dev/null
	$TC qdisc del dev $IF_WAN ingress 2> /dev/null > /dev/null
 
	# Unload modules
	for i in $MODULES ; do
		rmmod $i
	done
}
##############################################################
 
 
 
###############################################################################
start() {
# Load modules
for i in $MODULES ; do
	insmod $i
done
 
ifconfig $IF_WAN txqueuelen 1000
 
# reset qdiscs
$TC qdisc del dev $IF_WAN root    2> /dev/null > /dev/null
$TC qdisc del dev $IF_WAN ingress 2> /dev/null > /dev/null
 
 
###############################################################################
$TC qdisc add dev $IF_WAN root       handle  1   hfsc default 1
 
$TC class add dev $IF_WAN parent 1:  classid 1:1  hfsc sc rate ${UP_RATE}kbit ul rate ${UP_RATE}kbit
$TC qdisc add dev $IF_WAN parent 1:1 handle 11: fq_codel
$TC filter add dev $IF_WAN parent 11: handle 11 protocol all flow hash keys nfct-src divisor 1024
 
$TC class add dev $IF_WAN parent 1:  classid 1:2  hfsc sc rate ${PHY_RATE}mbit ul rate ${PHY_RATE}mbit
$TC filter add dev $IF_WAN parent 1: protocol ip prio 1 u32 match ip dst ${WAN_NET} flowid 1:2
$TC filter add dev $IF_WAN parent 1: protocol arp prio 2 u32 match u32 0 0 flowid 1:2
}
```

What we need to do:

1. Load kernel modules (will need HFSC / FQ\_CODEL / INGRESS qdiscs, and FLOW / U32 classifiers)
2. Set the TX queue length. By default virtual iface (bridges (br-\*), vlans (eth0.\*)) txqueuelen is set to 0 and so no queue will exist, and the qdisc will inherit this value. QoS is about changing the queue (reordering, dropping), so we need to have a queue to change.
3. We add hfsc qdisc to the device ($IF\_WAN), with handle X (1), and set default to Y (1 also), so every packet that isn't match by a filter will go to the class X:Y (1:1 here). The default behavior of HFSC is to drop packets that aren't classified, so it's safer to use default.
4. We add an hfsc class with classid X:1 (X = 1) to the qdisc with handle X (parent X: or parent 1: in our case). This class will rate limit the traffic to internet. This is the class that will get all the traffic not match be any filter (still following).
5. We add an fq\_codel qdisc to the 1:1 hfsc class. The name of the qdisc will be 11 or 11: or 11:0 (handle 11, but we could have chosen 42)
6. We add a filter to the fq\_codel to put each packet in a class (dynamic ...) based on its src ip address before NATing (nfct-src). To be more precise we hash nfct-src modulo “divisor” (1024) and with this hash we decide in which fq\_codel class we put the packet.
7. To finish we create another hfsc class for the WAN\_SUBNET (hi-speed) traffic, and we filter in it all the IP packets with ${WAN\_NET} destination (192.168.1.0/24), and all the ARP packets.

## Other end

```
$TC qdisc add dev $IF_WAN root       handle  1   hfsc default 2
 
$TC class add dev $IF_WAN parent 1:  classid 1:1  hfsc sc rate ${UP_RATE}kbit ul rate ${UP_RATE}kbit
$TC qdisc add dev $IF_WAN parent 1:1 handle 11: fq_codel
$TC filter add dev $IF_WAN parent 11: handle 11 protocol all flow hash keys nfct-src divisor 1024
 
$TC class add dev $IF_WAN parent 1:  classid 1:2  hfsc sc rate ${PHY_RATE}mbit ul rate ${PHY_RATE}mbit
$TC filter add dev $IF_WAN parent 1: protocol ip prio 1 u32 match ip dst ${WAN_NET} flowid 1:2 # match all local ip traffic
$TC filter add dev $IF_WAN parent 1: protocol ip prio 1 u32 match ip dst 255.255.255.255/32 flowid 1:2 # Limited Broadcast
#$TC filter add dev $IF_WAN parent 1: protocol ip prio 1 u32 match ip dst 169.254.0.0/16 flowid 1:2 # link-local
#$TC filter add dev $IF_WAN parent 1: protocol ip prio 1 u32 match ip dst 224.0.0.0/4 flowid 1:2 # multicast
 
$TC filter add dev $IF_WAN parent 1: protocol ip prio 2 u32 match u32 0 0 flowid 1:1 # match all the remaining ip traffic
 
#$TC filter add dev $IF_WAN parent 1: protocol all prio 3 u32 match u32 0 0 flowid 1:2 # useless as we use default 2
```
