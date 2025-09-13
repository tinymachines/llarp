# AFP Netatalk share configuration (Apple Time Machine)

Netatalk is an OpenSource software package, that can be used to turn a \*NIX machine into an extremely high-performance and reliable file server for Macintosh computers. Using Netatalk's AFP 3.3 compliant file-server leads to significantly higher transmission speeds compared with Macs accessing a server via SaMBa/NFS while providing clients with the best possible user experience (full support for Macintosh metadata, flawlessly supporting mixed environments of classic Mac OS and OS X clients)

This guide will walk you though the steps of installing the required packages and settings up linux users on the LEDE device so your Mac(s) can securely connect over the network to your Time Machine server.

In order for this guide to work you will need to meet the following prerequisites:

- [Setup storage device with Ext4 filesystem](/docs/guide-user/storage/usb-drives "docs:guide-user:storage:usb-drives")
- [Configuration Fstab for automatic storage mount](/docs/guide-user/storage/fstab "docs:guide-user:storage:fstab")

### Package Installation

```
opkg update && opkg install avahi-utils netatalk
```

### Optional Package Installation

These packages are optional although recommend. nano will make editing text files super easy and the shadow packages make user and group managment a breeze, otherwise you'll have to manually edit user, group and password files by hand. The downside these packages will use precious space on your root partition. If your working with limited space consider using [extroot](/docs/guide-user/additional-software/extroot_configuration "docs:guide-user:additional-software:extroot_configuration").

```
opkg update && opkg install nano shadow-groupadd shadow-groupmod shadow-useradd shadow-usermod
```

### Available Netatalk Features

Many of the Netatalk goodies such as Spotlight search, Zeroconfig, ACL and LDAP support have been disabled. That was probably a wise decision to save space and provide a broader range of hardware support. The good news Time Machine support is available. With a simple command `afpd -V` we can check what features have been compiled into Netatalk.

```
 afpd 3.1.10 - Apple Filing Protocol (AFP) daemon of Netatalk
  
This program is free software; you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation; either version 2 of the License, or (at your option) any later
version. Please see the file COPYING for further information and details.
  
afpd has been compiled with support for these features:

        AFP versions:	2.2 3.0 3.1 3.2 3.3 3.4 
       CNID backends:	dbd last tdb 
    Zeroconf support:	No
TCP wrappers support:	No
       Quota support:	No
 Admin group support:	Yes
  Valid shell checks:	No
    cracklib support:	No
          EA support:	ad | sys
         ACL support:	No
        LDAP support:	No
       D-Bus support:	No
   Spotlight support:	No
       DTrace probes:	No

            afp.conf:	/etc/afp.conf
         extmap.conf:	/etc/extmap.conf
     state directory:	/var/netatalk/
  afp_signature.conf:	/var/netatalk/afp_signature.conf
    afp_voluuid.conf:	/var/netatalk/afp_voluuid.conf
     UAM search path:	/usr/lib/uams//
Server messages path:	/var/netatalk/msg/
```

### Basic File Share Configuration (Time Machine Server)

