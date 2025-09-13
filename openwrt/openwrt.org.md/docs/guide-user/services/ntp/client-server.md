# NTP client / NTP server

See also [NTP](/docs/guide-user/advanced/ntp_configuration "docs:guide-user:advanced:ntp_configuration")

**`Note:`** most devices supported by OpenWrt do not have a hardware clock.

You can set the system date and time using one of the following methods:

- *Manually* by utilizing **`busybox-date`** , e.g.
  
  ```
  date -s  hh:mm[:ss] or [YYYY.]MM.DD-hh:mm[:ss] or YYYY-MM-DD hh:mm[:ss] or [[[[[YY]YY]MM]DD]hh]mm[.ss]
  ```

<!--THE END-->

- [*Network Time Protocol*](https://en.wikipedia.org/wiki/Network%20Time%20Protocol "https://en.wikipedia.org/wiki/Network Time Protocol") by invoking **`busybox-ntpd`** once, e.g.:
  
  ```
  ntpd -q -p ptbtime1.ptb.de
  ```
  
  , or configure `/etc/config/system` accordingly to have nptd run as NTP client (and optionally additionally as NTP server) daemon. By default busybox-ntpd runs as a client and does not serve time. You can set the UCI option `enable_server` in `/etc/config/system` (in the ntp section) to enable serving time as well.

<!--THE END-->

- [*Time Protocol*](https://en.wikipedia.org/wiki/Time%20Protocol "https://en.wikipedia.org/wiki/Time Protocol") ![:!:](/lib/images/smileys/exclaim.svg) **Obsolete** Use rdate ( **`busybox-rdate`** ) to set the time:
  
  ```
  rdate -s time.protocol.server.org
  ```
  
  Use with `/etc/crontabs/root`

<!--THE END-->

1. *Other NTP packages* If the default busybox-ntpd isn't sufficient, one of the following alternate ntpd packages can be installed:

Name Version Size Description ntpclient 2007\_365-4 12.970 NTP client for setting system time from NTP servers. ntpd 4.2.6p4-1 168.021 The ISC ntp suite is a collection of tools used to synchronize the system clock with remote NTP time servers and run/montior local NTP servers. This package contains the [ntpd](https://en.wikipedia.org/wiki/ntpd "https://en.wikipedia.org/wiki/ntpd") server. See [ntpd](http://man.cx/ntpd "http://man.cx/ntpd") ntpd-ssl 4.2.6p4-1 179.511 The ISC ntp ... . This package contains the ntpd server with OpenSSL support. ntpdate 4.2.6p4-1 36.642 The ISC ntp ... . This package contains [ntpdate](https://en.wikipedia.org/wiki/ntpdate "https://en.wikipedia.org/wiki/ntpdate"). See [ntpdate](http://man.cx/ntpdate "http://man.cx/ntpdate") ntp-utils 4.2.6p4-1 158.035 The ISC ntp ... . This package contains `ntpdc` and `ntpq`.

NTP (Network Time Protocol) is used to keep computer clocks accurate by synchronizing them over the Internet or a local network, or by following an accurate hardware receiver that interprets GPS, DCF-77, NIST or similar time signals.

This package contains the NTP daemon and utility programs. An NTP daemon needs to be running on each host that is to have its clock accuracy controlled by NTP. The same NTP daemon is also used to provide NTP service to other hosts.

![](/_media/meta/icons/tango/48px-outdated.svg.png) In [R28612](https://dev.openwrt.org/changeset/28612 "https://dev.openwrt.org/changeset/28612") and [R28613](https://dev.openwrt.org/changeset/28613 "https://dev.openwrt.org/changeset/28613") `busybox-rdate` has been replaced with `busybox-ntpd` by default.  
If you check the entire file [Config.in](https://dev.openwrt.org/browser/trunk/package/busybox/config/networking/Config.in?rev=28613 "https://dev.openwrt.org/browser/trunk/package/busybox/config/networking/Config.in?rev=28613") not only the diffs above, you will learn that busybox-ntpd *is* employable as server as well by default.

The `busybox-ntpd` will auto-tune its sync rate depending on clock drift and other factors, it varies between 1-60min, and yes its a daemon which keeps syncing the time. When invoking it with `-q` it would act like ntpdate, means do a burst poll/sync cycle and exit.

## Installation

See [opkg](/docs/guide-user/additional-software/opkg "docs:guide-user:additional-software:opkg") for more details on using the OpenWrt package manager.

By default, **busybox-ntpd**, can supply both a client for setting time, and a server for supplying time to the local net. This is installed out of the box and should take care of most time syncing needs. It doesnt support advanced features like query, so the server cannot be monitored from other systems like Nagios.

Some packages, such as **`luci-app-ntpc`** and **`ntpclient`** , may conflict with the built-in **`busybox-ntpd`** installation. If an NTP client or server fails to work as expected, you can check if there is another program using the NTP port by calling **`netstat -np | grep 123`** to search for clients, and **`netstat -nlp | grep 123`** to look for servers.

Example (install the real ntpd package (=not busybox-ntpd):

```
opkg update
opkg install ntpd
/etc/init.d/sysntpd disable
/etc/init.d/ntpd enable
/etc/init.d/ntpd start
netstat -l | grep ntp
```

When you use ntpd, make sure you disable sysntpd daemon. An ntpd server should be listening on the default NTP port (UDP 123).

## Configuration

- The busybox-ntpd is configured in `/etc/config/system`.

By default, it runs as a client and does not serve time to other peers. A server can be enabled by adding the flag “-l” to “local args” in /etc/init.d/sysntpd (line 23). Starting with Backfire 10.3.1 this is not anymore needed and can be also changed in /etc/config/system.

- The package `ntpclient` is configured in `/etc/config/ntpclient`.

`ntpdate` is a command line tool that usually is used for one time synchronizations with remote ntp peers:

```
ntpdate pool.ntp.org
```

and also in conjuction with `/etc/crontabs/root`

- `ntpd` is a daemon that runs all the time in the background for permanent synchronization.

According to [Debian](http://packages.debian.org/squeeze/ntp "http://packages.debian.org/squeeze/ntp") the same NTP daemon is also used to provide NTP service to other hosts.

To use ntpd as NTP client daemon, no change to the firewall is required, to run as NTP server daemon, open port 123 UDP for your NTP clients (which is by default open in LAN). An example to run `ntpd` as a server:

```
driftfile  /var/lib/ntp/ntp.drift

server 0.openwrt.pool.ntp.org iburst
server 1.openwrt.pool.ntp.org iburst
server 2.openwrt.pool.ntp.org iburst
server 3.openwrt.pool.ntp.org iburst

#exchange time with everybody but dont allow configuration (noquery to forbid query)
restrict -4 default kod notrap nomodify nopeer
restrict -6 default kod notrap nomodify nopeer

#local users may interrogate the ntp server more closely
restrict 127.0.0.1
restrict ::1
```

Depending on your configuration ntpd won't start properly when

```
restrict 127.0.0.1
restrict ::1
```

is not set. When ntpd is started and it tries to connect to a server for which only a hostname is known, e.g. 0.openwrt.pool.ntp.org, and for some reason DNS service is not available yet (e.g. you are on a dial-up connection and it takes some time to set everything up), then without the above snippet you'll find two processes of ntpd running (one as user 'root', the other as user 'ntp') and you will have errors like this in the log:

```
ntp_intres.request: permission denied
```

The explanation I found at [https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=571469](https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=571469 "https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=571469"). The default configuration above sets “nomodify”. That configuration on localhost “will prevent the resolver process from adding the peers.” \[...] “The nomodify will only be a problem in case the resolver process needs to be started, which it does when it can't resolve the hostsnames when ntpd starts. So this is mostly when the network isn't up yet.” (explanation by Kurt, from Debian bug report mentioned above) (sic)

## rdate server

First of all: rdate is old, very simple and does not give you highly reliable time. If you still want to run a server for rdate clients for some reason you can use the xinetd package.

After installing xinetd and running “/etc/init.d/xinetd enable”, create a file “/etc/xinetd.d/time-stream” with the following content:

```
service time
{
	disable = no
	id		= time-stream
	type		= INTERNAL
	wait		= no
	socket_type	= stream
	flags		= IPv4
}
```

Finally run “/etc/init.d/xinetd restart” and your rdate-timeserver should be up and running.

## Testing an NTP Server

You can test any NTP server (including those in OpenWRT) by using the `ntpdate` utility, which is available in most Linux distributions.

```
ntpdate -q [OpenWRT IP Address]
```

This should return something like:

```
server 192.168.1.1, stratum 2, offset -0.909611, delay 0.02853
30 Nov 00:43:21 ntpdate[44]: step time server 192.168.1.1 offset -0.909611 sec
```

If your system uses **`chrony`** instead of **`ntpdate`** , you need to add the server to your config file, even if you're just testing it. To do so:

1. Add `server [OpenWRT IP] iburst noselect` to your `chrony.config` - this will allow you to query the server, without using it to set system time.
2. Run `chronyc ntpdata [OpenWRT IP]` - this will return data about the NTP server. You may need to be root to execute this command.

## Troubleshooting

To enable syslog to show ntpd updates create `/etc/hotplug.d/ntp/20-ntpd-logger` and put the following into it. Restart ntpd with `/etc/init.d/sysntpd restart` and log updates will go to syslog.

```
#!/bin/sh
[ $ACTION = "step" ]    && logger -t ntpd Time set, stratum=$stratum interval=$poll_interval offset=$offset
[ $ACTION = "stratum" ] && logger -t ntpd Stratum change, stratum=$stratum interval=$poll_interval offset=$offset
```

**Log Output:**

```
Wed Jan  5 18:18:54 2022 user.notice ntpd: Stratum change, stratum=2 interval=2048 offset=0.007304
Wed Jan  5 18:18:54 2022 user.notice ntpd: Stratum change, stratum=3 interval=2048 offset=0.009748
```

## Notes
