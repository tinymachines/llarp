# Routing rules

Netifd supports *IP rule* declarations which are required to implement policy routing.

## IPv4 rules

IPv4 rules can be defined by declaring one or more sections of type `rule`, e.g.:

```
config rule
	option mark   '0xFF'
        option in     'lan'
	option dest   '172.16.0.0/16'
	option lookup '100'
```

- `mark`, here `0xFF`, is a [fwmark](http://www.tldp.org/HOWTO/Adv-Routing-HOWTO/lartc.netfilter.html "http://www.tldp.org/HOWTO/Adv-Routing-HOWTO/lartc.netfilter.html") to be matched
- `in`, here `lan`, is the incoming *logical interface name*
- `dest`, here `172.16.0.0/16`, is the destination subnet to match
- `lookup`, here `100`, is the routing table ID to use for the matched traffic

## IPv6 rules

IPv6 rules are denoted by sections of type `rule6`, e.g.:

```
config rule6
        option in     'vpn'
	option dest   'fdca:1234::/64'
	option action 'prohibit'
```

- `vpn` is the incoming *logical interface name*
- `fdca:1234::/64` is the destination subnet to match
- `prohibit` is a routing action to take

## Options for IPv4 and IPv6 rules

Both `rule` and `rule6` sections share the same set of defined options.

Name Type Required Default Description `in` string no *(none)* Specifies the incoming *logical interface name* `out` string no *(none)* Specifies the outgoing *logical interface name* `src` ip subnet no *(none)* Specifies the source subnet to match (CIDR notation) `dest` ip subnet no *(none)* Specifies the destination subnet to match (CIDR notation) `tos` integer no *(none)* Specifies the TOS value to match in IP headers `mark` mark/mask no *(none)* Specifies the *fwmark* and optionally its mask to match, e.g. `0xFF` to match mark 255 or `0x0/0x1` to match any even mark value `uidrange` integer/integer range no *(none)* Specifies an individual UID or range of UIDs to match, e.g. `1000` to match corresponding UID or `1000-1005` to inclusively match all UIDs within the corresponding range `suppress_prefixlength` integer no *(none)* Reject routing decisions that have a prefix length less than or equal to the specified value `ipproto` integer 0-255 no `0` The **ipproto** element allows you to specify a protocol number in IP rule configuration, enabling rules to target traffic based on the protocol. This aligns with the [IANA Protocol Numbers](https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml "https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml"). The **ipproto** value is an unsigned integer and must be in the range of **0–255**. `invert` boolean no `0` If set to `1`, the meaning of the match options is inverted `priority` integer no *(incrementing)* Controls the order of the IP rules, by default the priority is auto-assigned so that they are processed in the same order they're declared in the config file `lookup` routing table at least one of *(none)* The rule target is a table lookup, the ID can be either a numeric table index ranging from `0` to `65535` or a symbolic alias declared in `/etc/iproute2/rt_tables`. The special aliases `local` (`255`), `main` (`254`) and `default` (`253`) are recognized as well `goto` rule index The rule target is a jump to another rule specified by its `priority` value `action` string The rule target is one of the routing actions outlined in the table below `disabled` boolean no `0` Specifies if the rule should be set or not.

## Routing actions

Action Description `unicast` Permit the traffic; the rule returns the route found in the routing table referenced by the rule `prohibit` When reaching the rule, respond with *ICMP prohibited* messages and abort route lookup `unreachable` When reaching the rule, respond with *ICMP unreachable* messages and abort route lookup `blackhole` When reaching the rule, drop packet and abort route lookup `throw` Stop lookup in the current routing table even if a default route exists
