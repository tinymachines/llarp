# Fstab Configuration

The Fstab, or **f**ile **s**ystems **tab**le, is a central configuration that defines how file systems (usually on block devices) should be mounted if requested (such as on booting the device or connecting it physically). This way, you don’t have to manually mount your devices when you want to access them. The mounting configuration can consist of static file systems but also swap partitions.  
The fstab UCI subsystem is where all the options for all devices and file systems to be mounted are defined, the actual file is located at ***/etc/config/fstab***.  
By default this subsystem and its configuration file do not exist, as for the average OpenWrt usecase (network devices) it's not needed.  
So if you need to configure this, you must first create it.

Since the tool dealing with mounts is **block**, all current options can be found in its [source code](https://git.openwrt.org/?p=project%2Ffstools.git%3Ba%3Dblob%3Bf%3Dblock.c%3Bhb%3DHEAD "https://git.openwrt.org/?p=project/fstools.git;a=blob;f=block.c;hb=HEAD").

## Creating fstab

You should use the *block* utility. Install the package *block-mount*:

```
opkg update
opkg install block-mount
```

If you're dealing with USB storage, install *kmod-usb-storage* as well:

```
opkg install kmod-usb-storage
```

Get a sample fstab UCI subsystem configuration file.

```
block detect | uci import fstab
```

Now there is a UCI subsystem, you can use UCI command line to change it or just edit the file `/etc/config/fstab` itself.

It is possible to set on other devices, but the process is a bit more involved, see [Extroot configuration](/docs/guide-user/additional-software/extroot_configuration "docs:guide-user:additional-software:extroot_configuration") for details.  
Also see [Mounting Block Devices](/docs/techref/block_mount "docs:techref:block_mount") for technical details of the mounting process and scripts involved.

## Configuration

The configuration file consists of a *global* section defining defaults, *mount* sections defining file systems to be mounted and *swap* sections defining partitions to be activated. Whenever you change your fstab configuration, run this command to mount everything in the new way:

```
block umount
block mount
```

### The Global section

Name Type RequiredDefaultDescription *anon\_swap* booleanno 0 mount swap devices that don’t have their own config section *anon\_mount*booleanno 0 mount block devices that don’t have their own config section *auto\_swap* booleanno 1 automatically mount swap devices when they appear *auto\_mount*booleanno 1 automatically mount block devices when they appear *delay\_root*integerno 0 wait X seconds before trying to mount root devices on boot *check\_fs* booleanno 0 run e2fsck on device prior to a mount

### The Swap sections

Name Type Required Default Description *enabled* boolean no 1 Enables/disables using UCI section *device* string no - The swap partition’s device node (e.g. sda1) *uuid* string no - The swap partition’s UUID *label* string no - The swap partition’s label (e.g. mkswap -L label /dev/sdb2) *priority* integer no -1 The swap partition’s priority

### The Mount sections

Name Type Required DefaultDescription *enabled*booleanno 1 Enables/disables using UCI section *uuid* string yes (one)- The data partition’s file system UUID (not GPT partition UUIDs, aka PARTUUID) *label* string - The data partition’s label *device* string - The data partition’s device node (e.g. sda1) *autofs* booleanno 0 Should autofs (on-demand mounting) be used *target* string no - The data partition’s mount point. Some values have special meanings, see the Extroot section below. *options*string no - The data partition's mount options, e.g. noexec,noatime,nodiratim.

Managing *autofs* as well as mount notifications (for procd triggers) is taken care of by `blockd`. Hence `blockd` needs to be installed for those features to work.

## The right amount of SWAP

If you ask people or search the net, you will find as a general rule of thumb *double RAM* for machines with 512MiB of RAM or less than, and *same amount as RAM* for machines with more. This very rough estimate does apply for your embedded device.  
Be aware that **access time** of swap is absymal if compared to real RAM, so having swap may not help much in your specific case.  
A CUPS spooling server will run just fine when only SWAP is available, whereas some applications may perform very poorly when their data it stored on the SWAP rather then being kept in the “real” RAM.  
The decision which data is kept in the RAM and which is stored on the SWAP is made by the system. In contrast to other operating systems, Linux makes ample use of memory, so that your system runs smoother and more efficiently. If memory is then needed by an application, the system will unload stuff again, and make memory available.
