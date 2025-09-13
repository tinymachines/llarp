# IPsec Firewall

When configuring firewalls, tunnels and zones we always have to keep security in mind. First rule should be: Everything that is not allowed explicitly should be denied automatically. This article provides an easy but quite powerful security concept for your IPsec VPN setup. If you missed the [basics](/docs/guide-user/services/vpn/strongswan/basics "docs:guide-user:services:vpn:strongswan:basics") please have look over there first.

## Preface

In the following chapters you will find a detailed description of how to setup firewall rules for IPsec VPN connections. The experienced reader may notice that nowhere iptables IPsec policy rules are used (-m policy --pol ipsec). The reason for that is a special VPN scenario where both tunnel ends use [overlapping IP addresses](/docs/guide-user/services/vpn/strongswan/overlappingsubnets "docs:guide-user:services:vpn:strongswan:overlappingsubnets"). In this case we have do use source NAT (network address translation) rules. **SNAT is only available in the POSTROUTING nat table**. At this late firewall stage the system will discover for the first time that the packet has to pass the IPsec tunnel. Any ipsec policy based filter before will ignore the packet.

## Zones

As in many commercial firewall solutions OpenWrt works with zones. A zone is more or less a bunch of computers that reside in the same network. Common examples are WAN, LAN, WLAN, ... Why not introduce a new zone for computers behind tunnels. Here are two facts that should encourage the use of a new zone named VPN.

- When routing packets to a remote VPN side (e.g. 192.168.10.0/24) the packet will normally go through the firewall chain of the outside interface.
- Computers in a remote VPN are mostly in a secure zone. You should not mix them up with less secure machines (like servers in the internet)
- VPN and WAN in the same zone needs fine granular rules to ensure that packets won't reach an unallowed target.

**Conclusion: Create a new zone and call it vpn.** It is not required to assign an interface to it. If you want to rename the zone to something else you have to adapt parameter **zone** in [/etc/config/ipsec](/docs/guide-user/services/vpn/strongswan/configuration "docs:guide-user:services:vpn:strongswan:configuration").

## Default Rules

We could build our own VPN firewall ruleset with iptables but why not go with LuCI. The interface should be flexible enough to build rules for our new OpenWrt IPsec enhanced router. The basic “Deny All” configuration can be achieved in the upper two panels. You should start with something like that:

[![](/_media/doc/howto/ipsec_firewall.png)](/_detail/doc/howto/ipsec_firewall.png?id=docs%3Aguide-user%3Aservices%3Avpn%3Astrongswan%3Afirewall "doc:howto:ipsec_firewall.png")

Idea behind that is:

- The standard rule is to deny all (first panel)
- Depending on the zone we allow access to the device (INPUT). For our dual band router these are LAN, WLAN2 (2.5 GHz) and WLAN5 (5 GHz)
- The router is allowed to send data into all zones (OUTPUT).
- Sending data between zones is disabled (FORWARD). This will be achieved through firewall rules afterwards.

## Tunnel Endpoints

To allow IPsec communications from a remote VPN Gateway the router must be able to terminate incoming connections. Three rules are required.

- ESP payload: the encrypted data packets
- ISAKMP: Handling of security associations (SA)
- NAT-T: Handling of IPsec between natted devices

The easiest will be to allow all traffic to the Endpoint ports. Although being security paranoid we have to think about [road warriors](/docs/guide-user/services/vpn/ipsec/racoon/roadwarrior "docs:guide-user:services:vpn:ipsec:racoon:roadwarrior") that want to connect from random internet addresses. The input\_rule queue is a a good place to activate those rules manually with the following commands.

```
iptables -A input_rule -p esp -j ACCEPT 
iptables -A input_rule -p udp --dport 500 -j ACCEPT 
iptables -A input_rule -p udp --dport 4500 -j ACCEPT 
```

But we are not interested in manual setup. The solution should automatically integrate itself into the OpenWrt environment. So nothing to do now. We will discuss all different security aspects in detail and at the end of the page you will find a all-in-one script that will take care of everything.

## VPN Rule Orders

