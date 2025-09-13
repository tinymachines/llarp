# IPsec Site-to-Site

This article assumes you have enabled IPSec on your OpenWrt router as described in the [basics guide](/docs/guide-user/services/vpn/strongswan/basics "docs:guide-user:services:vpn:strongswan:basics") and the [firewall guide](/docs/guide-user/services/vpn/strongswan/firewall "docs:guide-user:services:vpn:strongswan:firewall"). Now we want to build the first site to site tunnel.

## Topology

The task to achive is the connectivity of our home (W)LAN with our company's networks. To make it not too easy we also want to access the company's DMZ through the tunnel. Here the (more or less) big picture.

[![](/_media/doc/howto/ipsec_site_to_site.png)](/_detail/doc/howto/ipsec_site_to_site.png?id=docs%3Aguide-user%3Aservices%3Avpn%3Astrongswan%3Asite2site "doc:howto:ipsec_site_to_site.png")

Additionally we sum up the facts in text mode to explain the infrastructure in detail.

- The interest of our efforts is to get from a computer in the home W(LAN) into the ACME DMZ and internal networks.
- All traffic should be securely tunneled between our OpenWrt based router and the company's firewall.
- We do not care about our routers external IP. So we name it x.x.x.x.
- The external IP of the ACME firewall is 7.7.7.7. At least this should be a fixed access point throughout the internet.
- Our home (W)LAN uses IP adresses 192.168.2.64/26. That is the subnet from 192.168.2.64 to 192.168.2.127.
- ACMEs internal LAN is 10.1.2.0/24 (IP range between 10.1.2.1 and 10.1.2.254)
- The ACME DMZ has official IP addresses in the range 66.77.88.192/26.

This may not be the most basic setup but it is the simplest to show some facts. You can access multiple subnets through one remote IPsec gateway, you can tunnel official IP adresses and you do not need a fixed external IP address.

## Strongswan Configuration

To reach the ACME infrastructure we have to tell racoon all the details about the tunnel and the remote networks. We provide all informations in the central [/etc/config/ipsec](/docs/guide-user/services/vpn/strongswan/configuration "docs:guide-user:services:vpn:strongswan:configuration") file. The required informations for Phase 1 (initial handshake) are:

- IP of the remote gateway: 7.7.7.7
- Aggressive Negotiation: Always a good idea if our router has a changing outside IP.
- The local identfier. “bratwurst” was choosen in this case. Also needed with a changing outside IP.
- Proposal: The most common standard for medium security level. A preshared key with Diffie Hellman group 2 and AES 128 Bit encryption.

For the tunnels we need security policies. There are two different subnets we want to reach so two sainfo blocks have to be created in our file. These define the so called Phase 2 proposals. We provide:

- Definiton of the connected local and remote subnets
- Security parameters (similar to phase 1)

```
#/etc/config/ipsec
config 'ipsec'
  list listen ''
  
config 'remote' 'acme'
  option 'enabled' '1'
  option 'gateway' '7.7.7.7'
  option 'pre_shared_key' 'yourpasswordhere'
  option 'exchange_mode' 'aggressive'
  option 'local_identifier' 'bratwurst'
  list   'p1_proposal' 'pre_g2_aes_sha1'
  list   'tunnel' 'acme_dmz'
  list   'tunnel' 'acme_lan'

config 'p1_proposal' 'pre_g2_aes_sha1'
  option 'encryption_algorithm' 'aes128'
  option 'hash_algorithm' 'sha1'
  option 'dh_group' '2'

config 'tunnel' 'acme_lan'
  option 'local_subnet' '192.168.2.64/26'
  option 'remote_subnet' '10.1.2.0/24'
  option 'p2_proposal' 'g2_aes_sha1'

config 'tunnel' 'acme_dmz'
  option 'local_subnet' '192.168.2.64/26'
  option 'remote_subnet' '66.77.88.192/26'
  option 'p2_proposal' 'g2_aes_sha1'

config 'p2_proposal' 'g2_aes_sha1'
  option 'pfs_group' '2'
  option 'encryption_algorithm' 'aes128'
  option 'authentication_algorithm' 'sha1'
...
```

Restart Charon and firewall afterwards. If everything was setup correctly according to the [basics](/docs/guide-user/services/vpn/strongswan/basics "docs:guide-user:services:vpn:strongswan:basics") and [firewall](/docs/guide-user/services/vpn/strongswan/firewall "docs:guide-user:services:vpn:strongswan:firewall") guide you should be able to see the new configuration.

... pictures with checks ...

## Central Side Gateway

ACME corporation uses a Juniper firewall. They kindly provided us some configuration pictures. Take them as a sample for your individual implementation.

Phase 1 settings

[![](/_media/doc/howto/ipsec_juniper1.png)](/_detail/doc/howto/ipsec_juniper1.png?id=docs%3Aguide-user%3Aservices%3Avpn%3Astrongswan%3Asite2site "doc:howto:ipsec_juniper1.png")

Phase 2 settings

[![](/_media/doc/howto/ipsec_juniper2.png)](/_detail/doc/howto/ipsec_juniper2.png?id=docs%3Aguide-user%3Aservices%3Avpn%3Astrongswan%3Asite2site "doc:howto:ipsec_juniper2.png")

