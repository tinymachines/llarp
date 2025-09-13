# NTP

See also [NTP client / NTP server](/docs/guide-user/services/ntp/client-server "docs:guide-user:services:ntp:client-server")

NTP provides time synchronization based on a network of reference clocks located around the world. OpenWrt supports both **NTP client** protocol (to synchronize local time with a distant clock) and **NTP server** protocol (to deliver time to your local network).

The ntp configuration is located in **system** uci subsystem, and found in file ***/etc/config/system***.

## Timeserver section

The NTP configuration is found in **timeserver** section of **system** uci subsystem.

```
# uci show system
system.ntp=timeserver
system.ntp.enabled='1'
system.ntp.enable_server='0'
system.ntp.server='0.openwrt.pool.ntp.org' '1.openwrt.pool.ntp.org' '2.openwrt.pool.ntp.org' '3.openwrt.pool.ntp.org'
```

## Timeserver section options

These are the options defined for the **timeserver ntp** section:

Name Type Required Default Description *server* list of hostnames no (openwrt ntp servers) Pool of NTP servers to poll the time from.  
If empty, ntpd disables client mode, and system time won't be set automatically. *enable\_server* boolean no 0 setting this to 1 enables the time server on this device, ntpd will answer with the time of the router.  
(busybox-ntpd listens to UDP 123 by default) *interface* interface name no *(none)* Bind timeserver only to specified interface. Available in snapshot since [e12fcf0](https://git.openwrt.org/?p=openwrt%2Fopenwrt.git%3Ba%3Dcommit%3Bh%3De12fcf0fe5597467f7cc21144e5f4da60500ebd2 "https://git.openwrt.org/?p=openwrt/openwrt.git;a=commit;h=e12fcf0fe5597467f7cc21144e5f4da60500ebd2") and in 21.02.0-rc4 since [a75928d](https://git.openwrt.org/?p=openwrt%2Fopenwrt.git%3Ba%3Dcommit%3Bh%3Da75928d1259e52e52b1991a4dc39df61ba3c9206 "https://git.openwrt.org/?p=openwrt/openwrt.git;a=commit;h=a75928d1259e52e52b1991a4dc39df61ba3c9206"). *use\_dhcp* boolean no 1 setting this to 0 disables the use of DHCP-provided NTP servers.

## Legacy information

In */etc/config/system* *busybox-rdate* (was invoked by scripts) has been replaced with *busybox-nptd* (can run as a daemon) to avoid race condition and also to use current NTP. The remote time is since configured in */etc/config/system* and not in */etc/config/timeserver* any longer.

- ![:!:](/lib/images/smileys/exclaim.svg) Old scripts first checked if a lease time server is defined for the interface in the network config.
- ![:!:](/lib/images/smileys/exclaim.svg) If not available or syncing fails, then it searches for time servers in the timeserver config that are either explicitly defined for that interface or via the global setting in the system config.

## NTP server

By default, NTP client is enabled and NTP server is disabled. Enable server mode:

```
uci set system.ntp.enable_server="1"
uci commit system
/etc/init.d/sysntpd restart
```

## Regional NTP pulls

In theory, OpenWrt pull zone provide the closest available servers. Practically, this may result in distant connections. To use NTP servers located in your country, it is possible to use regional pull zone. For example, in France, here is a sample configuration (notice the 'fr' for France and adapt it):

```
uci -q delete system.ntp.server
uci add_list system.ntp.server="0.fr.pool.ntp.org"
uci add_list system.ntp.server="1.fr.pool.ntp.org"
uci add_list system.ntp.server="2.fr.pool.ntp.org"
uci add_list system.ntp.server="3.fr.pool.ntp.org"
uci commit system
/etc/init.d/sysntpd restart
```

## NTP tools

By default, NTP server analysis tools are not installed (and not needed). You may want to install ntp-utils package, which is a collection of tools used to synchronize the system clock with remote NTP time servers and run/monitor local NTP servers. This package contains ntpdc, ntpq and ntptime.

```
opkg install ntp-utils
```

Enter 'ntpq' to query the NTP subsystem and 'peers' to display NTP peers used by your OpenWrt appliance:

```
# ntpq
ntpq> peer
     remote           refid      st t when poll reach   delay   offset  jitter
==============================================================================
 0.fr.pool.ntp.o .POOL.          16 p    -   64    0    0.000    0.000   0.000
 1.fr.pool.ntp.o .POOL.          16 p    -   64    0    0.000    0.000   0.000
 2.fr.pool.ntp.o .POOL.          16 p    -   64    0    0.000    0.000   0.000
 3.fr.pool.ntp.o .POOL.          16 p    -   64    0    0.000    0.000   0.000
+ntp-3.arkena.ne 138.96.64.10     2 u  134  256  375   11.838   -1.119   1.194
 nsr2.neoserveur 172.2.53.81      2 u 1520  512    2   17.462   -0.064   2.688
+62.210.28.176 ( 84.255.209.79    4 u  222  256  377   12.241    1.094   1.620
-time1.agiri.nin 213.246.39.118   3 u   28  256  377   12.385    2.388   0.767
*ns3.stoneartpro 193.52.184.106   2 u  107  256  377   11.448    0.467   1.243
```

Type 'q' to exit this display.
