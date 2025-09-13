# Debugging

Debugging hardware can be tricky especially when doing kernel and drivers development. It might become handy for you to add serial console to your device as well as using JTAG to debug your code.

## Serial Port

→ [port.serial](/docs/techref/hardware/port.serial "docs:techref:hardware:port.serial")

## JTAG

→ [port.jtag](/docs/techref/hardware/port.jtag "docs:techref:hardware:port.jtag")

## GDB

![:!:](/lib/images/smileys/exclaim.svg) → [gdb](/docs/guide-developer/gdb "docs:guide-developer:gdb") a very short introduction on the GNU Debugger

## perf/oprofile cpu profiling

→ [http://false.ekta.is/2012/11/cpu-profiling-applications-on-openwrt-with-perf-or-oprofile/](http://false.ekta.is/2012/11/cpu-profiling-applications-on-openwrt-with-perf-or-oprofile/ "http://false.ekta.is/2012/11/cpu-profiling-applications-on-openwrt-with-perf-or-oprofile/")

## Wireless

When encountering wireless bugs, such as connection drop or wpa rekeying issues, it is possible to remotely run `tcpdump` in order to capture wireless management traffic for later analysis of the communication leading to the problem.

### Capture Management Traffic

The command below will spawn a monitor interface with a mac80211 based driver, start `tcpdump` and save the captured data locally into `/tmp`:

```
ssh root@192.168.1.1 'grep -q mon0 /proc/net/dev || /usr/sbin/iw phy phy0 interface add mon0 type monitor;
    /sbin/ifconfig mon0 up; /usr/sbin/tcpdump -s 0 -i mon0 -y IEEE802_11_RADIO -w -' > /tmp/wifi.pcap
```

A smaller alternative to `tcpdump` is the `iwcap` utility. Its MIPS binary only ~5KB large and it does not require `libpcap` to function. It also supports the filtering of data frames through the `-D` switch to cut down the amount of captured traffic;

```
ssh root@192.168.1.1 'grep -q mon0 /proc/net/dev || /usr/sbin/iw phy phy0 interface add mon0 type monitor;
    /sbin/ifconfig mon0 up; /usr/sbin/iwcap -i mon0 -s' > /tmp/wifi.pcap
```

### Logging hostapd behaviour

Note that recent versions of openwrt ship with a version of hostapd which has verbose debug messages disabled in order to save on space (see [https://dev.openwrt.org/ticket/15658](https://dev.openwrt.org/ticket/15658 "https://dev.openwrt.org/ticket/15658") ).

To enable debug you need to install the debug build of hostapd from the packages for your router (package name hostapd), having first removed the cut-down version: &lt;code bash&gt; opkg remove wpad-mini \[download the wpad-debug package for your router to /tmp] opkg install /tmp/wpad-debug\*.ipk &lt;/code&gt;

Increase the log level for hostapd:

```
# Levels (minimum value for logged events):
#  0 = verbose debugging
#  1 = debugging
#  2 = informational messages
#  3 = notification
#  4 = warning"
```

... the default is “informational messages”. The example below shows you how to change this to “debugging”.

Check the log level currently being used:

```
root@OpenWrt:~# ps | grep hostapd
 6948 root      1784 S    /usr/sbin/hostapd -P /var/run/wifi-phy1.pid -B /var/run/hostapd-phy1.conf
 6987 root      1784 S    /usr/sbin/hostapd -P /var/run/wifi-phy0.pid -B /var/run/hostapd-phy0.conf
 7019 root      1448 S    grep hostapd
```

let say for the sake of argument you're only interested in addressing a problem with the phy0 hostapd. First check the current level for this hostapd:

```
root@OpenWrt:~# grep _level /var/run/hostapd-phy0.conf 
logger_syslog_level=2
logger_stdout_level=2
```

... log level 2 is selected. Let's change this:

```
root@OpenWrt:~# uci set wireless.radio0.log_level=1
root@OpenWrt:~# uci commit wireless
root@OpenWrt:~# wifi up
root@OpenWrt:~# grep _level /var/run/hostapd-phy0.conf 
logger_syslog_level=1
logger_stdout_level=1
```

... and we can see that the level has been changed. The logread command will now show brief debug messages like those below:

```
Tue Apr 22 11:35:41 2014 daemon.debug hostapd: wlan0: STA 20:16:d8:db:aa:56 MLME: MLME-REASSOCIATE.indication(20:16:d8:db:aa:56)
Tue Apr 22 11:35:41 2014 daemon.debug hostapd: wlan0: STA 20:16:d8:db:aa:56 MLME: MLME-DELETEKEYS.request(20:16:d8:db:aa:56)
Tue Apr 22 11:35:41 2014 daemon.debug hostapd: wlan0: STA 20:16:d8:db:aa:56 WPA: event 1 notification
Tue Apr 22 11:35:41 2014 daemon.debug hostapd: wlan0: STA 20:16:d8:db:aa:56 WPA: start authentication
Tue Apr 22 11:35:41 2014 daemon.debug hostapd: wlan0: STA 20:16:d8:db:aa:56 IEEE 802.1X: unauthorizing port
Tue Apr 22 11:35:41 2014 daemon.debug hostapd: wlan0: STA 20:16:d8:db:aa:56 WPA: sending 1/4 msg of 4-Way Handshake
Tue Apr 22 11:35:41 2014 daemon.debug hostapd: wlan0: STA 20:16:d8:db:aa:56 WPA: received EAPOL-Key frame (2/4 Pairwise)
Tue Apr 22 11:35:41 2014 daemon.debug hostapd: wlan0: STA 20:16:d8:db:aa:56 WPA: sending 3/4 msg of 4-Way Handshake
Tue Apr 22 11:35:41 2014 daemon.debug hostapd: wlan0: STA 20:16:d8:db:aa:56 WPA: received EAPOL-Key frame (4/4 Pairwise)
```

... you may want to then setup remote logging via syslog to another computer by setting a logfile (warning - this won't be auto-rotated, so make sure it doesn't fill up a vital filesystem).

```
uci set system.@system[0].log_file=[path-to-my-logfile]
uci commit
[reboot required]
```

or alternatively, if you're able to, it might be better to use system.@system\[0].log\_ip to log to a remote machine (which must be running an appropriate listener e.g. rsyslogd - see [https://forum.openwrt.org/viewtopic.php?id=11912](https://forum.openwrt.org/viewtopic.php?id=11912 "https://forum.openwrt.org/viewtopic.php?id=11912")).

If you wish to debug on the command line instead, you may be able to do-so using a command like this:

```
kill `cat /var/run/wifi-phy0.pid` ; /usr/sbin/hostapd -dd -P /var/run/wifi-phy0.pid  /var/run/hostapd-phy0.conf
```

... use the output of ps above to create the necessary commandline - remove the '-B' argument to stop hostapd forking into the background, and add '-dd' to verbose debug to stdout.

depending on your hardware and interface state, it may be necessary to create or re-create the relevant wlan device before starting hostapd e.g.

```
iw dev wlan0 del
iw phy phy0 interface add wlan0 type managed
```

## Add and modify compiler debug flags

![:!:](/lib/images/smileys/exclaim.svg) The “Compile with debug” entry in advanced developer menu enables “-g3” compile option.

![:!:](/lib/images/smileys/exclaim.svg) You have to disable \_sstrip_ to keep debug information.

Note, if you just want to build a single package unstripped, try, “make package/foo/compile STRIP=true” Also, unstripped binaries are placed in “staging\_dir/target-\*/root-\*/” where your host side tools can use them. (Remember, gdbserver can attach to the stripped binary, while gdb loads the unstripped binary) see [gdb](/docs/guide-developer/gdb "docs:guide-developer:gdb")

Alternatively: You can add or modify “Custom Target Options” like add “-g3 -ggdb3”

![:!:](/lib/images/smileys/exclaim.svg) Be aware there are default compiler options defined in include/target.mk for example (“-Os -pipe”)

![:!:](/lib/images/smileys/exclaim.svg) Some packets might overwrite or not use the flags. Check your compile log.

Additional tips:

- check with different gcc versions
- There is “-O0” to disable compiler optimizations.
- “-Wall -Wextra” might provide useful warnings
- see [https://gcc.gnu.org/bugs/](https://gcc.gnu.org/bugs/ "https://gcc.gnu.org/bugs/")
