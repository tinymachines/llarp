# Netfilter In OpenWrt

The purpose of this section is to briefly describe the netfilter/iptables subsystem and then delve into OpenWrt specifics.

netfilter rules require a fine level of granularity to tune packet filtering. This **can** cause undesirable scenarios when many rules are matching on similar packets. Be careful using the iptable application!

## Netfilter and iptables Overview

[Netfilter](https://www.netfilter.org/ "https://www.netfilter.org/") is the packet filtering framework inside the [Linux kernel](https://en.wikipedia.org/wiki/Linux%20kernel "https://en.wikipedia.org/wiki/Linux kernel"). It allows for packet filtering, network address \[and port] translation (NA\[P]T) and other packet manipulations. It is far more than a simple firewall and very powerful!

Netfilter has code hooks in the kernel networking stacks (`NF_HOOK_` which are a set of `#define` to one of the `nf_hook` netfilter calls) and a set of netfilter kernel modules (mostly starting with `nf_`, `ipt_` or `xt_`)

[iptables](https://netfilter.org/projects/iptables "https://netfilter.org/projects/iptables") is the user interface to the kernel netfilter subsystem. The iptables application uses the netfilter `libiptc` library to communicate between with the netfilter kernel modules. `libiptc`, like the networking stacks, uses a BSD socket interface to communicate between user-space and kernel-space.

There are many netfilter/iptables references so we will not repeat here, mainly because this would be almost purely a cut-and-paste effort with marginal levels of accuracy. Some good references are:

- [Netfilter Home](http://netfilter.org/ "http://netfilter.org/")
- [Netfilter HOWTO documents](https://www.netfilter.org/documentation/HOWTO/ "https://www.netfilter.org/documentation/HOWTO/")
- [Wikipedia:netfilter](https://en.wikipedia.org/wiki/Netfilter "https://en.wikipedia.org/wiki/Netfilter")
- [Wikipedia:iptables](https://en.wikipedia.org/wiki/Iptables "https://en.wikipedia.org/wiki/Iptables")
- [LHN:Linux Firewalls](http://www.linuxhomenetworking.com/wiki/index.php/Quick_HOWTO_:_Ch14_:_Linux_Firewalls_Using_iptables "http://www.linuxhomenetworking.com/wiki/index.php/Quick_HOWTO_:_Ch14_:_Linux_Firewalls_Using_iptables")
- [iptables Tutorial](https://www.frozentux.net/iptables-tutorial/iptables-tutorial.html "https://www.frozentux.net/iptables-tutorial/iptables-tutorial.html")
- Linux man pages: `iptables` and `iptables-extensions`

## Netfilter Functionality in OpenWrt

This section contains a high-level view of netfilter provided by OpenWrt.

### Netfilter Capabilities

The netfilter capabilities exist in the kernel, either in the monolith or as loadable kernel modules. By default, OpenWrt builds the kernel with a useful set of netfilter capabilities for a robust router.

- NAT
- REJECT
- REDIRECT
- CONNTRACK
- LOG
- TCPMSS
- COMMENT
- MATCH: MAC, STATE (connection state), TIME, MULTIPORT (one or more IP ports), LIMIT...
- MARK
- MASQUERADE

### Netfilter User Interfaces

`iptables` and `ip6tables` user interfaces exist.

![:!:](/lib/images/smileys/exclaim.svg) `ebtables` is no longer available in official versions due to performance implications ([https://forum.openwrt.org/viewtopic.php?pid=94379#p94379](https://forum.openwrt.org/viewtopic.php?pid=94379#p94379 "https://forum.openwrt.org/viewtopic.php?pid=94379#p94379")). Please employ OpenWrt Buildroot if you need ebtables support. The kernel Kconfig settings are `BRIDGE_NF_EBTABLES`.

![:!:](/lib/images/smileys/exclaim.svg) `arptables` is not built, probably same reason as `ebtables`. This is an ipv4 function. The kernel Kconfig settings are `IP_NF_ARPTABLES`.

![FIXME](/lib/images/smileys/fixme.svg) `ebtables` has returned. Were fore-mentioned performance issues fixed?

### Netfilter Tables

By default, OpenWrt uses three netfilter tables: `filter`, `nat`, `mangle`. These are sufficient to provide the desired netfilter functionality.

Two other netfilter tables are: `raw`, `security`.

The `raw` table can be added to the kernel via `make menuconfig` *Kernel modules → Netfilter Extensions → kmod-ipt-raw* . This will enable the netfilter `IP_NF_RAW` config:

```
config IP_NF_RAW
	tristate  'raw table support (required for NOTRACK/TRACE)'
	help
	  This option adds a `raw' table to iptables. This table is the very
	  first in the netfilter framework and hooks in at the PREROUTING
	  and OUTPUT chains.
	
	  If you want to compile it as a module, say M here and read
	  <file:Documentation/kbuild/modules.txt>.  If unsure, say `N'.
```

The `security` table does not seem to be in the OpenWrt menuconfig. There is a reference in the kernel `ipv4/netfilter/Kconfig` to it but it is unclear how to enable kernel support for it.

```
config IP_NF_SECURITY
	tristate "Security table"
	depends on SECURITY
	depends on NETFILTER_ADVANCED
	help
	  This option adds a `security' table to iptables, for use
	  with Mandatory Access Control (MAC) policy.
	 
	  If unsure, say N.
```

### fw3 and netfilter Detailed Example

As was previously mentioned, there are a large number of netfilter references and examples. However, I find it helpful (to myself) to track each step of a specific fw3 rule from definition to packet processing (“[Soup\_to\_nuts](https://en.wikipedia.org/wiki/Soup_to_nuts "https://en.wikipedia.org/wiki/Soup_to_nuts")”).

This example [fw3 application](/docs/guide-user/firewall/overview "docs:guide-user:firewall:overview") configuration rule allows SSH access from any station on the WAN-side of the router to any station on the LAN-side.

```
config rule
	option src 'wan'
	option dest 'lan'
	option proto 'tcp'
	option dest_port '22'
	option target 'ACCEPT'
	option name 'ACCEPT-SSH-WAN-LAN'
```

fw3 UCI parses the rule to the following iptables rule (with some others for context, implicitly created). The rules are listed as they appear in the `fw3 print` listing.

```
...
iptables -t filter -N zone_lan_dest_ACCEPT
iptables -t filter -N zone_lan_dest_REJECT
...
iptables -t filter -N zone_wan_forward
...
# TCP/22 from WAN jumps to zone_lan_dest_ACCEPT chain
iptables -t filter -A zone_wan_forward -p tcp -m tcp --dport 22 -m comment --comment "!fw3: ACCEPT-SSH-WAN-LAN" -j zone_lan_dest_ACCEPT
...
# All TCP from WAN jumps to zone_lan_dest_REJECT
iptables -t filter -A zone_wan_forward -p tcp -m comment --comment "!fw3: REJECT-ALL-WAN-LAN" -j zone_lan_dest_REJECT
...
# zone_lan_dest_ACCEPT jumps to final ACCEPT target
iptables -t filter -A zone_lan_dest_ACCEPT -o br-lan -m comment --comment "!fw3" -j ACCEPT
...
# All traffic jumps to final reject target
iptables -t filter -A zone_lan_dest_REJECT -o br-lan -m comment --comment "!fw3" -j reject
...
# FORWARD hook, jump to chain zone_wan_forward
iptables -t filter -A FORWARD -i eth1 -m comment --comment "!fw3" -j zone_wan_forward
```

The `zone_lan_dest_ACCEPT`, `zone_lan_dest_REJECT` and `zone_wan_forward` chains are created, primarily for convenience so they can be added and removed easily.

The first rule added to the `zone_wan_forward` chain performs a packet match for tcp/22 (SSH) and, if it passes, jumps to the `zone_lan_dest_ACCEPT` chain. Farther down the rules, this chain matches on the output interface `br-lan` (the lan-bridge) and jumps to the final `ACCEPT` target. One nuance to consider: the netfilter output interface does not provide any routing routing information; IFF the network stack decides to route the packet to the LAN then this rule will be invoked.

![:!:](/lib/images/smileys/exclaim.svg) Generally each match and target is a unique kernel module. TCP/22 uses the `xt_tcpudp` module, comment uses the `xt_comment` module (always returns success). The mangle TCPMSS target uses `xt_TCPMSS`; the `reject` target uses `ipt_REJECT`. The `ACCEPT` and `DROP` targets are essentially no-ops: `ACCEPT` allows the network stack to continue processing and `DROP` immediately discards the packet.

If the 'TCP/22' rule does not match, netfilter continues to the next rule which matches all TCP traffic (other than SSH) and jumps to `zone_lan_dest_REJECT`. The next rule chain jumps to the final `reject` target which sends back an ICMP packet to the originator.

Finally, the `zone_wan_forward` chain is appended to the FORWARD hook matching input from the `eth1`, the WAN interface. This hook is statically called in the kernel ipv4 network stack (see the `NF_HOOK` call in `./net/ipv4/ip_forward.c:ip_forward`.)

So that covers a single conceptual rule: TCP/SSH traffic allowed from the WAN to the LAN. NAT is a little more tricky ![;-)](/lib/images/smileys/wink.svg)

### fw3 and netfilter Additional Capabilities

Beyond the standard netfilter capabilities provided in the OpenWrt release, these are useful (but not necessary.)

#### ipset

[ipset](http://ipset.netfilter.org "http://ipset.netfilter.org") is a netfilter mechanism to quickly manage lists of similar entities.

One powerful use is blocking spam. Typically one adds a rule to reject/drop traffic from each source. In the standard firewall, the following rules block a single source from sending a large amount of email spam to the mail server (SMTP is port 25).

Currently, the **most maintainable** mechanism in OpenWrt is to add rules to a new chain in the WAN zone in `/etc/firewall.user`

```
iptables -N spam_block
iptables -A forwarding_rule -j spam_block
iptables -t filter -A spam_block -s 103.110.144.0/22 -p tcp -m tcp --dport 25 -j DROP
iptables -t filter -A spam_block -s 114.67.64.0/18 -p tcp -m tcp --dport 25 -j DROP
...
```

There are thousands of spam sources so the number of rules in the (custom) spam\_block chain can be quite large.

In order to use [ipset](http://ipset.netfilter.org "http://ipset.netfilter.org"), it must be added to the kernel and application package.

In the OpenWrt image build directory, set it in the menu *Kernel Modules → Netfilter Extensions → kmod-ipt-ipset*

Once the kernel is running, add the package using `opkg install ipset`.

![:!:](/lib/images/smileys/exclaim.svg) the `ipset` package install will fail if the kernel has not been built to support it. DO NOT force install!!!!

![FIXME](/lib/images/smileys/fixme.svg) There is probably a better way to add custom firewall capabilities.

##### Using ipset

This example shows how to use `ipset` to block a large number of spammers!

![FIXME](/lib/images/smileys/fixme.svg) not tested yet...

```
config ipset
	option external         spam_block
	option match            'dest_ip dest_port'
	option family           ipv4
	option storage          hash
```

![:!:](/lib/images/smileys/exclaim.svg) Adding each rule to ipset will make `/etc/config/firewall` unmanageable. Put the iptable rules in `/etc/firewall.user`. And there is no point to using ipset for a small number of rules.
