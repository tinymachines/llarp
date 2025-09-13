# Bandwith Monitoring with wrtbwmon

wrtbwmon is a small and basic shell script designed to run on linux powered routers (OpenWRT, DD-WRT, Tomato, and other routers where shell access is available). It provides per user bandwidth monitoring capabilities and generates usage reports. See the screenshot [here](https://raw.githubusercontent.com/pyrovski/wrtbwmon/master/example.png "https://raw.githubusercontent.com/pyrovski/wrtbwmon/master/example.png").

Original wrtbwmon is hosted on [code.google](https://code.google.com/p/wrtbwmon/ "https://code.google.com/p/wrtbwmon/"), but it has been dead since 2010. We have a fork for OpenWrt which is hosted on [github](https://github.com/pyrovski/wrtbwmon "https://github.com/pyrovski/wrtbwmon") by pyrovski.

There are many good general descriptions about how to install it:

1. [google code](https://code.google.com/p/wrtbwmon/wiki/Deploying "https://code.google.com/p/wrtbwmon/wiki/Deploying")
2. [kallisti](http://www.kallisti.net.nz/blog/2010/12/per-user-traffic-monitoring-on-openwrt/ "http://www.kallisti.net.nz/blog/2010/12/per-user-traffic-monitoring-on-openwrt/")
3. [pyrovski](https://github.com/pyrovski/wrtbwmon "https://github.com/pyrovski/wrtbwmon")

## Installation

Based on these 3 descriptions I've created a step-by-step manual for installing wrtbwmon on OpenWrt:

- download latest tar.gz from [https://github.com/pyrovski/wrtbwmon/releases](https://github.com/pyrovski/wrtbwmon/releases "https://github.com/pyrovski/wrtbwmon/releases")
- tar -zxvf /tmp/wrtbwmon-0.2.tar.gz
- copy that 7 files to any folder, eg /opt/wrtbwmon/
- edit wrtbwmon.sh to set both baseDir and dataDir to point to directory of readDB.awk and usage.htm* (eg /opt/wrtbwmon/)

Note: If you're looking for an install that will collect data for you in a sqlite3 database

- Download latest tar.gz from [https://github.com/Jcarnage/wrtbwmon.git](https://github.com/Jcarnage/wrtbwmon.git "https://github.com/Jcarnage/wrtbwmon.git").
- It's based on the pyrovski base release package but adds a remote scripts for capturing and displaying all the data.

## using first time

Using wrtbwmon consists of three separated steps: setup, update and publish.

Note: The setup below uses pyrovski's version of wrtbwmon. Other versions may differ.

- ./wrtbwmon setup /tmp/usage.db # this will create iptables chains and rules
  
  - to verify 1st step, run: iptables -t mangle -L | grep -i rrd
- ./wrtbwmon update /tmp/usage.db # this will copy usage statistics from iptables to usage.db file
  
  - to verify 2nd step, run: cat /tmp/usage.db
- ./wrtbwmon publish /tmp/usage.db /tmp/usage.htm
- ln -s /tmp/usage.htm /www/usage.htm
- check result at [http://192.168.1.1/usage.htm](http://192.168.1.1/usage.htm "http://192.168.1.1/usage.htm")

## schedule the whole process

### Setup

- ./wrtbwmon setup /tmp/usage.db
- it must run once after every boot in order to restore required iptables chains and rules
- one way to do this is to insert this command into /etc/rc.local
- ```
  if [ -x /opt/wrtbwmon/wrtbwmon ]; then
  	logger -t 'rc.local' "Starting wrtbwmon setup..."
  	/opt/wrtbwmon/wrtbwmon setup  /tmp/usage.db
  fi
  ```

### Update

- ./wrtbwmon update /tmp/usage.db
- it must run regularly, eg every 5 minutes
- one way to do this is cron
- ```
  cat << "EOF" >> /etc/crontabs/root
  */5 * * * * /opt/wrtbwmon/wrtbwmon update /tmp/usage.db
  EOF
  service cron restart
  logread -l 5 -f
  ```

### Publish

- in order to have friendly-names insted of mac-addresses, create a text file
  
  - echo “00:aa:bb:cc:dd:ee,friendlyname1” &gt; /opt/wrtbwmon/macusers.txt
  - echo “11:22:33:44:55:66,friendlyname1” &gt;&gt; /opt/wrtbwmon/macusers.txt
  - letters in mac address must be lowercase!
  - unnecessary to insert devices using static-leases or in /etc/hosts file
- publishing /tmp/usage.htm file can be accomplished by two different ways:
  
  - we can publish it regularly via cron, but this is not necessary
  - or
  - we can publish it on demand via cgi-bin: create a file to /www/cgi-bin/usage
  - ```
    #!/bin/sh
    echo 'Content-Type: text/html'
    echo 'X-Dummy: dummy'
    echo
    /opt/wrtbwmon/wrtbwmon update  /tmp/usage.db
    /opt/wrtbwmon/wrtbwmon publish /tmp/usage.db /tmp/usage.htm /opt/wrtbwmon/macusers.txt
    cat /tmp/usage.htm
    ```
  - chmod +x /www/cgi-bin/usage
  - check result at [http://192.168.1.1/cgi-bin/usage](http://192.168.1.1/cgi-bin/usage "http://192.168.1.1/cgi-bin/usage")

## Extras

### Log level

You can change loglevel of cron in order to write only error messages into syslog by:

```
uci set system.@system[0].cronloglevel="9"
uci commit system
service cron restart
logread -l 5 -f
```

### Log rotation

If you are interested in the traffic of the current day, then usage.db file has to be deleted every day at midnight. If we move usage.db file instead of deleting, then it can be used later for publishing via cgi-bin.

```
 0 0 * * * mv /tmp/usage.db /mnt/usbdrive/wrtbwmon/usage-$(date '+%Y.%m.%d').db
```

### Peak and offpeak times

Note: this only works with kallisti's version. Bandwidth usage can be separated to peak and offpeak times.

In this example the off-peak counters get updated from 4:00 to 8:59, the peak counters the rest of the day.

```
*/30 0-3    * * * /opt/wrtbwmon/wrtbwmon update  /tmp/wrtbwmon.db peak
*/30,59 4-8 * * * /opt/wrtbwmon/wrtbwmon update  /tmp/wrtbwmon.db offpeak
*/30 9-23   * * * /opt/wrtbwmon/wrtbwmon update  /tmp/wrtbwmon.db peak
```

### Backup

The /tmp/usage.db file is a database file that contains the accounting records. It will be written to very often, so it is not recommended to put it on flash memory, but should be put in RAM (like in /tmp/ directory). If you put it in RAM, schedule a periodic backup task and restore it if missing, for example:

```
# local backup storage
15 * * * * cp /tmp/usage.db /mnt/usbdrive/wrtbwmon/
 * * * * * [ ! -f /tmp/usage.db ] && cp /mnt/usbdrive/wrtbwmon/usage.db /tmp/
# online backup storage
15 * * * * cd /tmp && ftpput -u username -p password usage.db . some_ftp_server_url
 * * * * * [ ! -f /tmp/usage.db ] && wget some_url/usage.db -O /tmp/usage.db
```

## Enhanced version

You may use a forked version and is luci companion.

- [wrtbwmon](https://github.com/brvphoenix/wrtbwmon "https://github.com/brvphoenix/wrtbwmon") - pyrovski's forked enhanced version
- [luci-app-wrtbwmon](https://github.com/brvphoenix/luci-app-wrtbwmon "https://github.com/brvphoenix/luci-app-wrtbwmon")
