# Using storage devices

*Tip:* The [**Quick Start for installing a USB drive**](/docs/guide-user/storage/usb-drives-quickstart "docs:guide-user:storage:usb-drives-quickstart") solves the very common case of installing a single USB drive onto your OpenWrt device. People do this to use Samba or other programs that need to store data on an external drive. The remainder of this page provides much more information about USB devices and drivers.

Many supported devices have ports to connect storage devices, most common are USB, or Sata.  
This article will describe how to configure your device to use such storage devices for storage or for sharing. If you want to expand your firmware's space (to install more packages) please read the article about [Extroot configuration](/docs/guide-user/additional-software/extroot_configuration "docs:guide-user:additional-software:extroot_configuration").

To configure external disk space, follow the procedures of this page:

1. Verify storage drivers
2. Verify that the OS recognizes the attached disk and its partitions
3. Create a partition on the USB disk
4. Create a file system in the partition
5. Automount the partition
6. Idle spin down of hard disks

## Install and verify USB drivers

This step ensures that required USB storage drivers are properly installed.

1. Start by refreshing the list of available software packages:
   
   ```
   opkg update
   ```
2. The typical OpenWrt package already has core USB device drivers installed (if your device has USB ports at all), but might not yet have an USB storage device driver installed. Install this storage driver first (if it is already installed, the following command will just say “is already installed”:
   
   ```
   opkg install kmod-usb-storage
   ```
3. Some USB storage devices may require the UAS driver:
   
   ```
   opkg install kmod-usb-storage-uas
   ```
4. To check, if the whole USB driver chain is working correctly, install the optional **usbutils** package:
   
   ```
   opkg install usbutils
   ```
5. Now connect your USB disk/stick and list your connected devices with a command from these **usbutils**:
   
   ```
   lsusb -t
   ```
6. This will output a list of device USB hub ports and connected external storage devices:
   
   ```
   /:  Bus 02.Port 1: Dev 1, Class=root_hub, Driver=xhci-mtk/1p, 5000M
   /:  Bus 01.Port 1: Dev 1, Class=root_hub, Driver=xhci-mtk/2p, 480M
       |__ Port 1: Dev 5, If 0, Class=Mass Storage, Driver=usb-storage, 480M
   ```

<!--THE END-->

- “Bus...”-Lines represent the host chip. Here, the “Driver” will be `xhci` for USB3.0, `ehci` for USB2.0 and `uhci` or `ohci` for USB1.1.
- Lines with “Class=Mass Storage” represent connected USB devices. Here the “Driver” is either `usb-storage` for storage of type [Bulk only Transport](https://en.wikipedia.org/wiki/USB_mass_storage_device_class "https://en.wikipedia.org/wiki/USB_mass_storage_device_class") or `usb-storage-uas` for storage of type [USB\_Attached\_SCSI](https://en.wikipedia.org/wiki/USB_Attached_SCSI "https://en.wikipedia.org/wiki/USB_Attached_SCSI")

In step 5, verify that the output prints no error and has at least one output line for **root\_hub** and **Mass Storage** and that each **Driver=** lists a driver name. If not, then refer to [the Installing USB Drivers](/docs/guide-user/storage/usb-installing "docs:guide-user:storage:usb-installing") for more suggestions on drivers.

## Verify that the OS recognizes the attached disk and partitions

This optional verification step can be used, to check that the OS can properly detect a connected external drive.

1. Ensure your USB disk/stick is stick connected
2. Run in a command line:
   
   ```
   ls -l /dev/sd*
   ```
3. This should now show a list of block devices known to the OS
   
   ```
   brw-------    1 root     root        8,   0 Oct 30 12:49 /dev/sda
   brw-------    1 root     root        8,   1 Oct 30 12:49 /dev/sda1
   ```
   
   This should print at least a connected disk like “/dev/sda” or “/dev/sdb”. If no disk at all is listed, recheck USB driver installation and reboot your OpenWrt device once.
4. Install the **block** tool to get more info about existing partitions
   
   ```
   opkg install block-mount
   ```
   
   for exFAT you also need libblkid
   
   ```
   opkg install libblkid
   ```
5. Run the **block** tool:
   
   ```
   block info | grep "/dev/sd"
   ```
   
   and you should see output like this, if your disk already has partitions:
   
   ```
   /dev/sda1: UUID="2eb39413-83a4-4bae-b148-34fb03a94e89" VERSION="1.0" TYPE="ext4"
   ```

If a disk already has existing partitions, they get listed as **/dev/sda1**, **/dev/sda2** ,**/dev/sda3** and so on.  
If we had connected more than one storage device we would have also a **/dev/sdb1** (first partition of second device), **/dev/sdc1** (first partition of third device) and so on.

## Create a partition on the USB disk

if the previous chapter did not list any existing partitions (like “/dev/sda1”, “/dev/sda2”, “/dev/sdb1”...), you have to create a partition first for further storage usage.

1. To do so, install **gdisk**:
   
   ```
   opkg install gdisk
   ```
2. Start **gdisk** with the disk name identified in the previous chapter:
   
   ```
   gdisk /dev/sda
   ```
3. In the interactive gdisk menu, create a partition with gdisk command
   
   ```
   n
   ```
   
   This triggers an interactive dialogue: Use the suggested defaults for the partition creation (number, starting sector, size, Hex code)
4. When done, confirm the changes with gdisk interactive command
   
   ```
   w
   ```
   
   and then confirm your choice with
   
   ```
   Y
   ```
5. Keep a note of the created partition name for the next step

Refer to the gdisk help text (write “?”) in case you need additional help. Stick to a single partition, to stay aligned to the following HowTo.

## Install file system drivers and create a file system in the partition

To use a partition for data storage, it needs to be formatted with a file system.

The following is the most simplest (and recommended) default configuration for OpenWrt file system usage.  
For advanced users, there are [further optional file system options available](/docs/guide-user/storage/filesystems-and-partitions "docs:guide-user:storage:filesystems-and-partitions").

**WARNING: This step deletes existing data in that partition. Ensure you have a backup of important files before starting!**

- For USB hard disks, install EXT4 file system and use EXT4 to format the partition (in this example '/dev/sda1'):
  
  ```
  opkg install e2fsprogs
  opkg install kmod-fs-ext4
  mkfs.ext4 /dev/sda1
  ```
- For USB drives formatted with exFAT:
  
  ```
  opkg install kmod-fs-exfat
  ```
- For USB drives formatted as NTFS see [Filesystems](/docs/guide-user/storage/filesystems-and-partitions#setup_ntfs "docs:guide-user:storage:filesystems-and-partitions") and [Writable NTFS](/docs/guide-user/storage/writable_ntfs "docs:guide-user:storage:writable_ntfs")
- For SSD drives and thumb drives, install F2FS file system and use F2FS to format the partition (in this example '/dev/sda1'):
  
  ```
  opkg install f2fs-tools
  opkg install kmod-fs-f2fs
  mkfs.f2fs /dev/sda1
  ```

## Automount the partition

Automount ensures that the external disk partition is automatically made available for usage when booting the OpenWrt device

1. Generate a config entry for the fstab file:
   
   ```
   block detect | uci import fstab
   ```
2. Now enable automount on that config entry:
   
   ```
   uci set fstab.@mount[-1].enabled='1'
   uci commit fstab
   ```
3. Optionally enable autocheck of the file system each time the OpenWrt device powers up:
   
   ```
   uci set fstab.@global[0].check_fs='1'
   uci commit fstab
   ```
4. Reboot your OpenWrt device (to verify that automount works)
5. After the reboot, check your results: Run
   
   ```
   uci show fstab
   ```
   
   to see something like this
   
   ```
   fstab.@global[0]=global
   fstab.@global[0].anon_swap='0'
   fstab.@global[0].anon_mount='0'
   fstab.@global[0].auto_swap='1'
   fstab.@global[0].auto_mount='1'
   fstab.@global[0].check_fs='0'
   fstab.@global[0].delay_root='5'
   fstab.@mount[0]=mount
   fstab.@mount[0].target='/mnt/sda1'
   fstab.@mount[0].uuid='49c35b1f-a503-45b1-a953-56707bb84968'
   fstab.@mount[0].enabled='1'
   ```
6. Check the “enabled” entry. It should be '1'.
7. Note the “target” entry. This is the file path, where your attached USB storage drive can be accessed from now on. E.g. you can now list files from your external disk:
   
   ```
   ls -l /mnt/sda1
   ```
8. Run the following command, to verify that the disk is properly mounted at this path
   
   ```
   block info
   ```
   
   The result will be:
   
   ```
   ...
   /dev/sda1: UUID="2eb39413-83a4-4bae-b148-34fb03a94e89" VERSION="1.0" MOUNT="/mnt/sda1" TYPE="ext4"
   ```
9. Your external storage is now ready for further usage:
   
   ```
   service fstab boot
   ```

## Optional: Idle spindown timeout on disks for NAS usage

If you want to use OpenWrt as a permanent NAS, you should spin down the drive during times of inactivity. This may be to have it quiet, reduce power consumption, and increase life of a harddisk (e.g. especially if using a home-edition harddisk (instead of a 24×7-datacenter drive).

There are several optional packages available to automatically spin down an attached disk after a certain time of inactivity.

**1. Option: hdparm**  
Using standard SATA commands this tool permanently saves a spindown timer on the harddisk itself. The harddisk will then maintain that spindown-timer value, even if turned off, even after a restart and even if attached to a different device. As this is simply a command line for a built-in harddisk function no service will run in the background for this and 'hdparm' could even be uninstalled after setting this parameter. Unfortunately many older USB2.0 PATA/SATA adapters do not support the required SATA command, although even decade-old harddisks do support it. Fortunately most USB3.0 SATA drives seem to support this command. To install the package:

```
opkg update && opkg install hdparm
```

To set a reasonable idle timeout of 10 minutes on the harddisk:

```
hdparm -S 120 /dev/sda2
```

- If the command failed with an error message, your USB-SATA device sadly does not support it and you won't be able to use 'hdparm' for disk spindown.
- For more details of allowed options see [https://linux.die.net/man/8/hdparm](https://linux.die.net/man/8/hdparm "https://linux.die.net/man/8/hdparm") at “-S” parameter
  
  - 0 means “idle timeout disabled”
  - 1 to 240 specify multiples of 5 seconds, for timeouts from 5 seconds to 20 minutes.
  - 241 to 251 specify from 1 to 11 units of 30 minutes, for timeouts from 30 minutes to 5.5 hours.

Of course you can always change the timeout or disable auto-spindown again later on. Depending on your harddisk, the value may be active until the next reset or permanently stored on the harddisk. The harddisk firmware itself manages the spindown timeout, not a OpenWrt service. For persistent changes use `/etc/rc.local` file, like:

```
# set timeout to put the drive into idle (low-power) mode
/sbin/hdparm -S 120 /dev/sda2
 
exit 0
```

**2. Option: hd-idle with LuCi integration**  
[hd-idle](/docs/guide-user/storage/hd-idle "docs:guide-user:storage:hd-idle") is a service than runs in the background of OpenWrt and maintains its own idle timeout. Once the defined timeout counter reaches 0, it will send a “live” spindown SATA command to the disk. Unlike the permanent spindown command from hdparm, a lot more USB2.0 SATA drives seem to support this “spindown-now” SATA command.

To install the package with LuCi web GUI integration:

```
opkg update && opkg install luci-app-hd-idle
```

To enable and configure it, in LuCI go to the Services → HDD Idle page.

To install only the CLI package (without LuCi):

```
opkg update && opkg install hd-idle
```

To configure it, edit the `/etc/config/hd-idle` and then autostart and run the hd-idle service `service hd-idle enable && service hd-idle start`.

Options to configure:

Name Type Default Description `disk` string `sda` Replace `sda` with your device's identifier `enabled` boolean `0` Enable hd-idle operation `idle_time_unit` string `minutes` The unit of time used in the `idle_time_interval` option `idle_time_interval` integer `10` How much idle time before spindown
