# IPv4 Benchmark Network Address Translation

After you install OpenWrt on your Router you should do a *Network Address Translation Benchmark* to know how well it performs address translation of network packets between your local network (LAN) to your internet service provider (WAN).

The diagram below shows the general layout of the benchmark test described below:

[![](/_media/media/jperf-ipv4-setup.png?w=600&tok=199f04)](/_detail/media/jperf-ipv4-setup.png?id=docs%3Aguide-user%3Aperf_and_log%3Abenchmark.nat "media:jperf-ipv4-setup.png")

## Rationale

It is important to know the performance of the router in order to maximise the subscription you are paying to your internet service provider for the bandwidth allocated.

In order to make full use of the bandwidth you are paying for, the router has to be able to process network packets at rates that exceed the bandwidth of the subscription you are paying for.

You should not take benchmarks found online as a reference because it is now using OpenWrt iptables (Masquerade) to perform translation of ip address of network packets instead of the factory firmware network stack implementation.

For a graphical approach to testing you can follow the methods to utilise jperf to benchmark Network Address Translation performance as described below:

[Jperf](http://code.google.com/p/xjperf/%E2%80%8E "http://code.google.com/p/xjperf/‎") ![FIXME](/lib/images/smileys/fixme.svg) (as of Jun-2020 the link seems not to be correct) is [Iperf](http://en.wikipedia.org/wiki/Iperf%E2%80%8E "http://en.wikipedia.org/wiki/Iperf‎") with a Java graphical frontend.

## Prerequisites

- Jperf requires the installation of a Java Runtime before it can be used.
- You can obtain Java Runtime by using OpenJRE on Linux or you can download and install JRE from Oracle Website.
- You need 2 gigabit capable computers, one as a server, the other as the client both with Java Runtime installed.
- You should do this on an isolated network to ensure accurate results with minimal disruptions also because some settings used for benchmarking may not be secure.

## Method

1. Download Jperf on both the client and the server.
2. Plug the Server's gigabit Port to the WAN port on the Router.
3. Plug the Client's gigabit to any LAN port on the Router.
4. In order to simplify the steps involved we will use 10.1.1.0/24 as the WAN Network and the default 192.168.1.0/24 as the LAN Network

### WAN Network Settings

On the Client Computer using Web Browser,Telnet or SSH get to the Router Configuration Page at IP Address 192.168.1.1 and set the network settings on the Router WAN Interface to

Protocol Static IP Address 10.1.1.1 Subnet Mask 255.255.255.0 Default Gateway

[![](/_media/media/doc/howtos/openwrt_server_wan.png)](/_detail/media/doc/howtos/openwrt_server_wan.png?id=docs%3Aguide-user%3Aperf_and_log%3Abenchmark.nat "media:doc:howtos:openwrt_server_wan.png")

Click Save and Apply.

### Server Network Settings

On the Server use its own network configuration tool to set the network settings to

Protocol Static IP Address 10.1.1.2 Subnet Mask 255.255.255.0 Default Gateway 10.1.1.1

[![](/_media/media/doc/howtos/server.png)](/_detail/media/doc/howtos/server.png?id=docs%3Aguide-user%3Aperf_and_log%3Abenchmark.nat "media:doc:howtos:server.png")

Click Save and Apply.

### Network Settings Verification

By this step your client should be able to ping the server successfully by the command:

```
ping 10.1.1.2 
```

You should get a series of ping echo response if not recheck your network settings or turn off your firewall on both the Client and the Server. There is no need to change the LAN Settings as by default OpenWrt sets LAN to 192.168.1.0/24 in DHCP Mode.

## Setting Up Jperf

Extract the compressed files in Jperf to a folder. If you are running Linux you might need to set the execute bit on jperf.sh. Open a Terminal in that directory and run

```
chmod +x jperf.sh
```

In Windows you run Jperf by double clicking jperf.bat. In UNIX you run Jperf by executing jperf.sh.

### Set Server To Listen

You should be able to see the jperf main screen.

You need to set the Jperf on the Server to listen first before we can run the Client.

For the Server, simply select Server and change the metric to Mbits for easy reference and comparison as shown below.

Then click run Iperf to set the Server to listening mode.

For TCP select TCP as shown below, for UDP select UDP

[![](/_media/media/doc/howtos/jperf_server.png)](/_detail/media/doc/howtos/jperf_server.png?id=docs%3Aguide-user%3Aperf_and_log%3Abenchmark.nat "media:doc:howtos:jperf_server.png")

### Start Benchmark On Client

For the Client Computer, simply select Client and enter the Server Address 10.1.1.2 and change the metric to Mbits as well.

[![](/_media/media/doc/howtos/jperf_client.png)](/_detail/media/doc/howtos/jperf_client.png?id=docs%3Aguide-user%3Aperf_and_log%3Abenchmark.nat "media:doc:howtos:jperf_client.png")

For UDP, you need to set the bandwidth to line rate eg. 900Mbits and observe the actual throughput on the receiver Server as shown below

[![](/_media/media/jperf-udp.png?w=1000&tok=6e2be0)](/_detail/media/jperf-udp.png?id=docs%3Aguide-user%3Aperf_and_log%3Abenchmark.nat "media:jperf-udp.png")

When you are ready click run Iperf to start the test. After the test ends you should ALWAYS analyse the result on the Server for accuracy instead of the Client since only the network packets that get through matters not the packets generated.

[![](/_media/media/doc/howtos/jperf_result.png)](/_detail/media/doc/howtos/jperf_result.png?id=docs%3Aguide-user%3Aperf_and_log%3Abenchmark.nat "media:doc:howtos:jperf_result.png")

For the above picture it indicates that the Router will be generally sufficiently powerful enough for a &lt; 250Mbps Internet Subscription Plan.

Note that OpenWrt does Network Address Translation in Software so any activities that taxes the router's processor will affect the Network Address Translation performance including accessing the router web server LuCI, Telnet sessions, SSH sessions, Samba file copy etc. Running Network Congestion Control software like SQM also reduces the network throughput performance.