Rules for the VPN zone require special considerations especially if you want to edit them with LuCI. Think of the IP address/interface overlap. Your routers default outgoing interface is normally the WAN connection. Every packet that does not match your internal network will leave there. But with active security profiles in the kernel packets e.g. to the remote VPN subnet 192.168.10.0/24 will go out through the WAN interface too. Of course they will be encrypted in advance. A simple rule “Allow all LAN Zone to WAN Zone” matches any packet to one of the remote VPN networks. Placed at the wrong position on top of the list it may conflict with other VPN specific rules that follow.

**Conclusion: The firewall script of at least version 10 will take care about that. You do not have to bother.**

[![](/_media/doc/howto/ipsec_vpn_rules.png)](/_detail/doc/howto/ipsec_vpn_rules.png?id=docs%3Aguide-user%3Aservices%3Avpn%3Astrongswan%3Afirewall "doc:howto:ipsec_vpn_rules.png")

## Outgoing VPN Packets

Up to here it was easy. Now it is time for a deeper firewall inspection. A packet from zone SRC to any other zone will sometime pass the **zone\_SRC\_forward** chain. At this point the firewall checks the packets destination address and forwards or drops it. For each rule we created from SRC to somwhere else an entry has been placed into this chain. The chain sequence is analogous to the order of rules. A comparison of the following picture with the above ruleset should make it clear.

[![](/_media/doc/howto/ipsec_forward_chain.png)](/_detail/doc/howto/ipsec_forward_chain.png?id=docs%3Aguide-user%3Aservices%3Avpn%3Astrongswan%3Afirewall "doc:howto:ipsec_forward_chain.png")

First of all two rules to zone VPN afterwards one to WAN and one to LAN. But with a sharp eye there are still two faults in our chain.

- The packets to zone VPN are not only accepted but forwarded two another still empty chain called zone\_vpn\_ACCEPT. The explanation lies in the rulset generator of LuCI. A zone is normally bound to an interface. A chain with name zone\_xxx\_ACCEPT will check if a source or target of a packet matches the zone XXX. With no interface assigned to zone VPN this chain is left empty. So the packet will not be accepted.
- Not only are we loosing packets but also it would be possible that a packet is allowed to pass because a following rule to a completely different zone has a match. E.g. a packet from zone WLAN2 to IP address 192.168.10.2. Both VPN rules will have no match. But as the packet will leave the router on the WAN interface it will match the third rule (WLAN2→WAN ANY). But that is not our intention. A packet to zone VPN should never be accepted by a rule to another zone.

Two problems two solutions.

- Populating the zone\_vpn\_ACCEPT chain is easy. For each remote VPN network put an ACCEPT entry into that chain. So even a misconfiguration in LuCI will not mess anything up.
- The second one was quite trickier. Sort the VPN rules to the top of the list and put a blocking rule behind the last VPN rule in the chain. This new blocking rule must of course once again check against all networks behind VPN tunnels.

And that what it has to look like afterwards. The zone\_VPN\_ACCEPT and zone\_VPN\_REJECT are populated and zone\_VPN\_REJECT chain inserted at the right position. The VPN networks defined in our /etc/config/ipsec are 192.168.10.0/24 and 62.40.12.192/26.

[![](/_media/doc/howto/ipsec_chain_mod.png)](/_detail/doc/howto/ipsec_chain_mod.png?id=docs%3Aguide-user%3Aservices%3Avpn%3Astrongswan%3Afirewall "doc:howto:ipsec_chain_mod.png")

The naming convention follows the LuCI standard so you won't get confused. Once again no action has to be taken because we will use a script.

## Incoming VPN Packets

Now that outgoing packets are covered by new policies we take care about the other direction. This is much easyier than before. The forward chain misses the jump into zone\_vpn\_forward chain as LuCI once again left it out due to missing associated interfaces. Without an interface we cannot insert the link directly but have to do subnet checkings in a new layer in between. As the picture shows we jump along the chains forward → zone\_VPN\_forward (new) → zone\_vpn\_forward (existing).

[![](/_media/doc/howto/ipsec_chain_mod2.png)](/_detail/doc/howto/ipsec_chain_mod2.png?id=docs%3Aguide-user%3Aservices%3Avpn%3Astrongswan%3Afirewall "doc:howto:ipsec_chain_mod2.png")

In this case a single rule from remote machine 192.168.10.1 to local machine 192.168.213.66 was defined. With the new chain links it will be evaluated by the firewall. This modification will also be accomplished by our script.

## Packets To The Device

