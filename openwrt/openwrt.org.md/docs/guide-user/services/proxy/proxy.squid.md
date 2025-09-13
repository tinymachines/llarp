# Squid

Squid is an enterprise-class caching web proxy.

## 1. Squid transparent mode on devices with sufficient space to install Squid

### Prerequisites

#### External storage

You will need additional storage for Squid cache.

### Installation

Install Squid on LEDE/OpenWrt device (can be extrooted for more installation space):

```
opkg install squid
```

Optional packages:

- luci-app-squid - Luci application for managing Squid settings
- squid-mod-cachemgr - Page for Squid statistics etc

```
opkg install luci-app-squid squid-mod-cachemgr
```

### Storage configuration

You need to update 'fstab' configuration to mount your caching storage device partition to “/tmp/squid”.

Open 'fstab' configuration in Luci or in terminal:

```
vi /etc/config/fstab
```

In this example partition '/dev/sda1' with 'ext4' filesystem, is mounted to '/tmp/squid', and filesystem check (fsck) is enabled:

```
config mount
        option enabled '1'
        option device '/dev/sda1'
        option fstype 'ext4'
        option enabled_fsck '1'
        option target '/tmp/squid'
```

Save your configuration and try out if mounting works. Manually mount your configuration file for test:

```
mount -a
```

And check if you see your device in list:

```
df -h
```

#### Set up forwarding

Add http (port 80) traffic forwarding to Squid (so called transparent mode). Add firewall section:

```
vi /etc/config/firewall
```

```
config redirect
        option name 'Allow-transparent-Squid'
        option enabled '1'
        option proto 'tcp'
        option target 'DNAT'
        option src 'lan'
        option src_ip '!192.168.1.1'
       	option src_dip '!192.168.1.1'
        option src_dport '80'
        option dest 'lan'
        option dest_ip '192.168.1.1'
        option dest_port '3128'
```

Reload and restart firewall service:

```
/etc/init.d/firewall reload
/etc/init.d/firewall restart
```

#### Squid configuration

Edit Squid configuration:

```
vi /etc/squid/squid.conf
```

or use **luci-app-squid** and go to Services→Squid→Advanced Settings.

```
acl localnet src 10.0.0.0/8
acl localnet src 172.16.0.0/12
acl localnet src 192.168.0.0/16
acl localnet src fc00::/7
acl localnet src fe80::/10

acl ssl_ports port 443

acl safe_ports port 80
acl safe_ports port 21
acl safe_ports port 443
acl safe_ports port 70
acl safe_ports port 210
acl safe_ports port 1025-65535
acl safe_ports port 280
acl safe_ports port 488
acl safe_ports port 591
acl safe_ports port 777
acl connect method connect

http_access deny !safe_ports
http_access deny connect !ssl_ports

http_access allow localhost manager
http_access deny manager

http_access deny to_localhost

http_access allow localnet
http_access allow localhost

http_access deny all

refresh_pattern ^ftp: 1440 20% 10080
refresh_pattern ^gopher: 1440 0% 1440
refresh_pattern -i (/cgi-bin/|\?) 0 0% 0
refresh_pattern . 0 20% 4320

access_log none
cache_log /dev/null
cache_store_log stdio:/dev/null
logfile_rotate 0

logfile_daemon /dev/null

http_port 3128 intercept

# cache_dir aufs Directory-Name Mbytes L1 L2 [options]
cache_dir aufs /tmp/squid/cache 900 16 512

# If you have 64 MB device RAM you can use 16 MB cache_mem, default is 8 MB
cache_mem 8 MB             
maximum_object_size_in_memory 100 KB
maximum_object_size 32 MB
```

In this example, 900 means that Squid is allowed to use 900 MB for **cache**:

```
cache_dir aufs /tmp/squid/cache 900 16 512
```

You can use your device capacity here, but make sure you leave some (5% - 15%) free space on device for logs/folder tree etc.

![:!:](/lib/images/smileys/exclaim.svg) Squid will crash when the disk gets full or unwritable! When this happens your Internet traffic, also access to Luci will stop working. You can fix it by logging in with SSH, disabling cache\_dir:

```
#cache_dir aufs /tmp/squid/cache 900 16 512
```

or by fixing settings. Configuration reload is needed after all changes or disabling.

#### Reload configuration

Squid reconfiguration and cache directory tree rebuild :

