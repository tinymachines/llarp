# Filesystems

This page contains basic information about filesystems (file systems) and partitions. A filesystem is “how data is written in a partition of the storage device”. Windows, macOS, and Linux use different default filesystems, and not all filesystems work equally well across operating systems.

OpenWrt is a Linux-based operating system and thus typically works best with filesystems native to Linux. However it can also read/write data with many filesystems, albeit sometimes slower or less reliable than with native Linux filesystems. In case you wonder, the reason for this reduced performance is patents and other ways to impede the adoption of Microsoft or Apple filesystems by other parties.

Installing these additional filesystems in OpenWrt is commonly for file sharing using [USB 3.0 storage](/docs/guide-user/storage/usb-drives-quickstart "docs:guide-user:storage:usb-drives-quickstart") and [Samba](/docs/guide-user/services/nas/cifs.server "docs:guide-user:services:nas:cifs.server").

### Check available filesystems

To see what filesystems can be read currently, enter `cat /proc/filesystems`.

A full list of filesystems available in OpenWrt can be obtained by writing  
`opkg update && opkg list | grep kmod-fs`

The tools for the filesystem of your choosing can be found by writing  
`opkg list | grep FILESYSTEM_NAME`

OpenWrt has drivers and filesystem tools available for ext2/3/4, f2fs, btrfs, and many other filesystems supported by Linux.

## OpenWrt/Linux filesystems