If we want to reach the device through a VPN tunnel we have to check the correctness of the INPUT chain. It branches into the input (lowercase!) chain where the system checks it for the different zones. The jump over to the vpn\_zone is missing by default although the chain itself already exists and is populated. So just put this entry at the beginning.

[![](/_media/doc/howto/ipsec_chain_in.png)](/_detail/doc/howto/ipsec_chain_in.png?id=docs%3Aguide-user%3Aservices%3Avpn%3Astrongswan%3Afirewall "doc:howto:ipsec_chain_in.png")

This feature has been introduced in version 9 of our firewall script.

## NAT Translation

Some of our interfaces will run in masquerade mode. The source address of packets that will leave through these interfaces will be translated to the interface address itself. This is an unwanted contrast to VPN networks where IP addresses are usually untouched. Maybe sometime later we will have look at overlapping VPN subnets. This time our challenge lies in the NAT POSTROUTING chain. For each interface that you flagged with masquerading in LuCI a rule is inserted there. When taking no action something like this will happen.

- Our LAN is connected via IPsec to the remote subnet 192.168.10.0/24
- We send a packet to the remote subnet.
- After all filter rules have been applied the packet enters the NAT table
- Our tunnel is terminated on the WAN interface (PPPOE-WAN) with activated masquerading
- The NAT ruleset chooses the WAN zone for the packet
- Therefore the packet source address is translated to our offical WAN IP
- Afterwards it is put into the tunnel
- Ouch!

So once again we have to fix the queue. Therefore we will put a rule at the first position in the chain. This will ensure that packets to foreign VPN subnets will remain untouched.

## Firewall integration

To enable custom firewall rules we hook up with the default firewall mechanism. Ensure that firewall user scripts are loaded and reloaded everytime we (re)start the OpenWrt firewall. Verify/adapt the following lines in /etc/config/firewall

```
config include
        option path '/etc/firewall.user'
        option reload 1
```

Additionally place the call to the ipsec user firewall script into /etc/firewall.user.

```
# This file is interpreted as shell script.
# Put your custom iptables rules here, they will
# be executed with each firewall (re-)start.

# Internal uci firewall chains are flushed and recreated on reload, so
# put custom rules into the root chains e.g. INPUT or FORWARD or into the
# special user chains, e.g. input_wan_rule or postrouting_lan_rule.

/etc/firewall.ipsec 
```

## VPN Firewall Script

Finally we have a look at the script. It injects all the additionally required settings according to [/etc/config/ipsec](/docs/guide-user/services/vpn/strongswan/configuration "docs:guide-user:services:vpn:strongswan:configuration") into the OpenWrt firewall. Save it as **/etc/ipsec/firewall.sh** and put a calling line into **/etc/firewall.user** so it gets loaded automatically. **REMARK: This script only enables VPN firewall rules that have been set in the LUCI web interface. There is no guarantee that manually implemented rules in /etc/config/firewall will work!**

