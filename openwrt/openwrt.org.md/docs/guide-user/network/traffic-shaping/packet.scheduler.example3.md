# Example3: traffic shaping and prioriziting for multiple users with HFSC

The default behavior of HFSC is to drop not classified traffic. If it apply (static or dhcp interface for exemple, instead of pppoe), don't forget to classify ARP packets, or to add a default class (in the following exemple all the non classified traffic will go in the 1:50 class)

```
-$TC qdisc add dev $IF_DSL root       handle  1:   hfsc
+$TC qdisc add dev $IF_DSL root       handle  1:   hfsc default 50
```

```
#!/bin/sh
#
# racTC.sh - 2-Ebenen-traffic shaping with HFSC
# Copyright (C) 2010  rac 
# for use with OpenWrt
# License GPLv2
# Version 0.4
 
##############################################################
# Variables
TC=/usr/sbin/tc #-------- location of traffic control
IPT=/usr/sbin/iptables #- location of iptables
IF_DSL=pppoe-dsl #------- interface to dsl
UP_RATE=576 #------------ 90% of available bandwidth in kilobits/sec
DOWN_RATE=5400
IP_USER1=192.168.10.42
IP_USER2=192.168.20.42
IP_USER3=192.168.30.42
IP_SERVER=192.168.40.42
IP_DSL=$(ifconfig|grep 'inet addr:84'|cut -d':' -f2|awk '{print $1}')
USER1=$(($UP_RATE/4))		# 25%
USER2=$(($UP_RATE/4))		# 25%
USER3=$(($UP_RATE/4))		# 25%
SERVER=$((1*$UP_RATE/10))	# 10%
ROUTER=$((1*$UP_RATE/20))	#  5%
 
MODULES='ipt_TOS ipt_tos ipt_length sch_hfsc sch_ingress'
 
##############################################################
# status
if [ "$1" = "status" ]; then
	tc -s qdisc ls dev $IF_DSL
	tc -s class ls dev $IF_DSL
	exit
fi
##############################################################
# Delete existing qdiscs (hide errors)
$TC qdisc del dev $IF_DSL root    2> /dev/null > /dev/null
$TC qdisc del dev $IF_DSL ingress 2> /dev/null > /dev/null
##############################################################
# Unload modules
if [ "$1" = "stop" ]; then 
	for i in $MODULES ; do
		rmmod $i
	done
	exit
fi
##############################################################
# Load modules
for i in $MODULES ; do
        insmod $i
done
 
############################################################################################################################
# Manipulating qdiscs
$TC qdisc del dev $IF_DSL root    2> /dev/null > /dev/null
$TC qdisc del dev $IF_DSL ingress 2> /dev/null > /dev/null
###
$TC qdisc add dev $IF_DSL root       handle  1:   hfsc
$TC class add dev $IF_DSL parent 1:  classid 1:1  hfsc sc rate ${UP_RATE}kbit ul rate ${UP_RATE}kbit
$TC class add dev $IF_DSL parent 1:1 classid 1:10 hfsc ls rate ${USER1}kbit   ul rate ${UP_RATE}kbit
$TC class add dev $IF_DSL parent 1:1 classid 1:20 hfsc ls rate ${USER2}kbit   ul rate ${UP_RATE}kbit
$TC class add dev $IF_DSL parent 1:1 classid 1:30 hfsc ls rate ${USER3}kbit   ul rate ${UP_RATE}kbit
$TC class add dev $IF_DSL parent 1:1 classid 1:40 hfsc sc rate ${SERVER}kbit  ul rate ${UP_RATE}kbit
$TC class add dev $IF_DSL parent 1:1 classid 1:50 hfsc sc rate ${ROUTER}kbit  ul rate ${UP_RATE}kbit
##################################################################################
# Zweite Ebene: Priorisierung : Jede User-Klasse hat ihre eigenen 3-5 Sub-Klassen:
##################################################################################
# echo "User 1:"
$TC class add dev $IF_DSL parent 1:10 classid 1:101 hfsc rt m1 ${USER1}kbit d  100ms m2 $((5*$USER1/10))kbit ls m1 ${USER1}kbit d 50ms m2 $((7*$USER1/10))kbit # real time
$TC class add dev $IF_DSL parent 1:10 classid 1:102 hfsc sc m1 0            d  100ms m2 $((4*$USER1/10))kbit # http
$TC class add dev $IF_DSL parent 1:10 classid 1:103 hfsc sc m1 0            d 4000ms m2 $((1*$USER1/10))kbit # Bulk
 
# echo "User 2:"
$TC class add dev $IF_DSL parent 1:20 classid 1:201 hfsc rt m1 ${USER2}kbit d  100ms m2 $((5*$USER2/10))kbit ls m1 ${USER2}kbit d 50ms m2 $((7*$USER2/10))kbit # real time
$TC class add dev $IF_DSL parent 1:20 classid 1:202 hfsc sc m1 0            d  100ms m2 $((4*$USER2/10))kbit # http
$TC class add dev $IF_DSL parent 1:20 classid 1:203 hfsc sc m1 0            d 4000ms m2 $((1*$USER2/10))kbit # Bulk
 
# echo "User 3:"
$TC class add dev $IF_DSL parent 1:30 classid 1:301 hfsc rt m1 ${USER3}kbit d  100ms m2 $((5*$USER3/10))kbit ls m1 ${USER3}kbit d 50ms m2 $((7*$USER3/10))kbit # real time
$TC class add dev $IF_DSL parent 1:30 classid 1:302 hfsc sc m1 0            d  100ms m2 $((4*$USER3/10))kbit # http
$TC class add dev $IF_DSL parent 1:30 classid 1:303 hfsc sc m1 0            d 4000ms m2 $((1*$USER3/10))kbit # Bulk
 
##################################################################################
# Filter für die zweite Ebene
##################################################################################
# We use iptables with "-j CLASSIFY", not further filters needed
 
#############################################################################
# MANGLE
 
#================================
# POSTROUTING (Policy: ACCEPT)
#----------------------------
$IPT -t mangle -F
$IPT -t mangle -X
 
IPTM="$IPT -t mangle"
IPTMOD="$IPT -t mangle -A POSTROUTING -o $IF_DSL"
 
$IPTM -N TC_USER1
$IPTM -N TC_USER2
$IPTM -N TC_USER3
 
##################################################################################
# jump to user chain; multiple IPs possible
$IPTMOD -s $IP_USER1  -j TC_USER1
$IPTMOD -s $IP_USER2  -j TC_USER2
$IPTMOD -s $IP_USER3  -j TC_USER3
$IPTMOD -s $IP_SERVER -j CLASSIFY --set-class 1:40
$IPTMOD -s $IP_DSL    -j CLASSIFY --set-class 1:50
 
# Link-sharing implemented, thus it is in everyones own interest to not mess with TOS-Flags.
# Packets without a classification will be dropped! Make sure to classify all.
##################################################################################
$IPTM -A TC_USER1 -j CLASSIFY --set-class 1:103 -m tos --tos Maximize-Throughput #- BULK
$IPTM -A TC_USER1 -j CLASSIFY --set-class 1:103 -m tos --tos Maximize-Throughput #- BULK
$IPTM -A TC_USER1 -j CLASSIFY --set-class 1:101 -p icmp #-------------------------- superfluous
$IPTM -A TC_USER1 -j CLASSIFY --set-class 1:101 -m tos --tos Maximize-Reliability
$IPTM -A TC_USER1 -j CLASSIFY --set-class 1:101 -m tos --tos Minimize-Delay
$IPTM -A TC_USER1 -j CLASSIFY --set-class 1:101 -p udp -m length --length :412 #--- small udp
$IPTM -A TC_USER1 -j CLASSIFY --set-class 1:101 -p tcp -m length --length :128 #--- small tcp
$IPTM -A TC_USER1 -j CLASSIFY --set-class 1:102 -p tcp --dport 1:1024 #------------ no better idea
$IPTM -A TC_USER1 -j CLASSIFY --set-class 1:103 #---------------------------------- default
 
#################################################################################
$IPTM -A TC_USER2 -j CLASSIFY --set-class 1:201 -m tos --tos Minimize-Delay #------- 
$IPTM -A TC_USER2 -j CLASSIFY --set-class 1:201 -m tos --tos Maximize-Reliability #- 
$IPTM -A TC_USER2 -j CLASSIFY --set-class 1:202 -m tos --tos Normal-Service #-------
$IPTM -A TC_USER2 -j CLASSIFY --set-class 1:203 -m tos --tos Maximize-Throughput #--
$IPTM -A TC_USER2 -j CLASSIFY --set-class 1:203 -m tos --tos Minimize-Cost #--------
 
#################################################################################
$IPTM -A TC_USER3 -j CLASSIFY --set-class 1:301 -m tos --tos Minimize-Delay #------- 
$IPTM -A TC_USER3 -j CLASSIFY --set-class 1:301 -m tos --tos Maximize-Reliability #-
$IPTM -A TC_USER3 -j CLASSIFY --set-class 1:302 -m tos --tos Normal-Service #-------
$IPTM -A TC_USER3 -j CLASSIFY --set-class 1:303 -m tos --tos Maximize-Throughput #--
$IPTM -A TC_USER3 -j CLASSIFY --set-class 1:303 -m tos --tos Minimize-Cost #-------- 
```