The afp.conf file contains all AFP specific configurations and AFP volume definitions. Let's edit ours with `nano /etc/afp.conf` and setup our Time Machine Server; we'll be using the nano text editor in this tutorial. Netatalk has a lot of great features not covered in this *guide*. Make sure to checkout the documentation for more Time Machine options and other possible AFP uses. [http://netatalk.sourceforge.net/3.0/htmldocs/afp.conf.5.html](http://netatalk.sourceforge.net/3.0/htmldocs/afp.conf.5.html "http://netatalk.sourceforge.net/3.0/htmldocs/afp.conf.5.html")

log file = /var/log/afpd.log For initial configuration, it's good to check the log file.

afp interfaces = br-lan In case you have multiple interfaces. Select the one, which you want to use for listening.

vol size limit = size in MiB (V) Useful for Time Machine: limits the reported volume size, thus preventing Time Machine from using the whole real disk space for backup. Example: “vol size limit = 1000” would limit the reported disk space to 1 GB. IMPORTANT: This is an approximated calculation taking into account the contents of Time Machine sparsebundle images. Therefor you MUST NOT use this volume to store other content when using this option, because it would NOT be accounted. The calculation works by reading the band size from the Info.plist XML file of the sparsebundle, reading the bands/ directory counting the number of band files, and then multiplying one with the other.

```
;
; Netatalk 3.x configuration file
; 

[Global]
; Global server settings
log file = /var/log/afpd.log
afp interfaces = br-lan

[Backups]
path = /mnt/sdb1/Backups
time machine = yes
vol size limit = 250000 
valid users = @users
```

Don't forget to restart the daemon with `/etc/init.d/afpd restart`.

### Avahi-daemon Configuration

The default avahi-daemon configuration `/etc/avahi/avahi-daemon.conf` works perfect with stable LEDE 17.01.0+ and no chages are required.

```
[server]
#host-name=LEDE
#domain-name=local
use-ipv4=yes
use-ipv6=yes
check-response-ttl=no
use-iff-running=no

[publish]
publish-addresses=yes
publish-hinfo=yes
publish-workstation=no
publish-domain=yes
#publish-dns-servers=192.168.1.1
#publish-resolv-conf-dns-servers=yes

[reflector]
enable-reflector=no
reflect-ipv=no

[rlimits]
#rlimit-as=
rlimit-core=0
rlimit-data=4194304
rlimit-fsize=0
rlimit-nofile=30
rlimit-stack=4194304
rlimit-nproc=3
```

By default Avahi daemon requires running dbus. Start the dbus with command `/etc/init.d/dbus start` in case it's not running. Or disable it with `enable-dbus=no`. Start the Avahi daemon with command `/etc/init.d/avahi-daemon start`.

![:!:](/lib/images/smileys/exclaim.svg) Learn about other configuration options here [https://github.com/lathiat/avahi](https://github.com/lathiat/avahi "https://github.com/lathiat/avahi")

### Zeroconf Advertising

The LEDE implementation of Netatalk was not compiled with Zeroconf support; so we must advertise the required afpovertcp, device-info, and adisk text-record properties manually. We previously installed avahi-daemon (via avahi-utils) for exactly this purpose. Let's create a service file `nano /etc/avahi/services/afp.service` using the template below.

```
<?xml version="1.0" standalone='no'?><!--*-nxml-*-->
<!DOCTYPE service-group SYSTEM "avahi-service.dtd">
<service-group>
 <name replace-wildcards="yes">%h</name>
  <service>
   <type>_afpovertcp._tcp</type>
   <port>548</port>
  </service>
  <service>
   <type>_device-info._tcp</type>
   <port>0</port>
   <txt-record>model=TimeCapsule</txt-record>
  </service>
  <service>
   <type>_adisk._tcp</type>
   <port>9</port>
   <txt-record>sys=waMa=0,adVF=0x100,adVU=00000000-AAAA-BBBB-CCCC-111111111111</txt-record>
   <txt-record>dk0=adVN=Backups,adVF=0x81</txt-record>
  </service>
</service-group>
```

![:!:](/lib/images/smileys/exclaim.svg) `model=TimeCapsule` this determines the hardware icon that appear within macOS Finder. Some available options are Xserve, PowerBook, PowerMac, Macmini, iMac, MacBook, MacBookPro, MacBookAir, MacPro, MacPro6,1, TimeCapsule, AppleTV1,1 and AirPort.

![:!:](/lib/images/smileys/exclaim.svg) `adVU=00000000-AAAA-BBBB-CCCC-111111111111` must be changed to a uniquely generated UUID. You can create a UUID in LEDE by writing `cat /proc/sys/kernel/random/uuid` (each time generating and displaying a new UUID).

![:!:](/lib/images/smileys/exclaim.svg) `adVN=Backups` should match the virtual volume name of your `timemachine = YES` share from `/etc/afp.conf`. If you used my example settings above; leave this set to `Backups`. Most online guides use *“TimeMachine”* however *“Backups”* is more traditional since it's the default when using macOS Server or Time Capsule; although it realy dosen't matter what you call it, as long as they both match.

Don't forget to restart the daemons after changing the configuration.

**Some helpful links**

- [https://guidgenerator.com](https://guidgenerator.com "https://guidgenerator.com")
- [https://www.freeformatter.com/xml-formatter.html](https://www.freeformatter.com/xml-formatter.html "https://www.freeformatter.com/xml-formatter.html")
- [http://netatalk.sourceforge.net/wiki/index.php/Bonjour\_record\_adisk\_adVF\_values](http://netatalk.sourceforge.net/wiki/index.php/Bonjour_record_adisk_adVF_values "http://netatalk.sourceforge.net/wiki/index.php/Bonjour_record_adisk_adVF_values")

### User and Group Management

In this section we'll create two (2) new users on the LEDE system for file sharing purposes. Create as many or as little as you like, the principles are the same. We'll also accomplish the following:

- create home folders for the new user(s)
- create a group with the same name as the new user(s)
- add new user(s) to a supplementary group named “users”

1\. Create a place for the users home folder with `mkdir /home/`. The default location for most Linux distros.

2\. Add the new user(s). In my example users anne &amp; brian will be created. They will receive a home folder `/home/username` and become members of the group `users` and `username`.

```
useradd --create-home --groups users --user-group anne
useradd --create-home --groups users --user-group brian
```

3\. Add passwords for the newly created user(s).

```
passwd anne
passwd brian
```

4\. Change the permissions of the Backups directory. You will have to improvise and use your systems own mount and or backup location.

```
cd /mnt/sdb1/
mkdir Backups
chmod 775 Backups/
chgrp users Backups/
```

5\. Verify the permission changes with `ls -alF`.

```
root@LEDE:/mnt/sdb1# ls -alF
drwxr-xr-x    5 root     root          4096 Apr 25 18:48 ./
drwxr-xr-x    1 root     root           224 Apr 25 21:49 ../
drwxrwxr-x    2 root     users         4096 Apr 25 21:01 Backups/
drwxr-xr-x    3 root     root          4096 Apr 25 18:48 Shared/
drwx------    2 root     root         16384 Apr 25 16:35 lost+found/
```

![:!:](/lib/images/smileys/exclaim.svg) The `users` group is very important because the `valid users = @users` option in the Netatalk configuration. All members in this group have access to Time Machine services. Lets check what members makeup the `users` group with `grep users /etc/group`. You should see somthing similar to my results.

```
root@LEDE:~# grep users /etc/group
users:x:100:mrengles,anne,brian
```

### Preserving Configuration on Firmware Upgrade

The default LEDE firmware upgrade procedure might not backup some of our configuration files. That would be a horrible waste of hard work.

Add them to the list of custom backup files at `/lib/upgrade/keep.d/` as follows:

```
echo '/etc/afp.conf ' >> /lib/upgrade/keep.d/afp
echo '/etc/avahi/ ' >> /lib/upgrade/keep.d/afp
echo '/etc/extmap.conf ' >> /lib/upgrade/keep.d/afp
echo '/home/ ' >> /lib/upgrade/keep.d/afp
echo '/var/netatalk/ ' /lib/upgrade/keep.d/afp
```

You can verify the setting by the following command:

```
sysupgrade -l
```

This can also be accomplished via LuCi &gt; System &gt; Backup / Flash Firmware &gt; Configurations &gt; Backup file list and simply append the following:

```
/etc/afp.conf
/etc/avahi/
/etc/extmap.conf
/home/
/var/netatalk/
```

For more information, please check the [Upgrading LEDE from the Command Line](/docs/guide-user/installation/sysupgrade.cli "docs:guide-user:installation:sysupgrade.cli")

### Setup Time Machine on macOS

Settting up Time Machine on the Mac is a very simple process:

- Open System Preferences &gt; Time Machine &gt; Select Backup Disk.
- Select “Backups on LEDE” (encrypted backups will also work).
- Login with your username and password (from earlier in this guide).

Apple can explain how-to use Time Machine much better then myself, so I'll let them. If you completed this *guide* successfully, chances are you wont need help. [https://support.apple.com/en-us/HT201250](https://support.apple.com/en-us/HT201250 "https://support.apple.com/en-us/HT201250")

![:!:](/lib/images/smileys/exclaim.svg) Depending on your storage requirements the initial backup could take several hours.

### Final Thoughts

If you have questions, post them in the OpenWrt Forum so that myself and others can respond. [https://forum.openwrt.org](https://forum.openwrt.org "https://forum.openwrt.org")

Please update this user guide if you have a better way of doing things or notice typos and errors. ![:-)](/lib/images/smileys/smile.svg)
