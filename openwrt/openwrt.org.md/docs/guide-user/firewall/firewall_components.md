# Firewall components

The OpenWrt firewall implementation is the mechanism by which network traffic is filtered coming through the router. At a high level, one of three outcomes will occur: either the packet is discarded (dropped) without any further action, rejected (with an appropriate response to the source), or accepted (routed to the destination). Note that the router itself is a destination for management and monitoring.

The OpenWrt firewall revolves around the Linux [netfilter](http://www.netfilter.org "http://www.netfilter.org") project. There are the following main components to the OpenWrt firewall:

1. the [firewall3](/docs/guide-user/firewall/overview "docs:guide-user:firewall:overview") application
2. a set of netfilter hooks in the kernel networking stacks
3. a set of linux kernel modules that handle the inspection of network packets
4. a set of kernel tuning parameters to configure the network stacks and firewall modules

This documentation is based on [OpenWrt 18.06.0](/releases/18.06/notes-18.06.0 "releases:18.06:notes-18.06.0"). Many of the configurations have been tested against this release using the [test network](/docs/guide-user/firewall/fw3_configurations/fw3_ref_topo "docs:guide-user:firewall:fw3_configurations:fw3_ref_topo")

## Firewall3 (fw3)

The [fw3 application](/docs/guide-user/firewall/overview "docs:guide-user:firewall:overview") package is the main application used to provision the firewall. It was developed by the OpenWrt team specifically for the project.

## Kernel netfilter hooks

Each of the network stacks have netfilter functions call `hooks` embedded at specific places in the code. As a network packet moves through the stack, each hook is called to check the packet against possible netfilter rules bound to the hook.

The netfilter hook code uses the `NF_HOOK` set of macros. Each hook takes the following arguments:

- network protocol: unspec (all), ipv4, ipv6, arp, bridge, decnet
- hook num: PRE\_ROUTING, LOCAL\_IN, FORWARD, LOCAL\_OUT, POST\_ROUTING
- net structure: context for the network stack
- socket: BSD socket used for packet
- network packet: a socket buffer containing the network packet
- incoming device (interface): the source of the packet
- outgoing device (interface): the destination of the packet after routing
- a function callback if the packet passes the filter

## Kernel netfilter modules

The netfilter kernel modules are loaded at boot depend on the configured. There are roughly 35 kernel modules to support the standard netfilter capabilities but there are many more depending on the requirements of the router. For example, many routers use the [ipset](http://ipset.netfilter.org/ "http://ipset.netfilter.org/") feature. This adds ~16 additional kernel modules.

Most of the netfilter modules are small, providing a single specific capability. For example:

- `ipt_REJECT` performs REJECT (target),
- `xt_multiport` performs match of the IP port (match)
- `xt_TCPMSS` performs Maximum Segment Size adjustment in the TCP header (target in `mangle` table)

Several of the netfilter modules are larger. For example:

- `nf_conntrack` performs connection tracking for masquerading (NAT) and packet de-fragmentation.

## Kernel tuning via sysctl

The `sysctl` service is executed at boot time. This is a shell script that loads `/etc/sysctl.conf` and all files under `/etc/sysctl.d/`. These set/tune kernel parameters to provide OpenWrt features. See [sysctl.conf](http://man.cx/sysctl.conf "http://man.cx/sysctl.conf").

All are parameters documented under the `Documentation/networking` directory of kernel source tree so the specifics will not be repeated here. See `ip-sysctl.txt` and `nf_conntrack-sysctl.txt` for reference.

![:!:](/lib/images/smileys/exclaim.svg) Since the OpenWrt feature set is fairly static, the kernel parameters almost certainly do not need to tuned beyond the defaults provided in the build.

![:!:](/lib/images/smileys/exclaim.svg) Notice that netfilter bridging support in the kernel is disabled! See `ip-sysctl.txt`:

```
bridge-nf-call-iptables - BOOLEAN
	1 : pass bridged IPv4 traffic to iptables' chains.
	0 : disable this.
	Default: 1
```
