# Writable NTFS

Below describes adding read/write support for NTFS in Linux which is performed using either the [NTFS-3G](https://en.wikipedia.org/wiki/NTFS-3G "https://en.wikipedia.org/wiki/NTFS-3G") or [NTFS3](https://www.kernel.org/doc/html/v6.1/filesystems/ntfs3.html "https://www.kernel.org/doc/html/v6.1/filesystems/ntfs3.html") driver.

## Installation

### Prerequisites

1. Install [USB support](/docs/guide-user/storage/usb-drives-quickstart "docs:guide-user:storage:usb-drives-quickstart").
2. Connect your storage, the device and its partitions will become available as [Device file](https://en.wikipedia.org/wiki/Device%20file "https://en.wikipedia.org/wiki/Device file")s under `/dev/`, e.g. `/dev/sda1`.

### Driver

NTFS is the primary Windows filesystem and is available in Linux via the `ntfs-3g` driver. With kernel 5.15 onward the new `ntfs3` driver may be used instead which aims to improve performance as an in-kernel driver similar to native Linux filesystems and has become the recommended approach. Both are available in OpenWrt. For `ntfs3`, it is started to support from Kernel 5.x, but recommend use OpenWRT 24.x.x or above since the kernel version 6.6 has ntfs3's new patch in it.

- Install `ntfs-3g` or `kmod-fs-ntfs3`(and `kmod-nls-utf8` for unicode dir/file name)
- Install `fdisk` *optional* to autodetect the filesystem type when using the hotplug script

### Configuration

Once the appropriate driver is intalled this can be mounted or checked in LuCI → System → Mount Points.

Mount a partition to an existing directory. You can create one with `mkdir`, for example `mkdir -p /mnt/sda1`.

To mount a partition to above directory:

For *ntfs-3g*

```
# ntfs-3g /dev/sda1 /mnt/sda1 -o rw,big_writes
```

For *ntfs3*

```
# mount -t ntfs3 -o rw /dev/sda1 /mnt/sda1 (or mount -t ntfs3 -o rw,iocharset=utf8 /dev/sda1 /mnt/sda1)
```

To auto mount a partition at startup (with drive plugged in) edit `/etc/rc.local`:

```
sleep 1

ntfs-3g /dev/sda1 /mnt/sda1 -o rw,lazytime,noatime,big_writes,discard
#mount -t ntfs3 -o rw,nosuid,lazytime,noatime,prealloc,hide_dot_files,windows_names,discard,iocharset=utf8 /dev/sda1 /mnt/sda1

exit 0
```

To unmount:

```
umount /dev/sda1
```

To be able to mount it automatically:

```
ln -s /usr/bin/ntfs-3g /sbin/mount.ntfs
```

For details about mounting options used above see [man page](https://manned.org/ntfs-3g.8 "https://manned.org/ntfs-3g.8").

### Trouble shooting

Especially for *ntfs3*, sometime without clue, show mount error like below

```
# mount -t ntfs3 /dev/sda2 /mnt/folder1
mount: mounting /dev/sda2 on /mnt/folder1 failed: Invalid argument
```

In this case, you need clear dirty page on the target disk which frequently occured by accident shutdown, power off or sudden cable unplug.

To do clearing dirty page, at this moment(5th Jan 2025), you need to install the package 'ntfs-3g-utils' ironically. (Be aware, this clearing task might lost any unfinshed file node which means file system breaking in some part.)

So, what you need to do is

```
# opkg update && opkg install ntfs-3g ntfs-3g-utils
# ntfsfix -d /dev/sda2
# mount -t ntfs3 /dev/sda2 /mnt/folder1
```

Tada! Done. (Hope the 'ntfs3' support self fix logic in it sooner or later)

To automatically do above, you have to put a script in '/etc/init.d' as priority lower than 10 as below.

```
# touch /etc/init.d/ntfs_fix_before_mount
# chmod 755 /etc/init.d/ntfs_fix_before_mount
# nano /etc/init.d/ntfs_fix_before_mount

and paste below into it.
-----------------
#!/bin/sh /etc/rc.common

START=10
STOP=11

boot() {
	return 0
}

start() {
        ntfsfix -d /dev/sda2
        ntfsfix -d /dev/sdb2
        ntfsfix -d /dev/sdc2
}

restart() {
	return 0
}

stop() {
	return 0
}

-----------------------------
# /etc/init.d/ntfs_fix_before_mount enable (<-- IMPORTANT)
```

## Hotplug Mounting

(Be aware, this automatically create and destroy folders that the pluged device name(e.g. /dev/sda1 into /mnt/sda1). If you want to control the mounting point name at your own. The script must be modified or not applicable.)

### With a custom hotplug script

Now that you can get your volume to mount on command, the next step is mounting it when it's plugged in automatically.

To get our drive to mount on plugin, we utilize the [hotplug](/docs/techref/hotplug_legacy "docs:techref:hotplug_legacy") system. Create the following files as `/etc/hotplug.d/block/10-mount`.

```
 
#!/bin/sh
# Copyright (C) 2011 OpenWrt.org
sleep 10 #more apps installed, need more time to load kernel modules!
blkdev=`dirname $DEVPATH`
if [ `basename $blkdev` != "block" ]; then
	device=`basename $DEVPATH`
	case "$ACTION" in
		add)
			mkdir -p /mnt/$device
			# vfat & ntfs-3g check
			if [ `which fdisk` ]; then
				isntfs=`fdisk -l | grep $device | grep NTFS`
				isvfat=`fdisk -l | grep $device | grep FAT`
				isfuse=`lsmod | grep fuse`
				isntfs3g=`which ntfs-3g`
			else
				isntfs=""
				isvfat=""
			fi

			# mount with ntfs-3g if possible, else with default mount
			if [ "$isntfs" -a "$isfuse" -a "$isntfs3g" ]; then
				ntfs-3g -o rw,lazytime,noatime,big_writes /dev/$device /mnt/$device
			elif [ "$isvfat" ]; then
				mount -o iocharset=utf8,discard /dev/$device /mnt/$device
			else
				mount /dev/$device /mnt/$device
			fi
		;;
		remove)
			umount -l /dev/$device
		;;
	esac
fi
```

(The script above comes from [this blog post](http://blog.podspring.com/?p=288 "http://blog.podspring.com/?p=288"))

Now, whenever you plug in an NTFS USB disk, it should automatically mount. (Note that this will be a different path than `/mnt/usb-ntfs`)

### Improved hotplug script

Below is a modified version of the script which should work fine even if you are using [root file system using extroot](/docs/guide-user/additional-software/extroot_configuration "docs:guide-user:additional-software:extroot_configuration"). The original script tries to re-mount all the filesystems, including mtdblock* filesystems at boot which is not what we want.

Code is added to dismiss disks which can be managed by [block\_mount](/docs/techref/block_mount "docs:techref:block_mount"). It should be preferred if it supports the file system you are using but it has limited filesystem type support.

The mount binary seem to figure out what filesystem type it is trying to mount, therefore the code sections for checking this is removed. The script should be able to mount any supported filesystem. (so should it be in ntfs section?)

Some sensible mount options which should be suitable for both solid state and normal drives is also added. In addition, hdparm is called to set drive APM setting so drive can go to standby if not used (the correct setting may be drive dependent). The hd-idle does not seem to work on USB drives properly, but the APM setting is able to make the drive to use its internal logic if supported by the drive.

One other problem with the original script was related to unmounting. Once a drive is disconnected, it disappears from /dev therefore it can not be unmounted by giving the original /dev path (you would just get 'No such file or directory' error). Therefore the script finds where the drive was mounted and uses the mount point for unmounting.

The script was tested on OpenWrt 21.02.1 and requires hdparm to be installed. Modify the script to suit your needs.

```
#!/bin/sh

# Copyright (C) 2021 OpenWrt.org

blkdev=`dirname $DEVPATH`
basename=`basename $blkdev`
device=`basename $DEVPATH`
path=$DEVPATH

if [ $basename != "block" ] && [ -z "${device##sd*}" ]; then
        islabel=`block info /dev/$device | grep -q LABEL ; echo $?`
        if [ $islabel -eq 0 ] ; then
                mntpnt=`block info /dev/$device |sed 's/.*LABEL="\([^"]*\)".*/\1/'`
        else
                mntpnt=$device
        fi

        # Do not tolerate spaces in mount points -- the remove case mountpoint determination fails
        if echo "$mntpnt" |grep -q ' ' ; then
                exit 0
        fi

        case "$ACTION" in
                add)
                        mkdir -p "/mnt/$mntpnt"
                        # Set APM value for automatic spin down
                        /sbin/hdparm -B 127 /dev/$device
                        # Try to be gentle on solid state devices
                        mount -o lazytime,noatime,discard /dev/$device "/mnt/$mntpnt"
                ;;
                remove)
                        # Once the device is removed, the /dev entry disappear. We need mountpoint
                        mountpoint=`mount |grep /dev/$device | sed 's/.* on \(.*\) type.*/\1/'`
                        umount -l $mountpoint
                        rmdir $mountpoint
                ;;
        esac
fi
```
