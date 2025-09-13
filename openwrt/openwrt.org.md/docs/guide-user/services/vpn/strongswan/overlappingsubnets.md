# IPsec With Overlapping Subnets

One of the most common problems when establishing VPN tunnels are overlapping subnets. I.e. the IP adresses at least on one tunnel end conflict with the existing setup. Very often the firewall administrator is struggling with such a setup because special settings have to take place to create correct address translation for a clean solution. Hopefully this article will help the OpenWrt user to make it fuss-free. We assume you have read the [basics](/docs/guide-user/services/vpn/strongswan/basics "docs:guide-user:services:vpn:strongswan:basics") and the [firewall](/docs/guide-user/services/vpn/strongswan/firewall "docs:guide-user:services:vpn:strongswan:firewall") setup guide for IPsec.

## Real Life Example

So what is it all about. Let us start with a picture and some explanations. What do we have?

- ACME company with internal subnet 10.1.2.0/24 has an existing tunnel to another company with subnet 192.168.2.0/24. The firewall therefore will route all packets with destination 192.168.2.1-192.168.2.254 into the existing tunnel.
- Our OpenWrt user at home has already a IPsec VPN connection too. The OpenWrt firewall protects their network 192.168.2.64/26 and routes all traffic to 10.1.0.0-10.1.3.254 towards the established tunnel to another company.
- When establishing a new tunnel between home and ACME without address translation we would run into routing conflicts. E.g. if we want to reach the server 10.1.2.55 from home it could either be a machine in the ACME network or in the others company network.

[![](/_media/doc/howto/ipsec_overlapping_subnets_1.png)](/_detail/doc/howto/ipsec_overlapping_subnets_1.png?id=docs%3Aguide-user%3Aservices%3Avpn%3Astrongswan%3Aoverlappingsubnets "doc:howto:ipsec_overlapping_subnets_1.png")

What to do? Both firewall adminstrators have to choose IP address ranges for the new tunnel that do not overlap with the existing infrastructure. In our case:

- The ACME administrator chooses to “hide” the remote home network behind the subnet 192.168.3.0/26. So when someone from ACME company wants to reach the newly conected home network they have to take on of those addresses instead of the real ones in range 192.168.2.64/26
- The same applies for the home user. They do not want to reach the ACME network with its real IP addresses but changes the target range to 10.1.4.0/24.
- That means each of both sides determines the remote part of the tunnel subnets.

Let us look at the packet flow and see where address translation has to occur. Let us assume we want to reach ACME mailserver on address 10.1.2.55 from our laptop with address 192.168.2.77.

- We cannot use the mailservers real address but have to choose 10.1.4.55 instead. You can see that the lower part of the IP will match the original address while the higher is taken from the translated subnet.
- The laptop sends a packet with header 192.168.2.77→10.1.4.55.
- The OpenWrt firewall has to translate the source address into one that can safely pass the tunnel. Again it will only translate the higher digits. The header will become 192.168.3.13→10.1.4.55. If not sure why 2.77 is converted to 3.13 you just have to check the last bits of the home netmask ...11000000. Only the last 6 bits will be retained.
- The packet is sent into the tunnel.
- When it reaches the ACME firewall it will be translated again. This time the destination address will be mapped over to the real addresses. The header will be changed to 192.168.3.13→10.1.2.55
- The answer packet of the mailserver will travel this chain backwards.

**Conclusion: If you have IP conflicts in a new VPN setup first of all choose alternative addresses for packets that will pass the tunnel. Retain the subnet masks for both ends.**

## Linux NAT

Now that we know where and how to change IP addresses we will make a short excursion into the Linux netfilter deeps. We have no real choices to implement the above explained translation rules.

- **Source address translation**: Required for outgoing packets. The firewall allows source address translation only in the POSTROUTING chain of the NAT table. This is the very last step of kernel packet mangling. This implies a feature and some trouble. All filter rules are applied before source translation. So they can be implemented with the original packets IP addresses. We have no burden to work on translated packets. On the other hand the firewall cannot know that the packet is routed into an IPsec tunnel before the translation takes place. As mentioned [here](/docs/guide-user/services/vpn/ipsec/racoon/firewall#preface "docs:guide-user:services:vpn:ipsec:racoon:firewall") our firewall script already observes these quirks.
- **Destination address translation**: Required for incoming packets. The right place is the PREROUTING chain of the NAT table. The firewall will jump there before any filter chain is traversed. And again we have the possibility to build filter rules based on how we “see” our internal network topology - with the real local addresses.
- **iptables module**: When most of us think about address translation in the kernel the SNAT and DNAT rules come into mind. If you dig into the documentation you will soon discover that they work well only on single addresses. If you provide address ranges these modules will apply some kind of randomness. So what we need is a 1:1 subnet mapping. The command of interest is **NETMAP**. It will replace the higher address bits of a IP address with a new subnet while keeping the lower bits. This will help us to stay deterministic and to keep number of firewall rules small.

## OpenWrt Firewall Rules

Once again we want to integrate the required rules nicely into the OpenWrt firewall concept. Let us start with the destination translation in the prerouitng chain. We want to translate the target IP of packets that come out of the tunnel into the matching ones of our internal subnet. OpenWrt automatically creates two chains for the VPN zone: zone\_vpn\_prerouting and prerouting\_vpn. They are already linked correctly but have to be populated correctly. Just a source/destination address match paired with a NETMAP translation will do what is required. Have a look at the picture.

[![](/_media/doc/howto/ipsec_prerouting_chain.png)](/_detail/doc/howto/ipsec_prerouting_chain.png?id=docs%3Aguide-user%3Aservices%3Avpn%3Astrongswan%3Aoverlappingsubnets "doc:howto:ipsec_prerouting_chain.png")

For outgoing packets we need source translation in the postrouting chain. A zone\_vpn\_nat chain already exists but is not linked correctly. Just place an ACCEPT rule into it for every non-natted IPsec tunnel and a NETMAP rule for every tunnel that requires address translation.

[![](/_media/doc/howto/ipsec_postrouting_chain.png)](/_detail/doc/howto/ipsec_postrouting_chain.png?id=docs%3Aguide-user%3Aservices%3Avpn%3Astrongswan%3Aoverlappingsubnets "doc:howto:ipsec_postrouting_chain.png")

## Configuration

Nice to know, that the configuration is very simple. The [ipsec](/docs/guide-user/services/vpn/strongswan/basics#ikedaemon "docs:guide-user:services:vpn:strongswan:basics") and [firewall](/docs/guide-user/services/vpn/strongswan/firewall#vpnfirewallscript "docs:guide-user:services:vpn:strongswan:firewall") scripts will take care of the required settings. You just have to add a **local\_nat** configuration line into the tunnel section of your [/etc/config/ipsec](/docs/guide-user/services/vpn/strongswan/configuration "docs:guide-user:services:vpn:strongswan:configuration") file.

```
...
config 'tunnel' 'acme_lan'
  option 'local_nat' '191.168.3.0/26'
  option 'remote_subnet' '192.168.10.0/24'
  option 'local_subnet' '192.168.2.64/26'
  option 'p2_proposal' 'g2_aes_sha1'
...
```

This will tell the system that the local subnet 192.168.2.64/26 will be translated to 192.168.3.0/26 inside the IPsec tunnel.

## What's Next

OpenWrt as a central VPN gateway for [road warriors](/docs/guide-user/services/vpn/strongswan/roadwarrior "docs:guide-user:services:vpn:strongswan:roadwarrior").
