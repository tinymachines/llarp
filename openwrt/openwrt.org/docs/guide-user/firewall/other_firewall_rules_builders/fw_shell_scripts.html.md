# Firewall Builder: Shell scripts

If [firewall3](/docs/guide-user/firewall/overview "docs:guide-user:firewall:overview") is unavailable, one can add netfilter rules manually using the `iptables` command in a shell scripts.

The script could be loaded using [init scripts](/docs/guide-developer/procd-init-scripts "docs:guide-developer:procd-init-scripts") or added to `/etc/rc.local`.

Here is an example netfilter configuration bash script taken from the [freifunk project](https://en.wikipedia.org/wiki/Freifunk "https://en.wikipedia.org/wiki/Freifunk").

This has not been tested. It is retained here for completeness.

```
#!/bin/sh
#
# by rac 2011, placed under GPLv2
#
#############################################################################
# Variables
 
IPT=/usr/sbin/iptables
 
# Interfaces:
IF_LAN=eth0.1
IF_DSL=pppoe-dsl
IF_FUNK=wlan0
 
# Netz IPs:
NET_LAN=192.168.0.0/16
NET_DSL=xxx.xxx.xxx.xxx/16
NET_FUNK=10.0.0.0/8
 
# Eigene IPs:
IP_LAN=192.168.1.1
IP_DSL=$(ifconfig|grep 'inet addr:xxx'|cut -d':' -f2|awk '{print $1}')
IP_FUNK=10.0.0.1
 
# User IPs:
IP_USER1=192.168.1.1
IP_USER2=192.168.2.1
IP_USER3=192.168.3.1
IP_USER4=192.168.4.1
IP_USER5=192.168.5.1
 
# User IP/MAC-Combos:
USER1=" -s 192.168.1.1 -m mac --mac-source xx:xx:xx:xx:xx:xx"
USER2=" -s 192.168.2.1 -m mac --mac-source xx:xx:xx:xx:xx:xx"
USER3=" -s 192.168.3.1 -m mac --mac-source xx:xx:xx:xx:xx:xx"
USER4=" -s 192.168.4.1 -m mac --mac-source xx:xx:xx:xx:xx:xx"
USER5=" -s 192.168.5.1 -m mac --mac-source xx:xx:xx:xx:xx:xx"
 
# Besondere IPs/Netze:
UNI=xxx.xxx.xxx.xxx
NET_VEREIN=xxx.xxx.xxx.xxx/24
NET_DNS=xxx.xxx.xxx.xxx/24
FRIEND1=xxx.xxx.xxx.xxx
 
#############################################################################
# Ketten leeren und löschen
 
$IPT -t filter -F
$IPT -t filter -X
$IPT -t nat -F
$IPT -t nat -X 
#$IPT -t mangle -F  this will be done by the tc script
#$IPT -t mangle -X
$IPT -t raw -F
$IPT -t raw -X
 
if [ "$1" = "stop" ]; then
	echo "Firewall completely flushed! Now running with no firewall."
	exit 0
fi
 
#############################################################################
# Default Policies fuer integrierte Ketten festlegen:
# http://en.wikipedia.org/wiki/File:Netfilter-packet-flow.svg
 
# Policies setzen
$IPT -t raw -P PREROUTING ACCEPT #----- before connection tracking
$IPT -t raw -P OUTPUT ACCEPT #--------- before connection tracking
$IPT -t mangle -P PREROUTING ACCEPT #-- before routing; change TOS, TTL, MARK, etc
$IPT -t mangle -P INPUT ACCEPT #------- 
$IPT -t mangle -P FORWARD ACCEPT #----- 
$IPT -t mangle -P OUTPUT ACCEPT #------ 
$IPT -t mangle -P POSTROUTING ACCEPT #- VOR nat POSTROUTING, MARK by source
$IPT -t nat -P PREROUTING ACCEPT   #--- before routing
$IPT -t nat -P POSTROUTING ACCEPT #---- 
$IPT -t nat -P OUTPUT ACCEPT #--------- 
$IPT -t filter -P INPUT DROP #--------- 
$IPT -t filter -P FORWARD DROP #------- 
$IPT -t filter -P OUTPUT ACCEPT #------ 
 
# Eigene Ketten anlegen
$IPT -N INPUT_dsl
$IPT -N INPUT_lan
$IPT -N INPUT_funk
$IPT -N FWD_lan_dsl
$IPT -N FWD_dsl_lan
$IPT -N FWD_funk_dsl
$IPT -N FWD_dsl_funk
$IPT -N FWD_lan_funk
$IPT -N FWD_funk_lan
$IPT -N nuisance
 
#############################################################################
# FILTER
 
#================================
# INPUT (Policy: DROP)
#---------------------
$IPT -A INPUT -j ACCEPT -i lo -s 127.0.0.1 -d 127.0.0.1 #--------------- loopback
$IPT -A INPUT -j ACCEPT -i $IF_LAN  -p udp --dport 67:68 --sport 67:68 #- DHCP-Anfragen kommen von 255.255.255.255
$IPT -A INPUT -j ACCEPT -i $IF_FUNK -p udp --dport 67:68 --sport 67:68 #- DHCP-Anfragen kommen von 255.255.255.255
$IPT -A INPUT -j ACCEPT -m state --state ESTABLISHED,RELATED #- ALLES, was vom Router aufgebaut wurde, darf wieder zurueck
 
$IPT -A INPUT -j INPUT_lan -i $IF_LAN -s $NET_LAN -d $IP_LAN
$IPT -A INPUT -j INPUT_dsl -i $IF_DSL
$IPT -A INPUT -j INPUT_funk -i $IF_FUNK -s $NET_FUNK -d $IP_FUNK
 
$IPT -A INPUT_lan -j ACCEPT #--------------------- Alles von intern erlaubt
 
$IPT -A INPUT_dsl -j ACCEPT -p icmp -s 0/0 --icmp-type 11 #-------- Time Exceeded
$IPT -A INPUT_dsl -j ACCEPT -p tcp --dport 22 #-------------------- ssh
$IPT -A INPUT_dsl -j LOG       --log-prefix "IPT_dsl-Rej "
$IPT -A INPUT_dsl -j DROP
 
$IPT -A INPUT_funk -j ACCEPT -p icmp --icmp-type 8 #--------------- allow system to be pinged!
$IPT -A INPUT_funk -j ACCEPT -p tcp --dport 8080 #----------------- kleine Nachricht
$IPT -A INPUT_funk -j LOG       --log-prefix "IPT_funk-Rej "
$IPT -A INPUT -j REJECT    --reject-with icmp-host-prohibited
 
#================================
# FORWARD (Policy: DROP)
#-----------------------
$IPT -A FORWARD -j ACCEPT -m state --state ESTABLISHED,RELATED #- ALLES, was bereits aufgebaut wurde, darf auch wieder durch
 
$IPT -A FORWARD -j FWD_lan_dsl -i $IF_LAN -o $IF_DSL -s $NET_LAN
$IPT -A FORWARD -j FWD_dsl_lan -i $IF_DSL -o $IF_LAN
$IPT -A FORWARD -j FWD_funk_dsl -i $IF_FUNK -o $IF_DSL -s $NET_FUNK
$IPT -A FORWARD -j FWD_dsl_funk -i $IF_DSL -o $IF_FUNK
$IPT -A FORWARD -j FWD_lan_funk -i $IF_LAN -o $IF_FUNK -s $NET_LAN
$IPT -A FORWARD -j FWD_funk_lan -i $IF_FUNK -o $IF_LAN -s $NET_FUNK
$IPT -A FORWARD -j LOG       --log-prefix "FORWARD: " #--- duerfte nix uebrig bleiben
$IPT -A FORWARD -j DROP
 
# LAN und DSL
$IPT -A FWD_lan_dsl -j REJECT -p udp --dport 135:139 #--------------- hat nichts im internet verloren
$IPT -A FWD_lan_dsl -j REJECT -p tcp --dport 135:139 #--------------- hat nichts im internet verloren
$IPT -A FWD_lan_dsl -j REJECT -p tcp --dport 445  #------------------ hat nichts im internet verloren
$IPT -A FWD_lan_dsl -j ACCEPT
 
# DSL to LAN (the portforwards)
$IPT -A FWD_dsl_lan -j ACCEPT -p udp --dport 11111 --sport 1024:65535 -d $IP_USER1 -m state --state NEW #- udp
$IPT -A FWD_dsl_lan -j ACCEPT -p tcp --dport 11111 --sport 1024:65535 -d $IP_USER1 -m state --state NEW #- tcp
$IPT -A FWD_dsl_lan -j ACCEPT -p udp --dport 22222 --sport 1024:65535 -d $IP_USER2 -m state --state NEW #- udp
$IPT -A FWD_dsl_lan -j ACCEPT -p tcp --dport 22222 --sport 1024:65535 -d $IP_USER2 -m state --state NEW #- tcp
$IPT -A FWD_dsl_lan -j ACCEPT -p udp --dport 44444 --sport 1024:65535 -d $IP_USER4 -m state --state NEW #- tcp
$IPT -A FWD_dsl_lan -j ACCEPT -p tcp --dport  8000 --sport 1024:65535 -d $IP_USER5 -s $FRIEND1 -m state --state NEW #- tcp
$IPT -A FWD_dsl_lan -j LOG       --log-prefix "FWD_dsl_lan "
$IPT -A FWD_dsl_lan -j DROP
 
# FUNK to DSL
$IPT -A FWD_funk_dsl -j ACCEPT -s 10.10.10.99 -m mac --mac-source 11:22:33:44:55:66 #------- no safety here!
$IPT -A FWD_funk_dsl -j LOG       --log-prefix "FWD_funk_dsl "
$IPT -A FWD_funk_dsl -j REJECT    --reject-with icmp-host-prohibited
 
# DSL to FUNK
$IPT -A FWD_dsl_funk -j LOG       --log-prefix "FWD_dsl_funk "
$IPT -A FWD_dsl_funk -j DROP
 
# LAN to FUNK
$IPT -A FWD_lan_funk -j ACCEPT #------------------------------- alles erlaubt
$IPT -A FWD_lan_funk -j LOG       --log-prefix "FWD_lan_funk "
$IPT -A FWD_lan_funk -j DROP
 
# FUNK to LAN
$IPT -A FWD_funk_lan -j ACCEPT #------------------------------- alles erlaubt
$IPT -A FWD_funk_lan -j LOG       --log-prefix "FWD_funk_lan "
$IPT -A FWD_funk_lan -j DROP
 
#================================
# OUTPUT (Policy: ACCEPT)
#---------------------
 
#############################################################################
# NAT
 
#================================
# PREROUTING (Policy: ACCEPT)
#----------------------------
 
#
# Portforwads:
#
 
$IPT -t nat -A PREROUTING -i $IF_DSL -p udp --dport 11111 -j DNAT --to-destination ${IP_USER1}:11111 #--- udp
$IPT -t nat -A PREROUTING -i $IF_DSL -p tcp --dport 11111 -j DNAT --to-destination ${IP_USER1}:11111 #--- tcp
$IPT -t nat -A PREROUTING -i $IF_DSL -p udp --dport 22222 -j DNAT --to-destination ${IP_USER2}:11111 #--- udp
$IPT -t nat -A PREROUTING -i $IF_DSL -p tcp --dport 22222 -j DNAT --to-destination ${IP_USER2}:11111 #--- tcp
$IPT -t nat -A PREROUTING -i $IF_DSL -p udp --dport 44444 -j DNAT --to-destination ${IP_USER4}:11111 #--- udp
$IPT -t nat -A PREROUTING -i $IF_DSL -p tcp --dport 55555 -j DNAT --to-destination ${IP_USER5}:11111 #--- tcp
 
#================================
# POSTROUTING (Policy: ACCEPT)
#-----------------------------
$IPT -t nat -A POSTROUTING -o $IF_DSL -j MASQUERADE #--------------- Alles ins Internet auf Router-IP naten
 
#############################################################################
# MANGLE
 
#================================
# POSTROUTING (Policy: ACCEPT)
#----------------------------
# included in the tc script
```
