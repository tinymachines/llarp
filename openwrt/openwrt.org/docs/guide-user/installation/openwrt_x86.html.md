# OpenWrt on x86 hardware (PC / VM / server)

See also: [OpenWrt on UEFI based x86 systems](/docs/guide-developer/uefi-bootable-image "docs:guide-developer:uefi-bootable-image")

OpenWrt can run in normal PC, VM, or server hardware, and take advantage of the much more powerful hardware the x86 (Intel/AMD) architecture can offer.

### Download disk images

[Go here](https://downloads.openwrt.org/releases/ "https://downloads.openwrt.org/releases/"), choose the release version, then click on **target** and then on **x86**. You will see different targets.

There are multiple targets for x86 OpenWrt, some are targeted at old or specific hardware and their build defaults may not be suit modern x86 hardware:

- **64** is for modern PC hardware (anything from around 2007 onward), it is built for 64-bit capable computers and has support for modern CPU features. Choose this unless you have good reasons not to.
- **Generic** is for 32-bit-only hardware (either old hardware or some Atom processors), should be **i686** Linux architecture, will work on Pentium 4 and later. Use this only if your hardware can't run the 64-bit version.
- **Legacy** is for very old PC hardware, Pentium MMX, what is called **i586** in Linux architecture support. It will miss a lot of features you want/need on modern hardware like multi-core support and support for more than 4GB of RAM, but will actually run on ancient hardware while other versions will not.
- **Geode** is a custom Legacy target customized for Geode SoCs, which are still in use in many (aging) networking devices, like the older Alix boards from PCEngines.

Once you select a target, there are multiple disk image files with different characteristics:

- **ext4-combined-efi.img.gz** This disk image uses a single read-write ext4 partition without a read-only squashfs root filesystem. As a result, the root partition can be expanded to fill a large drive (e.g. SSD/SATA/mSATA/SATA DOM/NVMe/etc). Features like Failsafe Mode or Factory Reset will not be available as they need a read-only squashfs partition in order to function. It has both the boot and root partitions and Master Boot Record (MBR) area with updated GRUB2.
- **ext4-combined.img.gz** This disk image is the same as above but it is intended to be booted with PC BIOS instead of EFI.
- **ext4-rootfs.img.gz** This is a partition image of only the root partition. It can be used to install OpenWRT without overwriting the boot partition and Master Boot Record (MBR).
- **kernel.bin**
- **squashfs-combined-efi.img.gz** This disk image uses the traditional OpenWrt layout, a squashfs read-only root filesystem and a read-write partition where settings and packages you install are stored. Due to how this image is assembled, you will have less than 100MB of space to store additional packages and configuration, and extroot does not work. It supports booting from EFI.
- **squashfs-combined.img.gz** This disk image is the same as above but it is intended to be booted with PC BIOS instead of EFI.
- **squashfs-rootfs.img.gz**
- **rootfs.tar.gz** This contains all the files from the root partition. It can be extracted onto a root filesystem without the need of overwriting the partition. To avoid conflicts, it is highly recommended you backup any older files and extract this file onto an empty filesystem.

## Hardware support

All images support basic video output (screen text terminal), so you can connect a screen to the device's video ports and see it boot up.

Some images support keyboard input which can be used to configure OpenWrt.

To communicate through a PC serial port you will need a “null-modem” aka “crossed” serial cable to connect the device's serial port to your PC's serial port.

To be able to connect to your device, the image must support the Ethernet hardware.

- The [64-bit](https://downloads.openwrt.org/snapshots/targets/x86/64/profiles.json "https://downloads.openwrt.org/snapshots/targets/x86/64/profiles.json") image supports Intel and Realtek Ethernet chipsets.
- The [Generic](https://downloads.openwrt.org/snapshots/targets/x86/generic/profiles.json "https://downloads.openwrt.org/snapshots/targets/x86/generic/profiles.json") and [Legacy](https://downloads.openwrt.org/snapshots/targets/x86/legacy/profiles.json "https://downloads.openwrt.org/snapshots/targets/x86/legacy/profiles.json") images support Intel, Realtek, Via and some other ethernet chipsets.
- The [Geode](https://downloads.openwrt.org/snapshots/targets/x86/geode/profiles.json "https://downloads.openwrt.org/snapshots/targets/x86/geode/profiles.json") images support Geode hardware so as long as you have a Geode-based board you should be fine.

NVMe SSD support is available since OpenWrt 21.02.

## Packages to consider on x86

OpenWrt has a minimalist philosophy regarding packaging strategy due to limited space on embedded devices. For many x86 machines, disk space is likely not a limiting factor. Users coming from desktop distros where thousand of modules are provided in the default image, might be surprised to see that on OpenWrt, the default number of drivers is also minimal. Therefore, it may be necessary to identify and obtain the needed modules for things like: storage controllers (SATA/USB etc.), sound module, crypto modules, video modules, etc.

One strategy to identify needed modules is to boot into a live Linux distro (for example [Arch Linux](https://archlinux.org/download "https://archlinux.org/download")) and inspect the output of `lsmod` or `lspci -vvv | grep driver` and then search for corresponding OpenWrt kmod packages.

Another option if building your own image is to build all modules `ALL_KMODS=y` and see what works. Newer hardware may not be supported out-of-the-box.

Beyond the kmods, some common packages to consider installing on x86 are listed below:

- For CPU/APU microcode updates for AMD processors, [amd64-microcode](/packages/pkgdata/amd64-microcode "packages:pkgdata:amd64-microcode") and for Intel processors, [intel-microcode](/packages/pkgdata/intel-microcode "packages:pkgdata:intel-microcode").
- For disk monitoring, [smartmontools](/packages/pkgdata_owrt21_2/smartmontools "packages:pkgdata_owrt21_2:smartmontools"), see: [smartmontools](/docs/guide-user/additional-software/smartmontools "docs:guide-user:additional-software:smartmontools")
- For hardware monitoring, [lm-sensors](/packages/pkgdata/lm-sensors "packages:pkgdata:lm-sensors")
- For hardware watchdog support, see: [watchdog](/docs/guide-user/hardware/watchdog "docs:guide-user:hardware:watchdog")
- For kernel entropy, [rng-tools](/packages/pkgdata/rng-tools "packages:pkgdata:rng-tools"), see: [rng](/docs/guide-user/services/rng "docs:guide-user:services:rng")

## Installation

The installation consists of writing a raw disk image on the drive which will boot OpenWrt system. It may be a USB flash drive, USB SDcard reader with SDcard or in a SATA hard drive or SSD (recommended). You can do it either on a secondary PC, or booting the router machine with a Live CD/USB.

Installation procedure differs depending from what OS you are using to write the raw disk image from, mostly because of different tools you have to use.

Writing raw image files DELETES the content of the drive you write them on. Be sure to select the correct drive so you do not delete anything important.

### Windows / macOS

If you are using a Windows / macOS, you will need a program to extract the raw disk image from the compressed archive you downloaded. Then you will need to open the raw image file with a program that can write it on the drive you want to install OpenWrt on.

A good free and opensource archiver program you can use is [7zip](https://www.7-zip.org/ "https://www.7-zip.org/"), or [Keka](https://www.keka.io/en/ "https://www.keka.io/en/").

A good free and opensource raw disk image writer program you can use is [Win32 Disk Imager](https://sourceforge.net/projects/win32diskimager/ "https://sourceforge.net/projects/win32diskimager/"), or [Etcher](https://www.balena.io/etcher/ "https://www.balena.io/etcher/").

### Linux

Extract the image file from the archive. Most sane distros will let you do so by right click and then select “extract”, or you will have to open up your graphical archive manager and do it from there. Then write the image file you extracted to the drive you want to install OpenWrt in. Many distros include a disk image writer application such as GNOME Disks. Identify the disk you want to write the image on, e.g. sda, sdb, sdc, etc., and write the image with dd tool where using the previously identified drive name. Note you have to gain administrative privileges with sudo and write to the drive (sda, sdb), not to a partition (sda1, sdb3).

```
# Unpack image
gunzip openwrt-*.img.gz
 
# Identify disk (to replace sdX in the following command below)
lsblk
 
# Write image
dd if=openwrt-21.02.0-x86-64-generic-ext4-combined.img bs=1M of=/dev/sdX
```

## Installing OpenWrt on an internal drive

If you want to write OpenWrt in SATA or IDE drives or CF Cards or SD cards, you can just remove them from the device and flash the image raw from your PC. Also sometimes eMMC is removable or can be put in “usb write mode” in some devices.

But if you cannot remove the storage from the device (or do not have an adapter to connect them to the PC), you can write OpenWrt on a USB drive (or another removable storage device), then you can then insert it in a USB port or slot. When booting select the drive where you installed OpenWrt.

Then you need to identify how is the internal storage device called with lsblk or dmesg:

```
opkg update
opkg install lsblk
lsblk
dmesg | grep -e sd
```

Be aware that you will also see the USB drive or the storage device you have temporarily installed OpenWrt on.

This for example is the output of a 4GB USB drive with 2 partitions on it that was assigned the name /dev/sda:

```
[    2.807590] sd 4:0:0:0: [sda] 7839744 512-byte logical blocks: (4.01 GB/3.74 GiB)
[    2.808703] sd 4:0:0:0: [sda] Write Protect is off
[    2.808754] sd 4:0:0:0: [sda] Mode Sense: 23 00 00 00
[    2.809827] sd 4:0:0:0: [sda] Write cache: disabled, read cache: enabled, doesn't support DPO or FUA
[    2.814991]  sda: sda1 sda2
[    2.818338] sd 4:0:0:0: [sda] Attached SCSI removable disk
```

After you have identified the onboard storage you want to install OpenWrt in, you can follow the Linux install instructions [above](/docs/guide-user/installation/openwrt_x86#linux "docs:guide-user:installation:openwrt_x86"). Then power off the system, unplug the removable storage device you used to install OpenWrt, and power on again. Now it should boot from the internal storage.

## Partition layout

The x86 image is using the following partition layout (as seen from inside of the device):

1. /dev/sda1 is a 16MB ext4 /boot partition where GRUB and the kernel are stored.
2. /dev/sda2 is a 104MB partition containing the squashfs root filesystem and a read-write f2fs filesystem OR the ext4 root filesystem (depending on what image you have chosen).

Any additional space in the device is unallocated.

## Expanding root partition and filesystem

See also automated script on: [Expanding root partition and filesystem](/docs/guide-user/advanced/expand_root "docs:guide-user:advanced:expand_root").

### Expanding root partition

When installing OpenWrt on a VM, be sure to [expand the underlying disk image](/docs/guide-user/virtualization/qemu#preparation "docs:guide-user:virtualization:qemu") before expanding the partition.

Use [parted](http://man.cx/parted "http://man.cx/parted") to fix the partition table, identify and expand the root partition.

```
# Install packages
opkg update
opkg install parted
 
# Identify disk name and partition number
parted -l -s
 
# Expand root partition
parted -f -s /dev/sda resizepart 2 100%
 
# Apply changes
reboot
```

### Expanding root filesystem

Be sure to [expand the underlying partition](/docs/guide-user/installation/openwrt_x86#expanding_root_partition "docs:guide-user:installation:openwrt_x86") before expanding the filesystem.

It is possible to expand the root filesystem online while OpenWrt is booted. You can also perform this operation offline to reduce the chance of filesystem corruption.

Use [losetup](http://man.cx/losetup "http://man.cx/losetup") to map the root partition and [resize2fs](http://man.cx/resize2fs "http://man.cx/resize2fs") to expand the root filesystem.

```
# Install packages
opkg update
opkg install losetup resize2fs
 
# Map loop device to root partition
losetup /dev/loop0 /dev/sda2 2> /dev/null
 
# Expand root filesystem
resize2fs -f /dev/loop0
 
# Apply changes
reboot
```

### Expanding root partition with fdisk

You can also use `fdisk` to expand the root partition if `parted` does not work for you. The easiest way to do this is from the machine booted with a “live CD” distro like [Finnix](https://www.finnix.org "https://www.finnix.org").

Here's an overview of the steps:

1. Use fdisk to display the partition table. Notice the ~100MB root partition.
2. Write down the starting sector address of the root partition (Usually `/dev/sda2` or `/dev/nvme0n1p2`).
3. Use fdisk to delete partition 2 but don't write the changes to disk yet.
4. Use fdisk to create a new partition 2.
   
   1. choose/type the starting sector address you wrote down earlier (as by default it will try to place it somewhere else).
   2. leave the default end sector address (this will mean the partition will now use all available space).
5. Write the partition table changes to disk.
   
   1. When it warns about partition signatures being present, type **n** to NOT remove the partition signature to proceed.
6. Proceed with updating `/boot/grub/grub.cfg` with the new partition UUID

Example output:

```
Welcome to fdisk (util-linux 2.32).
Changes will remain in memory only, until you decide to write them.
Be careful before using the write command.

Command (m for help): p
Disk /dev/sda: 7.2 GiB, 7751073792 bytes, 15138816 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0xcbad8a62

Device     Boot Start    End Sectors  Size Id Type
/dev/sda1  *      512  33279   32768   16M 83 Linux
/dev/sda2       33792 246783  212992  104M 83 Linux

Command (m for help): d
Partition number (1,2, default 2): 

Partition 2 has been deleted.

Command (m for help): n
Partition type
   p   primary (1 primary, 0 extended, 3 free)
   e   extended (container for logical partitions)
Select (default p): 
Partition number (2-4, default 2): 
First sector (33280-15138815, default 34816): 33792
Last sector, +sectors or +size{K,M,G,T,P} (33792-15138815, default 15138815): 

Created a new partition 2 of type 'Linux' and of size 7.2 GiB.
Partition #2 contains a ext4 signature.

Do you want to remove the signature? [Y]es/[N]o: n

Command (m for help): w

The partition table has been altered.
Syncing disks.
```

Be aware that deleting and recreating the root partition can change its UUID. Make sure to update the root partition UUID in your GRUB configuration `/boot/grub/grub.cfg` in order for the system to be bootable.

```
# Update GRUB configuration
ROOT_BLK="$(readlink -f /sys/dev/block/"$(awk -e \
'$9=="/dev/root"{print $3}' /proc/self/mountinfo)")"
ROOT_DISK="/dev/$(basename "${ROOT_BLK%/*}")"
ROOT_DEV="/dev/${ROOT_BLK##*/}"
ROOT_UUID="$(partx -g -o UUID "${ROOT_DEV}" "${ROOT_DISK}")"
sed -i -r -e "s|(PARTUUID=)\S+|\1${ROOT_UUID}|g" /boot/grub/grub.cfg
```

## Adding extra partitions

When OpenWrt is installed on a x86 machine using **generic-ext4-combined.img.gz**, the drive's partition table is overwritten, which means that any existing partition is deleted. Any remaining space will be unallocated and the drive will have a normal MBR partition table.

Any partition management tool that supports MBR and ext4 can be used to create extra partitions on the drive, e.g. [parted](/packages/pkgdata/parted "packages:pkgdata:parted"), [fdisk](/packages/pkgdata/fdisk "packages:pkgdata:fdisk").

But attention must be taken for future upgrades. If extra partitions are added, you cannot use **-combined.img.gz** images anymore, because writing this type of image will override the drive's partition table and delete any existing extra partition, and also revert boot and rootfs partitions back to default size.

## Upgrading

On most embedded devices that run OpenWrt, upgrading is much simpler than the first installation and consists of simply executing the `sysupgrade` command. This holds true for the x86 platforms as well.

Use any of the usual [sysupgrade](/docs/guide-user/installation/generic.sysupgrade "docs:guide-user:installation:generic.sysupgrade"), [LuCI Attended Sysupgrade](/docs/guide-user/installation/attended.sysupgrade "docs:guide-user:installation:attended.sysupgrade"), [owut](/docs/guide-user/installation/sysupgrade.owut "docs:guide-user:installation:sysupgrade.owut") or [Firmware Selector](https://firmware-selector.openwrt.org/ "https://firmware-selector.openwrt.org/") tools for upgrading your x86 device. But:

Your first step is always...

**Make a backup!**

- From LuCI, go to **System → Backup/Flash firmware**. Click **Generate archive**.
- From CLI use `sysupgrade --create-backup /tmp/backup.tar.gz` and use `scp` or some other tool to copy the file to a safe location (usually another host).

*Just do it. Every time...*

### Extracting boot partition image

The boot partition contains part of GRUB2 software, Linux kernel and `grub.cfg` with boot options. rootfs partition contains OpenWrt files, packages and configs.

At the moment, it's not built a separated image file with boot partition, as it's available for rootfs. To be able to upgrade boot partition without overriding the whole drive, we must extract it from **ext4-combined.img.gz**, this requires a spare empty drive or a virtual machine.

1. Uncompress combined partitions image: `gzip -d openwrt-19.07.8-x86-64-generic-ext4-combined.img.gz`
2. Write the image to the **empty** drive: `dd if=openwrt-19.07.8-x86-64-generic-ext4-combined.img of=/dev/sdd` (drive may be on sda, sdb, nvme0n1, etc)
3. Extract boot partition image: `dd if=/dev/sdd1 of=openwrt-19.07.8-x86-64-generic-ext4-boot.img`

We will end up with the partition image **openwrt-19.07.8-x86-64-generic-ext4-boot.img**. Back to OpenWRT machine/drive, if the drive is on sdd and GRUB2 boot partition is on sdd1, we can write the updated image with `dd if=openwrt-19.07.8-x86-64-generic-ext4-boot.img of=/dev/sdd1`. Note we're here writing on the partition sdd1, not on the drive sdd.

### Upgrading rootfs partition

As said above, there are 2 options for upgrading rootfs partition, when we are using the ext4 filesystem and not squashfs: writing **ext4-rootfs.img.gz** image or uncompressing **rootfs.tar.gz** into existing partition.

Writing **ext4-rootfs.img.gz** will delete any file on the partition. When using `dd`, it will preserve partition's actual size, it won't revert its size to image's.

1. Uncompress rootfs image: `gzip -d openwrt-19.07.8-x86-64-generic-ext4-rootfs.img.gz`
2. Write the image to the partition: `dd if=openwrt-19.07.8-x86-64-generic-ext4-rootfs.img of=/dev/sdd2`

For uncompressing **rootfs.tar.gz**, we must mount rootfs partition, delete all files from it, then uncompress updated files.

It may be tempting to not delete config files, but the risk isn't worth it, because some file may conflict and not be properly upgraded. It's safer to backup config files (as we should also backup whole drive before upgrading) and copy them back after upgrading. I suggest going further and having a Subversion repository on another computer where all config files are saved and their changes are tracked, and use **rsync** to sync between the repository working copy and production files on the router.

```
# mount rootfs partition, in this example it's on sdd2
mkdir /mnt/rootfs
mount -v /dev/sdd2 /mnt/rootfs
cd /mnt/rootfs
 
# delete all files on the partition
rm -Rf *
 
# copy rootfs.tar.gz here then uncompress it
tar -xvzf openwrt-19.07.8-x86-64-generic-rootfs.tar.gz
 
# wait for uncompress then delete the file
rm openwrt-19.07.8-x86-64-generic-rootfs.tar.gz
```

## Building your own image with larger partition size

Anyone can compile OpenWrt from source, but it's a complex procedure with many options which require some experience, specially for using it on a production router.

Different from compiling, we can build our own custom image using the [Image Builder](/docs/guide-user/additional-software/imagebuilder "docs:guide-user:additional-software:imagebuilder"). This doesn't compile the whole software, instead it downloads required packages from the same repository used by OpenWrt to install them. Image Builder builds the same image files used for installing and upgrading OpenWrt.

Due to that it's much simpler than compiling and offers great advantages, like adding directly to the image all packages we need, removing those we don't need, and also adding to it our config files. Having packages on the image, we don't need to reinstall all of them after an upgrade. And having our config files directly on the image, we don't need to reconfigure everything or copy all files from backup, which is specially difficult when default network configs don't work with our router's interfaces or it doesn't start with correct IP address. In many cases, OpenWrt will be back fully working on first boot after upgrading.

Another advantage for building a custom image is when the default rootfs partition size is too small to store all packages and we need to expand it. Note that, when following above procedures of installing then expanding partition and upgrading by writing partition image or extracting rootfs.tar.gz, we don't need to build the image with the final size of the partition. Doing so would result in the too large image file and would require enough RAM to store the whole file during building. It's recommended to use on the image just enough size to store all packages plus a small amount of free space.

Follow the [Image Builder](/docs/guide-user/additional-software/imagebuilder "docs:guide-user:additional-software:imagebuilder") tutorial to setup the building environment using the x86/64 target. Once the building environment is setup, we use the `make image` command to build an image, which results on a set of files with the types of images described on this page. They are saved on `bin/targets/x86/64` inside the building folder.

Because x86 hardware doesn't have profiles, we don't need to use the `PROFILE` parameter. With `PACKAGES` parameter we set all packages we want to add to or remove from default list. The command `make info` lists default packages list. `FILES` parameter is used to add custom config and script files to be added to the image, it points to a folder which represents root folder when OpenWrt is running.

For changing default partition sizes use parameters `CONFIG_TARGET_KERNEL_PARTSIZE` and `CONFIG_TARGET_ROOTFS_PARTSIZE`. We can either edit `.config` file on building folder or pass them directly to `make image`. Example `CONFIG_TARGET_KERNEL_PARTSIZE=128 CONFIG_TARGET_ROOTFS_PARTSIZE=512`.
