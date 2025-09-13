# CHROOT

## Preconditions

- External storage [Quick Start for Adding a USB drive](/docs/guide-user/storage/usb-drives-quickstart "docs:guide-user:storage:usb-drives-quickstart")
- create a partition for data files (CHROOT files) and create one swap partition [Using storage devices](/docs/guide-user/storage/usb-drives "docs:guide-user:storage:usb-drives"). A swap partition is most likely needed as the programms you would like to run exceed the RAM of your device.
- Format external storage with a file system [Filesystems](/docs/guide-user/storage/filesystems-and-partitions "docs:guide-user:storage:filesystems-and-partitions")
- Create a mount point using `block-mount`. There is a LUCI webinterface available
- Find out which architecture your SOC/processor has: OpenWRT summary [Instruction Sets](/docs/techref/instructionset/start "docs:techref:instructionset:start")

## Install Debian

- ARM: [https://www.kernel.org/doc/html/latest/arm/index.html](https://www.kernel.org/doc/html/latest/arm/index.html "https://www.kernel.org/doc/html/latest/arm/index.html"). In practice armel will be used for older CPUs (armv4t, armv5, armv6), and armhf for newer CPUs (armv7+VFP). [Debian WIKI](https://wiki.debian.org/ArmHardFloatPort "https://wiki.debian.org/ArmHardFloatPort")
- MIPS: Through the Debian 10 (“buster”) release, Debian currently provides 3 ports, 'mips', 'mipsel', and 'mips64el'. The 'mips' and 'mipsel' ports are respectively big and little endian variants, using the O32 ABI with hardware floating point. They use the MIPS II ISA in Jessie and the MIPS32R2 ISA in Stretch and later. The 'mips64el' port is a 64-bit little endian port using the N64 ABI, hardware floating point and the MIPS64R2 ISA. The 'mips' (32-bit big-endian MIPS CPUs) Debian port was discontinued post Debian 10 (“buster”). Please prepare to migrate your MIPS hardware to mipsel or mips64el, much recent MIPS hardware (such as Octeon CPUs) supports endian switching at runtime and can therefore be supported by the other MIPS ports. [Debian Wiki](https://wiki.debian.org/MIPSPort "https://wiki.debian.org/MIPSPort")

Install package

```
opkg install debootstrap binutils
```

and use it to create the CHROOT environment.  
Below example shows the installation of Debian 10 (Buster) for an ARMv5 (armel) at the mountpoint `/mnt/sda`

```
debootstrap --arch=armel buster /mnt/sda/ http://ftp.de.debian.org/debian
```

You need to connect the `/dev`, `/sys` and `/proc` of your CHROOT environment with the OpenWRT (host system) environment. To do the mount during startup please add to `/etc/rc.local`

```
mount --bind /dev /mnt/sda/dev/
mount --bind /proc /mnt/sda/proc/
mount --bind /sys /mnt/sda/sys/
```

You can login to the CHROOT environment by

```
# This is necessary because the chroot expects /bin/ash to be found
ln -s /bin/bash bin/ash
# Change to CHROOT
chroot /mnt/sda/ /bin/bash
```

I recommend to change the shell promt, as for the moment you will not recognize that your are within the CHROOT environment.

```
echo 'PS1="CHROOT:\w# "' >> ~/.bashrc
```

Next we will install and reconfigure locales.

```
CHROOT:/# apt-get install locales
CHROOT:/# dpkg-reconfigure locales
```

This shall give the minimum steps for a CHROOT environment on top of OpenWRT. use this as a basis to install further services like `ssh`, ...

## Install CUPS (print server)

[p910nd Printer Server](/docs/guide-user/services/print_server/p910nd.server "docs:guide-user:services:print_server:p910nd.server") may be suitable as well. There is another way to use CUPS on OpenWRT [CUPS Print Server](/docs/guide-user/services/print_server/cups.server "docs:guide-user:services:print_server:cups.server"). The user need to compile an OpenWRT image including CUPS.

This approach doesn't require an new compilation but it requires more hardware resources. In CHROOT environment (based on debian) execute

```
CHROOT:/# apt-get update
CHROOT:/# apt-get install avahi-daemon avahi-discover libnss-mdns avahi-utils ghostscript
CHROOT:/# apt-get install cups
```

Within the CHROOT environment you can start CUPS by

```
# Service needed for Avahi mDNS/DNS-SD Daemon: avahi-daemon.
CHROOT:/# /etc/init.d/dbus start
 
# Start service for bonjour /  Avahi mDNS/DNS-SD Daemon: avahi-daemon.
CHROOT:/# /etc/init.d/avahi-daemon start
 
# dbus and avahi needed by CUPS
CHROOT:/# chroot /mnt/sda /bin/bash /etc/init.d/cups start
```

From OpenWRT you can start CUPS by:

```
# Service needed for Avahi mDNS/DNS-SD Daemon: avahi-daemon.
chroot /mnt/sda /bin/bash /etc/init.d/dbus start
 
# Start service for bonjour /  Avahi mDNS/DNS-SD Daemon: avahi-daemon.
chroot /mnt/sda /bin/bash /etc/init.d/avahi-daemon start
 
# dbus and avahi needed by CUPS
chroot /mnt/sda /bin/bash /etc/init.d/cups start
```

See below the Autostart example. Below commands can be added as well.

## Install Resilio Sync

See an example at [Resilio sync on Linksys WRT 1900 ACS and other OpenWRT](https://forum.resilio.com/topic/44082-resilio-sync-on-linksys-wrt1900acs-and-other-openwrt-boxes/ "https://forum.resilio.com/topic/44082-resilio-sync-on-linksys-wrt1900acs-and-other-openwrt-boxes/")

1. Download the appropriate package from [Installing-Sync-package-on-Linux](https://help.resilio.com/hc/en-us/articles/206178924-Installing-Sync-package-on-Linux "https://help.resilio.com/hc/en-us/articles/206178924-Installing-Sync-package-on-Linux")
2. Transfer it to your device using e.g. SCP or WinSCP
   
   ```
    scp /mnt/disk1/armbian-rootfs.tar.bz root@openwrt:/mnt/sda/tmp 
   ```
3. Change to your CHROOT environment `chroot /mnt/sda /bin/bash` and install
   
   ```
   CHROOT:/# sudo dpkg -i <resilio-sync.deb> 
   ```
   
   or
   
   ```
   CHROOT:/# apt-get update
   CHROOT:/# apt-get install resilio-sync
   CHROOT:/# update-rc.d resilio-sync defaults
   ```
   
   in a debian chroot

Resilio Sync is tested on [ZyXEL NSA3xx](/toh/zyxel/nsa310b "toh:zyxel:nsa310b") CPU 1200 MHz / RAM 256MB. With ~100GB of files. Resilio sync occupies ~100MB of RAM and fully loads the CPU in case of indexing. The LUCI web interface lags while Resilio Sync is indexing.

## Autostart

Optionally I recommend to create a script in OpenWRT `/etc/init.d/` to handle the autostart during boot and the stop during shutdown. This script can collect all applications/processes running in the CHROOT environment. Basis taken from `/etc/rc.common`

```
#!/bin/sh /etc/rc.common
#
 
START=99
STOP=10
 
. $IPKG_INSTROOT/lib/functions.sh
. $IPKG_INSTROOT/lib/functions/service.sh
 
start() {
        chroot /mnt/sda /bin/bash /etc/init.d/resilio-sync start
}
 
restart() {
        chroot /mnt/sda /bin/bash /etc/init.d/resilio-sync restart
}
 
stop() {
        chroot /mnt/sda /bin/bash /etc/init.d/resilio-sync stop
}
enable() {
        err=1
        name="$(basename "${initscript}")"
        [ "$START" ] && \
                ln -sf "../init.d/$name" "$IPKG_INSTROOT/etc/rc.d/S${START}${name}"
                err=0
        [ "$STOP" ] && \
                ln -sf "../init.d/$name" "$IPKG_INSTROOT/etc/rc.d/K${STOP}${name}"
                err=0
        return $err
}
disable() {
        name="$(basename "${initscript}")"
        rm -f "$IPKG_INSTROOT"/etc/rc.d/S??$name
        rm -f "$IPKG_INSTROOT"/etc/rc.d/K??$name
}
```
