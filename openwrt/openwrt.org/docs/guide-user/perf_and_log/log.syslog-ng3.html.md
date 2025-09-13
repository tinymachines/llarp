# syslog-ng

## Installation

### Replacing Default Logging with syslog-ng -- 2018

As of February, 2019, version of syslog-ng in OpenWrt master is 3.19.1

As of March, 2018, [https://openwrt.org/packages/pkgdata/syslog-ng](https://openwrt.org/packages/pkgdata/syslog-ng "https://openwrt.org/packages/pkgdata/syslog-ng") is version 3.8.1

On `master` of April, 2018, the following steps will replace the default OpenWRT logging with `syslog-ng`

- Install `syslog-ng` and its dependencies
- Disable the default logging with `/etc/init.d/log disable` or by removing the symlink in `/etc/rc.d`
- Confirm that `syslog-ng` is enabled; `/etc/rc.d/S20syslog-ng → ../init.d/syslog-ng`
- reboot

* * *

![FIXME](/lib/images/smileys/fixme.svg) Much of the following appears to be from Backfire, c. 2011

```
# opkg install syslog-ng
```

## Configuration

Configuration is controlled by `/etc/syslog-ng.conf` The default configuration logs to `/var/log/messages`.

Below is a sample configuration for logging to a remote server via TCP (extended from default config file):

```
#############################################################################
# OpenWrt syslog-ng.conf specific file
# which collects all local logs into a single file called /var/log/messages.
# More details about these settings can be found here:
# https://www.syslog-ng.com/technical-documents/doc/syslog-ng-open-source-edition/3.16/release-notes/global-options

@version: 3.19
@include "scl.conf"
@include "/etc/syslog-ng.d/" # Put any customization files in this directory

options {
	chain_hostnames(no); # Enable or disable the chained hostname format.
	create_dirs(yes);
	keep_hostname(yes); # Enable or disable hostname rewriting.
	log_fifo_size(256); # The number of messages that the output queue can store.
	log_msg_size(1024); # Maximum length of a message in bytes.
	stats_freq(0); # The period between two STATS messages (sent by syslog-ng, containing statistics about dropped logs) in seconds.
	flush_lines(0); # How many lines are flushed to a destination at a time.
	use_fqdn(no); # Add Fully Qualified Domain Name instead of short hostname.
};

filter notice_or_higher {
        level(notice..emerg)  # remove debug and info message
};

# syslog-ng gets messages from syslog-ng (internal) and from /dev/log
source src {
        internal();
        unix-dgram("/dev/log");
};
source kernel {
        file("/proc/kmsg" program_override("kernel"));
};
source net {
        tcp(ip(0.0.0.0) port(514));
};
destination messages {
        file("/var/log/messages");
};
destination syslogd_tcp {
        tcp("syslog." port(514));    # hostname is syslog, replace with your own loghost name or IP
};
log {
        source(src);
        source(kernel);
        filter(notice_or_higher);
        destination(messages);
        destination(syslogd_tcp);
};
```

#### Reconfiguration

To apply changes, it is not sufficient to simply restart the `syslog-ng` daemon. Instead, stop and start the daemon as follows (taken from [http://baheyeldin.com/technology/linux/logging-with-syslog-ng-on-openwrt.html](http://baheyeldin.com/technology/linux/logging-with-syslog-ng-on-openwrt.html "http://baheyeldin.com/technology/linux/logging-with-syslog-ng-on-openwrt.html")):

```
# killall syslog-ng
# /etc/init.d/syslog-ng start
```

#### IPv6 Logserver

To log to a logserver listening on an IPv6 address, use a `udp6()` destination in the configuration file:

```
...
destination d_udp6 { udp6("1234:5678:1011:1314::01" port(514)); };
...
log {
    source(src);
    source(kernel);
    destination(d_udp6);
};
...
```

## Startup

```
# /etc/init.d/syslog-ng enable
# /etc/init.d/syslog-ng start
```

## logread

The logread is an interface to read log messages. When the `syslog-ng` installed then the default OpenWrt [logread](/docs/guide-user/base-system/log.essentials#logread "docs:guide-user:base-system:log.essentials") command from ubox package will be overridden with the `/usr/sbin/logread` script that reads `/var/log/messages` instead of ring buffer.

To show all log messages that contains a specific text (like a daemon name) and follow (like in tail -f) use:

```
logread -fe firewall
```

The script has less options than the ubox logread:

```
-l <count>   Got only the last 'count' messages
-e <pattern> Filter messages with a regexp
-f           Follow log messages
-h           Print this help message
```
