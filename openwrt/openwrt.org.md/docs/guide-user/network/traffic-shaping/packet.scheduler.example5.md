# Example5: Traffic Prioritizing with HTB and MAC filtering

```
#!/bin/sh
# We have 200000kbit bandwidth and want to reduce a couple of MACs to 3000kbit to keep our cable bill
# from going over.  This script uses MAC addresses (instead of IP addresses), so it works with IPv6
# streams as well.  The filtered device is the bridged "local" network (not the WAN).  If you have more
# or fewer devices, you will need to add filters and target classes for them.  You can share target
# classes if you want devices to share bandwidth.  Bandwidth below 1 mbit/sec is likely to make a
# streaming device fail.  High definition and high movement media streams may look quite bad at
# 3 Mbit/sec where low movement channels like news will look just fine.
 
BW0=200000kbit                  ;# Bandwidth of actual connection.  Default tagged users will share this
BW=3000kbit                     ;# Bandwidth to give ROKU users.
 
MAC_ROKU1=C8:3A:6B:27:F9:B0
MAC_ROKU2=94:E9:79:4A:F1:88
 
DEV=br-lan
TC=$(which tc)
TCF="${TC} filter add dev $DEV parent 1: protocol ip prio 5 u32 match u16 0x0800 0xFFFF at -2"
 
filter_mac() {
 
  M0=$(echo $1 | cut -d : -f 1)$(echo $1 | cut -d : -f 2)
  M1=$(echo $1 | cut -d : -f 3)$(echo $1 | cut -d : -f 4)
  M2=$(echo $1 | cut -d : -f 5)$(echo $1 | cut -d : -f 6)
 
  $TCF match u16 0x${M2} 0xFFFF at -4 match u32 0x${M0}${M1} 0xFFFFFFFF at -8 flowid $2
  $TCF match u32 0x${M1}${M2} 0xFFFFFFFF at -12 match u16 0x${M0} 0xFFFF at -14 flowid $2
}
 
insmod sch_htb 2> /dev/null
 
$TC qdisc add dev $DEV root       handle 1:    htb default 0xA
$TC class add dev $DEV parent 1:  classid 1:1  htb rate ${BW0}
$TC class add dev $DEV parent 1:1 classid 1:10 htb rate ${BW0}
 
$TC class add dev $DEV parent 1:1 classid 1:20 htb rate ${BW}
$TC class add dev $DEV parent 1:1 classid 1:21 htb rate ${BW}
 
filter_mac $MAC_ROKU1 1:20      ;# Filter ROKU1 to 1:20
filter_mac $MAC_ROKU2 1:21      ;# Filter ROKU2 to 1:21
 
$TCF flowid 1:10                ;# Filter everyone else to 1:10
```
