# Darkstat

[https://unix4lyfe.org/darkstat/](https://unix4lyfe.org/darkstat/ "https://unix4lyfe.org/darkstat/")

Darkstat is a packet sniffer that runs as a background process on a cable/DSL router, gathers all sorts of statistics about network usage, and serves them over HTTP. One advantage of darkstat is that it can monitor IPv6 traffic in addition to IPv4 traffic.

It is a very stable application that runs smoothly and requires no maintenance.

NOTE: on 2020-06-07 it was reported that darkstat prevent ssh of working due to a change of ownership of the file /tmp/empty that should be own by root for ssh to work. To correct this, stop darkstat and edit the file /etc.init.d/darkstat to comment the following line:

chown $USER:$GROUP $RUN\_D

The line should look like this:

\# chown $USER:$GROUP $RUN\_D

and start darkstat again.

Alternatively, instead of the solution above, edit the following line in the file /etc/init.d/darkstat:

RUN\_D=/var/empty

to be like that:

RUN\_D=/var/empty/darkstat

## Installation

Installation is very simple:

```
opkg install darkstat
/etc/init.d/darkstat enable
/etc/init.d/darkstat start
```

You can also install it through luci.

Then is you open a web browser at the address of the router on port 667, you will see the traffic graphs.

## Configuration

In OpenWrt, **darkstat** can use almost all of the regular darkstat parameters. These are set in the file */etc/config/darkstat*

```
config darkstat
	option interface        'lan'
	option syslog           false
	option verbose          false
	option no_promisc       false
	option no_dns           false
	option no_macs          false
	option no_lastseen      false
	option httpaddr         '0.0.0.0'
#	option httpport         '667'
#	option network_filter   'not (src net 192.168.1 and dst net 192.168.1)'
#	option network_netmask  '192.168.1.0/255.255.255.0'
	option local_only       false
#	option hosts_max        '1000'
#	option hosts_keep       '500'
#	option ports_max        '60'
#	option ports_keep       '30'
#	option highest_port     '65534'
#	option export_file      'darkstat_export.log'
#	option import_file      'darkstat_export.log'
#	option daylog_file	'darkstat_daylog.log'
```

**Note** In OpenWrt/LEDE 17.01 and below, the last 3 parameters are not available. The config file above is the one currently 18.06 and above (you may need to update the package in 18.06 to have them). Also, in OpenWrt/LEDE 17.01 and below, the init script in /etc/init.d is not a procd script as in 18.06 and above.

**Note**: the init script and the config file found in trunk are compatible with the darkstat found in OpenWrt/LEDE 17.01 and below and provides the last 3 parameters.

Option Explanation Default interfaceCapture traffic on the specified network interface. This is the only mandatory argument.'lan' syslogErrors, warnings, and verbose messages will go to syslog (facility daemon, priority debug) instead of stderr.false verboseProduce more verbose debugging messages.false no\_promiscDo not use promiscuous mode to capture.false no\_dnsDo not resolve IPs to host names. This can significantly reduce memory footprint on small systems as an extra process is created for DNS resolution.false no\_macsDo not display MAC addresses in the hosts table.false httpaddrBind the web interface to the specified address. The default is to listen on all interfaces.'0.0.0.0' httpportBind the web interface to the specified port. The default is 667.Commented out network\_filterUse the specified filter expression when capturing traffic. The filter syntax is beyond the scope of this wiki page; please refer to the tcpdump documentation.Commented out network\_netmaskDefine a “local network” according to the network and netmask addresses. All traffic entering or leaving this network will be graphed, as opposed to the default behaviour of only graphing traffic to and from the local host.Commented out local\_onlyMake the web interface only display hosts on the “local network.” This is intended to be used together with the *network\_netmask* argument.false hosts\_maxThe maximum number of hosts that will be kept in the hosts table. This is used to limit how much accounting data will be kept in memory. The number of *hosts-max* must be greater than *hosts-keep*.Commented out hosts\_keepWhen the hosts table hits *hosts-max* and traffic is seen from a new host, we clean out the hosts table, keeping only the top *hosts-keep* number of hosts, sorted by total traffic.Commented out ports\_maxThe maximum number of ports that will be tracked for each host. This is used to limit how much accounting data will be kept in memory. The number of *ports-max* must be greater than *ports-keep*.Commented out ports\_keepWhen a ports table fills up, this many ports are kept and the rest are discarded.Commented out highest\_portPorts that are numerically higher than this will not appear in the per-host ports tables, although their traffic will still be accounted for. This can be used to hide ephemeral ports. By default, all ports are tracked.Commented out export\_fileOn shutdown, or upon receiving SIGUSR1 or SIGUSR2, export the in-memory database to the named file in the /tmp/empty directory.Commented out import\_fileUpon starting, import a darkstat database from the named file in the /tmp/empty directory.Commented out daylog\_fileLog daily traffic statistics into the named file in the /tmp/empty directory. The daylog format is: localtime time\_t bytes\_in bytes\_out pkts\_in pkts\_outs. Lines starting with a # are comments stating when logging started and stopped. Commented out

## Other Bandwidth Monitoring Applications

Darkstat shows the traffic in real time the traffic for different hosts within your network, but it does not show the traffic profile of the various host over time.

Another application, [Bandwidthd](/docs/guide-user/services/network_monitoring/bandwidthd "docs:guide-user:services:network_monitoring:bandwidthd") allows to see the traffic profile of the various host over time. It also indicate the level of traffic for various type, such as TCP, UDP, ICMP, HTTP, SMTP, FTP. But it cannot show the IPv6 traffic (maybe one day!!).

The various application for monitoring bandwidth in OpenWrt can be found in the documentation page about [Network Monitoring](/docs/guide-user/services/network_monitoring/start "docs:guide-user:services:network_monitoring:start").