```
squid -k reconfigure    (use -f "cfgfile" if congiguration file has moved)    
squid -z                (rebuild cache directory tree)
squid                   (start squid to make sure it will be running)
```

#### Keep settings

If you have successfully set up your Squid cache, you may want to preserve the settings while (future) sysupgrade. Add squid configuration **/etc/squid/squid.conf** into sysupgrade keep file:

```
vi /etc/sysupgrade.conf
```

or use **luci** and go to System→Backup/Flash Firmware→Configuration.

```
## This file contains files and directories that should
## be preserved during an upgrade.

# /etc/example.conf
# /etc/openvpn/

/etc/squid/squid.conf
```

### Execution

Squid should be working now. If you want to be sure it's really caching, you can control cache folder used size:

```
df -h
```

That should be something like in this example:

```
Filesystem                Size      Used Available Use% Mounted on
        ..                  ..        ..        ..   ..         ..
/dev/sda1               1000M       600M      400M  60% /tmp/squid
```

Or use squid-mod-cachemgr, accessing its page:

```
http://192.168.1.1/cgi-bin/cachemgr.cgi
```

## 2. Squid on devices without enough flash space

![:!:](/lib/images/smileys/exclaim.svg) This howto is a work in progress, and I expect that it will not work for everyone unless others (i.e. you) contribute to it's development.

### Prerequisites

#### External storage

You *will* need additional storage for Squid, definitely for it's cache, and most likely for the executable too.

This howto assumes that an ext4 filesystem is mounted as **/opt**, with at least 4GB of free storage space. IMHO, this is *much* easier than using [extroot](/docs/guide-user/additional-software/extroot_configuration "docs:guide-user:additional-software:extroot_configuration").

```
root@db-router:~# df -h
Filesystem                Size      Used Available Use% Mounted on
/dev/root                10.8M     10.8M         0 100% /rom
tmpfs                    61.4M    980.0K     60.5M   2% /tmp
/dev/mtdblock3            3.8M    868.0K      2.9M  23% /overlay
overlayfs:/overlay        3.8M    868.0K      2.9M  23% /
tmpfs                   512.0K         0    512.0K   0% /dev
/dev/sda5                28.4G     21.0M     26.9G   0% /opt
```

How to do this is covered elsewhere in the wiki (i.e. [Storage](/docs/guide-user/storage/start "docs:guide-user:storage:start"), and [USB Storage](/docs/guide-user/storage/usb-drives "docs:guide-user:storage:usb-drives")), and the forums.

### Installation

Squid is a big package, and for many systems it will not fit on the root file system (i.e. under **/usr**). Since the web cache will be on external storage, we may as well put Squid on it too.

#### Before installing

For maximum compatibility, install Squid's dependencies in the regular way so that Squid and all other apps will find them in the expected location. Depending upon which packages you have already installed, these dependencies may already be on the rootfs.

To do this, execute the following command:

```
root@db-router:~# opkg install $(opkg depends -A squid* | grep -v depends | grep -v squid | sort -u)
Package libc (1.1.11-1) installed in root is up to date.
Package libopenssl (1.0.2d-1) installed in root is up to date.
Package libpthread (1.1.11-1) installed in root is up to date.
Package librt (1.1.11-1) installed in root is up to date.
Package libltdl (2.4-1) installed in root is up to date.
Package libstdcpp (4.8-linaro-1) installed in root is up to date.
```

You will then need to ensure packages can be installed onto the external storage:

```
### Allow packages to be installed to (external storage mounted as) /opt...
  if ! grep -q usb /etc/opkg.conf; then
    cat << 'EOF' >> /etc/opkg.conf
dest usb /opt
EOF
  fi;
```

![:!:](/lib/images/smileys/exclaim.svg) I suggest you do not change the **$PATH** in **/etc/profile** (and certainly *not* **$LD\_LIBRARY\_PATH**).

#### Installing

You can install the Squid packages via the following command:

```
### Install the Squid package (and optionally, the cache manager package)...
  opkg -d usb install squid
# opkg -d usb install squid-mod-cachemgr
 
# debug tip: use this to see which libraries Squid uses (with their location)...
# ldd /opt/usr/sbin/squid
```

#### After installing

Because the Squid package is installed on external storage (e.g. the executable is in **/opt/usr/sbin** instead of **/usr/sbin**), we need to do a few tricks for it to work.

