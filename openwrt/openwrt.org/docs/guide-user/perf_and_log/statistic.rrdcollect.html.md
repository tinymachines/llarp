# RRDcollect

RRDcollect is a daemon which polls certain files in `/proc` directory, gathering data and storing it inside RRDtool's database files. This normally takes place on your OpenWrt Router, but you can also write to a remote filesystem ([cifs.client](/docs/guide-user/services/nas/cifs.client "docs:guide-user:services:nas:cifs.client") or [nfs.client](/docs/guide-user/services/nas/nfs.client "docs:guide-user:services:nas:nfs.client")) and execute RRDtool on that machine. See [http://oss.oetiker.ch/rrdtool/](http://oss.oetiker.ch/rrdtool/ "http://oss.oetiker.ch/rrdtool/") for more info.

## Preparation

### Prerequisites

*none*

### Required Packages

Name Version Size in Bytes Description rrdcollect 0.2.4-1 19 204 RRDcollect is a daemon which polls ceratin files in /proc/ directory, gathering data and storing it inside RRDtool's database files. Being written in C should be both fast and resources-friendly. Supports both scanf(3)-style pattern matches and perl compatible regular expressions. This package contains the RRD collecting daemon. librrd1 1.0.50-1 138 975 RRD is the Acronym for Round Robin Database. RRD is a system to store and display time-series data (i.e. network bandwidth, machine-room temperature, server load average). It stores the data in a very compact way that will not expand over time, and it presents useful graphs by processing the data to enforce a certain data density. It can be used either via simple wrapper scripts (from shell or Perl) or via frontends that poll network devices and put friendly user interface on it.  
This is version 1.0.x with cgilib-0.4, gd1.3 and libpng-1.0.9 linked into librrd.so. The library is much smaller compared to the 1.2.x version with separate dynamic linked libraries. This package contains a shared library, used by other programs. zlib 1.2.5-1 39 388 Library implementing the deflate compression method rrdcollect-example 0.2.4-1 9 864 RRDcollect is a daemon which polls ceratin files in /proc/ directory, gathering data and storing it inside RRDtool's database files. Being written in C should be both fast and resources-friendly. Supports both scanf(3)-style pattern matches and perl compatible regular expressions. This package contains examples for the RRD collecting daemon.

## Installation

[opkg](/docs/guide-user/additional-software/opkg "docs:guide-user:additional-software:opkg")

```
opkg install rrdcollect
vi /etc/???  you will need to find out the path of the configuration file first :-P
```

## Configuration

[https://lists.oetiker.ch/pipermail/rrd-users/2002-September/005146.html](https://lists.oetiker.ch/pipermail/rrd-users/2002-September/005146.html "https://lists.oetiker.ch/pipermail/rrd-users/2002-September/005146.html")

## Examples

## Start on boot

First create `/etc/init.d/rrdcollect` with the right content. Then To enable/disable start on boot:  
`/etc/init.d/rrdcollect enable` this simply creates a symlink: `/etc/rc.d/S??rrdcollect → /etc/init.d/umurmur`  
`/etc/init.d/rrdcollect disable` this removes the symlink again

## Administration

## Troubleshooting

## Notes

- Well, figure it out or use [statistic.collectd](/docs/guide-user/perf_and_log/statistic.collectd "docs:guide-user:perf_and_log:statistic.collectd")
