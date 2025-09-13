# SD card

OpenWrt can be installed and run from devices that use an SD card. Common devices with this include Raspberry Pi and NanoPi.

### Graphical Utilities

Install [Balena Etcher](https://etcher.balena.io/ "https://etcher.balena.io/"), a free open source program to flash SD cards on Windows, Linux, or macOS.

1. Download the image for your device which will be named similar to `openwrt-*-sysupgrade.img.gz`
2. Select the image
3. Select your SD card
4. Flash the image

### Command Line

1. Download the image for your device which will be named similar to `openwrt-*-sysupgrade.img.gz`
2. Decompress it:
   
   ```
   gzip -d openwrt-*-sysupgrade.img.gz
   ```
3. Connect an SD card to your computer and look at `lsblk` or `dmesg` to identify it. In most cases, it would be something like `/dev/sdX`. [1)](#fn__1)
4. Double check you identified your SD card correctly. If the `/dev/sdX` you have chosen corresponds to your hard drive, the next step would destroy your system.
5. Copy the image to the SD card with:
   
   ```
   dd if=openwrt-*-sysupgrade.img of=/dev/sdX
   ```

### Which image to chose?

Most SD card devices have multiple images available which differ in the [filesystem](/docs/guide-user/storage/filesystems-and-partitions "docs:guide-user:storage:filesystems-and-partitions") used.

#### ext4-sdcard.img.gz

- Not optimized for flash memory (journaling increases flash wear)
- SD card can be easily mounted externally for modification
- Updates and changes can be made directly to the partition
- Linux desktop standard

#### squashfs-sdcard.img.gz

- Compressed
- Newer images include a hidden F2FS filesystem, which is optimized for flash memory
- Needs special mount procedure to externally modify
- All changes are done in an overlay partition
- Due to overlay partition it is simple to reset system to defaults

#### Other images

- ubifs-sdcard.img.gz

### Mounting a squashfs image locally

If you insert your newly flashed SD card into a Linux computer it will be easy to mount the read only squashfs partition but it won't know about the overlay, which is not even in the partition table but instead located immediately after the squashfs filesystem in the same partition. In fact, before you've booted the SD card on your device, the overlay won't even exist.

So, first you need to make sure you've booted your image. You then need to mount the overlay as a loopback device. You can discover the offset by running `losetup` on the device, or calculate the offset yourself by inspecting the filesystem.

```
# Setup the loop back device.
# See libfstools/rootdisk.c for source of partition offset logic.
DEVICE= ### Set this appropriately - e.g. /dev/sda
PARTITION="$DEVICE"2
FS_SIZE="$(sudo unsquashfs -s "$PARTITION" | grep -o 'Filesystem size [0-9]* bytes' | grep -o '[0-9][0-9]*')"
FS_OFFSET="$(expr '(' "$FS_SIZE" + 65535 ')' / 65536 '*' 65536)" 
LOOP_DEVICE="$(sudo losetup -f --show -o "$FS_OFFSET" "$PARTITION")"

# Now mount both partitions (remember, you may need to unmount any automatic mounts)
mkdir -p /mnt/base /mnt/overlay /mnt/combined
sudo mount "$PARTITION" /mnt/base            
sudo mount "$LOOP_DEVICE" /mnt/overlay
sudo mount -o noatime,lowerdir=/mnt/base,upperdir=/mnt/overlay/upper,workdir=/mnt/overlay/work -t overlay overlayfs /mnt/combined
```

This should leave you with a writable filesystem in /mnt/combined which will work as it does on OpenWrt.

### Expanding the filesystem

To use the whole available space of your SD card, you may have to resize your partition.

#### squashfs image

First, make sure the partition is not mounted, then do something like:

```
DEVICE= ### Set this appropriately - e.g. /dev/sda
PARTITION="$DEVICE"2
sudo cfdisk "$DEVICE"  # select resize, then write
```

If you've never booted the image that's all there is to it. OpenWrt will create an overlay which uses the rest of this partition on the first boot.

However, if you already booted the image OpenWrt will have created an overlay that is smaller, so you'll need to resize the filesystem. Expand the partition as above, then:

```
# Create a loop device pointing to the FS
# See libfstools/rootdisk.c for source of partition offset logic.
FS_SIZE="$(sudo unsquashfs -s "$PARTITION" | grep -o 'Filesystem size [0-9]* bytes' | grep -o '[0-9][0-9]*')"
FS_OFFSET="$(expr '(' "$FS_SIZE" + 65535 ')' / 65536 '*' 65536)" 
LOOP_DEVICE="$(sudo losetup -f --show -o "$FS_OFFSET" "$PARTITION")"

# Now to resize... you may need to use fsck first though.
sudo fsck "$LOOP_DEVICE"
sudo resize2fs "$LOOP_DEVICE"
sudo fsck "$LOOP_DEVICE"
```

If you get an error from resize2fs about a bad superblock, you probably have an F2FS filesystem. Use `resize.f2fs` instead of `resize2fs`.

#### ext4 image

You can use `gparted` to resize and extend the partitions. To do it online, follow the procedure described on [github](http://bugs.openwrt.org/index.php?do=details&task_id=2951 "http://bugs.openwrt.org/index.php?do=details&task_id=2951") or [expanding\_root\_partition\_and\_filesystem](/docs/guide-user/installation/openwrt_x86#expanding_root_partition_and_filesystem "docs:guide-user:installation:openwrt_x86").

Example, to resize `/dev/mmcblk0p2` mounted on `/`, install `parted`, `tune2fs` and `resize2fs` then:

```
parted
p
resizepart 2 32GB
q
```

Next, you may need to repair your device (perhaps say yes to all interactive queries):

```
mount -o remount,ro /                  #Remount root as Read Only
tune2fs -O^resize_inode /dev/mmcblk0p2    #Remove reserved GDT blocks
fsck.ext4 /dev/mmcblk0p2                  #Fix part, answer yes to remove GDT blocks remnants
```

Now, `reboot` and then resize the partition:

```
resize2fs /dev/mmcblk0p2
```

Note that these operations may alter partition UUID. Either preserve the partition UUID or edit your boot parameters. For example on raspberry pi you must update

```
/boot/cmdline.txt
/boot/partuuid.txt
```

## Manual disk image assembly

Examples:

- [Sunxi](/docs/techref/hardware/soc/soc.allwinner.sunxi#chaos_calmer_-_assembling_the_sd_card_image_yourself "docs:techref:hardware:soc:soc.allwinner.sunxi")

Howto:

1. Partition and format the SD card. Details devicespecific? → Devicepage
2. Copy bootloader, kernel, rootfs (and if necessary other data) to SD card. Details devicespecific? → Devicepage
3. Possibly resize filesystem in order to use the complete available space on the SD card

[1)](#fnt__1)

You want to specify the device and not the partition, meaning, you have to use `/dev/sdX` and not `/dev/sdX1`
