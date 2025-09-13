# Scheduling tasks with cron

This article relies on the following:

- Accessing [web interface](/docs/guide-quick-start/walkthrough_login "docs:guide-quick-start:walkthrough_login") / [command-line interface](/docs/guide-quick-start/sshadministration "docs:guide-quick-start:sshadministration")
- Managing [configs](/docs/guide-user/base-system/uci "docs:guide-user:base-system:uci") / [packages](/docs/guide-user/additional-software/managing_packages "docs:guide-user:additional-software:managing_packages") / [services](/docs/guide-user/base-system/managing_services "docs:guide-user:base-system:managing_services") / [logs](/docs/guide-user/base-system/log.essentials "docs:guide-user:base-system:log.essentials")

## Introduction

- OpenWrt can run scheduled tasks using [cron](https://en.wikipedia.org/wiki/Cron "https://en.wikipedia.org/wiki/Cron") service.
- This how-to describes the method for setting up cron jobs.
- See also [Watchcat](/docs/guide-user/advanced/watchcat "docs:guide-user:advanced:watchcat") to reboot based on schedule or connectivity.

## Goals

- Run programs or scripts at a specific time.
- Automate scheduled task management.

## Web interface instructions

Set up cron jobs using web interface.

1. Navigate to **LuCI → System → Scheduled Tasks**.
2. Edit the configuration and click the **Save** button.

## Command-line instructions

Set up cron jobs using command-line interface.

```
# Edit configuration
crontab -e 
 
# Show configuration
crontab -l
 
# Apply changes
service cron restart
```

This will edit the configuraion `/etc/crontabs/root` file in [vi editor](/docs/guide-user/base-system/user.beginner.cli#editing_files "docs:guide-user:base-system:user.beginner.cli").

![:!:](/lib/images/smileys/exclaim.svg) There should be a EOL character on the last line of the crontab file. Just leave an empty line at the end to be sure.

## Task specification

Each line is a separate task written in the specification:

```
* * * * * command to execute
- - - - -
| | | | |
| | | | ----- Day of week (0 - 6) (Sunday =0)
| | | ------- Month (1 - 12)
| | --------- Day (1 - 31)
| ----------- Hour (0 - 23)
------------- Minute (0 - 59)
```

Examples of time specification:

min  
0-59 hour  
0-23 day/month  
1-31 month  
1-12 day/week  
0-6 Description \*/5 * * * * Every 5 minutes 12 \*/3 * * * Every 3 hours at 12 minutes 57 11 15 1,6,12 * At 11:57 Hrs on 15th of Jan, June &amp; Dec 25 6 * * 1-5 At 6:25 AM every weekday (Mon-Fri) 0 0 4,12,26 * * At midnight on 4th, 12th and 26th of every month 5,10 9,14 10 * 0,4 At 9:05AM, 9:10AM, 2:05PM and 2:10PM every Sunday and Thursday

![:!:](/lib/images/smileys/exclaim.svg) 0 (zero) is treated as Sunday. If you set the day of the week to 7, BusyBox will go bonkers and run your command every day.

**Table of shortcuts:**

Shortcut Equivalent Description `@reboot` Run once, at startup `@yearly` `0 0 1 1 *` Every year `@annually` `0 0 1 1 *` Every year `@monthly` `0 0 1 * *` Every month `@weekly` `0 0 * * 0` Every week `@daily` `0 0 * * *` Every day `@midnight` `0 0 * * *` Every day `@hourly` `0 * * * *` Every hour

![:!:](/lib/images/smileys/exclaim.svg) Time shortcuts are not enabled by default. Shortcuts require compiling busybox with FEATURE\_CROND\_SPECIAL\_TIMES enabled in the busybox compile options.

## Troubleshooting

You can read log messages with:

```
logread -e cron
```

Not all messages are logged, to increase logging change `cronloglevel` option.

## Extras

### References

- [crontab(1)](http://man.cx/crontab%281%29 "http://man.cx/crontab%281%29"), [crontab(5)](http://man.cx/crontab%285%29 "http://man.cx/crontab%285%29")
- [BusyBox crontab](https://busybox.net/downloads/BusyBox.html#crontab "https://busybox.net/downloads/BusyBox.html#crontab")
- [Crontab quick reference](http://adminschoice.com/crontab-quick-reference "http://adminschoice.com/crontab-quick-reference")

### Periodic reboot

A simple workaround for some hard-to-solve problems (memory leak, performance degradation, ...) is to reboot the router periodically, for instance every night.

However, this is not as simple as it seems, because the router usually does not have a real-time clock. This could lead to a never-ending loop of reboots.

In the boot process the clock is initially set by `sysfixtime` to the most recent timestamp of any file found in /etc. The most recent file is possibly a status file or config file, modified maybe 30 seconds before the reboot initiated by cron. So, in the boot process the clock gets set backwards a few seconds to that file's timestamp. Then cron starts and notices a few seconds later that the required boot moment has again arrived and reboots again... At the end of the boot process ntpd starts, and it may also take a while before ntpd gets and sets the correct time, so cron may start the reboot in between.

One solution for cron is to use a delay and touch a file in `/etc` before reboot.

```
# Reboot at 4:30am every day
# Note: To avoid infinite reboot loop, wait 70 seconds
# and touch a file in /etc so clock will be set
# properly to 4:31 on reboot before cron starts.
30 4 * * * sleep 70 && touch /etc/banner && reboot
```

![:!:](/lib/images/smileys/exclaim.svg) On many platforms `shutdown` does not work; it will just halt the CPU but it won't power off the device. There is usually no programmable circuitry to actually power off the unit. `reboot` does work, in case you should want to reboot the router periodically.

### Periodic network restart

A simple solution for restart all your network (lan, wan and wifi) every 10 minutes is this:

```
*/10 * * * * service network restart
```

### Alarm clock

If you have [DST](https://en.wikipedia.org/wiki/Daylight%20saving%20time "https://en.wikipedia.org/wiki/Daylight saving time") you could write yourself a nice alarm clock. When DST starts in central Europe, clocks advance from 02:00 CET to 03:00 CEST on last Sunday in March. Six day before that, you could make your WoL wake you 10 minutes earlier. Later won't work, you'll be late. When DST ends in central Europe, clocks retreat from 03:00 CEST to 02:00 CET on last Sunday in October.

```
# min hour day month dayofweek command
59 05 * * 1 /usr/bin/wol -h 192.168.1.255 xx:xx:xx:xx:xx:xx
# crontab must end with the last line as space or a comment
```

### Keep number of configs / snapshots of config

To keep a number N of configurations/settings at the directory “/root”, you can also use cron. This way you can access and restore configurations of the past N days. The cronjob can easily be extended to copy the config to another device, to be able to replicate a broken OpenWRT device from scratch.

```
#Make a new backup/configurations snapshot at nighttime 00:01 am, keep last N=100 snapshots
#01 00 * * * sysupgrade -b "/root/backup-${HOSTNAME}.tar.gz" # <-- keep just one config
01 00 * * * find "/root" -type f -name "backup-*.tar.gz" | sort -r | awk 'NR > 100' | xargs rm -f; sysupgrade -b "/root/backup-${HOSTNAME}-$(date +\%Y-\%m-\%d-\%H-\%M-\%S).tar.gz"
```