There are several ways to achieve this (such as adding **/opt/usr/sbin** to **$PATH**), but I recommend:

```
### Create a link to the startup script and configuration files...
  ln -s /opt/etc/init.d/squid      /etc/init.d/squid        ## this is absolutely required (i.e. dont cp)
  ln -s /opt/etc/squid             /etc/                    ## there may be better ways of achieving this
  ln -s /opt/etc/config/squid      /etc/config/squid        ## if not, it will complain with: validation failed
 
# alternatively, this appears cleaner than a ln -s (but use squid -f if executing from cmd line)...
# uci set squid.squid.config_file='/opt/etc/squid/squid.conf'
# uci commit
 
 
### Make the necessary changes to the startup script if not symlinking /usr/sbin/squid (required, redoable)...
  sed -i '/^PROG=/   s:=/usr/:=/opt/usr/:' /etc/init.d/squid    ## for: squid
  sed -i '/ssl_crtd/ s: /usr/: /opt/usr/:' /etc/init.d/squid    ## for: ssl_crtd
 
# alternatively, create symlinks where the startup script expects them to be (is a bit messy?)...
# ln -s /opt/usr/sbin/squid          /usr/sbin/squid
# ln -s /opt/usr/lib/squid/ssl_crtd  /usr/lib/squid/ssl_crtd
 
 
### Make the necessary fixes to the configuration file...
if ! grep -q zxdavb /etc/squid/squid.conf; then
  cat << 'EOF' >> /etc/squid/squid.conf
 
# Changes necessary because squid is installed upon /opt (zxdavb)...
  error_directory /opt/usr/share/squid/errors/templates/       # WARNING: this will disable multi-language support on error pages
  icon_directory  /opt/usr/share/squid/icons                   # usually: /usr/share/squid/icons
EOF
fi;
```

Squid should now run (well, not yet. Keep reading ![:-)](/lib/images/smileys/smile.svg)):

```
/etc/init.d/squid start
ps -w | grep squid
netstat -nltp 
logread | grep squid
/etc/init.d/squid stop
```

To enable Squid to start automatically at system startup, execute **/etc/init.d/squid enable**.

### Configuration

For reference, OpenWrt's default Squid configuration can always be found on GitHub, including the [init script](https://github.com/openwrt/packages/blob/master/net/squid/files/squid.init "https://github.com/openwrt/packages/blob/master/net/squid/files/squid.init"), the [uci configuration](https://github.com/openwrt/packages/blob/master/net/squid/files/squid.config "https://github.com/openwrt/packages/blob/master/net/squid/files/squid.config"), and [squid.conf](https://github.com/openwrt/packages/blob/master/net/squid/files/squid.conf "https://github.com/openwrt/packages/blob/master/net/squid/files/squid.conf"). ![:!:](/lib/images/smileys/exclaim.svg) Squid will *not run* from external storage unless some changes are made to these files (some of these changes have been made in earlier sections).

#### Creating the cache directory

Squid will fail to start unless it can access this directory, that is: it must exist, have the correct permission and the correct owner/group (see below).

```
### Create the cache directory (this is all that is required for the default user:group)...
  mkdir -p          /opt/var/cache/squid
  chmod 0777        /opt/var/cache/squid
 
 
### Make the necessary changes to the configuration file...
if ! grep -q cache_dir /etc/squid/squid.conf; then
  cat << 'EOF' >> /etc/squid/squid.conf
 
# cache_dir: change it if you want. 2048 meams 2GB cache size.
  cache_dir ufs /opt/var/cache/squid 2048 16 256
EOF
fi;
 
 
### Create swap directories under the cache directory and then exit...
  /opt/usr/sbin/squid -z
 
# debug tip: use this to see if the swap directories are being populated during caching...
# du -m /opt/var/cache/squid/ | sort -nr | head -n17 | tail -n16
```

### Execution

You have to **/etc/init.d/squid enable**, and **/etc/init.d/squid start**, and it should be good to go!

#### Starting Squid from the command line

This may be useful for debugging configurations, etc.

You might not get the Squid executable to work from the command line (e.g. **squid -d2**) without (temporarily) adding the following to **/etc/squid/squid.conf**:

```
http_port 3128
coredump_dir /tmp/squid
visible_hostname OpenWrt
pinger_enable off
```

