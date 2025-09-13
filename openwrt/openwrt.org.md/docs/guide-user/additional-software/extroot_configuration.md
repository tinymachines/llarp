# Extroot configuration

This article relies on the following:

- Accessing [web interface](/docs/guide-quick-start/walkthrough_login "docs:guide-quick-start:walkthrough_login") / [command-line interface](/docs/guide-quick-start/sshadministration "docs:guide-quick-start:sshadministration")
- Managing [configs](/docs/guide-user/base-system/uci "docs:guide-user:base-system:uci") / [packages](/docs/guide-user/additional-software/managing_packages "docs:guide-user:additional-software:managing_packages") / [services](/docs/guide-user/base-system/managing_services "docs:guide-user:base-system:managing_services") / [logs](/docs/guide-user/base-system/log.essentials "docs:guide-user:base-system:log.essentials")

## Introduction

This guide describes how to configure OpenWrt to use a storage device (USB or SATA or SD card or whatever) to expand your root filesystem, to install freely all the packages you need.

In most supported devices OpenWrt splits the internal storage into `rootfs` and `rootfs_data` or `ubifs` partitions which are merged together into a single writable `overlay` filesystem.

Partition Mount point Compression Writable `rootfs` `/rom` Yes No `rootfs_data`  
`ubifs` `/overlay`  
`/rom/overlay` No Yes `overlay` `/` Unmodified files Yes

This way OpenWrt fits even in tiny amounts of internal storage (as low as 4 MiB), but still allows to write settings and install some packages in the writable partition without changing all Linux programs used. Extroot works by setting another overlay partition in the external storage device, and during boot this new overlay partition will be mounted over the internal storage's overlay partition. This approach also allows easy fallback in case the external storage device is removed, as your device will still have its own overlay partition and thus will load all configuration from there. Which means that it will behave exactly the same as just before you set up extroot.

