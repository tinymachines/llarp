# Example1: Traffic Prioritizing with PRIO

```
#!/bin/sh
# A single user has 1000kbit upload for themself. But they want prioritizing.
 
# Variables
TC=$(which tc)
IPT=$(which iptables)
IPTMO="$IPT -t mangle -A POSTROUTING"
DEV=pppoe-dsl
 
insmod sch_prio
 
# The PRIO qdisc is a non-shaping container for a configurable number of classes
# which are dequeued in order. This allows for easy prioritization of traffic,
# where lower classes are only able to send if higher ones have no packets
# available.
 
$TC qdisc add dev $DEV root       handle 1:    prio default 30
$TC class add dev $DEV parent 1:  classid 1:1  prio rate 1000kbit?
$TC class add dev $DEV parent 1:1 classid 1:10 prio ??? #-- ssh, ACKs, VoIP, gaming
$TC class add dev $DEV parent 1:1 classid 1:20 prio ??? #-- http
$TC class add dev $DEV parent 1:1 classid 1:30 prio ??? #-- bulk, default, mails, etc
 
# Filter
# Since PRIO honors the TOS/QoS-Field by default, we should be concerned with our
# applications setting the right QoS for every packet they create. Additionally we
# can not blindly trust the set TOS and change it:
 
$IPTMO -N CHKTOS #-------------------------------create custom chain for this issue
$IPTMO -o $DEV -j CHKTOS #----every packet immediately jumps to custom-chain: CHKTOS
$IPTMO -A CHKTOS -m tos ! --tos Normal-Service -j RETURN #---if TOS is set, leave it
$IPTMO -A CHKTOS -p udp -j TOS --set-tos Minimize-Delay #-----UDP gets high priority
$IPTMO -A CHKTOS -p udp -m length --length :160 -j TOS --set-tos Minimize-Delay
#-- small udp packets
$IPTMO -A CHKTOS -p tcp -m length --length :128 -j TOS --set-tos Minimize-Delay
#-- small tcp packets get high priority
# If bulk traffic gets tunneled through ssh connections, change their TOS 
# (some programs do this by themselves, but not all):
$IPTMO -o $DEV -p tcp --dport 22 -m tos --tos Minimize-Delay -m connrate \
--connrate 20000:inf -j TOS --set-tos Maximize-Throughput
```
