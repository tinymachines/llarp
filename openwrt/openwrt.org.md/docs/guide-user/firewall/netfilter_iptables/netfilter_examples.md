# netfilter Configuration Examples

This section contains a collection of netfilter configuration examples that are difficult or impossible to provision through the [fw3 application](/docs/guide-user/firewall/overview "docs:guide-user:firewall:overview").

These rule sets will generally be added to `/etc/firewall.user` and will be parsed after the fw3 configuration. Rules added using `-A` will be appended to the end of the existing chain so may not be run if there is a prior match. Use `-I [rulenum]` to insert the rule after rulenum in the chain (default is adding as the first rule.)

To reiterate an earlier point, the netfilter chains can get a tricky because the [fw3 application](/docs/guide-user/firewall/overview "docs:guide-user:firewall:overview") implicitly creates a number of them to organize rule sets. See [netfilter management](/docs/guide-user/firewall/netfilter_iptables/netfilter_management "docs:guide-user:firewall:netfilter_iptables:netfilter_management") for tools to diagnose `iptables` commands.

The examples in this section explicitly use the `iptables` application and not fw3 UCI configurations.

## Limit incoming traffic from the WAN zone

This example uses the netfilter `limit` match to forward at most 1000 packets/second from the WAN-sid to the LAN-side. After the number of packets exceeds the limit (1000/s), a subsequent rule will be processed until the policy (which is usually set to DROP.)

```
# create a new chain and append to the forwarding_wan chain
iptables -N wan_forward_limit
iptables -A wan_forward_limit -m limit --limit 1000/s --limit-burst 10000 -j RETURN
iptables -A forwarding_wan_rule -j wan_forward_limit
```

For practical reasons, this rule would only used if the LAN-side network is very slow/congested (for example, a T1 ~1.5Mbit throughput).

As an example of a rule implicitly created by fw3, this rule is created when the `Enable SYN-flood protection` checkbox is set. This rule prevents a DDoS syn-flood attack by limiting the number of TCP SYN packets to 25/sec. All SYN packets after the limit are handled by a subsequent rule.

```
iptables -t filter -A syn_flood -p tcp -m tcp --tcp-flags FIN,SYN,RST,ACK SYN -m limit --limit 25/sec --limit-burst 50 -m comment --comment "!fw3" -j RETURN
```
