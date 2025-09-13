# Firewall usage guide

This section contains useful information and best-practice guides for configuring [firewall3](/docs/guide-user/firewall/overview "docs:guide-user:firewall:overview").

## Rules

### Names

Depending on network topology, there can be a large number of fw3 rules. For maintenance, and debugging, it helps to create a naming scheme to enter in the `name` option of the [config sections](/docs/guide-user/firewall/firewall_configuration "docs:guide-user:firewall:firewall_configuration"). Use whatever pattern works well for you.

One possible pattern for rule names is: **target-port-source-dest**, where:

- **target** is the netfilter target,
- **port** is the port number (see [RFC 793, Section 2.7](https://tools.ietf.org/html/rfc793#section-2.7 "https://tools.ietf.org/html/rfc793#section-2.7")),
- **source** is the zone, device, or specific station the packet originates from, and...
- **dest** is the zone, device, or specific station the packet is destined for

Examples:

ACCEPT a SSH request from any device in the WAN zone of the router to any device in the LAN zone.

```
option name 'ACCEPT-SSH-WAN-LAN'
```

ACCEPT an SSH request from any device in the WAN zone to the router. This is only necessary if the default rule and WAN zone config rule are set to REJECT or DROP.

```
option name 'ACCEPT-SSH-WAN-DEVICE'
```

### Enabling or disabling

The `enabled` option is defined for each functional section and defaulted to *true*. To override it add `option enabled '0`' to a particular rule (or toggle the LuCI *Network → Firewall → Traffic Rule → **Enable*** checkbox.)

This is very useful when adding a rule and quickly enabling/disabling it.

For example, the following rule disables SSH access from a particular station on the WAN-side of the [reference network](/docs/guide-user/firewall/fw3_configurations/fw3_ref_topo "docs:guide-user:firewall:fw3_configurations:fw3_ref_topo") to devices on the LAN-side. Note, for production, it is probably easier to use a MAC address instead of setting up a static DHCP lease and adding separate rules for IPv4 and IPv6.

```
config rule
	option	src		'wan'
	option	dest		'lan'
	option	proto		'tcp'
	option	dest_port	'22'
	option	src_ip		'192.168.3.171'
	option	target		'REJECT'
	option	name		'REJECT-SSH-WANSTA-LAN'
	option	enabled		'0'
```

### Debugging

It is important to test each firewall rule you have added. If it works, GREAT!

If it does not produce the desired result then it is almost certainly a problem with the resulting netfilter rule(s) or rule order. See [Openwrt Netfilter Management](/docs/guide-user/firewall/netfilter_iptables/netfilter_management "docs:guide-user:firewall:netfilter_iptables:netfilter_management") for tips on debugging the problem.

## Default configuration

When the openwrt image is first installed on the target device, it contains a “safe” `/etc/config/firewall` file. This is a useful file to study and potentially save for backup. Note there are a large number of rules commented out that could be uncommented for your use.

It will generally need to be modified for your needs.

The original source for the firewall configuration file is in the firewall package source as `firewall.config`. This is installed to the root file system for the image.
