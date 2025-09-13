# ubox

- [Project's git](http://git.openwrt.org/?p=project%2Fubox.git%3Ba%3Dsummary "http://git.openwrt.org/?p=project/ubox.git;a=summary")

Package `ubox` was added in [r36427](https://dev.openwrt.org/changeset/36427 "https://dev.openwrt.org/changeset/36427") and package `block-mount` was dropped in [r36988](https://dev.openwrt.org/changeset/36988 "https://dev.openwrt.org/changeset/36988"). [r37199](https://dev.openwrt.org/changeset/37199 "https://dev.openwrt.org/changeset/37199") finally adds a UCI-default script for fstab generation.

Cf.

- [https://forum.openwrt.org/viewtopic.php?pid=205552#p205552](https://forum.openwrt.org/viewtopic.php?pid=205552#p205552 "https://forum.openwrt.org/viewtopic.php?pid=205552#p205552")
- [https://lists.openwrt.org/pipermail/openwrt-devel/2013-June/020538.html](https://lists.openwrt.org/pipermail/openwrt-devel/2013-June/020538.html "https://lists.openwrt.org/pipermail/openwrt-devel/2013-June/020538.html")

for some insight.

call

```
block detect
```

to get a sample UCI configuration file. If target is / then it will be used as extroot. block info is also valid to get the uuid.

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

[1)](#fnt__1)

yes, *heavily* stripped OpenWrt can run on 16 or even 8MiB

[2)](#fnt__2)

yes, 4MiB and 2MiB possible
