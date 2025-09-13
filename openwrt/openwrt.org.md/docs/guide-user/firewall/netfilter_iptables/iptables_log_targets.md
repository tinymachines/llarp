# Logging Forwarded Packets in OpenWrt

This article demonstrates how to extend the firewall3 configuration to add iptable LOG targets for forwarded packets between the LAN-side and WAN-side of the router.

The [fw3 application](/docs/guide-user/firewall/overview "docs:guide-user:firewall:overview") does not support extended logging rules except for rejected packets, so these must be added using the `iptables` application.

## Requirements

This is a set of simple requirements to implement the iptable LOG rules. The basic idea is they should be simple, easily added and easily flushed.

- log rules must be easily added and removed
- log rules must not affect existing chains
- log rules must be persistent across reboots

Additionally it is recognized that the log rules will impact performance based on how much traffic is logged. The custom firewall rules demonstrate levels of logging from minimal to noisy.

## Custom Firewall Rules

There is no fw3 configuration option to add LOG rules so these are implemented as iptable rules in `/etc/firewall.user` included in `/etc/config/firewall`.

The chains/rules below are comment but some explanation is in order.

1. First create a new chain for logging. All LOG rules are added and flushed from this.
2. Append this chain to the firewall3 `forwarding_rule` (which is actually a chain).
3. Add a rule to the forwarding\_log\_chain to LOG TCP syn packets on HTTP(80) or HTTPS(443). These packets are going from LAN-side to a WAN-side web server to make an HTTP/S connection.
4. Add a rule to LOG TCP ACK-FIN packets on HTTP/S. These packets are going from the LAN-side to the WAN-side to release the HTTP/S connection.

There is an alternative set of rules commented-out to log ALL HTTP/S traffic in both directions (LAN-side and WAN-side). These rules noticeably slow down the router.

Finally, if I've made a mess of things, I can flush all the rules from the logging chain and start again. This is commented out but can be run manually.

```
# create a new chain for logging forwarded packets
iptables -N forwarding_log_chain

# append to openwrt forwarding_rule chain (which generally has nothing in it)
iptables -A forwarding_rule -j forwarding_log_chain

# add log rules all HTTP/S SYN (can use --syn instead of --tcp-flags) and FIN-ACK events
iptables -A forwarding_log_chain -p tcp --dport 80:443 --tcp-flags ALL SYN -j LOG --log-prefix "HTTP-SYN:"
iptables -A forwarding_log_chain -p tcp --dport 80:443 --tcp-flags ALL ACK,FIN -j LOG --log-prefix "HTTP-ACK-FIN:"

# alternative log rule for all HTTP/S events.  NOISY - causes some througput delays)
# iptables -A forwarding_log_chain -p tcp --dport 80:443 -j LOG --log-prefix "HTTP-DPRT-ALL:"
# iptables -A forwarding_log_chain -p tcp --sport 80:443 -j LOG --log-prefix "HTTP-SPRT-ALL:"

# Flush entries from logging chain
# iptables -F forwarding_log_chain
```

## Logging Destination

The iptable rules above will generate a log message for each match with the given log prefix but where do the log messages go?

See [log.essentials](/docs/guide-user/base-system/log.essentials "docs:guide-user:base-system:log.essentials") for an understanding of how openwrt logging works.

One of the best ways to capture the iptable LOG events over a long period is to set up the logging to station on the LAN-side. The station just has to listen on the configured port for log messages and collect them. The messages can be post-processed (e.g. DNS lookup) later.

TCP, I believe, sets up a connection for each log message, which will impact performance. UDP does not do this which makes it much more performant, but also potentially lossy.
