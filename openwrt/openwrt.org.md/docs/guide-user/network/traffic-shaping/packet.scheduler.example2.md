# Example2: plain simple bandwidth/traffic sharing with HTB

```
#!/bin/sh
# We have 1000kbit upload and want to guarantee each user a certain amount of it.
# If one user does not use its full quota, the unused quota get evenly distributed amongst the other users.
 
# Variables
IF_DSL=pppoe-dsl
TC=$(which tc)
IPT=$(which iptables)
IPTMOD="$IPT -t mangle -A POSTROUTING -o $IF_DSL"
IP_USER1=10.0.0.1
IP_USER2=10.0.0.2
IP_USER3=10.0.0.3
IP_USER4=10.0.0.4
 
insmod sch_htb
 
$TC qdisc add dev $IF_DSL root       handle 1:    htb default 40
$TC class add dev $IF_DSL parent 1:  classid 1:1  htb rate 1000kbit
$TC class add dev $IF_DSL parent 1:1 classid 1:10 htb rate 250kbit #-- 25% to user1
$TC class add dev $IF_DSL parent 1:1 classid 1:20 htb rate 250kbit #-- 25% to user2
$TC class add dev $IF_DSL parent 1:1 classid 1:30 htb rate 350kbit #-- 35% to user3
$TC class add dev $IF_DSL parent 1:1 classid 1:40 htb rate 150kbit #-- 15% to user4
 
$IPTMOD -s $IP_USER1 -j CLASSIFY --set-class 1:10
$IPTMOD -s $IP_USER2 -j CLASSIFY --set-class 1:20
$IPTMOD -s $IP_USER3 -j CLASSIFY --set-class 1:30
$IPTMOD -s $IP_USER4 -j CLASSIFY --set-class 1:40
```
