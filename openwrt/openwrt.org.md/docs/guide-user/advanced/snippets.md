# Snippets

On this page you will find script and config snippets that didn't fit in other articles. Some snippets have nature of tweaks or one-line HOWTOs, while others are just fun to run.

## System

### Generate 100% CPU load

There is bunch of reasons why you would like to stress your CPU, one of the less serious is to play with [heartbeat trigger](/docs/guide-user/base-system/led_configuration#heartbeat "docs:guide-user:base-system:led_configuration").

```
cat /dev/urandom | gzip > /dev/null
```

Note: *This will compress infinite stream of random bits and discard them. The compress level can't be changed, so you may want to run more than one instance of the script to get your average CPU load high.*

### Show command line with parameters of a process

Traditionally you would use `top` or `ps` command to get parameters of running processes. However if the command line is too long [busybox's](http://www.busybox.net/ "http://www.busybox.net/") version of those commands will truncate it to fit your terminal window.

```
ps w
```

or

```
cat /proc/<PID>/cmdline
```

Note: *Substitute &lt;PID&gt; with the [process identifier](https://en.wikipedia.org/wiki/Process_identifier "https://en.wikipedia.org/wiki/Process_identifier") of your process.*

### Prompt

#### Colors

Edit `PS1` variable in `/etc/profile` file:

```
export PS1='\[\e[1;31m\]\u@\h:\w\$ \[\e[0m\]'
```

*This gives you normal text and background color, but red prompt, which reminds you that you are root. Other users (if exist) could get green prompt.* [Color codes](https://wiki.archlinux.org/index.php/Color_Bash_Prompt#List_of_colors_for_prompt_and_Bash "https://wiki.archlinux.org/index.php/Color_Bash_Prompt#List_of_colors_for_prompt_and_Bash").

#### Screen session

It may be useful to display name of `screen` session if you are in one. *Tip: mix some colors in.* In the example the `screen` session has name `pts-0`:

```
root@tsunami/pts-0:~# 
```

```
local SCREEN_SESSION_NAME=$(screen -ls | sed -n 's|[^a-z]*[0-9][0-9]*\.\([a-zA-Z][a-zA-Z0-9-]*\).*Attached.*|/\1|p')
export PS1="\u@\h${SCREEN_SESSION_NAME}:\w\\$ "
```

#### Red background if last command failed

Changes background color of prompt to red, when last command failed, i.e. its exit code is not equal to zero.

```
export PS1="\$([ \$? -ne 0 ] && echo \\\[\\\e[41m\\\])\u@\h:\w\\$\[\e[0m\] "
```

### Paste file on web from CLI

```
cat /etc/config/some.conf | nc paste.dyndns.org 1234
```

### Get bridge status

```
devstatus br-lan
```

```
cat /sbin/devstatus
#!/bin/sh
. /usr/share/libubox/jshn.sh
DEVICE="$1"
 
[ -n "$DEVICE" ] || {
	echo "Usage: $0 <device>"
	exit 1
}
 
json_init
json_add_string name "$DEVICE"
ubus call network.device status "$(json_dump)"
```

Here you may see that it uses [jshn library](/docs/guide-developer/jshn "docs:guide-developer:jshn")

## Wireless

### Toggle button for WiFi

```
[ -s /var/state/wireless ] && wifi down || wifi up
```

### Unlock all WiFi regulatory domains on Atheros

- [build your own image](/docs/guide-developer/toolchain/start "docs:guide-developer:toolchain:start") and set `CONFIG_ATH_USER_REGD` flag.
- see the whole [regulatory database](http://git.kernel.org/cgit/linux/kernel/git/linville/wireless-regdb.git/tree/db.txt?id=HEAD "http://git.kernel.org/cgit/linux/kernel/git/linville/wireless-regdb.git/tree/db.txt?id=HEAD") to find out what regulations apply.

## Packages

### Make local copy of packages

If you use trunk version it may be useful to make local copy of packages, because new trunk version may prevent you to install kernel-related packages from official sources.

```
wget -r -np http://downloads.openwrt.org/snapshots/trunk/ar71xx/packages/
```

*Assuming your architecture is `ar71xx`. This may require around 300 MB of free disk space.*

### Elliptic curves in OpenSSH

[ECC](https://en.wikipedia.org/wiki/Elliptic_curve_cryptography "https://en.wikipedia.org/wiki/Elliptic_curve_cryptography") is especially favourable on low performance system like mobile phones or routers. For example, 15360 bit [RSA](https://en.wikipedia.org/wiki/RSA_%28algorithm%29 "https://en.wikipedia.org/wiki/RSA_(algorithm)") key took 9.1 seconds to login and [equally strong](http://www.keylength.com/en/4/ "http://www.keylength.com/en/4/") (actually little bit stronger) 521 bit [ECDSA](https://en.wikipedia.org/wiki/ECDSA "https://en.wikipedia.org/wiki/ECDSA") key took only 1.7 seconds to login. However the difference won't be really noticeble with shorter keys. To get it working, you need to:

1. compile `libopenssl` without `NO-EC` option
2. compile `openssh-server` and `openssh-keygen` with the new `libopenssl` in `build_dir`
3. ```
   ssh-keygen -t ecdsa -b 521
   ```

### Reinstalling Packages after Firmware Upgrade

If you save the list of installed packages before a firmware upgrade, you can reinstall all packages that are not part of the firwmare with the script suggested in [this thread](https://forum.openwrt.org/viewtopic.php?id=42739 "https://forum.openwrt.org/viewtopic.php?id=42739").

## USB

### Benchmark your drive

Firstly, you will need `hdparm` program. Then locate your attached drive in `/dev` directory - typically `/dev/sda1` or `/dev/sda2` etc.

```
opkg update && opkg install hdparm
hdparm -t /dev/sda1
```

See also [USB Benchmarks](/docs/guide-user/perf_and_log/benchmark.usb "docs:guide-user:perf_and_log:benchmark.usb") and [Filesystems performance](/docs/techref/hardware/performance "docs:techref:hardware:performance") page.

## LED

### IPv6 activity LED

Flashes on activity in [Hurricane Electric](http://tunnelbroker.net "http://tunnelbroker.net") [6in4 tunnel](/docs/guide-user/network/tunneling_interface_protocols#static_ipv6-in-ipv4_tunnel "docs:guide-user:network:tunneling_interface_protocols"). Taken from `/etc/config/system` file:

`config 'led' '6in4_led' option 'name' '6in4' option 'sysfs' 'tl-wr1043nd:green:qss' option 'trigger' 'netdev' option 'mode' 'link tx rx' option 'dev' '6in4-wan6'`

Note:*detailed configuration is [here](/docs/guide-user/base-system/led_configuration#networkactivity "docs:guide-user:base-system:led_configuration").*

## Banner customization

All edits take place in `/etc/profile` file. We place the scripts in this section below the `cat /etc/banner`.

### Show screen sessions

For those who uses the `screen` command. This will print for example this:

`3 Screen sessions: pts-0, snort, iperf`

And the script for it:

```
local screenlabel=$(screen -ls | sed -n 's|^\([0-9][0-9]*\) Socket.*| \1 Screen sessions: |p')
screen -ls | sed -n 's|[^a-z]*[0-9][0-9]*\.\([a-zA-Z][a-zA-Z0-9-]*\).*|\1|p' | sed -e "s|^|${screenlabel}|" -e :a -e N -e 's|\n|, |' -e ta
```

*Note: `screenlabel` variable just contain number of sessoins and static text, so if you are ok with just list of screen sessions you can skip it and make it little bit more clear. Second line first get names of sessions, then add `screenlabel` variable in front of it and then put it all in one line.*

### Show available entropy

Less useful script, but anyway ;)

`Entropy: 143/4096`

```
echo " Entropy:" $(cat /proc/sys/kernel/random/entropy_avail)/$(cat /proc/sys/kernel/random/poolsize)
```