Note that OpenWrt is known to [ignore](https://bugs.openwrt.org/index.php?do=details&task_id=2231 "https://bugs.openwrt.org/index.php?do=details&task_id=2231") the fstab configuration on devices without overlay partition in `/proc/mtd`. You can work around the issue by using `/` for the mount point on ROMs without overlay partition at all.

## Instructions

The following instructions assume that you already have access to a shell on your OpenWRT device. Most if not all of these commands can be done via the web interface, however that is emphatically not recommended. Usually the shell is accessed via [ssh](/docs/guide-quick-start/sshadministration "docs:guide-quick-start:sshadministration") or [serial console](/docs/techref/hardware/port.serial "docs:techref:hardware:port.serial").

### 1. Preparation

Devices with 8 MiB flash or more should have enough space to install the required packages, otherwise create a [custom image](/docs/guide-user/additional-software/extroot_configuration#custom_image "docs:guide-user:additional-software:extroot_configuration"). Remove all packages you have installed to add secondary functionality, as they are only wasting space now. (If you do not have a record of what these are, try removing 'ntfs' as that may free up enough space.) Leave only those needed to access the internet and needed to access the extroot filesystem. After you make the extroot you will have all the space you need to install secondary packages.

You may not need to make a custom image: try the OEM image first (OpenWRT GL.inet for a GL.inet mango).

The extroot can be anything that `block` can mount. Currently `block` creates some restrictions on what extroot can be. It must a [filesystem of type](https://git.openwrt.org/?p=project%2Ffstools.git%3Ba%3Dblob%3Bf%3Dblock.c%3Bhb%3DHEAD#l1554 "https://git.openwrt.org/?p=project/fstools.git;a=blob;f=block.c;hb=HEAD#l1554"): ext2/3/4, f2fs, btrfs, ntfs, or ubifs (note that it can not be a FAT16/32 filesystem). For most, this filesystem will be a on USB storage device. However, it could also be on an SD-Card or a SATA drive connected via e-sata or even a network block device (assuming its set up early enough). If you're using a USB connected device follow the [USB installation guide](/docs/guide-user/storage/usb-installing "docs:guide-user:storage:usb-installing") to set up USB storage in OpenWrt.

The following assumes that you will be creating your extroot as an EXT4 filesystem on your OpenWRT device with a connected USB flash drive. The process is similar for other kinds of devices.

Installing these packages requires a sensible amount of extra filespace. If you completely fill the filesystem by installing these, you will probably have to re-flash the entire system. So if you think you may already be close to filling the filesystem, remove some installed packages first. Good candidates for removal are ntfs3 and ntfs3-utils: you can re-install them later after you have extroot installed.

Install the required packages.

```
opkg update
opkg install block-mount kmod-fs-ext4 e2fsprogs parted kmod-usb-storage
```

If you are using an ssd in a usb enclosure, you will probably need to add the kmod-usb-storage-uas package as well.

Identify the name of the USB disk.

```
ls -l /sys/block
```

### 2. Partitioning and formatting

Partition and format the USB disk.

```
DISK="/dev/sda"
parted -s ${DISK} -- mklabel gpt mkpart extroot 2048s -2048s
DEVICE="${DISK}1"
mkfs.ext4 -L extroot ${DEVICE}
```

This will wipe all data on the disk, so do not run these commands blindly.

### 3. Configuring extroot

Configure the extroot mount entry.

```
eval $(block info ${DEVICE} | grep -o -e 'UUID="\S*"')
eval $(block info | grep -o -e 'MOUNT="\S*/overlay"')
uci -q delete fstab.extroot
uci set fstab.extroot="mount"
uci set fstab.extroot.uuid="${UUID}"
uci set fstab.extroot.target="${MOUNT}"
uci commit fstab
```

### 4. Configuring rootfs\_data / ubifs

Configure a mount entry for the the original overlay.

```
ORIG="$(block info | sed -n -e '/MOUNT="\S*\/overlay"/s/:\s.*$//p')"
uci -q delete fstab.rwm
uci set fstab.rwm="mount"
uci set fstab.rwm.device="${ORIG}"
uci set fstab.rwm.target="/rwm"
uci commit fstab
```

This will allow you to access the `rootfs_data` / `ubifs` partition and customize the extroot configuration `/rwm/upper/etc/config/fstab`.

### 5. Transferring data

Transfer the content of the current overlay to the external drive.

```
mount ${DEVICE} /mnt
tar -C ${MOUNT} -cvf - . | tar -C /mnt -xf -
```

### 6. Apply changes

Reboot the device to apply the changes.

```
reboot
```

## Testing

### Web interface instructions

1. **LuCI → System → Mount Points** should show USB partition mounted as `overlay`.
2. **LuCI → System → Software** should show free space of overlay partition.

### Command-line instructions

The USB partition should be mounted to `/overlay`. Free space for `/` should be the same as `/overlay`.

```
# grep -e /overlay /etc/mtab
/dev/sda1 /overlay ext4 rw,relatime,data=ordered
overlayfs:/overlay / overlay rw,noatime,lowerdir=/,upperdir=/overlay/upper,workdir=/overlay/work
 
# df /overlay /
Filesystem           1K-blocks      Used Available Use% Mounted on
/dev/sda1              7759872    477328   7221104   6% /overlay
overlayfs:/overlay     7759872    477328   7221104   6% /
```

## Troubleshooting

- Analyze the `preinit` stage of the boot log:

```
block info; uci show fstab; logread | sed -n -e "/- preinit -/,/- init -/p"
```

- If you receive a “block: extroot: UUID mismatch” error in your logs after upgrading, remove `.extroot-uuid` from the volume:

```
mount /dev/sda1 /mnt
rm -f /mnt/.extroot-uuid /mnt/etc/.extroot-uuid
umount /mnt
```

- Do not use vfat (FAT/FAT32); it does not work. If you have a FAT preformatted USB drive, you cannot use it for extroot without reformatting. Use e.g. ext4 (install e2fsprogs, then format your FAT formatted USB drive using `mkfs.ext4 /dev/sda1` as per the example).
- If the partition containing your extroot isn't mounted during boot, but you can mount it without problems from a shell, you should try to increase `config global / option delay_root`. On my system I had to set it to 15 seconds to get extroot working. Another hint to this being the culprit is having a working swap or other partitions mounted after booting, but not your extroot.

```
uci set fstab.@global[0].delay_root="15"
uci commit fstab
```

- ![FIXME](/lib/images/smileys/fixme.svg): **might be outdated** Add option `force_space` in `/etc/opkg.conf` to allow installation of packets bigger than your `/rom` partitions free space:

```
echo option force_space >> /etc/opkg.conf
```

- Another possibility to consider and try is to modify `/etc/rc.local` as described in [14946](https://dev.openwrt.org/ticket/14946 "https://dev.openwrt.org/ticket/14946") ticket, which in the case of running Chaos Calmer r44266 in the Comtrend AR-5387un, has been the only thing that allowed me to achieve extroot:

```
export PREINIT=1
mount_root
```

- If you are putting the extroot on a non-USB device such as a mmc card all modules needed acccess the device should be in appropriate file in `/etc/modules-boot.d`. For example using a sdhci card on a mt7688/mt7628 device `/etc/modules-boot.d/mmc` needs have two lines added:

```
mmc_core
mmc_block
sdhci
mtk_sd
```

## Extras

### Preserving opkg lists

Save opkg lists to `/usr/lib/opkg/lists` stored on the extroot, instead of in RAM. This makes package lists survive reboot and saves some RAM.

#### Web interface instructions

1. Navigate to **LuCI → System → Software → Configuration** to change `/var/opkg-lists` to `/usr/lib/opkg/lists`.
2. Navigate to **LuCI → System → Software → Actions → Update lists** to do an initial build of the package list onto extroot.

#### Command-line instructions

```
sed -i -e "/^lists_dir\s/s:/var/opkg-lists$:/usr/lib/opkg/lists:" /etc/opkg.conf
opkg update
```

### Swap

If your device fails to read the lists due to small RAM such as 32MB, enable swap.

```
# Create swap file
DIR="$(uci -q get fstab.extroot.target)"
dd if=/dev/zero of=${DIR}/swap bs=1M count=100
mkswap ${DIR}/swap
 
# Enable swap file
uci -q delete fstab.swap
uci set fstab.swap="swap"
uci set fstab.swap.device="${DIR}/swap"
uci commit fstab
service fstab boot
 
# Verify swap status
cat /proc/swaps
```

### USB dongle

It's a good idea to include the `usb-modeswitch` tool in the image. There is a caveat: if the `/overlay` points to a memory card sitting in a slot of the dongle - the otherwise working `pivot overlay` set-up will break in the later stages of OS boot. This is because the `usb-modeswitch` (while disabling the CDROM and enabling the modem) would also intermittently affect the card-reader in the dongle thus hurting the file system. To avoid this you need a dongle that can be pre-configured to enable its modem or network adapter (and the card-reader as well) on the power-up, without the need to do it with the `usb-modeswitch` on the router.

Insert your dongle in a desktop and use a terminal to send the necessary AT-commands. Check your dongle's initial configuration:

```
at^setport?
^SETPORT:A1,A2;1,3,2,A1,A2
OK
```

The meaning of the above report can be understood with the following command:

```
at^setport=?
^SETPORT:A1: CDROM
^SETPORT:A2: SD
^SETPORT:A: BLUE TOOTH
^SETPORT:B: FINGER PRINT
^SETPORT:D: MMS
^SETPORT:E: PC VOICE
^SETPORT:1: MODEM
^SETPORT:2: PCUI
^SETPORT:3: DIAG
^SETPORT:4: PCSC
^SETPORT:5: GPS
^SETPORT:6: GPS CONTROL
^SETPORT:16: NCM
OK
```

So, in the example above we have a dongle with CDROM and card-reader available in the first configuration (to the left of the `;` character), and with modem, control and diagnostic interfaces, and card-reader available in the other configuration. It is between these configurations the `usb-modeswitch` switches the dongle on the router.

Your goal is to disable the CDROM and enable the modem (the `1` above) or the network adapter (the `16` above) while leaving the card-reader enabled (the `A2` above). **NOTE: Never disable the PCUI** (the `2` above) - this will lock you out from your dongle!

Some dongles accept a 'disable all' operand (the `FF` below). Place the list of all the functions you need on your dongle by default to the right of the `;` character according to their codes from the dongle's answer above:

```
at^setport="ff;1,2,3,a2"
OK
 
at^reset
OK
 
at^setport?
^SETPORT:;1,2,3,A2
OK
```

This sequence has disabled the CDROM and made the modem, control and diagnostic interfaces and the card-reader available by default - without any `usb-modeswitch` interaction. Thus only one configuration exists now in the dongle - see the `;` character, there is nothing to the left of it now.

Pre-configuration support: Huawei E3131s-2 f/w v21.158.47.00.1094

### Remote file system

Follow: [Fstab not mounting cifs at boot or through CLI](https://forum.openwrt.org/viewtopic.php?id=32812 "https://forum.openwrt.org/viewtopic.php?id=32812")

### LUKS encrypted extroot

You may wish to have your extroot filesystem in a LUKS encrypted container. As of OpenWrt 22.03.2, this [isn't well supported](https://forum.openwrt.org/t/extroot-encryption/133230/6 "https://forum.openwrt.org/t/extroot-encryption/133230/6"). OpenWrt does not have an official way to open encrypted LUKS volumes before the extroot check happens during the normal boot path. So at the time of extroot check time, the extroot filesystem will not be visible and the boot process will continue as if there is not extroot. Below are two different methods for getting the system to run on an encrypted extroot. The first method is preferable because there are less side-effects and is a cleaner approach.

Before doing any of the below, you'll need to create the LUKS container in which to put your extroot filesystem. Follow the [disk encryption](/docs/guide-user/storage/disk.encryption "docs:guide-user:storage:disk.encryption") documentation to get a LUKS container setup on your device. You will need enough space on your `rootfs_data` to install `cryptsetup` and its dependencies. Once, you have your LUKS container follow the [instructions](#instructions "docs:guide-user:additional-software:extroot_configuration ↵") above for creating the extroot filesystem on the unlocked LUKS device, including copying the `rootfs_data` files from `/overlay` to the newly created extroot.

#### PREINIT

In the PREINIT phase of boot, `mount_root` will be run, which will check for an extroot config on first the ROM device and then on the [''rootfs\_data'' device](https://github.com/openwrt/fstools/blob/master/libfstools/overlay.c#L439 "https://github.com/openwrt/fstools/blob/master/libfstools/overlay.c#L439") (see [The OpenWrt Flash Layout](/docs/techref/flash.layout "docs:techref:flash.layout") for more on the flash layout). Using a stock OpenWRT firmware, there will be no extroot config on the ROM device. To check the `rootfs_data` filesystem, `mount_root` will [mount the filesystem to a temporary location](https://github.com/openwrt/fstools/blob/master/libfstools/overlay.c#L431 "https://github.com/openwrt/fstools/blob/master/libfstools/overlay.c#L431") (`/tmp/overlay`), check the file `/tmp/overlay/etc/config/fstab`, which is the same fstab configured above, for a configured extroot. If found, it will search in order `/tmp/overlay/upper/sbin/block`, `/tmp/overlay/sbin/block`, and `/sbin/block` for the presence of the block binary, and if it finds one will [run that binary](https://github.com/openwrt/fstools/blob/master/libfstools/extroot.c#L69 "https://github.com/openwrt/fstools/blob/master/libfstools/extroot.c#L69") with the `extroot` argument. This is why the `block-mount` package must be installed for extroot to work.

Because `mount_root` which is running from the ROM in the PREINIT phase attempts to run `block` from the overlay filesystem, we can use this as a way to inject commands/code into the PREINIT phase before the extroot check takes place. This is done by creating a script to replace the `block` binary which will be in charge of setting up the encrypted device, getting the extroot filesystem visible to the system, and then running the real `block`. The script below does this while relying on the `decrypt.sh` script from the [disk encryption tutorial](/docs/guide-user/storage/disk.encryption "docs:guide-user:storage:disk.encryption"). So run `install-decrypt.sh` from there first. To install the block script, move the binary at `/sbin/block` to `/sbin/block.bin`, and move the `block` script to `/sbin/block` and make sure it has the executable permission bit set.

The `block` script checks for the existence of a special path, `/.use_crypt_extroot` on the mounted overlayfs or `/upper/.use_crypt_extroot` on the `/overlay` filesystem, to determine if it should use do its magic. So if this file does not exist, the extroot will not be configured. This allows one to easily disable setting up the crypto disk early on, thus effectively disabling extroot. Once on the extroot, to access this file you'll need to mount the `rootfs_data`, or you could turn off the device, remove the extroot block device, and boot without it.

Once the `block` script has been properly installed, `decrypt.sh` has been installed, `/etc/crypttab` has been setup, the extroot has been configured, and `/.use_crypt_extroot` exists, then you are ready to reboot and enter your encrypted extroot.

[block](/_export/code/docs/guide-user/additional-software/extroot_configuration?codeblock=19 "Download Snippet")

```
#!/bin/sh
 
# Prereqs:
#  * packages:
#    * block-mount
#    * cryptsetup
#  * move /sbin/block to /sbin/block.bin
#  * install decrypt script to /sbin/decrypt.sh with execute permission
#
# This script should be placed at /upper/sbin/block of the UBIFS overlay,
# or /sbin/block if already on the overlayfs and be set with execute
# permission.
# It is expected that the extroot is on a device that the kernel names as
# sd* or mmcblk*, otherwise modify appropriately.
 
# Set to 1 to enable debug logs
export DEBUG=
 
SDIR=${0%/*}
BLOCK="${SDIR}/block.bin"
LD_LIBRARY_PATH=${LD_LIBRARY_PATH:-.}
LD_LIBRARY_PATH="${SDIR}/../usr/lib:${LD_LIBRARY_PATH}"
PATH=$PATH:${SDIR}:${SDIR}/../usr/sbin:${SDIR}/../usr/bin
 
block() {
  ( exec -a ${0} ${BLOCK} "$@" )
}
 
if [ "$PREINIT" != "1" ]; then
  exec block "$@"
fi
 
get_jiffies() {
  head -n3 /proc/timer_list | tail -n1 | cut -d' ' -f 3
}
 
if [ -z "$BLOCK_LOG" ] && [ -n "$DEBUG" ]; then
  TIME=$(get_jiffies)
  export BLOCK_LOG="/tmp/block.$(printf '%016d' ${TIME:-9999999999}).log"
  exec 2>"$BLOCK_LOG"
  set -x
fi
 
if [ ! -x "$BLOCK" ]; then
  echo "Error: ${BLOCK} is not an executable" >&2
  return 1
fi
 
if [ "$1" = "extroot" ] && [ -e ${SDIR}/../.use_crypt_extroot ]; then
  # We are being called to setup the extroot, so make sure crypto block
  # devices are all setup.
 
  # Hotplug runs too late, create device nodes for /dev/sd*, if there are any
  for SYSDEVPATH in /sys/class/block/sd*; do
    [ ! -f "$SYSDEVPATH"/dev ] && continue
    [ -e "/dev/${SYSDEVPATH##*/}" ] && continue
    MAJMIN=$(cat "$SYSDEVPATH"/dev | tr ':' ' ')
    mknod /dev/${SYSDEVPATH##*/} b $MAJMIN
  done
 
  # Load modules needed for cryptsetup
  KVER=$(uname -r)
  insmod ${SDIR}/../lib/modules/${KVER}/af_alg.ko
  insmod ${SDIR}/../lib/modules/${KVER}/algif_rng.ko
  insmod ${SDIR}/../lib/modules/${KVER}/algif_hash.ko
  insmod ${SDIR}/../lib/modules/${KVER}/algif_skcipher.ko
 
  # FIXME: Why does block info only show ubi devices?
#  block info | cut -d: -f1 |
  # Do this hack instead, only check scsi and mmc devices
  find /dev -type b | grep -E "/(sd|mmcblk).*" |
  while read DEVPATH; do
    cryptsetup --disable-locks isLuks $DEVPATH || continue
    export ACTION=add DEVNAME="${DEVPATH##*/}" 
    # Assume this script is located in $OVERLAY/sbin when called
    ALTROOT="${SDIR}/.." "$SDIR"/decrypt.sh || "$SDIR"/decrypt.sh
  done
fi
 
block "$@"
```

#### /etc/rc.local

There is another way to work around the current limitations. **However, it should only be used if the above method does not work for your setup, it is more prone to breaking or having strange side effects**. The basic idea is that extroot will be setup as in the [instructions](#instructions "docs:guide-user:additional-software:extroot_configuration ↵") section above, which will fail to load during the normal boot path because the extroot filesystem will not be found. This will be expected. Modifications to `/etc/rc.local` will unlock the LUKS volume at the end of the boot process when we have more control of the system and then we'll run `mount_root` again and this time it will find the extroot filesystem and switch root into it.

So at this point your uci fstab configuration should have a mount section with target `/overlay`. I use the `uuid` option instead of the `device` option so I don't need to keep the `/etc/rc.local` synchronized with `/etc/config/fstab`. Here's a relevant snippet of script that illustrates what needs to be put into `/etc/rc.local`. Currently this script will not work for LUKS volumes being opened with a password. The volume must be opened with a keyfile (stdin is not properly setup in `/etc/rc.local` so cryptsetup will fail when trying to get a password). In the script below, the key is stored at `/root/extroot.key`. Check your threat model to see if this works for you.

```
# Only setup the encrypted extroot if /.use_crypt_extroot exists on rootfs_data.
# This makes it easier disable the encrypted extroot from failsafe mode.
mkdir -p /mnt/tmp
if [ -e /.use_crypt_extroot ]; then 
  # Setup crypt device which contains the extroot
  cryptsetup open -d /root/extroot.key /dev/sda1 cextroot
  umount /overlay
 
  # /tmp will get overridden by another tmpfs by mount_root, but we need the
  # initial one because it contains the ubus named socket.
  mount --bind /tmp /mnt/tmp
 
  # Re-run mount_root now that we have a block device that it will recognize
  # as an extroot. This sleep is needed, otherwise procd seems to freak out
  # and the watchdog timer doesn't get reset. Not sure exactly why.
  sleep 5
  PREINIT=1 mount_root
 
  # Free the new tmpfs just created by mount_root. Since it will never be used,
  # its just wasting memory.
  umount -l /tmp
 
  # Put the original tmpfs back to where it was in the VFS, primarily so that
  # programs can find the ubus socket.
  mount --bind /rom/mnt/tmp /tmp
 
  # Need to re-run this too for some reason, otherwise some other mounts are not
  # mounted after mount_root, eg. /rwm.
  block mount
 
  # Reload rpcd to register rpc objects on the extroot
  service rpcd reload
fi
```

**NOTE:** Since this method is essentially redoing some of the boot process, it does take longer. On my device, its about 20-30 seconds longer for the web interface to be available. Logging in via SSH is not delayed though.

### System upgrade

This section applies to OpenWrt snapshot, but not to OpenWrt releases, as the kernel-related packages (and the packages requiring them) in releases will only receive fixes and security patches.

DO NOT try to do upgrades using `opkg upgrade`. You will likely end up with an inconsistent state and soft-bricked router that way:

- The main reason is that the uClibc ABI (Application Binary Interface) is unstable and changes from revision to revision, so binaries for one version of uClibc may be incompatible with versions from another.
- When upgrading, your \`/rom\` or \`/rwm\` partition may change UUIDs, so the extroot mounting can fail. Check the troubleshooting section for how to correct it.
- Another problem that can arise is if you try to upgrade the kernel packages, then flash and reboot, but your operation is interrupted in any way, then you will have a kernel and module mismatch and likely a brick. If you decide to upgrade anyway, be sure to have the correct kernel modules on extroot \`/upper/lib/modules\` before attempting a version upgrade.
- Finally, if you upgrade all packages but the kernel and the kernel modules, some packages like `iptables` will be broken.

Additionally, you may have to repeat steps 3 and 4 of the instructions if the ROM partition changes UUID.

It's recommended to update/reinstall all your packages, especially kernel modules, after a system upgrade.

### Custom image

This method is useful for devices with 4 MiB flash or less. In the default OpenWrt firmware images there are no tools to make extroot, as the build system currently makes only barebone images. The only way to go for these devices is to rebuild a firmware image with the right packages using the Image Builder. The Image Builder can run only in a 64bit Linux operating system, so if you don't have a linux system on hand, look up a tutorial to install Ubuntu 64bit in VirtualBox. Then go in the same download page where you can download the firmware for your device and scroll down until you find a file starting with “**OpenWrt-imagebuilder**”. Download it and extract it in a folder in the Linux system.

Open a terminal in that folder, and write:

```
make info
```

This will write on screen all the possible profile names for the devices supported by that Image Builder, so we can build the image for the right device. Each entry will look like this:

```
tl-wr1043nd-v1:
    TP-LINK TL-WR1043N/ND v1
    Packages: kmod-usb-core kmod-usb2 kmod-ledtrig-usbdev
```

First line is the profile name, the second line is a full descriptive name of your device, third line is a list of default packages for that device, and should list some packages about USB or Sata or whatever other storage device.

In my case I have a TP-LINK TL-WR1043N/ND v1, so the profile name for my device is **tl-wr1043nd-v1** Now you need to write the command to start building the image (note how the name after the **PROFILE=** is my device's profile name, please use the profile name for yours):

```
make image PROFILE=tl-wr1043nd-v1 PACKAGES="block-mount kmod-fs-ext4 kmod-usb-storage kmod-usb-ohci kmod-usb-uhci"
```

This will build a firmware image that is able to read a partition formatted with ext4 filesystem. Sadly the package **e2fsprogs** with the tools for ext4 filesystem is too large to fit in 4 MiB devices.

Afterwards, open the folder **bin** inside the Image Builder folder, then open the **target** folder, then the folder you find in it (it has a device-type-specific name), and then inside a folder called **generic** and you should reach the flashable images. Choose the right image (factory or sysupgrade) and install it.

Then you will have to format the USB drive with ext4 filesystem, and to do that you will need to use a Linux LiveCD or [gparted](https://gparted.org/livecd.php "https://gparted.org/livecd.php") disk. Sadly this is inconvenient but as said above we cannot fit formatting tools in devices with 4MB of flash.

### Automated setup

You can use the [openwrt-auto-extroot](/docs/guide-developer/imagebuilder_frontends#openwrt-auto-extroot "docs:guide-developer:imagebuilder_frontends") ImageBuilder frontend to build a custom firmware image that will automatically format and set up extroot on **any** plugged-in, but not yet setup storage device.

### Automated upgrade

Set up [Hotplug extras](/docs/guide-user/advanced/hotplug_extras "docs:guide-user:advanced:hotplug_extras") and [Opkg extras](/docs/guide-user/advanced/opkg_extras "docs:guide-user:advanced:opkg_extras"). Packages required by Extroot should be saved in the `init` Opkg profile and restored automatically after upgrade following by the script to reconfigure Extroot.

```
cat << "EOF" > /etc/uci-defaults/90-extroot-restore
if uci -q get fstab.extroot > /dev/null \
&& [ ! -e /etc/extroot-restore ] \
&& [ -e /etc/opkg-restore-init ] \
&& lock -n /var/lock/extroot-restore
then
UUID="$(uci -q get fstab.extroot.uuid)"
DIR="$(uci -q get fstab.extroot.target)"
DEV="$(block info | sed -n -e "/${UUID}/s/:.*$//p")"
if touch /etc/extroot-restore \
&& grep -q -e "\s${DIR}\s" /etc/mtab \
&& mount "${DEV}" /mnt
then
BAK="$(mktemp -d -p /mnt -t bak.XXXXXX)"
mv -f /mnt/etc /mnt/upper "${BAK}"
cp -f -a "${DIR}"/. /mnt
umount "${DEV}"
fi
lock -u /var/lock/extroot-restore
reboot
fi
exit 1
EOF
cat << "EOF" >> /etc/sysupgrade.conf
/etc/uci-defaults
EOF
```
