# Bandwidth Monitoring Guide

Let's divide the available bandwidth monitoring tools into two sections:

- Tools for current bandwidth usage
- Tools for historical bandwidth usage

## View current bandwidth usage

Interactive bandwidth measurement and monitoring can be achieved with the two small tools: bmon and iftop. They require less system resources on your OpenWrt system.

### Using bmon

`bmon` package is available for most platforms and has CLI and HTML interfaces.

CLI interface: Run bmon from SSH to see the standard CLI interface. Pressing “g” shows a graph with the current bandwidth being used. Pressing “d” shows the details of it.

HTML interface: you can optionally configure bmon to output in HTML. To do that you need to install the uhttp package and do a little bit of configuration. It is not too hard; here are the steps:

```
opkg install uhttpd bmon
/etc/init.d/uhttpd start
mkdir /tmp/bmon
ln -s /tmp/bmon/ /www/
bmon -o html:path=/www/bmon/
```

To only run to HTML output so you can start on boot (can add the following to rc.local):

```
bmon -o null -O html:path=/www/bmon/ 2>&1 >/dev/null &
```

### Using iftop

`iftop` package allows a deeper insight into data being transferred and active connections. You can run iftop for your bridged LAN interface to show the connections being established, the data being transferred, as well as the bandwidth. From SSH enter the following:

```
opkg install iftop
iftop -i br-lan
```

[![iftop](/_media/media/iftop.png?w=400&tok=9d4a38 "iftop")](/_detail/media/iftop.png?id=docs%3Aguide-user%3Aservices%3Anetwork_monitoring%3Abwmon "media:iftop.png")

## View historical bandwidth usage

These tools are more feature-rich applications, moreover many of them can collect statistics from multiple sources (eg. CPU, RAM, disk, etc).  
With the caveats that they consume more system resources on your router, and if you are using flow offloading this data might not be recorded accurately.

Approximate order from most-basic to most-feature-rich:  
wrtbwmon &lt; vnstat &lt; YAMon &lt; luci-app-nlbwmon &lt; luci-app-statistics &lt; bandwidthd &lt; ntop

If you simply want easy historical bandwidth monitoring, consider `luci-app-vnstat` and `luci-app-nlbwmon`. Both can be installed via LuCI and work without configuration. Both use minimal CPU. Both display charts via LuCI (vstat appears in the Status menu). Vnstat monitors traffic at the interface level and can display usage per hour, per day, and per month. Nlbwmon monitors traffic per MAC address but only displays charts per “accounting period”. The accounting period defaults to monthly, but is reconfigurable.

[![luci-app-nlbwmon](/_media/media/luci-app-nlbwmon.png?w=400&tok=7b3593 "luci-app-nlbwmon")](/_detail/media/luci-app-nlbwmon.png?id=docs%3Aguide-user%3Aservices%3Anetwork_monitoring%3Abwmon "media:luci-app-nlbwmon.png")

## Available tools

Other OpenWrt Network Monitoring docs here: [network\_monitoring](/docs/guide-user/services/network_monitoring/start "docs:guide-user:services:network_monitoring:start"). The semi complete list of options available is below:

