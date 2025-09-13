# Logging messages

This article relies on the following:

- Accessing [web interface](/docs/guide-quick-start/walkthrough_login "docs:guide-quick-start:walkthrough_login") / [command-line interface](/docs/guide-quick-start/sshadministration "docs:guide-quick-start:sshadministration")
- Managing [configs](/docs/guide-user/base-system/uci "docs:guide-user:base-system:uci") / [packages](/docs/guide-user/additional-software/managing_packages "docs:guide-user:additional-software:managing_packages") / [services](/docs/guide-user/base-system/managing_services "docs:guide-user:base-system:managing_services") / [logs](/docs/guide-user/base-system/log.essentials "docs:guide-user:base-system:log.essentials")

## Introduction

The OpenWrt system logging facility is an important debugging/monitoring capability. The standard logging facility is implemented using `logd`, the ubox log daemon. This is implemented as a [ring buffer](https://en.wikipedia.org/wiki/Circular_buffer "https://en.wikipedia.org/wiki/Circular_buffer") with fixed sized records stored in [RAM](https://en.wikipedia.org/wiki/Random-access_memory "https://en.wikipedia.org/wiki/Random-access_memory"). The ring buffer records can be read using `logread` on the router, streamed to a file or sent to a remote system through a TCP/UDP socket.

```
# List syslog
logread
 
# Write a message with a tag to syslog
logger -t TAG MESSAGE
 
# List syslog filtered by tag
logread -e TAG
```

```
Usage: logger [OPTIONS] [MESSAGE]

Write MESSAGE (or stdin) to syslog

        -s      Log to stderr as well as the system log
        -t TAG  Log using the specified tag (defaults to user name)
        -p PRIO Priority (numeric or facility.level pair)
```

Examples of using priority and tag values:

```
logger "example"
logger -p notice -t example_tag "example notice"
logger -p err -t example_tag "example error"
# Fri May  8 00:23:26 2020 user.notice root: example
# Fri May  8 00:23:31 2020 user.notice example_tag: example notice
# Fri May  8 00:23:40 2020 user.err example_tag: example error
```

The `logger` utility [comes from the BusyBox](https://github.com/mirror/busybox/blob/master/sysklogd/logger.c "https://github.com/mirror/busybox/blob/master/sysklogd/logger.c") but you may replace it with the full version from `linux-utils` by installing the `logger` package.

## Messages format

The message format differs based on the destination (local logread, local file, remote socket). Roughly it can be viewed as:

```
<time stamp> <router name> <subsystem name/pid> <log_prefix>: <message body>
```

The logging message facility and priority are roughly equivalent to syslog implementations (see linux `/usr/include/sys/syslog.h`). The local 'logread' executable puts the facility.priority after the time stamp. Logging to a remote socket puts a numeric value before the time stamp.

For some common OpenWrt messages see [log.messages](/docs/guide-user/perf_and_log/log.messages "docs:guide-user:perf_and_log:log.messages"). ![FIXME](/lib/images/smileys/fixme.svg) - the log.messages reference is way out of date but a useful placeholder.

## logd

`logd` is a default OpenWrt logging daemon provided by [ubox](https://github.com/openwrt/ubox "https://github.com/openwrt/ubox") package. It listens on `/dev/log` unix socket to record syslog messages. It's configured in `/etc/config/system`. After changing the file, run

```
service log restart
service system restart
```

to read in the new configuration and restart the service.

There are three basic destinations for log messages: the RAM ring buffer (the default), a local persistent file, a remote destination listening for messages on a TCP or UDP port.

The full set of `log_*` options for `/etc/config/system` are defined in [System Configuration](/docs/guide-user/base-system/system_configuration "docs:guide-user:base-system:system_configuration")

Additionally it sends log messsages to UBUS and you can listen them with `ubus subscribe log`.

### logread

This is the default interface to read log messages. It's provided by the [ubox](https://github.com/openwrt/ubox "https://github.com/openwrt/ubox") package.

It is a local executable in `/sbin/logread` that will read the ring buffer records and display them chronologically.

To show all log messages that contains a specific text (like a daemon name) and follow (like in `tail -f`) use:

```
logread -fe firewall
```

Options:

```
-s <path>		Path to ubus socket
-l	<count>		Got only the last 'count' messages
-e	<pattern>	Filter messages with a regexp
-r	<server> <port>	Stream message to a server
-F	<file>		Log file
-S	<bytes>		Log size
-p	<file>		PID file
-h	<hostname>	Add hostname to the message
-P	<prefix>	Prefix custom text to streamed messages
-z	<facility>	handle only messages with given facility (0-23), repeatable
-Z	<facility>	ignore messages with given facility (0-23), repeatable
-f			Follow log messages
-u			Use UDP as the protocol
-t			Add an extra timestamp
-0			Use \0 instead of \n as trailer when using TCP
```

The `logread` can be also used to stream logs to a remote Syslog server. It's used internally by the `/etc/init.d/log`. You can configure the streaming in the `/etc/config/system`.

Please note that if you install the [syslog-ng](/docs/guide-user/perf_and_log/log.syslog-ng3 "docs:guide-user:perf_and_log:log.syslog-ng3") then the logread command will be overridden with it's own `/usr/sbin/logread` that has less options.

### Local file logging

In order to log to a local file on the router, one needs to set the following options:

```
config system 
...
   option log_file '/var/log/mylog'
   option log_remote '0'
```

The `/etc/init.d/log` script will start additionally the `/sbin/logread -f -F /var/log/mylog -p /var/run/log` command to dump messages from a ring buffer into the file.

### Network logging

In order to log remotely one needs to set the following options in `/etc/config/system`

```
config system
...
   option log_ip <destination IP>
   option log_port <destination port>
   option log_proto <tcp or udp>
```

For the destination port, if you'll be manually reading the logs on the remote system as an unprivileged user (such as via the netcat command given below), then specify a high port (e.g. 5555). If you're sending to a syslog server, use whatever port the syslog server is listening on (typically 514).

Additionally, the firewall3 default is to ACCEPT all LAN traffic. If the router blocks LAN-side access, add the following firewall3 rule to `/etc/config/firewall` to ACCEPT tcp/udp traffic from the router to the LAN-side.

```
config rule
      option target 'ACCEPT'
      option dest 'lan'
      option proto 'tcp udp'
      option dest_port '5555'
      option name 'ACCEPT-LOG-DEVICE-LAN'
```

and then reload the rules using `service firewall restart`.

For the LAN-side station/client, there are a large number of mechanisms to listen for log messages. One of the simplest is ncat:

```
# TCP
ncat -4 -l 5555
 
# Read UDP logs with ncat or python3
ncat -u -4 -l 5555
python3 -c "import socket
s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
s.bind(('0.0.0.0', 5141))
while True:
   print(s.recvfrom(4096)[0].decode('utf-8'))"
```

Log messages are in [traditional syslog format (RFC 3164 / 5424)](https://sematext.com/blog/what-is-syslog-daemons-message-formats-and-protocols/ "https://sematext.com/blog/what-is-syslog-daemons-message-formats-and-protocols/"), beginning with a priority number in angle brackets (e.g., &lt;30&gt;) and lacking a terminating newline. The above netcat method will therefore yield somewhat messy output. The python log reader above will most of the time get the line breaks into the right spots. A cleaner solution is to send messages to a remote machine's syslog daemon, in which case they will appear in the remote system's logs. See [Receiving Messages from a Remote System](https://www.rsyslog.com/receiving-messages-from-a-remote-system/ "https://www.rsyslog.com/receiving-messages-from-a-remote-system/") for server configuration instructions for rsyslog.

The advantage to using TCP is reliability - it logs every event. The disadvantage is it can cause some performance degradation on the router if the logging level is high. There is a section on iptable event logging which can cause a noticable latency in traffic throughput using TCP socket logging.

## Test runtime logging support

If you want to test the logging out, just run a command like

```
logger testLog "Blah1"
```

and it should be written to the configured destination. If an event is not logged, check:

\* `/sbin/logd` is running; it should have an argument of `-S <log_size>` indicating the size of the ring buffer, * `logd` is configured correctly in `/etc/config/system`, * restart it using `service log restart` and check for warnings/errors

## Logrotate

To automatically manage large collections of daily, weekly, or monthly logs, you may want to use [logrotate](/packages/pkgdata/logrotate "packages:pkgdata:logrotate"). Here's an example that rotates a persistent log on a USB storage each night keeping it for 1 week.

```
# Install packages
opkg update
opkg install logrotate
 
# Configure logging
uci set system.@system[0].log_file="/mnt/sda1/logs/system.log"
uci set system.@system[0].log_remote="0"
uci commit system
service system restart 
 
# Configure logrotate
cat << "EOF" > /etc/logrotate.conf
include /etc/logrotate.d
/mnt/sda1/logs/system.log {
    daily
    rotate 1
    missingok
    notifempty
    postrotate
        service log restart
        sleep 1
        logger -p warn -s "Log rotation complete"
    endscript
}
EOF
 
# Configure cron
cat << "EOF" >> /etc/crontabs/root
58 23 * * * logrotate /etc/logrotate.conf
EOF
service cron restart
 
# Debugging
logrotate --verbose --debug /etc/logrotate.conf
```

## Alternative implementations

The logging mechanism discussed here uses `logd`. There are other packages that provide the same functionality:

- [syslog-ng](/docs/guide-user/perf_and_log/log.syslog-ng3 "docs:guide-user:perf_and_log:log.syslog-ng3") - is better supported in OpenWrt and used by default by some manufactures like Turris.
- [rsyslog](/docs/guide-user/perf_and_log/log.rsyslog "docs:guide-user:perf_and_log:log.rsyslog")