```
#!/bin/sh
#/etc/ipsec/firewall.sh - version 2
 
. /etc/functions.sh
 
GetZone() {
  config_get zone "$1" zone vpn
}
 
GetTunnel() {
  local remote_subnet
  local local_subnet
  local local_nat
 
  config_get remote_subnet "$1" remote_subnet
  config_get local_subnet  "$1" local_subnet
  config_get local_nat     "$1" local_nat ""
  iptables -A zone_${zone}_ACCEPT -d $remote_subnet -j ACCEPT
  iptables -A zone_${zone}_ACCEPT -s $remote_subnet -j ACCEPT
  iptables -A zone_${zone}_REJECT -d $remote_subnet -j reject
  iptables -A zone_${zone}_REJECT -s $remote_subnet -j reject
  iptables -A zone_${zone}_INPUT -s $remote_subnet -j zone_${zone}
  iptables -A zone_${zone}_FORWARD -s $remote_subnet -j zone_${zone}_forward
 
  if [ "$local_nat" == "" ]; then
    iptables -t nat -A zone_${zone}_nat -d $remote_subnet -j ACCEPT
  else
    iptables -t nat -A zone_${zone}_nat -d $remote_subnet \
             -s $local_subnet -j NETMAP --to $local_nat
    iptables -t nat -A prerouting_${zone} -s $remote_subnet \
             -d $local_nat -j NETMAP --to $local_subnet
  fi
}
 
GetRemote() {
  local enabled
  local gateway
 
  config_get_bool enabled "$1" enabled 0
  config_get      gateway "$1" gateway
  [[ "$enabled" == "0" ]] && return
 
  config_list_foreach "$1" tunnel GetTunnel
}
 
GetDevice() {
  . /lib/functions/network.sh
  local interface="$1"
  network_get_device listen "$interface"
  # open IPsec endpoint
  if [ "$listen" == "" ]; then
    iptables -A zone_${zone}_gateway -p esp -j ACCEPT
    iptables -A zone_${zone}_gateway -p udp --dport 500 -j ACCEPT
    iptables -A zone_${zone}_gateway -p udp --dport 4500 -j ACCEPT
    if [ $has_ip6tables -eq 1 ]; then
      ip6tables -A zone_${zone}_gateway -p esp -j ACCEPT
      ip6tables -A zone_${zone}_gateway -p udp --dport 500 -j ACCEPT
      ip6tables -A zone_${zone}_gateway -p udp --dport 4500 -j ACCEPT
    fi
  else
    iptables -A zone_${zone}_gateway -i $listen -p esp -j ACCEPT
    iptables -A zone_${zone}_gateway -i $listen -p udp --dport 500 -j ACCEPT
    iptables -A zone_${zone}_gateway -i $listen -p udp --dport 4500 -j ACCEPT
    if [ $has_ip6tables -eq 1 ]; then
      ip6tables -A zone_${zone}_gateway -i $listen -p esp -j ACCEPT
      ip6tables -A zone_${zone}_gateway -i $listen -p udp --dport 500 -j ACCEPT
      ip6tables -A zone_${zone}_gateway -i $listen -p udp --dport 4500 -j ACCEPT
    fi
  fi
 
}
 
GetInterface() {
  config_list_foreach "$1" listen GetDevice
}
 
zone=vpn
config_load ipsec
config_foreach GetZone ipsec
 
if [ -x /usr/sbin/ip6tables ]; then
  has_ip6tables=1
else
  has_ip6tables=0
fi
 
iptables -F zone_${zone}_ACCEPT
if [ $has_ip6tables -eq 1 ]; then
  ip6tables -F zone_${zone}_ACCEPT
fi
 
iptables -N zone_${zone}_gateway
iptables -I input -j zone_${zone}_gateway
if [ $has_ip6tables -eq 1 ]; then
  ip6tables -N zone_${zone}_gateway
  ip6tables -I input -j zone_${zone}_gateway
fi
config_foreach GetInterface ipsec
 
iptables -t nat -F zone_${zone}_nat
iptables -t nat -I POSTROUTING 2 -j zone_${zone}_nat
iptables -t nat -I PREROUTING 2 -j zone_${zone}_prerouting
 
# sort VPN rules to top of forward zones and insert VPN reject marker afterwards
ForwardZones=`iptables -S | awk '/.N.*zone.*_forward/{print $2}' | grep -v ${zone}`
for ForwardZone in $ForwardZones ; do
  echo "iptables -F $ForwardZone" > /tmp/fwrebuild
  iptables -S $ForwardZone | grep zone_${zone}_ACCEPT | \
    grep -v "^-N" | awk '{ print "iptables " $0}' >> /tmp/fwrebuild
  echo "iptables -A $ForwardZone -j zone_${zone}_REJECT" >> /tmp/fwrebuild
  iptables -S $ForwardZone | grep -v zone_${zone}_ACCEPT | \
    grep -v "^-N" | awk '{ print "iptables " $0}' >> /tmp/fwrebuild
 
  chmod +x /tmp/fwrebuild
  /tmp/fwrebuild
  rm /tmp/fwrebuild
done
 
# link zone_vpn via zone_vpn_INPUT
iptables -N zone_${zone}_INPUT
iptables -I input -j zone_${zone}_INPUT
 
# link zone_vpn_forward via zone_vpn_FORWARD
iptables -N zone_${zone}_FORWARD
iptables -I forward -j zone_${zone}_FORWARD
 
config_foreach GetRemote remote
```

## What's next

With the firewall ready we can start our first IPSec VPN scenario. A [site to site](/docs/guide-user/services/vpn/strongswan/site2site "docs:guide-user:services:vpn:strongswan:site2site") connection.