## Firewall

To reach the remote subnets the last thing we need are two firewall rules. Simply allow all traffic from the local lan 192.168.2.64/26 to the ACME subnets. If you join multiple tunnels in the one zone called VPN you have to use explicit destination adresses to separate traffic. An ALL→ALL rule would allow traffic to all destination networks. And do not forget to contact the ACME firewall admin to add those access rules too.

[![](/_media/doc/howto/ipsec_fw_site2site.png)](/_detail/doc/howto/ipsec_fw_site2site.png?id=docs%3Aguide-user%3Aservices%3Avpn%3Astrongswan%3Asite2site "doc:howto:ipsec_fw_site2site.png")

## DNS

Connecting two private networks opens an interesting DNS challenge. The ACME DNS server does not only resolve official server names to IP addresses but also those of ACME internal servers. E.g. hobbit.acme.inc and its IP 10.1.2.42. As we have established a VPN connection we already can reach this host by its address. To get it by its name too we have to offer a name resolution in our home domain. With OpenWrt being very powerful we assume that our router has an active Dnsmasq DNS server. So we have two possibilities to resolve acme.inc addresses.

- **Manually**: Each acme.inc server and its IP address is put into the OpenWrt local hosts file. Dnsmasq will read this list and answer DNS requests for those ACME machines correctly. This should only be an option if we have a very restrictive VPN connection.
- **Automatically**: Dnsmasq forwards requests for acme.inc through the tunnel to the ACME DNS server. This avoids double work.

DNS fowarding through VPN tunnels is almost the same as normal DNS forwarding with one exception. Dnsmasq must use the correct source interface. By default it will use the OpenWrt internet IP for it's requests but this cannot be tunneled. So just expand the Dnsmasq forward settings in LuCI with the OpenWrt internal IP address. In our scenario we wan't to reach ACME DNS at 10.1.2.250 by using our internal IP 192.168.2.82. Don't forget to add this domain on the whitelist otherwise Dnsmasq will detect rebind attacks and discard requests.

[![](/_media/doc/howto/ipsec_dns.png)](/_detail/doc/howto/ipsec_dns.png?id=docs%3Aguide-user%3Aservices%3Avpn%3Astrongswan%3Asite2site "doc:howto:ipsec_dns.png")

## Route-Based VPNs

The instructions above are for a policy-based VPN. Some VPNs (such as Azure gateways supporting IKEv2) are route-based and do not use traffic selectors. All traffic entering the tunnel is sent to the peer. The Strongswan wiki has some [information regarding route-based VPNs](https://wiki.strongswan.org/projects/strongswan/wiki/RouteBasedVPN "https://wiki.strongswan.org/projects/strongswan/wiki/RouteBasedVPN"). In general, the steps for configuring a route-based VPN are as follows:

1. Disable installation of routes in the charon daemon (install\_routes = no in /etc/strongswan.conf)
2. Add an updown script to each route-based connection. The updown script must accomplish the following:
3. Create a tunnel interface for the connection (VTI is currently the only supported tunnel type; XFRM is not currently available in OpenWRT)
4. Add routes to the remote peer using the newly created tunnel device. Ensure the source ip is correct! The tunnel device will only encapsulate packages whose source matches the “leftsubnet” parameter.

Here is an example script. You can save this (perhaps as /etc/strongswan.d/ipsec-notify.sh) and invoke it using the “local\_updown” option for the tunnel configuration. This script is more advanced than most of the examples found elsewhere. It will attempt to automatically configure the source IP address when routing into the tunnel (this might matter if you have multiple interfaces on your OpenWRT device).

```
#!/bin/bash

set -o nounset
set -o errexit

VTI_IF="vti${PLUTO_UNIQUEID}"


case "${PLUTO_VERB}" in
    up-client)
        ip tunnel add "${VTI_IF}" local "${PLUTO_ME}" remote "${PLUTO_PEER}" mode vti key "${PLUTO_MARK_OUT%%/*}"
        sysctl -w net.ipv4.conf.${VTI_IF}.disable_policy=1
        ip link set "${VTI_IF}" up
        dev=`ip -4 -o route get ${PLUTO_MY_CLIENT} | awk '{ print $5; }'`
        addr=`ip -4 -o address show ${dev} | awk '{ split($4, fields, "/"); print fields[1]; }'`
        ip route add "${PLUTO_PEER_CLIENT}" dev "${VTI_IF}" src "${addr}"
        ;;
    down-client)
        ip tunnel del "${VTI_IF}"
        ;;
esac
```

**Important!** This code requires that the kmod-ip-vti package is installed. It also requires that a unique mark be set on all tunnel traffic. This is accomplished in /etc/ipsec.conf by adding the mark parameter to the connection section, e.g. “mark=%unique”. There is not currently any UCI analogue for this connection option.

## What's next

You should now understand and what to do in case of local and remote [overlapping subnets](/docs/guide-user/services/vpn/strongswan/overlappingsubnets "docs:guide-user:services:vpn:strongswan:overlappingsubnets").
