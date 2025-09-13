# FreeSWITCH on OpenWrt intro

This page is meant to provide some basic information about FreeSWITCH on OpenWrt. Visit the official [FreeSWITCH wiki](https://freeswitch.org/confluence/display/FREESWITCH/FreeSWITCH+Explained "https://freeswitch.org/confluence/display/FREESWITCH/FreeSWITCH+Explained") to find out more about FreeSWITCH in particular.

**Telephony systems like FreeSWITCH are targeted by criminals to commit toll fraud. If you fall victim to toll fraud this can cost you a lot of money. You are responsible for the security of your sytem. Make sure all security measures are in place before bringing FreeSWITCH online.**

## freeswitch init configuration

The file `/etc/config/freeswitch` contains the general on/off switch - FreeSWITCH is disabled by default. Here you can also change the command line switches that are used when starting FreeSWITCH. E.g. you can set the directories for recordings and logs etc.

**WARNING: FreeSWITCH writes to its databases constantly. Constant writes will quickly kill your device's integrated flash memory.**

It's recommended to keep the databases on external storage (see [Using storage devices](/docs/guide-user/storage/usb-drives "docs:guide-user:storage:usb-drives")).

If that is not possible they can also be kept in the device's RAM (working memory), on a *tmpfs* filesystem (`/tmp` is mounted as a *tmpfs* file system on OpenWrt devices). RAM memory is not subject to constant writing wear like flash memory.  
The downside of the *tmpfs* approach is that the databases will be lost when the device loses power or is restarted, also the RAM used by these databases will decrease the amount of available RAM of the system by a few MB. Please consider your options and requirements.

Last but not least, you can select whether the output streams (*STDOUT* and *STDERR*) that are sent to the init process (`procd`), shall be forwarded to the system logger. Defaults to yes for both.

## freeswitch packages

### Modules

FreeSWITCH has a multitude of modules. OpenWrt typically runs on hardware that is somewhat restricted, i.e. memory, storage and processing power are limited. Luckily only a few packages are needed for basic functionality (depending on what you want it to do). Here is a list of modules you might be interested in:

- [freeswitch-mod-commands](https://freeswitch.org/confluence/display/FREESWITCH/mod_commands "https://freeswitch.org/confluence/display/FREESWITCH/mod_commands"): various API commands, for instance `fsctl`
- [freeswitch-mod-dialplan-xml](https://freeswitch.org/confluence/display/FREESWITCH/XML+Dialplan "https://freeswitch.org/confluence/display/FREESWITCH/XML+Dialplan"): adds support for dialplans written in XML
- [freeswitch-mod-dptools](https://freeswitch.org/confluence/display/FREESWITCH/mod_dptools "https://freeswitch.org/confluence/display/FREESWITCH/mod_dptools"): dialplan tools (`answer`, `blind_transfer` etc.)
- [freeswitch-mod-event-socket](https://freeswitch.org/confluence/display/FREESWITCH/mod_event_socket "https://freeswitch.org/confluence/display/FREESWITCH/mod_event_socket"): provides a socket interface to FreeSWITCH which is used, for example, by `fs_cli`
- [freeswitch-mod-hash](https://freeswitch.org/confluence/display/FREESWITCH/mod_hash "https://freeswitch.org/confluence/display/FREESWITCH/mod_hash"): can be used to limit the amount of calls and other things
- [freeswitch-mod-logfile](https://freeswitch.org/confluence/display/FREESWITCH/mod_logfile "https://freeswitch.org/confluence/display/FREESWITCH/mod_logfile"): allows saving logs of the running application
- [freeswitch-mod-sofia](https://freeswitch.org/confluence/display/FREESWITCH/mod_sofia "https://freeswitch.org/confluence/display/FREESWITCH/mod_sofia"): the SIP stack used by FreeSWITCH
- [freeswitch-mod-spandsp](https://freeswitch.org/confluence/display/FREESWITCH/mod_spandsp "https://freeswitch.org/confluence/display/FREESWITCH/mod_spandsp"): adds fax capabilities, also includes additional audio codecs, e.g. G722 (“HD Voice”)
- [freeswitch-mod-xml-cdr](https://freeswitch.org/confluence/display/FREESWITCH/mod_xml_cdr "https://freeswitch.org/confluence/display/FREESWITCH/mod_xml_cdr"): can save call data records, also useful for troubleshooting

### FreeTDM modules

FreeSWITCH supports select TDM hardware. At the heart of this sits [libfreetdm](https://freeswitch.org/confluence/display/FREESWITCH/FreeTDM "https://freeswitch.org/confluence/display/FREESWITCH/FreeTDM"). It will be pulled in automatically when you install the endpoint driver *freeswitch-mod-freetdm*, which is used by FreeSWITCH to interconnect with all protocols supported by FreeTDM.

FreeTDM itself is modular as well. OpenWrt packages the following FreeTDM modules:

- libfreetdm-ftmod-analog: signaling module; provides support for FXS/FXO
- libfreetdm-ftmod-analog-em: signaling module; not solely for analog, supports E1/T1 analog and digital cards using CASE&amp;M signaling
- libfreetdm-ftmod-libpri: signaling module; provides support for ISDN over PRI/BRI
- libfreetdm-ftmod-pritap: PRI tapping
- libfreetdm-ftmod-skel: example module
- libfreetdm-ftmod-zt: I/O module; takes care of reading and writing raw data bytes and executing low level control commands on the telephony hardware

Don't forget to install *kmod-dahdi*. It provides the kernel driver for the TDM hardware.

### Utilities

There are also a number of utilities available. Let's just mention the one that is probably the most important:

- [freeswitch-util-fs-cli](https://freeswitch.org/confluence/display/FREESWITCH/Command-Line+Interface+fs_cli "https://freeswitch.org/confluence/display/FREESWITCH/Command-Line+Interface+fs_cli"): allows CLI access to a FreeSWITCH server, either local or remote (uses the event socket interface mentioned above)

### Examples

The FreeSWITCH source contains a number of folders with configuration examples. These are packaged as well:

- freeswitch-example-curl
- freeswitch-example-insideout
- ...

Any of these will install the corresponding sample configuration to `/usr/share/freeswitch/examples`.

## Hotplug

The *freeswitch* package includes a hotplug script. You can set a hotplug interface in `/etc/config/freeswitch` to enable it.

Note: It may be advisable to disable the init autostart, to avoid FreeSWITCH beeing started twice when booting:

```
/etc/init.d/freeswitch disable
```

The hotplug script can check the following extra conditions:

- a device (perhaps a USB stick) is connected at a given mount point (for instance `/mnt/usb`)
- the system clock is accurate (needs `ntpd` to be installed)

If you add any of these conditions the hotplug script will only start FreeSWITCH if the condition is met. You can also specify the timeout after which it considers a condition failed (defaults to 60 seconds).

Below a log excerpt from the hotplug script in action:

```
Sat Nov 17 11:24:43 2018 user.notice freeswitch-hotplug: /mnt/usb mounted
Sat Nov 17 11:24:43 2018 user.notice freeswitch-hotplug: ntpd stratum 16
Sat Nov 17 11:24:43 2018 user.notice freeswitch-hotplug: system time not in sync yet, timeout in 60 s
Sat Nov 17 11:24:48 2018 user.notice freeswitch-hotplug: ntpd stratum 16
Sat Nov 17 11:24:48 2018 user.notice freeswitch-hotplug: system time not in sync yet, timeout in 55 s
Sat Nov 17 11:24:53 2018 user.notice freeswitch-hotplug: ntpd stratum 3
Sat Nov 17 11:24:53 2018 user.notice freeswitch-hotplug: ntpd to system time offset +/- 4 ms
Sat Nov 17 11:24:53 2018 user.notice freeswitch-hotplug: system time in sync
Sat Nov 17 11:24:54 2018 user.notice freeswitch-hotplug: started freeswitch due to "ifup wan" event
```

Both extra conditions were configured. A device was already mounted at `/mnt/usb`. The system time was initially not accurate, so the hotplug script waited a bit before starting FreeSWITCH.