The two most common Linux filesystems are [ext4](https://en.wikipedia.org/wiki/ext4 "https://en.wikipedia.org/wiki/ext4") and [f2fs](https://en.wikipedia.org/wiki/f2fs "https://en.wikipedia.org/wiki/f2fs"), with [btrfs](https://en.wikipedia.org/wiki/btrfs "https://en.wikipedia.org/wiki/btrfs") growing in popularity:

- ext4 is well suited for HDDs and SSDs (using TRIM) and is the default filesystem of most desktop Linux distributions.
- f2fs is well suited for flash (SSDs or USB thumbdrives). The format can be incompatible between kernel versions, requiring some time for “fsck” to upgrade the filesystem.
- btrfs is the default filesystem for more cutting-edge Linux distributions. It is considered the sucessor to ext4, with the author stating “there will be no ext5”. It has some more advanced features such as checksumming.

### ext4

This command will download the tools needed to create and fix ext4 (and older versions)  
`opkg install e2fsprogs`

If in the list of supported filesystems in your device you don't see ext4, you must install also the driver itself  
`opkg install kmod-fs-ext4`

### f2fs

This command will download the tools needed to create and fix f2fs  
`opkg install f2fs-tools`

If in the list of supported filesystems in your device you don't see f2fs, you must install also the driver itself  
`opkg install kmod-fs-f2fs`

### btrfs

This command will download the tools needed to create and fix btrfs  
`opkg install btrfs-progs`

If in the list of supported filesystems in your device you don't see btrfs, you must install also the driver itself  
`opkg install kmod-fs-btrfs`

## Windows filesystems

The two most common filesystems used by Windows are [NTFS](https://en.wikipedia.org/wiki/NTFS "https://en.wikipedia.org/wiki/NTFS") and [exFAT](https://en.wikipedia.org/wiki/exFAT "https://en.wikipedia.org/wiki/exFAT") as described below.

### NTFS

NTFS is the proprietary file system used in Windows. Two drivers are available with read/write support in Linux, `ntfs-3g`, and with kernel 5.15 onward the new in-kernel driver `ntfs3`. See [Writable NTFS](/docs/guide-user/storage/writable_ntfs "docs:guide-user:storage:writable_ntfs") for important information on mounting and features.

Download and install the NTFS3 driver  
`opkg install kmod-fs-ntfs3`

## Apple filesystems

In Apple land you have [HFS](https://en.wikipedia.org/wiki/HFS "https://en.wikipedia.org/wiki/HFS"), [HFS+](https://en.wikipedia.org/wiki/HFS+ "https://en.wikipedia.org/wiki/HFS+") and [APFS](https://en.wikipedia.org/wiki/APFS "https://en.wikipedia.org/wiki/APFS"). There is a driver available for HFS and HFS+ but it has low performance and does not support all features. APFS was introduced in 2017 but there is currently no support for it in OpenWrt (nor in Linux).

### HFS and HFS+

This command will download the tools needed to create and fix HFS and HFS+  
`opkg install hfsfsck`

If in the list of supported filesystems in your device you don't see **hfs** and **hfsplus**, you must install also the drivers  
`opkg install kmod-fs-hfs kmod-fs-hfsplus`

## Multiplatform filesystems

### FAT32

[FAT32](https://en.wikipedia.org/wiki/FAT32 "https://en.wikipedia.org/wiki/FAT32") was a common multiplatform file system. It can be read/write by Windows, macOS, Linux, and any other device you might have (smartTV, tablets, car audio with usb, etc). Its has two major drawbacks given its age: it cannot store files larger than 3.9 GB, and it lacks journaling support, meaning it's also prone to corruption if the device is disconnected while writing. This can lead to data loss if the device is written again without running a filesystem check.

This command will download the tools needed to create and fix FAT32 (and older versions)  
`opkg install dosfstools` (The dosfstools package includes the [mkfs.fat](https://linux.die.net/man/8/mkfs.vfat "https://linux.die.net/man/8/mkfs.vfat") and [fsck.fat](https://linux.die.net/man/8/fsck.vfat "https://linux.die.net/man/8/fsck.vfat") utilities, which respectively make and check MS-DOS FAT filesystems.)

If in the list of supported filesystems in your device you don't see **vfat**, you must install also the driver itself  
`opkg install kmod-fs-vfat`

#### Available NLS files

Some filesystems, like FAT32, may need additional Native Language Support (NLS) packages (codepages / charsets) to handle the filenames. If your mount fails, look in dmesg - a message like  
`FAT: codepage cp437 not found`  
means that you need NLS codepage 437, and a message like  
`FAT: IO charset iso8859-1 not found`  
means that you need NLS ISO 8859-1.

Available NLS packages can be listed by writing `opkg update && opkg list “kmod-nls*”`. There will be many available, below are a few examples.

Name Description kmod-nls-cp1250 Kernel module for NLS Codepage 1250 (Eastern Europe) kmod-nls-cp1251 Kernel module for NLS Codepage 1251 (Russian) kmod-nls-cp437 Kernel module for NLS Codepage 437 (United States, Canada) kmod-nls-cp775 Kernel module for NLS Codepage 775 (Baltic Rim) kmod-nls-cp850 Kernel module for NLS Codepage 850 (Europe) kmod-nls-cp866 Kernel module for NLS Codepage 866 (Cyrillic) kmod-nls-iso8859-1 Kernel module for NLS ISO 8859-1 (Latin 1) kmod-nls-koi8r Kernel module for NLS KOI8-R (Russian) kmod-nls-utf8 Kernel module for NLS UTF-8

### exFAT

exFAT is commonly used by OEMs for external SSDs and SD cards. The downside to this filesystem is the lack of journaling support, which makes breakage during sudden poweroff more likely. exFAT will provide good performance while maintaining compatibility with Windows and macOS.

As of Linux kernel 5.4 there is a [new exFAT driver](https://www.phoronix.com/scan.php?page=news_item&px=Linux-5.4-Released "https://www.phoronix.com/scan.php?page=news_item&px=Linux-5.4-Released") this is available with low overhead. This new driver is quite performant and will max out gigabit LAN at 120 MB/s using USB 3.0 external drives on some targets, as tested on the [wrt\_ac\_series](/toh/linksys/wrt_ac_series "toh:linksys:wrt_ac_series").

This will install the driver to use exFAT and the tool to be able to run check disk if needed:  
`opkg install kmod-fs-exfat exfat-fsck`

Under Windows, exFAT does not support TRIM; but under Linux/OpenWRT, it does.

## Partitions

A [partition](https://en.wikipedia.org/wiki/Disk_partitioning "https://en.wikipedia.org/wiki/Disk_partitioning") is a way to split the storage space in more different sections, each using its own independent filesystem.

This can be useful to separate different types of data, for example to keep your expanded firmware separate from the actual data you want to store and share, or data that must be easily accessible from Windows or macOS directly if you disconnect the external drive.

Discussing advanced partitioning is beyond the scope of this article, as OpenWrt uses the same commandline tools used by any other Linux system.

- **fdisk** tool is used to create/modify partitions on a drive initialized with MBR scheme; since version 2.23 (OpenWRT is on 2.37, as of 2024!), it also supports GPT just fine.
- **gdisk** tool is used to create/modify partitions on a drive initialized with GPT scheme.
