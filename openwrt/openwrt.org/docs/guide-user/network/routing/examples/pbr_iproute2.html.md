# Routing example: PBR with iproute2

Routing through your tunnel can be as simple as 'send-it-all', the default if you use LuCI to create the interface, or as complex as you want. Advanced routing is not the purpose of this howto, but if all you want is to do simple source based routing, that is, route traffic through your VPN based in the hosts IP addresses, here is how.

First you need to install the `ip` package (formerly `iproute2`). It allows you, among other things, to enable more than one routing table and to create rules to apply them, without any additional firewall rules. For this to work, host's IP must be always the same. You can configure it manually in the host or designate one in your DHCP using its MAC address or host name.

Now use `opkg` or LuCI to install `ip` and create a new routing table. To do that edit `/etc/iproute2/rt_tables`. It should look like this:

```
#
# reserved values
#
255  local
254  main
253  default
10   vpn
0    unspec
#
# local
#
#1   inr.ruhelp
```

Only the line `10 vpn` was added, and both the number and the name are for you to chose. To learn more about the number and names, read [https://web.archive.org/web/20210902034600/https://serverfault.com/questions/963206/confused-about-iproute2-rt-tables](https://web.archive.org/web/20210902034600/https://serverfault.com/questions/963206/confused-about-iproute2-rt-tables "https://web.archive.org/web/20210902034600/https://serverfault.com/questions/963206/confused-about-iproute2-rt-tables"). Save the file and add one ore more host rules in the terminal. Supposing you want to route two hosts with addresses 192.168.1.20 and 192.168.1.30 (could be any addresses) use

```
ip rule add from 192.168.1.20 table vpn
ip rule add from 192.168.1.30 table vpn
```

Now add a default route to your new table and flush the route cache using

```
ip route add default via <ip_of_the_far_end_of_your_tunnel> dev <pptp_iface_name> table vpn
ip route flush cache
```

**Update:** If you can't get ICMP packets to pass through and thus you are unable to open half of the websites you want, add a few more lines to the above configuration so it looks like:

```
ip rule add from 192.168.1.20 table vpn
ip rule add from 192.168.1.30 table vpn
ip route add 192.168.1.20 dev <pptp_iface_name> table vpn
ip route add 192.168.1.30 dev <pptp_iface_name> table vpn
ip route add default via <ip_of_the_far_end_of_your_tunnel> dev <pptp_iface_name> table vpn
ip route flush cache
```

Now all the traffic from hosts using the alternate routing table will go through the VPN. You can `traceroute` from a VPN routed host to check it. The table you created will survive reboots (it's written), but the route and rules won't so you must add them using a script. Search documentation for the proper way to do that.

**Update:** If you can ping external IP addresses from the host through the VPN, but not any other local hosts in your network (traceroute not working), the default gateway or you (probably) cannot ping qualified domain addresses (DNS not working), check the following:

If you see something like this in your current configuration, it means that the rules you added precede `local` rule. This means that local traffic is routed through the `vpn` table you just added, because new rules have a higher priority. This might be undesirable in many cases.

```
# ip rule list
0:      from 192.168.1.20 lookup vpn
0:      from 192.168.1.30 lookup vpn
0:	from all lookup local 
32766:	from all lookup main 
32767:	from all lookup default
```

All you need to do is to set the correct priority for your rules. Modify the `ip rule add` commands to the following:

```
ip rule add from 192.168.1.20 priority 10 table vpn
ip rule add from 192.168.1.30 priority 10 table vpn
```

You should be able to traceroute to any host on the Internet and verify that your traffic goes through the VPN. You also should be able to ping your default gateway now.

You can do a lot using only `ip` package routing manipulation. For even more complex routing rules, it can also be coupled with `iptables` marking rules: `iptables` marks the packets using `PREROUTING` and `mangle` table, and `ip` routes them according to the marking. Just google for information about it.
