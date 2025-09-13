# NZBGet

[NZBGet](https://nzbget.net/ "https://nzbget.net/") is a Usenet downloader written in C++ and designed with performance in mind to achieve maximum download speed by using very little system resources.

It can run successfully under OpenWRT on many embedded devices - an installation requires ~11MB storage, and little CPU or RAM. However, NZBGet isn't in the OpenWRT package repository, so it must be installed manually.

## Prerequisites

- [usb-drives](/docs/guide-user/storage/usb-drives "docs:guide-user:storage:usb-drives") obtain support for USB storage and mount local filesystem

## Stage the NZBGet Installer onto OpenWRT Device

Obtain the URL of the latest stable Linux version of NZBGet from the [NZBGet Downloads page](https://nzbget.net/download "https://nzbget.net/download").

### Option 1: Download Directly to OpenWRT Device

It's important to download the NZBGet installer (currently ~30MB) to external storage.

```
opkg update
opkg install ca-bundle ca-certificates libustream-openssl
FILE="/mnt/sda1/nzbget-21.0-bin-linux.run"  # Substitute appropriate path
URL="https://github.com/nzbget/nzbget/releases/download/v21.0/nzbget-21.0-bin-linux.run"  # Substitute actual URL
wget -O $FILE $URL
```

### Option 2: Download to PC; upload to OpenWRT Device

If you have already configured your OpenWRT device as an (S)FTP server, NFS server, etc., you can skip installing the SSL dependencies needed by wget by downloading the NZBGet installer to a PC, and staging it from there onto your OpenWRT device. Again, you'll want to upload the NZBGet install to the OpenWRT device's external storage, because it may be too large for internal flash storage.

## Install NZBGet

If your device has sufficient internal flash storage (currently requiring ~11MB), it's most natural to install NZBGet under `/usr/share`.

```
FILE="/mnt/sda1/nzbget-21.0-bin-linux.run"  # Substitute appropriate path
sh $FILE --destdir /usr/share/nzbget
```

Test the install by executing `/usr/share/nzbget/nzbget -s` on the router, then browsing to &lt;router\_ip&gt;:6789 (default username/pw is “nzbget”/“tegbzn6789”).

## Create NZBGet Init Script

Create `/usr/share/nzbget/init` with the following contents:

```
#!/bin/sh /etc/rc.common
START=99
STOP=99
USE_PROCD=1
PROG=/usr/share/nzbget/nzbget
 
start_service() {
    procd_open_instance
    procd_set_param command $PROG -s
    # if process dies sooner than respawn_threshold, it is considered crashed and after 5 retries the service is stopped
    procd_set_param respawn ${respawn_threshold:-3600} ${respawn_timeout:-5} ${respawn_retry:-5}
    procd_set_param pidfile /var/run/nzbget.pid
    procd_set_param stdout 1  # forward stdout of the command to logd
    procd_set_param stderr 1  # same for stderr
    # procd_set_param user nobody # run service as user nobody
    procd_close_instance
}
```

Symlink this script under `/etc/init.d`, then start/enable the service.

```
ln -s /usr/share/nzbget/init /etc/init.d/nzbget
/etc/init.d/nzbget start
/etc/init.d/nzbget enable
```
