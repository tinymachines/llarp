# IPv6 multicast

## Configuration

While the nature of bridged interfaces will ensure IPv6 multicast traffic is passed between them, it does mean that all multicast traffic will be forwarded across all interfaces, even if there is nobody listening to the multicasted streams. This can quickly saturate the network bandwidth, particularly of a wireless link (which may carry multicast traffic in both directions when only one direction is wanted).

To avoid this, configuring full routing instead of using a bridge will ensure only the necessary traffic is forwarded across interfaces. However in this case an additional multicast routing daemon is required in order to manage which multicast streams are forwarded where. This is because although the Linux kernel handles the actual packet routing, a user-space daemon is required to send and receive MLD messages and to set up the actual routes the kernel uses.

There are a number of different programs that can do this.

### mcproxy

mcproxy is a relative large (1.5 MB) daemon that works well. It contains UCI integration although as of 2021 this does not work, returning shell errors if it is used, however this can be bypassed.

It is installed in the usual way:

```
opkg install mcproxy
```

Since the UCI interface gives shell errors when it is used, the option to use a custom config file must be enabled. Edit `/etc/config/mcproxy` and find the entry for `mcproxy_file`. Set the `disabled` option to `0`. This tells OpenWrt to read the `/etc/mcproxy.conf` file you supply instead of building it from the rest of the values in `/etc/config/mcproxy`.

Remove the default `/etc/mcproxy.conf` as it contains a large, complex example and start from scratch. Use a simple config such as this to begin with:

```
protocol IGMPv3;
protocol MLDv2;

pinstance myProxy: "nicDst" ==> "nicSrc";
```

Here `nicSrc` and `nicDst` are network interface names (as shown with `ip addr`, not the OpenWrt interface name). `nicSrc` is the interface that is providing the multicast data, and `nicDst` is the interface that should receive a copy of the multicast data if someone on that interface has subscribed to it. Note that the arrow suggests the direction has been reversed, but the arrow appears to refer to the direction of subscription messages rather than the direction of the resulting traffic.

Once the config file has been saved, test it with `mcproxy -svv` to display diagnostic information. Once you are happy it is working, start the service in the background with `service mcproxy start`.

### omcproxy

omcproxy is a smaller alternative to mcproxy, taking up less space. It includes UCI and LuCI integration, but unfortunately as of 2021 the project appears to be abandoned and it does not seem to work with OpenWrt. The LuCI integration does not appear to work either.

### smcroute

smcroute is a static multicast router. Rather than listening to MLD messages and setting up routes dynamically, the source and destinations are configured once and the traffic is always forwarded.

This can be a robust alternative for networks where the multicast activity is relatively fixed, such as continuous streaming of security camera feeds or sensor data. In these cases the ability to join and leave multicast groups is not particularly useful (since the receivers want to permanently be part of the multicast groups) so having smcroute forward the data at all times is not a drawback.

On larger networks where bandwidth is limited so the multicast data should only be forwarded when someone is listening, one of the other programs that handle MLD messages is a better choice.

Install smcroute:

```
opkg install smcroute
```

All configuration is done in `/etc/smcroute.conf`. A basic configuration file looks like this:

```
# Tell the kernel and any upstream switch we want these packets.
mgroup from br-lan group ff05::/64

# Specify where to forward packets in this multicast group.
mroute from br-lan group ff05::/64 to wlan0
```

This will route all traffic coming in on the `br-lan` interface, which is being sent to any address in the IPv6 multicast subnet `ff05::/64` and will forward the packets out the `wlan0` interface. Note that all these are system interfaces (as shown with `ip addr`), not OpenWrt interfaces.

smcroute can be started in debug mode during testing:

```
service smcroute stop
smcrouted -n -l debug
```

The [project's GitHub page](https://github.com/troglobit/smcroute "https://github.com/troglobit/smcroute") has good documentation on the configuration file.

Note that smcroute does not set promiscuous mode on the interface. This means incoming multicast packets may not be visible to the machine and if so they cannot be forwarded. The preferred solution is to add an `mgroup` directive to tell the kernel to subscribe to the group. If the hardware is set correctly, this will enable only those packets to arrive on the machine. If this does not work, you will need to go into the OpenWrt interface settings for the source interface and enable promiscuous mode. This will deliver all network traffic to the system. You can test if this is the problem by running `tcpdump` on the source interface, which enables promiscuous mode while it is running. If multicast traffic is forwarded only while `tcpdump` is running, then promiscuous mode needs to be enabled for that interface.

## Testing

When testing multicast routing (e.g. with `ping`) ensure the TTL is set larger than one. By default all multicast packets have a TTL of 1 which means they will not be routed at all. The `-t` option for `ping` will do this, and other programs will have different options.

```
ping -t 4 ff05::1
```

You can use `tcpdump` on the router at each hop to confirm multicast traffic is arriving and leaving on the correct interfaces. If for example traffic should arrive on the `br-lan` interface and be forwarded to `wlan0`, ping packets can be examined like so:

```
$ tcpdump -nn -i br-lan icmp6
20:38:23.819226 IP6 2001:db8::1 > ff08:1500::1: ICMP6, echo request, seq 1, length 64
20:38:24.824981 IP6 2001:db8::1 > ff08:1500::1: ICMP6, echo request, seq 2, length 64
```

The fact that packets appear here confirms that they are making it onto the machine so the upstream network is configured correctly. The same command can then be run on the output interface to make sure the packets are also being forwarded out again:

```
$ tcpdump -nn -i wlan0 icmp6
20:38:23.819226 IP6 2001:db8::1 > ff08:1500::1: ICMP6, echo request, seq 1, length 64
20:38:24.824981 IP6 2001:db8::1 > ff08:1500::1: ICMP6, echo request, seq 2, length 64
```

If these packets do not appear, the multicast daemon has not been configured correctly (or the TTL is too low on the packets and they are being dropped at this node).

If the multicast routes appear to work but only when `tcpdump` is running, try enabling “promiscuous mode” on that interface. `tcpdump` enables this while it is running, and it may be required in order for multicast packets to arrive on the machine. Ideally the switch hardware in the OpenWrt device will have MLD snooping enabled so that it can selectively receive multicast packets, however as of 2021 this functionality is not available, so receiving all packets via promiscuous mode is required.