Home Description opkg [bmon](http://freshmeat.net/projects/bmon/ "http://freshmeat.net/projects/bmon/") a portable bandwidth monitor and rate estimator yes [iftop](http://www.ex-parrot.com/pdw/iftop/ "http://www.ex-parrot.com/pdw/iftop/") iftop does for network usage what top(1) does for CPU usage. iftop shows table of highest bandwidth usage paired on IP source and destination pairs. yes [vnstat](http://humdi.net/vnstat/ "http://humdi.net/vnstat/") a console-based network traffic monitor yes luci-app-vnstat LuCI interface for vnstat yes [collectd](http://collectd.org "http://collectd.org") a daemon which collects different statistics yes [luci\_app\_statistics](/docs/guide-user/luci/luci_app_statistics "docs:guide-user:luci:luci_app_statistics") collectd and rrd-tool based general statistics tool yes [ntop](http://www.ntop.org/ "http://www.ntop.org/") a network traffic probe that shows the network usage no [pmacct](http://www.pmacct.net/ "http://www.pmacct.net/") IP usage accounting suite no [fprobe](http://fprobe.sourceforge.net/ "http://fprobe.sourceforge.net/") Forward aggregated traffic data as NetFlows to tools like ntop or pmacct no [darkstat](https://unix4lyfe.org/darkstat/ "https://unix4lyfe.org/darkstat/") Captures network traffic, calculates statistics about usage, and serves reports over HTTP yes [MRTG](http://oss.oetiker.ch/mrtg/ "http://oss.oetiker.ch/mrtg/") Tobi Oetiker's MRTG - The Multi Router Traffic Grapher no [bwm-ng](http://www.gropp.org/?id=projects&sub=bwm-ng "http://www.gropp.org/?id=projects&sub=bwm-ng") small and simple console-based live network and disk io bandwidth monitor yes [IPTraf-ng](https://github.com/iptraf-ng/iptraf-ng/ "https://github.com/iptraf-ng/iptraf-ng/") IPTraf-ng is a console-based network monitoring program for Linux that displays information about IP traffic. yes [bandwidthd](http://bandwidthd.sourceforge.net/ "http://bandwidthd.sourceforge.net/") builds HTML files with graphs and charts are built by individual IPs yes [wrtbwmon](https://github.com/pyrovski/wrtbwmon "https://github.com/pyrovski/wrtbwmon") Per-user bandwidth monitoring tool for Linux-based routers no [nlbwmon](https://github.com/jow-/nlbwmon "https://github.com/jow-/nlbwmon") LuCI Traffic Usage Monitor; tracks amount of data sent/received per device, per month yes [YAMon](http://usage-monitoring.com "http://usage-monitoring.com") Per-user bandwidth monitoring (and more) with detailed, extensive graphical reporting capabilities no [CloudShark](https://enterprise.cloudshark.org/blog/2014-06-30-capturing-smartphone-traffic-with-openwrt-and-cloudshark "https://enterprise.cloudshark.org/blog/2014-06-30-capturing-smartphone-traffic-with-openwrt-and-cloudshark") capture filtered traffic, then upload to cloud for analyze yes [Netify](https://www.netify.ai/get-netify/openwrt "https://www.netify.ai/get-netify/openwrt") DPI engine with cloud-based bandwidth monitoring, device discovery and analysis yes

## Measuring maximum bandwidth

With higher bandwidth being offered by ISPs it becomes harder both for the end-user and the service provider to provide this bandwidth. That is also why many websites offer speedtests such as [speed.io](https://www.speed.io "https://www.speed.io") and [waveform](https://www.waveform.com/tools/bufferbloat "https://www.waveform.com/tools/bufferbloat") bufferbloat test.

Just because you have gigabit internet does not necessarily mean that each download you do at 100 MB/s. There are many factors that affect your download and/or upload speed.

- The maximum bandwidth the remote server provides you
- The bandwidth between your provider and the provider of the remote server
- The total bandwidth behind the access multiplexer DSLAM or DOCSIS modem
- The bandwidth being used by other clients connected to your OpenWrt router
- The bandwidth your LAN provides (Ethernet or Wi-Fi)

To measure your maximum bandwidth, you should start a terminal with iftop and bmon. Next up you should shut down or disconnect all clients except the machine you're connected to the router with.

Now you can start an online speed test and check the real bandwidth that is been used by these services. You can then open up an additional terminal and start 3 downloads with wget on your OpenWrt router in parallel. Note: you should always tell wget to store large files in “/dev/null”, because otherwise it might crash your router by writing into the RAM until it's full.

```
wget http://speedtest.netcologne.de/test_1gb.bin -O /dev/null &&
wget http://speedtest.qsc.de/1GB.qsc -O /dev/null &&
wget ftp://ftp.halifax.rwth-aachen.de/opensuse/distribution/11.3/iso/openSUSE-11.3-DVD-i586.iso
 -O /dev/null
```

### Troubleshooting bandwidth problems

If you tested your maximum bandwidth and it is either not reaching the maximum contracted with your ISP or only sometimes reaches the maximum there is a short checklist that you should walk through and check.

Sometimes end-user service contracts with ISP state the bandwidth as “up to” which means that they can provide you the maximum bandwidth, but they cannot guarantee that it is available. This is often the case with some ADSL or VDSL providers Germany.

#### Does your local network provide enough bandwidth?

You should make sure that when you do have a 50 Mbit/s line that your LAN has at least 100 Mbit/s. A Gigabit LAN would be recommend for bandwidths greater than 40 Mbit/s, because otherwise your LAN bandwidth might be consumed by local file transfers or other LAN services being used by other clients connected to your router. Try not to make internet bandwidth tests from your wireless network and instead test your wireless network separately by transferring data from cable-connected clients (Ethernet or Fibre) to wireless clients.

#### Is your local network traffic clean?

Running iftop helps you find all traffic that is currently active in your local network. So if another client transfers gigabytes of data within your local network this can also dramatically slow down your internet transfers. Make sure the only connection that is available in your LAN while testing is the test download traffic. Especially services such as SMB (Samba/Windows Workgroups or Domains) produce lots of overhead and unwanted network traffic. Try to find that unwanted network traffic and eliminate the services on the clients that consume the bandwidth.

#### Is your router hardware/software fast enough?

Just make sure that your router has sufficient RAM free and the CPU is not fully used while transferring big amounts of data. Usually this is not a problem, but installing too much software and using your router for other services (which is for some people common with OpenWrt) it can slow down the network management of your router. Also make sure that when you have an internet line that has a bandwidth greater than 70 Mbit/s it is highly recommended to use Gigabit Ethernet.

#### Does your ISP provide the bandwidth promised?

Due to some press reports about ISP not providing the proper bandwidth, many people in the first place start to blame the ISP when their bandwidth is not as expected. In fact most ISPs do all they can to provide the proper bandwidth; blaming them for not trying to do so is often wrong. If you did check all points above and direct downloads from the website or a website directly located in the network of your ISP are still not at the speed expected and that happens around the clock (24hrs/day) you should call your ISP to do bandwidth measurement on his side.
