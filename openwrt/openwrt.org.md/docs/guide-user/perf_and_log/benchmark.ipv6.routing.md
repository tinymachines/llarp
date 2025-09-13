# IPv6 Benchmark Routing Performance

After you install OpenWrt on your Router you should do a IPv6 Routing Benchmark to know how well it performs routing of IPv6 network packets between your local network (LAN) to your internet service provider (WAN) should it already provide IPv6 connectivity.

Diagram below shows the general layout of the benchmark test described below

[![](/_media/media/jperf-ipv6-setup.png?w=600&tok=a87d87)](/_detail/media/jperf-ipv6-setup.png?id=docs%3Aguide-user%3Aperf_and_log%3Abenchmark.ipv6.routing "media:jperf-ipv6-setup.png")

Note that in this setup to simplify the network requirements instead of utilising DHCPv6 IPv6 address propagation, we statically assigned each nodes with static IPv6 addresses unlike the [IPv4 NAT guide](/docs/guide-user/perf_and_log/benchmark.nat "docs:guide-user:perf_and_log:benchmark.nat")

## Rationale

It is important to know the performance of the router in routing IPv6 Packets in order to maximise the subscription you are paying to your internet service provider for the bandwidth allocated when connecting to IPv6 enabled websites and services

In order to make full use of the bandwidth you are paying for, the router has to be able to process IPv6 network packets at rates that exceed the bandwidth of the subscription you are paying for.

You should not take benchmarks found online as a reference because it is now using OpenWrt iptables (Masquerade) to perform routing of IPv6 network packets instead of the factory firmware network stack implementation.

For a graphical approach to testing you can follow the methods to utilise jperf to benchmark Network Address Translation performance as described below:

[Jperf](http://code.google.com/p/xjperf/%E2%80%8E "http://code.google.com/p/xjperf/‎") is [Iperf](http://en.wikipedia.org/wiki/Iperf%E2%80%8E "http://en.wikipedia.org/wiki/Iperf‎") with a Java graphical frontend.

## Prerequisites

- Jperf requires the installation of a Java Runtime before it can be used.
- You can obtain Java Runtime by using OpenJRE on Linux or you can download and install JRE from Oracle Website.
- You need 2 IPv6 gigabit capable computers, one as a server, the other as the client both with Java Runtime installed.
- You should do this on an isolated network to ensure accurate results with minimal disruptions also because some settings used for benchmarking may not be secure.

## Method

1. Download Jperf on both the client and the server.
2. Plug the Server's gigabit Port to the WAN port on the Router.
3. Plug the Client's gigabit to any LAN port on the Router.
4. In order to simplify the steps involved we will use 2001:1::1/64 as the WAN Network and the default 2001:2::1/64 as the LAN Network

### WAN Network Settings

On the Client Computer using Web Browser,Telnet or SSH get to the Router Configuration Page at IP Address 192.168.1.1 and set the network settings on the Router WAN Interface to

Protocol Static IPv6 Address 2001:1::1 IPv6 Prefix 64 Default Gateway

[![](/_media/media/ipv6-wan.png)](/_detail/media/ipv6-wan.png?id=docs%3Aguide-user%3Aperf_and_log%3Abenchmark.ipv6.routing "media:ipv6-wan.png")

Click Save and Apply.

### Server Network Settings

On the Server use its own network configuration tool to set the network settings to

Protocol Static IPv6 Address 2001:1::4 Prefix 64 Default Gateway 2001:1::1

[![](/_media/media/ipv6-server.png?w=800&tok=e48d7f)](/_detail/media/ipv6-server.png?id=docs%3Aguide-user%3Aperf_and_log%3Abenchmark.ipv6.routing "media:ipv6-server.png")

Click Save and Apply.

### LAN Network Settings

On the Client Computer using Web Browser,Telnet or SSH get to the Router Configuration Page at IP Address 192.168.1.1 and set the network settings on the Router LAN Interface to

Protocol Static IPv6 Address 2001:2::1 IPv6 Prefix 64 Default Gateway

[![](/_media/media/ipv6-lan.png)](/_detail/media/ipv6-lan.png?id=docs%3Aguide-user%3Aperf_and_log%3Abenchmark.ipv6.routing "media:ipv6-lan.png")

Click Save and Apply.

### Client Network Settings

On the Client use its own network configuration tool to set the network settings to

Protocol Static IPv6 Address 2001:2::2 Prefix 64 Default Gateway 2001:2::1

[![](/_media/media/ipv6-client.png?w=800&tok=71a016)](/_detail/media/ipv6-client.png?id=docs%3Aguide-user%3Aperf_and_log%3Abenchmark.ipv6.routing "media:ipv6-client.png")

Click Save and Apply.

### Network Settings Verification

By this step your client should be able to ping the server successfully by the command:

```
ping 2001:1::4 
```

You should get a series of ping echo response if not recheck your network settings or turn off your firewall on both the Client and the Server.

## Setting Up Jperf

Extract the compressed files in Jperf to a folder. If you are running Linux you might need to set the execute bit on jperf.sh. Open a Terminal in that directory and run

```
chmod +x jperf.sh
```

In Windows you run Jperf by double clicking jperf.bat. In UNIX you run Jperf by executing jperf.sh.

### Set Server To Listen

You should be able to see the jperf main screen.

You need to set the Jperf on the Server to listen first before we can run the Client.

Remember to check the IPv6 checkbox to bind to the IPv6 interface

For the Server, simply select Server and change the metric to Mbits for easy reference and comparison as shown below.

Then click run Iperf to set the Server to listening mode.

For TCP select TCP as shown below, for UDP select UDP

[![](/_media/media/jperf-ipv6-server.png)](/_detail/media/jperf-ipv6-server.png?id=docs%3Aguide-user%3Aperf_and_log%3Abenchmark.ipv6.routing "media:jperf-ipv6-server.png")

### Start Benchmark On Client

For the Client Computer, simply select Client and enter the Server Address 2001:1::4 and change the metric to Mbits as well.

[![](/_media/media/jperf-ipv6-client.png?w=1000&tok=c24921)](/_detail/media/jperf-ipv6-client.png?id=docs%3Aguide-user%3Aperf_and_log%3Abenchmark.ipv6.routing "media:jperf-ipv6-client.png")

For UDP, you need to set the bandwidth to line rate eg. 900Mbits and observe the actual throughput on the receiver Server as shown below

[![](/_media/media/jperf-ipv6-udp.png?w=1000&tok=3ebea1)](/_detail/media/jperf-ipv6-udp.png?id=docs%3Aguide-user%3Aperf_and_log%3Abenchmark.ipv6.routing "media:jperf-ipv6-udp.png")

When you are ready click run Iperf to start the test. After the test ends you should ALWAYS analyse the result on the Server for accuracy instead of the Client since only the network packets that get through matters not the packets generated.

[![](/_media/media/doc/howtos/jperf_result.png)](/_detail/media/doc/howtos/jperf_result.png?id=docs%3Aguide-user%3Aperf_and_log%3Abenchmark.ipv6.routing "media:doc:howtos:jperf_result.png")

For the above picture it indicates that the Router will be generally sufficiently powerful enough for a &lt; 250Mbps Internet Subscription Plan.

Note that OpenWrt does Routing and Lookups in Software so any activities that taxes the router's processor will affect the Network Address Translation performance including accessing the router web server LuCI, Telnet sessions, SSH sessions, Samba file copy etc. Running Network Congestion Control software like SQM also reduces the network throughput performance.
