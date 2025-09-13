# Procd system init and daemon management

**See also: [procd\_init\_scripts](/docs/guide-developer/procd-init-scripts#procd_init_scripts "docs:guide-developer:procd-init-scripts")**

`procd` is the OpenWrt [process](https://en.wikipedia.org/wiki/Process%20%28computing%29 "https://en.wikipedia.org/wiki/Process (computing)") management daemon written in [C](https://en.wikipedia.org/wiki/C%20%28programming%20language%29 "https://en.wikipedia.org/wiki/C (programming language)"). It keeps track of processes started from init scripts (via ubus calls), and can suppress redundant service start/restart requests when the config/environment has not changed.

`procd` has replaced ... , e.g.

- `hotplug2`, a dynamic device management subsystem for embedded systems. Hotplug2 is a trivial replacement of some of the UDev functionality in a tiny pack, intended for Linux early userspace: Init RAM FS and InitRD.
- `busybox-klogd` and `busybox-syslogd`
- `busybox-watchdog`

`procd` is intended to stay compatible with the existing format of `/etc/config/`; exceptions ...

## Help with the development of procd

1. test what has been ported
2. review of the code

## Buttons with procd

![:!:](/lib/images/smileys/exclaim.svg) see commit in [https://dev.openwrt.org/log/trunk/package/base-files/files/etc/rc.button](https://dev.openwrt.org/log/trunk/package/base-files/files/etc/rc.button "https://dev.openwrt.org/log/trunk/package/base-files/files/etc/rc.button")

![:!:](/lib/images/smileys/exclaim.svg) see use case [hardware.button](/docs/guide-user/hardware/hardware.button "docs:guide-user:hardware:hardware.button")

## Init scripts with procd

see [procd-init-scripts](/docs/guide-developer/procd-init-scripts "docs:guide-developer:procd-init-scripts")

## early state and preinit

Before the real procd runs, a small init process is started. This process has the job of early system init. It will do the following things in the listed order

- bring up basic mounts such as /proc /sys/{,fs/cgroup} /dev/{,shm,pts}
- create some required folder, /tmp/{run,lock,state}
- bring up /dev/console and map the processes stdin/out/err to the console (this is the “Console is alive” message)
- setup the PATH environment variable
- check if “init\_debug=” is set in the kernel command line and apply the debug level if set
- initialise the watchdog
- start kmodloader and load the modules listed in /etc/modules-boot.d/
- start hotplug with the preinit rules (/etc/hotplug-preinit.json)
- start preinit scripts found inside /lib/preinit/

Once preinit is complete the init process is done and will do an exec on the real procd. This will replace init as pid1 with an instance of procd running as the new pid 1. The watchdog file descriptor is not closed. Instead it is handed over to the new procd process. The debug\_level will also be handed over to the new procd instance if it was set via command line or during preinit.

## procd start up

Procd will first do some basic process init such as setting itself to be owner of its own process group and setting up signals. We are now ready to bring up the userland in the following order

- find out if a watchdog file descriptor was passed by the init process and start up the watchdog
- setup /dev/console to be our stdin/out/err
- start the coldplug process using the full rule set (/etc/hotplug.json). This is done by manually triggering all events that have already happened using udevtrigger
- start ubus, register it as a service and connect to it.

The basic system bringup is now complete, procd is up and running and can start handling daemons and services

## /etc/inittab

Procd supports four commands inside inittab

- respawn - this works just like you expect it. It starts a process and will respawn it once it has completed.
- respawnlate - this works like the respawn but will start the process only when the procd init is completed.
- askfirst - this works just like respawn but will print the line “Please press Enter to activate this console.” before starting the process
- askconsole - this works like askfirst but, instead of running on the tty passed as a parameter, it will look for the tty defined in the kernel command line using “console=”
- askconsolelate - this works like the askconsole but will start the process only when the procd init is completed.
- sysinit - this will trigger procd to run the command, given as a parameter, only once. This is usually used to trigger execution of /etc/rc.d/

Once all items inside /etc/inittab are processed, procd enter its normal run mode and will handle messages coming in via ubus. It will stay in this state until a reboot/shutdown is triggered.

## ubus command interface

## hotplug

Hotplug scripts are located inside /etc/hotplug.d and are based on json\_script. This is a json based if then else syntax. Procd hotplug service offers the following actions:

- makedev
- rm
- exec
- button
- load-firmware

**Under Construction!**  
This page is currently under construction. You can edit the article to help completing it.

## procd (process management daemon) – Technical Reference

- [Project's git](http://git.openwrt.org/?p=project%2Fprocd.git%3Ba%3Dsummary "http://git.openwrt.org/?p=project/procd.git;a=summary")
- procd is available in OpenWrt since [r34865 (trunk)](https://dev.openwrt.org/changeset/34865 "https://dev.openwrt.org/changeset/34865"). It consists of files under GPLv2, LGPLv2.1 and ISC licenses.
- [commits to OpenWrt trunk regarding procd](https://dev.openwrt.org/search?q=procd&noquickjump=1&changeset=on "https://dev.openwrt.org/search?q=procd&noquickjump=1&changeset=on")

## OpenWrt – operating system architecture

Whereas desktop distributions use [glib](https://en.wikipedia.org/wiki/GLib "https://en.wikipedia.org/wiki/GLib")+[dbus](https://en.wikipedia.org/wiki/D-Bus "https://en.wikipedia.org/wiki/D-Bus")+[udev(part of systemd)](https://en.wikipedia.org/wiki/udev "https://en.wikipedia.org/wiki/udev"), OpenWrt uses [libubox](/docs/techref/libubox "docs:techref:libubox")+[ubus](/docs/techref/ubus "docs:techref:ubus")+[procd](/docs/techref/procd "docs:techref:procd"). This provides some pretty awesome functionality without requiring huge libraries with huge dependencies (\*cough* glib).

Desktop Distributions OpenWrt [Android](https://en.wikipedia.org/wiki/Android%20%28operating%20system%29 "https://en.wikipedia.org/wiki/Android (operating system)") [Replicant](https://en.wikipedia.org/wiki/Replicant%20%28operating%20system%29 "https://en.wikipedia.org/wiki/Replicant (operating system)") [mer-based](https://en.wikipedia.org/wiki/Mer%20%28software%20distribution%29 "https://en.wikipedia.org/wiki/Mer (software distribution)") Typical main memory size **128 MiB** to 16 GiB (or more) **32 MiB** to 512 MiB[1)](#fn__1) min **92 MiB** for Android 2.1  
min **340 MiB** for Android 4.0 ? Supported instruction sets almost anything almost anything x86, 86-64, ARM, MIPS32 non-volatile storage space 100 MiB 8 MiB[2)](#fn__2) 150MiB for Android 2.1  
512MiB for Android 4.0 ? [kernel](https://en.wikipedia.org/wiki/Kernel%20%28computing%29 "https://en.wikipedia.org/wiki/Kernel (computing)") **`Linux kernel`** FOSS and binary drivers FOSS drivers: e.g. [802.11](https://en.wikipedia.org/wiki/Comparison%20of%20open-source%20wireless%20drivers "https://en.wikipedia.org/wiki/Comparison of open-source wireless drivers"); [Iaccess](/docs/techref/hardware/internet.access.technologies "docs:techref:hardware:internet.access.technologies") Android binary drivers [C standard library](https://en.wikipedia.org/wiki/C%20standard%20library "https://en.wikipedia.org/wiki/C standard library") [glibc](https://en.wikipedia.org/wiki/GNU%20C%20Library "https://en.wikipedia.org/wiki/GNU C Library") [uClibc](https://en.wikipedia.org/wiki/uClibc "https://en.wikipedia.org/wiki/uClibc"), [musl](https://en.wikipedia.org/wiki/musl "https://en.wikipedia.org/wiki/musl") [bionic](https://en.wikipedia.org/wiki/Bionic%20%28software%29 "https://en.wikipedia.org/wiki/Bionic (software)") glibc + [libhybris](https://en.wikipedia.org/wiki/Hybris%20%28software%29 "https://en.wikipedia.org/wiki/Hybris (software)") eglibc 2.15 [init](https://en.wikipedia.org/wiki/init "https://en.wikipedia.org/wiki/init") [init](https://en.wikipedia.org/wiki/init "https://en.wikipedia.org/wiki/init")  
[Upstart](https://en.wikipedia.org/wiki/Upstart "https://en.wikipedia.org/wiki/Upstart")  
[Initng](https://en.wikipedia.org/wiki/Initng "https://en.wikipedia.org/wiki/Initng") **`systemd`** busybox-initd **`procd`** Android init-fork `systemd` [rsyslog](https://en.wikipedia.org/wiki/rsyslog "https://en.wikipedia.org/wiki/rsyslog") / [syslog-ng](https://en.wikipedia.org/wiki/syslog-ng "https://en.wikipedia.org/wiki/syslog-ng") busybox-klogd, busybox-syslogd [watchdog](https://en.wikipedia.org/wiki/watchdog "https://en.wikipedia.org/wiki/watchdog") busybox-watchdog [udev](https://en.wikipedia.org/wiki/udev "https://en.wikipedia.org/wiki/udev") [hotplug2](/docs/techref/hotplug_legacy "docs:techref:hotplug_legacy") [cron](https://en.wikipedia.org/wiki/cron "https://en.wikipedia.org/wiki/cron") `busybox-crond` [atd](https://en.wikipedia.org/wiki/at%20%28Unix%29 "https://en.wikipedia.org/wiki/at (Unix)") *na* [D-Bus](https://en.wikipedia.org/wiki/D-Bus "https://en.wikipedia.org/wiki/D-Bus") [ubus](/docs/techref/ubus "docs:techref:ubus") Binder ? D-Bus network configuration [NetworkManager](https://en.wikipedia.org/wiki/NetworkManager "https://en.wikipedia.org/wiki/NetworkManager") + GUI `netifd` ConnectivityManager  
(not [ConnMan = ConnectionManager](https://connman.net/ "https://connman.net/")!) ? ConnMan [GLib](https://en.wikipedia.org/wiki/GLib "https://en.wikipedia.org/wiki/GLib")  
(GObject, Glib, GModule, GThread, GIO) [libubox](/docs/techref/libubox "docs:techref:libubox") ? ? Qt-based? [PulseAudio](https://en.wikipedia.org/wiki/PulseAudio "https://en.wikipedia.org/wiki/PulseAudio") [pulseaudio](/docs/guide-user/hardware/audio/pulseaudio "docs:guide-user:hardware:audio:pulseaudio") (optional) PulseAudio PulseAudio PulseAudio [Package management system](https://en.wikipedia.org/wiki/Package%20management%20system "https://en.wikipedia.org/wiki/Package management system") [dpkg](https://en.wikipedia.org/wiki/dpkg "https://en.wikipedia.org/wiki/dpkg")/[APT](https://en.wikipedia.org/wiki/Advanced%20Packaging%20Tool "https://en.wikipedia.org/wiki/Advanced Packaging Tool")  
[RPM](https://en.wikipedia.org/wiki/RPM%20Package%20Manager "https://en.wikipedia.org/wiki/RPM Package Manager")/[yum](https://en.wikipedia.org/wiki/Yellowdog%20Updater,%20Modified "https://en.wikipedia.org/wiki/Yellowdog Updater, Modified")  
[portage](https://en.wikipedia.org/wiki/Portage%20%28software%29 "https://en.wikipedia.org/wiki/Portage (software)")  
[pacman](https://en.wikipedia.org/wiki/pacman%20%28package%20manager%29 "https://en.wikipedia.org/wiki/pacman (package manager)")  
... `opkg` [apk](https://en.wikipedia.org/wiki/APK%20%28file%20format%29 "https://en.wikipedia.org/wiki/APK (file format)") ? [RPM](https://en.wikipedia.org/wiki/RPM%20Package%20Manager "https://en.wikipedia.org/wiki/RPM Package Manager")

#### What's the difference between ubus vs dbus?

`dbus` is bloated, its C API is very annoying to use and requires writing large amounts of boilerplate code. In fact, the pure C API is so annoying that its own API documentation states: “If you use this low-level API directly, you're signing up for some pain.”

`ubus` is tiny and has the advantage of being easy to use from regular C code, as well as automatically making all exported API functionality also available to shell scripts with no extra effort.

“Of course, NetworkManager should be renamed to ***`“unetwork”`*** , dbus to ***`“ubus”`*** , PulseAudio to ***`“usound”`*** , and X.Org-Server/Wayland-Compositor to ***`“udisplay”`*** ; and then indescribable happiness would come down to all people of this world.” – [Lennart Poettering](http://lists.freedesktop.org/archives/dbus/2010-April/012545.html "http://lists.freedesktop.org/archives/dbus/2010-April/012545.html")

* * *

- →[OpenWrt Buildroot – About](/docs/guide-developer/toolchain/start "docs:guide-developer:toolchain:start")
- → [OpenWrt Buildroot – Installation](/docs/guide-developer/toolchain/install-buildsystem "docs:guide-developer:toolchain:install-buildsystem")
- →[OpenWrt Buildroot – Usage](/docs/guide-developer/toolchain/start "docs:guide-developer:toolchain:start")
- →[OpenWrt Buildroot – Patches](/docs/guide-developer/toolchain/use-patches-with-buildsystem "docs:guide-developer:toolchain:use-patches-with-buildsystem")

* * *

- →[file\_system](/docs/techref/file_system "docs:techref:file_system") / [flash.layout](/docs/techref/flash.layout "docs:techref:flash.layout")
- →[internal.layout](/docs/techref/internal.layout "docs:techref:internal.layout")
- →[preinit\_mount](/docs/techref/preinit_mount "docs:techref:preinit_mount")/[process.boot](/docs/techref/process.boot "docs:techref:process.boot")/[requirements.boot.process](/docs/techref/requirements.boot.process "docs:techref:requirements.boot.process")

<!--THE END-->

- [PulseAudio does not depend on GLib](https://www.freedesktop.org/wiki/Software/PulseAudio/FAQ/#index2h3 "https://www.freedesktop.org/wiki/Software/PulseAudio/FAQ/#index2h3") and does not seem to depends on D-Bus neither: [LFS](http://www.linuxfromscratch.org/blfs/view/svn/multimedia/pulseaudio.html "http://www.linuxfromscratch.org/blfs/view/svn/multimedia/pulseaudio.html")
- [FOSDEM2013: Can Linux network configuration suck less?](https://archive.fosdem.org/2013/schedule/event/dist_network/ "https://archive.fosdem.org/2013/schedule/event/dist_network/")

### History

Package history is available at:

- current history: [https://dev.openwrt.org/log/trunk/package/system/procd](https://dev.openwrt.org/log/trunk/package/system/procd "https://dev.openwrt.org/log/trunk/package/system/procd")
- old history pre r37007 [https://dev.openwrt.org/log/trunk/package/procd/Makefile?rev=36995](https://dev.openwrt.org/log/trunk/package/procd/Makefile?rev=36995 "https://dev.openwrt.org/log/trunk/package/procd/Makefile?rev=36995")

<!--THE END-->

- [r34865: procd: add initial implementation](https://dev.openwrt.org/changeset/34865 "https://dev.openwrt.org/changeset/34865")
- [r34866: base-files: add basic procd integration, let procd start (and restart) ubus instead of having an ubus init script](https://dev.openwrt.org/changeset/34866 "https://dev.openwrt.org/changeset/34866")
- [r34867: dropbear: convert init script to procd](https://dev.openwrt.org/changeset/34867 "https://dev.openwrt.org/changeset/34867")
- [r36003: base-files: make basefiles aware of procd](https://dev.openwrt.org/changeset/36003 "https://dev.openwrt.org/changeset/36003")
- [r36005: busybox: make init and logread depend on !PROCD\_INIT](https://dev.openwrt.org/changeset/36005 "https://dev.openwrt.org/changeset/36005")
- [r36446: hotplug2: make it depend on !PROCD\_INIT](https://dev.openwrt.org/changeset/36446 "https://dev.openwrt.org/changeset/36446")
- [r36896: procd: make the preinit rules wildcard all buttons for failsafe](https://dev.openwrt.org/changeset/36896 "https://dev.openwrt.org/changeset/36896")
- [r36987: hotplug2: procd does the hotplugging now](https://dev.openwrt.org/changeset/36987 "https://dev.openwrt.org/changeset/36987")
- [r36998: base-files: procd is now the init process](https://dev.openwrt.org/changeset/36998 "https://dev.openwrt.org/changeset/36998")
- [r36999: base-files: diag does not need to insmod any drivers, procd already did it for us](https://dev.openwrt.org/changeset/36999 "https://dev.openwrt.org/changeset/36999")
- [r37000: base-files: input/button drivers get loaded before preinit by procd](https://dev.openwrt.org/changeset/37000 "https://dev.openwrt.org/changeset/37000")
- [r37002: base-files: /etc/init.d/rcS is no longer needed, procd handles this for us now](https://dev.openwrt.org/changeset/37002 "https://dev.openwrt.org/changeset/37002")
- [r37039: busybox: disable syslogd/klogd by default, procd replaces them](https://dev.openwrt.org/changeset/37039 "https://dev.openwrt.org/changeset/37039")
- [r37106: busybox: disable the watchdog utility by default (procd handles watchdog devices)](https://dev.openwrt.org/changeset/37106 "https://dev.openwrt.org/changeset/37106")
- [r37242, 37243, 37244: busybox: convert telnet, crond and sysntpd init scripts to procd](https://dev.openwrt.org/changeset/37242 "https://dev.openwrt.org/changeset/37242")
- [r37245: dropbear: register a config.change trigger: procd\_add\_config\_trigger "dropbear" "/etc/init.d/dropbear" "restart"](https://dev.openwrt.org/changeset/37245 "https://dev.openwrt.org/changeset/37245")
- [r37429: procd: add proto and trigger support to the /etc/init.d/log](https://dev.openwrt.org/changeset/37249 "https://dev.openwrt.org/changeset/37249")
- [r37336: procd: make old button hotplug rules work until all packages are migrated](https://dev.openwrt.org/changeset/37336 "https://dev.openwrt.org/changeset/37336")

[1)](#fnt__1)

yes, *heavily* stripped OpenWrt can run on 16 or even 8MiB

[2)](#fnt__2)

yes, 4MiB and 2MiB possible
