## Snort

[Snort](https://www.snort.org "https://www.snort.org") is the foremost open source Intrusion Prevention System (IPS). It uses a series of rules that help define malicious network activity, finds packets that match against them, and generates alerts for users. It can be deployed inline to stop these packets, as well. Snort has three primary uses: As a packet sniffer like tcpdump, as a packet logger which is useful for network traffic debugging, or as a full-blown network intrusion prevention system.

Snort can operate in several modes:

1. Alert/logging only, so-called Intrusion Detection System (IDS)
2. Alert/logging + blocking, so-called Intrusion Prevention System (IPS)

The IDS configuration will:

- Only require a single NIC
- Only alert users to rule matches but take no action to prevent them (ie will not drop or reject)

The IPS configuration will:

- Require at least two NICs, one LAN facing and a second one WAN facing. If the device is the network router, only two are required but if the device is physically connected to the router, a third NIC will be needed in order to connect to the snort box.

Before you install:

- Make sure you have sufficient resources for `snort` to operate, as it is very memory and CPU intensive.
- Specifically, `snort` will consume from 200 MB to 1 GB of RAM, depending on your rules and configuration.
- Intrusion prevention will use a lot of CPU, so x86 or high-end ARM (Pi-4-like performance) is necessary.

## Installation

While packages for both Snort 2 and Snort 3 are available, this page is focused on the current 3.x series. Snort 2 was removed from SNAPSHOT in Janaury 2024 but remains as a legacy package in 23.05 and earlier releases, but likely without maintenance updates.

Install snort:

```
opkg update
opkg install snort3
```

Check the installed package version:

```
opkg info snort3 | grep Version
```

This will tell you which of the following instructions are applicable for your version:

1. Package version at or before 3.1.48.0-1, you installed a very old version that will require completely manual setup. The [Obtain Rules](#obtain_rules "docs:guide-user:services:snort ↵") section applies, but not much else.
2. Package version 3.1.48.0-2 or newer, AND OpenWrt version is 23.05 or older. This has OpenWrt-specific files that help get things set up with a handful of steps. After reading [Obtain Rules](#obtain_rules "docs:guide-user:services:snort ↵"), jump to [Manual Configuration](#manual_configuration "docs:guide-user:services:snort ↵") for these versions.
3. Package version 3.1.78.0-2 or later, AND you are running OpenWrt SNAPSHOTs (or a version after 23.05). Many more features were added to the config file and full auto-configuration scripts allow you to customize your use case with much greater ease. Jump immediately to [Auto-Configuration](#auto-configuration "docs:guide-user:services:snort ↵") for these versions, which has tools for installing rules automatically.

#### Disable Flow Offloading

Make sure that Flow offloading type (luci: network&gt;firewall&gt; Routing/NAT Offloading) is set to none. With hardware or software offloading enabled, not all packets will flow through snort.

## Obtain rules

At a minimum, grab a copy of the freely available [community rules](https://www.snort.org/downloads/community/snort3-community-rules.tar.gz "https://www.snort.org/downloads/community/snort3-community-rules.tar.gz") and place snort3-community.rules in a directory of your choosing, for example on external media, for example, `/mnt/mmcblk0p3/snort/`.

In addition to this rule set, users may optionally register for a free account at [snort.org](https://www.snort.org/users/sign_up "https://www.snort.org/users/sign_up") which grants access to more rule sets to augment the free ones described above.

Here is a simple helper script:

```
#!/bin/sh
# snortver needs to be manually defined
# find the largest number from https://www.snort.org/downloads/#rule-downloads
shortver=31470
snort=/mnt/mmcblk0p3/snort/
oinkcode=your-unique-hash
 
wget "https://www.snort.org/rules/snortrules-snapshot-$shortver.tar.gz?oinkcode=$oinkcode" -O /tmp/new.tar.gz || exit 1
tar zxf /tmp/new.tar.gz -C "$snort" || exit 1
```

## Manual Configuration

The following sections apply to OpenWrt's Snort3 package versions 3.1.48.0-2 through 3.1.77.0-0. If your version is later than that, jump down to [Auto-Configuration](#auto-configuration "docs:guide-user:services:snort ↵").

### IDS Configuration for stable release ONLY

There are several config files:

- `/etc/config/snort` is the OpenWrt daemon config file holding some runtime options.
- `/etc/snort/snort.lua` is the main configuration, allowing the implementation and configuration of Snort inspectors (preprocessors), rules files inclusion, event filters, output, etc.
- `/etc/snort/snort_defaults.lua` file contains default values such as paths to rules, AppID, intelligence lists, and network variables.

1\. Define which interface on which to listen in `/etc/config/snort` (default is eth0).

2\. Edit `/etc/snort/snort_defaults.lua` defining the path to the directory holding the contents of the tarball. In the example below, we are using attached storage but any path will work:

```
RULE_PATH = '/mnt/mmcblk0p3/snort/rules/'
BUILTIN_RULE_PATH = '/mnt/mmcblk0p3/snort/builtin_rules'
PLUGIN_RULE_PATH = '/mnt/mmcblk0p3/snort/so_rules'
```

3\. Edit the main config file, `/etc/snort/snort.lua` for the initial setup. At a minimum, we need to define three sections:

- HOME\_NET (define the network/networks to protect by IP range, note that multiple ranges can be defined as shown below)
- EXTERNAL\_NET (define everything but HOME\_NET)
- ips section (setup run mode \[listen and alert only or listen, alert, and drop] and define the .rules file/files to read)

```
HOME_NET = [[ 10.1.8.0/24 192.168.1.0/24 ]]
EXTERNAL_NET = "!$HOME_NET"
```

Snort can operate in three modes:

1. Tap: act as an IDS, only alerting to rule matches, use **mode = tap,**
2. Inline: act as an IPS, both alerting to rule matches AND triggering corresponding drop rules, use **mode = inline,**
3. Inline-test: simulate the inline mode allowing users to evaluate the behavior of inline without affecting traffic, use **mode = inline-test,**

```
ips =
{
    mode = tap,
    variables = default_variables,
    
    rules = [[ 
    include $RULE_PATH/snort3-community.rules
    include $RULE_PATH/snort3-malware-backdoor.rules
    include $RULE_PATH/snort3-policy-multimedia.rules
    include $RULE_PATH/snort3-protocol-services.rules
    include $RULE_PATH/snort3-policy-social.rules
    ]]
}
```

Memory and CPU usage will proportionally increase as the number of rules increases. Be sure to check system usage with a utility like top or htop.

### IPS Configuration for stable release ONLY

1\. Define the interface pair or device pair on which to listen in `/etc/config/snort` (for example eth0:eth1).

2\. Change `mode = tap` in the `ips =<` section of `/etc/snort/snort.lua` to `mode = inline`.

3\. Add the following under the `ips =` section of `/etc/snort/snort.lua`:

```
daq = {
  module_dirs = {
    '/usr/lib/daq',
  },
  modules = {
    {
      name = 'afpacket',
      mode = 'inline',
      action_override = 'drop',
      variables = {
        'fanout_type=hash'
      }
    }
  }
}
```

4\. Edit `/etc/init.d/snort` and append a `-Q` to the `procd_set_param command` like so to enable Inline mode which will trigger drop rules:

```
procd_set_param command $PROG -q --daq-dir /usr/lib/daq/ -i "$interface" -c "$config_name" -A "$alert_module" -Q
```

### Configuration for development snapshot ONLY

This section only applies to users running development snapshots post 07-Dec-2022! This version of the package is much compartmentalized and simplified in its setup compared to the older package.

There are several config files:

- `/etc/config/snort` is the OpenWrt daemon config file holding some runtime options.
- `/etc/snort/homenet.lua` contains definitions for several key variables.
- `/etc/snort/local.lua` contains all other modules and options.

1\. Edit `/etc/snort/homenet.lua` and redefine `HOME_NET` and `EXTERNAL_NET`, for example:

```
HOME_NET = [[ 10.9.8.0/24 192.168.1.0/24 ]]
EXTERNAL_NET = "!$HOME_NET"
```

2\. Edit `/etc/snort/local.lua` to setup options unique to your use case of snort. The defaults included should be sane for the role of IDS (alert only), but users may easily uncomment some options therein to use IPS (drop) mode. See the comments in the file. Be sure to add the following line in the ips = section if running in IPS mode: `action_override = 'drop',`

3\. Install or symlink rules to `/etc/snort/rules/snort.rules` edit optionally edit `/etc/snort/local.lua` to define extra rules files if not using unified 'snort.rules'

### Validate the configuration

Validate the config file by running the following:

#### For the stable release ONLY

```
snort -c /etc/snort/snort.lua --daq-dir /usr/lib/daq -T
```

#### For the development release ONLY

```
snort -c /etc/snort/snort.lua --tweaks local -T
```

### Run snort

Start the daemon and optionally enable it to run at boot:

```
/etc/init.d/snort start
/etc/init.d/snort enable
```

The OpenWrt package writes alerts to the syslog by default. Query like so:

```
# logread -e snort
Mon Nov 28 09:55:23 2022 auth.info snort: [1:254:16] "PROTOCOL-DNS SPOOF query response with TTL of 1 min. and no authority" [Classification: Potentially Bad Traffic] [Priority: 2] {UDP} 1.1.1.1:53 -> 10.1.8.202:55572
Mon Nov 28 13:09:16 2022 auth.info snort: [1:29456:3] "PROTOCOL-ICMP Unusual PING detected" [Classification: Information Leak] [Priority: 2] {ICMP} 10.9.1.235 -> 0.0.0.15
Mon Nov 28 13:09:17 2022 auth.info snort: [1:29456:3] "PROTOCOL-ICMP Unusual PING detected" [Classification: Information Leak] [Priority: 2] {ICMP} 10.9.1.235 -> 0.0.0.15
Mon Nov 28 13:09:18 2022 auth.info snort: [1:29456:3] "PROTOCOL-ICMP Unusual PING detected" [Classification: Information Leak] [Priority: 2] {ICMP} 10.9.1.235 -> 0.0.0.15
Mon Nov 28 13:09:19 2022 auth.info snort: [1:29456:3] "PROTOCOL-ICMP Unusual PING detected" [Classification: Information Leak] [Priority: 2] {ICMP} 10.9.1.235 -> 0.0.0.15
```

## Auto-Configuration

This section describes OpenWrt's Snort3 configuration when the package version is 3.1.78.0-2 and later (released January 2024).

### Quickstart

To boost your confidence, we'll do the minimum to verify that everything is in place and all the data is flowing through snort as expected.

First, set the config to use auto-configuration, enable it and point it to your WAN interface.

```
uci set snort.snort.enabled=1
uci set snort.snort.manual=0
uci set snort.snort.home_net="any"
uci set snort.snort.interface="$(uci get network.wan.device)"
uci commit
```

Next, set up a set of testing rules.

```
snort-rules --testing
snort-mgr check --verbose
```

That `snort-mgr check` command will spit out pile of diagnostics, there are two lines that mean everything is working. We want to be sure it's loading rules (the first line) and that it `successfully validated`.

```
... a bunch of stuff ...
Loading /etc/snort/rules/testing.rules:
... a bunch of stuff ...
Snort successfully validated the configuration (with 5 warnings).
```

Time to start snort up.

```
/etc/init.d/snort start
logread -e snort
snort-mgr status
```

The `snort-mgr status` command should show something like this:

```
snort is running
Total system memory=984.027M  Used=319.121M (32.4%)  Free=664.906M (67.6%)
  PID USER       VSZ STAT COMMAND
11694 root     92000 S    /usr/bin/snort -q -c /var/snort.d/snort_conf.lua
```

Now it's time for that test, which uses the test rule (it detects pings from anywhere to anywhere and logs them as incidents).

```
ping -c4 8.8.8.8
snort-mgr report
```

The output from `snort-mgr report` should show those four pings from your router's IP as the source, and Google DNS as the destination.

```
Events involving all IPs - 2024-01-10T14:55:57-08:00
  Count Message            gid   sid Dir Source    Destination
      4 TEST ALERT ICMP v4   1 99010 C2S 10.1.1.20 8.8.8.8
      4 incidents shown of 4 logged
```

Now we're ready for “production”, so simply do this to fetch the snort community rules (assuming no `oinkcode`, see below).

```
snort-rules
/etc/init.d/snort restart
```

### Config File

There is no LuCI support for any of snort configuration, but there is a fairly rich command line suite for managing snort behavior and determining what incidents are actual intrusions.

The `snort` section of the configuration file contains all the basic parameters for generating custom Lua configuration for your installation.

Name Type Default Description `enabled` bool `0` Defaults to off, so that user must configure before first start. `manual` bool `1` When set to 1, use manual configuration for legacy behavior. When disabled, then auto-generate configuration. `oinkcode` string - `home_net` address `192.168.1.0/24` The IP range or ranges to protect. May be `any`, but more likely it's your lan range, default is `192.168.1.0/24`. `external_net` address `any` The IP range external to home. Usually `any`, but if you only care about true external hosts (trusting all lan devices), then `!$HOME_NET` or some specific range. `config_dir` path `/etc/snort` Location of the base snort configuration files. It is very unlikely that you'll want to change this, as by default a large part of the default configuration resides in `/etc/snort`, and this is also the prefix for locating the `rules` directory. `temp_dir` path `/var/snort.d` Location of all transient snort configuration. If you use the `snort-rules` utility to download rules, it places the downloads here. `log_dir` path `/var/log` Location of the generated logs. You may want to point this to a non-volatile location, say an external hard drive, if you wish to keep historical records of alerts. `logging` bool `1` Enable external logging of events thus enabling 'snort-mgr report'. `snort` can run in IPS mode without logging, but you'll be unable to see what or why packets are being rejected. `openappid` bool `0` If you install the `openappid` package, which allows more sophisticated application and service filtering, then turn this on to enable its use. `mode` one\_of `ids` `ids`, `ips` for detection-only or prevention, respectively. `method` one\_of `pcap` `pcap`, `afpacket`, `nfq` `action` one\_of `default` `default`, `alert`, `block`, `drop`, `reject` `interface` id `eth0` The interface on which to filter packets, usually `uci get network.wan.device`, possibly `br-lan` or even both. Note that this item is used by both legacy and auto-generated configurations. `snaplen` int `1518` Set snap length { 0-65535 } `include` path - User-defined snort configuration. It is applied at end of the generated `snort_conf.lua`, so its contents may override any of the defaults.

When the `snort.method` option is set to `nfq`, then the `nfq` section of the config file contains tuning parameters for the rules and queues that are used for packet capture.

Name Type Default Description `queue_count` int `4` An integer in the range 1-16. Count of queues to allocate in the nftables chain, usually 2-8. `queue_start` int `4` An integer in the range 1-32768. Start of queue numbers in nftables. `queue_maxlen` int `1024` An integer in the range 1024-65536. `fanout_type` one\_of `hash` `hash`, `lb`, `cpu`, `rollover`, `rnd`, `qm` For details, see  
[https://github.com/florincoras/daq/blob/master/README](https://github.com/florincoras/daq/blob/master/README "https://github.com/florincoras/daq/blob/master/README")  
[https://www.kernel.org/doc/Documentation/networking/packet\_mmap.txt](https://www.kernel.org/doc/Documentation/networking/packet_mmap.txt "https://www.kernel.org/doc/Documentation/networking/packet_mmap.txt") `thread_count` int `0` An integer in the range 0-32, defaulting to 0. A value of 0 computes available CPUs and uses all. `chain_type` one\_of `input` `prerouting`, `input`, `forward`, `output`, `postrouting` `chain_priority` one\_of `filter` `raw`, `filter`, `300` `include` path - User-defined rules to include inside queue chain. The rules supplied here are inserted before the `queue` statement, so you can filter or drop packets prior to them reaching `snort`.

Logging alerts to the system log is completely disabled by default (i.e., `logread -e snort` only shows startup messages and errors and so on). If you wish for alerts to be written to the system log, use the `snort.include` facility to override this. Be aware that this can be quite verbose and cause the log to rollover quite often.

```
$ echo "alert_syslog = { level = 'info', }" >> /etc/snort/include.snort
$ uci set snort.snort.include=/etc/snort/include.snort
$ uci commit
$ /etc/init.d/snort restart
...
$ logread -e snort
```

### Rules

Before you can run snort, you need to install a set of snort rules. The command line package, `snort-rules`, allows you to do so quickly and easily. You can use it to generate a set of test rules that detect ping between any two hosts on your network, so that's a good place to start as it provides assurance that all the other pieces are in place.

```
$ snort-rules --testing
snort-rules[29098]: Generating testing rules...
snort-rules[29098]: Snort rules loaded, restart snort now.

$ cat /etc/snort/rules/testing.rules
alert icmp any any <> any any (msg:"TEST ALERT ICMP v4"; icode:0; itype: 8; sid:99010;)
alert icmp any any <> any any (msg:"TEST ALERT ICMP v6"; icode:0; itype:33; sid:99011;)
alert icmp any any <> any any (msg:"TEST ALERT ICMP v6"; icode:0; itype:34; sid:99012;)
```

Once you're confident that you have everything else in place, you can then use `snort-rules` to download a real ruleset.

If you have registered with [snort.org](https://snort.org "https://snort.org") and have an `oinkcode`, then your first step is to edit `/etc/config/snort` and modify the value of `oinkcode` in the `snort` section of that file. If you don't wish to register, that's fine, you can still use the [snort community rules](https://www.snort.org/downloads/#rule-downloads "https://www.snort.org/downloads/#rule-downloads"), by simply running `snort-rules` without adding an `oinkcode` to your config.

By default, the `snort.snort.temp_dir` location points to `/var/snort.d/`, which is in OpenWrt's volatile RAM file system. This is where the rules are installed, then a symbolic link is created from `/etc/snort/rules/` to this volatile ruleset. When you reboot, or do a sysupgrade, then the rules are lost and you will need to reload them.

The `--persist` option allows you to install the ruleset into the `conf_dir` location instead of linking there. If you simply supply that option, then the rules are stored in `/etc/snort/rules/` directly rather than being linked, so when you do `sysupgrade` they will be automatically restored. Be aware that this makes the sysupgrade backup file very large if you are using a large ruleset (say from 50-60K bytes to 3-4MB!), so this might not be a good idea depending on your hardware capacity.

Another solution is to simply point `temp_dir` to an external drive location, say `uci set snort.snort.temp_dir=/mnt/sda2/snort.d`, where the files are non-volatile and will not become part of the backup as they are when in `/etc/`.

Without `--persist` we see the link from where snort expects the rules, to where they actually reside.

```
$ snort-rules
...
$ ll /etc/snort/rules
lrwxr-xr-x    1 root     root            26 Jan  8 13:54 /etc/snort/rules -> /var/snort.d/rules/

$ ll /var/snort.d/rules
drwxr-xr-x    2 root     root          4096 Jan  8 14:27 ./
drwxr-xr-x    7 root     root          4096 Jan  8 14:27 ../
-rw-r--r--    1 root     root         66826 Jan  4 13:31 snort3-app-detect.rules
-rw-r--r--    1 root     root         87719 Jan  4 13:31 snort3-browser-chrome.rules
-rw-r--r--    1 root     root        156437 Jan  4 13:31 snort3-browser-firefox.rules
...
```

With the `--persist` option...

```
$ snort-rules --persist
...
$ ll /etc/snort/rules
drwxr-xr-x    2 root     root          4096 Jan  8 14:27 ./
drwxr-xr-x    7 root     root          4096 Jan  8 14:27 ../
-rw-r--r--    1 root     root         66826 Jan  4 13:31 snort3-app-detect.rules
-rw-r--r--    1 root     root         87719 Jan  4 13:31 snort3-browser-chrome.rules
-rw-r--r--    1 root     root        156437 Jan  4 13:31 snort3-browser-firefox.rules
...
```

Note that the `/etc/snort` directory is included in `sysupgrade` backups, so storing data here is probably not a good idea as it can bloat your backups by 10s or 100s of megabytes depending on the size of your ruleset. Likewise, unless you've expanded your root partition, this can easily fill the partition and cause issues. One way around this is to specify a `temp_dir` on an external, non-volatile drive as in this example:

```
$ /etc/init.d/snort stop
 
# '/mnt/sda2' is a USB drive or whatever...
$ uci set snort.snort.temp_dir='/mnt/sda2/snort.d'
$ uci commit
 
$ snort-rules  # Fetch them to the new location, and fix the link in 'snort.config_dir'
$ /etc/init.d/snort start
```

TODO `snort-mgr check`, restart and all that...

### Reports

The reporting facility requires the `coreutils-sort` package for proper operation. It is not installed as a dependency, so if you choose to use `snort-mgr report`, then you'll have to manually add it: `opkg update && opkg install coreutils-sort`.

Here's an example report, using the `--verbose` option to list both the rules involved and the symbolic names of the hosts referenced in the incidents. The incidents are filtered in two ways for this example:

1. By date, with the `--date-spec` option. The `today` value shows everything occurring since the most recent midnight. Alternatively, you can supply `+YY/DD/MM-hh:mm` (everything at or after the supplied date), or `-YY/MM/DD-hh:mm`, which selects everything before the date.
2. By content, using the `--pattern` option. In this case, `ssh|scan` is applied to the output lines as a case-insensitive alternation of the two values.

```
$ snort-mgr report -v -d today -p "ssh|scan"
Events involving ssh|scan - 2024-01-08T13:21:54-08:00
  Count Message                                       gid   sid Dir Source     Destination
     43 INDICATOR-SHELLCODE ssh CRC32 overflow filler   1  1325 C2S 10.1.1.186 10.1.1.20(22)
     20 INDICATOR-SCAN SSH brute force login attempt    1 19559 C2S 10.1.1.186 10.1.1.20(22)
      2 INDICATOR-SHELLCODE ssh CRC32 overflow filler   1  1325 C2S 10.1.1.186 192.168.1.204(22)
     65 incidents shown of 2596 logged

2 unique rules triggered:
  1 - gid=  1 sid= 1325 /etc/snort/rules/snort3-indicator-shellcode.rules:41:alert tcp $EXTERNAL_NET any -> $HOME_NET $SSH_PORTS ( msg:"INDICATO
  2 - gid=  1 sid=19559 /etc/snort/rules/snort3-indicator-scan.rules:43:alert tcp $EXTERNAL_NET any -> $HOME_NET 22 ( msg:"INDICATOR-SCAN SSH br

Per-rule details may be viewed by specifying the appropriate gid and sid, e.g.:
    https://www.snort.org/rule-docs/1-19559

Hosts by name:
  192.168.1.204                           alma9.vm.lan
  10.1.1.186                              rover.main.lan
  10.1.1.20                               openwrt-vm.main.lan
```

## Information references

- Look up log entries by keyword in the [snort database](https://www.snort.org/search "https://www.snort.org/search").
- Linux installation/configuration [guide](https://snort-org-site.s3.amazonaws.com/production/document_files/files/000/004/026/original/Snort_3_GA_on_OracleLinux_8.pdf "https://snort-org-site.s3.amazonaws.com/production/document_files/files/000/004/026/original/Snort_3_GA_on_OracleLinux_8.pdf") written by Yaser Mansour. It is targeted at Oracle Linux 8 but concepts are not distro-specific.
- Official [Snort User Manual](https://www.snort.org/documents/1 "https://www.snort.org/documents/1").
