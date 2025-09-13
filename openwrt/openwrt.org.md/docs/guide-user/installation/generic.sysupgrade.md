# Upgrading OpenWrt firmware using LuCI and CLI

See also:

- [OpenWrt flash Layout](/docs/techref/flash.layout "docs:techref:flash.layout")
- [Upgrading OpenWrt firmware using CLI](/docs/guide-user/installation/sysupgrade.cli "docs:guide-user:installation:sysupgrade.cli")
- [Upgrading OpenWrt firmware using LuCI](/docs/guide-quick-start/sysupgrade.luci "docs:guide-quick-start:sysupgrade.luci")
- [Keep Settings and Upgrade Compatibility](/docs/guide-quick-start/admingui_sysupgrade_keepsettings#upgrade_compatibility "docs:guide-quick-start:admingui_sysupgrade_keepsettings")
- [Saving/restoring user-installed packages](/docs/guide-user/installation/sysupgrade.packages "docs:guide-user:installation:sysupgrade.packages")

## How the OpenWrt upgrade works

An OpenWrt **sysupgrade** will replace the entire current OpenWrt installation with a new version. This includes the Linux kernel and SquashFS/ext4/ubifs/JFFS2/other OS partition/s. This is NOT the same as a first time installation (factory).

Sysupgrade via LuCI or CLI works by optionally saving specified configuration files, **wiping the entire file system**, installing the new version of OpenWrt and then restoring back the saved configuration files. **This means that any parts of the file system that are not specifically saved will be lost.**

In particular, any manually installed software packages you may have installed after the initial OpenWrt installation have to be reinstalled after an OpenWrt upgrade. That way everything will match, e.g. the updated Linux kernel and any installed kernel modules.

Any configuration files or data files placed in locations not specifically listed as being preserved below will also be lost in an OpenWrt upgrade. Be sure to check any files you have added or customized from a default OpenWrt install to back up these items before an upgrade.

**IMPORTANT:** Most of the upgrade procedure can be automated by using the [attended.sysupgrade](/docs/guide-user/installation/attended.sysupgrade "docs:guide-user:installation:attended.sysupgrade") service. Attended sysupgrade will request the build of custom image including all your currently installed packages from a central server, download it when ready, and install it keeping your settings. The service can be accessed from LuCI by installing the \`luci-app-attendedsysupgrade\` package, or from the shell with the \`auc\` package. Note that you can upgrade systems using attended sysupgrade via LuCI even if they are not connected to the internet, as long as your browser has internet access.

See [this howto](https://web.archive.org/web/20220919082336/https://blog.mbirth.de/archives/2014/05/26/openwrt-sysupgrade-with-extroot.html "https://web.archive.org/web/20220919082336/https://blog.mbirth.de/archives/2014/05/26/openwrt-sysupgrade-with-extroot.html") about extroot procedure.

For [Dual Firmware Devices](/tag/dual_firmware "tag:dual_firmware") please consult your device page for additional information.

By compiling your own custom image with an OpenWrt buildroot or generating with the imagebuilder, it is possible to remove the need to perform many of the steps above.

## Upgrade steps

### 1. Prepare

The first part of the upgrade process is to prepare for the upgrade.

1. Setup for data migration ( keep settings ) and additional sysupgrade.conf entries
2. Export / save installed package list / manifest
3. Obtain / verify new installation sysupgrade image (and current / known good one to revert to)

This includes documenting programs and settings that will need to be re-installed or restored after the upgrade, locating and downloading the correct OpenWrt upgrade image for your hardware.

When it is possible to 'keep settings' sysupgrade will automatically preserve much of the OpenWrt OS configuration by saving and then restoring configuration files in specific common locations (including `/etc/config`). This will preserve things like OpenWrt network settings, Wi-Fi settings, the device hostname, and so on. Some data files and directories for additional services will need to be configured manually.

### 2. Upgrade

Next is the actual upgrade. The two common upgrade methods to perform the upgrade are:

- LuCI web interface System → Backup / Flash Firmware → “Flash new firmware image”
- Command-line using `sysupgrade` command over console or ssh

Both use the same `...sysupgrade.bin/img.gz` file (more below).

### 3. Post Install Configuration, Setup or Restore

After the OS upgrade, there are usually some additional configuration steps required to;

- Re-install additional packages not part of the base OpenWrt install
- Configure new OpenWrt functionality or to
- Update configuration files to reflect new settings or updated packages

Please see the section below with more details.

## Preparing for upgrade

### Can you keep settings?

See also: [Upgrade compatibility](/docs/guide-quick-start/admingui_sysupgrade_keepsettings#upgrade_compatibility "docs:guide-quick-start:admingui_sysupgrade_keepsettings")

Most of the time you can, jumping several versions, downgrading, if the release notes or upgrade message informs you it's not possible, then you will need to plan ahead of time and factor in the time and information required to re-apply some or most of your previous configuration manually.

1. It is worthwhile not keeping settings once every 12-16 months
2. Trying to get around the advice to start with new settings when needed can result in odd issues that can be difficult to troubleshoot

### Will you need to revert?

A time may come when you attempt an upgrade and for whatever reason it is unsuccessful. Contingency planning is a good skill for anything in IT.

1. Have you made a backup of your current settings? (for restoration to same or earlier OS versions)
2. Do you have a copy of your current (pre-upgrade) OS version if you need to re-install? (both factory and sysupgrade or even vendor firmware may be required)
3. Do you have a spare device in case things go pear shaped or you need much more time than expected?

### Configure your backup

Follow [Backup and restore](/docs/guide-user/troubleshooting/backup_restore "docs:guide-user:troubleshooting:backup_restore"), or skip this section if you do not want to preserve existing configuration.

### Downloading the OpenWrt upgrade image

#### Getting the right image

In most cases, platforms that support sysupgrade, have a downloadable image labelled **`...-sysupgrade.bin`** ...

- Images labelled “factory” or otherwise are generally not intended to be installed via an existing OpenWrt web interface.
  
  - FIRMWARE SELECTOR [https://firmware-selector.openwrt.org/](https://firmware-selector.openwrt.org/ "https://firmware-selector.openwrt.org/")
  - SEARCH USING MODEL: [Table of Hardware: Firmware downloads](/toh/views/toh_fwdownload "toh:views:toh_fwdownload")
  - OFFICIAL DOWNLOAD PAGE: [https://downloads.openwrt.org/releases/](https://downloads.openwrt.org/releases/ "https://downloads.openwrt.org/releases/")

#### OpenWrt on x86

For x86, use the same image you used for your initial installation of OpenWrt as the sysupgrade image as well (that is, there is no “factory” versus “sysupgrade” variant in contrast to most embedded devices). So, if you installed OpenWrt x86-64 `openwrt-version-number-x86-64-combined-ext4.img.gz`, you need to choose same image to do a sysupgrade; if you installed Openwrt with `openwrt-version-number-x86-64-combined-squashfs.img.gz`, you need that image to do a firmware upgrade.

#### Notes

WARNING: Double check you have the exact model number and in some cases country... If in any doubt about compatibility, read instructions on your device page thoroughly. If your are still unsure ask on the Forum.

NOTE: Keep a copy of images you use, you never know if you may need them again and that may be difficult if your internet is down! If you do not have current version of your system image download it from [https://firmware-selector.openwrt.org/](https://firmware-selector.openwrt.org/ "https://firmware-selector.openwrt.org/") prior to performing upgrade. You can check which version you use using luci main page or command line:

```
ubus call system board
```

#### Finding out which x86 image was used during installation

If system images used during initial instalation were deleted or lost and you forgot which image you used during installation, here is how you can check it.

Generic x86 system images come either in squashfs (RO) or ext4 (RW) flavour, first check file system type which you have on your device.

```
root@OpenWRT:~# df -T
```

sample output from x86 OpenWRT installation using squashfs file system:

```
Filesystem           Type       1K-blocks      Used Available Use% Mounted on
/dev/root            squashfs        4352      4352         0 100% /rom
tmpfs                tmpfs        1928268        84   1928184   0% /tmp
/dev/loop0           ext4       117464126     13802 112445660   0% /overlay
overlayfs:/overlay   overlay    117464126     13802 112445660   0% /
/dev/sda1            vfat           16334      6274     10060  38% /boot
/dev/sda1            vfat           16334      6274     10060  38% /boot
tmpfs                tmpfs            512         0       512   0% /dev
```

sample output from x86 OpenWRT installation using ext4 file system:

```
Filesystem           Type       1K-blocks      Used Available Use% Mounted on
/dev/root            ext4        30845052    321868  30506800   1% /
tmpfs                tmpfs        3912440      1596   3910844   0% /tmp
/dev/sda1            vfat           16334      6274     10060  38% /boot
/dev/sda1            vfat           16334      6274     10060  38% /boot
tmpfs                tmpfs            512         0       512   0% /dev
```

Now check if you used -efi system image. If the output of the command below is *no such file or directory* you used a openwrt-XX.XX.X-x86-64-generic-ext4-**combined**.img.gz system image. If the folder existst and is populated you used a openwrt-XX.XX.X-x86-64-generic-ext4-**combined-efi**.img.gz system image.

```
root@OpenWRT:~# ls /sys/firmware/efi
ls: /sys/firmware/efi: No such file or directory
```

## Upgrade procedure

### For LuCI-based upgrades

See also: [Upgrading OpenWrt firmware using LuCI](/docs/guide-quick-start/sysupgrade.luci "docs:guide-quick-start:sysupgrade.luci")

- Download the desired upgrade file to your PC using a web browser
- Proceed to the LuCI upgrade procedure, below

#### Web interface instructions

1. Navigate to **LuCI → System → Backup / Flash Firmware → Actions: Flash new firmware image**.
2. Click **Choose File** button to select firmware image.
3. Click **Flash image...** to upload firmware image.
4. [Verify](/docs/guide-quick-start/verify_firmware_checksum "docs:guide-quick-start:verify_firmware_checksum") firmware image checksum and proceed.
5. Wait until the router comes back online.

### Command-line instructions

OpenWrt provides [sysupgrade](/docs/techref/sysupgrade "docs:techref:sysupgrade") utility for firmware upgrade procedure.

- See CLI instructions page below:
  
  - [Upgrading OpenWrt firmware using CLI](/docs/guide-user/installation/sysupgrade.cli "docs:guide-user:installation:sysupgrade.cli")

#### For sysupgrade cli based upgrades

- Download the desired upgrade file to the local /tmp RAM drive on your OpenWrt system. The `/tmp` directory is stored in RAM (using [tmpfs](https://en.wikipedia.org/wiki/tmpfs "https://en.wikipedia.org/wiki/tmpfs")), not in the permanent flash storage.

```
# example downloading the OpenWrt 15.05 upgrade image for a TP-LINK TL-WR1043ND ver. 1.x router
cd /tmp
wget http://downloads.openwrt.org/chaos_calmer/15.05/ar71xx/generic/openwrt-15.05-ar71xx-generic-tl-wr1043nd-v1-squashfs-sysupgrade.bin
 
# check the integrity of the image file via md5sums (older images)
wget http://downloads.openwrt.org/chaos_calmer/15.05/ar71xx/generic/md5sums
md5sum -c md5sums 2> /dev/null | grep OK
 
# check the integrity of the image file via sha256sums
wget http://downloads.openwrt.org/chaos_calmer/15.05/ar71xx/generic/sha256sums
sha256sum -c sha256sums 2> /dev/null | grep OK
 
# the desired result is that the downloaded firmware filename is listed with "OK" afterwards
 
####################################################
# Initiate sysupgrade with your desired options
# by default ( no -n ) settings are kept
####################################################
sysupgrade -v /tmp/openwrt-15.05-ar71xx-generic-tl-wr1043nd-v1-squashfs-sysupgrade.bin
```

NOTE: see extras at end of page for low memory device workarounds

## Extras

### Verify the new OS version

- In LuCI, go to Status &gt; Overview to verify you are running the new OpenWrt release
- In SSH, the login banner has the release information

### Upgrade installed packages

Follow: [Upgrading packages](/docs/guide-user/additional-software/opkg#upgrading_packages "docs:guide-user:additional-software:opkg")

After the initial update, it is good to check for any updated packages released after the base OS firmware image was built. Note that on a device with only 4MB of NVRAM, these updates may not fit – check free space first with `df -h /` and ensure there is at least 600KB or so free.

### Reinstall user-installed packages

See also: [Preserving packages](/docs/guide-user/installation/sysupgrade.packages "docs:guide-user:installation:sysupgrade.packages")

After a successful upgrade, you will need to reinstall all previously installed and saved packages.

### Configure user-installed packages

See also: [Comparing configurations](/docs/guide-user/installation/sysupgrade.cli#comparing_new_package_config_options "docs:guide-user:installation:sysupgrade.cli")

The new package installations will have installed new, default versions of package configuration files. If existing configuration files are in place, opkg displays a warning about this and saves the new configuration file versions under `/etc/config/*-opkg` filenames.

The new package-provided config files should be compared with your older customized files to merge in any new options or changes of syntax. The `diff` tool is helpful for this.