A better option may be to start/stop Squid, and then use the generated configuration:

```
/etc/init.d/squid start
/etc/init.d/squid stop
squid -f /tmp/squid/squid.conf -d2 ...
```

## Maintenance

### Before a sysupgrade

Because Squid (and it's config file) is on external (i.e. permanent) storage, I suggest you **do not** do something similar to the following:

```
# echo '/etc/squid/' > /lib/upgrade/keep.d/squid                   ## Keep config across sysupgrades
```

However, if you are building your own images, you may want to do something with **./files/etc/uci-defaults/squid** (see the next bit).

### After a sysupgrade

After a **sysupgrade**, the following may need doing before Squid will run (NB: this assumes you're using **/opt**):

```
# the following needs redoing after a sysupgrade
[ -h /etc/squid ]                || rm -rf /etc/squid                             > /dev/null 2>&1 ## if not a symlink, delete the dir 
[ -e /etc/squid ]                || ln -s /opt/etc/squid /etc/                                     ## if not exists, create the symlink
 
[ -h /etc/init.d/squid ]         || rm    /etc/init.d/squid                       > /dev/null 2>&1 ## if not a symlink, delete the file 
[ -e /etc/init.d/squid ]         || ln -s /opt/etc/init.d/squid /etc/init.d/squid                  ## if not exists, create the symlink
 
[ -e /usr/sbin/squid ]           || ln -s /opt/usr/sbin/squid /usr/sbin/squid                      ## if not a symlink, delete the file 
[ -e /www/cgi-bin/cachemgr.cgi ] || ln -s /opt/www/cgi-bin/cachemgr.cgi /www/cgi-bin/cachemgr.cgi  ## if not exists, create the symlink
 
# now, re-enable Squid (it will restart later)...
/etc/init.d/squid enable
```

## Troubleshooting

### Configuring logging

Squid sends log entries to the system log, and has a wealth of logging options that are disabled by OpenWrt's default squid.conf file.

## Tweaks and Tips

### Using the cache manager (cachemgr.cgi)

The following requires that **uhttpd** is installed and running (the simplest/safest way to do this is **opkg install luci**).

Do the following:

```
opkg -d usb install squid-mod-cachemgr
echo 127.0.0.1:3128 > /etc/squid/cachemgr.conf
ln -s /opt/www/cgi-bin/cachemgr.cgi  /www/cgi-bin/cachemgr.cgi
```

You can now access it via: [http://&lt;IP address&gt;/cgi-bin/cachemgr.cgi](http://%3CIP%20address%3E/cgi-bin/cachemgr.cgi "http://<IP address>/cgi-bin/cachemgr.cgi").

### Using a specific user:group

This is how to use a user:group other that nobody:nogroup (**FYI only, not recommended**).

First, create the user and group:

```
# Create Squid user & group...
  opkg install shadow --force-overwrite # provides groupadd & useradd utils, but must replace passwd
 
# check for a free UID in the system user range (500-1000)
for UID in $(seq 300 1000); do
    grep -q -e "^[^:]*:[^:]:$UID:" /etc/passwd || break
done
[ $UID -eq 1000 ] && { echo "ERROR: Could not find a suitable UID"; exit 1; }
 
# check for a free GID in the system group range (500-1000)
for GID in $(seq 300 1000); do
    grep -q -e "^[^:]*:[^:]:$GID:" /etc/group || break
done
[ $GID -eq 1000 ] && { echo "ERROR: Could not find a suitable GID"; exit 1; }
 
# add new group entry, then a new user entry
  id -g squid > /dev/nul 2>&1 || groupadd squid --gid $GID
  id    squid > /dev/nul 2>&1 || useradd  squid --uid $UID --gid $GID
```

Then you need to configure external storage (permissions, and owner:group):

```
### create cache directory (may already exist)
  mkdir -p          /opt/var/cache/squid
  chmod 0755        /opt/var/cache/squid
  chown squid:squid /opt/var/cache/squid  # only if the squid user:group exists
```

The you need to configure squid to use the new user:group:

```
### Make the necessary changes to the configuration file (redoable)...
if ! grep -q cache_effective_user /etc/squid/squid.conf; then
  cat << 'EOF' >> /etc/squid/squid.conf
 
# Changes necessary because squid using it's own user:group...
  cache_effective_user  squid
  cache_effective_group squid
EOF
fi;
```
