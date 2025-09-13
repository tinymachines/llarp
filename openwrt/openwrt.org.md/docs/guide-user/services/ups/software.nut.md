# NUT (Network UPS Tools)

The [NUT](http://www.networkupstools.org/ "http://www.networkupstools.org/") package can be useful if you have an UPS connected to the router. For example, you have multiple devices connected to the UPS (PC, NAS ...), but your router is the only device that runs 24/7 (or at least it runs most of the time). In this case you run NUT in *netserver* mode, where other devices connect to router to see UPS status and be able to shut down correctly if power fails. NUT must be installed on every machine using this feature.

NUT can be installed from packages feed.

NUT was updated with more UCI in commit [a23c4e85](https://github.com/openwrt/packages/commit/a23c4e85c5f6c9f9dcf67743b93c492ba833e365 "https://github.com/openwrt/packages/commit/a23c4e85c5f6c9f9dcf67743b93c492ba833e365"), which appears in the 18.06 release.

## 18.06 and beyond

NOTE: configuration has **changed**: It's now all done through UCI (see below) (and the UCI is changed).

If you wish to use a 'standard' NUT config just remove the symlinks in /etc/nut and replace them with regular NUT configuration files.

### 18.06 / Commit a23c4e85

Due to changes in procd (or the OpenWrt shell wrapper around starting and stopping services with procd) stopping/restarting NUT stopped working properly. Work is underway to remedy this. Unfortunately issues were not reported before the 18.06 release. 18.06.1 has fixes for the most troublesome of the issues, and 18.06.2 should resolve the rest.

[PR #7638](https://github.com/openwrt/packages/pull/7638 "https://github.com/openwrt/packages/pull/7638") / [Commmit c95a1d3](https://github.com/openwrt/packages/commit/c95a1d3da89cb62eacc1d8217b861b36194d8838 "https://github.com/openwrt/packages/commit/c95a1d3da89cb62eacc1d8217b861b36194d8838") Resolves these issues in the 18.06 branch. This should be in the next 18.06.x point release (18.06.2).

See [PR #6987](https://github.com/openwrt/packages/pull/6897 "https://github.com/openwrt/packages/pull/6897"), [Issue #6997](https://github.com/openwrt/packages/issues/6997 "https://github.com/openwrt/packages/issues/6997"), [Issue #6966](https://github.com/openwrt/packages/issues/6966 "https://github.com/openwrt/packages/issues/6966"), and [Issue #6843](https://github.com/openwrt/packages/issues/6843 "https://github.com/openwrt/packages/issues/6843")

### Commit f48b060 on master

With [Commit f48b060 on master](https://github.com/openwrt/packages/commit/f48b060fa752fdf6556080dc1af221363f9b1ef4 "https://github.com/openwrt/packages/commit/f48b060fa752fdf6556080dc1af221363f9b1ef4") all known issues are resolved.

[Commit 8ff6a83](https://github.com/openwrt/packages/pull/7167/commits/8ff6a83a541b114437eab170a0760c1c04263aa2 "https://github.com/openwrt/packages/pull/7167/commits/8ff6a83a541b114437eab170a0760c1c04263aa2") adds building of serial drivers by default.

[Commit daa974c](https://github.com/openwrt/packages/pull/7167/commits/daa974cff0bef94c71277e703c32b3fd36f1411b "https://github.com/openwrt/packages/pull/7167/commits/daa974cff0bef94c71277e703c32b3fd36f1411b") completes the USB UPS hotplugging in which a USB UPS driver can be run as non-root and the USB device will be given the right permissions.

[Commit a5d06ce](https://github.com/openwrt/packages/pull/7592/commits/a5d06ce1106644b26a1b9d0ad87220d772d6b862 "https://github.com/openwrt/packages/pull/7592/commits/a5d06ce1106644b26a1b9d0ad87220d772d6b862") adds hotplug support for serial UPSes when using a standare serial-to-USB cable.

### Package Selection

Package Purpose nut Required to enable the 'real' packages nut-common Required for all NUT packages nut-server NUT server or standalone; only for the host attached directly to the UPS. Note will require a 'nut-dirver-xxx' driver to actually connect to the UPS. nut-upsmon Monitoring and/or triggering shutdown (e.g. client mode; can be on a server too and is in fact recommended on all hosts). nut-upsc Command line client for querying UPS status nut-upscmd Perform 'instant commands' on UPS (e.g. remote shutdown) if supported by UPS nut-upslog Read UPS log variables and write them to a file nut-upsrw Set variables on UPS (e.g. buzzer status) if supported by UPS nut-upssched Schedule script actions from some time after a UPS event nut-upsmon-sendmail-notify Send an email via sendmail command on a UPS event. In 18.06, added in commit [c94e334c4](https://github.com/openwrt/packages/commit/c94e334c4e5251d09995e3f6c8b80d61928a451c#diff-4ea671be370e4ab06ffeb50e1312d11e "https://github.com/openwrt/packages/commit/c94e334c4e5251d09995e3f6c8b80d61928a451c#diff-4ea671be370e4ab06ffeb50e1312d11e") nut-web-cgi A 'web' (e.g. uhttpd) GUI for monitoring the UPS nut-avahi-service Advertise the UPS server via mDNS (avahi-daemon only) nut-driver-xxx Where xxx is a driver from the list below

#### UPS Drivers

See [NUT Stable Hardware Compatibility List](https://networkupstools.org/stable-hcl.html "https://networkupstools.org/stable-hcl.html") to match your UPS model to a driver.

##### Serial

- al175
- bcmxcp
- belkin
- belkinunv
- bestfcom
- bestfortress
- bestuferrups
- bestups
- dummy-ups
- etapro
- everups
- gamatronic
- genericups
- isbmex
- liebert
- liebert-esp2
- masterguard
- metasys
- oldm
- e-shut
- mge-utalk

<!--THE END-->

- microdowell
- mge-shut
- oneac
- optiups
- powercom
- rhino
- safenet
- solis
- tripplite
- tripplitesu
- upscode2
- victronups
- powerpanel
- blazer\_ser
- clone
- ivtscd
- apcsmart
- apcsmart-old
- apcupsd-ups
- riello\_ser

##### SNMP

- snmp-ups

##### USB

- usbhid-ups
- bcmxcp\_usb
- tripplite\_usb
- blazer\_usb
- richcomm\_usb
- riello\_usb
- nutdrv\_atcl_
- usb nutdrv\_qx

## LuCI app

There was a Pull Request ([#936](https://github.com/openwrt/luci/pull/936 "https://github.com/openwrt/luci/pull/936")) for a LuCI app for the new configuration that sadly never made into 18.06, for complicated reasons that are non-technical, but is merged in a modified form into master.

## 18.06.x+ UCI files

File Purpose [nut\_cgi](/docs/guide-user/services/ups/software.nut#nut_cgi "docs:guide-user:services:ups:software.nut") configure nut-cgi [nut\_monitor](/docs/guide-user/services/ups/software.nut#nut_monitor "docs:guide-user:services:ups:software.nut") configure nut-monitor [nut\_server](/docs/guide-user/services/ups/software.nut#nut_server "docs:guide-user:services:ups:software.nut") configure nut-server

## UCI Configuration (18.06.x+)

### nut\_server

There can be more than one of each section (as appropriate)

#### config driver\_global

[Commit 44e57d4](https://github.com/openwrt/packages/commit/44e57d4bdfe93214e9c031f181533bb0e4ef25ca "https://github.com/openwrt/packages/commit/44e57d4bdfe93214e9c031f181533bb0e4ef25ca") (adds the following variables) and [Commit f48b060](https://github.com/openwrt/packages/commit/f48b060fa752fdf6556080dc1af221363f9b1ef4 "https://github.com/openwrt/packages/commit/f48b060fa752fdf6556080dc1af221363f9b1ef4") (fixes synchronous setting)

Option Type Required Default Description chroot string no *none* chroot directory driverpath string no /lib/nut Where to search for drivers maxstartdelay integer no *none* Override default for UPSes not specifying this field maxretry integer no 1 Number of time to retry loading driver (apart from procd's respawn) initially retrydelay integer no 5 Number of seconds between retries pollinterval integer no 2 Maximum number of seconds between UPS status refresh synchronous boolean string no no Whether reading from UPS has to empty pipe before more data written user string no nut If run as root, user to which to drop privileges

#### config driver 'upsname'

**NB**: From 18.06

The config section name (e.g. 'upsname' above) will be used a the ups name.

Option Type Required Default Description driver string yes *none* Driver for the model of UPS (see list above and [NUT HCL for stable release](https://networkupstools.org/stable-hcl.html "https://networkupstools.org/stable-hcl.html")) port string yes ? (shouldn't rely on anyway) Port on which the UPS is attached (or auto for auto-detection with USB) other string varies *none* see HCL above runas string no *none* User as which to run the daemon (note that means the USB device has in /dev/bus/usb/xxxx has to be *writable* by this user)

As of [ceff6883](https://github.com/openwrt/packages/commit/ceff68837d4b8d5a9bd8bf1962e913b5203d95e5 "https://github.com/openwrt/packages/commit/ceff68837d4b8d5a9bd8bf1962e913b5203d95e5") adding random parameters was removed and only pre-defined parameters are allowed.

Option Type Required Default Description mfr string no *none* Manufacturer description string model string no *none* Model description string serial string no *none* Serial number description string or regex match for serial number (depends on driver) sdtime integer no *none* Number of seconds for driver to sleep after sending shutdown signal offdelay integer no 20 Number of seconds UPS will wait before shutting down after receiving shutdown signal ondelay integer no 30 Number of seconds UPS will wait before powering up if still on mains after shutdown (must be less than ondelay) pollfreq integer no 30 How often driver will poll UPS for data vendor string no *none* regex to match USB vendor string product string no *none* regex to match USB product string bus string no *none* regex to match a specific USB bus or group of busses interruptonly boolean no false flag to driver to do no polling, only get data by interrupts (push) from UPS interruptsize integer no *none* limit interrupt data to given number of bytes; e.g. for some PowerCom units maxreport boolean no false With this option, the driver activates a tweak to workaround buggy firmware returning invalid HID report length. Some APC Back-UPS units are known to have this bug. vendorid string no *none* regex: Match only UPSes with this USB vendorid productid string no *none* regex: Match only UPSes with this USB productid community string no public For snmp-ups: community to poll UPS snmp\_version v1, v2c, or v3 no v1 For snmp-ups: SNMP version snmp\_retries integer no 5 Number of Net-SNMP tries snmp\_timeout integer no 1 Number of seconds between Net-SNMP retries notransferoids boolean no false Disable the monitoring of the low and high voltage transfer OIDs in the hardware. This will remove input.transfer.low and input.transfer.high from the list of variables. This should only be used on APCC Symmetra equipment which has strangeness in the three-phase power reporting.

[Commit 44e57d4](https://github.com/openwrt/packages/commit/44e57d4bdfe93214e9c031f181533bb0e4ef25ca "https://github.com/openwrt/packages/commit/44e57d4bdfe93214e9c031f181533bb0e4ef25ca") (adds the following variables)

Option Type Required Default Description synchronous yes or no no no Whether UPS must read all data from UPS before getting new data maxstartdelay integer no 45 How long NUT waits for driver to start before giving up retrydelay integer no 5 How long NUT waits to retry starting driver override list of strings no *none* names of 'override' config sections (below) default list of strings no *none* names of 'default' config sections (below) other list of strings no *none* names of 'other' config sections (below) otherflags list of strings no *none* names of 'otherflag' config sections (below)

config override 'override\_\[variable\_name]'

e.g. `config override 'override_battery_charge_low`' creates ups.conf entry for `override.battery.charge.low =`

Option Type Required Default Description value varies yes *none* Value driver 'pretends' UPS sent

config default 'default\_\[variable\_name]'

e.g. `config default 'default_battery_charge_low`' creates ups.conf entry for `default.battery.charge.low =`

Option Type Required Default Description value varies yes *none* Value driver 'pretends' UPS sent unless UPS actually sends a value

config override 'other\_\[parameter]'

e.g. `config other 'other_parameter`' creates ups.conf entry for `parameter =`

Option Type Required Default Description value varies yes *none* A way to handle currently unknown (to UCI) parameters

config override 'otherflag\_\[parameter]'

e.g. `config override 'otherflag_extraflag`' creates ups.conf entry for `extraflag`

Option Type Required Default Description value boolean yes false A way to handle currently unknown (to UCI) flags

#### config user

**NB** From 18.06

Option Type Required Default Description username string yes ? (probably not) 'username' (NUT only) for accessing a this server with e.g. upsmon (local or remote) password password yes *none* password for the above user actions string no *none* optional action (only listed allowed) instcmd list of strings no *none* upsmon ('slave' or 'master') yes ? Whether client is a 'slave' for 'master'. slaves are dependent on masters and can't shutdown the UPS on low UPS power; used for multiple hosts on the same UPS

#### config listen\_address

Option Type Required Default Description address IPv4 or IPv6 address yes ::1 Address to which to bind server (can be a wildcard address such as 0.0.0.0) port tcp port yes 3493 Port on which to listen

#### config upsd 'upsd'

There should only be on 'upsd' section and it should be named 'upsd'

Option Type Required Default Description maxage integer yes 15 Maximum number of seconds before data is considered 'stale' statepath string yes /var/run/nut Where to store runtime data maxconn integer yes 102 Maximum number of connections to accept at once certfile path no *none* Only for SSL-enabled builds; path to SSL certificate

### nut\_server default file

```
#config driver 'upsname'
#	option driver usbhid-ups
#	option port auto
#	option other other-value
#	option runas root

#config user
#	option username upsuser
#	option password upspassword
#	option actions optional-action
#	list instcmd optional-instant-command
#	option upsmon slave|master

#config listen_address
#	option address ::1
#	option port 3493

#config upsd 'upsd'
#	option maxage 15
#	option statepath /var/run/nut
#	option maxconn 1024
# NB: certificates only apply to SSL-enabled version
#       option certfile /usr/local/etc/upsd.pem
```

### nut\_server working example

```
config driver 'eaton5p'
  option driver usbhid-ups
  option port auto
  
config user
   option username upsuser
   option password somepassword
   option upsmon master
   # For a netserver, otherwise the default ::1 (localhost) is fine

config listen_address
   option 0.0.0.0

config upsd upsd
```

### nut\_monitor

#### config upsmon 'upsmon'

There should be only one upsmon section and should be named 'upsmon'

Option Type Required Default Description runas string yes nut User as which to execute upsmon minsupplies integer yes 1 Not OpenWrt relevent (Datacentre use) minimum number of UPSes that have to be supplying power to host shutdowncmd path yes /sbin/halt Command to run on UPS clean shutdown (either due to lower power, or NUT action notifycmd path no *none* Command to execute if 'notify' type EXEC is set defaultnotify list of SYSLOG or EXEC or IGNORE or WALL yes SYSLOG How to notify of UPS monitoring events. Note that nut-upsmond-sendmail-notify sets *notifycmd* to a script which emits a message via email (using 'sendmail' command in standard location) and adds EXEC to *defaultnotify* pollfreq integer yes 5 Time in seconds to query the NUT server pollfreqalert integer yes 5 Time in seconds to query the NUT server while on battery hostsync integer yes 15 From [upsmon.conf man page (official)](https://networkupstools.org/docs/man/upsmon.conf.html "https://networkupstools.org/docs/man/upsmon.conf.html") upsmon will wait up to this many seconds in master mode for the slaves to disconnect during a shutdown situation. By default, this is 15 seconds. When a UPS goes critical (on battery + low battery, or “FSD”: forced shutdown), the slaves are supposed to disconnect and shut down right away. The HOSTSYNC timer keeps the master upsmon from sitting there forever if one of the slaves gets stuck. This value is also used to keep slave systems from getting stuck if the master fails to respond in time. After a UPS becomes critical, the slave will wait up to HOSTSYNC seconds for the master to set the FSD flag. If that timer expires, the slave will assume that the master is broken and will shut down anyway. This keeps the slaves from shutting down during a short-lived status change to “OB LB” that the slaves see but the master misses. deadtime integer yes 15 How long a server can go missing before declaring it 'dead' powerdownflags path no /var/run/killpower If NUT sees this file it will powerdown the UPS(es) finaldelay integer yes 15 From [upsmon.conf man page (official)](https://networkupstools.org/docs/man/upsmon.conf.html "https://networkupstools.org/docs/man/upsmon.conf.html") When running in master mode, upsmon waits this long after sending the NOTIFY\_SHUTDOWN to warn the users. After the timer elapses, it then runs your SHUTDOWNCMD. By default this is set to 5 seconds. If you need to let your users do something in between those events, increase this number. Remember, at this point your UPS battery is almost depleted, so don’t make this too big. Alternatively, you can set this very low so you don’t wait around when it’s time to shut down. Some UPSes don’t give much warning for low battery and will require a value of 0 here for a safe shutdown. certpath path no /etc/ssl/certs Only for SSL-enabled builds: Path to directory containing CA certificates for validating SSL certificates certverify boolean no false Only for SSL-enabled builds: server CommonName must match DNS name we are using forcessl boolean no false Only for SSL-enabled builds: implied by certverify; without certverfy requires the connection is at least encrypted

For each of (lowercased):

- COMOK
- COMBAD
- SHUTDOWN
- REPLBATTERY
- NOCOMMS
- NOPARENT
- ONLINE
- ONBATT
- LOWBATT
- FSD

There are 'XXXmsg' and 'XXXnotifyflag' options (e.g. 'comokmsg' and 'comoknotifyflag').

This are all optional. The 'msg' options are strings and are messages to emit instead of the default on one of the above conditions (see [upsmon.conf man page (official)](https://networkupstools.org/docs/man/upsmon.conf.html "https://networkupstools.org/docs/man/upsmon.conf.html")).

The 'notifyflag' options are boolean (default true) and indicate whether to emit the message using the 'defaultnotify' setting or to not emit a message (IGNORE) setting for that message.

#### config master and config slave

##### Slave vs. Master

From 'UPS TYPES' in [upsmon manpage (official)](https://networkupstools.org/docs/man/upsmon.html "https://networkupstools.org/docs/man/upsmon.html")

upsmon and upsd(8) don’t always run on the same system. When they do, any UPSes that are directly attached to the upsmon host should be monitored in “master” mode. This makes upsmon take charge of that equipment, and it will wait for slaves to disconnect before shutting down the local system. This allows the distant systems (monitoring over the network) to shut down cleanly before upsdrvctl shutdown runs and turns them all off.

When upsmon runs as a slave, it is relying on the distant system to tell it about the state of the UPS. When that UPS goes critical (on battery and low battery), it immediately invokes the local shutdown command. This needs to happen quickly. Once it disconnects from the distant upsd(8) server, the master upsmon will start its own shutdown process. Your slaves must all shut down before the master turns off the power or filesystem damage may result.

upsmon deals with slaves that get wedged, hang, or otherwise fail to disconnect from upsd(8) in a timely manner with the HOSTSYNC timer. During a shutdown situation, the master upsmon will give up after this interval and it will shut down anyway. This keeps the master from sitting there forever (which would endanger that host) if a slave should break somehow. This defaults to 15 seconds.

If your master system is shutting down too quickly, set the FINALDELAY interval to something greater than the default 15 seconds. Don’t set this too high, or your UPS battery may run out of power before the master upsmon process shuts down that system

##### options

Option Type Required Default Description upsname string yes *none* name assigned to the UPS by the server hostname string yes *none* host with the UPS server (dns name or ip) port tcp port no 3493 port on which to connect to server powervalue integer yes 1 Number of UPSes supplying this host from the server username string yes *none* NUT username for connecting to the server password password yes *none* NUT password for the user for connecting to the server

### nut\_monitor default file

```
#config upsmon 'upsmon'
#	option runas run-as-user
#	option minsupplies 1
#	option shutdowncmd /sbin/halt
#	option notifycmd /path/to/cmd
#	list defaultnotify SYSLOG
#	option pollfreq 5
#	option pollfreqalert 5
# 	option hostsync 15
#	option deadtime 15
#	option powerdownflags /var/run/killpower
#	option onlinemsg "online message"
#	option onbattmsg "on battery message"
#	option lowbattmsg "low battery message"
#	option fsdmsg "forced shutdown message"
#	option comokmsg "communications restored message"
#	option combadmsg "communications bad message"
#	option shutdowmsg "shutdown message"
#	option replbattmsg "replace battery message"
#	option nocommmsg "no communications message"
#	option noparentmsg "no parent message"
#	option onlinenotify "online notify flag 1|0"
#	option onbattnotify "on battery notify flag 1|0"
#	option lowbattnotify "low battery notify flag 1|0"
#	option fsdnotify "forced shutdown notify flag 1|0"
#	option comoknotify "communications restored notify flag 1|0"
#	option combadnotify "communications bad notify flag 1|0"
#	option shutdownotify "shutdown notify flag 1|0"
#	option replbattnotify "replace battery notify flag 1|0"
#	option nocommnotify "no communications notify flag 1|0"
#	option noparentnotify "no parent notify flag 1|0"
#	option rbwarntime 4200 # replace battery warn time
#	option nocommwarntime 300 # no communications warn time
#	option finaldelay 5 # final delay
#	option certpath /path/to/ca/dir
#	option certverify 0
#	option forcessl 0

#config master
#	option upsname upsname
#	option hostname localhost
#	option port # optional port number
#	option powervalue 1
#	option username upsuser
#	option password upspassword

#config slave
#	option upsname upsname
#	option hostname localhost
#	option port # optional port number
#	option powervalue 1
#	option username upsuser
#	option password upspassword
```

### nut\_monitor working example

```
config 'upsmon' upsmon

config master
  option upsname eaton5p
  option hostname localhost
  option username upsuser
  option password somepassword
```

### nut\_cgi

The NUT CGI doensn't have to be on the same server as nut-monitor or nut-server.

It does however require a webserver installed (default configuration is for uhttpd).

Option Type Required Default upsname upsname yes *none* Name of UPS to monitor (as configured in nut\_server) hostname hostname yes *none* Name or IP of NUT server port tcp port no 3493 Port on which to connect to NUT server displayname string yes none What to show in Web UI as the UPS name

### nut\_cgi default config file

```
#config host
#	option upsname upsname
#	option hostname localhost
#	option port # optional port number
#	option displayname "Display Name"
```

### nut\_cgi working example

```
config host
  option uspsname eaton5p
  option hostname localhost
  option displayname "Eaton 5P"
```

## Pre 18.06

In *older release(s)* there's problem with some USB UPSes (e.g. EATON) that are not recognized by usbhid-ups. This is apparently a bug in libusb-compat, since libusb (0.1.4) can recognize them. You can work around this by installing Attitude Adjustment, manually installing packages *libusb-compat* and **nut-driver-usbhid-ups**, then manualy remove *libusb-compat* and install **libusb** istead (packages in trunk may break on having manually installed libusb)

You will want to have packages **nut**, **nut-server** and **nut-client** packages installed to have main functionality.

**NOTE** UCI configuration has changed for 18.06 (as of the commit above).

You may want to have nut-monitor installed, if you want to shutdown your router when UPS power goes critical and your device can turn itself off. Otherwise, the UPS will only provide information for you and clients.

NUT expects configuration by [UCI](/docs/techref/uci "docs:techref:uci"), by putting the following into **/etc/config/ups**:

```
config driver 'eaton'
        option driver 'usbhid-ups'
        option port 'auto'

config user
        option username 'guest'
        option password 'guest'
        option upsmon 'slave'
```

For the NUT to run at all, you must change the MODE in **/etc/nut/nut.conf** to e.g. netserver:

```
MODE=netserver
```

If you want the upsd be acccessible from network (why otherwise would you want to run nut on router?), you must put a LISTEN directive to **/etc/nut/upsd.conf**:

```
LISTEN 0.0.0.0
```

You may want to change options according to the type of UPS you have and options you want to use.

### Configuring upsmon

After you installed and configured NUT, you may want to setup your router for monitoring UPS. You need to install *nut-monitor* package and add your config to **/etc/config/upsmon**

Sample upsmon config

```
config upsmon
        option 'shutdowncmd' '/lib/nut/upsdrvctl shutdown'
        option 'notifycmd' '/etc/nut/notify.sh'
        option 'onlinemsg' 'UPS %s on line power'
        option 'onbattmsg' 'UPS %s on battery'
        option 'lowbattmsg' 'UPS %s battery is low'
        option 'fsdmsg' 'UPS %s: forced shutdown in progress'
        option 'commokmsg' 'Communications with UPS %s established'
        option 'commbadmsg' 'Communications with UPS %s lost'
        option 'shutdownmsg' 'Auto logout and shutdown proceeding'
        option 'replbattmsg' 'UPS %s battery needs to be replaced'
        option 'nocommmsg' 'UPS %s is unavailable'
        option 'noparentmsg' 'upsmon parent process died - shutdown impossible'
        option 'onlinenotify' 'EXEC+SYSLOG'
        option 'onbattnotify' 'EXEC+SYSLOG'
        option 'lowbattnotify' 'EXEC+SYSLOG'
        option 'fsdnotify' 'EXEC+SYSLOG'
        option 'commoknotify' 'EXEC+SYSLOG'
        option 'commbadnotify' 'EXEC+SYSLOG'
        option 'shutdownnotify' 'EXEC+SYSLOG'
        option 'replbattnotify' 'EXEC+SYSLOG'
        option 'nocommnotify' 'EXEC+SYSLOG'
        option 'noparentnotify' 'EXEC+SYSLOG'
config master
        option 'upsname' 'UPS'
        option 'user' 'guest'
        option 'password' 'guest'
```

Upsmon will send to *notifycmd* script some environment strings:

```
$UPSNAME - will contain the name of UPS specified in /etc/config/ups
$NOTIFYTYPE - will contain the type string of whatever caused this event to happen.
```
